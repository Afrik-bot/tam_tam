-- Location: supabase/migrations/20250812024540_populate_sample_video_content.sql
-- Schema Analysis: Complete TamTam schema exists with content, user_profiles, and interactions
-- Integration Type: Addition - Adding sample content for video feed
-- Dependencies: content, user_profiles tables (existing)

-- COMPLETE_EXISTS: All functionality exists in schema
-- ACTION: Add more sample video content to populate the feed

-- Function to populate sample video content for TamTam
DO $$
DECLARE
    sample_user_ids UUID[];
    video_urls TEXT[] := ARRAY[
        'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4',
        'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_2mb.mp4',
        'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
        'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
        'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4'
    ];
    thumbnail_base TEXT := 'https://picsum.photos/400/600?random=';
    current_video_url TEXT;
    current_thumbnail TEXT;
    i INTEGER := 1;
BEGIN
    -- Get existing user IDs from user_profiles
    SELECT ARRAY_AGG(id) INTO sample_user_ids 
    FROM public.user_profiles 
    WHERE is_active = true 
    LIMIT 10;
    
    -- If no users found, create some sample users first
    IF array_length(sample_user_ids, 1) IS NULL OR array_length(sample_user_ids, 1) = 0 THEN
        RAISE NOTICE 'No active users found. Please ensure user_profiles table has data.';
        RETURN;
    END IF;
    
    -- Generate sample video content
    WHILE i <= 15 LOOP
        current_video_url := video_urls[((i - 1) % array_length(video_urls, 1)) + 1];
        current_thumbnail := thumbnail_base || i::TEXT;
        
        INSERT INTO public.content (
            creator_id,
            type,
            title,
            description,
            video_url,
            thumbnail_url,
            view_count,
            like_count,
            comment_count,
            share_count,
            tip_count,
            total_tips_amount,
            tags,
            location,
            is_public,
            allows_comments,
            allows_duets,
            featured
        ) VALUES (
            sample_user_ids[((i - 1) % array_length(sample_user_ids, 1)) + 1],
            'video'::public.content_type,
            CASE 
                WHEN i % 5 = 1 THEN 'Amazing Dance Moves 🔥'
                WHEN i % 5 = 2 THEN 'Cooking Masterclass in 60 Seconds'
                WHEN i % 5 = 3 THEN 'Travel Vlog: Hidden Gems'
                WHEN i % 5 = 4 THEN 'DIY Home Hacks You Need'
                ELSE 'Daily Life Adventures'
            END,
            CASE 
                WHEN i % 5 = 1 THEN 'Check out these incredible dance moves! Perfect for beginners and pros alike. Tag your dance partner! #dance #moves #trending'
                WHEN i % 5 = 2 THEN 'Learn this amazing recipe that will blow your mind! Quick, easy, and delicious. Perfect for busy weekdays 👨‍🍳 #cooking #recipe #foodie'
                WHEN i % 5 = 3 THEN 'Discovering the most beautiful hidden locations that most people never see. Adventure awaits! 🌍 #travel #adventure #explore'
                WHEN i % 5 = 4 THEN 'These life hacks will save you time and money! Try them out and let me know which one is your favorite ⚡ #lifehacks #diy #tips'
                ELSE 'Just another day living my best life! Sometimes the simple moments are the most beautiful ones ✨ #lifestyle #daily #positivity'
            END,
            current_video_url,
            current_thumbnail,
            (random() * 100000 + 1000)::INTEGER,
            (random() * 5000 + 100)::INTEGER,
            (random() * 500 + 10)::INTEGER,
            (random() * 1000 + 50)::INTEGER,
            (random() * 50)::INTEGER,
            (random() * 1000)::NUMERIC(10,2),
            CASE 
                WHEN i % 5 = 1 THEN ARRAY['dance', 'trending', 'moves', 'viral']
                WHEN i % 5 = 2 THEN ARRAY['cooking', 'recipe', 'food', 'tutorial']
                WHEN i % 5 = 3 THEN ARRAY['travel', 'adventure', 'explore', 'nature']
                WHEN i % 5 = 4 THEN ARRAY['lifehacks', 'diy', 'tips', 'useful']
                ELSE ARRAY['lifestyle', 'daily', 'life', 'positive']
            END,
            CASE 
                WHEN i % 8 = 1 THEN 'New York, NY'
                WHEN i % 8 = 2 THEN 'Los Angeles, CA'
                WHEN i % 8 = 3 THEN 'Miami, FL'
                WHEN i % 8 = 4 THEN 'Chicago, IL'
                WHEN i % 8 = 5 THEN 'Austin, TX'
                WHEN i % 8 = 6 THEN 'Seattle, WA'
                WHEN i % 8 = 7 THEN 'Denver, CO'
                ELSE NULL
            END,
            true,
            true,
            i % 3 != 0, -- Allow duets for most videos
            i % 7 = 1   -- Feature some videos
        );
        
        i := i + 1;
    END LOOP;
    
    -- Add some sample interactions for the content
    DECLARE
        content_ids UUID[];
        user_id UUID;
        content_id UUID;
        j INTEGER := 1;
    BEGIN
        -- Get the newly created content IDs
        SELECT ARRAY_AGG(id) INTO content_ids 
        FROM public.content 
        WHERE created_at > NOW() - INTERVAL '1 minute'
        LIMIT 15;
        
        -- Add some likes and interactions
        FOREACH content_id IN ARRAY content_ids LOOP
            -- Add some random likes from different users
            FOR k IN 1..((random() * 5 + 1)::INTEGER) LOOP
                user_id := sample_user_ids[((k - 1) % array_length(sample_user_ids, 1)) + 1];
                
                INSERT INTO public.content_interactions (user_id, content_id, interaction_type)
                VALUES (user_id, content_id, 'like')
                ON CONFLICT (user_id, content_id, interaction_type) DO NOTHING;
            END LOOP;
            
            -- Add some random shares
            IF random() > 0.5 THEN
                user_id := sample_user_ids[1];
                INSERT INTO public.content_interactions (user_id, content_id, interaction_type)
                VALUES (user_id, content_id, 'share')
                ON CONFLICT (user_id, content_id, interaction_type) DO NOTHING;
            END IF;
        END LOOP;
    END;
    
    -- Add some sample comments
    DECLARE
        sample_comments TEXT[] := ARRAY[
            'This is amazing! Love it 🔥',
            'Can you do a tutorial on this?',
            'So creative and inspiring!',
            'This made my day better ✨',
            'Definitely trying this at home!',
            'You are so talented!',
            'More content like this please',
            'This is exactly what I needed today',
            'Incredible work, keep it up!',
            'Thanks for sharing this!'
        ];
        comment_text TEXT;
    BEGIN
        FOREACH content_id IN ARRAY content_ids LOOP
            -- Add 1-3 random comments per video
            FOR k IN 1..((random() * 3 + 1)::INTEGER) LOOP
                user_id := sample_user_ids[((k - 1) % array_length(sample_user_ids, 1)) + 1];
                comment_text := sample_comments[((k - 1) % array_length(sample_comments, 1)) + 1];
                
                INSERT INTO public.comments (content_id, user_id, text_content)
                VALUES (content_id, user_id, comment_text);
            END LOOP;
        END LOOP;
    END;

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error populating sample content: %', SQLERRM;
END $$;

