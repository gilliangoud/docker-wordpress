#!/bin/bash

# terminate on errors
set -e

# Check if volume is empty
if [ ! "$(ls -A "/var/www/wp-content" 2>/dev/null)" ]; then
    echo 'Setting up wp-content volume'
    # Copy wp-content from Wordpress src to volume
    cp -r /usr/src/wordpress/wp-content /var/www/
    chown -R nobody.nobody /var/www

    # Generate secrets
    curl -f https://api.wordpress.org/secret-key/1.1/salt/ >> /usr/src/wordpress/wp-secrets.php
fi

# Check if volume is empty
if [ ! -f /usr/src/wordpress/wp-secrets.php ]; then
    cat <<<"Setting up wp-secrets."
    echo "<?php" > /usr/src/wordpress/wp-secrets.php
    chown nobody.nobody /usr/src/wordpress/wp-secrets.php
    chmod 640 /usr/src/wordpress/wp-secrets.php
    # Generate secrets
    curl -f https://api.wordpress.org/secret-key/1.1/salt/ >> /usr/src/wordpress/wp-secrets.php
fi

exec "$@"
