from fastapi import FastAPI, HTTPException, Form, File, UploadFile, Depends, BackgroundTasks, WebSocket, WebSocketDisconnect, Request
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
from dotenv import load_dotenv

load_dotenv()

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
TELEGRAM_CHANNEL_ID = os.getenv("TELEGRAM_CHANNEL_ID", "123456")

async def send_telegram_notification(chat_id: str, message: str):
    if TELEGRAM_BOT_TOKEN == "mock_token":
        print(f"[MOCK TELEGRAM Notification to {chat_id}]: {message}")
        return
    url = f"https://api.telegram.org/bot{TELEGRAM_BOT_TOKEN}/sendMessage"
    async with httpx.AsyncClient() as client:
        try:
            await client.post(url, json={"chat_id": chat_id, "text": message, "parse_mode": "HTML"})
        except Exception as e:
            print(f"Telegram API Error: {e}")

async def send_telegram_photo_local(chat_id: str, local_path: str, caption: str):
    if TELEGRAM_BOT_TOKEN == "mock_token":
        print(f"[MOCK TELEGRAM Photo to {chat_id}]: {caption}")
        return
    url = f"https://api.telegram.org/bot{TELEGRAM_BOT_TOKEN}/sendPhoto"
    
    if not os.path.exists(local_path):
        print(f"Photo not found: {local_path}")
        return
        
    async with httpx.AsyncClient() as client:
        try:
            with open(local_path, "rb") as f:
                await client.post(
                    url, 
                    data={"chat_id": chat_id, "caption": caption, "parse_mode": "HTML"},
                    files={"photo": f}
                )
        except Exception as e:
            print(f"Telegram sendPhoto Error: {e}")

@app.get("/api/telegram/set-webhook")
async def set_telegram_webhook(request: Request):
    """Admin endpoint to automatically set the Telegram Webhook to this server's URL."""
    host_url = str(request.base_url).rstrip("/")
    # Change to https if the request came as http due to proxy
    if host_url.startswith("http://"):
        host_url = host_url.replace("http://", "https://")
        
    webhook_url = f"{host_url}/webhook/telegram"
    
    url = f"https://api.telegram.org/bot{TELEGRAM_BOT_TOKEN}/setWebhook?url={webhook_url}"
    async with httpx.AsyncClient() as client:
        resp = await client.get(url)
        return resp.json()

