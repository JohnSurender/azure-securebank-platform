"""Transactions service - money transfers with idempotency and audit trail."""
import logging
from datetime import datetime, timezone
from decimal import Decimal
from uuid import uuid4

from fastapi import FastAPI, Header, HTTPException, status
from pydantic import BaseModel, Field, model_validator

logging.basicConfig(level=logging.INFO, format='{"level":"%(levelname)s","msg":"%(message)s"}')
log = logging.getLogger("transactions")

app = FastAPI(title="SecureBank Transactions Service", version="1.0.0")

MAX_SINGLE_TRANSFER = Decimal("25000.00")  # fraud / AML guardrail


class TransferRequest(BaseModel):
    from_account: str
    to_account: str
    amount: Decimal = Field(gt=0, decimal_places=2)
    currency: str = Field(default="GBP", pattern="^[A-Z]{3}$")
    reference: str = Field(default="", max_length=18)  # Faster Payments ref limit

    @model_validator(mode="after")
    def different_accounts(self):
        if self.from_account == self.to_account:
            raise ValueError("from_account and to_account must differ")
        return self


class Transfer(BaseModel):
    id: str
    status: str
    created_at: datetime
    request: TransferRequest


_ledger: dict[str, Transfer] = {}
_idempotency: dict[str, str] = {}


@app.get("/healthz", tags=["ops"])
def healthz() -> dict:
    return {"status": "ok"}


@app.get("/readyz", tags=["ops"])
def readyz() -> dict:
    return {"status": "ready"}


@app.post("/transfers", response_model=Transfer, status_code=status.HTTP_201_CREATED)
def create_transfer(req: TransferRequest, idempotency_key: str = Header(..., alias="Idempotency-Key")) -> Transfer:
    if idempotency_key in _idempotency:
        return _ledger[_idempotency[idempotency_key]]
    if req.amount > MAX_SINGLE_TRANSFER:
        log.warning("transfer flagged for manual review amount=%s", req.amount)
        raise HTTPException(status_code=422, detail="Amount exceeds single-transfer limit; manual review required")

    t = Transfer(id=str(uuid4()), status="COMPLETED", created_at=datetime.now(timezone.utc), request=req)
    _ledger[t.id] = t
    _idempotency[idempotency_key] = t.id
    # Audit log: never log full account numbers (PCI DSS 3.4 masking principle)
    log.info("transfer id=%s from=***%s to=***%s amount=%s", t.id, req.from_account[-4:], req.to_account[-4:], req.amount)
    return t


@app.get("/transfers/{transfer_id}", response_model=Transfer)
def get_transfer(transfer_id: str) -> Transfer:
    if transfer_id not in _ledger:
        raise HTTPException(status_code=404, detail="Transfer not found")
    return _ledger[transfer_id]
