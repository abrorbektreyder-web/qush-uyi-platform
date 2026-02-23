# Railway rasmiy FastAPI hujjatiga mos Dockerfile
# https://docs.railway.com/guides/fastapi
FROM python:3-alpine

# Ffmpeg o'rnatamiz (Video siqish uchun)
RUN apk add --no-cache ffmpeg

# Ishlash papkasini /app deb belgilaymiz
WORKDIR /app

# Kodlarni konteynerga nusxalaymiz
COPY . .

# Kutubxonalarni o'rnatamiz
RUN pip install --no-cache-dir -r requirements.txt

# Serverni port bilan ishga tushuramiz
CMD uvicorn main:app --host 0.0.0.0 --port ${PORT:-8000}
