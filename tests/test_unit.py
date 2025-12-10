import unittest

class TestValidatorPayload(unittest.TestCase):
    def test_valid_payload(self):
        payload = {"transactionId": "t1", "amount": 10, "currency": "USD", "userId": "u1"}
        self.assertIsInstance(payload["transactionId"], str)
        self.assertIsInstance(payload["amount"], int)
        self.assertGreater(payload["amount"], 0)
        self.assertIn(payload["currency"], ["USD", "EUR", "MXN"])

if __name__ == "__main__":
    unittest.main()
