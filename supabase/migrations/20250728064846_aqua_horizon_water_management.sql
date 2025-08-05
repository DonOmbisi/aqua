-- Location: supabase/migrations/20250728064846_aqua_horizon_water_management.sql
-- Schema Analysis: Fresh project implementation
-- Integration Type: Complete water resource management system
-- Dependencies: auth.users (Supabase built-in)

-- 1. Types and Enums
CREATE TYPE public.user_role AS ENUM ('admin', 'manager', 'community_user', 'expert');
CREATE TYPE public.water_quality_status AS ENUM ('excellent', 'good', 'fair', 'poor', 'critical');
CREATE TYPE public.issue_category AS ENUM ('leak', 'contamination', 'shortage', 'infrastructure', 'other');
CREATE TYPE public.issue_status AS ENUM ('reported', 'investigating', 'in_progress', 'resolved', 'closed');
CREATE TYPE public.verification_status AS ENUM ('pending', 'verified', 'rejected');

-- 2. Core Tables

-- User profiles (intermediary table for app relationships)
CREATE TABLE public.user_profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    username TEXT UNIQUE NOT NULL,
    email TEXT NOT NULL UNIQUE,
    full_name TEXT NOT NULL,
    role public.user_role DEFAULT 'community_user'::public.user_role,
    location_coordinates POINT,
    profile_photo_url TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Water quality data
CREATE TABLE public.water_data (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    location_coordinates POINT NOT NULL,
    location_name TEXT,
    ph_level DECIMAL(3,1),
    turbidity DECIMAL(5,2),
    temperature DECIMAL(4,1),
    dissolved_oxygen DECIMAL(4,1),
    water_level DECIMAL(5,2),
    flow_rate DECIMAL(6,2),
    photos TEXT[] DEFAULT '{}',
    notes TEXT,
    verification_status public.verification_status DEFAULT 'pending'::public.verification_status,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Issue reports
CREATE TABLE public.issue_reports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    reporter_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    category public.issue_category NOT NULL,
    location_coordinates POINT NOT NULL,
    location_name TEXT,
    status public.issue_status DEFAULT 'reported'::public.issue_status,
    photos TEXT[] DEFAULT '{}',
    priority INTEGER DEFAULT 1 CHECK (priority BETWEEN 1 AND 5),
    assigned_to UUID REFERENCES public.user_profiles(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    resolved_at TIMESTAMPTZ
);

-- Community discussions/forums
CREATE TABLE public.discussions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    author_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    issue_id UUID REFERENCES public.issue_reports(id) ON DELETE SET NULL,
    parent_id UUID REFERENCES public.discussions(id) ON DELETE CASCADE,
    is_pinned BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Water data analytics/aggregated views
CREATE TABLE public.water_analytics (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    location_coordinates POINT NOT NULL,
    date_recorded DATE NOT NULL,
    avg_ph DECIMAL(3,1),
    avg_turbidity DECIMAL(5,2),
    avg_temperature DECIMAL(4,1),
    avg_dissolved_oxygen DECIMAL(4,1),
    sample_count INTEGER DEFAULT 1,
    quality_status public.water_quality_status,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 3. Essential Indexes
CREATE INDEX idx_user_profiles_role ON public.user_profiles(role);
CREATE INDEX idx_user_profiles_location ON public.user_profiles USING GIST(location_coordinates);
CREATE INDEX idx_water_data_user_id ON public.water_data(user_id);
CREATE INDEX idx_water_data_location ON public.water_data USING GIST(location_coordinates);
CREATE INDEX idx_water_data_created_at ON public.water_data(created_at);
CREATE INDEX idx_water_data_verification ON public.water_data(verification_status);
CREATE INDEX idx_issue_reports_reporter ON public.issue_reports(reporter_id);
CREATE INDEX idx_issue_reports_location ON public.issue_reports USING GIST(location_coordinates);
CREATE INDEX idx_issue_reports_status ON public.issue_reports(status);
CREATE INDEX idx_issue_reports_category ON public.issue_reports(category);
CREATE INDEX idx_discussions_author ON public.discussions(author_id);
CREATE INDEX idx_discussions_issue ON public.discussions(issue_id);
CREATE INDEX idx_discussions_parent ON public.discussions(parent_id);
CREATE INDEX idx_water_analytics_location ON public.water_analytics USING GIST(location_coordinates);
CREATE INDEX idx_water_analytics_date ON public.water_analytics(date_recorded);

-- 4. RLS Setup
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.water_data ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.issue_reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.discussions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.water_analytics ENABLE ROW LEVEL SECURITY;

-- 5. Helper Functions

-- Check if user has specific role
CREATE OR REPLACE FUNCTION public.has_role(required_role TEXT)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM public.user_profiles up
    WHERE up.id = auth.uid() AND up.role::TEXT = required_role
)
$$;

-- Check if user is admin or manager
CREATE OR REPLACE FUNCTION public.is_admin_or_manager()
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM public.user_profiles up
    WHERE up.id = auth.uid() AND up.role IN ('admin', 'manager')
)
$$;

