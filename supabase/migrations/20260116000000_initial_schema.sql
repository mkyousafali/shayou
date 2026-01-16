-- Create a table for Families (Parents)
-- In this simplified model, a 'family' is identified by its 6-digit access code
CREATE TABLE IF NOT EXISTS families (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    access_code TEXT NOT NULL, -- The 6-digit code
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create a table for Kids
-- Each kid belongs to one family
CREATE TABLE IF NOT EXISTS kids (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    family_id UUID REFERENCES families(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    balance INTEGER DEFAULT 0,
    avatar_url TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create a table for Tasks/Missions
CREATE TABLE IF NOT EXISTS tasks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    kid_id UUID REFERENCES kids(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    reward INTEGER NOT NULL,
    status TEXT DEFAULT 'available' CHECK (status IN ('available', 'pending', 'completed')),
    category TEXT DEFAULT 'Life Skill',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    completed_at TIMESTAMPTZ
);

-- Enable Row Level Security (RLS)
ALTER TABLE families ENABLE ROW LEVEL SECURITY;
ALTER TABLE kids ENABLE ROW LEVEL SECURITY;
ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;

-- Note: RLS Policies would typically check for the session/access_code logic.
-- For the prototype phase, we can allow authenticated access if using Supabase Auth,
-- or create specific policies if using a custom login flow.

-- Example Policy: Allow read/write for now
CREATE POLICY "Allow everything for now" ON families FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow everything for now" ON kids FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow everything for now" ON tasks FOR ALL USING (true) WITH CHECK (true);
