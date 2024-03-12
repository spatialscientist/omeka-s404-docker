FROM php:7.4-apache
#FROM php:apache

# Omeka-S web publishing platform for digital heritage collections (https://omeka.org/s/)
# Initial maintainer: Godwin Yeboah - IDG Research for Technology
LABEL maintainer_name="Godwin Yeboah"
LABEL maintainer_email="g.yeboah@warwick.ac.uk"
LABEL maintainer_email2="yeboahgodwin@gmail.com"
LABEL description="Docker for Omeka-S (version 4.0.4) \
web publishing platform for digital heritage collections (https://omeka.org/s/)."

RUN a2enmod rewrite

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get -qq update && apt-get -qq -y upgrade
RUN apt-get -qq update && apt-get -qq -y --no-install-recommends install \
    unzip \
    zip \
    curl \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libwebp-dev \
    libmcrypt-dev \
    nano \
    libpng-dev \
    libjpeg-dev \
    libmemcached-dev \
    zlib1g-dev \
    imagemagick \
    libmagickwand-dev

# Install the PHP extensions we need
RUN docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/
#RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-webp-dir=/usr/include/ --with-jpeg-dir=/usr/include/
RUN docker-php-ext-install -j$(nproc) iconv pdo pdo_mysql mysqli gd xml xmlrpc xmlwriter calendar json
RUN pecl install mcrypt-1.0.4 && docker-php-ext-enable mcrypt && pecl install imagick && docker-php-ext-enable imagick 

#RUN  docker-php-ext-install gd pdo pdo_mysql pdo_sqlite zip gmp bcmath pcntl ldap sysvmsg exif \
#&& a2enmod rewrite

############# copy starts
# install the PHP extensions we need
#RUN docker-php-ext-install -j$(nproc) iconv mcrypt \
#    pdo pdo_mysql mysqli gd
#RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/
# https://github.com/omeka/omeka-s/releases/download/v4.0.4/omeka-s-4.0.4.zip

RUN docker-php-ext-install exif && docker-php-ext-enable exif

# Download Omeka S 4.0.4 and move to appropriate folder and change ownership
RUN curl -J -L -s -k \
    'https://github.com/omeka/omeka-s/releases/download/v4.0.4/omeka-s-4.0.4.zip' \
    -o /var/www/omeka.zip \
&&  unzip -q /var/www/omeka.zip -d /var/www/ \
&&  rm /var/www/omeka.zip \
&&  rm -rf /var/www/html \
&&  mv /var/www/omeka-s/ /var/www/html \
&&  chown -R www-data:www-data /var/www/html

#COPY ./db.ini /var/www/html/db.ini
COPY ./.htaccess /var/www/html/.htaccess
COPY ./imagemagick-policy.xml /etc/ImageMagick/policy.xml

#VOLUME /var/www/html

#CMD ["apache2-foreground"]

############# copy paste end

# Add the Omeka-S PHP code
#COPY ./omeka-s-3.1.2.zip /var/www/
    #COPY ./omeka-s-3.2.0.zip /var/www/

    #RUN unzip -q /var/www/omeka-s-3.2.0.zip -d /var/www/ \
    #&&  rm /var/www/omeka-s-3.2.0.zip \
    #&&  rm -rf /var/www/html/ \
    #&&  mv /var/www/omeka-s/ /var/www/html/

COPY ./imagemagick-policy.xml /etc/ImageMagick/policy.xml
COPY ./.htaccess /var/www/html/.htaccess

# Add some Omeka modules. If you use the next four lines (which has been disabled), make sure that in each install module, 
# you go to the 'module.ini' file and disable the "#omeka_version_constraint = "^X.X.X"" or make it '^3.0.0'. You may not be able to install if you do not do this.
# line 1
#COPY ./omeka-s-modules-v4.tar.gz /var/www/html/
# line 2 to 4
#RUN rm -rf /var/www/html/modules/ \
#&&  tar -xzf /var/www/html/omeka-s-modules-v4.tar.gz -C /var/www/html/ \
#&&  rm /var/www/html/omeka-s-modules-v4.tar.gz