@app.post("/webhook/telegram")
async def telegram_webhook(update: dict):
    """Handle incoming Telegram messages (like /start)"""
    if "message" in update and "text" in update["message"]:
        chat_id = update["message"]["chat"]["id"]
        text = update["message"]["text"]
        
        if text.startswith("/start"):
            welcome_text = (
                "👋 Assalomu alaykum! <b>Qush Uyi</b> platformasinkng rasmiy botiga xush kelibsiz.\n\n"
                "👇 Pastdagi tugmani bosib ilovaga kiring va qushlarni xarid qiling yoki soting!"
            )
            
            url = f"https://api.telegram.org/bot{TELEGRAM_BOT_TOKEN}/sendMessage"
            payload = {
                "chat_id": chat_id,
                "text": welcome_text,
                "parse_mode": "HTML",
                "reply_markup": {
                    "inline_keyboard": [
                        [
                            # Make sure you change this URL later if you deploy Flutter Web!
                            {"text": "📱 Ilovani ochish", "web_app": {"url": "https://qush-uyi-platform.vercel.app"}}
                        ]
                    ]
                }
            }
            async with httpx.AsyncClient() as client:
                await client.post(url, json=payload)
                
    return {"status": "ok"}


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
    phone: str = Form(None),
    seller_name: str = Form(None),
    telegram_username: str = Form(None),
    files: List[UploadFile] = File(...),
    document_url: str = Form(None),
    db: Session = Depends(get_db)
):
    # Clean phone number
    clean_phone = phone.strip() if phone else None
    if clean_phone and not clean_phone.startswith('+'):
        clean_phone = f"+998{clean_phone}"
    
    # Auto-create user if not exists
    actual_user_id = user_id
    existing_user = db.query(models.User).filter_by(id=user_id).first()
    
    if not existing_user and clean_phone:
        # Try to find by phone
        existing_user = db.query(models.User).filter_by(phone_number=clean_phone).first()
        if existing_user:
            actual_user_id = existing_user.id
    
    if existing_user:
        # Update existing user's info if provided
        if seller_name and seller_name.strip():
            existing_user.full_name = seller_name.strip()
        if clean_phone:
            existing_user.phone_number = clean_phone
        if telegram_username and telegram_username.strip():
            clean_tg = telegram_username.strip().lstrip('@')
            existing_user.username = clean_tg
        existing_user.region_id = region_id
        existing_user.show_phone = True
        existing_user.allow_telegram = True
        db.commit()
    else:
        # Create new user record with real data
        clean_tg = telegram_username.strip().lstrip('@') if telegram_username else None
        new_user = models.User(
            phone_number=clean_phone or f"+998{random.randint(900000000, 999999999)}",
            full_name=seller_name.strip() if seller_name else "Sotuvchi",
            username=clean_tg,
            region_id=region_id,
            role="seller",
            show_phone=True,
            allow_telegram=True,
        )
        db.add(new_user)
        db.commit()
        db.refresh(new_user)
        actual_user_id = new_user.id

    new_bird = models.Bird(
        owner_id=actual_user_id,
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

    return {"status": "success", "bird_id": new_bird.id, "user_id": actual_user_id}

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
        
        # Build seller contact info
        seller_phone = None
        seller_telegram = None
        seller_name = "Foydalanuvchi"
        allow_tg = False
        
        if owner:
            seller_name = owner.full_name or "Foydalanuvchi"
            allow_tg = owner.allow_telegram if owner.allow_telegram is not None else True
            
            # Phone: show if user allows
            if owner.show_phone and owner.phone_number:
                seller_phone = owner.phone_number
            
            # Telegram: use username, telegram_id, or phone for t.me link
            if allow_tg:
                if owner.username:
                    seller_telegram = owner.username
                elif owner.telegram_id:
                    seller_telegram = str(owner.telegram_id)
                elif owner.phone_number:
                    # Fallback: use phone number for t.me/+998... links
                    seller_telegram = owner.phone_number
        
        results.append({
            "id": bird.id,
            "category_id": bird.category_id,
            "species": bird.species,
            "description": bird.description,
            "price": bird.price,
            "status": bird.status,
            "region_name": region_name.name_uz if region_name else "Noma'lum",
            "seller_name": seller_name,
            "seller_phone": seller_phone,
            "seller_telegram": seller_telegram,
            "allow_telegram": allow_tg,
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
    if bird.status != "active": raise HTTPException(400, "Bu qush allaqachon band qilingan!")

    # Auto-create buyer if not exists
    actual_buyer_id = request.buyer_id
    buyer = db.query(models.User).filter_by(id=request.buyer_id).first()
    if not buyer:
        # Create a new buyer user
        buyer = models.User(
            phone_number=f"+998{random.randint(900000000, 999999999)}",
            full_name="Xaridor",
            role="user",
            show_phone=True,
            allow_telegram=True,
        )
        db.add(buyer)
        db.commit()
        db.refresh(buyer)
        actual_buyer_id = buyer.id

    transaction = models.Transaction(
        user_id=actual_buyer_id,
        bird_id=request.bird_id,
        amount=request.amount,
        payment_method=request.payment_method,
        status="held"
    )
    db.add(transaction)
    
    # Update bird status to held
    bird.status = "held"
    
    # Create Order record
    order = models.Order(
        bird_id=bird.id,
        buyer_id=actual_buyer_id,
        seller_id=bird.owner_id,
        total_amount=request.amount,
        escrow_status="payment_held"
    )
    db.add(order)
    
    db.commit()
    db.refresh(transaction)
    
    msg = f"💰 ESCROW (Narx Muzlatildi):\nBuyurtma ID: {order.id}\nSumma: {request.amount} UZS\nXaridor ID: {actual_buyer_id}"
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

@app.get("/user/orders/{user_id}")
async def get_user_orders(user_id: str, db: Session = Depends(get_db)):
    orders = db.query(models.Order).filter_by(buyer_id=user_id).order_by(models.Order.created_at.desc()).all()
    results = []
    for order in orders:
        bird = db.query(models.Bird).filter_by(id=order.bird_id).first()
        media_urls = [{"type": m.media_type, "url": m.file_url} for m in bird.media] if bird else []
        results.append({
            "order_id": order.id,
            "bird_id": order.bird_id,
            "species": bird.species if bird else "Noma'lum",
            "price": order.total_amount,
            "status": order.escrow_status,
            "created_at": str(order.created_at),
            "media": media_urls
        })
    return {"orders": results}

@app.post("/pay/release/{order_id}")
async def release_fund(order_id: str, background_tasks: BackgroundTasks, db: Session = Depends(get_db)):
    order = db.query(models.Order).filter_by(id=order_id).first()
    if not order or order.escrow_status != "payment_held":
        raise HTTPException(400, "Order is not in held status")
        
    order.escrow_status = "completed"
    
    tx = db.query(models.Transaction).filter_by(bird_id=order.bird_id, status="held").first()
    if tx:
        tx.status = "released"
        
    bird = db.query(models.Bird).filter_by(id=order.bird_id).first()
    if bird:
        bird.status = "sold"
        
    db.commit()
    
    msg = f"✅ ESCROW (Sotuvchiga o'tkazildi):\nBuyurtma ID: {order.id}\nXaridor tovarini oldi. Summa ({order.total_amount} UZS) sotuvchiga hisobiga o'tkazish tavsiya qilinadi."
    background_tasks.add_task(send_telegram_notification, ADMIN_CHAT_ID, msg)
    
    return {"status": "success", "message": "Pul sotuvchiga o'tkazilishga ruhsat berildi."}

@app.post("/pay/dispute/{order_id}")
async def dispute_order(order_id: str, request: schemas.DisputeRequest, background_tasks: BackgroundTasks, db: Session = Depends(get_db)):
    order = db.query(models.Order).filter_by(id=order_id).first()
    if not order or order.escrow_status != "payment_held":
        raise HTTPException(400, "Order is not in held status")
        
    order.escrow_status = "disputed"
    
    tx = db.query(models.Transaction).filter_by(bird_id=order.bird_id, status="held").first()
    if tx:
        tx.status = "disputed"
        
    db.commit()
    
    msg = f"🚨 NIZO (DISPUTE) OCHILDI:\nBuyurtma ID: {order.id}\nSabab: {request.reason}\nAdmin aralashuvi kerak!"
    background_tasks.add_task(send_telegram_notification, ADMIN_CHAT_ID, msg)
    
    return {"status": "success", "message": "Nizo ochildi va adminga uzatildi."}

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

# --- ADMIN PANEL TELEGRAM INTEGRATION ---
@app.post("/admin/birds/{bird_id}/verify")
async def verify_and_publish_bird(bird_id: str, background_tasks: BackgroundTasks, db: Session = Depends(get_db)):
    bird = db.query(models.Bird).filter_by(id=bird_id).first()
    if not bird:
        raise HTTPException(404, "Qush topilmadi")
        
    bird.health_badge = "verified_healthy"
    db.commit()

    # Tasdiqlangach Dildan post yasab Rasmiy Kanalga uzatamiz!
    location = db.query(models.Region).filter_by(id=bird.region_id).first()
    reg_name = location.name_uz if location else "Noma'lum qism"
    
    formatted_price = f"{int(bird.price):,} UZS".replace(",", " ") if bird.price else "Kelishiladi"
    
    caption = (
        f"✅ <b>YANGI TASDIQLANGAN QUsh</b>\n\n"
        f"🐦 <b>Tur:</b> {bird.species}\n"
        f"💰 <b>Narx:</b> {formatted_price}\n"
        f"📍 <b>Hudud:</b> {reg_name}\n"
        f"📝 <b>Tavsif:</b> {bird.description or 'Yozilmagan'}\n\n"
        f"🛡 <b>Qush Uyi Platformasi tomonidan ishonchli deb topildi!</b>\n\n"
        f"👉 <b>Xarid qilish uchun ilovaga kiring:</b> \n"
        f"🌐 https://qush-uyi.uz/birds/{bird.id}"
    )

    if bird.media and len(bird.media) > 0:
        # Assuming the first media is image. Media URL is like "/uploads/..." 
        # So we strip the leading "/" to get the local filesystem path relative to CWD.
        photo_local_path = bird.media[0].file_url.lstrip("/") 
        background_tasks.add_task(send_telegram_photo_local, TELEGRAM_CHANNEL_ID, photo_local_path, caption)
    else:
        # Agar rasm bo'lmasa oddiy text yuboramiz.
        background_tasks.add_task(send_telegram_notification, TELEGRAM_CHANNEL_ID, caption)

    return {"status": "success", "message": "Qush tasdiqlandi va Kanalga yuborildi!"}

