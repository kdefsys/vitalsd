#!/bin/bash
#-------------------------------------------------------------------------------
# Proyecto: vitalsd | Módulo: collector.sh
#-------------------------------------------------------------------------------

#Funcion para obtener el uso de RAM parseando /proc/meminfo

obtener_uso_ram() {

	local mem_total=$(gawk '/MemTotal:/{print $2}' /proc/meminfo)
	local mem_disponible=$(gawk '/MemAvailable/{print $2}' /proc/meminfo)

	local mem_usada=$((mem_total - mem_disponible))
	local porcentaje_ram=$(( (mem_usada * 100) / mem_total ))

	echo "$porcentaje_ram"
}

# Funcion para obtener el uso de CPU analizando /proc/stat
# Al ser un demonio, necesitamos medir la diferencia en el tiempo

obtener_uso_cpu() {
	local archivo_temporal=$1
	local cpu_linea=$(head -n 1 /proc/stat)

	if [[ ! -f "$archivo_temporal" ]]; then
		echo "$cpu_linea" > "$archivo_temporal"
		echo "0"
		return
	fi

	local cpu_linea_anterior=$(cat "$archivo_temporal")
	echo "$cpu_linea" > "$archivo_temporal"

	local porcentaje_cpu=$(gawk -v prev="$cpu_linea_anterior" -v curr="$cpu_linea" '
		BEGIN {
			split(prev, p); split(curr, c);
			#Calculamos total anteriores y actuales
			prev_idle = p[5] + p[6];
			curr_idle = c[5] + c[6];

			prev_total = p[2]+p[3]+p[4]+p[5]+p[6]+p[7]+p[8];
			curr_total = c[2]+c[3]+c[4]+c[5]+c[6]+c[7]+c[8];

			diff_total = curr_total - prev_total;
			diff_idle = curr_idle - prev_idle;

			if(diff_total > 0){
				cpu_used = int(((diff_total - diff_idle) * 100) / diff_total);
				print cpu_used;
			} else{
				print 0;
			}
	}')
	echo "$porcentaje_cpu"
}
