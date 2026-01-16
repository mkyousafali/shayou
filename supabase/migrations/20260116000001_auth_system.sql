-- Migration: Login System
-- This migration enhances the schema to support Parent Supabase Auth 
-- and 6-digit access code authentication for kids.

-- 1. Create a Profiles table to link with Supabase Auth (auth.users)
-- Parents will use email/password + this profile.
CREATE TABLE IF NOT EXISTS profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    display_name TEXT NOT NULL,
    family_id UUID REFERENCES families(id) ON DELETE SET NULL,
    role TEXT DEFAULT 'parent' CHECK (role IN ('parent', 'guardian')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Add email to families (optional, but good for linking)
ALTER TABLE families ADD COLUMN IF NOT EXISTS parent_email TEXT;

-- 3. Update Kids table to include their individual access codes
-- This allows each kid to have their own secret code separate from the family code
ALTER TABLE kids ADD COLUMN IF NOT EXISTS access_code TEXT; 
ALTER TABLE kids ADD COLUMN IF NOT EXISTS pin_last_changed TIMESTAMPTZ DEFAULT NOW();

-- 4. Create a table for Login Sessions/Logs (Security Audit)
CREATE TABLE IF NOT EXISTS auth_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    actor_type TEXT NOT NULL CHECK (actor_type IN ('parent', 'kid')),
    actor_id UUID NOT NULL, -- UUID of family or kid
    action TEXT NOT NULL,   -- 'login_attempt', 'login_success', 'code_change'
    status TEXT NOT NULL,   -- 'success', 'failure'
    ip_address TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. Row Level Security Policies for Login System
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE auth_logs ENABLE ROW LEVEL SECURITY;

-- Allow parents to read/update their own profile
CREATE POLICY "Parents can view their own profile" 
ON profiles FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Parents can update their own profile" 
ON profiles FOR UPDATE USING (auth.uid() = id);

-- Allow admins/owners (the user themselves) to see their own logs
CREATE POLICY "Users can view their own auth logs" 
ON auth_logs FOR SELECT USING (
    (actor_type = 'parent' AND actor_id = auth.uid()) OR
    (actor_type = 'kid' AND actor_id IN (SELECT id FROM kids WHERE family_id IN (SELECT family_id FROM profiles WHERE id = auth.uid())))
);

-- 6. Trigger to automatically update updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE
ON profiles FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();
