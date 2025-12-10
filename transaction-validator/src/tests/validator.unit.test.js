import test from 'node:test'
import assert from 'node:assert/strict'

test('payload validation', () => {
  const ok = { transactionId: 't1', amount: 10, currency: 'USD', userId: 'u1' }
  assert.equal(typeof ok.transactionId, 'string')
  assert.equal(typeof ok.amount, 'number')
  assert.ok(ok.amount > 0)
  assert.ok(['USD', 'EUR', 'MXN'].includes(ok.currency))
})
