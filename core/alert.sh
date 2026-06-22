#!/bin/bash
#-----------------------------------------------------------------------------------------------
# Proyecto: vitalsd | Modulo: alert.sh
#-----------------------------------------------------------------------------------------------

# Función central para escribir logs con estructuras syslog estándar

registrar_log() {
	local nivel_severidad=$1
	local mensaje=$2
	local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
	local hostname=$(hostname)

	echo "[$timestamp] [$hostname] [$nivel_severidad] $mensaje" >> "$ARCHIVO_LOG"
}

# Evalua las métricas frente a los umbrales configurados
evaluar_metricas() {
	local cpu=$1
	local ram=$2

	if [[ "$cpu" -gt "$UMBRAL_CPU" ]]; then
		registrar_log "WARNING" "Uso de CPU crítico: ${cpu}% (Umbral máximo: ${UMBRAL_CPU}%)"
	fi

	if [[ "$ram" -gt "$UMBRAL_RAM" ]]; then
		registrar_log "CRITICAL" "Uso de RAM crítico: ${ram}% (Umbral máximo: ${UMBRAL_RAM}%)"
	fi
}
