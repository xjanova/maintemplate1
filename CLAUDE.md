# 🚀 XCLAUDE FRAMEWORK - คู่มือสำหรับ Claude

> **"Just tell Claude what you want"**
> แค่บอก Claude ว่าต้องการอะไร - ที่เหลือ Claude จัดการเอง

```
╔═══════════════════════════════════════════════════════════════════════════╗
║   __  __    ___ _                 _        ___                            ║
║   \ \/ /   / __| |__ _ _  _ ___ _| |___   | __| _ __ _ _ __  ___          ║
║    >  <   | (__| / _` | || / _` | / -_)  | _| '_/ _` | '  \/ -_)         ║
║   /_/\_\   \___|_\__,_|\_,_\__,_|_\___|  |_||_| \__,_|_|_|_\___|         ║
║                                                                           ║
║   Version 1.0.0 | AI-Powered Development Framework                       ║
╚═══════════════════════════════════════════════════════════════════════════╝
```

---

## 📋 สารบัญ

1. [ภาพรวม Framework](#ภาพรวม-framework)
2. [โครงสร้างโปรเจค](#โครงสร้างโปรเจค)
3. [วิธีทำงานของ Claude](#วิธีทำงานของ-claude)
4. [คำสั่งที่ใช้บ่อย](#คำสั่งที่ใช้บ่อย)
5. [การ Deploy อัตโนมัติ](#การ-deploy-อัตโนมัติ)
6. [การทดสอบและตรวจสอบ](#การทดสอบและตรวจสอบ)
7. [การแจ้งเตือน](#การแจ้งเตือน)
8. [การแก้ไขปัญหา](#การแก้ไขปัญหา)

---

## 🎯 ภาพรวม Framework

### สิ่งที่ Claude ทำได้อัตโนมัติ

| ความสามารถ | รายละเอียด |
|------------|-----------|
| 🖥️ **เขียนโค้ด** | พัฒนา PHP, HTML, CSS, JavaScript ตามที่สั่ง |
| 🧪 **ทดสอบ** | รันเทสต์อัตโนมัติและตรวจสอบผลลัพธ์ |
| 🚀 **Deploy** | Commit, Push, และ Deploy ขึ้น Server |
| 👁️ **ตรวจหน้าเว็บ** | เปิด URL จริงและวิเคราะห์ผลลัพธ์ |
| 🔧 **แก้ไขอัตโนมัติ** | หากมี error จะพยายามแก้ไขจนสำเร็จ |
| 📱 **แจ้งเตือน** | ส่งแจ้งเตือนผ่าน Line OA เมื่อมีปัญหา |
| 🔒 **Security Scan** | ตรวจช่องโหว่ความปลอดภัย |
| ⚡ **Performance** | วัดและปรับปรุงความเร็ว |

### Tech Stack

- **Backend:** PHP 8.2+ (Modern PHP)
- **CSS Framework:** Tailwind CSS 3.x
- **JavaScript:** Alpine.js 3.x + HTMX
- **Build Tool:** Vite
- **Web Server:** Nginx / Apache

---

## 📁 โครงสร้างโปรเจค

```
xclaude-project/
├── .xclaude/                    # ⚙️ Core Framework Config
│   ├── config.yml               # การตั้งค่าหลัก
│   ├── actions/                 # GitHub Actions templates
│   ├── templates/               # โค้ด templates
│   └── modules/                 # โมดูลเสริม
│
├── .github/workflows/           # 🔄 GitHub Actions
│   ├── deploy.yml               # Auto deploy
│   ├── release.yml              # Auto release
│   ├── test.yml                 # Auto test
│   └── security.yml             # Security scan
│
├── public/                      # 🌐 Web Root (Document Root)
│   ├── index.php                # Entry point
│   ├── css/                     # Compiled CSS
│   ├── js/                      # Compiled JS
│   └── assets/                  # รูปภาพ, fonts
│
├── src/                         # 💻 Source Code
│   ├── pages/                   # หน้าเว็บต่างๆ
│   ├── components/              # PHP Components
│   ├── layouts/                 # Layout templates
│   └── api/                     # API endpoints
│
├── config/                      # ⚙️ App Configuration
│   ├── app.php                  # App settings
│   ├── database.php             # Database settings
│   └── routes.php               # URL routes
│
├── storage/                     # 📦 Storage
│   ├── logs/                    # Log files
│   ├── cache/                   # Cache files
│   └── uploads/                 # User uploads
│
├── tests/                       # 🧪 Tests
│   ├── unit/                    # Unit tests
│   └── e2e/                     # End-to-end tests
│
├── scripts/                     # 🛠️ Scripts
│   ├── deploy.sh                # Smart deploy script
│   ├── install.sh               # Installation wizard
│   └── notify.sh                # Notification script
│
├── docs/                        # 📚 Documentation
│   ├── DEVELOPMENT.md           # Development guide
│   ├── TASKS.md                 # Task tracker
│   └── API.md                   # API documentation
│
├── .env                         # 🔐 Environment (ไม่ commit)
├── .env.example                 # 📝 Environment template
├── CLAUDE.md                    # 🤖 ไฟล์นี้!
└── README.md                    # 📖 Project README
```

### ไฟล์สำคัญสำหรับ Claude

| ไฟล์ | หน้าที่ | อ่านเมื่อไหร่ |
|------|--------|-------------|
| `CLAUDE.md` | คู่มือหลัก | เริ่มต้นทุกครั้ง |
| `.xclaude/config.yml` | การตั้งค่า framework | ต้องการรู้ config |
| `docs/TASKS.md` | งานที่ต้องทำ | รับงานใหม่ |
| `.env` | ค่า secrets | ต้องการ URL, Keys |
| `.deploy-feedback.json` | ผลการ deploy | หลัง deploy |

---

## 🤖 วิธีทำงานของ Claude

### ขั้นตอนมาตรฐาน

```
┌─────────────────────────────────────────────────────────────┐
│  👤 User: "เพิ่มหน้า login"                                   │
└─────────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│  📖 STEP 1: อ่านและเข้าใจ                                     │
│  - อ่าน CLAUDE.md (ไฟล์นี้)                                   │
│  - อ่าน .xclaude/config.yml                                 │
│  - อ่าน docs/TASKS.md                                       │
│  - สำรวจโค้ดที่มีอยู่                                          │
└─────────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│  📝 STEP 2: วางแผน                                           │
│  - ใช้ TodoWrite เขียนแผนงาน                                  │
│  - แจ้ง user ว่าจะทำอะไรบ้าง                                   │
└─────────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│  💻 STEP 3: พัฒนา                                            │
│  - เขียนโค้ด PHP + HTML + CSS (Tailwind)                    │
│  - ใช้ Alpine.js สำหรับ interactivity                        │
│  - ใช้ HTMX สำหรับ AJAX                                      │
└─────────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│  🧪 STEP 4: ทดสอบในเครื่อง                                    │
│  - ตรวจ syntax errors                                       │
│  - รัน unit tests ถ้ามี                                      │
└─────────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│  📤 STEP 5: Commit & Push                                   │
│  - git add .                                                │
│  - git commit -m "feat: เพิ่มหน้า login"                      │
│  - git push                                                 │
└─────────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│  🚀 STEP 6: Deploy อัตโนมัติ                                  │
│  - GitHub Actions ทำงาน                                     │
│  - deploy.sh รันบน server                                   │
│  - สร้าง .deploy-feedback.json                              │
└─────────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│  👁️ STEP 7: ตรวจสอบผลลัพธ์                                   │
│  - เปิด URL จริงด้วย WebFetch                                │
│  - วิเคราะห์หน้าเว็บ                                          │
│  - ตรวจว่าทำงานถูกต้องไหม                                     │
└─────────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│  ✅ STEP 8: รายงานผล                                         │
│  หาก สำเร็จ → แจ้ง user พร้อม URL                            │
│  หาก ล้มเหลว → แก้ไขอัตโนมัติ (กลับไป STEP 3)                  │
│  หาก ล้มเหลวเกิน 3 ครั้ง → แจ้ง Line OA + สร้าง Issue          │
└─────────────────────────────────────────────────────────────┘
```

### วิธีตรวจสอบหน้าเว็บ

Claude จะใช้ `WebFetch` เพื่อเปิดหน้าเว็บจริงและวิเคราะห์:

```
1. อ่าน SITE_URL จาก .env หรือ .xclaude/config.yml
2. ใช้ WebFetch tool เปิด URL
3. วิเคราะห์ HTML ที่ได้
4. ตรวจว่า:
   - หน้าโหลดสำเร็จ (ไม่มี error)
   - มี element ที่ต้องการ
   - ไม่มี broken links
   - CSS/JS โหลดถูกต้อง
