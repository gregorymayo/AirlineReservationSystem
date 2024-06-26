DROP DATABASE IF EXISTS project157a;
CREATE DATABASE project157a;
USE project157a;

CREATE TABLE routes (
    airline varchar(10),
    airlineID int,
    sourceAirport varchar(10),
    sourceAirportID int,
    destAirport varchar(10),
    destAirportID int,
    primary key(airlineID, sourceAirportID, destAirportID)
);

CREATE TABLE credentials (
    loginID varchar(255) primary key,
    password varchar(255) not null check(char_length(password) >= 12),
    userType varchar(10)
);

CREATE TABLE tickets (
    loginID varchar(255),
    ticketNumber int primary key auto_increment,
    foreign key(loginID) references credentials(loginID) on update cascade on delete cascade
);
alter table tickets auto_increment = 1;

CREATE TABLE ticketInfo (
    ticketNumber int primary key,
    airlineID int,
    sourceAirportID int,
    destAirportID int,
    ticketDate date,
    seats int not null check(seats > 0),
    updatedAt timestamp on update current_timestamp,
    foreign key(ticketNumber) references tickets(ticketNumber),
    foreign key(airlineID, sourceAirportID, destAirportID) references routes(airlineID, sourceAirportID, destAirportID)
);

CREATE TABLE ticketTypes (
    ticketNumber int,
    ticketType varchar(255),
    foreign key(ticketNumber) references tickets(ticketNumber)
);

CREATE TABLE archive (
    ticketNumber int,
    airlineID int,
    sourceAirportID int,
    destAirportID int,
    ticketDate date,
    seats int,
    updatedAt timestamp
);

DELIMITER $$

CREATE PROCEDURE archiveTickets(
    IN cutoffDate date
)
BEGIN
    INSERT INTO archive
    SELECT * FROM ticketInfo
    WHERE updatedAt < cutoffDate;
    DELETE FROM ticketInfo
    WHERE updatedAt < cutoffDate;
END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER onUpdateSeatsTrigger
AFTER UPDATE ON ticketInfo
FOR EACH ROW
BEGIN
    IF new.seats < 0 THEN
        UPDATE ticketInfo SET seats = old.seats
        WHERE ticketNumber = old.ticketNumber;
    END IF;
END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER onUpdateUserTypeTrigger
AFTER UPDATE ON credentials
FOR EACH ROW
BEGIN
    IF new.userType = 'admin' THEN
        UPDATE credentials SET userType = 'user'
        WHERE loginID = old.loginID;
    END IF;
END$$

DELIMITER ;

LOAD DATA LOCAL INFILE '/Users/Gjueves/Desktop/CS157A/routes.csv'
INTO TABLE routes
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(airline, airlineID, sourceAirport, sourceAirportID, destAirport, destAirportID);

ALTER TABLE routes ADD (seats int Default 250);