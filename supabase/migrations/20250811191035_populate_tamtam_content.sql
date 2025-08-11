-- Tam Tam Content Population Migration
-- This migration populates existing schema with realistic social-fi content

-- Clear existing data safely (maintain referential integrity)
DELETE FROM wallet_transactions;
DELETE FROM notifications WHERE content_id IS NOT NULL;
DELETE FROM content_interactions;
DELETE FROM comments;
DELETE FROM user_relationships;
DELETE FROM content;
DELETE FROM wallets;
DELETE FROM user_profiles WHERE id != 'auth.uid()'; -- Keep current user if exists
DELETE FROM auth.users WHERE email NOT LIKE '%@test.com'; -- Keep test users

-- Insert realistic user profiles for viral content creators
INSERT INTO auth.users (id, email, encrypted_password, email_confirmed_at, created_at, updated_at, raw_app_meta_data, raw_user_meta_data, is_super_admin, role) VALUES
  ('550e8400-e29b-41d4-a716-446655440001', 'mia.dancer@test.com', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '{"provider":"email","providers":["email"]}', '{}', false, 'authenticated'),
  ('550e8400-e29b-41d4-a716-446655440002', 'alex.comedy@test.com', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '{"provider":"email","providers":["email"]}', '{}', false, 'authenticated'),
  ('550e8400-e29b-41d4-a716-446655440003', 'zara.lifestyle@test.com', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '{"provider":"email","providers":["email"]}', '{}', false, 'authenticated'),
  ('550e8400-e29b-41d4-a716-446655440004', 'dj.beats@test.com', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '{"provider":"email","providers":["email"]}', '{}', false, 'authenticated'),
  ('550e8400-e29b-41d4-a716-446655440005', 'kai.travel@test.com', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '{"provider":"email","providers":["email"]}', '{}', false, 'authenticated'),
  ('550e8400-e29b-41d4-a716-446655440006', 'luna.art@test.com', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '{"provider":"email","providers":["email"]}', '{}', false, 'authenticated'),
  ('550e8400-e29b-41d4-a716-446655440007', 'ryan.fitness@test.com', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '{"provider":"email","providers":["email"]}', '{}', false, 'authenticated'),
  ('550e8400-e29b-41d4-a716-446655440008', 'elena.food@test.com', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '{"provider":"email","providers":["email"]}', '{}', false, 'authenticated');

