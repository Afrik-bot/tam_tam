-- Location: supabase/migrations/20250811070305_tamtam_complete_schema.sql
-- Schema Analysis: Fresh project - creating complete TamTam social-fi schema
-- Integration Type: Complete new schema
-- Dependencies: None (fresh start)

-- 1. Extensions & Types
CREATE TYPE public.user_role AS ENUM ('creator', 'user', 'admin', 'moderator');
CREATE TYPE public.content_type AS ENUM ('video', 'image', 'text', 'live_stream');
CREATE TYPE public.payment_status AS ENUM ('pending', 'completed', 'failed', 'refunded');
CREATE TYPE public.wallet_currency AS ENUM ('usd', 'eur', 'btc', 'eth', 'tam_token');
CREATE TYPE public.relationship_type AS ENUM ('following', 'blocked', 'matched');
CREATE TYPE public.notification_type AS ENUM ('like', 'comment', 'follow', 'tip', 'mention', 'system');
CREATE TYPE public.battle_status AS ENUM ('active', 'ended', 'cancelled');

-- 2. Core Tables (no foreign keys first)

-- Essential user profiles table (auth.users intermediary)
CREATE TABLE public.user_profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id),
    email TEXT NOT NULL UNIQUE,
    username TEXT NOT NULL UNIQUE,
    full_name TEXT NOT NULL,
    bio TEXT,
    avatar_url TEXT,
    cover_image_url TEXT,
    role public.user_role DEFAULT 'user'::public.user_role,
    verified BOOLEAN DEFAULT false,
    followers_count INTEGER DEFAULT 0,
    following_count INTEGER DEFAULT 0,
    total_tips_received DECIMAL(10,2) DEFAULT 0.00,
    clout_score INTEGER DEFAULT 0,
    country_code TEXT,
    language_preference TEXT DEFAULT 'en',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Content/Posts management
CREATE TABLE public.content (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    creator_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    type public.content_type NOT NULL,
    title TEXT,
    description TEXT,
    video_url TEXT,
    thumbnail_url TEXT,
    audio_url TEXT,
    tags TEXT[],
    location TEXT,
    is_public BOOLEAN DEFAULT true,
    allows_comments BOOLEAN DEFAULT true,
    allows_duets BOOLEAN DEFAULT true,
    view_count INTEGER DEFAULT 0,
    like_count INTEGER DEFAULT 0,
    comment_count INTEGER DEFAULT 0,
    share_count INTEGER DEFAULT 0,
    tip_count INTEGER DEFAULT 0,
    total_tips_amount DECIMAL(10,2) DEFAULT 0.00,
    featured BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- User relationships (following, blocking, matching)
CREATE TABLE public.user_relationships (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    follower_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    following_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    type public.relationship_type NOT NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(follower_id, following_id)
);

-- Content interactions (likes, views, etc.)
CREATE TABLE public.content_interactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    content_id UUID REFERENCES public.content(id) ON DELETE CASCADE,
    interaction_type TEXT NOT NULL, -- 'like', 'view', 'share'
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, content_id, interaction_type)
);

-- Comments system
CREATE TABLE public.comments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    content_id UUID REFERENCES public.content(id) ON DELETE CASCADE,
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    parent_comment_id UUID REFERENCES public.comments(id) ON DELETE CASCADE,
    text_content TEXT NOT NULL,
    like_count INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Tam Tam Wallet System
CREATE TABLE public.wallets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE UNIQUE,
    usd_balance DECIMAL(10,2) DEFAULT 0.00,
    eur_balance DECIMAL(10,2) DEFAULT 0.00,
    btc_balance DECIMAL(12,8) DEFAULT 0.00000000,
    eth_balance DECIMAL(18,8) DEFAULT 0.000000000000000000,
    tam_token_balance DECIMAL(10,2) DEFAULT 0.00,
    total_earned DECIMAL(10,2) DEFAULT 0.00,
    total_spent DECIMAL(10,2) DEFAULT 0.00,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Wallet transactions
