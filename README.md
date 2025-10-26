# Spirit D. Beast, Majesty

This repository contains the initial scaffold for the Spirit D. Beast, Majesty storefront and manager dashboard.

Stack (recommended)
- Frontend: Next.js + React
- Database & Auth: Supabase (Postgres, Auth, Storage)
- Payments: PayPal + PayFast (sandbox wired later)
- Hosting: Vercel (recommended)

Quickstart (development)
1. Create a Supabase project and run the SQL in `migrations/schema.sql` (or run it in the SQL editor).
2. Copy `.env.example` to `.env.local` and fill in the values.
3. Install dependencies:
   - `npm install`
4. Run the dev server:
   - `npm run dev`

Files included in this commit:
- README.md (this file)
- migrations/schema.sql (DB schema)
- .env.example (environment variable template)
- package.json
- pages/index.js (simple home page)
- .gitignore

Notes
- Seeds: The scaffold does not create production keys. Use sandbox keys for PayPal/PayFast until ready to go live.
- After you run the migration in Supabase, create a storage bucket for ebooks and images (private for ebooks).

If you'd like, I can seed an initial owner account and sample products — tell me the email/username to use and whether you want owner 2FA enabled.