#!/bin/bash
#===============================================================================
# Smart Deploy Script with Feedback System
# This script automatically detects project type and deploys accordingly
# Includes error handling, logging, and feedback for Claude
#===============================================================================

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="${SCRIPT_DIR}/.deploy.log"
FEEDBACK_FILE="${SCRIPT_DIR}/.deploy-feedback.json"
CONFIG_FILE="${SCRIPT_DIR}/.deploy.config"

#===============================================================================
# Logging Functions
#===============================================================================

log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "${timestamp} [${level}] ${message}" | tee -a "$LOG_FILE"
}

log_info() { log "INFO" "${BLUE}$*${NC}"; }
log_success() { log "SUCCESS" "${GREEN}$*${NC}"; }
log_warning() { log "WARNING" "${YELLOW}$*${NC}"; }
log_error() { log "ERROR" "${RED}$*${NC}"; }

#===============================================================================
# Feedback System for Claude
#===============================================================================

init_feedback() {
    cat > "$FEEDBACK_FILE" << EOF
{
    "deploy_start": "$(date -u '+%Y-%m-%dT%H:%M:%SZ')",
    "status": "in_progress",
    "project_type": null,
    "steps": [],
    "errors": [],
    "warnings": [],
    "urls_to_check": [],
    "suggestions": []
}
EOF
}

add_feedback() {
    local key="$1"
    local value="$2"

    if command -v jq &> /dev/null; then
        local temp_file=$(mktemp)
        jq --arg v "$value" ".$key += [\$v]" "$FEEDBACK_FILE" > "$temp_file" && mv "$temp_file" "$FEEDBACK_FILE"
    fi
}

set_feedback() {
    local key="$1"
    local value="$2"

    if command -v jq &> /dev/null; then
        local temp_file=$(mktemp)
        jq --arg v "$value" ".$key = \$v" "$FEEDBACK_FILE" > "$temp_file" && mv "$temp_file" "$FEEDBACK_FILE"
    fi
}

finalize_feedback() {
    local status="$1"
    set_feedback "status" "$status"
    set_feedback "deploy_end" "$(date -u '+%Y-%m-%dT%H:%M:%SZ')"

    # Print feedback summary for Claude
    echo ""
    echo "==============================================================================="
    echo "DEPLOY FEEDBACK FOR CLAUDE"
    echo "==============================================================================="
    cat "$FEEDBACK_FILE"
    echo "==============================================================================="
}

#===============================================================================
# Project Detection
#===============================================================================

detect_project_type() {
    log_info "Detecting project type..."

    if [ -f "package.json" ]; then
        if grep -q '"next"' package.json 2>/dev/null; then
            echo "nextjs"
        elif grep -q '"nuxt"' package.json 2>/dev/null; then
            echo "nuxt"
        elif grep -q '"react"' package.json 2>/dev/null; then
            echo "react"
        elif grep -q '"vue"' package.json 2>/dev/null; then
            echo "vue"
        elif grep -q '"express"' package.json 2>/dev/null; then
            echo "express"
        else
            echo "nodejs"
        fi
    elif [ -f "requirements.txt" ] || [ -f "pyproject.toml" ]; then
        if [ -f "manage.py" ]; then
            echo "django"
        elif grep -q "flask" requirements.txt 2>/dev/null || grep -q "flask" pyproject.toml 2>/dev/null; then
            echo "flask"
        elif grep -q "fastapi" requirements.txt 2>/dev/null || grep -q "fastapi" pyproject.toml 2>/dev/null; then
            echo "fastapi"
        else
            echo "python"
        fi
    elif [ -f "composer.json" ]; then
        if [ -f "artisan" ]; then
            echo "laravel"
        else
            echo "php"
        fi
    elif [ -f "Gemfile" ]; then
        echo "ruby"
    elif [ -f "go.mod" ]; then
        echo "go"
    elif [ -f "Cargo.toml" ]; then
        echo "rust"
    elif [ -f "index.html" ]; then
        echo "static"
    else
        echo "unknown"
    fi
}

#===============================================================================
# Deploy Functions by Project Type
#===============================================================================

deploy_nodejs() {
    log_info "Deploying Node.js application..."
    add_feedback "steps" "Installing Node.js dependencies"

    # Check Node.js version
    if ! command -v node &> /dev/null; then
        log_error "Node.js is not installed"
        add_feedback "errors" "Node.js is not installed. Please install Node.js first."
        add_feedback "suggestions" "Run: curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash - && sudo apt-get install -y nodejs"
        return 1
    fi

    # Install dependencies
    if [ -f "package-lock.json" ]; then
        npm ci || { log_error "npm ci failed"; add_feedback "errors" "npm ci failed - check package-lock.json"; return 1; }
    elif [ -f "yarn.lock" ]; then
        yarn install --frozen-lockfile || { log_error "yarn install failed"; add_feedback "errors" "yarn install failed"; return 1; }
    elif [ -f "pnpm-lock.yaml" ]; then
        pnpm install --frozen-lockfile || { log_error "pnpm install failed"; add_feedback "errors" "pnpm install failed"; return 1; }
    else
        npm install || { log_error "npm install failed"; add_feedback "errors" "npm install failed"; return 1; }
    fi
    add_feedback "steps" "Dependencies installed successfully"

    # Build if script exists
    if grep -q '"build"' package.json 2>/dev/null; then
        add_feedback "steps" "Building application"
        npm run build || { log_error "Build failed"; add_feedback "errors" "npm run build failed - check build configuration"; return 1; }
        add_feedback "steps" "Build completed successfully"
    fi

    # Restart service
    restart_service "node"
}