CREATE TABLE public.wallet_transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    from_user_id UUID REFERENCES public.user_profiles(id) ON DELETE SET NULL,
    to_user_id UUID REFERENCES public.user_profiles(id) ON DELETE SET NULL,
    wallet_id UUID REFERENCES public.wallets(id) ON DELETE CASCADE,
    transaction_type TEXT NOT NULL, -- 'tip', 'transfer', 'withdrawal', 'deposit', 'purchase'
    currency public.wallet_currency NOT NULL,
    amount DECIMAL(18,8) NOT NULL,
    fee_amount DECIMAL(18,8) DEFAULT 0.00000000,
    status public.payment_status DEFAULT 'pending'::public.payment_status,
    reference_id TEXT, -- External payment reference
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Live streaming battles
CREATE TABLE public.live_battles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    creator1_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    creator2_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    status public.battle_status DEFAULT 'active'::public.battle_status,
    total_tips DECIMAL(10,2) DEFAULT 0.00,
    creator1_tips DECIMAL(10,2) DEFAULT 0.00,
    creator2_tips DECIMAL(10,2) DEFAULT 0.00,
    winner_id UUID REFERENCES public.user_profiles(id) ON DELETE SET NULL,
    started_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    ended_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Stripe payment tracking
CREATE TABLE public.stripe_customers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE UNIQUE,
    stripe_customer_id TEXT UNIQUE NOT NULL,
    email TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE public.stripe_payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    stripe_payment_intent_id TEXT UNIQUE NOT NULL,
    amount INTEGER NOT NULL, -- Amount in cents
    currency TEXT DEFAULT 'usd',
    status TEXT NOT NULL,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Notifications system
CREATE TABLE public.notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    sender_id UUID REFERENCES public.user_profiles(id) ON DELETE SET NULL,
    type public.notification_type NOT NULL,
    title TEXT NOT NULL,
    message TEXT,
    content_id UUID REFERENCES public.content(id) ON DELETE SET NULL,
    read BOOLEAN DEFAULT false,
    data JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- NFT badges and collectibles
CREATE TABLE public.nft_collections (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    creator_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    description TEXT,
    image_url TEXT,
    total_supply INTEGER DEFAULT 1,
    price_per_nft DECIMAL(10,2),
    currency public.wallet_currency DEFAULT 'tam_token'::public.wallet_currency,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE public.user_nfts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    owner_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    collection_id UUID REFERENCES public.nft_collections(id) ON DELETE CASCADE,
    token_id TEXT NOT NULL,
    metadata JSONB DEFAULT '{}',
    purchased_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(collection_id, token_id)
);

-- 3. Essential Indexes for Performance
CREATE INDEX idx_user_profiles_username ON public.user_profiles(username);
CREATE INDEX idx_user_profiles_email ON public.user_profiles(email);
CREATE INDEX idx_content_creator_id ON public.content(creator_id);
CREATE INDEX idx_content_created_at ON public.content(created_at DESC);
CREATE INDEX idx_content_type ON public.content(type);
CREATE INDEX idx_user_relationships_follower ON public.user_relationships(follower_id);
CREATE INDEX idx_user_relationships_following ON public.user_relationships(following_id);
CREATE INDEX idx_content_interactions_user_content ON public.content_interactions(user_id, content_id);
CREATE INDEX idx_comments_content_id ON public.comments(content_id);
CREATE INDEX idx_comments_user_id ON public.comments(user_id);
CREATE INDEX idx_wallets_user_id ON public.wallets(user_id);
CREATE INDEX idx_wallet_transactions_wallet_id ON public.wallet_transactions(wallet_id);
CREATE INDEX idx_wallet_transactions_from_user ON public.wallet_transactions(from_user_id);
CREATE INDEX idx_wallet_transactions_to_user ON public.wallet_transactions(to_user_id);
CREATE INDEX idx_notifications_user_id ON public.notifications(user_id);
CREATE INDEX idx_notifications_read ON public.notifications(user_id, read);
CREATE INDEX idx_stripe_customers_user_id ON public.stripe_customers(user_id);
CREATE INDEX idx_stripe_payments_user_id ON public.stripe_payments(user_id);

-- 4. Functions (MUST BE BEFORE RLS POLICIES)

