-- Complemento de portal público para SISTEMA-PRESTAMOS.
-- La migración ya fue aplicada al proyecto Supabase wdaekievxgazzbkjffwc.
create table if not exists public.sp_portales (
 id uuid primary key default gen_random_uuid(),
 financiera_id uuid not null unique references public.sp_financieras(id) on delete cascade,
 slug text not null unique,
 titulo text not null default 'Portal de clientes',
 descripcion text,
 telefono text,
 correo text,
 direccion text,
 horarios text,
 medios_pago text,
 color_principal text not null default '#123c35',
 publicado boolean not null default false,
 actualizado_en timestamptz not null default now(),
 creado_en timestamptz not null default now(),
 constraint sp_portales_slug_formato check (slug ~ '^[a-z0-9]+(-[a-z0-9]+)*$')
);
create table if not exists public.sp_campanas (
 id uuid primary key default gen_random_uuid(),
 financiera_id uuid not null references public.sp_financieras(id) on delete cascade,
 titulo text not null, descripcion text not null, condiciones text,
 fecha_inicio date, fecha_fin date, publicada boolean not null default false,
 creado_en timestamptz not null default now(), creado_por uuid references auth.users(id),
 constraint sp_campanas_fechas check (fecha_fin is null or fecha_inicio is null or fecha_fin >= fecha_inicio)
);
create table if not exists public.sp_clientes_portal (
 id uuid primary key default gen_random_uuid(),
 financiera_id uuid not null references public.sp_financieras(id) on delete cascade,
 cliente_id uuid not null references public.sp_clientes(id) on delete cascade,
 usuario_id uuid not null references auth.users(id) on delete cascade,
 activo boolean not null default true, creado_en timestamptz not null default now(),
 unique(financiera_id, cliente_id), unique(financiera_id, usuario_id)
);
create table if not exists public.sp_solicitudes_portal (
 id uuid primary key default gen_random_uuid(),
 financiera_id uuid not null references public.sp_financieras(id) on delete cascade,
 nombres text not null, apellidos text not null, tipo_documento text not null default 'DNI',
 numero_documento text not null, telefono text not null, correo text,
 monto_solicitado numeric not null check (monto_solicitado > 0),
 plazo integer not null check (plazo > 0),
 frecuencia text not null check (frecuencia in ('diaria','semanal','quincenal','mensual')),
 destino text, estado text not null default 'recibida' check (estado in ('recibida','contactada','convertida','descartada')),
 creado_en timestamptz not null default now()
);
alter table public.sp_portales enable row level security;
alter table public.sp_campanas enable row level security;
alter table public.sp_clientes_portal enable row level security;
alter table public.sp_solicitudes_portal enable row level security;
drop policy if exists sp_portales_publico_ver on public.sp_portales;
create policy sp_portales_publico_ver on public.sp_portales for select to anon, authenticated
using (publicado = true and exists(select 1 from public.sp_financieras f where f.id = financiera_id and f.estado = 'activa'));
drop policy if exists sp_portales_empresa_gestionar on public.sp_portales;
create policy sp_portales_empresa_gestionar on public.sp_portales for all to authenticated
using (private.sp_es_miembro(financiera_id) and private.sp_tiene_permiso(financiera_id,'configuracion','administrar'))
with check (private.sp_es_miembro(financiera_id) and private.sp_tiene_permiso(financiera_id,'configuracion','administrar'));
drop policy if exists sp_campanas_publicas_ver on public.sp_campanas;
create policy sp_campanas_publicas_ver on public.sp_campanas for select to anon, authenticated
using (publicada = true and exists(select 1 from public.sp_financieras f join public.sp_portales p on p.financiera_id=f.id where f.id=sp_campanas.financiera_id and f.estado='activa' and p.publicado=true));
drop policy if exists sp_campanas_empresa_gestionar on public.sp_campanas;
create policy sp_campanas_empresa_gestionar on public.sp_campanas for all to authenticated
using (private.sp_es_miembro(financiera_id) and private.sp_tiene_permiso(financiera_id,'campanas','administrar'))
with check (private.sp_es_miembro(financiera_id) and private.sp_tiene_permiso(financiera_id,'campanas','administrar'));
drop policy if exists sp_clientes_portal_ver on public.sp_clientes_portal;
create policy sp_clientes_portal_ver on public.sp_clientes_portal for select to authenticated
using (usuario_id=(select auth.uid()) or private.sp_es_miembro(financiera_id));
drop policy if exists sp_clientes_portal_gestionar on public.sp_clientes_portal;
create policy sp_clientes_portal_gestionar on public.sp_clientes_portal for all to authenticated
using (private.sp_es_miembro(financiera_id) and private.sp_tiene_permiso(financiera_id,'clientes','editar'))
with check (private.sp_es_miembro(financiera_id) and private.sp_tiene_permiso(financiera_id,'clientes','editar'));
drop policy if exists sp_solicitudes_portal_publicar on public.sp_solicitudes_portal;
create policy sp_solicitudes_portal_publicar on public.sp_solicitudes_portal for insert to anon, authenticated
with check (exists(select 1 from public.sp_financieras f join public.sp_portales p on p.financiera_id=f.id where f.id=sp_solicitudes_portal.financiera_id and f.estado='activa' and p.publicado=true));
drop policy if exists sp_solicitudes_portal_empresa_ver on public.sp_solicitudes_portal;
create policy sp_solicitudes_portal_empresa_ver on public.sp_solicitudes_portal for select to authenticated
using (private.sp_es_miembro(financiera_id) and private.sp_tiene_permiso(financiera_id,'solicitudes','ver'));
drop policy if exists sp_solicitudes_portal_empresa_editar on public.sp_solicitudes_portal;
create policy sp_solicitudes_portal_empresa_editar on public.sp_solicitudes_portal for update to authenticated
using (private.sp_es_miembro(financiera_id) and private.sp_tiene_permiso(financiera_id,'solicitudes','editar'))
with check (private.sp_es_miembro(financiera_id) and private.sp_tiene_permiso(financiera_id,'solicitudes','editar'));
drop policy if exists sp_clientes_portal_propios on public.sp_clientes;
create policy sp_clientes_portal_propios on public.sp_clientes for select to authenticated
using (exists(select 1 from public.sp_clientes_portal cp where cp.financiera_id=sp_clientes.financiera_id and cp.cliente_id=sp_clientes.id and cp.usuario_id=(select auth.uid()) and cp.activo=true));
drop policy if exists sp_prestamos_portal_propios on public.sp_prestamos;
create policy sp_prestamos_portal_propios on public.sp_prestamos for select to authenticated
using (exists(select 1 from public.sp_clientes_portal cp where cp.financiera_id=sp_prestamos.financiera_id and cp.cliente_id=sp_prestamos.cliente_id and cp.usuario_id=(select auth.uid()) and cp.activo=true));
drop policy if exists sp_cuotas_portal_propias on public.sp_cuotas;
create policy sp_cuotas_portal_propias on public.sp_cuotas for select to authenticated
using (exists(select 1 from public.sp_clientes_portal cp join public.sp_prestamos pr on pr.cliente_id=cp.cliente_id and pr.financiera_id=cp.financiera_id where cp.usuario_id=(select auth.uid()) and cp.activo=true and pr.id=sp_cuotas.prestamo_id and pr.financiera_id=sp_cuotas.financiera_id));
drop policy if exists sp_pagos_portal_propios on public.sp_pagos;
create policy sp_pagos_portal_propios on public.sp_pagos for select to authenticated
using (exists(select 1 from public.sp_clientes_portal cp where cp.financiera_id=sp_pagos.financiera_id and cp.cliente_id=sp_pagos.cliente_id and cp.usuario_id=(select auth.uid()) and cp.activo=true));
create or replace function private.sp_crear_portal_financiera()
returns trigger language plpgsql security definer set search_path = ''
as $$
declare v_base text; v_slug text;
begin
 v_base := trim(both '-' from regexp_replace(lower(coalesce(new.nombre, 'financiera')), '[^a-z0-9]+', '-', 'g'));
 if v_base = '' then v_base := 'financiera'; end if;
 v_slug := left(v_base,45)||'-'||left(replace(new.id::text,'-',''),6);
 insert into public.sp_portales(financiera_id,slug,titulo,descripcion,publicado)
 values(new.id,v_slug,new.nombre,'Información, campañas y solicitudes de crédito de nuestra financiera.',false)
 on conflict(financiera_id) do nothing;
 return new;
end;
$$;
drop trigger if exists sp_financieras_crear_portal on public.sp_financieras;
create trigger sp_financieras_crear_portal after insert on public.sp_financieras
for each row execute function private.sp_crear_portal_financiera();