```

---

## ⌨️ คำสั่งที่ใช้บ่อย

### Slash Commands สำหรับ Claude

| คำสั่ง | ใช้งาน |
|--------|--------|
| `/new-feature ชื่อ` | เริ่มพัฒนาฟีเจอร์ใหม่ |
| `/fix-bug รายละเอียด` | แก้ไขบั๊ก |
| `/deploy` | Deploy ขึ้น production |
| `/deploy-status` | เช็คสถานะ deploy |
| `/verify-site` | เปิดเว็บตรวจสอบ |
| `/security-scan` | สแกนช่องโหว่ |
| `/release` | สร้าง release ใหม่ |

### Commit Message Convention

```bash
# ฟีเจอร์ใหม่ → Version Minor (1.x.0)
git commit -m "feat: เพิ่มหน้า login"

# แก้บั๊ก → Version Patch (1.0.x)
git commit -m "fix: แก้ปัญหาหน้าไม่โหลด"

# Breaking Change → Version Major (x.0.0)
git commit -m "feat!: เปลี่ยนโครงสร้าง API"

# อัปเดทเอกสาร → ไม่เปลี่ยน version
git commit -m "docs: อัปเดทคู่มือ"
```

---

## 🚀 การ Deploy อัตโนมัติ

### Flow การ Deploy

```
Merge to main
      ↓
