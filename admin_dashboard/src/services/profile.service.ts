import { apiClient } from "./api.service";
import { API_ENDPOINTS } from "../constants/api.constants";
import type { ApiResponse } from "../types/common.types";

// Profile types based on backend ProfileResponseDTO
export interface Profile {
  id: number;
  userId: number;
  firstName?: string;
  lastName?: string;
  displayName?: string;
  bio?: string;
  birthDate?: string;
  gender?: string;
  location?: string;
  jobTitle?: string;
  company?: string;
  education?: string;
  height?: number;
  bodyType?: string;
  ethnicity?: string;
  religion?: string;
  politicalView?: string;
  drinkStatus?: string;
  smokeStatus?: string;
  hasChildren?: boolean;
  wantChildren?: boolean;
  hasPets?: boolean;
  languages?: string[];
  interests?: string[];
  lookingFor?: string;
  relationshipType?: string;
  isVerified?: boolean;
  photos?: ProfilePhoto[];
  preferences?: ProfilePreferences;
  createdAt?: string;
  updatedAt?: string;
}

export interface ProfilePhoto {
  id: number;
  url: string;
  type: "AVATAR" | "COVER" | "HIGHLIGHT";
  isMain?: boolean;
  order?: number;
}

export interface ProfilePreferences {
  ageRange?: {
    min: number;
    max: number;
  };
  maxDistance?: number;
  interestedIn?: string[];
  showOnlineStatus?: boolean;
  showDistance?: boolean;
  showAge?: boolean;
}

export interface ProfileOptions {
  genders: string[];
  bodyTypes: string[];
  ethnicities: string[];
  religions: string[];
  politicalViews: string[];
  drinkStatuses: string[];
  smokeStatuses: string[];
  relationshipTypes: string[];
  languages: string[];
  interests: string[];
  educationLevels: string[];
  jobIndustries: string[];
}

export class ProfileService {
  // Get profile by user ID
  async getProfile(userId: string): Promise<ApiResponse<Profile>> {
    try {
      return await apiClient.get<Profile>(API_ENDPOINTS.PROFILE.BY_ID(userId));
    } catch (error) {
      return {
        success: false,
        error: error instanceof Error ? error.message : "Failed to get profile",
      };
    }
  }

  // Get current admin's profile
  async getMyProfile(): Promise<ApiResponse<Profile>> {
    try {
      return await apiClient.get<Profile>(API_ENDPOINTS.AUTH.PROFILE);
    } catch (error) {
      return {
        success: false,
        error:
          error instanceof Error ? error.message : "Failed to get my profile",
      };
    }
  }

  // Update current admin's profile
  async updateProfile(
    profileData: Partial<Profile>
  ): Promise<ApiResponse<Profile>> {
    try {
      return await apiClient.patch<Profile>(
        API_ENDPOINTS.AUTH.PROFILE,
        profileData
      );
    } catch (error) {
      return {
        success: false,
        error:
          error instanceof Error ? error.message : "Failed to update profile",
      };
    }
  }

  // Get profile configuration options
  async getProfileOptions(): Promise<ApiResponse<ProfileOptions>> {
    try {
      return await apiClient.get<ProfileOptions>(
        API_ENDPOINTS.PROFILE.OPTIONS
      );
    } catch (error) {
      return {
        success: false,
        error:
          error instanceof Error
            ? error.message
            : "Failed to get profile options",
      };
    }
  }

  // Helper method to get user's basic info for admin dashboard
  async getUserBasicInfo(userId: string): Promise<
    ApiResponse<{
      id: number;
      name: string;
      avatar?: string;
      age?: number;
      location?: string;
      isVerified?: boolean;
    }>
  > {
    try {
      const response = await this.getProfile(userId);

      if (response.success && response.data) {
        const profile = response.data;
        const basicInfo = {
          id: profile.userId,
          name:
            profile.displayName ||
            `${profile.firstName || ""} ${profile.lastName || ""}`.trim(),
          avatar: profile.photos?.find((p) => p.type === "AVATAR")?.url,
          age: profile.birthDate
            ? this.calculateAge(profile.birthDate)
            : undefined,
          location: profile.location,
          isVerified: profile.isVerified,
        };

        return {
          success: true,
          data: basicInfo,
        };
      }

      return {
        success: false,
        error: response.error || "Failed to get user info",
      };
    } catch (error) {
      return {
        success: false,
        error:
          error instanceof Error ? error.message : "Failed to get user info",
      };
    }
  }

  private calculateAge(birthDate: string): number {
    const today = new Date();
    const birth = new Date(birthDate);
    let age = today.getFullYear() - birth.getFullYear();
    const monthDiff = today.getMonth() - birth.getMonth();

    if (
      monthDiff < 0 ||
      (monthDiff === 0 && today.getDate() < birth.getDate())
    ) {
      age--;
    }

    return age;
  }
}

export const profileService = new ProfileService();
