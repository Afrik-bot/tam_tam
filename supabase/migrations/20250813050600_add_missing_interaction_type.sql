-- Fix interaction_type enum creation and column conversion
-- The content_interactions table already exists with text column, we need to convert it to enum

-- First create the enum type (outside DO block)
DO $$ 
BEGIN
    -- Check if enum type already exists
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'interaction_type') THEN
        EXECUTE 'CREATE TYPE public.interaction_type AS ENUM (''like'', ''share'', ''save'', ''report'')';
    END IF;
END $$;

-- Convert existing text column to enum type
DO $$ 
BEGIN
    -- Check if column exists and needs conversion
    IF EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_name = 'content_interactions' 
        AND column_name = 'interaction_type'
        AND data_type = 'text'
    ) THEN
        -- First ensure all existing data has valid enum values
        UPDATE public.content_interactions 
        SET interaction_type = 'like' 
        WHERE interaction_type NOT IN ('like', 'share', 'save', 'report') 
        OR interaction_type IS NULL;
        
        -- Convert column to enum type
        ALTER TABLE public.content_interactions 
        ALTER COLUMN interaction_type TYPE public.interaction_type 
        USING interaction_type::public.interaction_type;
        
        -- Set default value
        ALTER TABLE public.content_interactions 
        ALTER COLUMN interaction_type SET DEFAULT 'like'::public.interaction_type;
        
    ELSIF NOT EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_name = 'content_interactions' 
        AND column_name = 'interaction_type'
    ) THEN
        -- Add the column if it doesn't exist at all
        ALTER TABLE public.content_interactions 
        ADD COLUMN interaction_type public.interaction_type NOT NULL DEFAULT 'like'::public.interaction_type;
    END IF;
    
    -- Create indexes for better performance if they don't exist
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_content_interactions_type') THEN
        CREATE INDEX idx_content_interactions_type 
        ON public.content_interactions(interaction_type);
    END IF;
    
    -- Create composite index for common queries if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_content_interactions_user_content_type') THEN
        CREATE INDEX idx_content_interactions_user_content_type 
        ON public.content_interactions(user_id, content_id, interaction_type);
    END IF;
END $$;

-- Update RLS policies to work with the new structure
DROP POLICY IF EXISTS "users_manage_own_interactions" ON public.content_interactions;
DROP POLICY IF EXISTS "public_can_view_interaction_counts" ON public.content_interactions;

-- Create proper RLS policies
CREATE POLICY "users_manage_own_interactions"
ON public.content_interactions FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- Allow public to view interaction counts
CREATE POLICY "public_can_view_interaction_counts"
ON public.content_interactions FOR SELECT
TO public
USING (true);

-- Ensure we have sample data with proper interaction types
DO $$
DECLARE
    sample_user_id UUID;
    sample_content_id UUID;
    another_content_id UUID;
BEGIN
    -- Get sample user and content IDs
    SELECT id INTO sample_user_id FROM public.user_profiles LIMIT 1;
    SELECT id INTO sample_content_id FROM public.content WHERE type = 'video'::public.content_type LIMIT 1;
    SELECT id INTO another_content_id FROM public.content WHERE type = 'video'::public.content_type OFFSET 1 LIMIT 1;
    
    -- Insert sample interactions if we have data to work with
    IF sample_user_id IS NOT NULL AND sample_content_id IS NOT NULL THEN
        INSERT INTO public.content_interactions (user_id, content_id, interaction_type) 
        VALUES 
            (sample_user_id, sample_content_id, 'like'::public.interaction_type),
            (sample_user_id, COALESCE(another_content_id, sample_content_id), 'share'::public.interaction_type)
        ON CONFLICT (user_id, content_id, interaction_type) DO NOTHING;
    END IF;
END $$;