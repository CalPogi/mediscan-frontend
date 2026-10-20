create table public.grade_levels (
  id bigint generated always as identity primary key,
  name text not null,
  created_at timestamptz default now()
);

create table public.sections (
  id bigint generated always as identity primary key,
  grade_level_id bigint not null references public.grade_levels on delete cascade,
  name text not null,
  created_at timestamptz default now()
);

create table public.students (
  id bigint generated always as identity primary key,
  lrn text unique not null check (lrn ~ '^\d{12}$'),
  name text not null,
  sex text check (sex in ('Male', 'Female')),
  section_id bigint references public.sections,
  guardian_name text,
  guardian_contact text,
  created_at timestamptz default now()
);

create table public.medications (
  id bigint generated always as identity primary key,
  name text unique not null,
  dosage text,
  hardware_slot_id int unique check (hardware_slot_id > 0),
  stock_level int not null default 0 check (stock_level >= 0),
  created_at timestamptz default now()
);

create table public.dispensals (
  id bigint generated always as identity primary key,
  student_id bigint not null references public.students on delete cascade,
  medication_id bigint not null references public.medications,
  symptoms jsonb not null,
  status text not null default 'pending' check (status in ('pending', 'processing', 'completed', 'failed')),
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- Students are minors: no direct access. Only the lookup tables are readable;
-- everything else goes through the security definer RPCs below.
alter table public.grade_levels enable row level security;
alter table public.sections enable row level security;
alter table public.students enable row level security;
alter table public.medications enable row level security;
alter table public.dispensals enable row level security;

create policy "read grade_levels" on public.grade_levels for select to anon, authenticated using (true);
create policy "read sections" on public.sections for select to anon, authenticated using (true);

create function public.check_lrn(p_lrn text) returns jsonb
language sql security definer set search_path = '' as $$
  select coalesce(
    (select jsonb_build_object('found', true, 'name', s.name, 'sex', s.sex)
       from public.students s where s.lrn = p_lrn),
    jsonb_build_object('found', false))
$$;

create function public.register_student(
  p_lrn text, p_name text, p_sex text, p_section_id bigint,
  p_guardian_name text, p_guardian_contact text
) returns jsonb
language plpgsql security definer set search_path = '' as $$
begin
  if p_lrn is null or p_lrn !~ '^\d{12}$' then
    raise exception 'LRN must be exactly 12 digits';
  end if;
  insert into public.students (lrn, name, sex, section_id, guardian_name, guardian_contact)
  values (p_lrn, p_name, p_sex, p_section_id, p_guardian_name, p_guardian_contact);
  return jsonb_build_object('status', 'success');
exception when unique_violation then
  raise exception 'LRN already registered';
end $$;

create function public.assess(p_symptoms text[], p_pain_level int) returns jsonb
language plpgsql security definer set search_path = '' as $$
declare
  v_rec text;
  v_med public.medications;
begin
  if coalesce(p_pain_level, 0) >= 4 then
    return jsonb_build_object('recommendation', 'None', 'med_id', null,
      'advice', 'Pain level is high. Please proceed to the clinic immediately.');
  end if;

  if 'Menstrual Cramps' = any(p_symptoms) then v_rec := 'Sanitary Napkin';
  elsif 'Headache' = any(p_symptoms) or 'Fever' = any(p_symptoms) then v_rec := 'Biogesic';
  elsif 'Cough' = any(p_symptoms) or 'Colds' = any(p_symptoms) then v_rec := 'Neozep';
  end if;

  if v_rec is null then
    return jsonb_build_object('recommendation', 'None', 'med_id', null,
      'advice', 'No specific medication matched. Stay hydrated.');
  end if;

  select * into v_med from public.medications where name = v_rec;
  if not found or v_med.stock_level <= 0 then
    raise exception 'Medication (%) out of stock.', v_rec;
  end if;

  return jsonb_build_object('recommendation', v_med.name, 'med_id', v_med.id, 'dosage', v_med.dosage);
end $$;

create function public.request_dispense(p_lrn text, p_symptoms text[], p_pain_level int) returns jsonb
language plpgsql security definer set search_path = '' as $$
declare
  v_student_id bigint;
  v_med_id bigint;
  v_id bigint;
begin
  select id into v_student_id from public.students where lrn = p_lrn;
  if not found then raise exception 'Student not found'; end if;

  -- never trust a client med_id: recompute the recommendation here
  v_med_id := (public.assess(p_symptoms, p_pain_level) ->> 'med_id')::bigint;
  if v_med_id is null then raise exception 'No medication recommended'; end if;

  insert into public.dispensals (student_id, medication_id, symptoms)
  values (v_student_id, v_med_id, to_jsonb(p_symptoms))
  returning id into v_id;

  return jsonb_build_object('status', 'queued', 'dispensal_id', v_id);
end $$;

create function public.claim_next_dispensal() returns jsonb
language sql security definer set search_path = '' as $$
  with c as (
    update public.dispensals
       set status = 'processing', updated_at = now()
     where id = (select id from public.dispensals where status = 'pending'
                  order by created_at, id limit 1 for update skip locked)
    returning id, medication_id
  )
  select coalesce(
    (select jsonb_build_object('command', 'DISPENSE', 'dispensal_id', c.id, 'slot', m.hardware_slot_id)
       from c join public.medications m on m.id = c.medication_id),
    jsonb_build_object('command', 'IDLE'))
$$;

create function public.confirm_dispensal(p_id bigint) returns jsonb
language plpgsql security definer set search_path = '' as $$
declare
  v_d public.dispensals;
  v_med text;
  v_stu public.students;
begin
  update public.dispensals set status = 'completed', updated_at = now()
   where id = p_id and status in ('pending', 'processing')
  returning * into v_d;
  if not found then return jsonb_build_object('ok', false); end if;

  update public.medications set stock_level = greatest(stock_level - 1, 0)
   where id = v_d.medication_id returning name into v_med;
  select * into v_stu from public.students where id = v_d.student_id;

  return jsonb_build_object('ok', true, 'student_name', v_stu.name, 'lrn', v_stu.lrn, 'med_name', v_med);
end $$;

revoke execute on function public.check_lrn(text) from public;
revoke execute on function public.register_student(text, text, text, bigint, text, text) from public;
revoke execute on function public.assess(text[], int) from public;
revoke execute on function public.request_dispense(text, text[], int) from public;
revoke execute on function public.claim_next_dispensal() from public;
revoke execute on function public.confirm_dispensal(bigint) from public;

grant execute on function public.check_lrn(text) to anon;
grant execute on function public.register_student(text, text, text, bigint, text, text) to anon;
grant execute on function public.assess(text[], int) to anon;
grant execute on function public.request_dispense(text, text[], int) to anon;
grant execute on function public.claim_next_dispensal() to service_role;
grant execute on function public.confirm_dispensal(bigint) to service_role;
