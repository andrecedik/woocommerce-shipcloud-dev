#!/bin/bash

dirname=${PWD##*/}

echo "Using dirname as prefix:" $dirname

docker-compose up -d
sleep 15

docker exec ${dirname}_wordpress_1 wp core update --allow-root
docker exec ${dirname}_wordpress_1 wp core language update --allow-root
docker exec ${dirname}_wordpress_1 wp core install --url=localhost --title=Shipcloud --admin_user=admin --admin_password=admin --admin_email=info@example.com --allow-root
docker exec ${dirname}_wordpress_1 wp plugin install woocommerce --allow-root
docker exec ${dirname}_wordpress_1 wp plugin update woocommerce --allow-root
docker exec ${dirname}_wordpress_1 wp theme update twentyseventeen twentysixteen twentyfifteen --allow-root

if [ ! -d ./src/plugins/woocommerce-shipcloud ]; then
    git clone git@github.com:awsmug/woocommerce-shipcloud.git ./src/plugins/woocommerce-shipcloud
fi

cd ./src/plugins/woocommerce-shipcloud
git checkout develop
git pull

docker exec ${dirname}_wordpress_1 wp plugin activate woocommerce --allow-root
docker exec ${dirname}_wordpress_1 wp plugin activate woocommerce-shipcloud --allow-root
docker exec ${dirname}_wordpress_1 wp plugin deactivate hello --allow-root
docker exec ${dirname}_wordpress_1 wp plugin delete hello --allow-root
docker exec ${dirname}_wordpress_1 wp plugin deactivate akismet --allow-root
docker exec ${dirname}_wordpress_1 wp plugin delete akismet --allow-root