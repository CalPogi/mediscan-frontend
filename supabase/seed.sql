insert into public.grade_levels (name) values ('Grade 7');
insert into public.grade_levels (name) values ('Grade 8');
insert into public.grade_levels (name) values ('Grade 9');
insert into public.grade_levels (name) values ('Grade 10');
insert into public.grade_levels (name) values ('Grade 11');
insert into public.grade_levels (name) values ('Grade 12');
insert into public.sections (grade_level_id, name) values
  ((select id from public.grade_levels where name = 'Grade 7'), '7 AMETHYST'),
  ((select id from public.grade_levels where name = 'Grade 7'), '7 SPJ DIAMOND'),
  ((select id from public.grade_levels where name = 'Grade 7'), '7 GARNET'),
  ((select id from public.grade_levels where name = 'Grade 7'), '7 JADE'),
  ((select id from public.grade_levels where name = 'Grade 7'), '7 STE MALACHITE'),
  ((select id from public.grade_levels where name = 'Grade 7'), '7 PEARL'),
  ((select id from public.grade_levels where name = 'Grade 7'), '7 SAPPHIRE');
insert into public.sections (grade_level_id, name) values
  ((select id from public.grade_levels where name = 'Grade 8'), '8 ACACIA'),
  ((select id from public.grade_levels where name = 'Grade 8'), '8 IPIL'),
  ((select id from public.grade_levels where name = 'Grade 8'), '8 SPJ MAHOGANY'),
  ((select id from public.grade_levels where name = 'Grade 8'), '8 MOLAVE'),
  ((select id from public.grade_levels where name = 'Grade 8'), '8 NARRA'),
  ((select id from public.grade_levels where name = 'Grade 8'), '8 STE TALISAY');
insert into public.sections (grade_level_id, name) values
  ((select id from public.grade_levels where name = 'Grade 9'), '9 CATTLEYA'),
  ((select id from public.grade_levels where name = 'Grade 9'), '9 CHAMPACA'),
  ((select id from public.grade_levels where name = 'Grade 9'), '9 ROSE'),
  ((select id from public.grade_levels where name = 'Grade 9'), '9 SAMPAGUITA'),
  ((select id from public.grade_levels where name = 'Grade 9'), '9 TULIP'),
  ((select id from public.grade_levels where name = 'Grade 9'), '9 SPJ JASMINE');
insert into public.sections (grade_level_id, name) values
  ((select id from public.grade_levels where name = 'Grade 10'), '10 AGUINALDO'),
  ((select id from public.grade_levels where name = 'Grade 10'), '10 BONIFACIO'),
  ((select id from public.grade_levels where name = 'Grade 10'), '10 DEL PILAR'),
  ((select id from public.grade_levels where name = 'Grade 10'), '10 LUNA'),
  ((select id from public.grade_levels where name = 'Grade 10'), '10 SPJ JACINTO'),
  ((select id from public.grade_levels where name = 'Grade 10'), '10 RIZAL');
insert into public.sections (grade_level_id, name) values
  ((select id from public.grade_levels where name = 'Grade 11'), '11 ABM R.Lopez'),
  ((select id from public.grade_levels where name = 'Grade 11'), '11 ICT D. Banatao'),
  ((select id from public.grade_levels where name = 'Grade 11'), '11 HUMSS 1 F. Timbreza'),
  ((select id from public.grade_levels where name = 'Grade 11'), '11 HUMSS 2 C. Osias'),
  ((select id from public.grade_levels where name = 'Grade 11'), '11 HUMSS 3 I. Delos Reyes'),
  ((select id from public.grade_levels where name = 'Grade 11'), '11 STEM G. Zara');
insert into public.sections (grade_level_id, name) values
  ((select id from public.grade_levels where name = 'Grade 12'), '12 ABM 1'),
  ((select id from public.grade_levels where name = 'Grade 12'), '12 ABM 2'),
  ((select id from public.grade_levels where name = 'Grade 12'), '12 ICT'),
  ((select id from public.grade_levels where name = 'Grade 12'), '12 HUMSS 1'),
  ((select id from public.grade_levels where name = 'Grade 12'), '12 HUMSS 2'),
  ((select id from public.grade_levels where name = 'Grade 12'), '12 STEM');
insert into public.medications (name, dosage, hardware_slot_id, stock_level) values
  ('Biogesic', '500mg Tablet', 1, 50),
  ('Neozep', '1 Tablet', 2, 50),
  ('Sanitary Napkin', '1 Pad', 3, 30);
