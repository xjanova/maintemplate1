#!/bin/bash
#===============================================================================
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║                    XCLAUDE FRAMEWORK - Smart Deploy                       ║
# ║                                                                           ║
# ║  สคริปต์ Deploy อัจฉริยะพร้อมระบบ Feedback สำหรับ Claude                     ║
# ║  Smart deployment script with feedback system for Claude                  ║
# ╚═══════════════════════════════════════════════════════════════════════════╝
#===============================================================================

set -euo pipefail

# ═══════════════════════════════════════════════════════════════════════════
# Configuration
# ═══════════════════════════════════════════════════════════════════════════

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="${SCRIPT_DIR}/storage/logs/deploy.log"
FEEDBACK_FILE="${SCRIPT_DIR}/.deploy-feedback.json"
ENV_FILE="${SCRIPT_DIR}/.env"
ERROR_COUNT_FILE="${SCRIPT_DIR}/storage/cache/.error_count"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# ═══════════════════════════════════════════════════════════════════════════
# Load Environment
# ═══════════════════════════════════════════════════════════════════════════

load_env() {
    if [ -f "$ENV_FILE" ]; then
        export $(grep -v '^#' "$ENV_FILE" | xargs)
    fi
}

# ═══════════════════════════════════════════════════════════════════════════
# Logging Functions
# ═══════════════════════════════════════════════════════════════════════════

log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    # Ensure log directory exists
    mkdir -p "$(dirname "$LOG_FILE")"

    echo -e "${timestamp} [${level}] ${message}" | tee -a "$LOG_FILE"
}

log_info()    { log "INFO" "${BLUE}$*${NC}"; }
log_success() { log "SUCCESS" "${GREEN}✓ $*${NC}"; }
log_warning() { log "WARNING" "${YELLOW}⚠ $*${NC}"; }
log_error()   { log "ERROR" "${RED}✗ $*${NC}"; }

# ═══════════════════════════════════════════════════════════════════════════
# Line OA Notification
# ═══════════════════════════════════════════════════════════════════════════

send_line_notify() {
    local message="$1"
    local token="${LINE_NOTIFY_TOKEN:-}"

    if [ -z "$token" ]; then
        log_warning "LINE_NOTIFY_TOKEN not set, skipping notification"
        return 0
    fi

    curl -s -X POST \
        -H "Authorization: Bearer $token" \
        -F "message=$message" \
        https://notify-api.line.me/api/notify > /dev/null 2>&1

    if [ $? -eq 0 ]; then
        log_info "Line notification sent"
    else
        log_warning "Failed to send Line notification"
    fi
}

# ═══════════════════════════════════════════════════════════════════════════
# Error Tracking for Human Escalation
# ═══════════════════════════════════════════════════════════════════════════

increment_error_count() {
    mkdir -p "$(dirname "$ERROR_COUNT_FILE")"

    if [ -f "$ERROR_COUNT_FILE" ]; then
        count=$(cat "$ERROR_COUNT_FILE")
        count=$((count + 1))
    else
        count=1
    fi

    echo "$count" > "$ERROR_COUNT_FILE"
    echo "$count"
}

reset_error_count() {
    echo "0" > "$ERROR_COUNT_FILE"
}

check_error_threshold() {
    local threshold="${ERROR_THRESHOLD:-3}"

    if [ -f "$ERROR_COUNT_FILE" ]; then
        local count=$(cat "$ERROR_COUNT_FILE")
        if [ "$count" -ge "$threshold" ]; then
            return 0  # Threshold exceeded
        fi
    fi
    return 1  # Threshold not exceeded
}

# ═══════════════════════════════════════════════════════════════════════════
# Feedback System for Claude
# ═══════════════════════════════════════════════════════════════════════════

init_feedback() {
    local version=$(git describe --tags --abbrev=0 2>/dev/null || echo "v0.0.0")

    cat > "$FEEDBACK_FILE" << EOF
{
    "framework": "Xclaude Framework",
    "version": "$version",
    "deploy_start": "$(date -u '+%Y-%m-%dT%H:%M:%SZ')",
    "status": "in_progress",
    "project_type": null,
    "site_url": "${SITE_URL:-}",
    "steps_completed": [],
    "errors": [],
    "warnings": [],
    "urls_to_check": [],
    "suggestions": [],
    "line_notified": false
}
EOF
}

