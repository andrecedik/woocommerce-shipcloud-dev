#!/bin/bash

docker-compose up -d
sleep 15

docker-compose exec --user=www-data wordpress wp core install --url=localhost --title=Shipcloud --admin_user=admin --admin_password=admin --admin_email=info@example.com

docker-compose exec --user=www-data wordpress wp core update --allow-root
docker-compose exec --user=www-data wordpress wp plugin install woocommerce --allow-root
docker-compose exec --user=www-data wordpress wp plugin update --all --allow-root
docker-compose exec --user=www-data wordpress wp theme update --all --allow-root
docker-compose exec --user=www-data wordpress wp core language update --allow-root

if [ ! -d ./src/plugins/shipcloud-for-woocommerce ]; then
    git clone git@github.com:awsmug/shipcloud-for-woocommerce.git ./src/plugins/shipcloud-for-woocommerce
fi

docker-compose exec --user=www-data wordpress wp plugin activate woocommerce --allow-root
docker-compose exec --user=www-data wordpress wp plugin activate shipcloud-for-woocommerce --allow-root

if [ -d ./src/plugins/hello ]; then
    docker-compose exec --user=www-data wordpress wp plugin deactivate hello --allow-root
    docker-compose exec --user=www-data wordpress wp plugin delete hello --allow-root
fi

if [ -d ./src/plugins/akismet ]; then
    docker-compose exec --user=www-data wordpress wp plugin deactivate akismet --allow-root
    docker-compose exec --user=www-data wordpress wp plugin delete akismet --allow-root
fi
