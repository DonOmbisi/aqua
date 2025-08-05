-- Clear all data from Aqua Horizon database
-- Run this in your Supabase SQL Editor

-- Disable RLS temporarily to allow deletion
ALTER TABLE public.user_profiles DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.water_data DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.issue_reports DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.discussions DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.water_analytics DISABLE ROW LEVEL SECURITY;

-- Delete all data (order matters due to foreign key constraints)
DELETE FROM public.discussions;
DELETE FROM public.water_analytics;
DELETE FROM public.issue_reports;
DELETE FROM public.water_data;
DELETE FROM public.user_profiles;

-- Delete auth users (this will cascade delete related user_profiles due to foreign key)
DELETE FROM auth.users;

-- Re-enable RLS
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.water_data ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.issue_reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.discussions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.water_analytics ENABLE ROW LEVEL SECURITY;

-- Verify all tables are empty
SELECT 'auth.users' as table_name, COUNT(*) as count FROM auth.users
UNION ALL
SELECT 'user_profiles' as table_name, COUNT(*) as count FROM public.user_profiles
UNION ALL
SELECT 'water_data' as table_name, COUNT(*) as count FROM public.water_data
UNION ALL
SELECT 'issue_reports' as table_name, COUNT(*) as count FROM public.issue_reports
UNION ALL
SELECT 'discussions' as table_name, COUNT(*) as count FROM public.discussions
UNION ALL
SELECT 'water_analytics' as table_name, COUNT(*) as count FROM public.water_analytics;
