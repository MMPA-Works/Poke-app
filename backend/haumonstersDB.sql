CREATE DATABASE IF NOT EXISTS haumonstersDB
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE haumonstersDB;

CREATE TABLE IF NOT EXISTS monsterstbl (
    monster_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    monster_name VARCHAR(150) NOT NULL,
    monster_type VARCHAR(100) NOT NULL,
    spawn_latitude DECIMAL(10,7) NOT NULL,
    spawn_longitude DECIMAL(10,7) NOT NULL,
    spawn_radius_meters DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    picture_url TEXT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (monster_id)
);
