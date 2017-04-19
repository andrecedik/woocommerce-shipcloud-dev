#!/bin/bash

dirname=${PWD##*/}

dockerexec="docker exec "${dirname}"_wordpress_1"

"${dockerexec} wp core update --allow-root"

echo "Using dirname as prefix:" $dirname

## docker exec ${dirname}_wordpress_1 wp core update --allow-root