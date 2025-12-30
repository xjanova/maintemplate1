#!/bin/bash

# ==============================================================================
#                    XCLAUDE FRAMEWORK - Installation Wizard
#                    Complete Setup for Beginners
# ==============================================================================
#
# One-liner install:
# bash <(curl -sL https://raw.githubusercontent.com/xjanova/maintemplate1/main/scripts/install.sh)
#
# ==============================================================================

set -e

# ==============================================================================
# Colors
# ==============================================================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
BOLD='\033[1m'
NC='\033[0m'

# ==============================================================================
# Variables
# ==============================================================================
GITHUB_REPO="xjanova/maintemplate1"
REPO_URL="https://github.com/${GITHUB_REPO}.git"
INSTALL_DIR=""
WEB_SERVER=""
DOMAIN=""
SERVER_IP=""
CURRENT_USER=$(whoami)

# ==============================================================================
# Helper Functions
# ==============================================================================

print_banner() {
    clear
    echo ""
    echo -e "${CYAN}================================================================${NC}"
    echo -e "${CYAN}        XCLAUDE FRAMEWORK - Installation Wizard${NC}"
    echo -e "${CYAN}        Complete Setup for Beginners${NC}"
    echo -e "${CYAN}================================================================${NC}"
    echo ""
}

print_step() {
    echo ""
    echo -e "${BLUE}================================================================${NC}"
    echo -e "${WHITE}${BOLD}  STEP $1${NC}"
    echo -e "${BLUE}================================================================${NC}"
    echo ""
}

print_substep() {
    echo -e "${PURPLE}  >> $1${NC}"
}

print_success() { echo -e "${GREEN}  [OK] $1${NC}"; }
print_error()   { echo -e "${RED}  [ERROR] $1${NC}"; }
print_warning() { echo -e "${YELLOW}  [WARNING] $1${NC}"; }
print_info()    { echo -e "${CYAN}  [INFO] $1${NC}"; }

print_command() {
    echo -e "${YELLOW}  \$ $1${NC}"
}

print_box() {
    local text="$1"
    local len=${#text}
    echo ""
    echo -e "${WHITE}  +$(printf '%*s' $((len + 2)) | tr ' ' '-')+${NC}"
    echo -e "${WHITE}  | ${CYAN}$text${WHITE} |${NC}"
    echo -e "${WHITE}  +$(printf '%*s' $((len + 2)) | tr ' ' '-')+${NC}"
    echo ""
}

ask_question() {
    local prompt="$1"
    local default="$2"
    local result=""

    if [ -n "$default" ]; then
        echo -e -n "${PURPLE}  ? ${WHITE}$prompt ${CYAN}[$default]${NC}: "
        read -r result
        echo "${result:-$default}"
    else
        echo -e -n "${PURPLE}  ? ${WHITE}$prompt${NC}: "
        read -r result
        echo "$result"
    fi
}

ask_yes_no() {
    local prompt="$1"
    local default="${2:-n}"
    local result=""

    if [ "$default" = "y" ]; then
        echo -e -n "${PURPLE}  ? ${WHITE}$prompt ${CYAN}[Y/n]${NC}: "
    else
        echo -e -n "${PURPLE}  ? ${WHITE}$prompt ${CYAN}[y/N]${NC}: "
    fi

    read -r result
    result="${result:-$default}"

    case "$result" in
        [Yy]* ) return 0;;
        * ) return 1;;
    esac
}

ask_password() {
    local prompt="$1"
    echo -e -n "${PURPLE}  ? ${WHITE}$prompt${NC}: "
    read -rs result
    echo ""
    echo "$result"
}

wait_for_enter() {
    echo ""
    echo -e -n "${YELLOW}  Press ENTER to continue...${NC}"
    read -r
}

check_command() {
    command -v "$1" &> /dev/null
}

get_server_ip() {
    # Try to get public IP
    curl -s ifconfig.me 2>/dev/null || curl -s icanhazip.com 2>/dev/null || hostname -I | awk '{print $1}' || echo "YOUR_SERVER_IP"
}

# ==============================================================================
# STEP 1: Welcome & Overview
# ==============================================================================

