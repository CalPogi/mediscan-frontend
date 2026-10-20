import { createClient } from 'npm:@supabase/supabase-js@2'

const json = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), { status, headers: { 'Content-Type': 'application/json' } })

const db = createClient(Deno.env.get('SUPABASE_URL')!, Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!)

async function sendSms(d: { student_name: string; lrn: string; med_name: string }) {
  const apikey = Deno.env.get('SEMAPHORE_API_KEY')
  const number = Deno.env.get('NURSE_PHONE_NUMBER')
  if (!apikey || !number) return
  const time = new Date().toLocaleTimeString('en-US', {
    timeZone: 'Asia/Manila', hour: '2-digit', minute: '2-digit', hour12: true,
  })
  const message = `ADVISORY: Student ${d.student_name} (LRN: ${d.lrn}) has dispensed 1 unit of ${d.med_name} at ${time}`
  try {
    await fetch('https://api.semaphore.co/api/v4/messages', {
      method: 'POST',
      body: new URLSearchParams({ apikey, number, message, sendername: 'SEMAPHORE' }),
    })
  } catch (e) {
    console.error('SMS Failed:', e)
  }
}

Deno.serve(async (req) => {
  const key = Deno.env.get('ESP_API_KEY')
  if (!key || req.headers.get('X-API-KEY') !== key) return json({ error: 'Unauthorized Hardware' }, 401)

  // path looks like /hardware/check-pending or /functions/v1/hardware/...
  const path = new URL(req.url).pathname.replace(/^.*?\/hardware/, '')

  if (req.method === 'GET' && path === '/check-pending') {
    const { data, error } = await db.rpc('claim_next_dispensal')
    if (error) return json({ error: error.message }, 500)
    return json(data)
  }

  const m = path.match(/^\/confirm-dispense\/(\d+)$/)
  if (req.method === 'POST' && m) {
    const { data, error } = await db.rpc('confirm_dispensal', { p_id: Number(m[1]) })
    if (error) return json({ error: error.message }, 500)
    if (!data.ok) return json({ error: 'Invalid Log' }, 400)
    await sendSms(data)
    return json({ status: 'completed' })
  }

  return json({ error: 'Not Found' }, 404)
})
