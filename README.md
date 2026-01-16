# SHAYOU – Kids Savings, Targets, and Rewards

SHAYOU is a mobile-first, offline-ready web application built with SvelteKit and Supabase to help kids learn about saving money, building habits, and reaching goals.

## Tech Stack
- **Frontend:** SvelteKit (Svelte 5)
- **Styling:** Tailwind CSS
- **Backend/Auth:** Supabase
- **PWA:** Vite PWA Plugin
- **Offline Storage:** IndexedDB (idb)

## Features
- **Kid Mode:** Joyful, futuristic UI for kids to track balance, goals, and tasks.
- **Parent Dashboard:** Clean interface for approvals, kid management, and wallet adjustments.
- **PWA Support:** Installable on iOS/Android, works offline with a queued sync system.
- **Ledger-based Accounting:** All transactions are logged for full auditability.

## Getting Started

1. **Clone and Install:**
   ```bash
   npm install
   ```

2. **Environment Setup:**
   Create a `.env` file from the placeholder and add your Supabase credentials:
   ```env
   PUBLIC_SUPABASE_URL=your_project_url
   PUBLIC_SUPABASE_ANON_KEY=your_anon_key
   ```

3. **Database Setup:**
   Run the SQL found in `supabase_schema.sql` in your Supabase SQL Editor.

4. **Run Development:**
   ```bash
   npm run dev
   ```

## Project Structure
- `/src/routes/parent`: Parent-only screens and logic.
- `/src/routes/kid`: Kid-focused home, tasks, and goal screens.
- `/src/lib/components`: Shared UI components (Material/Futuristic style).
- `/src/lib/supabase.ts`: Supabase client initialization.
- `/src/lib/offline.ts`: IndexedDB queue for offline sync.
