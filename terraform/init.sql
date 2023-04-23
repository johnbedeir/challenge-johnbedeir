CREATE DATABASE IF NOT EXISTS myapp_db;
USE myapp_db;

CREATE TABLE IF NOT EXISTS items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL
);

INSERT INTO items (name) VALUES ('Python');
INSERT INTO items (name) VALUES ('GoLang');
INSERT INTO items (name) VALUES ('PHP');