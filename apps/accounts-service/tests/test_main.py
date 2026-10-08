from fastapi.testclient import TestClient

from app.main import app

client = TestClient(app)


def test_health():
    assert client.get("/healthz").json() == {"status": "ok"}


def test_create_and_get_account():
    r = client.post("/accounts", json={"owner_name": "Ada Lovelace", "opening_balance": "100.00"})
    assert r.status_code == 201
    acc = r.json()
    assert acc["currency"] == "GBP"
    assert client.get(f"/accounts/{acc['id']}").json()["owner_name"] == "Ada Lovelace"


def test_insufficient_funds_rejected():
    acc = client.post("/accounts", json={"owner_name": "Alan Turing", "opening_balance": "10.00"}).json()
    r = client.post(f"/accounts/{acc['id']}/balance", json={"amount": "-50.00"})
    assert r.status_code == 409


def test_invalid_currency_rejected():
    r = client.post("/accounts", json={"owner_name": "Grace Hopper", "currency": "pounds"})
    assert r.status_code == 422
