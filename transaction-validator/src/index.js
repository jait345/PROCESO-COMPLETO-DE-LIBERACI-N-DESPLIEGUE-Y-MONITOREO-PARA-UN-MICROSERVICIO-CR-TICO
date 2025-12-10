import express from 'express'
import pino from 'pino'
import pinoHttp from 'pino-http'
import client from 'prom-client'

const PORT = process.env.PORT || 8080
const LOG_LEVEL = process.env.LOG_LEVEL || 'info'
const ENABLE_OTEL = process.env.ENABLE_OTEL === '1'

if (ENABLE_OTEL) {
  await import('./otel.js')
}

const logger = pino({ level: LOG_LEVEL })
const app = express()
app.use(express.json())
app.use(pinoHttp({ logger }))

client.collectDefaultMetrics()
const httpHistogram = new client.Histogram({
  name: 'http_request_duration_ms',
  help: 'http latency',
  labelNames: ['route', 'method', 'status'],
  buckets: [50, 100, 150, 200, 250, 500, 1000]
})

app.use((req, res, next) => {
  const start = process.hrtime.bigint()
  res.on('finish', () => {
    const end = process.hrtime.bigint()
    const ms = Number(end - start) / 1e6
    httpHistogram.observe({ route: req.route?.path || req.path, method: req.method, status: String(res.statusCode) }, ms)
  })
  next()
})

app.get('/health', (req, res) => {
  res.json({ status: 'ok' })
})

app.get('/metrics', async (req, res) => {
  res.set('Content-Type', client.register.contentType)
  res.end(await client.register.metrics())
})

app.post('/validate', (req, res) => {
  const { transactionId, amount, currency, userId } = req.body || {}
  if (!transactionId || typeof amount !== 'number' || amount <= 0 || !currency || !userId) {
    req.log.warn({ transactionId, userId }, 'invalid payload')
    return res.status(400).json({ ok: false, message: 'invalid payload' })
  }
  if (!['USD', 'EUR', 'MXN'].includes(currency)) {
    req.log.warn({ currency }, 'unsupported currency')
    return res.status(400).json({ ok: false, message: 'unsupported currency' })
  }
  res.json({ ok: true })
})

app.listen(PORT, () => {
  logger.info({ port: PORT }, 'transaction-validator started')
})
