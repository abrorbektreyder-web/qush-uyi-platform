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

class UserUpdateProfileRequest(BaseModel):
    full_name: str
    region_id: int

# In-memory storage for demo purposes (Use Redis/DB in production)
otp_storage = {}

# Mock Regions Data
REGIONS = [
    {"id": 1, "name_uz": "Andijon viloyati"},
    {"id": 2, "name_uz": "Buxoro viloyati"},
    {"id": 3, "name_uz": "Farg'ona viloyati"},
    {"id": 4, "name_uz": "Jizzax viloyati"},
    {"id": 5, "name_uz": "Xorazm viloyati"},
    {"id": 6, "name_uz": "Namangan viloyati"},
    {"id": 7, "name_uz": "Navoiy viloyati"},
    {"id": 8, "name_uz": "Qashqadaryo viloyati"},
    {"id": 9, "name_uz": "Samarqand viloyati"},
    {"id": 10, "name_uz": "Sirdaryo viloyati"},
    {"id": 11, "name_uz": "Surxondaryo viloyati"},
    {"id": 12, "name_uz": "Toshkent viloyati"},
    {"id": 13, "name_uz": "Toshkent shahri"},
    {"id": 14, "name_uz": "Qoraqalpog'iston Respublikasi"},
]

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
        "is_new_user": True, # Always true for demo to trigger profile fill
        "user": {
            "id": "mock_user_id",
            "phone": request.phone
        }
    }

@app.get("/regions")
async def get_regions():
    return REGIONS

@app.post("/user/update-profile")
async def update_profile(request: UserUpdateProfileRequest):
    # Mock update logic
    return {
        "status": "success",
        "message": "Profile updated successfully",
        "user": {
            "full_name": request.full_name,
            "region_id": request.region_id
        }
    }

@app.get("/")
async def root():
    return {"message": "Qush Uyi API is running"}
