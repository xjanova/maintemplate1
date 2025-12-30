#!/bin/bash

# TPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPW
# Q                    XCLAUDE FRAMEWORK - Installation Wizard                 Q
# Q                                                                           Q
# Q  One-liner install:                                                       Q
# Q  bash <(curl -sL https://raw.githubusercontent.com/xjanova/maintemplate1/main/scripts/install.sh)
# ZPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP]

set -e

# PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP
# Colors and Formatting
# PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

# Variables
REPO_URL="https://github.com/xjanova/maintemplate1.git"
INSTALL_DIR=""
WEB_SERVER=""
CONFIGURE_DEPLOY="no"
CONFIGURE_DB="no"
CONFIGURE_LINE="no"

# PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP
# Helper Functions
# PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP

print_banner() {
    clear
    echo -e "${CYAN}"
    cat << 'EOF'
TPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPW
Q   __  __    ___ _                 _        ___                            Q
Q   \ \/ /   / __| |__ _ _  _ ___ _| |___   | __| _ __ _ _ __  ___          Q
Q    >  <   | (__| / _` | || / _` | / -_)  | _| '_/ _` | '  \/ -_)         Q
Q   /_/\_\   \___|_\__,_|\_,_\__,_|_\___|  |_||_| \__,_|_|_|_\___|         Q
Q                                                                           Q
Q   Installation Wizard v1.0.0                                             Q
ZPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP]
EOF
    echo -e "${NC}"
}

print_step() {
    echo ""
    echo -e "${BLUE}${NC}"
    echo -e "${WHITE}  STEP $1: $2${NC}"
    echo -e "${BLUE}${NC}"
    echo ""
}

print_success() { echo -e "${GREEN} $1${NC}"; }
print_error()   { echo -e "${RED} $1${NC}"; }
print_warning() { echo -e "${YELLOW}  $1${NC}"; }
print_info()    { echo -e "${CYAN}9 $1${NC}"; }

ask_question() {
    local prompt="$1"
    local default="$2"
    local result=""

    if [ -n "$default" ]; then
        echo -e -n "${PURPLE}? ${WHITE}$prompt ${CYAN}[$default]${NC}: "
        read -r result
        echo "${result:-$default}"
    else
        echo -e -n "${PURPLE}? ${WHITE}$prompt${NC}: "
        read -r result
        echo "$result"
    fi
}

ask_yes_no() {
    local prompt="$1"
    local default="${2:-n}"
    local result=""

    if [ "$default" = "y" ]; then
        echo -e -n "${PURPLE}? ${WHITE}$prompt ${CYAN}[Y/n]${NC}: "
    else
        echo -e -n "${PURPLE}? ${WHITE}$prompt ${CYAN}[y/N]${NC}: "
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
    echo -e -n "${PURPLE}? ${WHITE}$prompt${NC}: "
    read -rs result
    echo ""
    echo "$result"
}

check_command() {
    command -v "$1" &> /dev/null
}

# PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP
# Step 1: Check Requirements
# PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP

