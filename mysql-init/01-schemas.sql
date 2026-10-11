-- One MySQL server, one schema per microservice (database-per-service pattern).
CREATE DATABASE IF NOT EXISTS cargorent_users;
CREATE DATABASE IF NOT EXISTS cargorent_vehicles;
CREATE DATABASE IF NOT EXISTS cargorent_bookings;
CREATE DATABASE IF NOT EXISTS cargorent_payments;
CREATE DATABASE IF NOT EXISTS cargorent_notifications;

CREATE USER IF NOT EXISTS 'cargorent'@'%' IDENTIFIED BY 'cargorent';
GRANT ALL PRIVILEGES ON cargorent_users.*         TO 'cargorent'@'%';
GRANT ALL PRIVILEGES ON cargorent_vehicles.*      TO 'cargorent'@'%';
GRANT ALL PRIVILEGES ON cargorent_bookings.*      TO 'cargorent'@'%';
GRANT ALL PRIVILEGES ON cargorent_payments.*      TO 'cargorent'@'%';
GRANT ALL PRIVILEGES ON cargorent_notifications.* TO 'cargorent'@'%';
FLUSH PRIVILEGES;
