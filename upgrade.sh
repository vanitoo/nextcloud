docker compose down
docker compose pull
docker compose up -d
docker exec -u 33 -it nextcloud /var/www/html/occ upgrade