-- Auto-update user stats function
CREATE OR REPLACE FUNCTION public.update_user_stats()
RETURNS TRIGGER
SECURITY DEFINER
LANGUAGE plpgsql
AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        IF TG_TABLE_NAME = 'user_relationships' AND NEW.type = 'following' THEN
            -- Update follower count
            UPDATE public.user_profiles 
            SET followers_count = followers_count + 1,
                updated_at = CURRENT_TIMESTAMP
            WHERE id = NEW.following_id;
            
            -- Update following count
            UPDATE public.user_profiles 
            SET following_count = following_count + 1,
                updated_at = CURRENT_TIMESTAMP
            WHERE id = NEW.follower_id;
        END IF;
    ELSIF TG_OP = 'DELETE' THEN
        IF TG_TABLE_NAME = 'user_relationships' AND OLD.type = 'following' THEN
            -- Update follower count
            UPDATE public.user_profiles 
            SET followers_count = followers_count - 1,
                updated_at = CURRENT_TIMESTAMP
            WHERE id = OLD.following_id;
            
            -- Update following count
            UPDATE public.user_profiles 
            SET following_count = following_count - 1,
                updated_at = CURRENT_TIMESTAMP
            WHERE id = OLD.follower_id;
        END IF;
    END IF;
    
    RETURN COALESCE(NEW, OLD);
END;
$$;

-- Auto-create user profile on signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
SECURITY DEFINER
LANGUAGE plpgsql
AS $$
DECLARE
    generated_username TEXT;
BEGIN
    -- Generate username from email
    generated_username := LOWER(split_part(NEW.email, '@', 1));
    
    -- Make username unique by appending random suffix if needed
    WHILE EXISTS (SELECT 1 FROM public.user_profiles WHERE username = generated_username) LOOP
        generated_username := LOWER(split_part(NEW.email, '@', 1)) || '_' || floor(random() * 10000)::text;
    END LOOP;

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
        generated_username,
        COALESCE(NEW.raw_user_meta_data->>'full_name', generated_username),
        COALESCE((NEW.raw_user_meta_data->>'role')::public.user_role, 'user'::public.user_role)
    );
    
    -- Create wallet for new user
    INSERT INTO public.wallets (user_id)
    VALUES (NEW.id);
    
    RETURN NEW;
END;
$$;

-- Admin role check function (using auth metadata)
CREATE OR REPLACE FUNCTION public.is_admin_from_auth()
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM auth.users au
    WHERE au.id = auth.uid() 
    AND (au.raw_user_meta_data->>'role' = 'admin' 
         OR au.raw_app_meta_data->>'role' = 'admin')
)
$$;

-- 5. Enable RLS on all tables
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.content ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_relationships ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.content_interactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.wallets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.wallet_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.live_battles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.stripe_customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.stripe_payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.nft_collections ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_nfts ENABLE ROW LEVEL SECURITY;

-- 6. RLS Policies (using corrected patterns)

-- Pattern 1: Core user table (user_profiles) - Simple only, no functions
CREATE POLICY "users_manage_own_user_profiles"
ON public.user_profiles
FOR ALL
TO authenticated
USING (id = auth.uid())
WITH CHECK (id = auth.uid());

-- Pattern 4: Public read, private write for content
CREATE POLICY "public_can_view_content"
ON public.content
FOR SELECT
TO public
USING (is_public = true);

CREATE POLICY "users_manage_own_content"
ON public.content
FOR ALL
TO authenticated
USING (creator_id = auth.uid())
WITH CHECK (creator_id = auth.uid());

-- Pattern 2: Simple user ownership for relationships
CREATE POLICY "users_manage_own_relationships"
ON public.user_relationships
FOR ALL
TO authenticated
USING (follower_id = auth.uid())
WITH CHECK (follower_id = auth.uid());

CREATE POLICY "users_view_relationships_about_them"
ON public.user_relationships
FOR SELECT
TO authenticated
USING (following_id = auth.uid());

-- Pattern 2: Simple user ownership for interactions
CREATE POLICY "users_manage_own_interactions"
ON public.content_interactions
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- Pattern 4: Public read, private write for comments
CREATE POLICY "public_can_view_comments"
ON public.comments
FOR SELECT
TO public
USING (true);

CREATE POLICY "users_manage_own_comments"
ON public.comments
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- Pattern 2: Simple user ownership for wallets
CREATE POLICY "users_manage_own_wallets"
ON public.wallets
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- Pattern 2: Users can view their own transactions
CREATE POLICY "users_view_own_transactions"
ON public.wallet_transactions
FOR SELECT
TO authenticated
USING (from_user_id = auth.uid() OR to_user_id = auth.uid());

CREATE POLICY "users_create_transactions"
ON public.wallet_transactions
FOR INSERT
TO authenticated
WITH CHECK (from_user_id = auth.uid() OR to_user_id = auth.uid());

-- Pattern 4: Public read for battles
CREATE POLICY "public_can_view_battles"
ON public.live_battles
FOR SELECT
TO public
USING (true);

