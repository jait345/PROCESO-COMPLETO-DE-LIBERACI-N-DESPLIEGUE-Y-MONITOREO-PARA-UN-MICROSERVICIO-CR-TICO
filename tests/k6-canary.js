import http from 'k6/http'
import { check, sleep } from 'k6'

export const options = {
  vus: 50,
  duration: '3m',
  thresholds: {
    http_req_failed: ['rate<0.02'],
    http_req_duration: ['p(95)<250']
  }
}

export default function () {
  const base = __ENV.CANARY_HOST
  const payload = JSON.stringify({ transactionId: 't' + Date.now(), amount: 10, currency: 'USD', userId: 'u1' })
  const headers = { 'Content-Type': 'application/json' }
  const res = http.post(`${base}/validate`, payload, { headers })
  check(res, { 'status is 200': (r) => r.status === 200 })
  sleep(0.2)
}