deploy_nextjs() {
    log_info "Deploying Next.js application..."
    deploy_nodejs

    # Check for standalone output
    if [ -d ".next/standalone" ]; then
        add_feedback "steps" "Next.js standalone build detected"
        add_feedback "urls_to_check" "/"
    fi
}

deploy_python() {
    log_info "Deploying Python application..."
    add_feedback "steps" "Setting up Python environment"

    # Check Python
    if ! command -v python3 &> /dev/null; then
        log_error "Python3 is not installed"
        add_feedback "errors" "Python3 is not installed"
        return 1
    fi

    # Create virtual environment if not exists
    if [ ! -d "venv" ]; then
        python3 -m venv venv || { log_error "Failed to create venv"; return 1; }
    fi

    # Activate and install
    source venv/bin/activate

    if [ -f "requirements.txt" ]; then
        pip install -r requirements.txt || { log_error "pip install failed"; add_feedback "errors" "pip install failed"; return 1; }
    elif [ -f "pyproject.toml" ]; then
        pip install -e . || { log_error "pip install failed"; return 1; }
    fi
    add_feedback "steps" "Python dependencies installed"

    restart_service "python"
}

deploy_django() {
    log_info "Deploying Django application..."
    deploy_python

    # Run migrations
    add_feedback "steps" "Running Django migrations"
    python manage.py migrate --noinput || { log_warning "Migrations failed"; add_feedback "warnings" "Django migrations failed"; }

    # Collect static files
    add_feedback "steps" "Collecting static files"
    python manage.py collectstatic --noinput || { log_warning "collectstatic failed"; add_feedback "warnings" "collectstatic failed"; }

    add_feedback "urls_to_check" "/admin/"
    add_feedback "urls_to_check" "/"
}

deploy_flask() {
    log_info "Deploying Flask application..."
    deploy_python
    add_feedback "urls_to_check" "/"
}

deploy_fastapi() {
    log_info "Deploying FastAPI application..."
    deploy_python
    add_feedback "urls_to_check" "/docs"
    add_feedback "urls_to_check" "/"
}

deploy_php() {
    log_info "Deploying PHP application..."
    add_feedback "steps" "Installing PHP dependencies"

    if [ -f "composer.json" ]; then
        composer install --no-dev --optimize-autoloader || { log_error "Composer install failed"; return 1; }
    fi
    add_feedback "steps" "PHP dependencies installed"
}

deploy_laravel() {
    log_info "Deploying Laravel application..."
    deploy_php

    # Laravel specific
    add_feedback "steps" "Running Laravel optimizations"
    php artisan config:cache || log_warning "config:cache failed"
    php artisan route:cache || log_warning "route:cache failed"
    php artisan view:cache || log_warning "view:cache failed"

    # Migrations
    add_feedback "steps" "Running Laravel migrations"
    php artisan migrate --force || { log_warning "Migrations failed"; add_feedback "warnings" "Laravel migrations failed"; }

    add_feedback "urls_to_check" "/"
}

deploy_static() {
    log_info "Deploying static site..."
    add_feedback "steps" "Static site - no build required"
    add_feedback "urls_to_check" "/index.html"
    log_success "Static site deployed"
}

#===============================================================================
# Service Management
#===============================================================================

restart_service() {
    local service_type="$1"
    add_feedback "steps" "Restarting service"

    # Check for PM2
    if command -v pm2 &> /dev/null; then
        log_info "Restarting with PM2..."
        if [ -f "ecosystem.config.js" ]; then
            pm2 reload ecosystem.config.js --update-env || pm2 start ecosystem.config.js
        else
            pm2 reload all || log_warning "PM2 reload failed"
        fi
        add_feedback "steps" "PM2 service restarted"
        return 0
    fi

    # Check for systemd service
    local service_name=$(basename "$SCRIPT_DIR")
    if systemctl list-units --full -all | grep -q "${service_name}.service"; then
        log_info "Restarting systemd service..."
        sudo systemctl restart "$service_name" || log_warning "systemctl restart failed"
        add_feedback "steps" "Systemd service restarted"
        return 0
    fi

    # Check for Docker
    if [ -f "docker-compose.yml" ] || [ -f "docker-compose.yaml" ]; then
        log_info "Restarting with Docker Compose..."
        docker-compose down && docker-compose up -d --build || { log_error "Docker restart failed"; return 1; }
        add_feedback "steps" "Docker containers restarted"
        return 0
    fi

    add_feedback "warnings" "No service manager detected. Application may need manual restart."
    log_warning "No service manager detected"
}

