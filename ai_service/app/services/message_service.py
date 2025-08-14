"""
Message service for Amoura AI Service.

This module provides the MessageService class for handling AI-powered
message editing using Google Gemini API.
"""

import google.generativeai as genai
from typing import Optional, Dict, List
from sqlalchemy.orm import Session
from fastapi import HTTPException, status

from app.core.config import get_settings
from app.core.exceptions import ExternalAPIError
from app.core.logging import LoggerMixin
from app.db import crud


class MessageService(LoggerMixin):
    """
    Service for AI-powered message editing.
    
    This service uses Google Gemini API to provide intelligent
    message editing capabilities with conversation context awareness.
    """
    
    def __init__(self, db: Session):
        """
        Initialize MessageService.
        
        Args:
            db: Database session
        """
        self.db = db
        self.settings = get_settings()
        
        # Configure Gemini API
        if not self.settings.GEMINI_API_KEY:
            raise ValueError("Gemini API key not configured")
        
        genai.configure(api_key=self.settings.GEMINI_API_KEY)
        self.model = genai.GenerativeModel('gemini-2.5-flash')
        
        self.logger.info("MessageService initialized successfully")
    
    def edit_message(
        self, 
        original_message: str, 
        edit_prompt: str, 
        user_id: int, 
        other_user_id: int
    ) -> str:
        """
        Edit a message using Gemini AI based on the user's prompt.
        
        This method:
        1. Validates both users exist
        2. Retrieves conversation history from database
        3. Creates context-aware system prompt
        4. Uses Gemini AI to edit the message
        5. Returns the edited message
        
        Args:
            original_message: The original message to edit
            edit_prompt: The user's instructions for editing
            user_id: ID of the user requesting the edit
            other_user_id: ID of the other user in the conversation
            
        Returns:
            The edited message
            
        Raises:
            HTTPException: If users not found or editing fails
        """
        self.logger.info(f"Editing message for user {user_id} in conversation with user {other_user_id}")
        
        try:
            # Validate users exist
            self._validate_users_exist(user_id, other_user_id)
            
            # Retrieve conversation history
            messages = crud.get_message_history(self.db, user_id, other_user_id)
            conversation_history = crud.format_messages_for_ai(messages, user_id)
            
            if not messages:
                self.logger.warning(f"No conversation history found between users {user_id} and {other_user_id}")
            
            # Fetch concise profile context for both users (no bio, capped length)
            user_profile_raw = crud.get_user_profile_raw_data(self.db, user_id)
            other_profile_raw = crud.get_user_profile_raw_data(self.db, other_user_id)
            user_profile_summary = self._summarize_profile(user_profile_raw) if user_profile_raw else None
            other_profile_summary = self._summarize_profile(other_profile_raw) if other_profile_raw else None

            # Include profile context only if relevant to the user's instruction or recent topics
            if not self._should_include_profile_context(
                edit_prompt=edit_prompt,
                original_message=original_message,
                conversation_history=conversation_history,
            ):
                user_profile_summary = None
                other_profile_summary = None

            # Create system prompt with conversation + profile context (stage-aware)
            system_prompt = self._create_system_prompt(
                conversation_history=conversation_history,
                user_profile_summary=user_profile_summary,
                other_profile_summary=other_profile_summary,
            )
            
            # Create user prompt with stage hint and trimmed inputs
            user_prompt = self._create_user_prompt(
                original_message,
                edit_prompt,
                conversation_history,
            )
            
            # Generate edited message using Gemini
            edited_message = self._generate_edited_message(system_prompt, user_prompt)
            
            self.logger.info(f"Successfully edited message for user {user_id}")
            return edited_message
            
        except HTTPException:
            raise
        except Exception as e:
            self.logger.error(f"Error editing message: {e}")
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="An error occurred while editing the message. Please try again."
            )
    
    def _validate_users_exist(self, user_id: int, other_user_id: int):
        """
        Validate that both users exist in the database.
        
        Args:
            user_id: First user ID
            other_user_id: Second user ID
            
        Raises:
            HTTPException: If either user not found
        """
        user = crud.get_user_by_id(self.db, user_id)
        if not user:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"User with ID {user_id} not found."
            )
        
        other_user = crud.get_user_by_id(self.db, other_user_id)
        if not other_user:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Other user with ID {other_user_id} not found."
            )
    
    def _create_system_prompt(
        self,
        conversation_history: Optional[List[Dict]] = None,
        user_profile_summary: Optional[str] = None,
        other_profile_summary: Optional[str] = None,
    ) -> str:
        """Create a stage-aware, concise system prompt with context.

        Includes:
        - Stage guidance (early vs ongoing)
        - Known concise profile context (no bio)
        - Recent messages (trimmed)
        """
        msg_count = len(conversation_history) if conversation_history else 0
        stage = "early" if msg_count <= 6 else "ongoing"

        system_prompt = f"""
        You are an expert dating coach and message editor for a dating app.
        Your job is to rewrite the user's message per their instructions so it feels
        natural and effective for a dating conversation.

        STAGE-AWARE TONE (stage: {stage}):
        - Prefer light, friendly, genuine curiosity.
        - Be cautious with premature intimacy at early stage; if the USER EXPLICITLY asks to express strong feelings (e.g., "I love you"), keep that intent and phrase it gently, sincerely, and respectfully for the stage.
        - Be respectful; gentle flirting only when appropriate.

        CORE PRINCIPLES:
        1) HONOR EXPLICIT USER INTENT in the instructions; do not change the topic.
        2) Preserve the user's personality while improving clarity and tone.
        3) Improve readability: clean grammar, concise wording, natural flow.
        4) Encourage conversation with at most one short, relevant question if it fits.
        5) Do not invent facts or over-promise; no assumptions about the relationship.
        6) Keep it culturally neutral and respectful; no manipulation.

        REWRITE RULES:
        - If the original feels too intense for the stage, soften to a warm, sincere,
          getting-to-know-you vibe without grand declarations.
        - When instructions request expressing love/affection, keep that message; you may soften wording (e.g., acknowledging boldness) but do not remove the core sentiment.
        - Produce a single, concise message. No explanations.
        - Avoid filler like leading "So," and avoid stacking multiple questions.
        - Keep the same language as the original. No emojis unless already present or requested.

        RELEVANCE RULES FOR CONTEXT:
        - Only mention profile details if they are directly relevant to the USER INSTRUCTIONS or to the RECENT MESSAGES topics.
        - Do NOT introduce unrelated details from profiles (e.g., pets) when the instruction is about a different topic (e.g., expressing affection).

        OUTPUT FORMAT:
        - Return ONLY the edited message text.
        """

        # Compact profile context (no bio, short, factual)
        context_lines: List[str] = []
        if user_profile_summary:
            context_lines.append(f"You: {user_profile_summary}")
        if other_profile_summary:
            context_lines.append(f"Other person: {other_profile_summary}")
        if context_lines:
            system_prompt += """

            KNOWN CONTEXT (use only if relevant; do not invent details):
            """ + "\n".join(f"- {line}" for line in context_lines)

        # Add trimmed recent messages (oldest→newest)
        if conversation_history:
            MAX_MSGS = 6
            MAX_PER_MSG = 200
            trimmed = []
            start = max(0, len(conversation_history) - MAX_MSGS)
            for m in conversation_history[start:]:
                role = m.get("role", "user")
                content = (m.get("content", "") or "").strip()
                if len(content) > MAX_PER_MSG:
                    content = content[:MAX_PER_MSG] + " …"
                trimmed.append(f"- {role}: {content}")
            if trimmed:
                system_prompt += """

                RECENT MESSAGES (oldest→newest):
                """ + "\n".join(trimmed)

        return system_prompt
    
    def _create_user_prompt(self, original_message: str, edit_prompt: str, conversation_history: Optional[List[Dict]] = None) -> str:
        """
        Create the user prompt for Gemini.
        
        Args:
            original_message: The original message to edit
            edit_prompt: The user's instructions for editing
            conversation_history: Optional conversation history for stage hint
            
        Returns:
            The user prompt
        """
        # Trim long inputs to respect context limits
        MAX_PART = 500
        orig = (original_message or "").strip()
        instr = (edit_prompt or "").strip()
        if len(orig) > MAX_PART:
            orig = orig[:MAX_PART] + " …"
        if len(instr) > MAX_PART:
            instr = instr[:MAX_PART] + " …"

        msg_count = len(conversation_history) if conversation_history else 0
        stage = "early" if msg_count <= 6 else "ongoing"

        return f"""
        ORIGINAL MESSAGE:
        {orig}

        USER INSTRUCTIONS:
        {instr}

        CONSTRAINTS:
        - Stage: {stage}
        - Keep to one concise message; avoid over-promising or premature intimacy.
        - If the original is too intense for the stage, soften to warm and curious.
        - Return ONLY the edited message text; no preface, no explanation.
        """

    def _summarize_profile(self, raw: tuple) -> Optional[str]:
        """Create a concise, capped-length summary from get_user_profile_raw_data output.

        raw tuple shape:
          (user, profile, location, pet_names, interest_names, language_names,
           body_type_name, orientation_name, job_industry_name,
           drink_status_name, smoke_status_name, education_level_name)

        Notes:
        - Excludes bio and any long free text
        - Prioritizes: pets > interests (max 2) > languages (max 2) > location (city/state) > job industry
        - Length budget ~160 chars; drops overflow parts
        """
        try:
            (
                user,
                profile,
                location,
                pet_names,
                interest_names,
                language_names,
                body_type_name,
                orientation_name,
                job_industry_name,
                drink_status_name,
                smoke_status_name,
                education_level_name,
            ) = raw

            MAX_CHARS = 160
            MAX_INTERESTS = 2
            MAX_LANGS = 2

            parts: List[str] = []

            # Pets (compact)
            if pet_names:
                pets_lower = [p.lower() for p in pet_names]
                if any(p in pets_lower for p in ("cat", "cats")):
                    parts.append("has a cat")
                elif any(p in pets_lower for p in ("dog", "dogs")):
                    parts.append("has a dog")
                else:
                    parts.append(f"pets: {', '.join(pet_names[:1])}")

            # Interests and languages (top few)
            if interest_names:
                parts.append(f"into {', '.join(interest_names[:MAX_INTERESTS])}")
            if language_names:
                parts.append(f"speaks {', '.join(language_names[:MAX_LANGS])}")

            # Location (city/state)
            try:
                city = getattr(location, 'city', None)
                state = getattr(location, 'state', None)
                loc_bits = [bit for bit in [city, state] if bit]
                if loc_bits:
                    parts.append(f"location: {', '.join(loc_bits)}")
            except Exception:
                pass

            # Job industry (short)
            if job_industry_name:
                parts.append(f"works in {job_industry_name}")

            if not parts:
                return None

            # Enforce length by greedily adding until limit
            chosen: List[str] = []
            current = 0
            for part in parts:
                extra = len(part) if not chosen else len(part) + 2  # account for ", "
                if current + extra <= MAX_CHARS:
                    chosen.append(part)
                    current += extra
                else:
                    break

            return ", ".join(chosen) if chosen else None
        except Exception:
            return None

    def _should_include_profile_context(
        self,
        edit_prompt: str,
        original_message: str,
        conversation_history: Optional[List[Dict]] = None,
    ) -> bool:
        """Heuristically decide whether to include profile context.

        Include profiles only when the user's instruction or recent messages
        mention topics where profile facts are helpful (e.g., interests, hobbies,
        work, languages, travel, location, pets, music, food, sports, books, movies).

        This prevents injecting irrelevant details (like pets) when the
        instruction is about expressing affection or other unrelated topics.
        """
        try:
            text = f"{edit_prompt}\n{original_message}".lower()
            if conversation_history:
                # Concatenate last few messages content for quick keyword scan
                for m in conversation_history[-6:]:
                    c = (m.get("content", "") or "").lower()
                    if c:
                        text += "\n" + c

            keywords = [
                "interest", "interests", "hobby", "hobbies", "like", "likes", "favorite",
                "work", "job", "career", "industry",
                "language", "languages", "speak", "speaks",
                "travel", "trip", "city", "country", "location", "from",
                "pet", "pets", "cat", "dog",
                "music", "song", "artist", "band",
                "food", "cuisine", "restaurant",
                "sport", "sports",
                "book", "movie", "film", "series",
            ]

            return any(k in text for k in keywords)
        except Exception:
            # On any error, default to excluding profiles to avoid irrelevant injections
            return False
    
    def _generate_edited_message(self, system_prompt: str, user_prompt: str) -> str:
        """
        Generate edited message using Gemini AI.
        
        Args:
            system_prompt: System prompt for context
            user_prompt: User prompt with original message and instructions
            
        Returns:
            The edited message
            
        Raises:
            ExternalAPIError: If Gemini API call fails
        """
        try:
            # Combine system prompt and user prompt since Gemini doesn't support system role
            combined_prompt = f"{system_prompt}\n\n{user_prompt}"

            response = self.model.generate_content(combined_prompt)

            edited_message = response.text.strip()
            # Light sanitization: remove surrounding quotes if present
            if (edited_message.startswith('"') and edited_message.endswith('"')) or \
               (edited_message.startswith("'") and edited_message.endswith("'")):
                edited_message = edited_message[1:-1].strip()

            if not edited_message:
                raise ExternalAPIError(
                    api_name="Gemini",
                    error="Generated message is empty"
                )

            return edited_message

        except Exception as e:
            self.logger.error(f"Error generating response from Gemini: {e}")
            raise ExternalAPIError(
                api_name="Gemini",
                error=f"Failed to generate edited message: {e}"
            )