step_welcome() {
    print_banner

    echo -e "${WHITE}  Welcome! This wizard will help you set up Xclaude Framework.${NC}"
    echo ""
    echo -e "${WHITE}  What this wizard will do:${NC}"
    echo -e "${CYAN}  1. Check your system requirements${NC}"
    echo -e "${CYAN}  2. Set up SSH key for GitHub (if needed)${NC}"
    echo -e "${CYAN}  3. Clone the repository to your server${NC}"
    echo -e "${CYAN}  4. Configure your environment (.env file)${NC}"
    echo -e "${CYAN}  5. Set up file permissions${NC}"
    echo -e "${CYAN}  6. Configure your web server (Nginx/Apache)${NC}"
    echo -e "${CYAN}  7. Set up GitHub Secrets for auto-deploy${NC}"
    echo -e "${CYAN}  8. Test the installation${NC}"
    echo -e "${CYAN}  9. Show you how to use Claude AI${NC}"
    echo ""

    SERVER_IP=$(get_server_ip)
    print_info "Detected server IP: $SERVER_IP"
    echo ""

    if ! ask_yes_no "Ready to begin?" "y"; then
        echo ""
        echo "  Installation cancelled. Run this script again when ready."
        exit 0
    fi
}

# ==============================================================================
# STEP 2: Check System Requirements
# ==============================================================================

step_check_requirements() {
    print_step "1/9: Checking System Requirements"

    echo -e "${WHITE}  Checking required software...${NC}"
    echo ""

    local all_ok=true

    # PHP
    if check_command php; then
        local php_version=$(php -v | head -n1 | cut -d' ' -f2)
        print_success "PHP installed (version $php_version)"
    else
        print_error "PHP not found"
        echo -e "${YELLOW}    Install with: sudo apt install php8.2 php8.2-fpm php8.2-cli${NC}"
        all_ok=false
    fi

    # Git
    if check_command git; then
        print_success "Git installed"
    else
        print_error "Git not found"
        echo -e "${YELLOW}    Install with: sudo apt install git${NC}"
        all_ok=false
    fi

    # curl
    if check_command curl; then
        print_success "curl installed"
    else
        print_error "curl not found"
        echo -e "${YELLOW}    Install with: sudo apt install curl${NC}"
        all_ok=false
    fi

    # Web server
    if check_command nginx; then
        print_success "Nginx installed"
        WEB_SERVER="nginx"
    elif check_command apache2 || check_command httpd; then
        print_success "Apache installed"
        WEB_SERVER="apache"
    else
        print_warning "No web server detected (Nginx/Apache)"
        WEB_SERVER="none"
    fi

    # SSH
    if check_command ssh; then
        print_success "SSH installed"
    else
        print_warning "SSH not found"
    fi

    # Optional checks
    echo ""
    echo -e "${WHITE}  Optional software:${NC}"

    if check_command composer; then
        print_success "Composer installed"
    else
        print_info "Composer not found (optional)"
    fi

    if check_command node; then
        print_success "Node.js installed"
    else
        print_info "Node.js not found (optional)"
    fi

    if [ "$all_ok" = false ]; then
        echo ""
        print_warning "Some required software is missing."
        if ! ask_yes_no "Continue anyway?" "n"; then
            exit 1
        fi
    fi

    wait_for_enter
}

# ==============================================================================
# STEP 3: Setup SSH Key for GitHub
# ==============================================================================

