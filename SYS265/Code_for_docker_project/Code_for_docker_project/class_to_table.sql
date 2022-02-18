\c testDB;
CREATE TABLE datatodisplay (
    id SERIAL,
    class VARCHAR(50) NOT NULL,
    class_time VARCHAR(50) NOT NULL,
    PRIMARY KEY (id)
);
INSERT INTO datatodisplay (class,class_time)
VALUES  ('SYS265','2.45'),
        ('COR204','1.15'),
        ('COR203','1.15'),
        ('SEC345','1.15'),
        ('SEC260','1.15');
