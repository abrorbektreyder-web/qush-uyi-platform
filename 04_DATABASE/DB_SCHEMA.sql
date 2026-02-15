/*
  =============================================================
  PROJECT: QUSHLI PLATFORMASI (Uzbekistan Market Leader)
  DATABASE: PostgreSQL
  VERSION: 1.0 (MVP + SCALE)
  =============================================================
*/

-- 1. FOYDALANUVCHILAR VA XAVFSIZLIK (AUTH & USERS)
-- Maqsad: Telegram orqali tez kirish va ishonchli profillar.

CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    phone_number VARCHAR(15) UNIQUE,    -- +998... (SMS uchun)
    telegram_id BIGINT UNIQUE,          -- Telegram Auth (Asosiy kirish)
    telegram_chat_id BIGINT UNIQUE,     -- [NEW] Telegram Linker (Bot notifications)
    username VARCHAR(50) UNIQUE,        -- @user (Telegram username)
    full_name VARCHAR(100),
    region_id INT REFERENCES regions(id), -- User's location
    avatar_url TEXT,
    
    -- Tizimdagi o'rni
    role VARCHAR(20) DEFAULT 'user',    -- 'user', 'seller', 'vet', 'admin', 'driver'
    is_verified BOOLEAN DEFAULT FALSE,  -- Pasport ID orqali tasdiqlanganmi?

    -- [NEW] Privacy Settings
    show_phone BOOLEAN DEFAULT TRUE,
    allow_telegram BOOLEAN DEFAULT TRUE,
    
    -- Ishonch va Moliya
    rating DECIMAL(3, 2) DEFAULT 0.00,  -- 0.00 dan 5.00 gacha
    balance DECIMAL(15, 2) DEFAULT 0.00,-- Ichki hamyon (Escrow uchun)
    
    -- Tizim ma'lumotlari
    last_login TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- [NEW] TASK 5.2: TRANSACTIONS (ESCROW HOLD)
CREATE TABLE transactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id),  -- Transaction initiator (Buyer)
    bird_id UUID REFERENCES birds(id),
    amount DECIMAL(15, 2) NOT NULL,
    payment_method VARCHAR(20),         -- 'click', 'payme'
    status VARCHAR(20) DEFAULT 'pending', -- 'pending', 'held', 'released', 'refunded'
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Veterinarlar uchun maxsus profil (Litsenziya)
CREATE TABLE vet_profiles (
    user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    license_number VARCHAR(50) NOT NULL,
    clinic_name VARCHAR(100),
    location POINT,                     -- Xaritada ko'rsatish uchun
    experience_years INT,
    status VARCHAR(20) DEFAULT 'pending' -- 'pending', 'approved', 'rejected'
);

-- 2. LOKATSIYA VA KATEGORIYALAR (STATIC DATA)

    id SERIAL PRIMARY KEY,
    name_uz VARCHAR(50),                -- "Andijon viloyati"
    name_ru VARCHAR(50)
);

-- Seed Regions
INSERT INTO regions (name_uz, name_ru) VALUES
('Andijon viloyati', 'Андижанская область'),
('Buxoro viloyati', 'Бухарская область'),
('Farg''ona viloyati', 'Ферганская область'),
('Jizzax viloyati', 'Джизакская область'),
('Xorazm viloyati', 'Хорезмская область'),
('Namangan viloyati', 'Наманганская область'),
('Navoiy viloyati', 'Навоийская область'),
('Qashqadaryo viloyati', 'Кашкадарьинская область'),
('Samarqand viloyati', 'Самаркандская область'),
('Sirdaryo viloyati', 'Сырдарьинская область'),
('Surxondaryo viloyati', 'Сурхандарьинская область'),
('Toshkent viloyati', 'Ташкентская область'),
('Toshkent shahri', 'г. Ташкент'),
('Qoraqalpog''iston Respublikasi', 'Республика Каракалпакстан');

CREATE TABLE categories (
    id SERIAL PRIMARY KEY,
    name_uz VARCHAR(50),                -- "Kanareyka", "To'ti"
    slug VARCHAR(50) UNIQUE,            -- URL uchun
    icon_url TEXT
);

-- 3. QUSHLAR - ASOSIY OBYEKT (CORE)

