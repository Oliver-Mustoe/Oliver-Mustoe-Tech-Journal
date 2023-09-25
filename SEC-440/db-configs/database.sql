CREATE DATABASE IF NOT EXISTS `the_vault` DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;
USE `the_vault`;

CREATE TABLE IF NOT EXISTS `users` (
	`id` int(11) NOT NULL AUTO_INCREMENT,
  	`username` varchar(50) NOT NULL,
  	`password` varchar(255) NOT NULL,
    PRIMARY KEY (`id`)
) AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;

-- Test with "INSERT INTO `users` (`id`, `username`, `password`) VALUES (value1, value2, value3);"
-- Credit: https://codeshack.io/login-system-python-flask-mysql/
