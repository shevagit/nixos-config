# Kaleipo Server Configuration

This NixOS configuration replicates your Debian 12 cloud server setup for the kaleipo server.

## Overview

This configuration includes:
- **nginx** - Web server with rate limiting and SSL
- **Docker** - Container platform
- **fail2ban** - Intrusion prevention
- **Tailscale** - VPN networking
- **ACME/SSL** - Certificate management
- **SSH** - Remote access (key-based only)
- **UFW-equivalent** - Firewall via NixOS firewall

## Installation

### 1. Install NixOS on the kaleipo server

Boot from NixOS installer and partition your disk:

```bash
# Example for UEFI system with a single disk
sudo fdisk /dev/sda  # or nvme0n1, etc.

# Create partitions:
# - /dev/sda1: 512MB EFI (type: EFI System)
# - /dev/sda2: Rest for root (type: Linux filesystem)

# Format partitions
sudo mkfs.fat -F 32 /dev/sda1
sudo mkfs.ext4 /dev/sda2

# Mount
sudo mount /dev/sda2 /mnt
sudo mkdir -p /mnt/boot
sudo mount /dev/sda1 /mnt/boot

# Generate hardware config
sudo nixos-generate-config --root /mnt

# The generated /mnt/etc/nixos/hardware-configuration.nix
# will be copied to replace the placeholder later
```

### 2. Clone your nixos-config repository

```bash
# On the installer
cd /mnt/home
git clone https://github.com/yourusername/nixos-config.git
cd nixos-config

# Copy the generated hardware configuration
sudo cp /mnt/etc/nixos/hardware-configuration.nix ./hosts/kaleipo/hardware-configuration.nix
```

### 3. Configure your setup

Edit `hosts/kaleipo/configuration.nix`:

```nix
# Add your SSH public key
users.users.sheva.openssh.authorizedKeys.keys = [
  "ssh-ed25519 AAAAC3... your-key-here"
];

# Configure static IP if needed
networking.interfaces.eth0.ipv4.addresses = [{
  address = "192.168.1.100";
  prefixLength = 24;
}];
networking.defaultGateway = "192.168.1.1";
networking.nameservers = [ "1.1.1.1" "8.8.8.8" ];
```

### 4. Install NixOS

```bash
# Install
sudo nixos-install --flake .#kaleipo

# Set root password when prompted
# Reboot
sudo reboot
```

### 5. Post-installation configuration

After first boot, log in and configure services:

#### Tailscale
```bash
sudo tailscale up --accept-routes
```

#### ACME/SSL Certificates

If using Cloudflare DNS for wildcard certificates:

1. Create secrets file:
```bash
sudo mkdir -p /run/secrets
sudo nano /run/secrets/cloudflare-api
```

Add:
```
CF_API_KEY=your-cloudflare-api-key
CF_EMAIL=your-email@example.com
```

2. Uncomment the ACME configuration in `configuration.nix`:
```nix
security.acme.certs."xamal.eu" = {
  domain = "*.xamal.eu";
  extraDomainNames = [ "xamal.eu" ];
  dnsProvider = "cloudflare";
  environmentFile = "/run/secrets/cloudflare-api";
  group = "nginx";
};
```

3. Rebuild:
```bash
sudo nixos-rebuild switch --flake /home/sheva/nixos-config#kaleipo
```

#### Nginx Virtual Hosts

Edit `configuration.nix` to add your services:

```nix
services.nginx.virtualHosts."app.xamal.eu" = {
  enableACME = true;
  forceSSL = true;
  locations."/" = {
    proxyPass = "http://localhost:8080";
    proxyWebsockets = true;
    extraConfig = ''
      limit_req zone=mylimit burst=10 nodelay;
    '';
  };
};
```

Then rebuild:
```bash
sudo nixos-rebuild switch --flake /home/sheva/nixos-config#kaleipo
```

## Updating the System

```bash
cd /home/sheva/nixos-config

# Update flake inputs
nix flake update

# Rebuild and switch
sudo nixos-rebuild switch --flake .#kaleipo
```

## Comparison with Ansible Setup

Both the Ansible playbooks (in `hq/ansible/`) and this NixOS configuration achieve the same server setup:

| Component | Ansible Role | NixOS Module |
|-----------|--------------|--------------|
| Base system | `base` | `modules/server/base.nix` |
| Docker | `docker` | `modules/common/docker.nix` |
| Nginx | `nginx` | `modules/server/nginx.nix` |
| fail2ban | `fail2ban` | `modules/server/fail2ban.nix` |
| Tailscale | `tailscale` | `modules/common/tailscale.nix` |
| ACME/SSL | `acme` | `modules/server/acme.nix` |
| Firewall | `ufw` | NixOS firewall (built-in) |

**Key differences:**
- Ansible manages Debian/Ubuntu systems imperatively
- NixOS is declarative and fully reproducible
- NixOS handles rollbacks automatically
- Ansible requires manual state management

## Migrating from Cloud Server

To migrate your existing services from the Debian cloud server:

1. **Backup data** from cloud server:
   ```bash
   # On cloud server
   sudo tar czf /tmp/docker-volumes.tar.gz /var/lib/docker/volumes/
   sudo tar czf /tmp/nginx-sites.tar.gz /etc/nginx/sites-enabled/
   ```

2. **Copy to kaleipo**:
   ```bash
   scp cloud-server:/tmp/*.tar.gz kaleipo:/tmp/
   ```

3. **Restore on kaleipo** and configure NixOS accordingly

4. **Test thoroughly** before switching DNS

5. **Update DNS** to point to kaleipo IP

## Services Reference

### fail2ban Status
```bash
sudo fail2ban-client status
sudo fail2ban-client status sshd
sudo fail2ban-client status nginx-http-auth
```

### Nginx
```bash
sudo systemctl status nginx
sudo nginx -t  # Test configuration
journalctl -u nginx -f  # Follow logs
```

### Docker
```bash
docker ps
docker compose up -d
```

### Tailscale
```bash
sudo tailscale status
sudo tailscale netcheck
```

## Troubleshooting

### Build the configuration without switching
```bash
sudo nixos-rebuild build --flake .#kaleipo
```

### Check what would change
```bash
sudo nixos-rebuild dry-activate --flake .#kaleipo
```

### Rollback to previous generation
```bash
sudo nixos-rebuild switch --rollback
```

### View system generations
```bash
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system
```

## Security Notes

- SSH is configured for key-based authentication only
- Root login is disabled
- fail2ban protects SSH and nginx
- Firewall allows only necessary ports (22, 80, 443, Tailscale)
- Automatic security updates are enabled
- Trusted IP (94.131.138.55) is whitelisted in fail2ban

## Support

For issues or questions:
- NixOS manual: https://nixos.org/manual/nixos/stable/
- NixOS options: https://search.nixos.org/options
- Ansible playbooks: See `hq/ansible/` directory
