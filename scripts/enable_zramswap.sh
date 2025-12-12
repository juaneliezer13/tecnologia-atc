#!/bin/bash

# Este script instala y configura ZRAM (50% RAM, Prioridad 100) si no está activo.
# Antes de ejecutar: sudo chmod +x enable_zramswap.sh
# Ejecutar con sudo: sudo ./enable_zramswap.sh

function check_zram_status() {
    if swapon -s | grep -q 'zram'; then
        exit 0
    fi
}

function install_and_configure_zram() {
    sudo apt update > /dev/null 2>&1
    sudo apt install zram-tools -y > /dev/null 2>&1

    NUM_CPUS=$(nproc)

    sudo sed -i "s/#\?\(ZRAM_PERCENT=\).*/\150/" /etc/default/zramswap
    sudo sed -i "s/#\?\(PRIORITY=\).*/\1100/" /etc/default/zramswap
    sudo sed -i "s/#\?\(SWAP_DEVICES=\).*/\1$NUM_CPUS/" /etc/default/zramswap

    sudo systemctl enable zramswap.service > /dev/null 2>&1
    sudo systemctl start zramswap.service > /dev/null 2>&1
}

check_zram_status
install_and_configure_zram

# Verificar si ZRAM se activó correctamente     
if swapon -s | grep -q 'zram'; then
    echo "ZRAM swap habilitado correctamente."
else
    echo "Error: No se pudo habilitar ZRAM swap." >&2
    exit 1
fi