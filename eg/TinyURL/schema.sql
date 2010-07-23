
CREATE TABLE url (
       id CHAR(8) NOT NULL PRIMARY KEY,
       url VARCHAR(255) NOT NULL,
       UNIQUE KEY(url)
);