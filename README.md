##  **vitalsd** 🐧

[![Bash Shell](https://img.shields.io/badge/Shell-Bash-4EAA25?logo=gnu-bash&logoColor=white)](https://www.gnu.org/software/bash/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Linux Standard](https://img.shields.io/badge/Standard-FHS-blue?logo=linux&logoColor=white)](https://refspecs.linuxfoundation.org/fhs.shtml)

**vitalsd** (*Vital System Daemon*) es un micro-demonio ligero y modular escrito nativamente en Bash para el monitoreo de recursos críticos (CPU y RAM) en sistemas operativos Linux. 

A diferencia de las herramientas convencionales que invocan binarios pesados de espacio de usuario (como `top` o `free`), **vitalsd** interactúa directamente con la interfaz del Kernel a través del sistema de archivos `/proc`. Esto garantiza una recolección de métricas de alta precisión con un impacto de rendimiento prácticamente nulo (<1% de uso de CPU).

---

## 🚀 Características Clave

* **Arquitectura Modular:** Separación estricta de responsabilidades en 3 submódulos independientes (`main`, `collector`, `alert`).
* **Acceso de Bajo Nivel:** Parseo eficiente con `gawk` directo desde `/proc/stat` y `/proc/meminfo`.
* **Cálculo de CPU Diferencial Real ($\Delta$):** Medición exacta por intervalos de tiempo mediante archivos temporales dinámicos, aislando los picos actuales de los promedios históricos.
* **Gestión Avanzada de Señales (POSIX Traps):**
  * `SIGINT` / `SIGTERM`: Apagado controlado con limpieza automática de recursos en `/tmp`.
  * `SIGHUP`: Recarga en caliente (*hot-reload*) del archivo de configuración sin interrumpir el proceso.
* **Despliegue Profesional:** Instalador `Makefile` que sigue rigurosamente el estándar FHS (*Filesystem Hierarchy Standard*) de Linux.

---

## 📂 Arquitectura del Proyecto

```text
vitalsd/
├── core/
│   ├── main.sh        # Orquestador del ciclo de vida y captura de señales
│   ├── collector.sh   # Extracción de métricas desde el Kernel (/proc)
│   └── alert.sh       # Evaluación de umbrales y registro de logs
├── config/
│   └── vitalsd.conf   # Variables de entorno y umbrales personalizables
└── Makefile           # Automatización de instalación/desinstalación global
```

## 🛠️ Instalación y Despliegue

Requisitos Previos:

* Sistema Operativo Linux (Kernel 2.6+)
* Herramientas basicas de compilacion (make, gawk).

Pasos para instalar:

git clone [https://github.com/kdefsys/vitalsd.git](https://github.com/kdefsys/vitalsd.git)
cd vitalsd
sudo make install

El Makefile se encargará de:

1. Copiar los submódulos a /usr/local/bin/vitalsd-core/.

2. Crear un enlace simbólico ejecutable global en /usr/local/bin/vitalsd.

3. Instalar la configuración base en /etc/vitalsd/vitalsd.conf.

4. Inicializar el archivo de logs oficial en /var/log/vitalsd.log con permisos restringidos de Sysadmin (640).

## ⚙️ Configuración

sudo nano /etc/vitalsd/vitalsd.conf

Campos disponibles:

1. **INTERVALO_REVISION**: Segundos de espera entre cada consulta al Kernel (por defecto: 3).

2. **UMBRAL_CPU**: Porcentaje máximo (0-100) permitido de uso global de CPU antes de alertar.

3. **UMBRAL_RAM**: Porcentaje máximo (0-100) permitido de ocupación de memoria real antes de alertar.

Recarga en Caliente (Hot-Reload)

Si modificas los umbrales en el archivo de configuración, no necesitas reiniciar el servicio. Envía una señal SIGHUP al proceso para forzar la actualización de parámetros al vuelo:

sudo kill -1 $(pgrep vitalsd)

## 📊 Uso y Monitoreo

Ejecución

Para iniciar el micro-demonio en segundo plano de forma estándar:

```sudo vitalsd & ```

Inspección de Alertas (Logs)

El demonio reporta su actividad y alertas críticas estructuradas bajo el estándar de formato Syslog en /var/log/vitalsd.log:

```tail -f /var/log/vitalsd.log ```

Ejemplo de salida

```
[2026-06-22 01:15:00] [linux-server] [INFO] Iniciando micro_demonio vitalsd [PID: 4321]
[2026-06-22 01:15:09] [linux-server] [WARNING] Uso de CPU crítico: 88% (Umbral máximo: 80%)
[2026-06-22 01:15:12] [linux-server] [CRITICAL] Uso de Memoria RAM crítico: 91% (Umbral máximo: 85%)
[2026-06-22 01:16:02] [linux-server] [INFO] Señal SIGHUP detectada. Forzando recarga de parámetros desde /etc/vitalsd/vitalsd.conf...

```

## 🗑️ Desinstalación

Si deseas remover completamente el software y limpiar el sistema operativo:

```sudo make uninstall```

