-- Drop database if exists (for clean reinstall)
DROP DATABASE IF EXISTS inventory_db;

-- Create database with UTF-8 encoding
CREATE DATABASE inventory_db
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

-- Use the database
USE inventory_db;

-- Verify database creation
SELECT DATABASE() AS current_database;
