#!/usr/bin/env bash
# inicio.sh — Solo actualización del sistema (Linux Mint / apt)
# Ejecutar con sudo: `sudo ./inicio.sh` o como root.

set -euo pipefail

check_apt_locks() {
	# Comprueba si hay locks de apt/dpkg activos
	if sudo fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1 || sudo fuser /var/lib/dpkg/lock >/dev/null 2>&1 || sudo fuser /var/lib/apt/lists/lock >/dev/null 2>&1; then
		echo "Error: hay otro proceso usando apt/dpkg. Espera a que termine o elimina el proceso." >&2
		ps aux | egrep "apt|dpkg" | egrep -v "egrep|ps aux" || true
		exit 1
	fi
}

fix_dpkg_if_needed() {
	echo "Comprobando estado de dpkg..."
	# `dpkg --audit` devuelve 0 cuando no hay problemas
	if ! sudo dpkg --audit >/dev/null 2>&1; then
		echo "Se detectaron paquetes en estado inconsistente. Ejecutando 'sudo dpkg --configure -a'..."
		if sudo dpkg --configure -a; then
			echo "dpkg configurado correctamente."
		else
			echo "'dpkg --configure -a' falló. Intentando 'sudo apt --fix-broken install -y'..."
			if sudo apt --fix-broken install -y; then
				echo "Dependencias rotas reparadas con éxito."
			else
				echo "No se pudo reparar dpkg/dependencias automáticamente. Revisa manualmente." >&2
				exit 1
			fi
		fi
	else
		echo "dpkg OK."
	fi
}

echo "Preparando verificación de dpkg/locks..."
check_apt_locks
fix_dpkg_if_needed

echo "Actualizando listas de paquetes..."
sudo apt update

echo "Aplicando actualizaciones de paquetes..."
sudo apt upgrade -y

echo "Realizando actualización completa (paquetes retenidos)..."
sudo apt full-upgrade -y

echo "Limpiando paquetes no necesarios..."
sudo apt autoremove --purge -y
sudo apt autoclean

echo "Actualización completada."