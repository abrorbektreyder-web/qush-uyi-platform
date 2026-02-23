from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, declarative_base
import os

# Bitta qozonda qaynaydigan tizim - MVP uchun SQLite dan vaqtinchalik yoki to'g'ridan-to'g'ri PostgreSQL dan foydalanamiz
# Haqiqiy serverga o'tganda (Vercel/Heroku) DATABASE_URL postgresql:// ga o'zgaradi
DATABASE_URL = os.getenv("DATABASE_URL", "sqlite:///./qush_uyi.db")

connect_args = {"check_same_thread": False} if DATABASE_URL.startswith("sqlite") else {}

engine = create_engine(DATABASE_URL, connect_args=connect_args)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

Base = declarative_base()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