-- Check if user can moderate content
CREATE OR REPLACE FUNCTION public.can_moderate()
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM public.user_profiles up
    WHERE up.id = auth.uid() AND up.role IN ('admin', 'manager', 'expert')
)
$$;

-- Check if user owns water data record
CREATE OR REPLACE FUNCTION public.owns_water_data(data_uuid UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM public.water_data wd
    WHERE wd.id = data_uuid AND wd.user_id = auth.uid()
)
$$;

-- Check if user owns issue report
CREATE OR REPLACE FUNCTION public.owns_issue_report(report_uuid UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM public.issue_reports ir
    WHERE ir.id = report_uuid AND ir.reporter_id = auth.uid()
)
$$;

-- Function for automatic profile creation
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
SECURITY DEFINER
LANGUAGE plpgsql
AS $$
BEGIN
  INSERT INTO public.user_profiles (id, username, email, full_name, role)
  VALUES (
    NEW.id, 
    COALESCE(NEW.raw_user_meta_data->>'username', split_part(NEW.email, '@', 1)),
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1)),
    COALESCE(NEW.raw_user_meta_data->>'role', 'community_user')::public.user_role
  );
  RETURN NEW;
END;
$$;

-- Trigger for new user creation
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers for updated_at
CREATE TRIGGER update_user_profiles_updated_at BEFORE UPDATE ON public.user_profiles FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER update_water_data_updated_at BEFORE UPDATE ON public.water_data FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER update_issue_reports_updated_at BEFORE UPDATE ON public.issue_reports FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER update_discussions_updated_at BEFORE UPDATE ON public.discussions FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- 6. RLS Policies

-- User profiles policies
CREATE POLICY "users_view_all_profiles" ON public.user_profiles FOR SELECT
TO authenticated USING (true);

CREATE POLICY "users_update_own_profile" ON public.user_profiles FOR UPDATE
TO authenticated USING (auth.uid() = id) WITH CHECK (auth.uid() = id);

-- Water data policies
CREATE POLICY "authenticated_view_water_data" ON public.water_data FOR SELECT
TO authenticated USING (true);

CREATE POLICY "users_manage_own_water_data" ON public.water_data FOR ALL
TO authenticated 
USING (public.owns_water_data(id) OR public.can_moderate())
WITH CHECK (auth.uid() = user_id OR public.can_moderate());

-- Issue reports policies
CREATE POLICY "authenticated_view_issue_reports" ON public.issue_reports FOR SELECT
TO authenticated USING (true);

CREATE POLICY "users_create_issue_reports" ON public.issue_reports FOR INSERT
TO authenticated WITH CHECK (auth.uid() = reporter_id);

CREATE POLICY "users_update_own_reports" ON public.issue_reports FOR UPDATE
TO authenticated 
USING (public.owns_issue_report(id) OR public.can_moderate())
WITH CHECK (public.owns_issue_report(id) OR public.can_moderate());

-- Discussions policies
CREATE POLICY "authenticated_view_discussions" ON public.discussions FOR SELECT
TO authenticated USING (true);

CREATE POLICY "users_create_discussions" ON public.discussions FOR INSERT
TO authenticated WITH CHECK (auth.uid() = author_id);

CREATE POLICY "users_update_own_discussions" ON public.discussions FOR UPDATE
TO authenticated 
USING (auth.uid() = author_id OR public.can_moderate())
WITH CHECK (auth.uid() = author_id OR public.can_moderate());

-- Water analytics policies (read-only for most users)
CREATE POLICY "authenticated_view_analytics" ON public.water_analytics FOR SELECT
TO authenticated USING (true);

CREATE POLICY "admins_manage_analytics" ON public.water_analytics FOR ALL
TO authenticated 
USING (public.is_admin_or_manager())
WITH CHECK (public.is_admin_or_manager());

-- 7. Mock Data
DO $$
DECLARE
    admin_uuid UUID := gen_random_uuid();
    manager_uuid UUID := gen_random_uuid();
    user1_uuid UUID := gen_random_uuid();
    user2_uuid UUID := gen_random_uuid();
    expert_uuid UUID := gen_random_uuid();
    water_data1_uuid UUID := gen_random_uuid();
    water_data2_uuid UUID := gen_random_uuid();
    issue1_uuid UUID := gen_random_uuid();
    issue2_uuid UUID := gen_random_uuid();
