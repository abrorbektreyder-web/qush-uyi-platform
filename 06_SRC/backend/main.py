from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import random

app = FastAPI(title="Qush Uyi API", version="1.0")

# CORS Configuration (Allow All for Web/Desktop dev)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Models
class SendOtpRequest(BaseModel):
    phone: str

class VerifyOtpRequest(BaseModel):
    phone: str
    code: str

# In-memory storage for demo purposes (Use Redis/DB in production)
otp_storage = {}

@app.post("/auth/send-otp")
async def send_otp(request: SendOtpRequest):
    # Generate 4-digit mock code
    mock_code = str(random.randint(1000, 9999))
    otp_storage[request.phone] = mock_code
    
    # In real app, send request to SMS provider here
    return {
        "message": "SMS sent successfully",
        "debug_code": mock_code, # Returned for testing ease
        "phone": request.phone
    }

@app.post("/auth/verify-otp")
async def verify_otp(request: VerifyOtpRequest):
    stored_code = otp_storage.get(request.phone)
    
    if not stored_code:
        raise HTTPException(status_code=400, detail="OTP not sent or expired")
    
    if request.code != stored_code and request.code != "1122": # 1122 is master code
        raise HTTPException(status_code=400, detail="Invalid OTP code")
        
    # Clear OTP after success
    if request.phone in otp_storage:
        del otp_storage[request.phone]
        
    # Generate Mock JWT
    mock_token = f"ey_mock_jwt_token_for_{request.phone}"
    
    return {
        "access_token": mock_token,
        "token_type": "bearer",
        "user_role": "user", # Default role
        "is_new_user": True # Mock status
    }

@app.get("/")
async def root():
    return {"message": "Qush Uyi API is running"}
