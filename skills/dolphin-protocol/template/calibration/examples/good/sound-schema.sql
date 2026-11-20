-- LABEL: good — real FK with ON DELETE, DECIMAL money, constrained
-- status, uniqueness beyond the PK, timestamps, FK-side index.
CREATE TABLE orders (
  id          BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  customer_id BIGINT NOT NULL REFERENCES customers(id) ON DELETE RESTRICT,
  total_idr   NUMERIC(14, 2) NOT NULL CHECK (total_idr >= 0),
  status      TEXT NOT NULL CHECK (status IN ('pending', 'paid', 'shipped', 'cancelled')),
  invoice_no  TEXT NOT NULL UNIQUE,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX orders_customer_id_idx ON orders (customer_id);
