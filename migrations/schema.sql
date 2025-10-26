-- SQL schema for Spirit D. Beast, Majesty (Postgres)
-- Run this in Supabase or your Postgres instance

-- Enable pgcrypto extension (for gen_random_uuid)
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Users
CREATE TABLE IF NOT EXISTS users (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  username text UNIQUE NOT NULL,
  email text UNIQUE NOT NULL,
  password_hash text NOT NULL,
  role text NOT NULL DEFAULT 'customer', -- 'owner' or 'customer'
  avatar_url text,
  created_at timestamptz DEFAULT now(),
  is_active boolean DEFAULT true
);

-- Settings (site appearance, shipping bands, rent defaults)
CREATE TABLE IF NOT EXISTS settings (
  id serial PRIMARY KEY,
  key text UNIQUE NOT NULL,
  value jsonb NOT NULL,
  updated_at timestamptz DEFAULT now()
);

-- Product types
DO $$ BEGIN
  CREATE TYPE IF NOT EXISTS product_type AS ENUM ('ebook', 'physical');
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

CREATE TABLE IF NOT EXISTS products (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  slug text UNIQUE NOT NULL,
  description text,
  type product_type NOT NULL,
  price_cents integer NOT NULL,
  rent_price_per_day_cents integer DEFAULT 4000, -- R40/day stored as cents
  stock integer DEFAULT 0,
  refundable boolean DEFAULT false,
  files jsonb,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS reviews (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id uuid REFERENCES products(id) ON DELETE CASCADE,
  author_id uuid REFERENCES users(id) ON DELETE SET NULL,
  rating smallint,
  comment text,
  created_at timestamptz DEFAULT now(),
  is_hidden boolean DEFAULT false,
  owner_response text
);

DO $$ BEGIN
  CREATE TYPE IF NOT EXISTS order_status AS ENUM ('pending', 'paid', 'fulfilled', 'shipped', 'cancelled');
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

CREATE TABLE IF NOT EXISTS orders (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES users(id) ON DELETE SET NULL,
  total_cents integer NOT NULL,
  shipping_cents integer DEFAULT 0,
  status order_status DEFAULT 'pending',
  payment_provider text,
  payment_id text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  shipping_address jsonb,
  is_rental boolean DEFAULT false
);

CREATE TABLE IF NOT EXISTS order_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id uuid REFERENCES orders(id) ON DELETE CASCADE,
  product_id uuid REFERENCES products(id) ON DELETE SET NULL,
  qty integer NOT NULL DEFAULT 1,
  unit_price_cents integer NOT NULL,
  rent_days integer DEFAULT 0,
  rent_due timestamptz
);

CREATE TABLE IF NOT EXISTS events (
  id bigserial PRIMARY KEY,
  name text,
  payload jsonb,
  created_at timestamptz DEFAULT now()
);
