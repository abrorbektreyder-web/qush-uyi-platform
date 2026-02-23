from fastapi import FastAPI, HTTPException, Form, File, UploadFile, Depends, BackgroundTasks, WebSocket, WebSocketDisconnect
from fastapi.staticfiles import StaticFiles
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
from typing import List, Optional, Dict
import os
import shutil
import random
import qrcode
from datetime import datetime
import json
import subprocess
import httpx
import asyncio

from database import engine, get_db, Base
import models
import schemas

# Create DB Schema
models.Base.metadata.create_all(bind=engine)

app = FastAPI(title="Qush Uyi Platform API", version="1.0-MVP")

# CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Uploads Setup
UPLOAD_DIR = "uploads"
QR_DIR = "uploads/qrcodes"
DOC_DIR = "uploads/docs"
os.makedirs(UPLOAD_DIR, exist_ok=True)
os.makedirs(QR_DIR, exist_ok=True)
os.makedirs(DOC_DIR, exist_ok=True)
app.mount("/uploads", StaticFiles(directory="uploads"), name="uploads")

TELEGRAM_BOT_TOKEN = os.getenv("TELEGRAM_BOT_TOKEN", "mock_token")
ADMIN_CHAT_ID = os.getenv("ADMIN_CHAT_ID", "123456")

async def send_telegram_notification(chat_id: str, message: str):
    if TELEGRAM_BOT_TOKEN == "mock_token":
        print(f"[MOCK TELEGRAM Notification to {chat_id}]: {message}")
        return
    url = f"https://api.telegram.org/bot{TELEGRAM_BOT_TOKEN}/sendMessage"
    async with httpx.AsyncClient() as client:
        try:
            await client.post(url, json={"chat_id": chat_id, "text": message})
        except Exception as e:
            print(f"Telegram API Error: {e}")

# --- STARTUP EVENT (SEEDS) ---
@app.on_event("startup")
def seed_database():
    db = next(get_db())
    # Seed Regions
    if db.query(models.Region).count() == 0:
        regions = ["Toshkent shahri", "Toshkent viloyati", "Andijon", "Buxoro", "Jizzax", 
                   "Qashqadaryo", "Navoiy", "Namangan", "Samarqand", "Surxondaryo", 
                   "Sirdaryo", "Xorazm", "Farg'ona", "Qoraqalpog'iston"]
        for r in regions:
            db.add(models.Region(name_uz=r, name_ru=r))
    # Seed Categories
    if db.query(models.Category).count() == 0:
        categories = ["Kabutar", "To'ti", "Kanareyka", "Bedana", "Tovuq", "O'rdak", "G'oz", "Boshqa"]
        for c in categories:
            db.add(models.Category(name_uz=c, slug=c.lower().replace("'", "")))
            
    # Seed Shop Items (MVP)
    if db.query(models.ShopItem).count() == 0:
        shop_items = [
            models.ShopItem(name="Premium Don", description="Qushlar uchun ozuqa", price=45000, stock_quantity=100, category="yem"),
            models.ShopItem(name="Vitaminki", description="Qushlar salomatligi uchun dorilar", price=25000, stock_quantity=50, category="dori"),
            models.ShopItem(name="Katta Qafas (Golden)", description="To'tilar uchun", price=350000, stock_quantity=10, category="qafas")
        ]
        db.add_all(shop_items)
            
    db.commit()

# --- AUTH ENDPOINTS ---
otp_storage = {}

@app.post("/auth/send-otp")
async def send_otp(request: schemas.SendOtpRequest):
    mock_code = "1122" # Fixed mock code
    otp_storage[request.phone] = mock_code
    return {"message": "SMS sent", "debug_code": mock_code, "phone": request.phone}

@app.post("/auth/verify-otp")
async def verify_otp(request: schemas.VerifyOtpRequest, db: Session = Depends(get_db)):
    stored_code = otp_storage.get(request.phone)
    if not stored_code or (request.code != stored_code and request.code != "1122"):
        raise HTTPException(status_code=400, detail="Invalid OTP")
    
    if request.phone in otp_storage:
        del otp_storage[request.phone]
        
    user = db.query(models.User).filter_by(phone_number=request.phone).first()
    is_new = False
    if not user:
        is_new = True
        user = models.User(phone_number=request.phone)
        db.add(user)
        db.commit()
        db.refresh(user)

    user.last_login = datetime.utcnow()
    db.commit()
        
    return {
        "access_token": f"mock_token_{user.id}",
        "token_type": "bearer",
        "user_role": user.role,
        "is_new_user": is_new,
        "user_id": user.id
    }

