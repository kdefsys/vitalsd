#!/bin/bash
#-------------------------------------------------------------------------------------
# Autor: kdefsys
# Proyecto: vitalsd
# Descripción: Ciclo principal del demonio y gestión de señales
#-------------------------------------------------------------------------------------

# 1. Configuración por defecto (Por si acaso no existieran los archivos)
INTERVALO_REVISION=3
UMBRAL_CPU=80
UMBRAL_RAM=85

# 2. Búsqueda inteligente del archivo de configuración
if [[ -f "/etc/vitalsd/vitalsd.conf" ]]; then
    CONFIG_FILE="/etc/vitalsd/vitalsd.conf"
    source "$CONFIG_FILE"
else
    DIR_ACTUAL=$(dirname "$(readlink -f "$0")")
    CONFIG_FILE="${DIR_ACTUAL}/../config/vitalsd.conf"
    if [ -f "$CONFIG_FILE" ]; then
        source "$CONFIG_FILE"
    fi
fi

# 3. Detección inteligente de la ruta del Log (Evita errores de permisos en desarrollo)
if [ -d "/var/log" ] && [ -w "/var/log" ]; then
    ARCHIVO_LOG="/var/log/vitalsd.log"
else
    ARCHIVO_LOG="vitalsd.log"
fi

# Definimos la ruta de nuestro archivo temporal usando el PID ($$) del script
TMP_CPU_FILE="/tmp/vitalsd_cpu_$$"

# Importando de manera segura los submódulos
DIR_ACTUAL=$(dirname "$(readlink -f "$0")")
source "$DIR_ACTUAL/collector.sh"
source "$DIR_ACTUAL/alert.sh"

# Función de salida limpia (Captura de SIGINT / SIGTERM)
salida_limpia() {
    registrar_log "INFO" "Señal de apagado recibida. Deteniendo vitalsd de forma controlada..."
    if [[ -f "$TMP_CPU_FILE" ]]; then
        rm -f "$TMP_CPU_FILE"
    fi
    exit 0
}

# Función para recargar configuración al vuelo (Captura de SIGHUP)
recargar_configuracion() {
    registrar_log "INFO" "Señal SIGHUP detectada. Forzando recarga de parámetros desde $CONFIG_FILE..."
    if [ -f "$CONFIG_FILE" ]; then
        source "$CONFIG_FILE"
        registrar_log "INFO" "Configuración actualizada: INTERVALO=${INTERVALO_REVISION}s, MaxCPU=${UMBRAL_CPU}%, MaxRAM=${UMBRAL_RAM}%"
    else
        registrar_log "WARNING" "No se pudo encontrar el archivo $CONFIG_FILE para recargar."
    fi
}

trap salida_limpia SIGTERM SIGINT
trap recargar_configuracion SIGHUP

registrar_log "INFO" "Iniciando micro_demonio vitalsd [PID: $$]"

while true; do
    USO_ACTUAL_RAM=$(obtener_uso_ram)
    USO_ACTUAL_CPU=$(obtener_uso_cpu "$TMP_CPU_FILE")
    evaluar_metricas "$USO_ACTUAL_CPU" "$USO_ACTUAL_RAM"
    sleep "$INTERVALO_REVISION"
done
