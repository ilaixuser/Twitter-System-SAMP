# 📱🐦 Niranam Twitter System (SA-MP CEF)

---

## 🇹🇭 ภาษาไทย (Thai Version)

### 📌 บทนำ

**Niranam Twitter System** เป็นระบบสมาร์ทโฟนและโซเชียลมีเดียจำลอง (Twitter/X) สำหรับเซิร์ฟเวอร์ **San Andreas Multiplayer (SA-MP)**
พัฒนาโดย **ilaixDev (Shop Niranam SAMP)**

ระบบนี้ถูกออกแบบมาให้:

* สมจริง (Realistic)
* ลื่นไหล (Smooth UI/UX)
* รองรับผู้เล่นจำนวนมาก (Scalable)

ทำงานผ่าน **CEF (Chromium Embedded Framework)** และจัดเก็บข้อมูลด้วย **MySQL**

---

### ⚙️ ระบบทำงานอย่างไร?

ระบบใช้โครงสร้างแบบ **Client-Server Architecture** ร่วมกับ Web Technology

#### 🔹 Backend (PAWN & MySQL)

* จัดการข้อมูล: ทวีต, โปรไฟล์, ไลก์, รีทวีต
* ตรวจสอบสิทธิ์ผู้เล่น
* ใช้ไฟล์: `niranam_twitter.inc`

#### 🔹 Frontend (HTML/CSS/JS)

* แสดง UI ผ่าน CEF
* ใช้ไฟล์: `index.html`

#### 🔹 การสื่อสาร (Bridge System)

* `cef_emit_event` → Server ➜ UI
* `cef_subscribe` → UI ➜ Server

📌 ตัวอย่าง:

> ผู้เล่นกด "ทวีต" → UI ส่งข้อมูล → Server บันทึก → Broadcast ให้ผู้เล่นทั้งหมด

---

### 🛠️ เทคโนโลยีที่ใช้ (Tech Stack)

**Backend**

* PAWN (YSI Hooks)
* MySQL Plugin (R41+)

**Frontend**

* HTML5
* CSS3
* Vanilla JavaScript

**Libraries**

* Tailwind CSS
* FontAwesome 6
* Google Fonts (Kanit)

**Integration**

* SA-MP CEF Plugin

**Audio**

* Web Audio API

---

### 📱 หน้าตาของระบบ (User Interface)

ดีไซน์สไตล์ **สมาร์ทโฟนยุคใหม่ (iPhone-like UI)** + Dark Mode

#### 🔒 Lock Screen

* เวลา / วันที่แบบเรียลไทม์
* Swipe to Unlock
* แอนิเมชันวอลเปเปอร์

#### 📡 Status Bar & Dynamic Island

* สัญญาณ / Wi-Fi / เวลา
* แบตเตอรี่แบบจำลอง

#### 🔔 Notification System

* Toast แจ้งเตือนลอยขึ้นมุมซ้ายบน
* แจ้งเตือนทวีตใหม่แบบเรียลไทม์

#### 🐦 Twitter (X App)

* ฟีดเลื่อนลื่น
* รองรับรูปภาพ
* แสดงชื่อ + @username + เวลาโพสต์
* Modal สำหรับโพสต์ (มีตัวนับ 280 ตัวอักษร)

#### 👤 Profile & Settings

* แก้ชื่อ / Avatar / Bio
* ดูจำนวนผู้ติดตาม

#### 🖼️ Image Viewer

* คลิกรูป → ขยายเต็มจอ

---

### ⌨️ คำสั่งการใช้งาน

* `/p` → เปิด/ปิดโทรศัพท์
* กด `P` (หรือ `ย`) → เปิด/ปิดแบบรวดเร็ว
* กด `Esc` → ปิด UI

🖱️ Mouse:

* เปิดโทรศัพท์ → ใช้งานเมาส์กับ UI
* ปิดโทรศัพท์ → กลับไปควบคุมกล้องเกม

---

### 🎥 วิดีโอสาธิต

ดูการทำงานจริงได้ที่นี่:

https://youtu.be/UbBt2tMXuNs?si=Ls3DioYk4_7OJorc

---

---

## 🇬🇧 English Version

### 📌 Introduction

**Niranam Twitter System** is a simulated smartphone and social media (Twitter/X) system for **San Andreas Multiplayer (SA-MP)** servers.
Developed by **ilaixDev (Shop Niranam SAMP)**

Designed to be:

* Realistic
* Smooth
* Scalable

Runs via **CEF (Chromium Embedded Framework)** and stores data using **MySQL**

---

### ⚙️ How It Works

Built on a **Client-Server Architecture** combined with Web Technology

#### 🔹 Backend (PAWN & MySQL)

* Handles tweets, profiles, likes, retweets
* Player authentication
* File: `niranam_twitter.inc`

#### 🔹 Frontend (HTML/CSS/JS)

* UI rendered via CEF
* File: `index.html`

#### 🔹 Bridge Communication

* `cef_emit_event` → Server ➜ UI
* `cef_subscribe` → UI ➜ Server

📌 Example:

> Player posts → UI sends data → Server saves → Broadcast to all players

---

### 🛠️ Tech Stack

**Backend**

* PAWN (YSI Hooks)
* MySQL Plugin

**Frontend**

* HTML5
* CSS3
* Vanilla JavaScript

**Libraries**

* Tailwind CSS
* FontAwesome 6
* Google Fonts (Kanit)

**Integration**

* SA-MP CEF Plugin

**Audio**

* Web Audio API

---

### 📱 User Interface

Modern **iPhone-style UI** with Dark Mode

#### 🔒 Lock Screen

* Real-time clock/date
* Swipe to unlock
* Animated wallpaper

#### 📡 Status Bar & Dynamic Island

* Signal / Wi-Fi / Time
* Simulated battery

#### 🔔 Notifications

* Floating toast alerts (top-left)
* Real-time tweet updates

#### 🐦 Twitter (X App)

* Smooth scrolling feed
* Image support
* Display names + @handles + time ago
* Tweet modal with 280-character counter

#### 👤 Profile & Settings

* Edit nickname / avatar / bio
* View followers

#### 🖼️ Image Viewer

* Click images → fullscreen view

---

### ⌨️ Commands & Controls

* `/p` → Toggle phone
* `P` key (or Thai `ย`) → Quick toggle
* `Esc` → Close phone

🖱️ Mouse:

* Phone ON → UI control
* Phone OFF → Game camera control

---

### 🎥 Video Showcase

Watch it in action:

https://youtu.be/UbBt2tMXuNs?si=Ls3DioYk4_7OJorc

---
