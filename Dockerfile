# Testing out this will build out the bedrock github file
FROM ubuntu:18.04

### ENV stuff
ENV NODE_VERSION 10.x
ENV PHP_VERSION 7.3
ENV TIMEZONE "America/New_York"
ENV DEBIAN_FRONTEND noninteractive
ENV APACHE_SERVER_NAME www.testing.local
ENV APP_PORT 5000

### System Stuff
RUN apt-get update \
    && apt-get install -y wget git curl tzdata unzip gnupg \
    && apt-get install -y apt-utils \
    && apt-get update

RUN echo ${TIMEZONE} > /etc/timezone
RUN dpkg-reconfigure -f noninteractive tzdata

### Node stuff
RUN wget -qO- https://deb.nodesource.com/setup_${NODE_VERSION} \
    && apt-get install -y nodejs \
    && apt-get install -y build-essential \
    && apt-get install -y npm \
    && apt-get update

## Using Ubuntu
RUN curl -sL https://deb.nodesource.com/setup_${NODE_VERSION} \
    && apt-get install -y nodejs

### Add NPM package stuff
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
    && apt-get install -y yarn

### PHP stuff
RUN apt-get install -y software-properties-common \
    && add-apt-repository ppa:ondrej/php \
    && apt-get update \
    && apt-get install -y php${PHP_VERSION} \
    && apt-get install -y php${PHP_VERSION}-cli php${PHP_VERSION}-common \
    && apt-get install -y php${PHP_VERSION}-curl php${PHP_VERSION}-gd php${PHP_VERSION}-json \
    && apt-get install -y php${PHP_VERSION}-mbstring php${PHP_VERSION}-intl php${PHP_VERSION}-mysql \
    && apt-get install -y php${PHP_VERSION}-xml php${PHP_VERSION}-zip \
    && apt-get install -y php-cli php-mbstring

### Composer
RUN curl -o /tmp/composer-setup.php https://getcomposer.org/installer \
    && curl -o /tmp/composer-setup.sig https://composer.github.io/installer.sig \
    # Make sure we're installing what we think we're installing!
    && php -r "if (hash('SHA384', file_get_contents('/tmp/composer-setup.php')) !== trim(file_get_contents('/tmp/composer-setup.sig'))) { unlink('/tmp/composer-setup.php'); echo 'Invalid installer' . PHP_EOL; exit(1); }" \
    && php /tmp/composer-setup.php --no-ansi --install-dir=/usr/local/bin --filename=composer --snapshot \
    && rm -f /tmp/composer-setup.*

### Install wp-cli
RUN curl -o /bin/wp-cli.phar https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
RUN chmod +x /bin/wp-cli.phar
RUN cd /bin && mv wp-cli.phar wp

## Restart the sever for php modules to be configured
RUN service apache2 restart
##
#RUN cd /var/www/html \
#    && composer create-project roots/bedrock ./

RUN cd /var/www/html \
    && git clone https://github.com/catalyte-mentorships/wordpress-api.git ./

RUN rm -rf /var/lib/apt/lists/*

## expose these ports on the docker virtual network
EXPOSE ${APP_PORT} 80

# Keep the container running
CMD ["tail", "-f", "/dev/null"]