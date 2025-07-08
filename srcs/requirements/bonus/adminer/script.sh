#!/bin/bash

echo "Downloading Adminer PHP file..."
wget -O index.php https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1.php 

echo "Starting PHP server on 0.0.0.0:8080..."
php -S 0.0.0.0:8080 