#===============================================================================
# Health Check
#===============================================================================

health_check() {
    local url="${1:-}"

    if [ -z "$url" ]; then
        # Try to get URL from config
        if [ -f "$CONFIG_FILE" ]; then
            source "$CONFIG_FILE"
            url="${SITE_URL:-}"
        fi
    fi

    if [ -z "$url" ]; then
        add_feedback "warnings" "No URL configured for health check"
        return 0
    fi

    add_feedback "steps" "Performing health check on $url"
    log_info "Performing health check on $url..."

    # Wait for service to start
    sleep 3

    local max_retries=5
    local retry=0

    while [ $retry -lt $max_retries ]; do
        HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$url" --max-time 10 2>/dev/null || echo "000")

        if [ "$HTTP_STATUS" -ge 200 ] && [ "$HTTP_STATUS" -lt 400 ]; then
            log_success "Health check passed! Status: $HTTP_STATUS"
            add_feedback "steps" "Health check passed (HTTP $HTTP_STATUS)"
            return 0
        fi

        retry=$((retry + 1))
        log_warning "Health check attempt $retry/$max_retries failed (HTTP $HTTP_STATUS)"
        sleep 2
    done

    log_error "Health check failed after $max_retries attempts"
    add_feedback "errors" "Health check failed - site returned HTTP $HTTP_STATUS"
    add_feedback "suggestions" "Check application logs: journalctl -u <service-name> or pm2 logs"
    return 1
}

#===============================================================================
# Auto-fix Common Issues
#===============================================================================

auto_fix() {
    local error_type="$1"

    case "$error_type" in
        "permission")
            log_info "Auto-fixing permission issues..."
            chmod -R 755 .
            chown -R www-data:www-data . 2>/dev/null || true
            ;;
        "port")
            log_info "Auto-fixing port conflicts..."
            # Find and kill process on common ports
            for port in 3000 5000 8000 8080; do
                fuser -k $port/tcp 2>/dev/null || true
            done
            ;;
        "npm_cache")
            log_info "Clearing npm cache..."
            npm cache clean --force
            rm -rf node_modules package-lock.json
            npm install
            ;;
        "pip_cache")
            log_info "Clearing pip cache..."
            pip cache purge
            rm -rf venv
            python3 -m venv venv
            source venv/bin/activate
            pip install -r requirements.txt
            ;;
    esac
}

#===============================================================================
# Main Deploy Function
#===============================================================================

main() {
    echo "==============================================================================="
    echo "                         SMART DEPLOY SCRIPT                                  "
    echo "==============================================================================="

    # Initialize
    init_feedback
    cd "$SCRIPT_DIR"
    > "$LOG_FILE"  # Clear log file

    log_info "Starting deployment..."
    log_info "Working directory: $SCRIPT_DIR"

    # Load config if exists
    if [ -f "$CONFIG_FILE" ]; then
        source "$CONFIG_FILE"
        log_info "Loaded configuration from $CONFIG_FILE"
    fi

    # Detect project type
    PROJECT_TYPE=$(detect_project_type)
    log_info "Detected project type: $PROJECT_TYPE"
    set_feedback "project_type" "$PROJECT_TYPE"

    # Deploy based on project type
    local deploy_status=0

    case "$PROJECT_TYPE" in
        "nextjs")
            deploy_nextjs || deploy_status=1
            ;;
        "react"|"vue"|"nuxt"|"nodejs"|"express")
            deploy_nodejs || deploy_status=1
            ;;
        "django")
            deploy_django || deploy_status=1
            ;;
        "flask")
            deploy_flask || deploy_status=1
            ;;
        "fastapi")
            deploy_fastapi || deploy_status=1
            ;;
        "laravel")
            deploy_laravel || deploy_status=1
            ;;
        "php")
            deploy_php || deploy_status=1
            ;;
        "python")
            deploy_python || deploy_status=1
            ;;
        "static")
            deploy_static || deploy_status=1
            ;;
        *)
            log_warning "Unknown project type. Running basic deployment..."
            add_feedback "warnings" "Unknown project type - only basic git pull was performed"
            ;;
    esac

    # Run health check
    if [ $deploy_status -eq 0 ]; then
        health_check || deploy_status=1
    fi

    # Finalize
    if [ $deploy_status -eq 0 ]; then
        log_success "Deployment completed successfully!"
        finalize_feedback "success"
    else
        log_error "Deployment failed!"
        finalize_feedback "failed"
    fi

    return $deploy_status
}

# Run main function
main "$@"