# --- USER ENDPOINTS ---
@app.get("/regions")
async def get_regions(db: Session = Depends(get_db)):
    return db.query(models.Region).all()

@app.get("/categories")
async def get_categories(db: Session = Depends(get_db)):
    return db.query(models.Category).all()

@app.post("/user/update-profile")
async def update_profile(
    phone_number: str = Form(...),
    full_name: str = Form(...),
    region_id: int = Form(...),
    role: str = Form("user"),
    db: Session = Depends(get_db)
):
    user = db.query(models.User).filter_by(phone_number=phone_number).first()
    if not user:
        raise HTTPException(404, "User not found")
        
    user.full_name = full_name
    user.region_id = region_id
    user.role = role
    db.commit()
    db.refresh(user)
    return {"status": "success", "user": user}

@app.post("/user/link-telegram")
async def link_telegram(request: schemas.LinkTelegramRequest, db: Session = Depends(get_db)):
    user = db.query(models.User).filter_by(phone_number=request.phone).first()
    if not user: raise HTTPException(404, "User not found")
    
    user.telegram_chat_id = request.telegram_chat_id
    db.commit()
    return {"status": "success", "message": "Telegram successfully linked", "user": user}

# --- BIRD & MEDIA PROCESSOR ---
async def compress_video(input_path: str, output_path: str):
    """
    Katta videolarni serverda siqish (FFMPEG).
    MVP uchun, agar ffmpeg yo'q bo'lsa xato bermaydi, shunchaki nusxa ko'chiradi.
    ASINXRON (Async) logikasi qo'shildi: server oqimlarini qotirib qo'ymaydi.
    """
    try:
        command = [
            "ffmpeg", "-i", input_path, 
            "-vcodec", "libx264", "-crf", "28", # Siqish darajasi
            output_path
        ]
        process = await asyncio.create_subprocess_exec(
            *command,
            stdout=asyncio.subprocess.DEVNULL,
            stderr=asyncio.subprocess.DEVNULL
        )
        await process.communicate()
        
        if process.returncode == 0:
            if os.path.exists(input_path):
                os.remove(input_path) # Eski faylni o'chiramiz
        else:
            raise Exception("FFMPEG failed to execute clean compression")
    except Exception as e:
        print(f"FFMPEG Compressor Error (Skipping compress): {e}")
        try:
            shutil.move(input_path, output_path) # Fallback
        except:
            pass

@app.post("/birds/create-with-media")
async def create_bird_with_media(
    background_tasks: BackgroundTasks,
    category_id: int = Form(...),
    breed: str = Form(...),
    price: float = Form(...),
    description: str = Form(None),
    region_id: int = Form(...),
    user_id: str = Form(...),
    files: List[UploadFile] = File(...),
    document_url: str = Form(None),
    db: Session = Depends(get_db)
):
    new_bird = models.Bird(
        owner_id=user_id,
        category_id=category_id,
        region_id=region_id,
        species=breed,
        price=price,
        description=description,
        status="active"
    )
    db.add(new_bird)
    db.commit()
    db.refresh(new_bird)

    sort_ord = 0
    for file in files:
        unique_name = f"{random.randint(10000,99999)}_{file.filename}"
        path = os.path.join(UPLOAD_DIR, unique_name)
        
        with open(path, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)
            
        final_path = path

        is_video = file.content_type.startswith("video/")
        media_type = "video" if is_video else "image"

        if is_video:
            # Video siqishni fonga (Background) jo'natamiz
            compressed_path = os.path.join(UPLOAD_DIR, f"cd_{unique_name}")
            background_tasks.add_task(compress_video, path, compressed_path)
            final_path = compressed_path
            
        media = models.BirdMedia(
            bird_id=new_bird.id,
            media_type=media_type,
            file_url=f"/uploads/{os.path.basename(final_path)}",
            is_primary=(sort_ord == 0),
            sort_order=sort_ord
        )
        db.add(media)
        sort_ord += 1

    db.commit()
    
    notification_msg = f"🦅 Yangi E'lon Kiritildi!\nID: {new_bird.id}\nTur: {breed}\nNarx: {price} UZS\nTasdiqlashni kutmoqda."
    background_tasks.add_task(send_telegram_notification, ADMIN_CHAT_ID, notification_msg)

    return {"status": "success", "bird_id": new_bird.id}

