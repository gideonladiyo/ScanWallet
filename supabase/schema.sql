-- ScanWallet Supabase schema (PLANNING.md §1–§3).
-- Run this in the Supabase SQL editor for your project.
-- IDEMPOTENT: safe to run multiple times — existing objects are dropped
-- and recreated cleanly, so a partial/failed earlier run gets repaired.

-- ==================== Enum Types ====================

DO $$ BEGIN
  CREATE TYPE transaction_type AS ENUM ('income', 'expense');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE sync_status AS ENUM ('pending_sync', 'synced');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- ==================== Tables ====================

CREATE TABLE IF NOT EXISTS profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name TEXT,
  avatar_url TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS accounts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  account_type TEXT NOT NULL,
  icon TEXT,
  color TEXT,
  balance NUMERIC(15, 2) NOT NULL DEFAULT 0,
  is_default BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_accounts_user_id ON accounts(user_id);

CREATE TABLE IF NOT EXISTS categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  transaction_type transaction_type NOT NULL,
  icon TEXT,
  color TEXT,
  is_default BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_categories_user_id ON categories(user_id);
CREATE UNIQUE INDEX IF NOT EXISTS idx_categories_user_name_type
  ON categories(user_id, name, transaction_type);

CREATE TABLE IF NOT EXISTS transactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  account_id UUID NOT NULL REFERENCES accounts(id) ON DELETE RESTRICT,
  category_id UUID NOT NULL REFERENCES categories(id) ON DELETE RESTRICT,
  type transaction_type NOT NULL,
  amount NUMERIC(15, 2) NOT NULL CHECK (amount > 0),
  date DATE NOT NULL DEFAULT CURRENT_DATE,
  note TEXT,
  merchant TEXT,
  source TEXT,
  sync_status sync_status NOT NULL DEFAULT 'pending_sync',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_transactions_user_id ON transactions(user_id);
CREATE INDEX IF NOT EXISTS idx_transactions_account_id ON transactions(account_id);
CREATE INDEX IF NOT EXISTS idx_transactions_category_id ON transactions(category_id);
CREATE INDEX IF NOT EXISTS idx_transactions_date ON transactions(date DESC);
CREATE INDEX IF NOT EXISTS idx_transactions_sync_status
  ON transactions(sync_status) WHERE sync_status = 'pending_sync';

-- ==================== Triggers & Functions ====================
-- Drop-then-create so a stale/half-created trigger from an earlier run
-- (the usual cause of "Database error saving new user") is replaced.

