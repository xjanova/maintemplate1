# คู่มือติดตั้ง XCLAUDE Framework

> **สำหรับผู้เริ่มต้น** - ติดตั้งระบบ Auto-Deploy + LINE Bot ครบวงจร

---

## สารบัญ

1. [ความต้องการของระบบ](#1-ความต้องการของระบบ)
2. [ขั้นตอนที่ 1: เตรียม Server](#2-ขั้นตอนที่-1-เตรียม-server)
3. [ขั้นตอนที่ 2: Clone และติดตั้ง](#3-ขั้นตอนที่-2-clone-และติดตั้ง)
4. [ขั้นตอนที่ 3: ตั้งค่า GitHub Secrets](#4-ขั้นตอนที่-3-ตั้งค่า-github-secrets)
5. [ขั้นตอนที่ 4: ตั้งค่า LINE OA (Optional)](#5-ขั้นตอนที่-4-ตั้งค่า-line-oa)
6. [ขั้นตอนที่ 5: ตั้งค่า Claude AI (Optional)](#6-ขั้นตอนที่-5-ตั้งค่า-claude-ai)
7. [ทดสอบระบบ](#7-ทดสอบระบบ)
8. [การแก้ไขปัญหา](#8-การแก้ไขปัญหา)

---

## 1. ความต้องการของระบบ

### Server Requirements

| รายการ | ขั้นต่ำ | แนะนำ |
|--------|---------|-------|
| OS | Ubuntu 20.04+ / Debian 11+ | Ubuntu 22.04 LTS |
| PHP | 8.1+ | 8.2+ |
| Web Server | Apache หรือ Nginx | Nginx |
| RAM | 1 GB | 2 GB+ |
| Storage | 10 GB | 20 GB+ |

### Software ที่ต้องติดตั้ง

```bash
# อัปเดตระบบ
sudo apt update && sudo apt upgrade -y

# ติดตั้ง PHP และ extensions
sudo apt install -y php8.2 php8.2-fpm php8.2-cli php8.2-common \
    php8.2-mysql php8.2-curl php8.2-json php8.2-mbstring php8.2-xml

# ติดตั้ง Nginx
sudo apt install -y nginx

# ติดตั้ง Git
sudo apt install -y git

# ติดตั้ง Composer (optional)
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer

# ติดตั้ง Node.js (optional - สำหรับ frontend build)
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs
```

---

## 2. ขั้นตอนที่ 1: เตรียม Server

### 2.1 สร้าง SSH Key สำหรับ GitHub

```bash
# สร้าง SSH key
ssh-keygen -t ed25519 -C "your-email@example.com" -f ~/.ssh/github_deploy -N ""

# ดู public key
cat ~/.ssh/github_deploy.pub
```

**คัดลอก public key แล้วเพิ่มใน GitHub:**
1. ไปที่ https://github.com/settings/keys
2. คลิก "New SSH key"
3. ใส่ Title: `Server Deploy Key`
4. วาง public key
5. คลิก "Add SSH key"

### 2.2 ตั้งค่า SSH Config

```bash
# สร้าง/แก้ไข SSH config
cat >> ~/.ssh/config << 'EOF'
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/github_deploy
    IdentitiesOnly yes
EOF

chmod 600 ~/.ssh/config
```

### 2.3 ทดสอบการเชื่อมต่อ GitHub

```bash
ssh -T git@github.com
```

ควรเห็น: `Hi username! You've successfully authenticated...`

---

## 3. ขั้นตอนที่ 2: Clone และติดตั้ง

### 3.1 Clone Repository

```bash
# สร้างโฟลเดอร์สำหรับเว็บ
sudo mkdir -p /var/www/myapp
sudo chown $USER:$USER /var/www/myapp

# Clone repository
cd /var/www
git clone git@github.com:YOUR_USERNAME/YOUR_REPO.git myapp
cd myapp
```

### 3.2 รัน Install Script

```bash
# ให้สิทธิ์และรัน
chmod +x scripts/install.sh
./scripts/install.sh
```

Script จะถามข้อมูลต่อไปนี้:
- ชื่อ App
- Domain/URL
- ข้อมูล Database (optional)
- LINE OA credentials (optional)
- Claude API Key (optional)

### 3.3 ตั้งค่า Nginx

```bash
# สร้าง Nginx config
sudo nano /etc/nginx/sites-available/myapp
```

วางเนื้อหานี้:

```nginx
server {
    listen 80;
    server_name your-domain.com www.your-domain.com;
    root /var/www/myapp/public;
    index index.php index.html;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php8.2-fpm.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.(git|env) {
        deny all;
    }

    # LINE Webhook endpoint
    location /src/api/line-webhook.php {
        fastcgi_pass unix:/var/run/php/php8.2-fpm.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        include fastcgi_params;
    }
}
```

```bash
# เปิดใช้งาน site
sudo ln -s /etc/nginx/sites-available/myapp /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

### 3.4 ติดตั้ง SSL (แนะนำ)

```bash
# ติดตั้ง Certbot
sudo apt install -y certbot python3-certbot-nginx

# ขอ SSL certificate
sudo certbot --nginx -d your-domain.com -d www.your-domain.com
```

---

## 4. ขั้นตอนที่ 3: ตั้งค่า GitHub Secrets

ไปที่: `https://github.com/YOUR_USERNAME/YOUR_REPO/settings/secrets/actions`

### Secrets ที่จำเป็น (สำหรับ Auto-Deploy)

| Secret Name | คำอธิบาย | ตัวอย่าง |
|-------------|----------|----------|
| `SSH_PRIVATE_KEY` | Private key สำหรับ SSH เข้า server | ดูด้านล่าง |
| `SERVER_HOST` | IP หรือ domain ของ server | `192.168.1.100` หรือ `server.example.com` |
| `SERVER_USER` | Username สำหรับ SSH | `ubuntu` หรือ `root` |
| `DEPLOY_PATH` | Path ของ app บน server | `/var/www/myapp` |
| `SITE_URL` | URL ของเว็บไซต์ | `https://your-domain.com` |

### วิธีดู SSH Private Key

```bash
# บน server
cat ~/.ssh/github_deploy

# หรือสร้าง deploy key ใหม่สำหรับ GitHub Actions
ssh-keygen -t ed25519 -C "github-actions" -f ~/.ssh/github_actions -N ""
cat ~/.ssh/github_actions
```

**สำคัญ:** คัดลอกทั้งหมดรวม `-----BEGIN` และ `-----END`

### เพิ่ม Public Key ใน Server

```bash
# เพิ่ม public key ที่ GitHub Actions จะใช้
cat ~/.ssh/github_actions.pub >> ~/.ssh/authorized_keys
```

---

## 5. ขั้นตอนที่ 4: ตั้งค่า LINE OA

> **Optional** - ข้ามขั้นตอนนี้ได้ถ้าไม่ต้องการแจ้งเตือนผ่าน LINE

### 5.1 สร้าง LINE Messaging API Channel

1. ไปที่ [LINE Developers Console](https://developers.line.biz/console/)
2. สร้าง Provider ใหม่ (ถ้ายังไม่มี)
3. สร้าง Channel → เลือก "Messaging API"
4. กรอกข้อมูล Channel

### 5.2 ตั้งค่า Webhook

1. ไปที่ Messaging API tab
2. ตั้งค่า Webhook URL:
   ```
   https://your-domain.com/src/api/line-webhook.php
   ```
3. เปิด "Use webhook"
4. ปิด "Auto-reply messages" (ถ้าต้องการให้ Bot ตอบเอง)

### 5.3 หา Channel Access Token

1. ไปที่ Messaging API tab
2. เลื่อนลงไปที่ "Channel access token"
3. กด "Issue" เพื่อสร้าง token

### 5.4 หา LINE User ID

**วิธีที่ 1: ใช้ Bot**
1. Add Friend กับ LINE OA ของคุณ
2. ส่งข้อความ `/myid`
3. Bot จะบอก User ID ของคุณ

**วิธีที่ 2: ดู Webhook Log**
1. ส่งข้อความใดๆ ให้ Bot
2. ดู webhook event ที่ได้รับ
3. หา `source.userId`

### 5.5 เพิ่ม GitHub Secrets

| Secret Name | ค่า |
|-------------|-----|
| `LINE_CHANNEL_ACCESS_TOKEN` | Token จากขั้นตอน 5.3 |
| `LINE_CHANNEL_SECRET` | Channel Secret จาก Basic settings |
| `LINE_USER_ID` | User ID จากขั้นตอน 5.4 |

### 5.6 อัปเดต .env บน Server

```bash
nano /var/www/myapp/.env
```

เพิ่ม:
```env
LINE_CHANNEL_ID=your_channel_id
LINE_CHANNEL_SECRET=your_channel_secret
LINE_CHANNEL_ACCESS_TOKEN=your_channel_access_token
LINE_USER_ID=Uxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

---

## 6. ขั้นตอนที่ 5: ตั้งค่า Claude AI

> **Optional** - ข้ามขั้นตอนนี้ได้ถ้าต้องการแค่โหมดแจ้งเตือน

### 6.1 สร้าง Claude API Key

1. ไปที่ [Anthropic Console](https://console.anthropic.com/)
2. สมัครบัญชี / เข้าสู่ระบบ
3. ไปที่ API Keys
4. กด "Create Key"
5. คัดลอก API Key

### 6.2 เพิ่มใน GitHub Secrets

| Secret Name | ค่า |
|-------------|-----|
| `CLAUDE_API_KEY` | `sk-ant-xxxxxxxxxxxxx` |

### 6.3 อัปเดต .env บน Server

```bash
nano /var/www/myapp/.env
```

เพิ่ม:
```env
CLAUDE_API_KEY=sk-ant-xxxxxxxxxxxxx

# จำกัดผู้ใช้ Claude AI (optional)
# ถ้าเว้นว่าง = ทุกคนใช้ได้
# ถ้าใส่ = เฉพาะ User IDs ที่ระบุ
ALLOWED_LINE_USERS=Uxxxxxxxxx,Uyyyyyyyyy
```

### 6.4 ค่าใช้จ่าย Claude API

| Model | Input | Output | หมายเหตุ |
|-------|-------|--------|----------|
| Claude Haiku | ~$0.25/M tokens | ~$1.25/M tokens | เร็ว ประหยัด |
| Claude Sonnet | ~$3/M tokens | ~$15/M tokens | สมดุล |
| Claude Opus | ~$15/M tokens | ~$75/M tokens | ฉลาดที่สุด |

> **หมายเหตุ:** Claude API แยกจาก Claude Pro/Max subscription

---

## 7. ทดสอบระบบ

### 7.1 ทดสอบเว็บไซต์

```bash
curl -I https://your-domain.com
```

ควรได้ `HTTP/2 200`

### 7.2 ทดสอบ Auto-Deploy

1. แก้ไขไฟล์ใดๆ ใน repository
2. Commit และ Push
3. ไปที่ GitHub Actions ดูสถานะ
4. รอ deploy เสร็จ
5. ตรวจสอบเว็บไซต์

### 7.3 ทดสอบ LINE Bot

1. Add Friend กับ LINE OA
2. ส่งข้อความ `help`
3. Bot ควรตอบกลับรายการคำสั่ง

### 7.4 ทดสอบ LINE Notify

1. Push code ใหม่ไปยัง `main` branch
2. รอ deploy
3. ควรได้รับแจ้งเตือนใน LINE

---

## 8. การแก้ไขปัญหา

### ปัญหา: Deploy ไม่ทำงาน

**ตรวจสอบ:**
```bash
# ตรวจสอบ SSH connection
ssh -i ~/.ssh/github_actions user@server "echo OK"

# ตรวจสอบ path
ls -la /var/www/myapp
```

**สาเหตุที่พบบ่อย:**
- SSH key ไม่ถูกต้อง
- Path ไม่ตรงกับ DEPLOY_PATH
- Permission denied

### ปัญหา: LINE Webhook ไม่ทำงาน

**ตรวจสอบ:**
```bash
# ตรวจสอบ PHP errors
tail -f /var/log/nginx/error.log

# ทดสอบ endpoint
curl -X POST https://your-domain.com/src/api/line-webhook.php
```

**สาเหตุที่พบบ่อย:**
- Webhook URL ผิด
- SSL certificate มีปัญหา
- PHP error

### ปัญหา: Claude AI ไม่ตอบ

**ตรวจสอบ:**
- API Key ถูกต้อง
- มี credits เพียงพอ
- User ID อยู่ใน ALLOWED_LINE_USERS (ถ้าตั้งค่าไว้)

### ดู Logs

```bash
# PHP/Nginx errors
tail -f /var/log/nginx/error.log

# App logs
tail -f /var/www/myapp/storage/logs/*.log
```

---

## Quick Reference

### GitHub Secrets ทั้งหมด

| Secret | จำเป็น | คำอธิบาย |
|--------|--------|----------|
| `SSH_PRIVATE_KEY` | ✅ | SSH private key |
| `SERVER_HOST` | ✅ | Server IP/domain |
| `SERVER_USER` | ✅ | SSH username |
| `DEPLOY_PATH` | ✅ | App path on server |
| `SITE_URL` | ✅ | Website URL |
| `LINE_CHANNEL_ACCESS_TOKEN` | ❌ | LINE OA token |
| `LINE_CHANNEL_SECRET` | ❌ | LINE channel secret |
| `LINE_USER_ID` | ❌ | LINE user to notify |
| `CLAUDE_API_KEY` | ❌ | Claude API key |

### คำสั่ง LINE Bot

| คำสั่ง | ผลลัพธ์ |
|--------|---------|
| `help` | ดูคำสั่งทั้งหมด |
| `status` | ดูสถานะ deploy |
| `url` | ดู URL เว็บไซต์ |
| `/myid` | ดู LINE User ID |

---

## Support

หากพบปัญหา:
1. ตรวจสอบ [GitHub Actions logs](../../actions)
2. ดู [Issues](../../issues)
3. สร้าง Issue ใหม่พร้อม error message

---

*สร้างโดย XCLAUDE Framework*