GitHub Actions: release.yml
      ↓
สร้าง Version Tag (v1.2.3)
      ↓
GitHub Actions: deploy.yml
      ↓
SSH เข้า Server → รัน deploy.sh
      ↓
deploy.sh ทำงาน:
  1. git pull
  2. composer install
  3. npm install && npm run build
  4. Clear cache
  5. Health check
      ↓
สร้าง .deploy-feedback.json
      ↓
แจ้ง Line OA (ถ้าตั้งค่าไว้)
```

### อ่านผล Deploy

หลัง deploy ให้อ่าน `.deploy-feedback.json`:

```json
{
  "status": "success",
  "version": "v1.2.3",
  "timestamp": "2024-01-15T10:30:00Z",
  "project_type": "php",
  "steps_completed": [
    "git_pull",
    "composer_install",
    "npm_build",
    "cache_clear",
    "health_check"
  ],
  "site_url": "https://example.com",
  "urls_to_check": ["/", "/login", "/api/health"],
  "errors": [],
  "warnings": []
}
```

### หาก Deploy ล้มเหลว

1. อ่าน `errors` ใน `.deploy-feedback.json`
2. อ่าน `suggestions` สำหรับวิธีแก้
3. แก้ไขโค้ด
4. Commit & Push ใหม่
5. หากยังล้มเหลว → ระบบจะแจ้ง Line OA

---

## 🧪 การทดสอบและตรวจสอบ

### 1. ตรวจสอบหน้าเว็บ (Visual Verification)

```
Claude ทำ:
1. WebFetch(SITE_URL + "/path")
2. วิเคราะห์ HTML response
3. ตรวจ:
   - Status code = 200
   - มี <title> ที่ถูกต้อง
   - มี content หลักๆ
   - ไม่มี PHP errors
   - ไม่มี JavaScript errors
```

### 2. Security Scan

GitHub Action `security.yml` จะ:
- ตรวจ SQL Injection
- ตรวจ XSS
- ตรวจ CSRF
- ตรวจ dependency vulnerabilities

### 3. Performance Check

- วัด page load time
- ตรวจ Lighthouse score
- แนะนำการปรับปรุง

---

## 📱 LINE OA Integration

### ความสามารถ

| ฟีเจอร์ | รายละเอียด |
|---------|------------|
| 💬 **สนทนากับ Claude** | ส่งข้อความใน LINE แล้วได้คำตอบจาก Claude AI |
| 🔔 **แจ้งเตือน Deploy** | รับแจ้งเตือนเมื่อ deploy สำเร็จหรือล้มเหลว |
| 📊 **สถานะโปรเจค** | ถามสถานะการทำงานของระบบ |

### การแจ้งเตือนอัตโนมัติ

| เหตุการณ์ | ข้อความ |
|----------|---------|
| Deploy สำเร็จ | ✅ Deploy สำเร็จ! |
| Deploy ล้มเหลว | ❌ Deploy ล้มเหลว! |

### ตั้งค่า LINE OA + Claude Bot

**ขั้นตอนที่ 1: สร้าง LINE OA**
1. ไปที่ [LINE Developers Console](https://developers.line.biz/console/)
2. สร้าง Messaging API Channel
3. คัดลอก Channel ID, Channel Secret, Channel Access Token

**ขั้นตอนที่ 2: ตั้งค่า Webhook**
1. ใน LINE Developers Console ไปที่ Messaging API
2. ตั้ง Webhook URL: `https://your-domain.com/src/api/line-webhook.php`
3. เปิด "Use webhook"

**ขั้นตอนที่ 3: หา User ID**
1. Add Friend กับ LINE OA ของคุณ
2. ส่งข้อความทดสอบ
3. ดู Webhook event ที่ส่งมา (userId ใน source object)