# Add Omeka-S-module-common which is required for installing EasyAdmin (next install after this)
RUN curl -J -L -s -k \
    'https://gitlab.com/Daniel-KM/Omeka-S-module-Common/-/archive/3.4.54/Omeka-S-module-Common-3.4.54.zip' \
    -o /var/www/common.zip \
&&  unzip -q /var/www/common.zip -d /var/www/ \
&&  rm /var/www/common.zip \
&&  mv /var/www/Omeka-S-module-Common-3.4.54/ /var/www/html/modules/Common \
&&  chown -R www-data:www-data /var/www/html/modules

# As an alternative to line 1-4 above. Install properly, Easy Install extension so that you can use that module to install others.
# the zipped file was manually compiled by selecting some modules of interest. For more modules, the 'EasyInstall' could be used to install them.
# COPY ./omeka-s320-modules-v2.zip /var/www/html/
# RUN rm -rf /var/www/html/modules/
# RUN unzip -q /var/www/html/omeka-s320-modules-v2.zip -d /var/www/html/
# RUN rm /var/www/html/omeka-s320-modules-v2.zip
# RUN cp -r /var/www/html/omeka-s320-modules-v2/ /var/www/html/modules/
RUN curl -J -L -s -k \
    'https://github.com/Daniel-KM/Omeka-S-module-EasyAdmin/releases/download/3.4.16/EasyAdmin-3.4.16.zip' \
    -o /var/www/easyadmin.zip \
&&  unzip -q /var/www/easyadmin.zip -d /var/www/ \
&&  rm /var/www/easyadmin.zip \
&&  mv /var/www/EasyAdmin /var/www/html/modules \
&&  chown -R www-data:www-data /var/www/html/modules

# # Copy/Add some themes by copying downloaded zipped files from https://omeka.org/s/themes/ to themes folder
# COPY ./centerrow.zip ./cozy.zip ./thedaily.zip ./default.zip ./foundation.zip ./papers.zip ./thanksroy.zip /var/www/html/themes/

# # Unzip the copied zipped files in themes folder
# RUN unzip -q /var/www/html/themes/centerrow.zip -d /var/www/html/themes/
# RUN unzip -q /var/www/html/themes/cozy.zip -d /var/www/html/themes/
# RUN unzip -q /var/www/html/themes/thedaily.zip -d /var/www/html/themes/
# #RUN unzip -q /var/www/html/themes/default-v1.6.3.zip -d /var/www/html/themes/ #There is a problem installing this one programmatically! It seems to require response as part of the unzipping process.
# RUN unzip -q /var/www/html/themes/foundation.zip -d /var/www/html/themes/
# RUN unzip -q /var/www/html/themes/papers.zip -d /var/www/html/themes/
# RUN unzip -q /var/www/html/themes/thanksroy.zip -d /var/www/html/themes/

# # Remove the zipped files you copied
# RUN rm /var/www/html/themes/centerrow.zip
# RUN rm /var/www/html/themes/cozy.zip
# RUN rm /var/www/html/themes/thedaily.zip
# #RUN rm /var/www/html/themes/default-v1.6.3.zip
# RUN rm /var/www/html/themes/foundation.zip
# RUN rm /var/www/html/themes/papers.zip
# RUN rm /var/www/html/themes/thanksroy.zip

#Copy modified .htaccess
COPY ./.htaccess /var/www/html/.htaccess

# Create one volume for files and config
RUN mkdir -p /var/www/html/volume/config/ && mkdir -p /var/www/html/volume/files/
COPY ./database.ini /var/www/html/volume/config/
RUN rm /var/www/html/config/database.ini \
&& ln -s /var/www/html/volume/config/database.ini /var/www/html/config/database.ini \
&& rm -Rf /var/www/html/files \
&& ln -s /var/www/html/volume/files /var/www/html/files \
&& chown -R www-data:www-data /var/www/html \
&& chown -R www-data:www-data /var/www/html/ \
&& chmod 600 /var/www/html/volume/config/database.ini \
&& chmod 600 /var/www/html/.htaccess

VOLUME /var/www/html/volume/

CMD ["apache2-foreground"]