add_to_feedback() {
    local key="$1"
    local value="$2"

    if command -v jq &> /dev/null; then
        local temp=$(mktemp)
        jq --arg v "$value" ".$key += [\$v]" "$FEEDBACK_FILE" > "$temp" && mv "$temp" "$FEEDBACK_FILE"
    fi
}

set_feedback() {
    local key="$1"
    local value="$2"

    if command -v jq &> /dev/null; then
        local temp=$(mktemp)
        jq --arg v "$value" ".$key = \$v" "$FEEDBACK_FILE" > "$temp" && mv "$temp" "$FEEDBACK_FILE"
    fi
}

finalize_feedback() {
    local status="$1"
    local line_notified="$2"

    set_feedback "status" "$status"
    set_feedback "deploy_end" "$(date -u '+%Y-%m-%dT%H:%M:%SZ')"

    if [ "$line_notified" = "true" ]; then
        if command -v jq &> /dev/null; then
            local temp=$(mktemp)
            jq '.line_notified = true' "$FEEDBACK_FILE" > "$temp" && mv "$temp" "$FEEDBACK_FILE"
        fi
    fi

    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}                    DEPLOY FEEDBACK FOR CLAUDE                             ${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════════════════${NC}"
    cat "$FEEDBACK_FILE"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════════════════${NC}"
}

# ═══════════════════════════════════════════════════════════════════════════
# Project Detection (Enhanced for Xclaude)
# ═══════════════════════════════════════════════════════════════════════════

detect_project_type() {
    log_info "ตรวจจับประเภทโปรเจค..."

    # Check for Xclaude PHP project first
    if [ -f "public/index.php" ] && [ -f ".xclaude/config.yml" ]; then
        echo "xclaude-php"
        return
    fi

    # Standard PHP
    if [ -f "public/index.php" ] || [ -f "index.php" ]; then
        if [ -f "artisan" ]; then
            echo "laravel"
        elif [ -f "composer.json" ]; then
            echo "php"
        else
            echo "php-simple"
        fi
        return
    fi

    # Node.js projects
    if [ -f "package.json" ]; then
        if grep -q '"next"' package.json 2>/dev/null; then
            echo "nextjs"
        elif grep -q '"nuxt"' package.json 2>/dev/null; then
            echo "nuxt"
        elif grep -q '"react"' package.json 2>/dev/null; then
            echo "react"
        elif grep -q '"vue"' package.json 2>/dev/null; then
            echo "vue"
        else
            echo "nodejs"
        fi
        return
    fi

    # Python projects
    if [ -f "requirements.txt" ] || [ -f "pyproject.toml" ]; then
        if [ -f "manage.py" ]; then
            echo "django"
        elif grep -q "flask" requirements.txt 2>/dev/null; then
            echo "flask"
        elif grep -q "fastapi" requirements.txt 2>/dev/null; then
            echo "fastapi"
        else
            echo "python"
        fi
        return
    fi

    # Static site
    if [ -f "index.html" ]; then
        echo "static"
        return
    fi

    echo "unknown"
}

# ═══════════════════════════════════════════════════════════════════════════
# Deploy Functions
# ═══════════════════════════════════════════════════════════════════════════