CREATE TABLE birds (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    owner_id UUID REFERENCES users(id) ON DELETE CASCADE,
    category_id INT REFERENCES categories(id),
    region_id INT REFERENCES regions(id),
    
    -- Qush ma'lumotlari
    species VARCHAR(100),               -- Zoti / Parodasi
    age_months INT,
    gender VARCHAR(10),                 -- 'male', 'female', 'unknown'
    weight_grams INT,
    description TEXT,
    
    -- Savdo sozlamalari
    price DECIMAL(15, 2),
    currency VARCHAR(3) DEFAULT 'UZS',
    price_type VARCHAR(20) DEFAULT 'fixed', -- 'fixed', 'auction', 'negotiable'
    
    -- Logistika imkoniyatlari (JSONB - kelajakda o'zgarishi mumkin)
    -- Misol: {"pickup": true, "taxi": true, "seller_delivery": false}
    delivery_options JSONB DEFAULT '{}',
    
    -- Statuslar
    status VARCHAR(20) DEFAULT 'active', -- 'active', 'sold', 'archived', 'banned'
    health_badge VARCHAR(20) DEFAULT 'none', -- 'none', 'verified_healthy', 'risk'
    
    -- Statistika (Sortirovka uchun)
    views_count INT DEFAULT 0,
    likes_count INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Media fayllar (Rasm, Video, Ovoz)
CREATE TABLE bird_media (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    bird_id UUID REFERENCES birds(id) ON DELETE CASCADE,
    media_type VARCHAR(10),             -- 'image', 'video', 'audio' (sayrash)
    file_url TEXT NOT NULL,
    is_primary BOOLEAN DEFAULT FALSE,   -- Muqova rasm
    sort_order INT DEFAULT 0
);

-- 4. RAQAMLI PASPORT VA SALOMATLIK (TRUST)

CREATE TABLE health_records (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    bird_id UUID REFERENCES birds(id) ON DELETE CASCADE,
    vet_id UUID REFERENCES users(id),   -- Tekshirgan doktor
    
    diagnosis TEXT,                     -- Tashxis
    vaccine_info TEXT,                  -- Emlash ma'lumotlari
    attachment_url TEXT,                -- Rentgen yoki analiz rasmi
    
    qr_code_hash VARCHAR(255),          -- Pasportni skaner qilish uchun
    checkup_date TIMESTAMP DEFAULT NOW(),
    valid_until TIMESTAMP               -- Qachongacha amal qiladi
);

-- 5. SAVDO VA XAVFSIZ BITIM (ESCROW & ORDERS)
-- Maqsad: Pulni himoya qilish va firibgarlikni oldini olish.

CREATE TABLE orders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    bird_id UUID REFERENCES birds(id),
    buyer_id UUID REFERENCES users(id),
    seller_id UUID REFERENCES users(id),
    
    -- Moliya
    total_amount DECIMAL(15, 2),        -- Umumiy summa
    platform_fee DECIMAL(15, 2),        -- Bizning komissiya (foyda)
    escrow_status VARCHAR(30) DEFAULT 'created', 
    /* STATUSLAR:
       1. created          - Buyurtma ochildi
       2. payment_held     - Pul yechildi va platformada muzlatildi
       3. delivery_started - Qush yo'lga chiqdi (Pitak/Taksi)
       4. delivered        - Qush yetib bordi
       5. completed        - Xaridor tasdiqladi, pul sotuvchiga o'tdi
       6. disputed         - Muammo bor (Admin aralashadi)
       7. cancelled        - Bekor qilindi
    */
    
    payment_method VARCHAR(20),         -- 'payme', 'click', 'card', 'cash'
    delivery_method VARCHAR(20),        -- 'pickup', 'taxi'
    
    driver_info JSONB,                  -- Agar taksi bo'lsa: {"name": "Ali", "car": "Cobalt 80A777AA"}
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- 6. CHAT VA MULOQOT (REAL-TIME)

CREATE TABLE chat_rooms (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    bird_id UUID REFERENCES birds(id),  -- Qaysi qush bo'yicha savdo?
    buyer_id UUID REFERENCES users(id),
    seller_id UUID REFERENCES users(id),
    last_message_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE messages (
    id BIGSERIAL PRIMARY KEY,
    room_id UUID REFERENCES chat_rooms(id) ON DELETE CASCADE,
    sender_id UUID REFERENCES users(id),
    
    content TEXT,                       -- Xabar matni
    media_url TEXT,                     -- Rasm yuborilsa
    message_type VARCHAR(20) DEFAULT 'text', -- 'text', 'offer', 'location'
    
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT NOW()
);

-- 7. INDEXLAR (OPTIMIZATSIYA)
-- Ilova qotmasligi uchun eng muhim qism.

CREATE INDEX idx_birds_status ON birds(status);
CREATE INDEX idx_birds_category ON birds(category_id);
CREATE INDEX idx_birds_region ON birds(region_id);
CREATE INDEX idx_birds_price ON birds(price);
CREATE INDEX idx_users_telegram ON users(telegram_id);
CREATE INDEX idx_messages_room ON messages(room_id, created_at);