-- Insert viral content creators with realistic stats
INSERT INTO user_profiles (id, username, full_name, email, bio, avatar_url, cover_image_url, followers_count, following_count, clout_score, verified, total_tips_received, role, country_code, language_preference, created_at) VALUES
  ('550e8400-e29b-41d4-a716-446655440001', 'mia_moves', 'Mia Rodriguez', 'mia.dancer@test.com', '💃 Dance challenges & tutorials | 2M+ hearts | Miami vibes ✨', 'https://images.unsplash.com/photo-1494790108755-2616b612b47c?w=400', 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=800', 2847392, 1284, 9850, true, 45892.50, 'creator'::user_role, 'US', 'en', NOW() - INTERVAL '2 years'),
  ('550e8400-e29b-41d4-a716-446655440002', 'alex_laughs', 'Alex Chen', 'alex.comedy@test.com', '😂 Making you laugh daily | Comedy skits & pranks | LA comedian 🎭', 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400', 'https://images.unsplash.com/photo-1519389950473-47ba0277781c?w=800', 1923847, 892, 8974, true, 32145.75, 'creator'::user_role, 'US', 'en', NOW() - INTERVAL '18 months'),
  ('550e8400-e29b-41d4-a716-446655440003', 'zara_glow', 'Zara Johnson', 'zara.lifestyle@test.com', '✨ Lifestyle & beauty tips | Self-care queen | NYC influencer 💄', 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=400', 'https://images.unsplash.com/photo-1522202176988-66273c2fd55f?w=800', 1456923, 2847, 7832, true, 28934.25, 'creator'::user_role, 'US', 'en', NOW() - INTERVAL '14 months'),
  ('550e8400-e29b-41d4-a716-446655440004', 'dj_vibes', 'Marcus Thompson', 'dj.beats@test.com', '🎵 Beats that move your soul | EDM producer | Live sets every Friday 🔥', 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=400', 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=800', 987234, 445, 6789, true, 19847.80, 'creator'::user_role, 'US', 'en', NOW() - INTERVAL '10 months'),
  ('550e8400-e29b-41d4-a716-446655440005', 'kai_explorer', 'Kai Williams', 'kai.travel@test.com', '🌍 Travel adventures & hidden gems | Digital nomad | Currently in Bali 🏝️', 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400', 'https://images.unsplash.com/photo-1469474968028-56623f02e42e?w=800', 743928, 3284, 5943, false, 15634.90, 'creator'::user_role, 'US', 'en', NOW() - INTERVAL '8 months'),
  ('550e8400-e29b-41d4-a716-446655440006', 'luna_creates', 'Luna Park', 'luna.art@test.com', '🎨 Digital art & NFT drops | Crypto artist | Building the metaverse ⚡', 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=400', 'https://images.unsplash.com/photo-1541701494587-cb58502866ab?w=800', 592847, 1847, 4756, false, 22847.35, 'creator'::user_role, 'KR', 'en', NOW() - INTERVAL '6 months'),
  ('550e8400-e29b-41d4-a716-446655440007', 'ryan_strong', 'Ryan Davis', 'ryan.fitness@test.com', '💪 Fitness motivation daily | Home workout guru | Transform your body 🔥', 'https://images.unsplash.com/photo-1566492031773-4f4e44671d66?w=400', 'https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?w=800', 834752, 628, 6234, false, 17293.45, 'creator'::user_role, 'CA', 'en', NOW() - INTERVAL '7 months'),
  ('550e8400-e29b-41d4-a716-446655440008', 'elena_tastes', 'Elena Rossi', 'elena.food@test.com', '🍝 Authentic Italian recipes | Food blogger | Mama\'s secret recipes 👩‍🍳', 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=400', 'https://images.unsplash.com/photo-1490818387583-1baba5e638af?w=800', 445923, 1234, 4589, false, 12847.25, 'creator'::user_role, 'IT', 'en', NOW() - INTERVAL '5 months');

-- Create wallets for all users
INSERT INTO wallets (user_id, usd_balance, tam_token_balance, btc_balance, eth_balance, total_earned, total_spent) VALUES
  ('550e8400-e29b-41d4-a716-446655440001', 15847.25, 89473.50, 0.00234567, 0.523456789012345678, 48392.75, 32545.50),
  ('550e8400-e29b-41d4-a716-446655440002', 12934.80, 67329.25, 0.00156432, 0.387291234567890123, 35847.20, 22912.40),
  ('550e8400-e29b-41d4-a716-446655440003', 18293.40, 94857.75, 0.00298765, 0.645123456789012345, 31847.85, 13554.45),
  ('550e8400-e29b-41d4-a716-446655440004', 9847.60, 45329.80, 0.00089432, 0.234567890123456789, 22893.40, 13045.80),
  ('550e8400-e29b-41d4-a716-446655440005', 7234.90, 38474.25, 0.00067891, 0.189012345678901234, 18937.15, 11702.25),
  ('550e8400-e29b-41d4-a716-446655440006', 11847.35, 56234.70, 0.00134567, 0.345678901234567890, 25893.45, 14046.10),
  ('550e8400-e29b-41d4-a716-446655440007', 8593.45, 41847.30, 0.00098765, 0.278901234567890123, 19847.90, 11254.45),
  ('550e8400-e29b-41d4-a716-446655440008', 6947.25, 34829.85, 0.00076543, 0.156789012345678901, 15293.50, 8346.25);

-- Create viral content with realistic engagement
INSERT INTO content (id, creator_id, type, title, description, video_url, thumbnail_url, audio_url, tags, view_count, like_count, comment_count, share_count, tip_count, total_tips_amount, featured, location, created_at) VALUES
  ('660e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440001', 'video'::content_type, 'Viral Dance Challenge', 'The new trending dance that everyone is doing! Who wants to duet? 💃✨', 'https://assets.mixkit.co/videos/preview/mixkit-girl-in-neon-sign-1232-large.mp4', 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=600', 'https://assets.mixkit.co/music/preview/mixkit-tech-house-vibes-130.mp3', ARRAY['dance', 'viral', 'trending', 'challenge', 'duet'], 4892847, 847293, 23847, 18492, 847, 12483.75, true, 'Miami, FL', NOW() - INTERVAL '3 days'),
  ('660e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440002', 'video'::content_type, 'Epic Prank Gone Right', 'Pranking my roommate with fake lottery ticket 😂 His reaction is PRICELESS!', 'https://assets.mixkit.co/videos/preview/mixkit-man-under-multicolored-lights-1237-large.mp4', 'https://images.unsplash.com/photo-1519389950473-47ba0277781c?w=600', 'https://assets.mixkit.co/music/preview/mixkit-happy-indie-folk-acoustic-upbeat-102.mp3', ARRAY['comedy', 'prank', 'funny', 'reaction', 'viral'], 2847392, 394857, 15847, 9482, 394, 5847.25, true, 'Los Angeles, CA', NOW() - INTERVAL '1 day'),
  ('660e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440003', 'video'::content_type, '10-Minute Glow Up', 'Transform your look in 10 minutes! ✨ These tips will change your life', 'https://assets.mixkit.co/videos/preview/mixkit-woman-running-above-the-camera-40142-large.mp4', 'https://images.unsplash.com/photo-1522202176988-66273c2fd55f?w=600', 'https://assets.mixkit.co/music/preview/mixkit-a-very-happy-christmas-897.mp3', ARRAY['beauty', 'makeup', 'transformation', 'tips', 'selfcare'], 1847293, 284729, 8472, 5847, 284, 4283.50, false, 'New York, NY', NOW() - INTERVAL '5 hours'),
  ('660e8400-e29b-41d4-a716-446655440004', '550e8400-e29b-41d4-a716-446655440004', 'video'::content_type, 'Friday Night Mix', 'Live DJ set from my rooftop studio 🎵 Drop your song requests below!', 'https://assets.mixkit.co/videos/preview/mixkit-dj-playing-music-4220-large.mp4', 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=600', 'https://assets.mixkit.co/music/preview/mixkit-tech-house-vibes-130.mp3', ARRAY['music', 'dj', 'electronic', 'live', 'edm'], 947382, 147384, 3847, 2847, 147, 2847.90, false, 'Chicago, IL', NOW() - INTERVAL '2 hours'),
  ('660e8400-e29b-41d4-a716-446655440005', '550e8400-e29b-41d4-a716-446655440005', 'video'::content_type, 'Hidden Bali Temple', 'Found this incredible hidden temple in Ubud 🏛️ The locals showed me secret paths!', 'https://assets.mixkit.co/videos/preview/mixkit-landscape-of-a-sunny-temple-in-japan-4267-large.mp4', 'https://images.unsplash.com/photo-1469474968028-56623f02e42e?w=600', 'https://assets.mixkit.co/music/preview/mixkit-peaceful-fashion-night-658.mp3', ARRAY['travel', 'adventure', 'bali', 'temple', 'hidden'], 584729, 84729, 2847, 1847, 84, 1847.45, false, 'Ubud, Bali', NOW() - INTERVAL '8 hours'),
  ('660e8400-e29b-41d4-a716-446655440006', '550e8400-e29b-41d4-a716-446655440006', 'image'::content_type, 'NFT Art Drop', 'My latest digital art piece just dropped! 🎨 Only 100 copies available', NULL, 'https://images.unsplash.com/photo-1541701494587-cb58502866ab?w=600', NULL, ARRAY['nft', 'digitalart', 'crypto', 'art', 'exclusive'], 384729, 47384, 1847, 2384, 238, 4738.80, false, 'Seoul, South Korea', NOW() - INTERVAL '6 hours'),
  ('660e8400-e29b-41d4-a716-446655440007', '550e8400-e29b-41d4-a716-446655440007', 'video'::content_type, '30-Day Transformation', 'My incredible fitness journey results! 💪 No gym needed, just dedication', 'https://assets.mixkit.co/videos/preview/mixkit-athlete-running-on-a-treadmill-28465-large.mp4', 'https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?w=600', 'https://assets.mixkit.co/music/preview/mixkit-deep-urban-623.mp3', ARRAY['fitness', 'transformation', 'motivation', 'workout', 'health'], 647384, 94738, 4738, 2847, 94, 1847.25, false, 'Toronto, Canada', NOW() - INTERVAL '12 hours'),
  ('660e8400-e29b-41d4-a716-446655440008', '550e8400-e29b-41d4-a716-446655440008', 'video'::content_type, 'Nonna\'s Secret Recipe', 'Making authentic carbonara the way my Nonna taught me 🍝 No cream allowed!', 'https://assets.mixkit.co/videos/preview/mixkit-chef-cooking-4262-large.mp4', 'https://images.unsplash.com/photo-1490818387583-1baba5e638af?w=600', 'https://assets.mixkit.co/music/preview/mixkit-italian-afternoon-923.mp3', ARRAY['cooking', 'italian', 'recipe', 'traditional', 'food'], 384756, 47382, 2847, 1738, 47, 947.50, false, 'Rome, Italy', NOW() - INTERVAL '4 hours');

-- Add follower relationships (realistic social network)
INSERT INTO user_relationships (follower_id, following_id, type) VALUES
  -- Mia (top creator) has many mutual follows
  ('550e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440001', 'following'::relationship_type),
  ('550e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440001', 'following'::relationship_type),
  ('550e8400-e29b-41d4-a716-446655440004', '550e8400-e29b-41d4-a716-446655440001', 'following'::relationship_type),
  ('550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440002', 'following'::relationship_type),
  ('550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440003', 'following'::relationship_type),
  -- Cross-creator follows for realistic network
  ('550e8400-e29b-41d4-a716-446655440005', '550e8400-e29b-41d4-a716-446655440006', 'following'::relationship_type),
  ('550e8400-e29b-41d4-a716-446655440006', '550e8400-e29b-41d4-a716-446655440005', 'following'::relationship_type),
  ('550e8400-e29b-41d4-a716-446655440007', '550e8400-e29b-41d4-a716-446655440001', 'following'::relationship_type),
  ('550e8400-e29b-41d4-a716-446655440008', '550e8400-e29b-41d4-a716-446655440003', 'following'::relationship_type);

-- Add realistic content interactions
INSERT INTO content_interactions (user_id, content_id, interaction_type) VALUES
  -- Viral dance video interactions
  ('550e8400-e29b-41d4-a716-446655440002', '660e8400-e29b-41d4-a716-446655440001', 'like'),
  ('550e8400-e29b-41d4-a716-446655440003', '660e8400-e29b-41d4-a716-446655440001', 'like'),
  ('550e8400-e29b-41d4-a716-446655440004', '660e8400-e29b-41d4-a716-446655440001', 'like'),
  ('550e8400-e29b-41d4-a716-446655440005', '660e8400-e29b-41d4-a716-446655440001', 'like'),
  ('550e8400-e29b-41d4-a716-446655440006', '660e8400-e29b-41d4-a716-446655440001', 'share'),
  -- Comedy video interactions  
  ('550e8400-e29b-41d4-a716-446655440001', '660e8400-e29b-41d4-a716-446655440002', 'like'),
  ('550e8400-e29b-41d4-a716-446655440003', '660e8400-e29b-41d4-a716-446655440002', 'like'),
  ('550e8400-e29b-41d4-a716-446655440007', '660e8400-e29b-41d4-a716-446655440002', 'share'),
  -- Beauty content interactions
  ('550e8400-e29b-41d4-a716-446655440001', '660e8400-e29b-41d4-a716-446655440003', 'like'),
  ('550e8400-e29b-41d4-a716-446655440008', '660e8400-e29b-41d4-a716-446655440003', 'like');

-- Add engaging comments
INSERT INTO comments (user_id, content_id, text_content, like_count) VALUES
  ('550e8400-e29b-41d4-a716-446655440002', '660e8400-e29b-41d4-a716-446655440001', 'This dance is FIRE! 🔥 Teaching this to my followers tomorrow!', 847),
  ('550e8400-e29b-41d4-a716-446655440003', '660e8400-e29b-41d4-a716-446655440001', 'Obsessed with this choreo! Tutorial please? 💃✨', 394),
  ('550e8400-e29b-41d4-a716-446655440004', '660e8400-e29b-41d4-a716-446655440001', 'Playing this at my next set for sure! The beat is perfect 🎵', 234),
  ('550e8400-e29b-41d4-a716-446655440001', '660e8400-e29b-41d4-a716-446655440002', 'Alex you are INSANE! 😂 I cant stop laughing!', 1284),
  ('550e8400-e29b-41d4-a716-446655440003', '660e8400-e29b-41d4-a716-446655440002', 'His face when he realized it was fake 💀💀💀', 847),
  ('550e8400-e29b-41d4-a716-446655440001', '660e8400-e29b-41d4-a716-446655440003', 'Zara always serving LOOKS! ✨ Need that lipstick shade!', 584),
  ('550e8400-e29b-41d4-a716-446655440005', '660e8400-e29b-41d4-a716-446655440005', 'Bali is magical! Adding this to my travel list 🏛️', 147),
  ('550e8400-e29b-41d4-a716-446655440007', '660e8400-e29b-41d4-a716-446655440007', 'Bro your transformation is incredible! What was your routine?', 284);

-- Add wallet transactions (tips, earnings, etc.)
INSERT INTO wallet_transactions (from_user_id, to_user_id, wallet_id, amount, currency, transaction_type, status, metadata) VALUES
  -- Tips for viral content
  ('550e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440001', (SELECT id FROM wallets WHERE user_id = '550e8400-e29b-41d4-a716-446655440001'), 25.50, 'tam_token'::wallet_currency, 'tip', 'completed'::payment_status, '{"content_id": "660e8400-e29b-41d4-a716-446655440001", "message": "Amazing dance! 💃"}'),
  ('550e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440001', (SELECT id FROM wallets WHERE user_id = '550e8400-e29b-41d4-a716-446655440001'), 50.00, 'tam_token'::wallet_currency, 'tip', 'completed'::payment_status, '{"content_id": "660e8400-e29b-41d4-a716-446655440001", "message": "Love this choreo! ✨"}'),
  ('550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440002', (SELECT id FROM wallets WHERE user_id = '550e8400-e29b-41d4-a716-446655440002'), 35.75, 'tam_token'::wallet_currency, 'tip', 'completed'::payment_status, '{"content_id": "660e8400-e29b-41d4-a716-446655440002", "message": "You crack me up! 😂"}'),
  -- Creator earnings from platform
  (NULL, '550e8400-e29b-41d4-a716-446655440001', (SELECT id FROM wallets WHERE user_id = '550e8400-e29b-41d4-a716-446655440001'), 1284.50, 'tam_token'::wallet_currency, 'creator_bonus', 'completed'::payment_status, '{"reason": "viral_content_bonus", "views": 4892847}'),
  (NULL, '550e8400-e29b-41d4-a716-446655440002', (SELECT id FROM wallets WHERE user_id = '550e8400-e29b-41d4-a716-446655440002'), 847.25, 'tam_token'::wallet_currency, 'creator_bonus', 'completed'::payment_status, '{"reason": "trending_content", "engagement_rate": 0.82}');

-- Add notifications for recent activities
INSERT INTO notifications (user_id, sender_id, content_id, type, title, message, data) VALUES
  ('550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440002', '660e8400-e29b-41d4-a716-446655440001', 'like'::notification_type, 'New Like', 'alex_laughs liked your dance video', '{"interaction_type": "like"}'),
  ('550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440003', NULL, 'follow'::notification_type, 'New Follower', 'zara_glow started following you', '{}'),
  ('550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440002', '660e8400-e29b-41d4-a716-446655440001', 'tip'::notification_type, 'You received a tip!', 'alex_laughs tipped you 25.50 TAM tokens', '{"amount": 25.50, "currency": "tam_token"}'),
  ('550e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440001', '660e8400-e29b-41d4-a716-446655440002', 'comment'::notification_type, 'New Comment', 'mia_moves commented on your video', '{"comment": "Alex you are INSANE! 😂"}'),
  ('550e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440008', NULL, 'follow'::notification_type, 'New Follower', 'elena_tastes started following you', '{}');

-- Update content engagement stats based on interactions
UPDATE content SET 
  like_count = (SELECT COUNT(*) FROM content_interactions WHERE content_id = content.id AND interaction_type = 'like'),
  share_count = (SELECT COUNT(*) FROM content_interactions WHERE content_id = content.id AND interaction_type = 'share'),
  comment_count = (SELECT COUNT(*) FROM comments WHERE content_id = content.id)
WHERE id IN ('660e8400-e29b-41d4-a716-446655440001', '660e8400-e29b-41d4-a716-446655440002', '660e8400-e29b-41d4-a716-446655440003');

RAISE NOTICE 'Tam Tam content populated successfully with viral creators and engaging content!';