#!/bin/bash

dirname=${PWD##*/}

echo "Using dirname as prefix:" $dirname

docker-compose up -d
sleep 15

docker exec ${dirname}_wordpress_1 wp core install --url=localhost --title=Shipcloud --admin_user=admin --admin_password=admin --admin_email=info@example.com --allow-root

docker exec ${dirname}_wordpress_1 wp core update --allow-root
docker exec ${dirname}_wordpress_1 wp plugin install woocommerce --allow-root
docker exec ${dirname}_wordpress_1 wp plugin update --all --allow-root
docker exec ${dirname}_wordpress_1 wp theme update --all --allow-root
docker exec ${dirname}_wordpress_1 wp core language update --allow-root

if [ ! -d ./src/plugins/shipcloud-for-woocommerce ]; then
    git clone git@github.com:awsmug/shipcloud-for-woocommerce.git ./src/plugins/shipcloud-for-woocommerce
fi

docker exec ${dirname}_wordpress_1 wp plugin activate woocommerce --allow-root
docker exec ${dirname}_wordpress_1 wp plugin activate shipcloud-for-woocommerce --allow-root

if [ -d ./src/plugins/hello ]; then
    docker exec ${dirname}_wordpress_1 wp plugin deactivate hello --allow-root
    docker exec ${dirname}_wordpress_1 wp plugin delete hello --allow-root
fi

if [ -d ./src/plugins/akismet ]; then
    docker exec ${dirname}_wordpress_1 wp plugin deactivate akismet --allow-root
    docker exec ${dirname}_wordpress_1 wp plugin delete akismet --allow-root
fi