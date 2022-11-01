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

if (!defined('ABSPATH')) {
    define('ABSPATH', dirname(__FILE__) . '/');
}

if ( !defined( 'WP_AUTO_UPDATE_CORE' ) ) {
    define( 'WP_AUTO_UPDATE_CORE', false );
}

if ( !defined( 'CORE_UPGRADE_SKIP_NEW_BUNDLED' ) ) {
    define( 'CORE_UPGRADE_SKIP_NEW_BUNDLED', true );
}

require_once(ABSPATH . 'wp-secrets.php');
require_once(ABSPATH . 'wp-settings.php');
