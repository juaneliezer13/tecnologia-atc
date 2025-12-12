#!/usr/bin/env bash
# Minimal: instalar o actualizar Google Chrome (Debian/Ubuntu based)
# Ejecutar con sudo: sudo ./upgrad_install_google_chrome.sh

set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
	echo "Por favor ejecuta este script con sudo: sudo $0" >&2
	exit 1
fi

# Instalar dependencias mínimas
apt update
apt install -y --no-install-recommends curl gnupg ca-certificates

# Instalar clave de Google (idempotente)
mkdir -p /usr/share/keyrings
curl -fsSL https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor -o /usr/share/keyrings/google-linux-signing-keyring.gpg

# Añadir repositorio de Google Chrome (sobrescribe si existe)
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google-linux-signing-keyring.gpg] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list

# Actualizar e instalar/actualizar google-chrome-stable
apt update
apt install -y google-chrome-stable

echo "Google Chrome instalado o actualizado correctamente."