deploy_xclaude_php() {
    log_info "กำลัง Deploy Xclaude PHP Framework..."
    add_to_feedback "steps_completed" "เริ่มต้น deploy Xclaude PHP"

    # Check PHP version
    if ! command -v php &> /dev/null; then
        log_error "PHP ไม่ได้ติดตั้ง"
        add_to_feedback "errors" "PHP is not installed"
        add_to_feedback "suggestions" "Install PHP 8.2+: sudo apt install php8.2 php8.2-cli php8.2-fpm"
        return 1
    fi

    local php_version=$(php -v | head -n 1 | cut -d " " -f 2 | cut -d "." -f 1-2)
    log_info "PHP version: $php_version"
    add_to_feedback "steps_completed" "ตรวจสอบ PHP version: $php_version"

    # Install composer dependencies if composer.json exists
    if [ -f "composer.json" ]; then
        log_info "Installing composer dependencies..."
        if command -v composer &> /dev/null; then
            composer install --no-dev --optimize-autoloader 2>&1 || {
                log_error "Composer install failed"
                add_to_feedback "errors" "composer install failed"
                return 1
            }
            add_to_feedback "steps_completed" "ติดตั้ง composer dependencies"
        else
            log_warning "Composer not installed, skipping"
            add_to_feedback "warnings" "Composer not installed"
        fi
    fi

    # Build frontend assets if package.json exists
    if [ -f "package.json" ]; then
        log_info "Building frontend assets..."
        if command -v npm &> /dev/null; then
            npm install 2>&1 || log_warning "npm install failed"
            if grep -q '"build"' package.json 2>/dev/null; then
                npm run build 2>&1 || log_warning "npm build failed"
            fi
            add_to_feedback "steps_completed" "Build frontend assets"
        fi
    fi

    # Set permissions
    log_info "Setting permissions..."
    chmod -R 755 public/ 2>/dev/null || true
    chmod -R 775 storage/ 2>/dev/null || true
    add_to_feedback "steps_completed" "ตั้งค่า permissions"

    # Clear cache
    if [ -d "storage/cache" ]; then
        rm -rf storage/cache/* 2>/dev/null || true
        add_to_feedback "steps_completed" "ล้าง cache"
    fi

    # Add URLs to check
    add_to_feedback "urls_to_check" "/"
    add_to_feedback "urls_to_check" "/api/health"

    log_success "Xclaude PHP deployed successfully"
    return 0
}

deploy_php() {
    log_info "กำลัง Deploy PHP application..."
    add_to_feedback "steps_completed" "เริ่มต้น deploy PHP"

    if [ -f "composer.json" ] && command -v composer &> /dev/null; then
        composer install --no-dev --optimize-autoloader 2>&1 || {
            log_error "Composer install failed"
            add_to_feedback "errors" "composer install failed"
            return 1
        }
        add_to_feedback "steps_completed" "ติดตั้ง composer dependencies"
    fi

    chmod -R 755 . 2>/dev/null || true
    add_to_feedback "urls_to_check" "/"

    log_success "PHP deployed successfully"
    return 0
}

deploy_nodejs() {
    log_info "กำลัง Deploy Node.js application..."
    add_to_feedback "steps_completed" "เริ่มต้น deploy Node.js"

    if ! command -v node &> /dev/null; then
        log_error "Node.js ไม่ได้ติดตั้ง"
        add_to_feedback "errors" "Node.js is not installed"
        add_to_feedback "suggestions" "Install Node.js: curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash - && sudo apt-get install -y nodejs"
        return 1
    fi

    # Install dependencies
    if [ -f "package-lock.json" ]; then
        npm ci 2>&1 || npm install 2>&1 || {
            log_error "npm install failed"
            add_to_feedback "errors" "npm install failed"
            return 1
        }
    else
        npm install 2>&1 || {
            log_error "npm install failed"
            add_to_feedback "errors" "npm install failed"
            return 1
        }
    fi
    add_to_feedback "steps_completed" "ติดตั้ง npm dependencies"

    # Build
    if grep -q '"build"' package.json 2>/dev/null; then
        npm run build 2>&1 || {
            log_error "npm build failed"
            add_to_feedback "errors" "npm run build failed"
            return 1
        }
        add_to_feedback "steps_completed" "Build สำเร็จ"
    fi

    # Restart with PM2 if available
    if command -v pm2 &> /dev/null; then
        pm2 reload all 2>/dev/null || pm2 start npm --name "app" -- start 2>/dev/null || true
        add_to_feedback "steps_completed" "Restart PM2"
    fi

    add_to_feedback "urls_to_check" "/"
    log_success "Node.js deployed successfully"
    return 0
}

deploy_static() {
    log_info "กำลัง Deploy static site..."
    add_to_feedback "steps_completed" "Static site - ไม่ต้อง build"
    add_to_feedback "urls_to_check" "/"
    add_to_feedback "urls_to_check" "/index.html"
    log_success "Static site deployed"
    return 0
}

# ═══════════════════════════════════════════════════════════════════════════
# Health Check
# ═══════════════════════════════════════════════════════════════════════════

health_check() {
    local url="${SITE_URL:-}"

    if [ -z "$url" ]; then
        log_warning "SITE_URL not configured, skipping health check"
        add_to_feedback "warnings" "SITE_URL not configured for health check"
        return 0
    fi

    log_info "กำลังตรวจสอบสุขภาพเว็บไซต์: $url"
    add_to_feedback "steps_completed" "เริ่ม health check"

    sleep 3  # Wait for service to start

    local max_retries=5
    local retry=0

    while [ $retry -lt $max_retries ]; do
        local status=$(curl -s -o /dev/null -w "%{http_code}" "$url" --max-time 10 2>/dev/null || echo "000")

        if [ "$status" -ge 200 ] && [ "$status" -lt 400 ]; then
            log_success "Health check passed! HTTP $status"
            add_to_feedback "steps_completed" "Health check passed (HTTP $status)"
            return 0
        fi

        retry=$((retry + 1))
        log_warning "Health check attempt $retry/$max_retries failed (HTTP $status)"
        sleep 2
    done

    log_error "Health check failed after $max_retries attempts"
    add_to_feedback "errors" "Health check failed - site returned HTTP $status"
    add_to_feedback "suggestions" "Check web server logs (nginx/apache)"
    add_to_feedback "suggestions" "Verify PHP is running correctly"
    return 1
}

# ═══════════════════════════════════════════════════════════════════════════
# Main Function
# ═══════════════════════════════════════════════════════════════════════════

main() {
    echo ""
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║               XCLAUDE FRAMEWORK - Smart Deploy Script                    ║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""

    # Initialize
    cd "$SCRIPT_DIR"
    load_env
    init_feedback

    # Clear old log
    mkdir -p "$(dirname "$LOG_FILE")"
    > "$LOG_FILE"

    log_info "เริ่มต้น deployment..."
    log_info "Working directory: $SCRIPT_DIR"

    # Detect and deploy
    local project_type=$(detect_project_type)
    log_info "ประเภทโปรเจค: $project_type"
    set_feedback "project_type" "$project_type"

    local deploy_status=0
    local line_notified="false"

    case "$project_type" in
        "xclaude-php")
            deploy_xclaude_php || deploy_status=1
            ;;
        "php"|"php-simple")
            deploy_php || deploy_status=1
            ;;
        "laravel")
            deploy_php || deploy_status=1
            ;;
        "nodejs"|"nextjs"|"react"|"vue"|"nuxt")
            deploy_nodejs || deploy_status=1
            ;;
        "static")
            deploy_static || deploy_status=1
            ;;
        *)
            log_warning "Unknown project type, performing basic deployment"
            add_to_feedback "warnings" "Unknown project type"
            ;;
    esac

    # Health check
    if [ $deploy_status -eq 0 ]; then
        health_check || deploy_status=1
    fi

    # Handle result
    if [ $deploy_status -eq 0 ]; then
        reset_error_count
        log_success "Deployment สำเร็จ!"

        # Send success notification
        if [ -n "${LINE_NOTIFY_TOKEN:-}" ]; then
            send_line_notify "✅ Deploy สำเร็จ!
🌐 URL: ${SITE_URL:-N/A}
📦 Version: $(git describe --tags --abbrev=0 2>/dev/null || echo 'N/A')
⏰ Time: $(date '+%Y-%m-%d %H:%M:%S')"
            line_notified="true"
        fi

        finalize_feedback "success" "$line_notified"
    else
        local error_count=$(increment_error_count)
        log_error "Deployment ล้มเหลว! (Error count: $error_count)"

        # Check if should escalate to human
        if check_error_threshold; then
            log_error "Error threshold exceeded! แจ้งเตือนให้มนุษย์ตรวจสอบ"
            add_to_feedback "errors" "ERROR THRESHOLD EXCEEDED - Human intervention required"

            if [ -n "${LINE_NOTIFY_TOKEN:-}" ]; then
                send_line_notify "🚨 ALERT: Deploy ล้มเหลวต่อเนื่อง!

❌ Error Count: $error_count
📍 Project: $(basename "$SCRIPT_DIR")
⏰ Time: $(date '+%Y-%m-%d %H:%M:%S')

⚠️ ต้องการให้มนุษย์เข้ามาตรวจสอบ
ดู logs: storage/logs/deploy.log"
                line_notified="true"
            fi
        else
            # Just send failure notification
            if [ -n "${LINE_NOTIFY_TOKEN:-}" ]; then
                send_line_notify "❌ Deploy ล้มเหลว (ครั้งที่ $error_count)
📍 Project: $(basename "$SCRIPT_DIR")
Claude กำลังพยายามแก้ไข..."
                line_notified="true"
            fi
        fi

        finalize_feedback "failed" "$line_notified"
    fi

    return $deploy_status
}

# Run
main "$@"
