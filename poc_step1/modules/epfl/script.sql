-- AUTO-GENERATED FILE.

-- This file is an auto-generated file by Ballerina persistence layer for model.
-- Please verify the generated scripts and execute them against the target DB server.

DROP TABLE IF EXISTS `etudiants`;

CREATE TABLE `etudiants` (
	`id` INT NOT NULL,
	`nom` VARCHAR(50),
	`prenom` VARCHAR(50),
	`email` VARCHAR(100),
	`actif` BOOLEAN,
	PRIMARY KEY(`id`)
);


