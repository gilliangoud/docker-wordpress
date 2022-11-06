<?php

define('WP_CONTENT_DIR', '/var/www/wp-content');

# Detect that we're behind a reverse proxy
if ( isset( $_SERVER['HTTP_X_FORWARDED_PROTO'] ) && $_SERVER['HTTP_X_FORWARDED_PROTO'] === 'https' ) {
    $_SERVER['HTTPS'] = 'on';
}

# Ability to manually set the wordpress URLS
if ( getenv( 'WP_HOME' ) == 'ANY' || getenv( 'WP_SITEURL' ) == 'ANY' ) {
    define( 'WP_HOME', ( isset( $_SERVER['HTTPS'] ) && $_SERVER['HTTPS'] === 'on' ? 'https' : 'http' ) . "://$_SERVER[HTTP_HOST]" );
    define( 'WP_SITEURL', ( isset( $_SERVER['HTTPS'] ) && $_SERVER['HTTPS'] === 'on' ? 'https' : 'http' ) . "://$_SERVER[HTTP_HOST]" );
}

$table_prefix  = getenv('TABLE_PREFIX') ?: 'wp_';

foreach ($_ENV as $key => $value) {
    $capitalized = strtoupper($key);
    if (!defined($capitalized)) {
        define($capitalized, $value);
    }
}

define('RT_WP_NGINX_HELPER_CACHE_PATH','/var/run/nginx');

if (!defined('ABSPATH')) {
    define('ABSPATH', dirname(__FILE__) . '/');
}

if ( !defined( 'WP_AUTO_UPDATE_CORE' ) ) {
    define( 'WP_AUTO_UPDATE_CORE', false );
}

if ( !defined( 'CORE_UPGRADE_SKIP_NEW_BUNDLED' ) ) {
    define( 'CORE_UPGRADE_SKIP_NEW_BUNDLED', true );
}

// define( 'WP_REDIS_HOST', '127.0.0.1' );
// define( 'WP_REDIS_PORT', 6379 );
// define( 'WP_REDIS_PASSWORD', 'secret' );
// define( 'WP_REDIS_TIMEOUT', 1 );
// define( 'WP_REDIS_READ_TIMEOUT', 1 );

// change the database for each site to avoid cache collisions
// define( 'WP_REDIS_DATABASE', 0 );

// supported clients: `phpredis`, `credis`, `predis` and `hhvm`
// define( 'WP_REDIS_CLIENT', 'phpredis' );

// automatically delete cache keys after 7 days
// define( 'WP_REDIS_MAXTTL', 60 * 60 * 24 * 7 );

// bypass the object cache, useful for debugging
// define( 'WP_REDIS_DISABLED', true );

require_once(ABSPATH . 'wp-secrets.php');
require_once(ABSPATH . 'wp-settings.php');
