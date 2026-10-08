from uuid import uuid4

from fastapi.testclient import TestClient

from app.main import app

client = TestClient(app)
BODY = {"from_account": "acc-1111", "to_account": "acc-2222", "amount": "42.50", "reference": "RENT OCT"}


def test_transfer_created():
    r = client.post("/transfers", json=BODY, headers={"Idempotency-Key": str(uuid4())})
    assert r.status_code == 201
    assert r.json()["status"] == "COMPLETED"


def test_idempotency_returns_same_transfer():
    key = str(uuid4())
    a = client.post("/transfers", json=BODY, headers={"Idempotency-Key": key}).json()
    b = client.post("/transfers", json=BODY, headers={"Idempotency-Key": key}).json()
    assert a["id"] == b["id"]


def test_same_account_rejected():
    body = {**BODY, "to_account": BODY["from_account"]}
    r = client.post("/transfers", json=body, headers={"Idempotency-Key": str(uuid4())})
    assert r.status_code == 422


def test_limit_exceeded_rejected():
    body = {**BODY, "amount": "30000.00"}
    r = client.post("/transfers", json=body, headers={"Idempotency-Key": str(uuid4())})
    assert r.status_code == 422


def test_missing_idempotency_key_rejected():
    assert client.post("/transfers", json=BODY).status_code == 422