BEGIN
    -- Create auth users with required fields
    INSERT INTO auth.users (
        id, instance_id, aud, role, email, encrypted_password, email_confirmed_at,
        created_at, updated_at, raw_user_meta_data, raw_app_meta_data,
        is_sso_user, is_anonymous, confirmation_token, confirmation_sent_at,
        recovery_token, recovery_sent_at, email_change_token_new, email_change,
        email_change_sent_at, email_change_token_current, email_change_confirm_status,
        reauthentication_token, reauthentication_sent_at, phone, phone_change,
        phone_change_token, phone_change_sent_at
    ) VALUES
        (admin_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'admin@aquahorizon.com', crypt('AquaAdmin123!', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "System Administrator", "username": "admin", "role": "admin"}'::jsonb, 
         '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null),
        (manager_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'manager@aquahorizon.com', crypt('AquaManager123!', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "Water Manager", "username": "watermanager", "role": "manager"}'::jsonb,
         '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null),
        (user1_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'john.doe@email.com', crypt('UserPass123!', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "John Doe", "username": "johndoe", "role": "community_user"}'::jsonb,
         '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null),
        (user2_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'jane.smith@email.com', crypt('UserPass123!', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "Jane Smith", "username": "janesmith", "role": "community_user"}'::jsonb,
         '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null),
        (expert_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'expert@aquahorizon.com', crypt('ExpertPass123!', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "Water Quality Expert", "username": "waterexpert", "role": "expert"}'::jsonb,
         '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null);

    -- Create water data records
    INSERT INTO public.water_data (id, user_id, location_coordinates, location_name, ph_level, turbidity, temperature, dissolved_oxygen, water_level, flow_rate, notes, verification_status)
    VALUES
        (water_data1_uuid, user1_uuid, POINT(-73.935242, 40.730610), 'Central Park Lake', 7.2, 5.5, 18.5, 8.2, 2.5, 15.3, 'Water quality appears normal. Clear visibility.', 'verified'::public.verification_status),
        (water_data2_uuid, user2_uuid, POINT(-73.989308, 40.733256), 'Hudson River - Pier 45', 6.8, 12.3, 16.8, 6.5, 3.2, 45.7, 'Slightly elevated turbidity levels observed.', 'pending'::public.verification_status);

    -- Create issue reports
    INSERT INTO public.issue_reports (id, reporter_id, title, description, category, location_coordinates, location_name, status, priority)
    VALUES
        (issue1_uuid, user1_uuid, 'Water Main Break on 5th Avenue', 'Large water main break causing flooding and water service disruption in the area.', 'leak'::public.issue_category, POINT(-73.981560, 40.767379), '5th Avenue & 59th Street', 'investigating'::public.issue_status, 4),
        (issue2_uuid, user2_uuid, 'Unusual Water Discoloration in Brooklyn', 'Reports of brown-colored water coming from taps in residential area.', 'contamination'::public.issue_category, POINT(-73.950270, 40.650002), 'Brooklyn Heights', 'reported'::public.issue_status, 3);

    -- Create sample discussions
    INSERT INTO public.discussions (author_id, title, content, issue_id)
    VALUES
        (expert_uuid, 'Water Quality Testing Best Practices', 'Here are some important guidelines for accurate water quality testing in the field...', NULL),
        (manager_uuid, 'Update on 5th Avenue Water Main Break', 'We have crews on site and expect to restore service within 8 hours.', issue1_uuid),
        (user1_uuid, 'Community Water Testing Initiative', 'Proposing a monthly community water testing program for our neighborhood.', NULL);

    -- Create water analytics data
    INSERT INTO public.water_analytics (location_coordinates, date_recorded, avg_ph, avg_turbidity, avg_temperature, avg_dissolved_oxygen, sample_count, quality_status)
    VALUES
        (POINT(-73.935242, 40.730610), CURRENT_DATE - INTERVAL '1 day', 7.2, 5.5, 18.5, 8.2, 1, 'good'::public.water_quality_status),
        (POINT(-73.989308, 40.733256), CURRENT_DATE - INTERVAL '1 day', 6.8, 12.3, 16.8, 6.5, 1, 'fair'::public.water_quality_status);

EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE NOTICE 'Foreign key error: %', SQLERRM;
    WHEN unique_violation THEN
        RAISE NOTICE 'Unique constraint error: %', SQLERRM;
    WHEN OTHERS THEN
        RAISE NOTICE 'Unexpected error: %', SQLERRM;
END $$;