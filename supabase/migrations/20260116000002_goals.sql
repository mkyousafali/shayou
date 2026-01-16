-- Create goals table
CREATE TABLE IF NOT EXISTS goals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    kid_id UUID REFERENCES kids(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    target_amount INTEGER NOT NULL,
    current_amount INTEGER DEFAULT 0,
    status TEXT DEFAULT 'active' CHECK (status IN ('active', 'reached')),
    icon TEXT,
    color TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    reached_at TIMESTAMPTZ
);

ALTER TABLE goals ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow everything for now" ON goals FOR ALL USING (true) WITH CHECK (true);
