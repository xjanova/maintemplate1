# GitHub Secrets Setup Guide

This guide explains how to configure GitHub Secrets for automatic deployment.

## Required Secrets

| Secret | Description | Required |
|--------|-------------|----------|
| `SSH_PRIVATE_KEY` | Private SSH key for server access | Yes |
| `SSH_KNOWN_HOSTS` | SSH fingerprint of your server | Yes |
| `SERVER_HOST` | Server IP address or hostname | Yes |
| `SERVER_USER` | SSH username for deployment | Yes |
| `DEPLOY_PATH` | Path to deploy on server | Yes |
| `SITE_URL` | Website URL for health checks | Yes |

## Step-by-Step Setup

### 1. Generate SSH Key (On Your Server)

```bash
# SSH into your server
ssh user@your-server.com

# Clone or copy the template
git clone https://github.com/YOUR_USERNAME/YOUR_REPO.git
cd YOUR_REPO

# Run the installation script
chmod +x install.sh
./install.sh
```

The script will:
- Generate an SSH deploy key
- Show you all the secrets you need
- Save configuration locally

### 2. Add Secrets to GitHub

1. Go to your repository on GitHub
2. Click **Settings** tab
3. In the left sidebar: **Secrets and variables** → **Actions**
4. Click **New repository secret**
5. Add each secret:

#### SSH_PRIVATE_KEY
```
-----BEGIN OPENSSH PRIVATE KEY-----
[Your private key content from install.sh]
-----END OPENSSH PRIVATE KEY-----
```

#### SSH_KNOWN_HOSTS
```
[SSH fingerprint from install.sh]
```

#### SERVER_HOST
```
your-server.com
# or IP address like: 192.168.1.100
```

#### SERVER_USER
```
ubuntu
# or your SSH username
```

#### DEPLOY_PATH
```
/var/www/your-project
# Full path to your project on the server
```

#### SITE_URL
```
https://your-site.com
# Your website URL for health checks
```

### 3. Verify Setup

1. Make a small change to your code
2. Commit and push to main:
   ```bash
   git add .
   git commit -m "chore: test deployment"
   git push origin main
   ```
3. Go to **Actions** tab in GitHub
4. Watch the deploy workflow run

## Troubleshooting

### "Permission denied (publickey)"

1. Verify SSH_PRIVATE_KEY is copied correctly
2. Check the public key is in server's `~/.ssh/authorized_keys`
3. Verify SSH_KNOWN_HOSTS matches your server

### "Host key verification failed"

Regenerate SSH_KNOWN_HOSTS:
```bash
ssh-keyscan -H your-server.com
```

### "No such file or directory"

1. Verify DEPLOY_PATH exists on server
2. Check SERVER_USER has write permissions

### "Connection timed out"

1. Check SERVER_HOST is correct
2. Verify server firewall allows SSH (port 22)
3. Check if server is online

## Security Notes

- Never share your SSH_PRIVATE_KEY
- Use dedicated deploy keys (not personal SSH keys)
- Rotate keys periodically
- Limit deploy user permissions on server

## Re-generating Secrets

If you need to regenerate secrets:

```bash
# On your server
cd /path/to/your/project
./install.sh
```

Then update the secrets in GitHub with the new values.