step_setup_ssh() {
    print_step "2/9: Setup SSH Key for GitHub"

    echo -e "${WHITE}  SSH keys allow your server to communicate with GitHub securely.${NC}"
    echo -e "${WHITE}  This is needed for:${NC}"
    echo -e "${CYAN}    - Cloning private repositories${NC}"
    echo -e "${CYAN}    - Auto-deploy from GitHub Actions${NC}"
    echo ""

    # Check if SSH key exists
    local ssh_key="$HOME/.ssh/id_rsa"
    local ssh_key_xclaude="$HOME/.ssh/id_rsa_xclaude"

    if [ -f "$ssh_key" ]; then
        print_success "SSH key already exists: $ssh_key"
        SSH_KEY_FILE="$ssh_key"
    elif [ -f "$ssh_key_xclaude" ]; then
        print_success "SSH key already exists: $ssh_key_xclaude"
        SSH_KEY_FILE="$ssh_key_xclaude"
    else
        print_info "No SSH key found."
        echo ""

        if ask_yes_no "Generate new SSH key for GitHub?" "y"; then
            echo ""
            print_substep "Generating SSH key..."

            mkdir -p ~/.ssh
            chmod 700 ~/.ssh

            ssh-keygen -t ed25519 -f "$ssh_key_xclaude" -N "" -C "xclaude-deploy@$(hostname)"

            print_success "SSH key generated!"
            SSH_KEY_FILE="$ssh_key_xclaude"

            echo ""
            print_box "IMPORTANT: Add this SSH key to GitHub"

            echo -e "${WHITE}  Your PUBLIC key (safe to share):${NC}"
            echo ""
            echo -e "${CYAN}"
            cat "${SSH_KEY_FILE}.pub"
            echo -e "${NC}"

            echo ""
            echo -e "${WHITE}  How to add to GitHub:${NC}"
            echo -e "${CYAN}  1. Go to: https://github.com/settings/keys${NC}"
            echo -e "${CYAN}  2. Click 'New SSH key'${NC}"
            echo -e "${CYAN}  3. Title: 'Xclaude Server - $(hostname)'${NC}"
            echo -e "${CYAN}  4. Paste the public key above${NC}"
            echo -e "${CYAN}  5. Click 'Add SSH key'${NC}"
            echo ""

            wait_for_enter
        else
            SSH_KEY_FILE=""
            print_info "Skipping SSH setup. Using HTTPS for clone."
        fi
    fi

    # Show existing key if found
    if [ -n "$SSH_KEY_FILE" ] && [ -f "${SSH_KEY_FILE}.pub" ]; then
        echo ""
        echo -e "${WHITE}  Your SSH public key:${NC}"
        echo -e "${CYAN}"
        cat "${SSH_KEY_FILE}.pub"
        echo -e "${NC}"

        if ask_yes_no "Have you added this key to GitHub?" "y"; then
            print_success "SSH key configured!"
        else
            echo ""
            echo -e "${WHITE}  Please add the key to GitHub:${NC}"
            echo -e "${CYAN}  https://github.com/settings/keys${NC}"
            wait_for_enter
        fi
    fi
}

# ==============================================================================
# STEP 4: Clone Repository
# ==============================================================================

step_clone_repository() {
    print_step "3/9: Clone Repository"

    echo -e "${WHITE}  Where should we install Xclaude Framework?${NC}"
    echo ""

    # Check if already in repo
    if [ -f "CLAUDE.md" ] && [ -d ".github" ]; then
        print_info "Already in Xclaude Framework directory!"
        INSTALL_DIR=$(pwd)

        if ask_yes_no "Update existing installation?" "y"; then
            print_substep "Updating repository..."
            git pull origin main 2>/dev/null || git pull origin claude/main 2>/dev/null || true
            print_success "Updated!"
        fi
        return 0
    fi

    # Ask for install directory
    INSTALL_DIR=$(ask_question "Installation directory" "/var/www/xclaude-app")

    # Check if directory exists
    if [ -d "$INSTALL_DIR" ]; then
        if [ -f "$INSTALL_DIR/CLAUDE.md" ]; then
            print_info "Existing installation found at $INSTALL_DIR"
            cd "$INSTALL_DIR"

            if ask_yes_no "Update existing installation?" "y"; then
                git pull origin main 2>/dev/null || git pull origin claude/main 2>/dev/null || true
                print_success "Updated!"
            fi
            return 0
        else
            print_warning "Directory exists but is not Xclaude Framework"
            if ! ask_yes_no "Delete and reinstall?" "n"; then
                INSTALL_DIR=$(ask_question "Choose different directory" "/var/www/xclaude-app-new")
            else
                rm -rf "$INSTALL_DIR"
            fi
        fi
    fi

    # Clone repository
    echo ""
    print_substep "Cloning repository..."

    mkdir -p "$(dirname "$INSTALL_DIR")"

    # Try SSH first, fallback to HTTPS
    if [ -n "$SSH_KEY_FILE" ]; then
        print_info "Trying SSH clone..."
        if git clone "git@github.com:${GITHUB_REPO}.git" "$INSTALL_DIR" 2>/dev/null; then
            print_success "Cloned via SSH!"
        else
            print_warning "SSH clone failed, trying HTTPS..."
            git clone "$REPO_URL" "$INSTALL_DIR"
            print_success "Cloned via HTTPS!"
        fi
    else
        git clone "$REPO_URL" "$INSTALL_DIR"
        print_success "Cloned via HTTPS!"
    fi

    cd "$INSTALL_DIR"
    print_success "Repository cloned to: $INSTALL_DIR"

    wait_for_enter
}

# ==============================================================================
# STEP 5: Configure Environment
# ==============================================================================

