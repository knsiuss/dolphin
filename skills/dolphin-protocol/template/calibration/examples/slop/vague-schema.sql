-- LABEL: slop — *_id with no FK constraint, FLOAT money, free-text
-- status, everything nullable, no uniqueness, no timestamps,
-- VARCHAR(255) for everything, no index on the referencing side.
CREATE TABLE orders (
  id          INT PRIMARY KEY,
  customer_id INT,
  total       FLOAT,
  status      VARCHAR(255),
  data        TEXT
);
