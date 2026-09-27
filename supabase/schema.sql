-- App Compras - Supabase/PostgreSQL
create table if not exists public.listas (
 id text primary key, name text not null default '', type text not null default 'Outros',
 status text not null default 'PENDENTE' check (status in ('PENDENTE','EM_COMPRA','CONCLUIDA')),
 created_at timestamptz not null default now(), started_at timestamptz, completed_at timestamptz, updated_at timestamptz not null default now()
);
create table if not exists public.itens_lista (
 id text primary key, list_id text not null references public.listas(id) on delete cascade,
 item_name text not null, unit text not null default 'UN', quantity numeric(12,1) not null default 1,
 note text not null default '', purchase_state text not null default 'PENDENTE' check (purchase_state in ('PENDENTE','COMPRADO','NAO_ENCONTRADO')),
 sort_order integer not null default 1, created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create index if not exists itens_lista_list_id_idx on public.itens_lista(list_id);
create table if not exists public.itens (
 id text primary key, name text not null, category text not null default 'Outros', default_unit text not null default 'UN',
 list_types text not null default 'Outros', active boolean not null default true, is_custom boolean not null default false, updated_at timestamptz not null default now()
);
create table if not exists public.tipos_lista (
 id text primary key, name text not null unique, active boolean not null default true, sort_order integer not null default 1, updated_at timestamptz not null default now()
);

alter table public.listas enable row level security;
alter table public.itens_lista enable row level security;
alter table public.itens enable row level security;
alter table public.tipos_lista enable row level security;

-- PROTÓTIPO SEM LOGIN: permite acesso pela chave pública do app.
-- Para uso multiusuário, substitua por Supabase Auth + políticas por user_id.
drop policy if exists "prototype listas" on public.listas;
create policy "prototype listas" on public.listas for all to anon using (true) with check (true);
drop policy if exists "prototype itens_lista" on public.itens_lista;
create policy "prototype itens_lista" on public.itens_lista for all to anon using (true) with check (true);
drop policy if exists "prototype itens" on public.itens;
create policy "prototype itens" on public.itens for all to anon using (true) with check (true);
drop policy if exists "prototype tipos_lista" on public.tipos_lista;
create policy "prototype tipos_lista" on public.tipos_lista for all to anon using (true) with check (true);
