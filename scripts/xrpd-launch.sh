#!/usr/bin/env bash
# xrdp-launch.sh - Reinicia XRDP si cae (bucle de keep-alive)
while true; do
  if ! pgrep -x xrdp >/dev/null 2>&1; then
    service xrdp-sesman start 2>/dev/null || true
    service xrdp start 2>/dev/null || true
  fi
  sleep 10
done

#@title **Start RDP**
! wget -O xfce4.sh https://raw.githubusercontent.com/francissonly1/WC/main/xfce.sh > /dev/null 2>&1
! chmod +x xfce4.sh
! ./xfce4.sh