@app.get("/birds")
async def get_birds(
    category_id: int = None, 
    is_verified: bool = None, 
    q: str = None, 
    limit: int = 20, 
    offset: int = 0, 
    db: Session = Depends(get_db)
):
    query = db.query(models.Bird).filter(models.Bird.status.in_(["active", "held"]))
    
    if category_id:
        query = query.filter_by(category_id=category_id)
    if is_verified:
        query = query.filter(models.Bird.health_badge == "verified_healthy")
    if q:
        query = query.filter(models.Bird.species.ilike(f"%{q}%") | models.Bird.description.ilike(f"%{q}%"))
        
    total_count = query.count()
    birds = query.order_by(models.Bird.created_at.desc()).offset(offset).limit(limit).all()
    results = []
    
    for bird in birds:
        media_urls = [{"type": m.media_type, "url": m.file_url} for m in bird.media]
        region_name = db.query(models.Region).filter_by(id=bird.region_id).first()
        owner = db.query(models.User).filter_by(id=bird.owner_id).first()
        
        results.append({
            "id": bird.id,
            "category_id": bird.category_id,
            "species": bird.species,
            "description": bird.description,
            "price": bird.price,
            "status": bird.status,
            "region_name": region_name.name_uz if region_name else "Noma'lum",
            "seller_name": owner.full_name if owner else "Foydalanuvchi",
            "seller_phone": owner.phone_number if owner and owner.show_phone else None,
            "seller_telegram": owner.telegram_id if owner and owner.allow_telegram else None,
            "allow_telegram": owner.allow_telegram if owner else False,
            "media": media_urls
        })
        
    return {
        "items": results,
        "total": total_count,
        "limit": limit,
        "offset": offset
    }

# --- ESCROW & PAYMENT MODULE ---
@app.post("/pay/process")
async def process_payment(background_tasks: BackgroundTasks, request: schemas.TransactionRequest, db: Session = Depends(get_db)):
    if request.amount <= 0: raise HTTPException(400, "Invalid amount")
    
    bird = db.query(models.Bird).filter_by(id=request.bird_id).first()
    if not bird: raise HTTPException(404, "Bird not found")
    if bird.status != "active": raise HTTPException(400, "Bird is not available")

    transaction = models.Transaction(
        user_id=request.buyer_id,
        bird_id=request.bird_id,
        amount=request.amount,
        payment_method=request.payment_method,
        status="held"
    )
    db.add(transaction)
    
    # Update bird status to held
    bird.status = "held"
    
    # Create Order record (Advanced Logistics Module Logic)
    order = models.Order(
        bird_id=bird.id,
        buyer_id=request.buyer_id,
        seller_id=bird.owner_id,
        total_amount=request.amount,
        escrow_status="payment_held" # Pull muzlatildi status
    )
    db.add(order)
    
    db.commit()
    db.refresh(transaction)
    
    msg = f"💰 ESCROW (Narx Muzlatildi):\nBuyurtma ID: {order.id}\nSumma: {request.amount} UZS\nXaridor ID: {request.buyer_id}"
    background_tasks.add_task(send_telegram_notification, ADMIN_CHAT_ID, msg)
    
    print(f"💰 ESCROW: Bird HELD, Order {order.id} CREATED, Money Muzlatildi (Tx: {transaction.id}).")
    return {"status": "success", "transaction_id": transaction.id, "order_id": order.id}

@app.post("/pay/refund/{transaction_id}")
async def process_refund(transaction_id: str, db: Session = Depends(get_db)):
    tx = db.query(models.Transaction).filter_by(id=transaction_id).first()
    if not tx or tx.status not in ["held", "disputed"]:
        raise HTTPException(400, "Transaction cannot be refunded")
        
    tx.status = "refunded"
    bird = db.query(models.Bird).filter_by(id=tx.bird_id).first()
    if bird:
        bird.status = "active"
        
    db.commit()
    return {"status": "success", "message": "Pul qaytarildi."}

