from fastapi import FastAPI, HTTPException
from pydantic import BaseModel

app = FastAPI()

class LoginRequest(BaseModel):
    phone: str

class VerifyRequest(BaseModel):
    phone: str
    code: str
    otp_hash: str

@app.post("/auth/login")
async def login(request: LoginRequest):
    # Mock SMS sending
    return {"message": "SMS sent", "otp_hash": "mock_hash_123"}

@app.post("/auth/verify")
async def verify(request: VerifyRequest):
    if request.code == "1122":
        return {
            "access_token": "mock_token_jwt",
            "user": {
                "id": "user_1",
                "role": "user",
                "is_new_user": False
            }
        }
    raise HTTPException(status_code=400, detail="Invalid code")
