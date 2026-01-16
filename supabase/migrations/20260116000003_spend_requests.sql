-- Create spend_requests table
CREATE TABLE IF NOT EXISTS spend_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    kid_id UUID REFERENCES kids(id) ON DELETE CASCADE,
    item TEXT NOT NULL,
    amount INTEGER NOT NULL,
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'declined')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE spend_requests ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow everything for now" ON spend_requests FOR ALL USING (true) WITH CHECK (true);
