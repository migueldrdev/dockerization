#!/bin/bashx
# MySQL - Script de inicio con verificaciones
cd "$(dirname "$0")"
SERVICE_NAME="MySQL"
COMPOSE_FILE="docker-compose.yml"
ENV_FILE=".env"
MYSQL_CONTAINER="mysql_container"
PHPMYADMIN_CONTAINER="phpmyadmin_container"

# Colores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Iniciando $SERVICE_NAME con phpMyAdmin...${NC}"

# Verificar si existe el archivo .env
if [ ! -f "$ENV_FILE" ]; then
    echo -e "${RED}❌ Archivo $ENV_FILE no encontrado${NC}"
    echo -e "${YELLOW}💡 Crea el archivo .env con MYSQL_ROOT_PASSWORD, MYSQL_DATABASE, etc.${NC}"
    exit 1
fi

# Verificar si Docker está corriendo
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}❌ Docker no está corriendo${NC}"
    exit 1
fi

# Crear directorio de datos si no existe
if [ ! -d "./data" ]; then
    echo -e "${YELLOW}📁 Creando directorio de datos...${NC}"
    mkdir -p ./data
fi

# Verificar si los contenedores ya existen
if [ "$(docker ps -aq -f name=$MYSQL_CONTAINER)" ]; then
    if [ "$(docker ps -q -f name=$MYSQL_CONTAINER)" ]; then
        echo -e "${YELLOW}⚠️  Los contenedores ya están corriendo${NC}"
        docker ps --filter name=mysql --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
        exit 0
    else
        echo -e "${YELLOW}🔄 Iniciando contenedores existentes...${NC}"
        docker compose -f $COMPOSE_FILE up -d
    fi
else
    echo -e "${GREEN}🐳 Creando e iniciando contenedores...${NC}"
    docker compose -f $COMPOSE_FILE up -d
fi

# Esperar a que MySQL esté listo
echo -e "${YELLOW}⏳ Esperando a que MySQL esté listo...${NC}"
sleep 15

# Verificar que ambos servicios estén corriendo
MYSQL_RUNNING=$(docker ps -q -f name=$MYSQL_CONTAINER)
PHPMYADMIN_RUNNING=$(docker ps -q -f name=$PHPMYADMIN_CONTAINER)

if [ -n "$MYSQL_RUNNING" ] && [ -n "$PHPMYADMIN_RUNNING" ]; then
    echo -e "${GREEN}✅ $SERVICE_NAME y phpMyAdmin iniciados correctamente${NC}"
    echo ""
    echo -e "${BLUE}📊 Estado de los contenedores:${NC}"
    docker ps --filter name=mysql --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
    echo ""
    echo -e "${BLUE}🌐 Información de conexión:${NC}"
    echo "  📍 MySQL Server: localhost:3306"
    echo "  🗄️  Base de datos: mydb (configurada en .env)"
    echo "  👤 Usuario: admin (configurado en .env)"
    echo "  🔑 Contraseña: (definida en .env)"
    echo ""
    echo -e "${BLUE}🌐 phpMyAdmin (Interfaz Web):${NC}"
    echo "  🔗 URL: http://localhost:8081"
    echo "  👤 Usuario: admin"
    echo "  🔑 Contraseña: (misma que MySQL)"
    echo ""
    echo -e "${BLUE}📋 Datos de prueba incluidos:${NC}"
    echo "  👥 Tabla 'users' con 2 registros de ejemplo"
    echo "  🛠️  Cliente CLI recomendado: mysql, MySQL Workbench"
elif [ -n "$MYSQL_RUNNING" ]; then
    echo -e "${YELLOW}⚠️  MySQL iniciado pero phpMyAdmin falló${NC}"
    echo -e "${YELLOW}💡 Revisa los logs de phpMyAdmin: docker logs $PHPMYADMIN_CONTAINER${NC}"
elif [ -n "$PHPMYADMIN_RUNNING" ]; then
    echo -e "${YELLOW}⚠️  phpMyAdmin iniciado pero MySQL falló${NC}"
    echo -e "${YELLOW}💡 Revisa los logs de MySQL: docker logs $MYSQL_CONTAINER${NC}"
else
    echo -e "${RED}❌ Error al iniciar los servicios${NC}"
    echo -e "${YELLOW}💡 Revisa los logs con: docker-compose logs${NC}"
    exit 1
fi