-- Update content statistics based on actual interactions
UPDATE public.content 
SET 
    like_count = (
        SELECT COUNT(*) FROM public.content_interactions 
        WHERE content_id = public.content.id AND interaction_type = 'like'
    ),
    comment_count = (
        SELECT COUNT(*) FROM public.comments 
        WHERE content_id = public.content.id
    ),
    share_count = (
        SELECT COUNT(*) FROM public.content_interactions 
        WHERE content_id = public.content.id AND interaction_type = 'share'
    )
WHERE created_at > NOW() - INTERVAL '1 hour';

-- Add function to clean up sample data if needed
CREATE OR REPLACE FUNCTION public.cleanup_sample_video_data()
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- Delete sample interactions first (children)
    DELETE FROM public.content_interactions 
    WHERE content_id IN (
        SELECT id FROM public.content 
        WHERE title ILIKE '%dance%' 
        OR title ILIKE '%cooking%' 
        OR title ILIKE '%travel%'
        OR title ILIKE '%diy%'
        OR title ILIKE '%daily life%'
    );
    
    -- Delete sample comments
    DELETE FROM public.comments 
    WHERE content_id IN (
        SELECT id FROM public.content 
        WHERE title ILIKE '%dance%' 
        OR title ILIKE '%cooking%' 
        OR title ILIKE '%travel%'
        OR title ILIKE '%diy%'
        OR title ILIKE '%daily life%'
    );
    
    -- Delete sample content last (parent)
    DELETE FROM public.content 
    WHERE title ILIKE '%dance%' 
    OR title ILIKE '%cooking%' 
    OR title ILIKE '%travel%'
    OR title ILIKE '%diy%'
    OR title ILIKE '%daily life%';
    
    RAISE NOTICE 'Sample video content cleaned up successfully';
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Cleanup failed: %', SQLERRM;
END;
$$;

-- Grant execute permission on the cleanup function
GRANT EXECUTE ON FUNCTION public.cleanup_sample_video_data() TO authenticated;

COMMENT ON FUNCTION public.cleanup_sample_video_data() IS 'Removes sample video content and related data for testing purposes';