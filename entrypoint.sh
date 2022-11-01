#!/bin/bash

# terminate on errors
set -e

# Check if volume is empty
if [ ! "$(ls -A "/var/www/wp-content" 2>/dev/null)" ]; then
    echo 'Setting up wp-content volume'
    # Copy wp-content from Wordpress src to volume
    cp -r /usr/src/wordpress/wp-content /var/www/
    chown -R nobody.nobody /var/www
fi

# Generate secrets
if [ ! -f /usr/src/wordpress/wp-secrets.php ]; then
    cat <<<"Setting up wp-secrets."
    echo "<?php" > /usr/src/wordpress/wp-secrets.php
    chown nobody.nobody /usr/src/wordpress/wp-secrets.php
    chmod 640 /usr/src/wordpress/wp-secrets.php
    curl -f https://api.wordpress.org/secret-key/1.1/salt/ >> /usr/src/wordpress/wp-secrets.php
fi

# su -s /bin/bash nobody -c 'wp plugin install nginx-cache --activate --path="/usr/src/wordpress"'

# rm -rf /usr/src/wordpress/wp-content
# ln -s /var/www/wp-content /usr/src/wordpress

exec "$@"
