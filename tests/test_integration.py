import os
import unittest
import json
import requests

BASE = os.environ.get("CANARY_HOST")

@unittest.skipIf(BASE is None, "CANARY_HOST not set")
class TestIntegration(unittest.TestCase):
    def test_health(self):
        r = requests.get(f"{BASE}/health", timeout=5)
        self.assertEqual(r.status_code, 200)
        self.assertEqual(r.json().get("status"), "ok")

    def test_validate(self):
        payload = {"transactionId":"t1","amount":10,"currency":"USD","userId":"u1"}
        r = requests.post(f"{BASE}/validate", headers={"Content-Type":"application/json"}, data=json.dumps(payload), timeout=5)
        self.assertEqual(r.status_code, 200)
        self.assertTrue(r.json().get("ok"))

if __name__ == "__main__":
    unittest.main()