step_configure_environment() {
    print_step "4/9: Configure Environment"

    echo -e "${WHITE}  Let's configure your application settings.${NC}"
    echo ""

    # Generate secret key
    SECRET_KEY=$(openssl rand -hex 32 2>/dev/null || head -c 64 /dev/urandom | base64 | tr -d '\n/+' | head -c 64)

    # App settings
    print_substep "Application Settings"
    echo ""
    APP_NAME=$(ask_question "Application name" "My Xclaude App")
    APP_ENV=$(ask_question "Environment (development/production)" "production")

    [ "$APP_ENV" = "production" ] && APP_DEBUG="false" || APP_DEBUG="true"

    # Domain/URL settings
    echo ""
    print_substep "Domain Configuration"
    echo ""
    echo -e "${WHITE}  Enter your domain (e.g., example.com or app.example.com)${NC}"
    echo -e "${CYAN}  If you don't have a domain, use your server IP: $SERVER_IP${NC}"
    echo ""

    DOMAIN=$(ask_question "Domain or IP" "$SERVER_IP")

    # Construct SITE_URL
    if ask_yes_no "Use HTTPS? (recommended if you have SSL)" "n"; then
        SITE_URL="https://${DOMAIN}"
    else
        SITE_URL="http://${DOMAIN}"
    fi

    print_info "Site URL will be: $SITE_URL"

    # Database settings
    echo ""
    print_substep "Database Configuration"
    echo ""

    if ask_yes_no "Configure database connection?" "y"; then
        DB_HOST=$(ask_question "Database host" "localhost")
        DB_PORT=$(ask_question "Database port" "3306")
        DB_NAME=$(ask_question "Database name" "xclaude_app")
        DB_USER=$(ask_question "Database user" "root")
        DB_PASS=$(ask_password "Database password (hidden)")
        CONFIGURE_DB="yes"
    else
        DB_HOST="localhost"
        DB_PORT="3306"
        DB_NAME=""
        DB_USER=""
        DB_PASS=""
        CONFIGURE_DB="no"
    fi

    # Line Notify (optional)
    echo ""
    print_substep "LINE OA Notifications (Optional)"
    echo ""
    echo -e "${WHITE}  LINE OA Messaging API sends alerts when deploy succeeds/fails.${NC}"
    echo -e "${WHITE}  Users must add your LINE OA as friend to receive notifications.${NC}"
    echo ""

    if ask_yes_no "Configure LINE OA notifications?" "n"; then
        echo ""
        echo -e "${CYAN}  Get your credentials at: https://developers.line.biz/console/${NC}"
        echo ""
        echo -e "${WHITE}  1. Create a Messaging API channel${NC}"
        echo -e "${WHITE}  2. Get Channel Access Token (long-lived)${NC}"
        echo -e "${WHITE}  3. Add Friend กับ OA แล้วดู Webhook event เพื่อหา User ID${NC}"
        echo ""
        LINE_CHANNEL_ACCESS_TOKEN=$(ask_question "LINE Channel Access Token" "")
        LINE_CHANNEL_SECRET=$(ask_question "LINE Channel Secret" "")
        echo ""
        echo -e "${WHITE}  User ID ขึ้นต้นด้วย 'U' ตามด้วยตัวอักษร 33 ตัว${NC}"
        echo -e "${WHITE}  เช่น: Uxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx${NC}"
        echo ""
        LINE_USER_ID=$(ask_question "LINE User ID (ผู้รับแจ้งเตือน)" "")

        echo ""
        if ask_yes_no "ต้องการเปิดใช้ Claude AI สำหรับตอบคำถาม? (ไม่จำเป็น)" "n"; then
            print_substep "Claude AI Integration"
            echo ""
            echo -e "${WHITE}  Claude AI จะทำให้ Bot ตอบคำถามได้อัจฉริยะ${NC}"
            echo -e "${WHITE}  ถ้าไม่ใส่ Bot จะทำงานในโหมดแจ้งเตือนอย่างเดียว${NC}"
            echo ""
            echo -e "${CYAN}  Get your API key at: https://console.anthropic.com/${NC}"
            echo ""
            CLAUDE_API_KEY=$(ask_question "Claude API Key" "")
        else
            CLAUDE_API_KEY=""
            echo -e "${GREEN}  ✓ Bot จะทำงานในโหมดแจ้งเตือน${NC}"
        fi
        CONFIGURE_LINE="yes"
    else
        LINE_CHANNEL_ACCESS_TOKEN=""
        LINE_CHANNEL_SECRET=""
        LINE_USER_ID=""
        CLAUDE_API_KEY=""
        CONFIGURE_LINE="no"
    fi

    # Create .env file
    echo ""
    print_substep "Creating .env file..."

    cat > .env << EOF
# ==============================================================================
# XCLAUDE FRAMEWORK - Environment Configuration
# Generated by install.sh on $(date)
# ==============================================================================

# Application
APP_NAME="$APP_NAME"
APP_ENV=$APP_ENV
APP_DEBUG=$APP_DEBUG
APP_SECRET=$SECRET_KEY
APP_TIMEZONE=Asia/Bangkok

# URLs
SITE_URL=$SITE_URL
STAGING_URL=

# Server (for auto-deploy)
SERVER_HOST=$SERVER_IP
SERVER_USER=$CURRENT_USER
DEPLOY_PATH=$INSTALL_DIR

# Database
DB_HOST=$DB_HOST
DB_PORT=$DB_PORT
DB_NAME=$DB_NAME
DB_USER=$DB_USER
DB_PASS=$DB_PASS

# LINE OA Messaging API
LINE_CHANNEL_ACCESS_TOKEN=$LINE_CHANNEL_ACCESS_TOKEN
LINE_CHANNEL_SECRET=$LINE_CHANNEL_SECRET
LINE_USER_ID=$LINE_USER_ID

# Claude AI (for LINE Bot)
CLAUDE_API_KEY=$CLAUDE_API_KEY

# Security
ALLOWED_HOSTS=$DOMAIN
RATE_LIMIT=60
ERROR_THRESHOLD=3
EOF

    print_success ".env file created!"

    wait_for_enter
}

