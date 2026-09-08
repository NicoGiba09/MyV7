#!/usr/bin/env bash

# setup_xrdp.sh - Versión corregida y compatible con Google Colab (sin systemctl).

# Uso: bash setup_xrdp.sh  <CONTRASEÑA> 

set -uo pipefail

USERNAME="${1:-admin}"
PASSWORD="${2:-admin}"
RESOLUTION="${3:-1850x720}"

export DEBIAN_FRONTEND=noninteractive

echo "📦 [1/6] Actualizando apt..."
apt-get update -y || { echo "❌ apt-get update falló"; exit 1; }

echo "🖥️ [2/6] Instalando KDE Plasma, Xorg y dependencias..."
apt-get install -y 

kde-plasma-desktop xorg x11-xserver-utils xauth dbus-x11 

openssl ca-certificates curl wget 

libx11-6 libxrandr2 libxinerama1 libxcursor1 libxi6 libxtst6 

|| { echo "❌ fallo al instalar el escritorio"; exit 1; }

echo "🔌 [3/6] Instalando XRDP..."
apt-get install -y xrdp xorgxrdp || { echo "❌ fallo al instalar XRDP"; exit 1; }

echo "👤 [4/6] Creando usuario '$USERNAME'..."
id "$USERNAME" >/dev/null 2>&1 \vert{}\vert{} useradd -m -s /bin/bash "$USERNAME" || { echo "❌ no se pudo crear el usuario"; exit 1; }
echo "$USERNAME:$PASSWORD" | chpasswd || { echo "❌ no se pudo fijar la contraseña"; exit 1; }
usermod -aG sudo,audio,video,render,input "$USERNAME" 2>/dev/null || true

echo "⚙️ [5/6] Configurando XRDP para KDE Plasma..."
echo "startplasma-x11" > "/home/$USERNAME/.xsession"
chown "$USERNAME:$USERNAME" "/home/$USERNAME/.xsession"

mkdir -p /etc/xrdp
cat > /etc/xrdp/sesman.ini <<EOF AllowRootLogin="true" DefaultWindowManager="startwm.sh" EOF EnableUserWindowManager="true" ListenAddress="127.0.0.1" ListenPort="3350" MaxLoginRetry="4" TerminalServerAdmins="tsadmins" TerminalServerUsers="tsusers" UserWindowManager="startwm.sh" [Globals] [Security] cat> /etc/xrdp/xrdp.ini <<EOF EOF TLSv1.3 [Globals] bitmap_cache="yes" bitmap_compression="yes" cat certificate="key_file=" channel_code="1" crypt_level="high" fork="yes" ini_version="1" max_bpp="32" port="3389" security_layer="tls" ssl_protocols="TLSv1.2," tcp_keepalive="yes" tcp_nodelay="yes"> /etc/xrdp/startwm.sh <<EOF #!/bin/bash +x -rf /etc/xrdp/startwm.sh /tmp/.X10-lock /tmp/.X11-unix/X10 2 DESKTOP_SESSION="plasma" DISPLAY=":10" EOF XDG_CURRENT_DESKTOP="KDE" XDG_SESSION_TYPE="x11" chmod dbus-launch exec export rm startplasma-x11>/dev/null || true

echo "🚀 [6/6] Iniciando servicios XRDP (Modo Colab)..."
pkill -f xrdp || true
pkill -f sesman || true
sleep 1

# Inicialización directa para evitar fallos de systemd en contenedores

xrdp-sesman
xrdp

sleep 3

echo ""
echo "=="
echo "✅ XRDP + KDE Plasma listos"
echo "   Puerto RDP   : 3389"
echo "   Usuario      : $USERNAME"
echo "   Contraseña   : $PASSWORD"
echo "=="
echo ""
echo "📱 Conéctate com qualquer cliente RDP:"
echo "   - Microsoft Remote Desktop (Android/Windows)"
echo "   - aRDP (Android)"
echo "   - Remmina (Linux)"
echo ""
echo "   Servidor: :3389"
echo "========================================"
