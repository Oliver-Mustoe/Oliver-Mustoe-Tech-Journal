CREATE TABLE DataToDisplay (
    id SERIAL,
    Class_Number VARCHAR(50),
    Class VARCHAR(50),
    Class_Time VARCHAR(50),
    PRIMARY KEY (id)
    )

COPY DataToDisplay
FROM '/var/lib/postgresql/data/class_info.csv'
DELIMITER ','
CSV HEADER;