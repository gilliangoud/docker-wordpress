FROM alpine:3.16
LABEL Maintainer="Gillian Goud <gillian@goud-it.nl>" \
      Description="Lightweight WordPress container with Nginx 1.22 & PHP-FPM 8.0 based on Alpine Linux."

# Install packages
RUN apk --no-cache add \
  php8 \
  php8-fpm \
  php8-mysqli \
  php8-json \
  php8-openssl \
  php8-curl \
  php8-zlib \
  php8-xml \
  php8-phar \
  php8-intl \
  php8-dom \
  php8-xmlreader \
  php8-xmlwriter \
  php8-exif \
  php8-fileinfo \
  php8-sodium \
  php8-gd \
  php8-simplexml \
  php8-ctype \
  php8-mbstring \
  php8-zip \
  php8-opcache \
  php8-iconv \
  php8-pecl-imagick \
  supervisor \
  imagemagick \
  curl \
  bash \
  less \
  rsync \
  nano

# Install nginx
ARG NGINX_VERSION=1.21.0
ENV VAR_PREFIX=/var/run LOG_PREFIX=/var/log/nginx TEMP_PREFIX=/tmp CACHE_PREFIX=/var/run/nginx CONF_PREFIX=/etc/nginx CERTS_PREFIX=/etc/pki/tls
RUN NGINX_VERSION=1.21.0 /bin/sh -c set -x    \
    && CONFIG="    --prefix=/usr/share/nginx/     --sbin-path=/usr/sbin/nginx     --add-module=/tmp/naxsi/naxsi_src     --modules-path=/usr/lib/nginx/modules     --conf-path=${CONF_PREFIX}/nginx.conf     --error-log-path=${LOG_PREFIX}/error.log     --http-log-path=${LOG_PREFIX}/access.log     --pid-path=${VAR_PREFIX}/nginx.pid     --lock-path=${VAR_PREFIX}/nginx.lock     --http-client-body-temp-path=${TEMP_PREFIX}/client_temp     --http-proxy-temp-path=${TEMP_PREFIX}/proxy_temp     --http-fastcgi-temp-path=${TEMP_PREFIX}/fastcgi_temp     --http-uwsgi-temp-path=${TEMP_PREFIX}/uwsgi_temp     --http-scgi-temp-path=${TEMP_PREFIX}/scgi_temp     --user=nobody     --group=nobody     --with-http_ssl_module     --with-pcre-jit     --with-http_realip_module     --with-http_addition_module     --with-http_sub_module     --with-http_dav_module     --with-http_flv_module     --with-http_mp4_module     --with-http_gunzip_module     --with-http_gzip_static_module     --with-http_random_index_module     --with-http_secure_link_module     --with-http_stub_status_module     --with-http_auth_request_module     --with-http_xslt_module=dynamic     --with-http_image_filter_module=dynamic     --with-http_geoip_module=dynamic     --with-threads     --with-stream     --with-stream_ssl_module     --with-stream_ssl_preread_module     --with-stream_realip_module     --with-stream_geoip_module=dynamic     --with-http_slice_module     --with-mail     --with-mail_ssl_module     --with-compat     --with-file-aio     --with-http_v2_module     --add-module=/tmp/ngx_cache_purge-2.3     --add-module=/tmp/ngx_http_redis-0.3.9     --add-module=/tmp/redis2-nginx-module-0.15     --add-module=/tmp/srcache-nginx-module-0.31     --add-module=/tmp/echo-nginx-module     --add-module=/tmp/ngx_devel_kit-0.3.1     --add-module=/tmp/set-misc-nginx-module-0.32     --add-module=/tmp/ngx_brotli     --with-ld-opt='-L/usr/lib'     --with-cc-opt=-Wno-error   "   \
    && apk add --no-cache --virtual .build-deps       alpine-sdk       autoconf       automake       binutils        build-base        build-base       ca-certificates       cmake        findutils       gcc        gd-dev       geoip-dev       gettext       git       gnupg        gnupg       go        gzip       libc-dev       libtool        libxslt-dev       linux-headers       libedit-dev       make       musl-dev       openssl-dev       pcre-dev       perl-dev       unzip       wget       zlib-dev   \
    && apk add --no-cache --update       curl       monit       wget       bash       bind-tools       rsync       geoip       openssl       pcre       tini       tar   \
    && cd /tmp   \
    && git clone https://github.com/google/ngx_brotli --depth=1   \
    && cd ngx_brotli \
    && git submodule update --init   \
    && export NGX_BROTLI_STATIC_MODULE_ONLY=1   \
    && cd /tmp   \
    && git clone https://github.com/nbs-system/naxsi.git   \
    && echo 'adding /usr/local/share/GeoIP/GeoIP.dat database'   \
    && wget -N https://raw.githubusercontent.com/openbridge/nginx/master/geoip/GeoLiteCity.dat.gz   \
    && wget -N https://raw.githubusercontent.com/openbridge/nginx/master/geoip/GeoIP.dat.gz   \
    && gzip -d GeoIP.dat.gz   \
    && gzip -d GeoLiteCity.dat.gz   \
    && mkdir /usr/local/share/GeoIP/   \
    && mv GeoIP.dat /usr/local/share/GeoIP/   \
    && mv GeoLiteCity.dat /usr/local/share/GeoIP/   \
    && chown -R nobody:nobody /usr/local/share/GeoIP/   \
    && curl -fSL http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz -o nginx.tar.gz   \
    && mkdir -p /usr/src   \
    && tar -zxC /usr/src -f nginx.tar.gz   \
    && rm nginx.tar.gz   \
    && cd /tmp   \
    && git clone https://github.com/openresty/echo-nginx-module.git   \
    && wget https://github.com/simpl/ngx_devel_kit/archive/v0.3.1.zip -O dev.zip   \
    && wget https://github.com/openresty/set-misc-nginx-module/archive/v0.32.zip -O setmisc.zip   \
    && wget https://people.freebsd.org/~osa/ngx_http_redis-0.3.9.tar.gz   \
    && wget https://github.com/openresty/redis2-nginx-module/archive/v0.15.zip -O redis.zip   \
    && wget https://github.com/openresty/srcache-nginx-module/archive/v0.31.zip -O cache.zip   \
    && wget https://github.com/FRiCKLE/ngx_cache_purge/archive/2.3.zip -O purge.zip   \
    && tar -zx -f ngx_http_redis-0.3.9.tar.gz   \
    && unzip dev.zip   \
    && unzip setmisc.zip   \
    && unzip redis.zip   \
    && unzip cache.zip   \
    && unzip purge.zip   \
    && cd /usr/src/nginx-$NGINX_VERSION   \
    && ./configure $CONFIG --with-debug   \
    && make -j$(getconf _NPROCESSORS_ONLN)   \
    && mv objs/nginx objs/nginx-debug   \
    && mv objs/ngx_http_xslt_filter_module.so objs/ngx_http_xslt_filter_module-debug.so   \
    && mv objs/ngx_http_image_filter_module.so objs/ngx_http_image_filter_module-debug.so   \
    && mv objs/ngx_stream_geoip_module.so objs/ngx_stream_geoip_module-debug.so   \
    && ./configure $CONFIG   \
    && make -j$(getconf _NPROCESSORS_ONLN)   \
    && make install   \
    && rm -rf /etc/nginx/html/   \
    && mkdir /etc/nginx/conf.d/   \
    && mkdir -p /usr/share/nginx/html/   \
    && install -m644 html/index.html /usr/share/nginx/html/   \
    && install -m644 html/50x.html /usr/share/nginx/html/   \
    && install -m755 objs/nginx-debug /usr/sbin/nginx-debug   \
    && install -m755 objs/ngx_http_xslt_filter_module-debug.so /usr/lib/nginx/modules/ngx_http_xslt_filter_module-debug.so   \
    && install -m755 objs/ngx_http_image_filter_module-debug.so /usr/lib/nginx/modules/ngx_http_image_filter_module-debug.so   \
    && install -m755 objs/ngx_stream_geoip_module-debug.so /usr/lib/nginx/modules/ngx_stream_geoip_module-debug.so   \
    && ln -s ../../usr/lib/nginx/modules /etc/nginx/modules   \
    && strip /usr/sbin/nginx*   \
    && strip /usr/lib/nginx/modules/*.so   \
    && mkdir -p /usr/local/bin/   \
    && mkdir -p ${CACHE_PREFIX}   \
    && mkdir -p ${CERTS_PREFIX}   \
    && mv /usr/bin/envsubst /tmp/   \
    && runDeps="$(scanelf --needed --nobanner /tmp/envsubst | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' | sort -u | xargs -r apk info --installed | sort -u )"   \
    && apk add --no-cache $runDeps   \
    && mv /tmp/envsubst /usr/local/bin/   \
    && cd /etc/pki/tls/   \
    && nice -n +5 openssl dhparam -out /etc/pki/tls/dhparam.pem.default 2048   \
    && apk add --no-cache $runDeps   \
    && apk del .build-deps   \
    && cd /tmp/naxsi   \
    && mv naxsi_config/naxsi_core.rules /etc/nginx/naxsi_core.rules   \
    && rm -rf /tmp/*   \
    && rm -rf /usr/src/*   \
    && ln -sf /dev/stdout ${LOG_PREFIX}/access.log   \
    && ln -sf /dev/stderr ${LOG_PREFIX}/error.log   \
    && ln -sf /dev/stdout ${LOG_PREFIX}/blocked.log

# Configure nginx
COPY config/nginx.conf /etc/nginx/nginx.conf

# Configure PHP-FPM
COPY config/fpm-pool.conf /etc/php8/php-fpm.d/zzz_custom.conf
COPY config/php.ini /etc/php8/conf.d/zzz_custom.ini

# Configure supervisord
COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# wp-content volume
VOLUME /var/www/wp-content
WORKDIR /var/www/wp-content
RUN chown -R nobody.nobody /var/www

# WordPress
ENV WORDPRESS_VERSION 6.1
ENV WORDPRESS_SHA1 d7ca8d05b33caf1ebf473387c8357f04a01cf0b5

RUN mkdir -p /usr/src

# Upstream tarballs include ./wordpress/ so this gives us /usr/src/wordpress
RUN curl -o wordpress.tar.gz -SL https://wordpress.org/wordpress-${WORDPRESS_VERSION}.tar.gz \
	&& echo "$WORDPRESS_SHA1 *wordpress.tar.gz" | sha1sum -c - \
	&& tar -xzf wordpress.tar.gz -C /usr/src/ \
	&& rm wordpress.tar.gz \
	&& chown -R nobody.nobody /usr/src/wordpress

# Add WP CLI
RUN curl -o /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x /usr/local/bin/wp

# WP config
COPY wp-config.php /usr/src/wordpress
RUN chown nobody.nobody /usr/src/wordpress/wp-config.php && chmod 640 /usr/src/wordpress/wp-config.php

# Robots
COPY config/robots.txt /usr/src/wordpress/robots.txt
RUN chown nobody.nobody /usr/src/wordpress/robots.txt && chmod 640 /usr/src/wordpress/robots.txt

# Entrypoint to copy wp-content
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]

EXPOSE 80

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

HEALTHCHECK --timeout=10s CMD curl --silent --fail http://127.0.0.1/wp-login.php
