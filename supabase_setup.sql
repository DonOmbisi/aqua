-- Supabase Database Setup Script for Aqua Horizon
-- Run this script in your Supabase SQL Editor

-- First, enable Row Level Security for auth.users (if not already enabled)
-- This is handled by Supabase automatically

-- Create user_profiles table
CREATE TABLE IF NOT EXISTS public.user_profiles (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  username TEXT UNIQUE,
  email TEXT UNIQUE NOT NULL,
  full_name TEXT,
  role TEXT DEFAULT 'community_user' CHECK (role IN ('community_user', 'expert', 'manager', 'admin')),
  phone TEXT,
  avatar_url TEXT,
  location_enabled BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security on user_profiles
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;

-- Create policies for user_profiles table
-- Users can view their own profile
CREATE POLICY "Users can view own profile" ON public.user_profiles
FOR SELECT USING (auth.uid() = id);

-- Users can insert their own profile  
CREATE POLICY "Users can insert own profile" ON public.user_profiles
FOR INSERT WITH CHECK (auth.uid() = id);

-- Users can update their own profile
CREATE POLICY "Users can update own profile" ON public.user_profiles
FOR UPDATE USING (auth.uid() = id);

-- Admins and managers can view all profiles
CREATE POLICY "Admins and managers can view all profiles" ON public.user_profiles
FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM public.user_profiles
    WHERE id = auth.uid() AND role IN ('admin', 'manager')
  )
);

-- Create water_quality_reports table
CREATE TABLE IF NOT EXISTS public.water_quality_reports (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  location_name TEXT,
  latitude FLOAT,
  longitude FLOAT,
  ph_level FLOAT,
  turbidity FLOAT,
  dissolved_oxygen FLOAT,
  temperature FLOAT,
  notes TEXT,
  photo_urls TEXT[],
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'verified', 'rejected')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS on water_quality_reports
ALTER TABLE public.water_quality_reports ENABLE ROW LEVEL SECURITY;

-- Policies for water_quality_reports
CREATE POLICY "Users can view all reports" ON public.water_quality_reports
FOR SELECT USING (true);

CREATE POLICY "Users can insert own reports" ON public.water_quality_reports
FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own reports" ON public.water_quality_reports
FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Experts and managers can verify reports" ON public.water_quality_reports
FOR UPDATE USING (
  EXISTS (
    SELECT 1 FROM public.user_profiles
    WHERE id = auth.uid() AND role IN ('expert', 'manager', 'admin')
  )
);

-- Function to automatically create user profile when user signs up
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.user_profiles (id, email, full_name, username)
  VALUES (
    new.id,
    new.email,
    COALESCE(new.raw_user_meta_data->>'full_name', ''),
    COALESCE(new.raw_user_meta_data->>'username', '')
  );
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger to automatically create profile on user signup
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS trigger AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create triggers for updated_at
CREATE TRIGGER handle_updated_at_user_profiles
  BEFORE UPDATE ON public.user_profiles
  FOR EACH ROW EXECUTE PROCEDURE public.handle_updated_at();

CREATE TRIGGER handle_updated_at_water_quality_reports
  BEFORE UPDATE ON public.water_quality_reports
  FOR EACH ROW EXECUTE PROCEDURE public.handle_updated_at();

-- Create some sample data for testing
INSERT INTO public.user_profiles (id, username, email, full_name, role) VALUES
  ('00000000-0000-0000-0000-000000000001'::uuid, 'testuser', 'test@example.com', 'Test User', 'community_user')
ON CONFLICT (id) DO NOTHING;

-- Note: You'll need to create the actual auth user first through Supabase Auth
-- before the profile record can be created with the above ID

COMMIT;
