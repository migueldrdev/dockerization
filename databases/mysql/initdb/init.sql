-- Dar todos los privilegios al usuario migueldrdev
GRANT ALL PRIVILEGES ON *.* TO 'migueldrdev'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;

-- Script de ejemplo, se ejecuta al iniciar por primera vez
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO users (name, email) VALUES
('Admin', 'admin@example.com'),
('Test User', 'test@example.com');