step_check_requirements() {
    print_step "1/7" "Checking System Requirements"

    local missing_deps=()

    # PHP
    if check_command php; then
        local php_version=$(php -v | head -n1 | cut -d' ' -f2)
        print_success "PHP installed ($php_version)"
    else
        print_error "PHP not found"
        missing_deps+=("php8.2")
    fi

    # Git
    if check_command git; then
        print_success "Git installed"
    else
        print_error "Git not found"
        missing_deps+=("git")
    fi

    # curl
    if check_command curl; then
        print_success "curl installed"
    else
        print_error "curl not found"
        missing_deps+=("curl")
    fi

    # Web server
    if check_command nginx; then
        print_success "Nginx installed"
        WEB_SERVER="nginx"
    elif check_command apache2 || check_command httpd; then
        print_success "Apache installed"
        WEB_SERVER="apache"
    else
        print_warning "No web server detected"
        WEB_SERVER="none"
    fi

    # Optional: Node.js
    if check_command node; then
        print_success "Node.js installed (optional)"
    else
        print_info "Node.js not found (optional)"
    fi

    # Optional: Composer
    if check_command composer; then
        print_success "Composer installed (optional)"
    else
        print_info "Composer not found (optional)"
    fi

    if [ ${#missing_deps[@]} -gt 0 ]; then
        echo ""
        print_error "Missing: ${missing_deps[*]}"
        echo ""
        echo -e "${YELLOW}Install with:${NC}"
        echo -e "  ${CYAN}Ubuntu/Debian:${NC} sudo apt install ${missing_deps[*]}"
        echo ""

        if ! ask_yes_no "Continue anyway?" "n"; then
            exit 1
        fi
    fi

    print_success "Requirements check complete"
}

# PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP
# Step 2: Clone Repository
# PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP

step_clone_repository() {
    print_step "2/7" "Clone Repository"

    # Check if already in repo
    if [ -f "CLAUDE.md" ] && [ -d ".github" ]; then
        print_info "Already in Xclaude Framework directory"
        INSTALL_DIR=$(pwd)

        if ask_yes_no "Update existing installation?" "y"; then
            git pull origin main 2>/dev/null || true
            print_success "Updated"
        fi
        return 0
    fi

    # Ask for directory
    INSTALL_DIR=$(ask_question "Installation directory" "/var/www/xclaude-app")

    # Check if exists
    if [ -d "$INSTALL_DIR" ] && [ -f "$INSTALL_DIR/CLAUDE.md" ]; then
        print_info "Existing installation found"
        cd "$INSTALL_DIR"

        if ask_yes_no "Update existing installation?" "y"; then
            git pull origin main 2>/dev/null || true
        fi
        return 0
    fi

    # Clone
    print_info "Cloning repository..."
    mkdir -p "$INSTALL_DIR"
    git clone "$REPO_URL" "$INSTALL_DIR"
    cd "$INSTALL_DIR"

    print_success "Cloned to $INSTALL_DIR"
}

# PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP
# Step 3: Configure Environment
# PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP

step_configure_environment() {
    print_step "3/7" "Environment Configuration"

    # Generate secret
    SECRET_KEY=$(openssl rand -hex 32 2>/dev/null || head -c 64 /dev/urandom | base64 | tr -d '\n/' | head -c 64)

    echo -e "${WHITE}Application Settings:${NC}"
    echo ""

    APP_NAME=$(ask_question "App name" "My Xclaude App")
    APP_ENV=$(ask_question "Environment (development/production)" "production")

    [ "$APP_ENV" = "production" ] && APP_DEBUG="false" || APP_DEBUG="true"

    echo ""
    echo -e "${WHITE}URL Configuration:${NC}"
    echo ""

    SITE_URL=$(ask_question "Site URL (https://example.com)" "")

    [ -z "$SITE_URL" ] && print_warning "No SITE_URL - Claude can't verify deployments"

    # Auto-deploy
    echo ""
    if ask_yes_no "Configure auto-deploy from GitHub?" "n"; then
        SERVER_HOST=$(ask_question "Server IP/hostname" "")
        SERVER_USER=$(ask_question "SSH username" "root")
        DEPLOY_PATH=$(ask_question "Deploy path" "$INSTALL_DIR")
        CONFIGURE_DEPLOY="yes"
    else
        SERVER_HOST=""
        SERVER_USER=""
        DEPLOY_PATH="$INSTALL_DIR"
    fi

    # Database
    echo ""
    if ask_yes_no "Configure database?" "n"; then
        DB_HOST=$(ask_question "Database host" "localhost")
        DB_PORT=$(ask_question "Database port" "3306")
        DB_NAME=$(ask_question "Database name" "xclaude_app")
        DB_USER=$(ask_question "Database user" "root")
        DB_PASS=$(ask_password "Database password")
        CONFIGURE_DB="yes"
    else
        DB_HOST="localhost"
        DB_PORT="3306"
        DB_NAME="xclaude_app"
        DB_USER="root"
        DB_PASS=""
    fi

    # Line Notify
    echo ""
    if ask_yes_no "Configure Line notifications?" "n"; then
        LINE_CHANNEL_TOKEN=$(ask_question "Line Channel Token" "")
        LINE_NOTIFY_TOKEN=$(ask_question "Line Notify Token" "")
        CONFIGURE_LINE="yes"
    else
        LINE_CHANNEL_TOKEN=""
        LINE_NOTIFY_TOKEN=""
    fi

    # Create .env
    print_info "Creating .env file..."

    cat > .env << EOF
# TPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPW
# Q                    XCLAUDE FRAMEWORK - Environment                        Q
# Q                    Generated by install.sh                                Q
# ZPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP]

# App
APP_NAME="$APP_NAME"
APP_ENV=$APP_ENV
APP_DEBUG=$APP_DEBUG
APP_SECRET=$SECRET_KEY
APP_TIMEZONE=Asia/Bangkok

# URLs
SITE_URL=$SITE_URL
STAGING_URL=

# Server (auto-deploy)
SERVER_HOST=$SERVER_HOST
SERVER_USER=$SERVER_USER
DEPLOY_PATH=$DEPLOY_PATH

# Database
DB_HOST=$DB_HOST
DB_PORT=$DB_PORT
DB_NAME=$DB_NAME
DB_USER=$DB_USER
DB_PASS=$DB_PASS

# Line
LINE_CHANNEL_TOKEN=$LINE_CHANNEL_TOKEN
LINE_NOTIFY_TOKEN=$LINE_NOTIFY_TOKEN

# Security
ALLOWED_HOSTS=${SITE_URL#https://}
RATE_LIMIT=60
ERROR_THRESHOLD=3
EOF

    print_success ".env file created"
}

# PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP
# Step 4: Set Permissions
# PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP

step_set_permissions() {
    print_step "4/7" "Setting Permissions"

    # Create directories
    mkdir -p storage/logs storage/cache storage/uploads
    mkdir -p public/css public/js public/assets
    print_success "Created directories"

    # Set permissions
    chmod -R 755 .
    chmod -R 775 storage
    chmod +x deploy.sh 2>/dev/null || true
    chmod +x scripts/*.sh 2>/dev/null || true
    print_success "Set permissions"

    # Ownership
    if [ "$EUID" -eq 0 ]; then
        WEB_USER=$(ask_question "Web server user" "www-data")
        chown -R "$WEB_USER:$WEB_USER" storage
        print_success "Set ownership to $WEB_USER"
    fi
}

# PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP
# Step 5: Configure Web Server
# PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP

step_configure_webserver() {
    print_step "5/7" "Web Server Configuration"

    if [ "$WEB_SERVER" = "none" ]; then
        print_warning "No web server detected, skipping"
        return 0
    fi

    if ! ask_yes_no "Generate web server config?" "y"; then
        return 0
    fi

    # Get domain
    DOMAIN=$(echo "$SITE_URL" | sed -e 's|https\?://||' -e 's|/.*||')
    [ -z "$DOMAIN" ] && DOMAIN=$(ask_question "Domain name" "localhost")

    if [ "$WEB_SERVER" = "nginx" ]; then
        cat > /tmp/xclaude-nginx.conf << EOF
server {
    listen 80;
    server_name $DOMAIN www.$DOMAIN;
    root $INSTALL_DIR/public;
    index index.php index.html;

    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php8.2-fpm.sock;
        fastcgi_param SCRIPT_FILENAME \$realpath_root\$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\. { deny all; }
    location ~ ^/(storage|config)/ { deny all; }
}
EOF

        print_success "Nginx config generated: /tmp/xclaude-nginx.conf"
        echo ""
        echo -e "${WHITE}To install:${NC}"
        echo -e "  ${CYAN}sudo cp /tmp/xclaude-nginx.conf /etc/nginx/sites-available/$DOMAIN${NC}"
        echo -e "  ${CYAN}sudo ln -sf /etc/nginx/sites-available/$DOMAIN /etc/nginx/sites-enabled/${NC}"
        echo -e "  ${CYAN}sudo nginx -t && sudo systemctl reload nginx${NC}"

        if [ "$EUID" -eq 0 ] && ask_yes_no "Install nginx config now?" "y"; then
            cp /tmp/xclaude-nginx.conf "/etc/nginx/sites-available/$DOMAIN"
            ln -sf "/etc/nginx/sites-available/$DOMAIN" /etc/nginx/sites-enabled/
            nginx -t && systemctl reload nginx
            print_success "Nginx configured"
        fi

    elif [ "$WEB_SERVER" = "apache" ]; then
        cat > /tmp/xclaude-apache.conf << EOF
<VirtualHost *:80>
    ServerName $DOMAIN
    DocumentRoot $INSTALL_DIR/public

    <Directory $INSTALL_DIR/public>
        AllowOverride All
        Require all granted
    </Directory>

    <Directory $INSTALL_DIR/storage>
        Require all denied
    </Directory>
</VirtualHost>
EOF

        print_success "Apache config generated: /tmp/xclaude-apache.conf"
        echo ""
        echo -e "${WHITE}To install:${NC}"
        echo -e "  ${CYAN}sudo cp /tmp/xclaude-apache.conf /etc/apache2/sites-available/${DOMAIN}.conf${NC}"
        echo -e "  ${CYAN}sudo a2ensite ${DOMAIN}.conf && sudo systemctl reload apache2${NC}"
    fi
}

# PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP
# Step 6: GitHub Secrets Guide
# PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP

step_github_secrets() {
    print_step "6/7" "GitHub Secrets Configuration"

    if [ "$CONFIGURE_DEPLOY" != "yes" ]; then
        print_info "Auto-deploy not configured, skipping"
        return 0
    fi

    echo -e "${WHITE}Add these secrets to GitHub:${NC}"
    echo -e "${CYAN}https://github.com/xjanova/maintemplate1/settings/secrets/actions${NC}"
    echo ""
    echo -e "                  ,                                    "
    echo -e " ${CYAN}Secret Name${NC}       ${CYAN}Value${NC}                              "
    echo -e "                  <                                    $"
    echo -e " SSH_PRIVATE_KEY   Your SSH private key               "
    echo -e " SERVER_HOST       $SERVER_HOST"
    echo -e " SERVER_USER       $SERVER_USER"
    echo -e " DEPLOY_PATH       $DEPLOY_PATH"
    echo -e " SITE_URL          $SITE_URL"
    echo -e "                  4                                    "
    echo ""

    if ask_yes_no "Generate SSH key for deploy?" "n"; then
        local keyfile=~/.ssh/id_rsa_xclaude

        if [ ! -f "$keyfile" ]; then
            ssh-keygen -t rsa -b 4096 -f "$keyfile" -N "" -C "xclaude-deploy"
            print_success "SSH key generated"
        else
            print_info "Key already exists"
        fi

        echo ""
        echo -e "${WHITE}Public key (add to server's ~/.ssh/authorized_keys):${NC}"
        echo -e "${CYAN}"
        cat "${keyfile}.pub"
        echo -e "${NC}"

        echo -e "${WHITE}Private key (use as SSH_PRIVATE_KEY secret):${NC}"
        echo -e "${YELLOW}Run: cat ${keyfile}${NC}"
    fi
}

# PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP
# Step 7: Finalize
# PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP

step_finalize() {
    print_step "7/7" "Finalizing Installation"

    # Test PHP
    if check_command php; then
        php -l public/index.php > /dev/null 2>&1 && print_success "PHP syntax OK" || print_warning "PHP check failed"
    fi

    # Create feedback file
    cat > .deploy-feedback.json << EOF
{
  "status": "installed",
  "version": "1.0.0",
  "timestamp": "$(date -Iseconds)",
  "install_path": "$INSTALL_DIR",
  "site_url": "$SITE_URL",
  "configured": {
    "environment": true,
    "deploy": $( [ "$CONFIGURE_DEPLOY" = "yes" ] && echo "true" || echo "false" ),
    "database": $( [ "$CONFIGURE_DB" = "yes" ] && echo "true" || echo "false" ),
    "line_notify": $( [ "$CONFIGURE_LINE" = "yes" ] && echo "true" || echo "false" )
  }
}
EOF

    print_success "Installation complete!"
}

# PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP
# Summary
# PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP

show_summary() {
    echo ""
    echo -e "${GREEN}TPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPW${NC}"
    echo -e "${GREEN}Q                    Installation Complete!                                 Q${NC}"
    echo -e "${GREEN}ZPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP]${NC}"
    echo ""
    echo -e "${WHITE}Summary:${NC}"
    echo -e "  ${CYAN}Path:${NC}        $INSTALL_DIR"
    echo -e "  ${CYAN}URL:${NC}         ${SITE_URL:-Not configured}"
    echo -e "  ${CYAN}Environment:${NC} $APP_ENV"
    echo -e "  ${CYAN}Web Server:${NC}  $WEB_SERVER"
    echo ""

    if [ -n "$SITE_URL" ]; then
        echo -e "${WHITE}Test:${NC}"
        echo -e "  ${CYAN}curl $SITE_URL${NC}"
        echo -e "  ${CYAN}curl $SITE_URL/api/health${NC}"
        echo ""
    fi

    echo -e "${WHITE}Next Steps:${NC}"
    echo -e "  1. Configure web server (if not done)"
    echo -e "  2. Add GitHub Secrets for auto-deploy"
    echo -e "  3. Push a commit to test workflow"
    echo ""
    echo -e "${PURPLE}Happy coding with Xclaude! =€${NC}"
    echo ""
}

# PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP
# Main
# PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP

main() {
    print_banner

    echo -e "${WHITE}Welcome to Xclaude Framework Installation Wizard${NC}"
    echo ""

    if ! ask_yes_no "Ready to begin?" "y"; then
        echo "Installation cancelled."
        exit 0
    fi

    step_check_requirements
    step_clone_repository
    step_configure_environment
    step_set_permissions
    step_configure_webserver
    step_github_secrets
    step_finalize
    show_summary
}

main "$@"
