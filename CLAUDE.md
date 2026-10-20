# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Scope

This repo (`CalPogi/mediscan-frontend`, branch `main`) is a standalone Vue 3 + Vite + TS kiosk
front end for MediScan, a school medicine dispenser. The parent folder's `CLAUDE.md` describes
the unrelated Accommo apps — none of its conventions apply here. The backend is Supabase project
`uzetpolgkcmtabpczgdn` (schema, RPCs and the hardware edge function live in `supabase/`). The old
Laravel backend (`../mediscan-backend`) is retired reference only.

## Commands

```bash
npm install
npm run dev                 # vite on :5173
npm run build               # type-check (vue-tsc --build) + vite build, in parallel
npm run type-check
npm run lint                # oxlint then eslint — both run with --fix and rewrite files
npm run format              # prettier on src/ (no semis, single quotes, width 100)
npx vitest run              # unit tests once; `npm run test:unit` is watch mode
npx vitest run path/to/file.spec.ts
npx vitest run -t "case name"
npx supabase db push        # apply supabase/migrations (add --include-seed on an empty db)
npx supabase gen types typescript --project-id uzetpolgkcmtabpczgdn > src/types/database.gen.ts  # after any migration; never hand-edit
npx supabase functions deploy hardware
npx supabase secrets set ESP_API_KEY=...   # also optional SEMAPHORE_API_KEY, NURSE_PHONE_NUMBER
npx playwright install      # first e2e run only
npm run test:e2e -- --project=chromium
```

There are no unit tests yet. `e2e/vue.spec.ts` is the untouched scaffold (expects an `h1` of
"You did it!") and fails against the real home page. Prettier has not been applied — views use
semicolons — so don't run `format` as part of an unrelated change.

## Architecture

Flat: `views/` call `services/api.ts` (the supabase-js client, typed with
`src/types/database.gen.ts`) directly with local refs. No state layer; `components/PageLayout.vue`
is unused. Env: `VITE_SUPABASE_URL`, `VITE_SUPABASE_ANON_KEY` in gitignored `.env.local`
(template: `.env.example`).

- `components/App*.vue` — small presentational primitives (button/card/input/form-group/
  background) used by every view. Colors come from CSS variables in `assets/main.css`
  (`--navy-primary`, `--danger`, …).
- Vue SFCs here put `<template>` first, then `<script setup lang="ts">`, then `<style scoped>`.

### Supabase

RLS is on for all 5 tables (`grade_levels`, `sections`, `students`, `medications`, `dispensals`).
The only policy is anon/authenticated SELECT on `grade_levels` and `sections`; students are
minors, so everything else goes through `security definer` RPCs (`search_path = ''`). Errors
raised by the RPCs surface as `error.message` in supabase-js and are shown to the user as-is.
New functions get execute granted to anon/authenticated by Supabase default privileges, so
always `revoke ... from anon, authenticated` explicitly, not just `from public`.

- anon RPCs: `check_lrn` (`{found,name,sex}`, no guardian data), `register_student`,
  `assess(symptoms, pain)` (port of the old AssessmentController), `request_dispense(lrn,
  symptoms, pain)` (re-runs `assess` server-side, never takes a client med_id, queues `pending`).
- service_role only: `claim_next_dispensal` (pending -> processing, returns `DISPENSE`/`IDLE`),
  `confirm_dispensal` (-> completed, stock -1).
- Edge function `hardware` (`verify_jwt = false`, requires header `X-API-KEY` = secret
  `ESP_API_KEY`): `GET https://uzetpolgkcmtabpczgdn.supabase.co/functions/v1/hardware/check-pending`
  and `POST .../hardware/confirm-dispense/:id`. Sends a Semaphore SMS to the nurse only if
  `SEMAPHORE_API_KEY` and `NURSE_PHONE_NUMBER` are set; SMS failure never fails the response.
- `supabase/seed.sql` holds the grades/sections and 3 medications.

### Kiosk flow (the student's LRN is the only identity)

1. `HomePage` → `/login` (`LoginView`): student types their LRN; rpc `check_lrn`.
   `found` → assessment; otherwise offer registration.
2. `/register/:lrn?` (`RegisView`): selects `grade_levels` with nested `sections` (grade select
   filters the section select); rpc `register_student`, then → assessment. The DB enforces a
   12-digit LRN.
3. `/assessment/:lrn` (`AssessmentView`): `check_lrn` for name and sex (sex `Female` adds
   "Menstrual Cramps" to the symptom list); rpc `assess`; rpc `request_dispense` with
   `lrn` + symptoms + pain level. Sleep/water/last-meal inputs are collected but ignored.

`request_dispense` only **queues** a `pending` dispensal row. The physical ESP device polls
`hardware/check-pending` and calls `hardware/confirm-dispense/:id` afterwards — the frontend
never talks to hardware and doesn't wait for confirmation, so its "Success! Dispensing…" alert
means "queued", and its "Hardware timeout." alert fires on any request error.
