#!/bin/bash

docker-compose up -d

docker-compose exec --user=www-data wordpress wp core install --url=localhost --title=Shipcloud --admin_user=admin --admin_password=admin --admin_email=info@example.com

docker-compose exec --user=www-data wordpress wp core update
docker-compose exec --user=www-data wordpress wp plugin install woocommerce
docker-compose exec --user=www-data wordpress wp plugin update --all
docker-compose exec --user=www-data wordpress wp theme update --all
docker-compose exec --user=www-data wordpress wp core language update

# Allow group to write everywhere.
docker-compose exec wordpress 'find src/ -exec chmod g+w {} \;'

if [ ! -d ./src/plugins/shipcloud-for-woocommerce ]; then
    git clone git@github.com:awsmug/shipcloud-for-woocommerce.git ./src/plugins/shipcloud-for-woocommerce
fi

docker-compose exec --user=www-data wordpress wp plugin activate woocommerce
docker-compose exec --user=www-data wordpress wp plugin activate shipcloud-for-woocommerce

if [ -d ./src/plugins/hello ]; then
    docker-compose exec --user=www-data wordpress wp plugin deactivate hello
    docker-compose exec --user=www-data wordpress wp plugin delete hello
fi

if [ -d ./src/plugins/akismet ]; then
    docker-compose exec --user=www-data wordpress wp plugin deactivate akismet --allow-root
    docker-compose exec --user=www-data wordpress wp plugin delete akismet --allow-root
fi
