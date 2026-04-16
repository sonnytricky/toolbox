#!/bin/bash

set -e

#########################################
#
# Version 1.0.0
#
#########################################
#
# Copyright (c) 2026 sonnytricky
#
#########################################

# Variablen
username=""

echo "Wählen Sie den Installationsmodus:"
echo "1) Server"
echo "2) Desktop"
read -rp "Bitte geben Sie 1 oder 2 ein: " mode

if [[ "$mode" != "1" && "$mode" != "2" ]]; then
  echo "Ungültige Auswahl. Abbruch."
  exit 1
fi

echo "System wird aktualisiert..."
apt update && apt upgrade -y

echo "Benötigte Grundpakete werden installiert..."
apt install -y locales curl nano wget sudo gnupg lsb-release ca-certificates

# dpkg-reconfigure tzdata
DEBIAN_FRONTEND=noninteractive dpkg-reconfigure tzdata

dpkg-reconfigure --frontend=noninteractive locales
echo -e "LANG=de_DE.UTF-8\nLANGUAGE=\"de_DE:de\"" > /etc/default/locale
echo "de_DE.UTF-8 UTF-8" > /etc/locale.gen
locale-gen

add_user() {
  while true; do
    read -rp "Benutzernamen eingeben: " username
    if id "$username" &>/dev/null; then
      echo "Benutzer existiert bereits. Bitte anderen Namen wählen."
    else
      break
    fi
  done

  while true; do
    read -rsp "Passwort für Benutzer $username: " pass1; echo
    read -rsp "Passwort zur Verifizierung erneut eingeben: " pass2; echo
    if [[ "$pass1" == "$pass2" ]]; then
      break
    else
      echo "Passwörter stimmen nicht überein. Bitte erneut versuchen."
    fi
  done

  useradd -m -s /bin/bash "$username"
  echo "$username:$pass1" | chpasswd
  usermod -aG sudo "$username"
  echo "Benutzer $username wurde angelegt und zur sudo-Gruppe hinzugefügt."
}

read -rp "Möchten Sie einen neuen Benutzer anlegen? (y/n): " create_user
new_user_created=false
if [[ "$create_user" =~ ^[Yy]$ ]]; then
  add_user
  new_user_created=true
fi

# Je nach Modus verschiedene Pakete installieren
if [[ "$mode" == "1" ]]; then
  # Server Pakete
  SERVER_PACKAGES=(git htop curl wget openssh-server)

  echo "Server-Basis-Pakete werden installiert..."
  apt install -y "${SERVER_PACKAGES[@]}"

  # Optionale Firewall (ufw)
  read -rp "Möchten Sie die Firewall (ufw) installieren und aktivieren? (y/n): " install_ufw
  if [[ "$install_ufw" =~ ^[Yy]$ ]]; then
    apt install -y ufw
    ufw default deny incoming
    ufw default allow outgoing
    ufw allow ssh
    ufw --force enable
    echo "Firewall (ufw) wurde installiert und aktiviert."
  fi

  # Docker Installation optional
  read -rp "Möchten Sie Docker und Docker Compose installieren? (y/n): " install_docker
  if [[ "$install_docker" =~ ^[Yy]$ ]]; then
    curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
    apt purge -y docker docker.io containerd runc || true
    apt update
    apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

    if $new_user_created; then
      usermod -aG docker "$username"
    fi

    echo "Docker wurde installiert."

    # Optionale Portainer Installation
    read -rp "Möchten Sie Portainer zur Docker-Verwaltung installieren? (y/n): " install_portainer
    if [[ "$install_portainer" =~ ^[Yy]$ ]]; then
      mkdir -p /opt/portainer
      cat > /opt/portainer/docker-compose.yml <<EOF
services:
  portainer:
    image: portainer/portainer-ce
    container_name: portainer
    restart: always
    ports:
      - "9000:9000"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - portainer_data:/data

volumes:
  portainer_data:
EOF

      echo "Die compose.yml für Portainer wird nun mit nano geöffnet. Sie können sie bei Bedarf anpassen."
      nano /opt/portainer/docker-compose.yml

      echo "Starte Portainer mit docker compose..."
      docker compose -f /opt/portainer/docker-compose.yml up -d

      echo "Portainer wurde gestartet."
    fi

  else
    if $new_user_created; then
      read -rp "Möchten Sie das Root-Passwort sperren? (y/n): " lock_root
      if [[ "$lock_root" =~ ^[Yy]$ ]]; then
        passwd -l root
        echo "Root-Passwort wurde gesperrt."
      else
        echo "Root-Passwort bleibt aktiv."
      fi
    fi
  fi

elif [[ "$mode" == "2" ]]; then
  # Desktop Pakete
  DESKTOP_PACKAGES=(git htop curl wget okular kde-spectacle fish gparted ark cifs-utils gwenview cups bzip2 gzip tar unzip zip synaptic)

  echo "Desktop-Pakete werden installiert..."
  apt install -y "${DESKTOP_PACKAGES[@]}"
fi

echo "Installation abgeschlossen."
# Beenden oder Kärnel härten
echo "Beenden mit CTRL+C oder zusätzliche Sicherheitsmaßnahmen aktivieren?"
read -rp "(y/n): " security_choice
if [[ "$security_choice" =~ ^[Yy]$ ]]; then
  read -rp "Möchten Sie das System (sysctl) sicherheitsoptimieren? (y/n): " harden_sysctl
  if [[ "$harden_sysctl" =~ ^[Yy]$ ]]; then
    cat > /etc/sysctl.d/99-hardening.conf <<EOF
# IP Spoofing Schutz
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1

# IPv6 deaktivieren (optional)
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1

# SYN-Flood Schutz
net.ipv4.tcp_syncookies = 1

# ICMP Echo (Ping) abschalten (optional)
# net.ipv4.icmp_echo_ignore_all = 1

# Weiterleitung deaktivieren
net.ipv4.ip_forward = 0
net.ipv6.conf.all.forwarding = 0

# Kernel Core Dumps verhindern
fs.suid_dumpable = 0

# Zugriff auf dmesg einschränken
kernel.dmesg_restrict = 1
kernel.kptr_restrict = 2
EOF

    sysctl --system
    echo "Systemhärtung via sysctl wurde angewendet."
  fi
fi


