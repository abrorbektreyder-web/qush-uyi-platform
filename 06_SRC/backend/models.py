import uuid
from datetime import datetime
from sqlalchemy import Column, String, Integer, Boolean, Float, ForeignKey, DateTime, JSON, Text
from sqlalchemy.orm import relationship
from database import Base

def generate_uuid():
    return str(uuid.uuid4())

class Region(Base):
    __tablename__ = "regions"
    id = Column(Integer, primary_key=True, index=True)
    name_uz = Column(String(50))
    name_ru = Column(String(50))

class Category(Base):
    __tablename__ = "categories"
    id = Column(Integer, primary_key=True, index=True)
    name_uz = Column(String(50))
    slug = Column(String(50), unique=True)
    icon_url = Column(Text, nullable=True)

class User(Base):
    __tablename__ = "users"
    id = Column(String, primary_key=True, default=generate_uuid, index=True)
    phone_number = Column(String(15), unique=True, index=True, nullable=True)
    telegram_id = Column(Integer, unique=True, index=True, nullable=True)
    telegram_chat_id = Column(Integer, unique=True, index=True, nullable=True)
    username = Column(String(50), unique=True, nullable=True)
    full_name = Column(String(100), nullable=True)
    region_id = Column(Integer, ForeignKey("regions.id"), nullable=True)
    avatar_url = Column(Text, nullable=True)
    
    role = Column(String(20), default="user") # user, seller, vet, admin, driver
    is_verified = Column(Boolean, default=False)
    show_phone = Column(Boolean, default=True)
    allow_telegram = Column(Boolean, default=True)
    rating = Column(Float, default=0.0)
    balance = Column(Float, default=0.0)
    
    last_login = Column(DateTime, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

class Transaction(Base):
    __tablename__ = "transactions"
    id = Column(String, primary_key=True, default=generate_uuid, index=True)
    user_id = Column(String, ForeignKey("users.id"))
    bird_id = Column(String, ForeignKey("birds.id"))
    amount = Column(Float, nullable=False)
    payment_method = Column(String(20)) # payme, click
    status = Column(String(20), default="pending") # pending, held, released, refunded
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

class VetProfile(Base):
    __tablename__ = "vet_profiles"
    user_id = Column(String, ForeignKey("users.id", ondelete="CASCADE"), primary_key=True)
    license_number = Column(String(50), nullable=False)
    clinic_name = Column(String(100), nullable=True)
    location = Column(String(100), nullable=True) # Point alternative for simple SQLite fallback
    experience_years = Column(Integer, nullable=True)
    status = Column(String(20), default="pending")

class Bird(Base):
    __tablename__ = "birds"
    id = Column(String, primary_key=True, default=generate_uuid, index=True)
    owner_id = Column(String, ForeignKey("users.id", ondelete="CASCADE"))
    category_id = Column(Integer, ForeignKey("categories.id"))
    region_id = Column(Integer, ForeignKey("regions.id"))
    
    species = Column(String(100))
    age_months = Column(Integer, nullable=True)
    gender = Column(String(10), default="unknown")
    weight_grams = Column(Integer, nullable=True)
    description = Column(Text, nullable=True)
    
    price = Column(Float, nullable=True)
    currency = Column(String(3), default="UZS")
    price_type = Column(String(20), default="fixed")
    delivery_options = Column(JSON, default=dict) # pickup, taxi
    
    status = Column(String(20), default="active", index=True)
    health_badge = Column(String(20), default="none")
    views_count = Column(Integer, default=0)
    likes_count = Column(Integer, default=0)
    created_at = Column(DateTime, default=datetime.utcnow)
    
    # Relationships
    owner = relationship("User")
    media = relationship("BirdMedia", back_populates="bird", cascade="all, delete")

class BirdMedia(Base):
    __tablename__ = "bird_media"
    id = Column(String, primary_key=True, default=generate_uuid, index=True)
    bird_id = Column(String, ForeignKey("birds.id", ondelete="CASCADE"))
    media_type = Column(String(10)) # image, video, audio
    file_url = Column(Text, nullable=False)
    is_primary = Column(Boolean, default=False)
    sort_order = Column(Integer, default=0)
    
    bird = relationship("Bird", back_populates="media")

class HealthRecord(Base):
    __tablename__ = "health_records"
    id = Column(String, primary_key=True, default=generate_uuid, index=True)
    bird_id = Column(String, ForeignKey("birds.id", ondelete="CASCADE"))
    vet_id = Column(String, ForeignKey("users.id"))
    diagnosis = Column(Text, nullable=True)
    vaccine_info = Column(Text, nullable=True)
    attachment_url = Column(Text, nullable=True)
    qr_code_hash = Column(String(255), nullable=True)
    checkup_date = Column(DateTime, default=datetime.utcnow)
    valid_until = Column(DateTime, nullable=True)

class Order(Base):
    __tablename__ = "orders"
    id = Column(String, primary_key=True, default=generate_uuid, index=True)
    bird_id = Column(String, ForeignKey("birds.id"))
    buyer_id = Column(String, ForeignKey("users.id"))
    seller_id = Column(String, ForeignKey("users.id"))
    
    total_amount = Column(Float)
    platform_fee = Column(Float, default=0.0)
    escrow_status = Column(String(30), default="created")
    
    payment_method = Column(String(20))
    delivery_method = Column(String(20))
    driver_info = Column(JSON, nullable=True)
    
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

class ChatRoom(Base):
    __tablename__ = "chat_rooms"
    id = Column(String, primary_key=True, default=generate_uuid, index=True)
    bird_id = Column(String, ForeignKey("birds.id"))
    buyer_id = Column(String, ForeignKey("users.id"))
    seller_id = Column(String, ForeignKey("users.id"))
    last_message_at = Column(DateTime, default=datetime.utcnow)

class Message(Base):
    __tablename__ = "messages"
    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    room_id = Column(String, ForeignKey("chat_rooms.id", ondelete="CASCADE"))
    sender_id = Column(String, ForeignKey("users.id"))
    
    content = Column(Text, nullable=True)
    media_url = Column(Text, nullable=True)
    message_type = Column(String(20), default="text")
    is_read = Column(Boolean, default=False)
    created_at = Column(DateTime, default=datetime.utcnow, index=True)

class ShopItem(Base):
    __tablename__ = "shop_items"
    id = Column(String, primary_key=True, default=generate_uuid, index=True)
    name = Column(String(100), nullable=False)
    description = Column(Text, nullable=True)
    price = Column(Float, nullable=False)
    stock_quantity = Column(Integer, default=0)
    category = Column(String(50)) # yem, dori, qafas
    image_url = Column(Text, nullable=True)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime, default=datetime.utcnow)

class ShopOrder(Base):
    __tablename__ = "shop_orders"
    id = Column(String, primary_key=True, default=generate_uuid, index=True)
    user_id = Column(String, ForeignKey("users.id"))
    total_amount = Column(Float, nullable=False)
    status = Column(String(30), default="new") # new, packing, shipping, delivered
    shipping_address = Column(Text, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)
