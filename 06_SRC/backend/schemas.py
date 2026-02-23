from pydantic import BaseModel
from typing import List, Optional, Any, Dict
from datetime import datetime

class SendOtpRequest(BaseModel):
    phone: str

class VerifyOtpRequest(BaseModel):
    phone: str
    code: str

class UserUpdateProfileRequest(BaseModel):
    phone_number: str
    full_name: str
    region_id: int
    role: str = "user"
    show_phone: bool = True
    allow_telegram: bool = True

class LinkTelegramRequest(BaseModel):
    phone: str
    telegram_chat_id: int

class UserResponse(BaseModel):
    id: str
    phone_number: str
    full_name: Optional[str] = None
    role: str
    region_id: Optional[int] = None
    is_verified: bool
    
    class Config:
        from_attributes = True

class CategoryResponse(BaseModel):
    id: int
    name_uz: str
    slug: str
    icon_url: Optional[str] = None
    
    class Config:
        from_attributes = True

class RegionResponse(BaseModel):
    id: int
    name_uz: str
    name_ru: str
    
    class Config:
        from_attributes = True

class CreateBirdRequest(BaseModel):
    category_id: int
    breed: str
    price: float
    description: str
    region_id: int
    user_id: str

class BirdResponse(BaseModel):
    id: str
    category_id: int
    region_id: int
    species: Optional[str] = None
    price: float
    status: str
    seller_name: Optional[str] = None
    seller_phone: Optional[str] = None
    region_name: Optional[str] = None
    media: Optional[List[Dict[str, Any]]] = []
    
    class Config:
        from_attributes = True

class TransactionRequest(BaseModel):
    bird_id: str
    amount: float
    payment_method: str
    buyer_id: str

class MockConfirmRequest(BaseModel):
    transaction_id: str

class ChatMessageCreate(BaseModel):
    room_id: str
    content: str
    message_type: str = "text"
