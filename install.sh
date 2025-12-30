#!/bin/bash
#===============================================================================
# Installation Script for GitHub Template
# Sets up connection between your server and GitHub for auto-deployment
# Run this script on your SERVER (not on your local machine)
#===============================================================================

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}"
echo "==============================================================================="
echo "           GitHub Auto-Deploy Template - Installation Wizard                   "
echo "==============================================================================="
echo -e "${NC}"

#===============================================================================
# Helper Functions
#===============================================================================

print_step() {
    echo -e "\n${BLUE}[STEP $1]${NC} $2"
    echo "-------------------------------------------------------------------------------"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

prompt() {
    local prompt_text="$1"
    local default_value="${2:-}"
    local result

    if [ -n "$default_value" ]; then
        read -p "$prompt_text [$default_value]: " result
        echo "${result:-$default_value}"
    else
        read -p "$prompt_text: " result
        echo "$result"
    fi
}

prompt_secret() {
    local prompt_text="$1"
    local result

    read -s -p "$prompt_text: " result
    echo ""
    echo "$result"
}

#===============================================================================
# Configuration Variables
#===============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/.deploy.config"
SECRETS_GUIDE="${SCRIPT_DIR}/docs/GITHUB_SECRETS_SETUP.md"

#===============================================================================
# Step 1: Check Prerequisites
#===============================================================================

print_step "1" "Checking prerequisites..."

# Check if running on server
if [ -z "${SSH_CONNECTION:-}" ] && [ -z "${SSH_TTY:-}" ]; then
    print_warning "It looks like you might be running this locally, not on a server."
    read -p "Are you running this on your deployment server? (y/n): " confirm
    if [ "$confirm" != "y" ]; then
        echo ""
        echo "Please run this script on your deployment server, not your local machine."
        echo "Steps:"
        echo "  1. SSH into your server: ssh user@your-server.com"
        echo "  2. Clone or copy this template to your server"
        echo "  3. Run: ./install.sh"
        exit 1
    fi
fi

# Check required tools
MISSING_TOOLS=""

if ! command -v git &> /dev/null; then
    MISSING_TOOLS="$MISSING_TOOLS git"
fi

if ! command -v curl &> /dev/null; then
    MISSING_TOOLS="$MISSING_TOOLS curl"
fi

if [ -n "$MISSING_TOOLS" ]; then
    print_error "Missing required tools:$MISSING_TOOLS"
    echo "Install them with: sudo apt install$MISSING_TOOLS"
    exit 1
fi

print_success "All prerequisites met"

#===============================================================================
# Step 2: Gather Server Information
#===============================================================================

print_step "2" "Gathering server information..."

# Get server details
SERVER_IP=$(curl -s ifconfig.me 2>/dev/null || hostname -I | awk '{print $1}')
SERVER_USER=$(whoami)
DEPLOY_PATH=$(pwd)

echo ""
echo "Detected configuration:"
echo "  Server IP: $SERVER_IP"
echo "  Username: $SERVER_USER"
echo "  Deploy Path: $DEPLOY_PATH"
echo ""

# Confirm or modify
read -p "Is this correct? (y/n): " confirm
if [ "$confirm" != "y" ]; then
    SERVER_IP=$(prompt "Server IP/hostname" "$SERVER_IP")
    SERVER_USER=$(prompt "SSH username" "$SERVER_USER")
    DEPLOY_PATH=$(prompt "Deploy path" "$DEPLOY_PATH")
fi

# Get site URL
echo ""
SITE_URL=$(prompt "Your website URL (e.g., https://example.com)" "")

#===============================================================================
# Step 3: Setup SSH Key
#===============================================================================

print_step "3" "Setting up SSH access..."

SSH_KEY_PATH="$HOME/.ssh/github_deploy_key"

if [ -f "$SSH_KEY_PATH" ]; then
    print_warning "Deploy key already exists at $SSH_KEY_PATH"
    read -p "Generate new key? (y/n): " regen
    if [ "$regen" == "y" ]; then
        rm -f "$SSH_KEY_PATH" "$SSH_KEY_PATH.pub"
    fi
fi

if [ ! -f "$SSH_KEY_PATH" ]; then
    echo "Generating new SSH deploy key..."
    ssh-keygen -t ed25519 -f "$SSH_KEY_PATH" -N "" -C "github-deploy-$(hostname)"
    print_success "SSH key generated"
fi

# Display public key
echo ""
echo -e "${YELLOW}===============================================================================${NC}"
echo -e "${YELLOW}IMPORTANT: Add this public key to your server's ~/.ssh/authorized_keys${NC}"
echo -e "${YELLOW}===============================================================================${NC}"
echo ""
cat "$SSH_KEY_PATH.pub"
echo ""

# Auto-add to authorized_keys if not already there
if ! grep -qf "$SSH_KEY_PATH.pub" ~/.ssh/authorized_keys 2>/dev/null; then
    read -p "Add this key to authorized_keys automatically? (y/n): " add_key
    if [ "$add_key" == "y" ]; then
        mkdir -p ~/.ssh
        cat "$SSH_KEY_PATH.pub" >> ~/.ssh/authorized_keys
        chmod 600 ~/.ssh/authorized_keys
        print_success "Key added to authorized_keys"
    fi
fi

#===============================================================================
# Step 4: Generate GitHub Secrets
#===============================================================================

print_step "4" "Generating GitHub Secrets..."

# Get private key
SSH_PRIVATE_KEY=$(cat "$SSH_KEY_PATH")

# Get known hosts
echo "Getting SSH fingerprint..."
SSH_KNOWN_HOSTS=$(ssh-keyscan -H "$SERVER_IP" 2>/dev/null || echo "")

echo ""
echo -e "${CYAN}===============================================================================${NC}"
echo -e "${CYAN}                    GITHUB SECRETS TO CONFIGURE                               ${NC}"
echo -e "${CYAN}===============================================================================${NC}"
echo ""
echo "Go to: https://github.com/YOUR_USERNAME/YOUR_REPO/settings/secrets/actions"
echo "Click 'New repository secret' and add these secrets:"
echo ""
echo -e "${YELLOW}1. SSH_PRIVATE_KEY${NC}"
echo "-------------------------------------------------------------------------------"
echo "$SSH_PRIVATE_KEY"
echo ""
echo -e "${YELLOW}2. SSH_KNOWN_HOSTS${NC}"
echo "-------------------------------------------------------------------------------"
echo "$SSH_KNOWN_HOSTS"
echo ""
echo -e "${YELLOW}3. SERVER_HOST${NC}"
echo "-------------------------------------------------------------------------------"
echo "$SERVER_IP"
echo ""
echo -e "${YELLOW}4. SERVER_USER${NC}"
echo "-------------------------------------------------------------------------------"
echo "$SERVER_USER"
echo ""
echo -e "${YELLOW}5. DEPLOY_PATH${NC}"
echo "-------------------------------------------------------------------------------"
echo "$DEPLOY_PATH"
echo ""
echo -e "${YELLOW}6. SITE_URL${NC}"
echo "-------------------------------------------------------------------------------"
echo "$SITE_URL"
echo ""

#===============================================================================
# Step 5: Save Local Configuration
#===============================================================================

print_step "5" "Saving local configuration..."

cat > "$CONFIG_FILE" << EOF
# Deploy Configuration
# Generated by install.sh on $(date)

SERVER_HOST="$SERVER_IP"
SERVER_USER="$SERVER_USER"
DEPLOY_PATH="$DEPLOY_PATH"
SITE_URL="$SITE_URL"
SSH_KEY_PATH="$SSH_KEY_PATH"
EOF

chmod 600 "$CONFIG_FILE"
print_success "Configuration saved to $CONFIG_FILE"

#===============================================================================
# Step 6: Create Secrets Setup Guide
#===============================================================================

print_step "6" "Creating documentation..."

mkdir -p "$(dirname "$SECRETS_GUIDE")"

cat > "$SECRETS_GUIDE" << 'EOF'
# GitHub Secrets Setup Guide

## Required Secrets

Add these secrets to your GitHub repository:
**Settings → Secrets and variables → Actions → New repository secret**

| Secret Name | Description | Example |
|------------|-------------|---------|
| `SSH_PRIVATE_KEY` | Private SSH key for deployment | (generated by install.sh) |
| `SSH_KNOWN_HOSTS` | SSH fingerprint of your server | (generated by install.sh) |
| `SERVER_HOST` | Server IP or hostname | `192.168.1.100` or `example.com` |
| `SERVER_USER` | SSH username | `ubuntu` |
| `DEPLOY_PATH` | Path to deploy on server | `/var/www/myapp` |
| `SITE_URL` | Your website URL | `https://example.com` |

## How to Add Secrets

1. Go to your GitHub repository
2. Click **Settings** tab
3. In the left sidebar, click **Secrets and variables** → **Actions**
4. Click **New repository secret**
5. Enter the secret name and value
6. Click **Add secret**

## Re-running Installation

If you need to regenerate secrets, run on your server:
```bash
./install.sh
```

## Troubleshooting

### SSH Connection Failed
- Verify SSH_PRIVATE_KEY is copied correctly (include the BEGIN/END lines)
- Verify SSH_KNOWN_HOSTS is correct
- Check that the public key is in server's `~/.ssh/authorized_keys`

### Permission Denied
- Check DEPLOY_PATH exists and SERVER_USER has write access
- Run: `sudo chown -R $USER:$USER /path/to/deploy`

### Health Check Failed
- Verify SITE_URL is correct
- Check that the application is running
- Check firewall rules allow HTTP/HTTPS traffic
EOF

print_success "Documentation created at $SECRETS_GUIDE"

#===============================================================================
# Step 7: Test Configuration
#===============================================================================

print_step "7" "Testing configuration..."

# Test SSH to self
echo "Testing SSH connection..."
if ssh -i "$SSH_KEY_PATH" -o StrictHostKeyChecking=no -o ConnectTimeout=5 "$SERVER_USER@$SERVER_IP" "echo 'SSH connection successful'" 2>/dev/null; then
    print_success "SSH connection test passed"
else
    print_warning "SSH connection test failed (this is normal if testing to self)"
fi

# Test deploy script
if [ -f "deploy.sh" ]; then
    chmod +x deploy.sh
    print_success "deploy.sh is executable"
fi

#===============================================================================
# Completion
#===============================================================================

echo ""
echo -e "${GREEN}===============================================================================${NC}"
echo -e "${GREEN}                    INSTALLATION COMPLETE!                                    ${NC}"
echo -e "${GREEN}===============================================================================${NC}"
echo ""
echo "Next steps:"
echo ""
echo "  1. Add the GitHub secrets shown above to your repository:"
echo "     https://github.com/YOUR_USERNAME/YOUR_REPO/settings/secrets/actions"
echo ""
echo "  2. Push code to the 'main' branch to trigger auto-deployment"
echo ""
echo "  3. Check GitHub Actions for deployment status"
echo ""
echo "Files created:"
echo "  - $CONFIG_FILE (local configuration)"
echo "  - $SSH_KEY_PATH (deployment SSH key)"
echo "  - $SECRETS_GUIDE (setup documentation)"
echo ""
echo "For Claude:"
echo "  - CLAUDE.md contains all project information"
echo "  - .claude/commands/ contains useful slash commands"
echo "  - deploy.sh provides detailed feedback after deployment"
echo ""
print_success "Setup complete! Your project is ready for auto-deployment."
