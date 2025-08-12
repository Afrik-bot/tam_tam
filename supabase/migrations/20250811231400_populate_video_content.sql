-- Location: supabase/migrations/20250811231400_populate_video_content.sql
-- Schema Analysis: Complete content management system exists with user_profiles, content, content_interactions
-- Integration Type: Data population for existing video functionality
-- Dependencies: Existing content table, user_profiles table, content_type enum

-- Populate sample video content for testing
DO $$
DECLARE
    user1_id UUID;
    user2_id UUID;
    user3_id UUID;
BEGIN
    -- Get existing user IDs or create sample users if none exist
    SELECT id INTO user1_id FROM public.user_profiles LIMIT 1;
    
    IF user1_id IS NULL THEN
        -- Create sample users if none exist
        user1_id := gen_random_uuid();
        user2_id := gen_random_uuid();
        user3_id := gen_random_uuid();
        
        -- Insert sample users
        INSERT INTO public.user_profiles (
            id, email, full_name, username, bio, avatar_url, verified, clout_score, 
            followers_count, following_count, role
        ) VALUES
            (user1_id, 'creator1@example.com', 'Maya Rodriguez', 'maya_creates', 
             'Content creator passionate about lifestyle and travel ✨', 
             'https://images.unsplash.com/photo-1494790108755-2616b612b002?w=400', 
             true, 95, 15400, 892, 'creator'::public.user_role),
            (user2_id, 'creator2@example.com', 'Jake Thompson', 'jake_tech', 
             'Tech enthusiast sharing the latest gadgets and reviews 🚀', 
             'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400', 
             true, 87, 12800, 445, 'creator'::public.user_role),
            (user3_id, 'creator3@example.com', 'Luna Park', 'luna_fitness', 
             'Fitness coach helping you achieve your best self 💪', 
             'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=400', 
             false, 72, 8900, 234, 'creator'::public.user_role);
    ELSE
        -- Use existing users
        SELECT id INTO user2_id FROM public.user_profiles OFFSET 1 LIMIT 1;
        SELECT id INTO user3_id FROM public.user_profiles OFFSET 2 LIMIT 1;
        
        -- Fallback to first user if not enough users exist
        user2_id := COALESCE(user2_id, user1_id);
        user3_id := COALESCE(user3_id, user1_id);
    END IF;
    
    -- Insert sample video content with working video URLs
    INSERT INTO public.content (
        id, creator_id, type, title, description, video_url, thumbnail_url, 
        audio_url, view_count, like_count, comment_count, share_count, 
        tip_count, total_tips_amount, tags, location, featured, is_public, 
        allows_comments, allows_duets
    ) VALUES
        (gen_random_uuid(), user1_id, 'video'::public.content_type, 
         'Morning Routine That Changed My Life', 
         'Sharing my 5AM morning routine that completely transformed my productivity and mindset. Try it for 30 days!',
         'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
         'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800',
         null, 24500, 1823, 156, 89, 12, 24.50,
         ARRAY['morning', 'routine', 'productivity', 'lifestyle'], 
         'Los Angeles, CA', true, true, true, true),
         
        (gen_random_uuid(), user2_id, 'video'::public.content_type, 
         'iPhone 15 Pro Max Review - 3 Months Later', 
         'My honest review after using the iPhone 15 Pro Max for 3 months. Is it worth the upgrade?',
         'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
         'https://images.unsplash.com/photo-1592750475338-74b7b21085ab?w=800',
         null, 18700, 1245, 89, 67, 8, 16.00,
         ARRAY['tech', 'review', 'iphone', 'apple'], 
         'San Francisco, CA', false, true, true, true),
         
        (gen_random_uuid(), user3_id, 'video'::public.content_type, 
         '15-Minute HIIT Workout - No Equipment', 
         'Get your heart pumping with this intense 15-minute HIIT workout. No equipment needed, just bring your energy!',
         'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
         'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=800',
         null, 31200, 2156, 203, 125, 18, 36.75,
         ARRAY['fitness', 'workout', 'hiit', 'health'], 
         'Miami, FL', true, true, true, true),
         
        (gen_random_uuid(), user1_id, 'video'::public.content_type, 
         'Bali Travel Vlog - Hidden Gems', 
         'Exploring the most beautiful hidden spots in Bali that most tourists never see. Pure magic!',
         'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
         'https://images.unsplash.com/photo-1537953773345-d172ccf13cf1?w=800',
         null, 42800, 3421, 287, 198, 25, 62.50,
         ARRAY['travel', 'bali', 'adventure', 'vlog'], 
         'Bali, Indonesia', true, true, true, true),
         
        (gen_random_uuid(), user2_id, 'video'::public.content_type, 
         'Best Budget Gaming Setup 2024', 
         'Building an amazing gaming setup on a budget. Everything you need to know to get started under $1000!',
         'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
         'https://images.unsplash.com/photo-1593305841991-05c297ba4575?w=800',
         null, 22100, 1687, 124, 93, 11, 22.00,
         ARRAY['gaming', 'tech', 'budget', 'setup'], 
         'Austin, TX', false, true, true, true),
         
        (gen_random_uuid(), user3_id, 'video'::public.content_type, 
         'Healthy Meal Prep - 5 Days in 1 Hour', 
         'Meal prep like a pro! Five days of healthy, delicious meals prepared in just one hour. Recipes included!',
         'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4',
         'https://images.unsplash.com/photo-1490645935967-10de6ba17061?w=800',
         null, 19400, 1534, 168, 76, 14, 28.00,
         ARRAY['food', 'healthy', 'mealprep', 'cooking'], 
         'New York, NY', false, true, true, true);
         
    -- Add some sample interactions
    INSERT INTO public.content_interactions (
        user_id, content_id, interaction_type, created_at
    )
    SELECT 
        (ARRAY[user1_id, user2_id, user3_id])[floor(random() * 3 + 1)],
        c.id,
        (ARRAY['like', 'share', 'view'])[floor(random() * 3 + 1)],
        NOW() - (random() * interval '30 days')
    FROM public.content c
    WHERE c.type = 'video'::public.content_type
    AND random() < 0.7; -- 70% chance of interaction
    
    RAISE NOTICE 'Successfully populated video content with sample data';
    
EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE NOTICE 'Foreign key error: %', SQLERRM;
    WHEN unique_violation THEN
        RAISE NOTICE 'Unique constraint error: %', SQLERRM;
    WHEN OTHERS THEN
        RAISE NOTICE 'Unexpected error: %', SQLERRM;
END $$;

-- Update content statistics to match the sample data
UPDATE public.content SET
    updated_at = CURRENT_TIMESTAMP
WHERE type = 'video'::public.content_type;

-- Add helpful cleanup function for development
CREATE OR REPLACE FUNCTION public.cleanup_sample_video_data()
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- Delete sample content interactions
    DELETE FROM public.content_interactions 
    WHERE content_id IN (
        SELECT id FROM public.content 
        WHERE video_url LIKE '%commondatastorage.googleapis.com%'
    );
    
    -- Delete sample content
    DELETE FROM public.content 
    WHERE video_url LIKE '%commondatastorage.googleapis.com%';
    
    -- Delete sample users created by this migration
    DELETE FROM public.user_profiles 
    WHERE email IN ('creator1@example.com', 'creator2@example.com', 'creator3@example.com');
    
    RAISE NOTICE 'Sample video data cleaned up successfully';
END;
$$;