**ขั้นตอนที่ 4: ตั้งค่า Claude API**
1. ไปที่ [Anthropic Console](https://console.anthropic.com/)
2. สร้าง API Key
3. เก็บไว้ใน GitHub Secrets

**GitHub Secrets ที่ต้องตั้งค่า:**
```
LINE_CHANNEL_ACCESS_TOKEN=your_channel_access_token
LINE_CHANNEL_SECRET=your_channel_secret
LINE_USER_ID=Uxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
CLAUDE_API_KEY=sk-ant-xxxxxxxxxxxxx
```

**ใน `.env` บน Server:**
```env
LINE_CHANNEL_ID=your_channel_id
LINE_CHANNEL_SECRET=your_channel_secret
LINE_CHANNEL_ACCESS_TOKEN=your_channel_access_token
LINE_USER_ID=Uxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
CLAUDE_API_KEY=sk-ant-xxxxxxxxxxxxx
```

### วิธีใช้งาน LINE Bot

**โหมดแจ้งเตือน (ไม่ต้องใช้ Claude API):**
- พิมพ์ `status` หรือ `สถานะ` - ดูสถานะ deploy ล่าสุด
- พิมพ์ `url` - ดู URL ของเว็บไซต์
- พิมพ์ `help` - ดูคำสั่งที่ใช้ได้
- รับแจ้งเตือนอัตโนมัติเมื่อ deploy สำเร็จ/ล้มเหลว

**โหมด AI (ต้องตั้งค่า Claude API):**
- ส่งข้อความถามอะไรก็ได้ - Claude จะตอบกลับ
- ถามเรื่องโปรเจค - เช่น "สถานะ deploy ล่าสุดเป็นอย่างไร?"
- ขอความช่วยเหลือ - เช่น "ช่วยอธิบายวิธีใช้ feature X"

> **หมายเหตุ:** `CLAUDE_API_KEY` เป็น optional - ถ้าไม่ใส่ Bot จะทำงานในโหมดแจ้งเตือนอย่างเดียว

---

## 🔧 การแก้ไขปัญหา

### ปัญหาที่พบบ่อยและวิธีแก้

| ปัญหา | สาเหตุ | วิธีแก้ |
|-------|--------|--------|
| Deploy ไม่ทำงาน | SSH key ไม่ถูกต้อง | ตรวจ `SSH_PRIVATE_KEY` secret |
| หน้าเว็บ 500 error | PHP syntax error | ตรวจ error log, แก้โค้ด |
| CSS ไม่โหลด | Build ไม่สำเร็จ | รัน `npm run build` ใหม่ |
| Database error | ตั้งค่าไม่ถูก | ตรวจ `.env` database settings |

### วิธีที่ Claude แก้ปัญหาอัตโนมัติ

```
1. ตรวจพบ error
      ↓
2. อ่าน error message
      ↓
3. วิเคราะห์สาเหตุ
      ↓
4. แก้ไขโค้ด
      ↓
5. Commit & Push ใหม่
      ↓
6. รอ deploy ใหม่
      ↓
7. ตรวจสอบอีกครั้ง
      ↓
8. หากยังไม่สำเร็จ (เกิน 3 ครั้ง)
      ↓
9. แจ้ง Line OA + สร้าง GitHub Issue
```

---

## 🎓 สำหรับ Claude: Quick Reference

### เมื่อได้รับงานใหม่

```
1. อ่าน CLAUDE.md (ไฟล์นี้)
2. อ่าน .xclaude/config.yml
3. อ่าน docs/TASKS.md
4. สำรวจโค้ดที่เกี่ยวข้อง
5. วางแผนด้วย TodoWrite
6. เริ่มพัฒนา
```

### เมื่อต้อง Deploy

```
1. git add -A
2. git commit -m "type: description"
3. git push origin branch-name
4. รอ GitHub Actions
5. อ่าน .deploy-feedback.json
6. WebFetch ตรวจหน้าเว็บ
```

### เมื่อพบ Error

```
1. อ่าน error message ให้ละเอียด
2. หาสาเหตุในโค้ด
3. แก้ไข
4. ทดสอบ
5. Deploy ใหม่
6. หากเกิน 3 ครั้ง → แจ้ง user + Line OA
```

### Environment Variables ที่สำคัญ

| Variable | ใช้งาน |
|----------|--------|
| `SITE_URL` | URL หลักของเว็บไซต์ |
| `LINE_CHANNEL_ACCESS_TOKEN` | Token สำหรับ LINE OA |
| `LINE_CHANNEL_SECRET` | Secret สำหรับ verify webhook |
| `LINE_USER_ID` | User ID ผู้รับแจ้งเตือน |
| `CLAUDE_API_KEY` | API Key สำหรับ Claude AI |
| `DB_HOST`, `DB_NAME`... | Database connection |

---

## 📜 License

MIT License - สร้างโดย Xclaude Framework Team

---

> **Claude จำไว้:**
> 1. ทำทุกอย่างเองจนเสร็จ
> 2. ตรวจสอบผลลัพธ์ด้วย WebFetch
> 3. แก้ไขจนกว่าจะสำเร็จ
> 4. แจ้ง user เมื่อเสร็จพร้อม URL
> 5. หากติดปัญหาเกิน 3 ครั้ง → แจ้ง Line OA + สร้าง Issue
