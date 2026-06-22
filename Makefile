# ====================================================================
# Makefile para vitalsd (Linux Micro-Daemon & Health Monitor)
# Autor: kdefsys
# ====================================================================

# Variables de rutas del sistema (Siguiendo el estándar FHS de Linux)
PREFIX      ?= /usr/local
BINDIR      = $(PREFIX)/bin
SYSCONFDIR  = /etc
LOGDIR      = /var/log

# Nombre del proyecto y subdirectorios
NAME        = vitalsd
CORE_DEST   = $(BINDIR)/$(NAME)-core

# Target por defecto: Informa al usuario que no requiere compilación
all:
	@echo "vitalsd es un proyecto basado en Bash. No requiere compilación."
	@echo "Ejecuta 'sudo make install' para instalar el demonio globalmente."

# Target para instalar el demonio y su estructura en el sistema operativo
install:
	@echo "Instalando $(NAME) en el sistema..."
	
	# 1. Crear la estructura de directorios del sistema si no existe
	mkdir -p $(BINDIR)
	mkdir -p $(CORE_DEST)
	mkdir -p $(SYSCONFDIR)/$(NAME)
	mkdir -p $(LOGDIR)

	# 2. Copiar todos los módulos del Core a su ubicación interna en /usr/local/bin
	cp -r core/* $(CORE_DEST)/
	
	# 3. Crear el enlace simbólico global en /usr/local/bin/vitalsd apuntando al main.sh
	# Esto permite ejecutar 'vitalsd' desde cualquier parte de la consola
	ln -sf $(CORE_DEST)/main.sh $(BINDIR)/$(NAME)

	# 4. Copiar el archivo de configuración a /etc/vitalsd/ solo si no existe previamente
	# Así evitamos sobrescribir cambios personalizados del administrador en actualizaciones
	if [ ! -f $(SYSCONFDIR)/$(NAME)/vitalsd.conf ]; then \
		cp config/vitalsd.conf $(SYSCONFDIR)/$(NAME)/vitalsd.conf; \
		echo "Configuración base instalada en $(SYSCONFDIR)/$(NAME)/vitalsd.conf"; \
	else \
		echo "El archivo de configuración ya existe. Omitiendo para proteger tus cambios."; \
	fi

	# 5. Asignación estricta de permisos de seguridad
	chmod +x $(BINDIR)/$(NAME)
	chmod +x $(CORE_DEST)/*.sh
	chmod 644 $(SYSCONFDIR)/$(NAME)/vitalsd.conf
	
	# 6. Preparar el archivo de logs del sistema con permisos restringidos (solo root y grupo admin)
	touch $(LOGDIR)/vitalsd.log
	chmod 640 $(LOGDIR)/vitalsd.log

	@echo "Instalación completada exitosamente."
	@echo "Puedes iniciar el demonio ejecutando: sudo vitalsd"

# Target para limpiar y desinstalar el proyecto por completo del sistema operativo
uninstall:
	@echo "Removiendo $(NAME) del sistema operativo..."
	
	# Eliminar el enlace ejecutable global y el directorio interno de módulos
	rm -f $(BINDIR)/$(NAME)
	rm -rf $(CORE_DEST)
	
	# Eliminar el directorio de configuración en /etc
	rm -rf $(SYSCONFDIR)/$(NAME)
	
	@echo "vitalsd ha sido desinstalado correctamente."
	@echo "Nota: El archivo de log en $(LOGDIR)/vitalsd.log se conservó por seguridad histórica."

# Declarar targets virtuales para evitar conflictos con archivos reales del mismo nombre
.PHONY: all install uninstall
