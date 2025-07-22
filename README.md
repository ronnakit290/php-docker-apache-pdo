# PHP Docker Apache with PDO

This Docker Compose setup provides a PHP-Apache environment with PDO support.

## Features

- PHP 8.2 with Apache
- PDO extensions (MySQL, PostgreSQL)
- Apache mod_rewrite enabled
- MySQL 8.0 database server
- phpMyAdmin for database management
- Source code mounted from `./src` to Apache htdocs
- PHP app accessible on port 8080
- phpMyAdmin accessible on port 8081

## Usage

### Build and Run

```bash
docker-compose up --build
```

### Run in Background

```bash
docker-compose up -d
```

### Stop Services

```bash
docker-compose down
```

### Access the Application

- **PHP Application:** http://localhost:8080
- **phpMyAdmin:** http://localhost:8081

### Database Credentials

- **Host:** mysql (from PHP) or localhost:3306 (from host machine)
- **Database:** testdb
- **Username:** testuser
- **Password:** testpass
- **Root Password:** rootpassword

## Directory Structure

```
.
├── docker-compose.yml    # Docker Compose configuration
├── Dockerfile            # PHP-Apache image with PDO
├── apache-config.conf     # Apache virtual host configuration
├── src/                   # Your PHP source code (mapped to htdocs)
│   └── index.php         # Demo file showing PDO support
└── README.md             # This file
```

## Services

- **php:** PHP 8.2 with Apache and PDO extensions
- **mysql:** MySQL 8.0 database server
- **phpmyadmin:** Web-based MySQL administration tool

## Development

- Place your PHP files in the `./src` directory
- Changes are reflected immediately (no rebuild needed)
- The container includes PDO drivers for MySQL and PostgreSQL
- Use phpMyAdmin to manage your MySQL database
- Database data is persisted in a Docker volume

## PDO Support

The container includes the following PDO drivers:
- pdo_mysql (for MySQL/MariaDB)
- pdo_pgsql (for PostgreSQL)
- pdo_sqlite (built-in with PHP)