# 🛠️ Setup-Skript für Debian/Ubuntu-basierte Systeme

Dieses Bash-Skript automatisiert die Grundinstallation und Konfiguration eines Linux-Systems und unterstützt dabei sowohl **Server-** als auch **Desktop-Installationen**.

---

## 📦 Funktionen

### 🔧 Allgemein

* Systemupdate (`apt update && upgrade`)
* Zeitzonen- und Locale-Konfiguration (de\_DE.UTF-8)
* Benutzeranlage mit Passwortprüfung und sudo-Rechten
* Grundpakete: `curl`, `wget`, `sudo`, `nano`, `gnupg`, `ca-certificates`, `lsb-release`

---

## Verwendung:

1. Skript herunterladen
```bash
wget https://raw.githubusercontent.com/sonnytricky/toolbox/refs/heads/dev/scripts/Universal-script/universal-install.sh
```

2. Skript ausführen:
```bash
bash universal-install.sh
```

---

### 💻 Desktop-Modus

Installiert zusätzliche Desktop-Programme:

* `git`, `htop`, `curl`, `wget`
* `okular`, `spektacle`, `gwenview` (Bild-/PDF-Anzeige & Screenshot)
* `fish` (alternativer Shell)
* `gparted` (Partitionierung)
* `ark`, `zip`, `tar`, `gzip`, `bzip2`, `unzip` (Archivtools)
* `cifs-utils` (Windows-Freigaben)
* `cups` (Drucker)
* `synaptic` (Paketverwaltung GUI)

---

### 🌐 Server-Modus

Installiert minimale Serverpakete:

* `git`, `htop`, `curl`, `wget`, `ssh`

Optional:

* **UFW (Firewall):** mit sicheren Grundeinstellungen (SSH erlaubt)
* **Docker & Docker Compose**
* **Portainer (Docker GUI-Verwaltung)** via `docker-compose.yml` + `nano` Bearbeitung

---

### 🔐 Sicherheitsfeatures (Optional)

Nach der Installation können zusätzliche Sicherheitsmaßnahmen aktiviert werden:

* Kernel-Härtung via `sysctl` (z. B. ICMP blockieren, IPv6 deaktivieren, IP-Spoofing-Schutz)
* Root-Login sperren (wenn neuer Benutzer angelegt wurde)

---

## ▶️ Verwendung

1. Skript als Root oder mit `sudo` ausführen:

   ```bash
   sudo bash dein-skript.sh
   ```

2. Wähle den Installationsmodus:
   `1 = Server`, `2 = Desktop`

3. Folge den interaktiven Fragen:

   * Benutzer anlegen?
   * Docker & Portainer installieren?
   * Firewall aktivieren?
   * Kernel härten?

---

## ⚠️ Voraussetzungen

* Debian/Ubuntu oder kompatibles System
* Internetverbindung
* Root-Rechte

---

## 📂 Dateien

Falls Portainer installiert wird, wird folgendes angelegt:

```bash
/opt/portainer/docker-compose.yml
```

Du kannst es direkt mit `nano` bearbeiten, bevor der Container gestartet wird.

---

## 🧪 Test

Empfohlen wird die Ausführung zuerst in einer **virtuellen Maschine (VM)** oder **Testumgebung**, da das Skript Änderungen am System vornimmt.

---

## 📌 Hinweise

* Alle Aktionen im Skript sind interaktiv und können übersprungen werden.
* `set -e` sorgt dafür, dass das Skript bei Fehlern abbricht.
* Die Systemhärtung verwendet `/etc/sysctl.d/99-hardening.conf`.

---