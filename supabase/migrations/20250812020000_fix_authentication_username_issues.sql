-- Fix authentication username issues
-- This migration fixes the handle_new_user trigger to properly use provided username
-- and improves username validation to handle case sensitivity correctly

-- Drop and recreate the handle_new_user function with proper username handling
DROP FUNCTION IF EXISTS public.handle_new_user() CASCADE;

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    provided_username TEXT;
    generated_username TEXT;
    final_username TEXT;
    username_suffix INTEGER := 0;
BEGIN
    -- First, try to get username from metadata
    provided_username := LOWER(TRIM(NEW.raw_user_meta_data->>'username'));
    
    -- If no username provided in metadata, generate from email
    IF provided_username IS NULL OR provided_username = '' THEN
        generated_username := LOWER(TRIM(split_part(NEW.email, '@', 1)));
    ELSE
        generated_username := provided_username;
    END IF;
    
    -- Ensure username is unique by checking and appending suffix if needed
    final_username := generated_username;
    
    -- Check for conflicts and resolve them
    WHILE EXISTS (SELECT 1 FROM public.user_profiles WHERE LOWER(username) = LOWER(final_username)) LOOP
        username_suffix := username_suffix + 1;
        final_username := generated_username || '_' || username_suffix;
    END LOOP;

    -- Insert user profile with the validated unique username
    INSERT INTO public.user_profiles (
        id, 
        email, 
        username, 
        full_name, 
        role
    )
    VALUES (
        NEW.id, 
        NEW.email, 
        final_username,
        COALESCE(NEW.raw_user_meta_data->>'full_name', final_username),
        COALESCE((NEW.raw_user_meta_data->>'role')::public.user_role, 'user'::public.user_role)
    );
    
    -- Create wallet for new user
    INSERT INTO public.wallets (user_id)
    VALUES (NEW.id);
    
    RETURN NEW;
EXCEPTION
    WHEN unique_violation THEN
        -- If still getting unique violation, try with timestamp suffix
        final_username := generated_username || '_' || EXTRACT(EPOCH FROM NOW())::INTEGER;
        
        INSERT INTO public.user_profiles (
            id, 
            email, 
            username, 
            full_name, 
            role
        )
        VALUES (
            NEW.id, 
            NEW.email, 
            final_username,
            COALESCE(NEW.raw_user_meta_data->>'full_name', final_username),
            COALESCE((NEW.raw_user_meta_data->>'role')::public.user_role, 'user'::public.user_role)
        );
        
        INSERT INTO public.wallets (user_id) VALUES (NEW.id);
        RETURN NEW;
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Failed to create user profile: %', SQLERRM;
END;
$$;

-- Recreate the trigger
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Add a function to properly check username availability (case-insensitive)
CREATE OR REPLACE FUNCTION public.is_username_available(check_username TEXT)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT NOT EXISTS (
    SELECT 1 FROM public.user_profiles 
    WHERE LOWER(TRIM(username)) = LOWER(TRIM(check_username))
);
$$;

-- Add a function to suggest alternative usernames if the preferred one is taken
CREATE OR REPLACE FUNCTION public.suggest_username_alternatives(preferred_username TEXT, limit_count INTEGER DEFAULT 5)
RETURNS TEXT[]
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
AS $$
DECLARE
    base_username TEXT;
    suggestions TEXT[] := '{}';
    candidate TEXT;
    counter INTEGER := 1;
BEGIN
    base_username := LOWER(TRIM(preferred_username));
    
    -- Generate suggestions by appending numbers
    WHILE array_length(suggestions, 1) < limit_count AND counter <= 100 LOOP
        candidate := base_username || '_' || counter;
        
        IF public.is_username_available(candidate) THEN
            suggestions := array_append(suggestions, candidate);
        END IF;
        
        counter := counter + 1;
    END LOOP;
    
    -- If still no suggestions, add timestamp-based ones
    IF array_length(suggestions, 1) = 0 THEN
        suggestions := array_append(suggestions, base_username || '_' || EXTRACT(EPOCH FROM NOW())::INTEGER);
    END IF;
    
    RETURN suggestions;
END;
$$;

-- Add index for case-insensitive username lookups to improve performance
CREATE INDEX IF NOT EXISTS idx_user_profiles_username_lower 
ON public.user_profiles (LOWER(username));

-- Update existing usernames to ensure no case conflicts exist
-- This handles any existing duplicates that differ only in case
DO $$
DECLARE
    duplicate_record RECORD;
    new_username TEXT;
    suffix_counter INTEGER;
BEGIN
    -- Find usernames that have case conflicts
    FOR duplicate_record IN 
        SELECT LOWER(username) as lower_username, array_agg(id ORDER BY created_at) as user_ids
        FROM public.user_profiles 
        GROUP BY LOWER(username) 
        HAVING COUNT(*) > 1
    LOOP
        suffix_counter := 1;
        
        -- Keep the first user (oldest) with original username, modify others
        FOR i IN 2..array_length(duplicate_record.user_ids, 1) LOOP
            -- Generate new unique username
            LOOP
                new_username := duplicate_record.lower_username || '_' || suffix_counter;
                
                IF public.is_username_available(new_username) THEN
                    UPDATE public.user_profiles 
                    SET username = new_username,
                        updated_at = CURRENT_TIMESTAMP
                    WHERE id = duplicate_record.user_ids[i];
                    EXIT;
                END IF;
                
                suffix_counter := suffix_counter + 1;
            END LOOP;
        END LOOP;
    END LOOP;
    
    RAISE NOTICE 'Username conflicts resolved successfully';
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error resolving username conflicts: %', SQLERRM;
END $$;