-- Creates the default profile/accounts/categories for a user. Idempotent:
-- safe to call repeatedly (guards with ON CONFLICT / NOT EXISTS), which is
-- what lets the signup trigger AND the backfill below share one code path.
-- NOTE: all tables are schema-qualified with `public.` and search_path is
-- pinned — the auth service (GoTrue) executes the signup trigger with its
-- own search_path that does NOT include `public`, so unqualified `profiles`
-- would fail with "relation does not exist" even when the table exists.
CREATE OR REPLACE FUNCTION ensure_user_defaults(p_user_id UUID, p_full_name TEXT DEFAULT '')
RETURNS void
SET search_path = ''
AS $$
BEGIN
  INSERT INTO public.profiles (id, full_name)
  VALUES (p_user_id, p_full_name)
  ON CONFLICT (id) DO NOTHING;

  INSERT INTO public.accounts (user_id, name, account_type, icon, color, balance, is_default)
  SELECT p_user_id, v.name, v.account_type, v.icon, v.color, 0, TRUE
  FROM (VALUES
    ('Cash',      'cash',     'cash_icon',      '#2ECC71'),
    ('GoPay',     'e_wallet', 'gopay_icon',     '#00AA13'),
    ('ShopeePay', 'e_wallet', 'shopeepay_icon', '#EE4D2D'),
    ('DANA',      'e_wallet', 'dana_icon',      '#108EE9'),
    ('BCA',       'bank',     'bca_icon',       '#004B87')
  ) AS v(name, account_type, icon, color)
  WHERE NOT EXISTS (
    SELECT 1 FROM public.accounts WHERE user_id = p_user_id
  );

  INSERT INTO public.categories (user_id, name, transaction_type, icon, color, is_default)
  SELECT p_user_id, v.name, v.transaction_type::public.transaction_type, v.icon, v.color, TRUE
  FROM (VALUES
    ('Makanan & Minuman',  'expense', 'food_icon',          '#FF5C5C'),
    ('Transportasi',       'expense', 'transport_icon',     '#F5A623'),
    ('Belanja',            'expense', 'shopping_icon',      '#7C5CFC'),
    ('Hiburan',            'expense', 'entertainment_icon', '#4F7CFF'),
    ('Tagihan & Utilitas', 'expense', 'bill_icon',          '#9AA0AC'),
    ('Lainnya',            'expense', 'other_icon',         '#5C616B'),
    ('Gaji',               'income',  'salary_icon',        '#2ECC71'),
    ('Freelance',          'income',  'freelance_icon',     '#1EA85C'),
    ('Investasi',          'income',  'invest_icon',        '#4F7CFF'),
    ('Lainnya',            'income',  'other_income_icon',  '#5C616B')
  ) AS v(name, transaction_type, icon, color)
  WHERE NOT EXISTS (
    SELECT 1 FROM public.categories WHERE user_id = p_user_id
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Auto-create profile + default accounts + default categories on signup.
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER
SET search_path = ''
AS $$
BEGIN
  PERFORM public.ensure_user_defaults(
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'full_name', '')
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();

-- Keep account balances in sync with transactions; the app never writes
-- balances directly from Dart (AGENTS.md §3). Schema-qualified + pinned
-- search_path (SECURITY DEFINER hygiene, same as handle_new_user).
CREATE OR REPLACE FUNCTION update_account_balance()
RETURNS TRIGGER
SET search_path = ''
AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    IF NEW.type = 'income' THEN
      UPDATE public.accounts SET balance = balance + NEW.amount, updated_at = NOW()
      WHERE id = NEW.account_id;
    ELSE
      UPDATE public.accounts SET balance = balance - NEW.amount, updated_at = NOW()
      WHERE id = NEW.account_id;
    END IF;
    RETURN NEW;

  ELSIF TG_OP = 'DELETE' THEN
    IF OLD.type = 'income' THEN
      UPDATE public.accounts SET balance = balance - OLD.amount, updated_at = NOW()
      WHERE id = OLD.account_id;
    ELSE
      UPDATE public.accounts SET balance = balance + OLD.amount, updated_at = NOW()
      WHERE id = OLD.account_id;
    END IF;
    RETURN OLD;

  ELSIF TG_OP = 'UPDATE' THEN
    IF OLD.type = 'income' THEN
      UPDATE public.accounts SET balance = balance - OLD.amount, updated_at = NOW()
      WHERE id = OLD.account_id;
    ELSE
      UPDATE public.accounts SET balance = balance + OLD.amount, updated_at = NOW()
      WHERE id = OLD.account_id;
    END IF;

    IF NEW.type = 'income' THEN
      UPDATE public.accounts SET balance = balance + NEW.amount, updated_at = NOW()
      WHERE id = NEW.account_id;
    ELSE
      UPDATE public.accounts SET balance = balance - NEW.amount, updated_at = NOW()
      WHERE id = NEW.account_id;
    END IF;
    RETURN NEW;
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_transaction_change ON transactions;
CREATE TRIGGER on_transaction_change
  AFTER INSERT OR UPDATE OR DELETE ON transactions
  FOR EACH ROW EXECUTE FUNCTION update_account_balance();

CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS set_profiles_updated_at ON profiles;
CREATE TRIGGER set_profiles_updated_at
  BEFORE UPDATE ON profiles
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

DROP TRIGGER IF EXISTS set_accounts_updated_at ON accounts;
CREATE TRIGGER set_accounts_updated_at
  BEFORE UPDATE ON accounts
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

DROP TRIGGER IF EXISTS set_transactions_updated_at ON transactions;
CREATE TRIGGER set_transactions_updated_at
  BEFORE UPDATE ON transactions
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- ==================== Row Level Security ====================

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users can view own profile" ON profiles;
CREATE POLICY "Users can view own profile" ON profiles FOR SELECT USING (auth.uid() = id);
DROP POLICY IF EXISTS "Users can update own profile" ON profiles;
CREATE POLICY "Users can update own profile" ON profiles FOR UPDATE USING (auth.uid() = id);
DROP POLICY IF EXISTS "Users can insert own profile" ON profiles;
CREATE POLICY "Users can insert own profile" ON profiles FOR INSERT WITH CHECK (auth.uid() = id);

ALTER TABLE accounts ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users can view own accounts" ON accounts;
CREATE POLICY "Users can view own accounts" ON accounts FOR SELECT USING (auth.uid() = user_id);
DROP POLICY IF EXISTS "Users can insert own accounts" ON accounts;
CREATE POLICY "Users can insert own accounts" ON accounts FOR INSERT WITH CHECK (auth.uid() = user_id);
DROP POLICY IF EXISTS "Users can update own accounts" ON accounts;
CREATE POLICY "Users can update own accounts" ON accounts FOR UPDATE USING (auth.uid() = user_id);
DROP POLICY IF EXISTS "Users can delete own accounts" ON accounts;
CREATE POLICY "Users can delete own accounts" ON accounts FOR DELETE USING (auth.uid() = user_id);

ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users can view own categories" ON categories;
CREATE POLICY "Users can view own categories" ON categories FOR SELECT USING (auth.uid() = user_id);
DROP POLICY IF EXISTS "Users can insert own categories" ON categories;
CREATE POLICY "Users can insert own categories" ON categories FOR INSERT WITH CHECK (auth.uid() = user_id);
DROP POLICY IF EXISTS "Users can update own categories" ON categories;
CREATE POLICY "Users can update own categories" ON categories FOR UPDATE USING (auth.uid() = user_id);
DROP POLICY IF EXISTS "Users can delete own categories" ON categories;
CREATE POLICY "Users can delete own categories" ON categories FOR DELETE USING (auth.uid() = user_id);

ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users can view own transactions" ON transactions;
CREATE POLICY "Users can view own transactions" ON transactions FOR SELECT USING (auth.uid() = user_id);
DROP POLICY IF EXISTS "Users can insert own transactions" ON transactions;
CREATE POLICY "Users can insert own transactions" ON transactions FOR INSERT WITH CHECK (auth.uid() = user_id);
DROP POLICY IF EXISTS "Users can update own transactions" ON transactions;
CREATE POLICY "Users can update own transactions" ON transactions FOR UPDATE USING (auth.uid() = user_id);
DROP POLICY IF EXISTS "Users can delete own transactions" ON transactions;
CREATE POLICY "Users can delete own transactions" ON transactions FOR DELETE USING (auth.uid() = user_id);

-- ==================== Backfill ====================
-- Repair auth users that have no profile/accounts/categories. This happens
-- when the database was reset while the user already existed: Google login
-- does NOT insert into auth.users again, so the signup trigger never fires
-- and the old user silently keeps missing their default rows (symptom:
-- transaction form has no accounts/categories, nothing can be saved).
-- Idempotent: existing users with rows are skipped by the NOT EXISTS guards.
SELECT public.ensure_user_defaults(
         u.id,
         COALESCE(u.raw_user_meta_data->>'full_name', '')
       )
FROM auth.users u;
