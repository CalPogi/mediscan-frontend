-- Laravel validated these as required; the init migration left them nullable.
alter table public.students
  alter column sex set not null,
  alter column section_id set not null,
  alter column guardian_name set not null,
  alter column guardian_contact set not null;
-- a medication without a slot would hand the ESP `slot: null`
alter table public.medications
  alter column dosage set not null,
  alter column hardware_slot_id set not null;
