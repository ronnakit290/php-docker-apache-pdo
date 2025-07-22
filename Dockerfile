FROM php:8.2-apache

# เปิดใช้งาน Apache mod_rewrite
RUN a2enmod rewrite

# ติดตั้ง PDO และ PDO MySQL
RUN docker-php-ext-install pdo pdo_mysql

# กำหนด Document Root (ถ้าต้องการ)
# ENV APACHE_DOCUMENT_ROOT /var/www/html/public

# COPY vhost.conf /etc/apache2/sites-available/000-default.conf
# (ตัวอย่างไว้สำหรับ config เพิ่มเติม)

# คัดลอก source code ไปใน container (เช่นกรณี Laravel/WordPress ฯลฯ)
COPY . /var/www/html

# ให้สิทธิ์กับไฟล์ (ถ้าจำเป็น)
# RUN chown -R www-data:www-data /var/www/html
