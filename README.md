# Xclaude Framework

<div align="center">

```
╔═══════════════════════════════════════════════════════════════════════════╗
║   __  __    ___ _                 _        ___                            ║
║   \ \/ /   / __| |__ _ _  _ ___ _| |___   | __| _ __ _ _ __  ___          ║
║    >  <   | (__| / _` | || / _` | / -_)  | _| '_/ _` | '  \/ -_)         ║
║   /_/\_\   \___|_\__,_|\_,_\__,_|_\___|  |_||_| \__,_|_|_|_\___|         ║
╚═══════════════════════════════════════════════════════════════════════════╝
```

**AI-Powered Development Framework**

*"Just tell Claude what you want"*

[![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)](https://github.com)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![PHP](https://img.shields.io/badge/PHP-8.2+-purple.svg)](https://php.net)

</div>

---

## ภาพรวม

**Xclaude Framework** คือ framework สำหรับพัฒนาเว็บที่ออกแบบมาให้ทำงานร่วมกับ Claude AI ได้อย่างสมบูรณ์แบบ

คุณแค่บอก Claude ว่าต้องการอะไร - Claude จะเขียนโค้ด ทดสอบ และ Deploy ให้อัตโนมัติ

### ความสามารถหลัก

| Feature | Description |
|---------|-------------|
| 🤖 **AI เขียนโค้ดให้** | Claude เข้าใจความต้องการและเขียนโค้ดคุณภาพสูง |
| 🚀 **Auto Deploy** | Merge แล้ว Deploy ขึ้น Server ทันที |
| 👁️ **ตรวจสอบผลลัพธ์** | Claude เปิดหน้าเว็บจริงและตรวจสอบ |
| 🔧 **แก้ไขอัตโนมัติ** | พบ error ก็แก้เอง ไม่ต้องรบกวนคุณ |
| 📱 **แจ้งเตือน Line** | มีปัญหาก็แจ้งผ่าน Line OA ทันที |
| 🔒 **Security Scan** | ตรวจช่องโหว่ทุกครั้งที่ Deploy |

---

## เริ่มต้นใช้งาน

### 1. สร้าง Repository จาก Template

คลิก **"Use this template"** บน GitHub เพื่อสร้าง repository ใหม่

### 2. ตั้งค่า Server (รันบน VPS ของคุณ)

```bash
# Clone repository
git clone https://github.com/YOUR_USERNAME/YOUR_REPO.git
cd YOUR_REPO

# รัน wizard ตั้งค่า
chmod +x install.sh
./install.sh
```

Wizard จะช่วย:
- สร้าง SSH key สำหรับ deploy
- แสดง secrets ที่ต้องเพิ่มใน GitHub
- ตั้งค่าการเชื่อมต่อ

### 3. เพิ่ม GitHub Secrets

เพิ่ม secrets ที่ได้จาก `install.sh` ใน GitHub:
- **Settings** → **Secrets and variables** → **Actions**

| Secret | Description |
|--------|-------------|
| `SSH_PRIVATE_KEY` | SSH key สำหรับ deploy |
| `SERVER_HOST` | IP หรือ hostname ของ server |
| `SERVER_USER` | SSH username |
| `DEPLOY_PATH` | Path บน server |
| `SITE_URL` | URL ของเว็บไซต์ |
| `LINE_NOTIFY_TOKEN` | (optional) สำหรับแจ้งเตือน Line |

### 4. เริ่มพัฒนา!

```bash
# พิมพ์ใน Claude Code
"เพิ่มหน้า login พร้อม OAuth"
```

Claude จะ:
1. วางแผนและอธิบายสิ่งที่จะทำ
2. เขียนโค้ด
3. Commit และ Push
4. รอ Deploy อัตโนมัติ
5. เปิดหน้าเว็บตรวจสอบ
6. แจ้งผลลัพธ์พร้อม URL

---

## โครงสร้างโปรเจค

```
xclaude-project/
├── .xclaude/                    # Core Framework Config
│   └── config.yml               # การตั้งค่าหลัก
├── .github/workflows/           # GitHub Actions
│   ├── deploy.yml               # Auto deploy
│   ├── release.yml              # Auto release
│   ├── security.yml             # Security scan
│   └── test.yml                 # Tests
├── public/                      # Web Root
│   ├── index.php                # Entry point
│   ├── css/                     # Styles
│   └── js/                      # Scripts
├── src/                         # Source Code
│   ├── pages/                   # หน้าเว็บ
│   ├── components/              # Components
│   └── layouts/                 # Layouts
├── config/                      # Configuration
├── storage/                     # Storage (logs, cache)
├── deploy.sh                    # Smart deploy script
├── install.sh                   # Setup wizard
└── CLAUDE.md                    # คู่มือสำหรับ Claude
```

---

## Tech Stack

- **Backend:** PHP 8.2+ (Modern PHP)
- **CSS:** Tailwind CSS 3.x
- **JavaScript:** Alpine.js 3.x + HTMX
- **Build:** Vite (optional)
- **CI/CD:** GitHub Actions

---

## Commit Convention

| Prefix | Description | Version Bump |
|--------|-------------|--------------|
| `feat:` | ฟีเจอร์ใหม่ | Minor (1.x.0) |
| `fix:` | แก้บั๊ก | Patch (1.0.x) |
| `feat!:` | Breaking change | Major (x.0.0) |
| `docs:` | เอกสาร | ไม่เปลี่ยน |
| `chore:` | งานทั่วไป | ไม่เปลี่ยน |

---

## เอกสาร

- [CLAUDE.md](CLAUDE.md) - คู่มือหลักสำหรับ Claude
- [docs/DEVELOPMENT.md](docs/DEVELOPMENT.md) - คู่มือพัฒนา
- [docs/GITHUB_SECRETS_SETUP.md](docs/GITHUB_SECRETS_SETUP.md) - ตั้งค่า Secrets
- [docs/TASKS.md](docs/TASKS.md) - ติดตามงาน

---

## การแจ้งเตือน Line

เพิ่ม `LINE_NOTIFY_TOKEN` ใน GitHub Secrets เพื่อรับการแจ้งเตือน:
- ✅ Deploy สำเร็จ
- ❌ Deploy ล้มเหลว
- 🚨 Error เกิน threshold (ต้องการมนุษย์ตรวจสอบ)

---

## License

MIT License - ใช้งานได้ฟรีทั้งส่วนตัวและเชิงพาณิชย์

---

<div align="center">

**Made with ❤️ by Xclaude Framework Team**

*"Just tell Claude what you want"*

</div>
