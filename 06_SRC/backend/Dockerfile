FROM python:3.10-slim

# Ffmpeg o'rnatamiz (Videolarni siqish uchun backendda kerak edi)
RUN apt-get update && \
    apt-get install -y ffmpeg && \
    rm -rf /var/lib/apt/lists/*

# Ishlash papkasini /app deb belgilaymiz
WORKDIR /app

# Kutubxonalar ro'yxatini nusxalaymiz
COPY requirements.txt .

# Kutubxonalarni o'rnatamiz
RUN pip install --no-cache-dir -r requirements.txt

# Kodlarni nusxalaymiz
COPY . .

# Railway uchun kerakli Portni ochamiz
EXPOSE 8000
EXPOSE 8080

# Eng asosiy yurgizish komandasi (Railway o'zi $PORT o'zgaruvchisini beradi)
CMD uvicorn main:app --host 0.0.0.0 --port ${PORT:-8000}