# ==============================================================================
# STEP 6: Set Permissions
# ==============================================================================

step_set_permissions() {
    print_step "5/9: Setting File Permissions"

    echo -e "${WHITE}  Setting up directories and permissions...${NC}"
    echo ""

    # Create directories
    print_substep "Creating directories..."
    mkdir -p storage/logs storage/cache storage/uploads
    mkdir -p public/css public/js public/assets
    print_success "Directories created"

    # Set permissions
    print_substep "Setting permissions..."
    chmod -R 755 .
    chmod -R 775 storage
    chmod +x deploy.sh 2>/dev/null || true
    chmod +x scripts/*.sh 2>/dev/null || true
    print_success "Permissions set"

    # Set ownership if root
    if [ "$EUID" -eq 0 ]; then
        echo ""
        print_substep "Setting file ownership..."

        # Detect web server user
        if id "www-data" &>/dev/null; then
            WEB_USER="www-data"
        elif id "nginx" &>/dev/null; then
            WEB_USER="nginx"
        elif id "apache" &>/dev/null; then
            WEB_USER="apache"
        else
            WEB_USER=$(ask_question "Web server user" "www-data")
        fi

        chown -R "$WEB_USER:$WEB_USER" storage public
        print_success "Ownership set to $WEB_USER"
    fi

    wait_for_enter
}

# ==============================================================================
# STEP 7: Configure Web Server
# ==============================================================================

step_configure_webserver() {
    print_step "6/9: Configure Web Server"

    if [ "$WEB_SERVER" = "none" ]; then
        print_warning "No web server detected. Skipping this step."
        echo ""
        echo -e "${WHITE}  You'll need to configure your web server manually.${NC}"
        echo -e "${CYAN}  Document root should be: $INSTALL_DIR/public${NC}"
        wait_for_enter
        return 0
    fi

    echo -e "${WHITE}  Configuring $WEB_SERVER for domain: $DOMAIN${NC}"
    echo ""

    if [ "$WEB_SERVER" = "nginx" ]; then
        # Detect PHP-FPM socket
        PHP_SOCKET="/var/run/php/php8.2-fpm.sock"
        if [ ! -S "$PHP_SOCKET" ]; then
            PHP_SOCKET=$(find /var/run/php -name "*.sock" 2>/dev/null | head -1)
            [ -z "$PHP_SOCKET" ] && PHP_SOCKET="/var/run/php/php-fpm.sock"
        fi

        cat > /tmp/xclaude-nginx.conf << EOF
server {
    listen 80;
    server_name $DOMAIN www.$DOMAIN;
    root $INSTALL_DIR/public;
    index index.php index.html;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;

    # Logging
    access_log /var/log/nginx/${DOMAIN}_access.log;
    error_log /var/log/nginx/${DOMAIN}_error.log;

    # Main location
    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    # PHP processing
    location ~ \.php\$ {
        fastcgi_pass unix:$PHP_SOCKET;
        fastcgi_param SCRIPT_FILENAME \$realpath_root\$fastcgi_script_name;
        include fastcgi_params;
        fastcgi_hide_header X-Powered-By;
    }

    # Deny access to hidden files
    location ~ /\. {
        deny all;
    }

    # Deny access to sensitive directories
    location ~ ^/(storage|config)/ {
        deny all;
    }

    # Cache static files
    location ~* \.(css|js|jpg|jpeg|png|gif|ico|svg|woff|woff2)\$ {
        expires 30d;
        add_header Cache-Control "public, immutable";
    }
}
EOF

        print_success "Nginx config generated!"
        echo ""
        echo -e "${WHITE}  Config file: /tmp/xclaude-nginx.conf${NC}"
        echo ""

        if [ "$EUID" -eq 0 ]; then
            if ask_yes_no "Install Nginx config automatically?" "y"; then
                cp /tmp/xclaude-nginx.conf "/etc/nginx/sites-available/$DOMAIN"
                ln -sf "/etc/nginx/sites-available/$DOMAIN" /etc/nginx/sites-enabled/

                # Test and reload
                if nginx -t 2>/dev/null; then
                    systemctl reload nginx
                    print_success "Nginx configured and reloaded!"
                else
                    print_error "Nginx config test failed. Please check manually."
                fi
            fi
        else
            echo -e "${WHITE}  To install manually (as root):${NC}"
            echo ""
            print_command "sudo cp /tmp/xclaude-nginx.conf /etc/nginx/sites-available/$DOMAIN"
            print_command "sudo ln -sf /etc/nginx/sites-available/$DOMAIN /etc/nginx/sites-enabled/"
            print_command "sudo nginx -t && sudo systemctl reload nginx"
        fi

    elif [ "$WEB_SERVER" = "apache" ]; then
        cat > /tmp/xclaude-apache.conf << EOF
<VirtualHost *:80>
    ServerName $DOMAIN
    ServerAlias www.$DOMAIN
    DocumentRoot $INSTALL_DIR/public

    <Directory $INSTALL_DIR/public>
        AllowOverride All
        Require all granted
    </Directory>

    <Directory $INSTALL_DIR/storage>
        Require all denied
    </Directory>

    <Directory $INSTALL_DIR/config>
        Require all denied
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/${DOMAIN}_error.log
    CustomLog \${APACHE_LOG_DIR}/${DOMAIN}_access.log combined
</VirtualHost>
EOF

        print_success "Apache config generated!"
        echo ""
        echo -e "${WHITE}  Config file: /tmp/xclaude-apache.conf${NC}"
        echo ""
        echo -e "${WHITE}  To install:${NC}"
        print_command "sudo cp /tmp/xclaude-apache.conf /etc/apache2/sites-available/${DOMAIN}.conf"
        print_command "sudo a2ensite ${DOMAIN}.conf"
        print_command "sudo a2enmod rewrite"
        print_command "sudo systemctl reload apache2"
    fi

    wait_for_enter
}

# ==============================================================================
# STEP 8: Setup GitHub Secrets for Auto-Deploy
# ==============================================================================

step_setup_github_secrets() {
    print_step "7/9: Setup GitHub Secrets for Auto-Deploy"

    echo -e "${WHITE}  GitHub Secrets allow automatic deployment when you push code.${NC}"
    echo -e "${WHITE}  When you push to GitHub, it will automatically update your server!${NC}"
    echo ""

    print_box "GitHub Secrets Configuration"

    echo -e "${WHITE}  Go to this URL:${NC}"
    echo -e "${CYAN}  https://github.com/${GITHUB_REPO}/settings/secrets/actions${NC}"
    echo ""
    echo -e "${WHITE}  Click 'New repository secret' and add each of these:${NC}"
    echo ""

    # Table header
    echo -e "${WHITE}  +-----------------------+------------------------------------------+${NC}"
    echo -e "${WHITE}  | Secret Name           | Value                                    |${NC}"
    echo -e "${WHITE}  +-----------------------+------------------------------------------+${NC}"
    echo -e "${WHITE}  | SSH_PRIVATE_KEY       | ${CYAN}(Your SSH private key - see below)${WHITE}      |${NC}"
    echo -e "${WHITE}  | SERVER_HOST           | ${CYAN}$SERVER_IP${NC}"
    echo -e "${WHITE}  | SERVER_USER           | ${CYAN}$CURRENT_USER${NC}"
    echo -e "${WHITE}  | DEPLOY_PATH           | ${CYAN}$INSTALL_DIR${NC}"
    echo -e "${WHITE}  | SITE_URL              | ${CYAN}$SITE_URL${NC}"
    if [ -n "$LINE_CHANNEL_ACCESS_TOKEN" ]; then
    echo -e "${WHITE}  | LINE_CHANNEL_ACCESS_TOKEN | ${CYAN}(Your LINE OA token)${NC}"
    echo -e "${WHITE}  | LINE_CHANNEL_SECRET   | ${CYAN}(Your LINE channel secret)${NC}"
    echo -e "${WHITE}  | LINE_USER_ID          | ${CYAN}$LINE_USER_ID${NC}"
    fi
    if [ -n "$CLAUDE_API_KEY" ]; then
    echo -e "${WHITE}  | CLAUDE_API_KEY        | ${CYAN}(Your Claude API key)${NC}"
    fi
    echo -e "${WHITE}  +-----------------------+------------------------------------------+${NC}"
    echo ""

    # SSH Private Key
    if [ -n "$SSH_KEY_FILE" ] && [ -f "$SSH_KEY_FILE" ]; then
        echo -e "${WHITE}  Your SSH PRIVATE key (for SSH_PRIVATE_KEY secret):${NC}"
        echo -e "${YELLOW}  KEEP THIS SECRET! Only paste it in GitHub Secrets.${NC}"
        echo ""

        if ask_yes_no "Show SSH private key now?" "y"; then
            echo ""
            echo -e "${RED}  ========== BEGIN PRIVATE KEY ==========${NC}"
            cat "$SSH_KEY_FILE"
            echo -e "${RED}  =========== END PRIVATE KEY ===========${NC}"
            echo ""
            echo -e "${WHITE}  Copy everything above (including BEGIN and END lines)${NC}"
            echo -e "${WHITE}  and paste it as the value for SSH_PRIVATE_KEY secret.${NC}"
        fi
    else
        echo ""
        echo -e "${YELLOW}  No SSH key found. To generate one:${NC}"
        print_command "ssh-keygen -t ed25519 -f ~/.ssh/id_rsa_xclaude -N '' -C 'xclaude-deploy'"
        echo ""
        echo -e "${WHITE}  Then add the PUBLIC key to this server's ~/.ssh/authorized_keys${NC}"
        echo -e "${WHITE}  and the PRIVATE key to GitHub Secrets as SSH_PRIVATE_KEY${NC}"
    fi

    echo ""
    print_substep "Server SSH Setup"
    echo ""
    echo -e "${WHITE}  Make sure GitHub Actions can connect to your server:${NC}"
    echo ""

    # Check if SSH key is in authorized_keys
    if [ -n "$SSH_KEY_FILE" ] && [ -f "${SSH_KEY_FILE}.pub" ]; then
        local pubkey=$(cat "${SSH_KEY_FILE}.pub")
        if grep -q "$pubkey" ~/.ssh/authorized_keys 2>/dev/null; then
            print_success "SSH key is already in authorized_keys"
        else
            if ask_yes_no "Add SSH key to authorized_keys?" "y"; then
                cat "${SSH_KEY_FILE}.pub" >> ~/.ssh/authorized_keys
                chmod 600 ~/.ssh/authorized_keys
                print_success "SSH key added to authorized_keys"
            fi
        fi
    fi

    wait_for_enter
}

# ==============================================================================
# STEP 9: Test Installation
# ==============================================================================

step_test_installation() {
    print_step "8/9: Test Installation"

    echo -e "${WHITE}  Let's verify everything is working...${NC}"
    echo ""

    local all_ok=true

    # Test PHP syntax
    print_substep "Testing PHP syntax..."
    if php -l public/index.php > /dev/null 2>&1; then
        print_success "PHP syntax OK"
    else
        print_error "PHP syntax error in index.php"
        all_ok=false
    fi

    # Test .env file
    print_substep "Checking .env file..."
    if [ -f ".env" ]; then
        print_success ".env file exists"
    else
        print_error ".env file missing"
        all_ok=false
    fi

    # Test web server
    print_substep "Testing web access..."
    sleep 2

    local http_status=$(curl -s -o /dev/null -w "%{http_code}" "$SITE_URL" --max-time 10 2>/dev/null || echo "000")

    if [ "$http_status" -ge 200 ] && [ "$http_status" -lt 400 ]; then
        print_success "Website accessible (HTTP $http_status)"
    elif [ "$http_status" = "000" ]; then
        print_warning "Could not connect to $SITE_URL"
        echo -e "${CYAN}    Check your web server and firewall settings${NC}"
    else
        print_warning "Website returned HTTP $http_status"
    fi

    # Test API health endpoint
    print_substep "Testing API health..."
    local api_status=$(curl -s -o /dev/null -w "%{http_code}" "$SITE_URL/api/health" --max-time 10 2>/dev/null || echo "000")

    if [ "$api_status" -ge 200 ] && [ "$api_status" -lt 400 ]; then
        print_success "API health endpoint OK (HTTP $api_status)"
    else
        print_info "API health endpoint not responding (HTTP $api_status)"
    fi

    # Summary
    echo ""
    if [ "$all_ok" = true ]; then
        print_success "All basic tests passed!"
    else
        print_warning "Some tests failed. Please review the errors above."
    fi

    wait_for_enter
}

# ==============================================================================
# STEP 10: Final Summary
# ==============================================================================

step_final_summary() {
    print_step "9/9: Installation Complete!"

    echo -e "${GREEN}  ================================================================${NC}"
    echo -e "${GREEN}            Xclaude Framework Successfully Installed!${NC}"
    echo -e "${GREEN}  ================================================================${NC}"
    echo ""

    echo -e "${WHITE}  Installation Summary:${NC}"
    echo -e "${CYAN}    Path:        $INSTALL_DIR${NC}"
    echo -e "${CYAN}    URL:         $SITE_URL${NC}"
    echo -e "${CYAN}    Environment: $APP_ENV${NC}"
    echo -e "${CYAN}    Web Server:  $WEB_SERVER${NC}"
    echo ""

    echo -e "${WHITE}  Quick Links:${NC}"
    echo -e "${CYAN}    Website:     $SITE_URL${NC}"
    echo -e "${CYAN}    Health API:  $SITE_URL/api/health${NC}"
    echo -e "${CYAN}    GitHub:      https://github.com/${GITHUB_REPO}${NC}"
    echo ""

    echo -e "${WHITE}  What's Next?${NC}"
    echo ""
    echo -e "${CYAN}  1. Verify GitHub Secrets are configured:${NC}"
    echo -e "${WHITE}     https://github.com/${GITHUB_REPO}/settings/secrets/actions${NC}"
    echo ""
    echo -e "${CYAN}  2. Test auto-deploy by pushing a commit:${NC}"
    echo -e "${WHITE}     git add . && git commit -m 'test deploy' && git push${NC}"
    echo ""
    echo -e "${CYAN}  3. Use Claude to build your app:${NC}"
    echo -e "${WHITE}     Just tell Claude what you want, for example:${NC}"
    echo -e "${WHITE}     - 'Create a login page'${NC}"
    echo -e "${WHITE}     - 'Add a contact form'${NC}"
    echo -e "${WHITE}     - 'Fix the error on homepage'${NC}"
    echo ""

    echo -e "${WHITE}  Useful Commands:${NC}"
    echo -e "${CYAN}    View logs:    tail -f $INSTALL_DIR/storage/logs/deploy.log${NC}"
    echo -e "${CYAN}    Deploy:       cd $INSTALL_DIR && ./deploy.sh${NC}"
    echo -e "${CYAN}    Update:       cd $INSTALL_DIR && git pull${NC}"
    echo ""

    echo -e "${PURPLE}  ================================================================${NC}"
    echo -e "${PURPLE}    Happy coding with Xclaude Framework!${NC}"
    echo -e "${PURPLE}  ================================================================${NC}"
    echo ""

    # Create feedback file
    cat > .deploy-feedback.json << EOF
{
  "status": "installed",
  "version": "1.0.0",
  "timestamp": "$(date -Iseconds)",
  "install_path": "$INSTALL_DIR",
  "site_url": "$SITE_URL",
  "server_ip": "$SERVER_IP",
  "domain": "$DOMAIN",
  "web_server": "$WEB_SERVER",
  "configured": {
    "environment": true,
    "database": $( [ "$CONFIGURE_DB" = "yes" ] && echo "true" || echo "false" ),
    "line_oa": $( [ "$CONFIGURE_LINE" = "yes" ] && echo "true" || echo "false" ),
    "ssh_key": $( [ -n "$SSH_KEY_FILE" ] && echo "true" || echo "false" )
  }
}
EOF
}

# ==============================================================================
# Main
# ==============================================================================

main() {
    step_welcome
    step_check_requirements
    step_setup_ssh
    step_clone_repository
    step_configure_environment
    step_set_permissions
    step_configure_webserver
    step_setup_github_secrets
    step_test_installation
    step_final_summary
}

main "$@"
