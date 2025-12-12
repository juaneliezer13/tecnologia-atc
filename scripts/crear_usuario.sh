#!/bin/bash
# crear_usuario.sh — Crear usuario según tipo (ve|ce)
# Antes de ejecutar, dar permisos de ejecución: chmod +x crear_usuario.sh
# Ejecutar con sudo: sudo ./crear_usuario.sh -t ve|ce

set -euo pipefail
if [ "$(id -u)" -ne 0 ]; then
    echo "Ejecuta: sudo $0 -t <ve|ce>" >&2
    exit 1
fi
if [ "$#" -lt 2 ]; then
    echo "Uso: $0 -t|--tipo [ve|ce]" >&2
    exit 1
fi
TIPO=""
while [ $# -gt 0 ]; do
    case "$1" in
        -t|--tipo)
            TIPO="$2"
            shift 2
            ;;
        *)
            echo "Argumento desconocido: $1" >&2
            exit 1
            ;;
    esac
done
if [ -z "$TIPO" ]; then
    echo "Falta --tipo/-t" >&2
    exit 1
fi
case "$TIPO" in
    ve)
        DISPLAY_NAME="Venezuela"
        PASSWORD="Vzla2023*"
        ;;
    ce)
        DISPLAY_NAME="Cuentas Externas"
        PASSWORD="CtaExt2023*"
        ;;
    *)
        echo "Valor inválido para --tipo: $TIPO (usar ve o ce)" >&2
        exit 1
        ;;
esac
UNAME=$(echo "$DISPLAY_NAME" | tr '[:upper:]' '[:lower:]' | tr -s ' ' '_' | tr -cd '[:alnum:]_-')
if id -u "$UNAME" >/dev/null 2>&1; then
    echo "El usuario $UNAME ya existe. Actualizando contraseña..."
    echo "$UNAME:$PASSWORD" | chpasswd
    echo "Contraseña actualizada para $UNAME"
else
    useradd -m -s /bin/bash -c "$DISPLAY_NAME" "$UNAME"
    echo "$UNAME:$PASSWORD" | chpasswd
    deluser "$UNAME" sudo 2>/dev/null || true
    echo "Usuario $UNAME creado con contraseña asignada."
fi
groups "$UNAME" || true

echo "Operación completada."