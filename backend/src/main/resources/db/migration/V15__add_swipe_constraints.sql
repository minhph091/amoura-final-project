-- Add unique constraint to prevent duplicate swipes
ALTER TABLE swipes 
ADD CONSTRAINT unique_swipe_pair UNIQUE (initiator, target_user); 