CREATE POLICY "creators_manage_own_battles"
ON public.live_battles
FOR ALL
TO authenticated
USING (creator1_id = auth.uid() OR creator2_id = auth.uid())
WITH CHECK (creator1_id = auth.uid() OR creator2_id = auth.uid());

-- Pattern 2: Stripe customer data
CREATE POLICY "users_manage_own_stripe_data"
ON public.stripe_customers
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

CREATE POLICY "users_view_own_payments"
ON public.stripe_payments
FOR SELECT
TO authenticated
USING (user_id = auth.uid());

-- Pattern 2: Simple user ownership for notifications
CREATE POLICY "users_manage_own_notifications"
ON public.notifications
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- Pattern 4: Public read, creator manage for NFTs
CREATE POLICY "public_can_view_nft_collections"
ON public.nft_collections
FOR SELECT
TO public
USING (true);

CREATE POLICY "creators_manage_own_collections"
ON public.nft_collections
FOR ALL
TO authenticated
USING (creator_id = auth.uid())
WITH CHECK (creator_id = auth.uid());

CREATE POLICY "users_manage_own_nfts"
ON public.user_nfts
FOR ALL
TO authenticated
USING (owner_id = auth.uid())
WITH CHECK (owner_id = auth.uid());

-- 7. Triggers
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

CREATE TRIGGER update_user_stats_on_follow
    AFTER INSERT OR DELETE ON public.user_relationships
    FOR EACH ROW EXECUTE FUNCTION public.update_user_stats();

