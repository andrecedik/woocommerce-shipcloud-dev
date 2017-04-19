#!/bin/bash

dirname=${PWD##*/}

echo "Using dirname as prefix:" $dirname

docker exec ${dirname}_wordpress_1 wp core update --allow-root