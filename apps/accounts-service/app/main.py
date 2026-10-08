"""Accounts service - manages customer bank accounts.

In-memory repository keeps the demo self-contained; swap AccountRepository
for a PostgreSQL implementation (DATABASE_URL) in real deployments.
"""
from decimal import Decimal
from uuid import uuid4

from fastapi import FastAPI, HTTPException, status
from pydantic import BaseModel, Field

app = FastAPI(title="SecureBank Accounts Service", version="1.0.0")


class AccountCreate(BaseModel):
    owner_name: str = Field(min_length=2, max_length=100)
    currency: str = Field(default="GBP", pattern="^[A-Z]{3}$")
    opening_balance: Decimal = Field(default=Decimal("0.00"), ge=0, decimal_places=2)


class Account(BaseModel):
    id: str
    owner_name: str
    currency: str
    balance: Decimal
    sort_code: str
    account_number: str


class BalanceChange(BaseModel):
    amount: Decimal = Field(decimal_places=2)


class AccountRepository:
    def __init__(self) -> None:
        self._items: dict[str, Account] = {}

    def create(self, data: AccountCreate) -> Account:
        acc = Account(
            id=str(uuid4()),
            owner_name=data.owner_name,
            currency=data.currency,
            balance=data.opening_balance,
            sort_code="04-00-04",
            account_number=str(uuid4().int)[:8],
        )
        self._items[acc.id] = acc
        return acc

    def get(self, account_id: str) -> Account | None:
        return self._items.get(account_id)


repo = AccountRepository()


@app.get("/healthz", tags=["ops"])
def healthz() -> dict:
    return {"status": "ok"}


@app.get("/readyz", tags=["ops"])
def readyz() -> dict:
    return {"status": "ready"}


@app.post("/accounts", response_model=Account, status_code=status.HTTP_201_CREATED)
def create_account(payload: AccountCreate) -> Account:
    return repo.create(payload)


@app.get("/accounts/{account_id}", response_model=Account)
def get_account(account_id: str) -> Account:
    acc = repo.get(account_id)
    if not acc:
        raise HTTPException(status_code=404, detail="Account not found")
    return acc


@app.post("/accounts/{account_id}/balance", response_model=Account)
def adjust_balance(account_id: str, change: BalanceChange) -> Account:
    """Internal endpoint called by transactions-service (protected by NetworkPolicy)."""
    acc = repo.get(account_id)
    if not acc:
        raise HTTPException(status_code=404, detail="Account not found")
    new_balance = acc.balance + change.amount
    if new_balance < 0:
        raise HTTPException(status_code=409, detail="Insufficient funds")
    acc.balance = new_balance
    return acc
