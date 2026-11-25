-- PROMOFIND — schéma Supabase (à exécuter dans SQL Editor)
-- 1) Crée d'abord ton utilisateur dans Authentication > Users.
-- 2) Après création, copie son UUID et remplace TON_UUID_ICI dans la dernière requête.
-- 3) Ne partage jamais de clé service_role.

create table if not exists public.admins (
  user_id uuid primary key references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);

create table if not exists public.offers (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  brand text,
  universe text not null default 'Électronique',
  category text not null default 'Autres',
  details text,
  specs text[] not null default '{}',
  price numeric(10,2),
  merchant text,
  url text,
  image text,
  feature text,
  affiliate boolean not null default false,
  published boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.admins enable row level security;
alter table public.offers enable row level security;

-- Droits SQL de base : les politiques RLS ci-dessous limitent ensuite les lignes accessibles.
grant usage on schema public to anon, authenticated;
grant select on public.offers to anon, authenticated;
grant select on public.admins to authenticated;
grant insert, update, delete on public.offers to authenticated;

-- Un utilisateur connecté ne peut voir que sa propre entrée admin.
drop policy if exists "admin can read own role" on public.admins;
create policy "admin can read own role" on public.admins
for select to authenticated using (user_id = auth.uid());

-- Tout le monde peut lire uniquement les offres publiées.
drop policy if exists "public reads published offers" on public.offers;
create policy "public reads published offers" on public.offers
for select to anon, authenticated using (published = true);

-- Seuls les comptes inscrits dans admins peuvent tout gérer.
drop policy if exists "admins read all offers" on public.offers;
create policy "admins read all offers" on public.offers
for select to authenticated using (exists (select 1 from public.admins a where a.user_id = auth.uid()));

drop policy if exists "admins insert offers" on public.offers;
create policy "admins insert offers" on public.offers
for insert to authenticated with check (exists (select 1 from public.admins a where a.user_id = auth.uid()));

drop policy if exists "admins update offers" on public.offers;
create policy "admins update offers" on public.offers
for update to authenticated using (exists (select 1 from public.admins a where a.user_id = auth.uid()))
with check (exists (select 1 from public.admins a where a.user_id = auth.uid()));

drop policy if exists "admins delete offers" on public.offers;
create policy "admins delete offers" on public.offers
for delete to authenticated using (exists (select 1 from public.admins a where a.user_id = auth.uid()));

-- IMPORTANT : remplace l'UUID ci-dessous par celui de TON compte admin Supabase.
-- À exécuter séparément après avoir créé le compte :
-- insert into public.admins (user_id) values ('TON_UUID_ICI');