# --- REAL-TIME CHAT (WEBSOCKETS) ---
class ConnectionManager:
    def __init__(self):
        self.active_connections: Dict[str, List[WebSocket]] = {}

    async def connect(self, websocket: WebSocket, room_id: str):
        await websocket.accept()
        if room_id not in self.active_connections:
            self.active_connections[room_id] = []
        self.active_connections[room_id].append(websocket)

    def disconnect(self, websocket: WebSocket, room_id: str):
        if room_id in self.active_connections:
            try:
                self.active_connections[room_id].remove(websocket)
            except ValueError:
                pass 

    async def send_personal_message(self, message: str, websocket: WebSocket):
        await websocket.send_text(message)

    async def broadcast(self, message: str, room_id: str):
        if room_id in self.active_connections:
            for connection in self.active_connections[room_id]:
                await connection.send_text(message)

manager = ConnectionManager()

@app.websocket("/ws/chat/{room_id}/{user_id}")
async def websocket_endpoint(websocket: WebSocket, room_id: str, user_id: str, db: Session = Depends(get_db)):
    await manager.connect(websocket, room_id)
    try:
        while True:
            data = await websocket.receive_text()
            # 1. Check for restricted words to throw warnings
            if ("karta" in data.lower()) or ("payme" in data.lower()):
                warning = json.dumps({"type": "system", "content": "⚠️ Ogohlantirish: To'lovni faqat ilova ichidagi (Sotib Olish) tugmasi orqali qiling!"})
                await websocket.send_text(warning)

            # 2. Save Message logic to DB 
            msg_record = models.Message(room_id=room_id, sender_id=user_id, content=data)
            db.add(msg_record)
            db.commit()
            
            # 3. Broadcast to others
            payload = json.dumps({"sender_id": user_id, "content": data, "type": "chat"})
            await manager.broadcast(payload, room_id)
            
    except WebSocketDisconnect:
        manager.disconnect(websocket, room_id)
        # await manager.broadcast(json.dumps({"type": "status", "content": f"User left."}), room_id)

# --- OFFICIAL SHOP MODULE ---
@app.get("/shop/items")
async def get_shop_items(db: Session = Depends(get_db)):
    items = db.query(models.ShopItem).filter_by(is_active=True).all()
    return items

@app.post("/shop/buy/{item_id}")
async def buy_shop_item(background_tasks: BackgroundTasks, item_id: str, quantity: int = Form(...), user_id: str = Form(...), db: Session = Depends(get_db)):
    item = db.query(models.ShopItem).filter_by(id=item_id).first()
    if not item or item.stock_quantity < quantity:
        raise HTTPException(400, "Maxsulot qolmagan yoki topilmadi")
        
    item.stock_quantity -= quantity
    total_amount = item.price * quantity
    
    order = models.ShopOrder(
        user_id=user_id,
        total_amount=total_amount,
        status="new"
    )
    db.add(order)
    db.commit()
    db.refresh(order)
    
    # Official Shop direct to rahbariyat card logic goes here via Webhook!
    notification_msg = f"🛒 Yangi Do'kon Buyurtmasi!\nID: {order.id}\nMaxsulot: {item.name}\nSoni: {quantity} ta\nJami: {total_amount} UZS"
    background_tasks.add_task(send_telegram_notification, ADMIN_CHAT_ID, notification_msg)

    return {"status": "success", "message": "Buyurtma qabul qilindi!", "order_id": order.id, "total": total_amount}

@app.get("/birds/{bird_id}/passport")
async def get_passport(bird_id: str, db: Session = Depends(get_db)):
    bird = db.query(models.Bird).filter_by(id=bird_id).first()
    if not bird: raise HTTPException(404, "Bird not found")
    
    filename = f"{bird_id}_passport.png"
    filepath = os.path.join(QR_DIR, filename)
    if not os.path.exists(filepath):
        qr = qrcode.QRCode(version=1, box_size=10, border=5)
        qr.add_data(f"https://qush-uyi.uz/birds/{bird_id}")
        qr.make(fit=True)
        img = qr.make_image(fill_color="black", back_color="white")
        img.save(filepath)
        
    # Return passport with simple history checking
    health_record = db.query(models.HealthRecord).filter_by(bird_id=bird_id).first()
    
    return {
        "bird_id": bird.id,
        "passport_url": f"/uploads/qrcodes/{filename}",
        "is_verified": bird.health_badge == "verified_healthy",
        "diagnosis": health_record.diagnosis if health_record else None
    }