-- 8. Storage Buckets Setup
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES 
    ('profile-images', 'profile-images', true, 5242880, ARRAY['image/jpeg', 'image/png', 'image/webp']),
    ('content-videos', 'content-videos', true, 104857600, ARRAY['video/mp4', 'video/quicktime', 'video/x-msvideo']),
    ('content-images', 'content-images', true, 10485760, ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/gif']),
    ('audio-tracks', 'audio-tracks', true, 10485760, ARRAY['audio/mpeg', 'audio/wav', 'audio/ogg']);

-- Storage RLS Policies

-- Profile images - users upload to their own folder
CREATE POLICY "users_upload_profile_images"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (
    bucket_id = 'profile-images'
    AND owner = auth.uid()
    AND (storage.foldername(name))[1] = auth.uid()::text
);

CREATE POLICY "public_view_profile_images"
ON storage.objects
FOR SELECT
TO public
USING (bucket_id = 'profile-images');

CREATE POLICY "users_manage_own_profile_images"
ON storage.objects
FOR UPDATE
TO authenticated
USING (bucket_id = 'profile-images' AND owner = auth.uid())
WITH CHECK (bucket_id = 'profile-images' AND owner = auth.uid());

CREATE POLICY "users_delete_own_profile_images"
ON storage.objects
FOR DELETE
TO authenticated
USING (bucket_id = 'profile-images' AND owner = auth.uid());

-- Content videos - creators upload, public view
CREATE POLICY "creators_upload_videos"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (
    bucket_id = 'content-videos'
    AND owner = auth.uid()
);

CREATE POLICY "public_view_videos"
ON storage.objects
FOR SELECT
TO public
USING (bucket_id = 'content-videos');

CREATE POLICY "creators_manage_own_videos"
ON storage.objects
FOR ALL
TO authenticated
USING (bucket_id = 'content-videos' AND owner = auth.uid())
WITH CHECK (bucket_id = 'content-videos' AND owner = auth.uid());

-- Content images - same as videos
CREATE POLICY "creators_upload_images"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (
    bucket_id = 'content-images'
    AND owner = auth.uid()
);

CREATE POLICY "public_view_content_images"
ON storage.objects
FOR SELECT
TO public
USING (bucket_id = 'content-images');

CREATE POLICY "creators_manage_own_content_images"
ON storage.objects
FOR ALL
TO authenticated
USING (bucket_id = 'content-images' AND owner = auth.uid())
WITH CHECK (bucket_id = 'content-images' AND owner = auth.uid());

-- Audio tracks - creators upload, public view
CREATE POLICY "creators_upload_audio"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (
    bucket_id = 'audio-tracks'
    AND owner = auth.uid()
);

CREATE POLICY "public_view_audio"
ON storage.objects
FOR SELECT
TO public
USING (bucket_id = 'audio-tracks');

CREATE POLICY "creators_manage_own_audio"
ON storage.objects
FOR ALL
TO authenticated
USING (bucket_id = 'audio-tracks' AND owner = auth.uid())
WITH CHECK (bucket_id = 'audio-tracks' AND owner = auth.uid());

-- 9. Mock Data for Testing
DO $$
DECLARE
    creator_id UUID := gen_random_uuid();
    user_id UUID := gen_random_uuid();
    admin_id UUID := gen_random_uuid();
    content_id UUID := gen_random_uuid();
    battle_id UUID := gen_random_uuid();
BEGIN
    -- Create complete auth.users records
    INSERT INTO auth.users (
        id, instance_id, aud, role, email, encrypted_password, email_confirmed_at,
        created_at, updated_at, raw_user_meta_data, raw_app_meta_data,
        is_sso_user, is_anonymous, confirmation_token, confirmation_sent_at,
        recovery_token, recovery_sent_at, email_change_token_new, email_change,
        email_change_sent_at, email_change_token_current, email_change_confirm_status,
        reauthentication_token, reauthentication_sent_at, phone, phone_change,
        phone_change_token, phone_change_sent_at
    ) VALUES
        (creator_id, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'creator@tamtam.com', crypt('tamtam123', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "TamTam Creator", "role": "creator"}'::jsonb, '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null),
        (user_id, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'user@tamtam.com', crypt('tamtam123', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "TamTam User", "role": "user"}'::jsonb, '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null),
        (admin_id, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'admin@tamtam.com', crypt('tamtam123', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "TamTam Admin", "role": "admin"}'::jsonb, '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null);

    -- Sample content
    INSERT INTO public.content (id, creator_id, type, title, description, view_count, like_count, comment_count)
    VALUES
        (content_id, creator_id, 'video'::public.content_type, 'My First TamTam Video', 'Welcome to my TamTam journey!', 1250, 89, 15),
        (gen_random_uuid(), creator_id, 'video'::public.content_type, 'Dance Challenge', 'Join the viral dance trend!', 5670, 234, 67),
        (gen_random_uuid(), user_id, 'image'::public.content_type, 'Beautiful Sunset', 'Captured this amazing moment today', 890, 45, 8);

    -- Sample relationships
    INSERT INTO public.user_relationships (follower_id, following_id, type)
    VALUES
        (user_id, creator_id, 'following'::public.relationship_type),
        (admin_id, creator_id, 'following'::public.relationship_type);

    -- Sample interactions
    INSERT INTO public.content_interactions (user_id, content_id, interaction_type)
    VALUES
        (user_id, content_id, 'like'),
        (user_id, content_id, 'view'),
        (admin_id, content_id, 'like'),
        (admin_id, content_id, 'view');

    -- Sample comments
    INSERT INTO public.comments (content_id, user_id, text_content)
    VALUES
        (content_id, user_id, 'Amazing content! Keep it up!'),
        (content_id, admin_id, 'Great job on your first video!');

    -- Sample wallet transactions
    INSERT INTO public.wallet_transactions (from_user_id, to_user_id, wallet_id, transaction_type, currency, amount, status)
    VALUES
        (user_id, creator_id, (SELECT id FROM public.wallets WHERE user_id = creator_id), 'tip', 'tam_token'::public.wallet_currency, 10.00, 'completed'::public.payment_status),
        (admin_id, creator_id, (SELECT id FROM public.wallets WHERE user_id = creator_id), 'tip', 'usd'::public.wallet_currency, 5.00, 'completed'::public.payment_status);

    -- Sample live battle
    INSERT INTO public.live_battles (id, creator1_id, creator2_id, title, description, total_tips, creator1_tips, creator2_tips)
    VALUES
        (battle_id, creator_id, user_id, 'Epic Dance Battle', 'Who has the best moves?', 150.00, 80.00, 70.00);

    -- Sample notifications
    INSERT INTO public.notifications (user_id, sender_id, type, title, message, content_id)
    VALUES
        (creator_id, user_id, 'like'::public.notification_type, 'New Like!', 'Someone liked your video', content_id),
        (creator_id, admin_id, 'follow'::public.notification_type, 'New Follower!', 'You have a new follower', null),
        (creator_id, user_id, 'tip'::public.notification_type, 'You received a tip!', 'Someone tipped you $5', content_id);

    -- Sample NFT collection
    INSERT INTO public.nft_collections (creator_id, name, description, total_supply, price_per_nft)
    VALUES
        (creator_id, 'TamTam Exclusive Badges', 'Limited edition creator badges', 100, 25.00);

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Mock data insertion failed: %', SQLERRM;
END $$;