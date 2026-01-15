#!/bin/bash

# Остановка и удаление всех контейнеров, связанных с проектом
echo "Stopping and removing containers..."
docker-compose down --volumes --remove-orphans

# Удаление всех томов проекта
echo "Removing volumes..."
docker volume rm $(docker volume ls -qf dangling=true)

# Удаление всех связанных с проектом данных и конфигурационных файлов
echo "Cleaning up project directories..."

#rm -rf ./nextcloud/config
rm -rf ./nextcloud/custom_apps
rm -rf ./nextcloud/data
rm -rf ./nextcloud/themes
rm -rf ./nextcloud/.htaccess
#rm -rf ./nextcloud/.user.ini

rm -rf ./collabora

rm -rf ./nginx/certs
rm -rf ./nginx/vhost.d
rm -rf ./nginx/html
rm -rf ./nginx/conf.d
rm -rf ./nginx/acme.sh


rm -rf ./mysql/db_data

echo "Cleanup complete!"
