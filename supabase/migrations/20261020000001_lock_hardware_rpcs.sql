-- Supabase's default privileges grant execute to anon/authenticated directly,
-- so "revoke from public" alone leaves these callable. Revoke explicitly.
revoke execute on function public.claim_next_dispensal() from anon, authenticated;
revoke execute on function public.confirm_dispensal(bigint) from anon, authenticated;
revoke execute on function public.check_lrn(text) from authenticated;
revoke execute on function public.register_student(text, text, text, bigint, text, text) from authenticated;
revoke execute on function public.assess(text[], int) from authenticated;
revoke execute on function public.request_dispense(text, text[], int) from authenticated;
