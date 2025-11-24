# SQL Constraints — A concise, production-ready reference covering all common SQL constraints: definitions, syntax, usage examples, and best practices. Suitable for inclusion in a GitHub repo README or a technical documentation site.

## Overview

Constraints are rules that the database enforces to ensure the integrity, consistency, and validity of data. They are declared at table creation time (`CREATE TABLE`) or added later with `ALTER TABLE`.

Common constraint types:

* **NOT NULL** — prohibits `NULL` values.
* **UNIQUE** — ensures all values in a column (or set of columns) are distinct.
* **PRIMARY KEY** — a combination of `NOT NULL` and `UNIQUE`; identifies each row uniquely.
* **FOREIGN KEY** — enforces referential integrity between two tables.
* **CHECK** — enforces a boolean expression for column values.
* **DEFAULT** — provides a default value when no value is supplied.

Notes: precise behavior of `NULL` handling and enforcement details can vary slightly across RDBMS (MySQL, PostgreSQL, SQL Server, Oracle). The examples below are ANSI-SQL compatible and work in modern RDBMS with only minor adjustments.

---

## 1. NOT NULL: Ensure a column must have a value (no `NULL`s allowed).

**Syntax:**

column_name data_type NOT NULL

**Example:**

CREATE TABLE employees (
  id INT PRIMARY KEY,
  first_name VARCHAR(100) NOT NULL,
  last_name VARCHAR(100) NOT NULL
);

**Behavior:** Inserts or updates that attempt to set the column to `NULL` will fail.

---

## 2. UNIQUE:  Ensure all values in a column or group of columns are distinct.

Syntax (column-level):
    column_name data_type UNIQUE

Syntax (table-level, composite unique):
    UNIQUE (column_a, column_b)

**Examples:**

-- Single column unique
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  email VARCHAR(320) UNIQUE
);

-- Composite unique (email scoped to tenant)
CREATE TABLE tenant_users (
  tenant_id INT NOT NULL,
  email VARCHAR(320) NOT NULL,
  UNIQUE (tenant_id, email)
);


**NULLs and UNIQUE:** Most RDBMS treat `NULL` as not equal to any other value, allowing multiple `NULL`s in a `UNIQUE` column. Check your target DBMS for exact behavior.

---

## 3. PRIMARY KEY :Uniquely identify each row in a table; implies `UNIQUE` + `NOT NULL`.

**Syntax (single column):**

column_name data_type PRIMARY KEY

**Syntax (table-level composite key):**


PRIMARY KEY (column_a, column_b)


**Examples:**

-- Single-column primary key
CREATE TABLE products (
  product_id INT PRIMARY KEY,
  name VARCHAR(200)
);

-- Composite primary key
CREATE TABLE order_items (
  order_id INT,
  product_id INT,
  quantity INT,
  PRIMARY KEY (order_id, product_id)
);


**Notes:** Primary keys are commonly implemented using indexes under the hood. Many teams use surrogate primary keys (`SERIAL`, `IDENTITY`, `BIGSERIAL`, or `UUID`) for simplicity.

---

## 4. FOREIGN KEY

**Purpose:** Enforce referential integrity: a value in a child table must exist in the referenced parent table.

**Syntax (inline):**

column_name data_type REFERENCES parent_table(parent_column)

**Syntax (table-level with actions):**


FOREIGN KEY (child_col) REFERENCES parent_table(parent_col)
  ON DELETE {CASCADE | SET NULL | RESTRICT | NO ACTION}
  ON UPDATE {CASCADE | SET NULL | RESTRICT | NO ACTION}


**Examples:**

CREATE TABLE customers (
  customer_id INT PRIMARY KEY,
  name VARCHAR(200) NOT NULL
);

CREATE TABLE orders (
  order_id INT PRIMARY KEY,
  customer_id INT NOT NULL,
  order_date DATE NOT NULL,
  FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
    ON DELETE RESTRICT
);

## Example with cascading delete
CREATE TABLE comments (
  comment_id INT PRIMARY KEY,
  post_id INT NOT NULL,
  content TEXT,
  FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE
);


**Notes on ON DELETE / ON UPDATE:**

* `CASCADE` propagates the delete/update to child rows.
* `SET NULL` sets the child column to `NULL` when parent is deleted/updated.
* `RESTRICT`/`NO ACTION` prevents the parent change if related children exist.



## 5. CHECK

**Purpose:** Enforce a boolean expression on column values.

**Syntax (column-level):**


column_name data_type CHECK (column_name > 0)


**Syntax (table-level):**

CHECK (expression)


**Examples:**

CREATE TABLE products (
  product_id INT PRIMARY KEY,
  price NUMERIC(10,2) CHECK (price >= 0),
  stock INT CHECK (stock >= 0)
);

-- Table-level check
CREATE TABLE employees (
  id INT PRIMARY KEY,
  salary NUMERIC(12,2),
  CHECK (salary BETWEEN 0 AND 1000000)
);


**Notes:** CHECK constraints are evaluated on insert and update. Some older DB engines (or specific storage engines like MySQL/MyISAM historically) did not enforce CHECK constraints — modern versions do.

---

## 6. DEFAULT

**Purpose:** Provide a default value for a column when none is supplied at insert.

**Syntax:**

column_name data_type DEFAULT default_value


**Examples:**


CREATE TABLE sessions (
  session_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  is_active BOOLEAN DEFAULT TRUE
);


**Notes:** A `DEFAULT` does not prevent other values; it only supplies a value if none is provided.

---

## 7. COMPOSITE CONSTRAINTS

You can combine constraints on multiple columns. Examples include composite `PRIMARY KEY` and composite `UNIQUE` constraints (shown earlier). Composite checks are also supported:

CREATE TABLE availability (
  resource_id INT,
  start_ts TIMESTAMP,
  end_ts TIMESTAMP,
  CHECK (end_ts > start_ts),
  PRIMARY KEY (resource_id, start_ts)
);


---

## 8. ALTERING / DROPPING CONSTRAINTS

**Add a constraint:**

ALTER TABLE table_name
  ADD CONSTRAINT constraint_name UNIQUE (column_name);

**Drop a constraint:**

ALTER TABLE table_name
  DROP CONSTRAINT constraint_name;


**Examples (PostgreSQL style):**


ALTER TABLE users ADD CONSTRAINT users_email_unique UNIQUE (email);
ALTER TABLE users DROP CONSTRAINT users_email_unique;


*Note:* Syntax can vary across RDBMS. MySQL often uses `DROP INDEX idx_name` for unique constraints declared as indexes. SQL Server uses `ALTER TABLE ... DROP CONSTRAINT` as well.

---

## Constraint enforcement & performance notes

* **Indexes:** `PRIMARY KEY` and `UNIQUE` typically create underlying indexes. This speeds lookups but can slow bulk inserts/updates.
* **Foreign keys:** Provide data integrity but add overhead on deletes/updates in parent tables.
* **CHECKs / NOT NULL / DEFAULT:** Minimal overhead; express business rules close to the data.
* **Order of operations:** On `INSERT`/`UPDATE`, DBMS evaluates defaults, then constraints; the exact order can be DB-specific for complex cases.

When designing tables for high-write workloads, balance integrity requirements with performance: consider whether all constraints must be enforced at the database layer or if some rules can be validated at the application layer (but note the risk of race conditions and integrity errors without DB enforcement).

-------

## Best practices & naming conventions

* Use clear, consistent constraint names, e.g. `pk_<table>`, `uq_<table>_<columns>`, `fk_<child>_<parent>`, `chk_<table>_<shortdesc>`.
* Prefer surrogate `id` primary keys (`bigint`/`uuid`) for most OLTP tables; use composite keys for pure join tables or where natural key uniqueness is crucial.
* Always name foreign-key constraints explicitly — it simplifies migrations and debugging.
* Keep `CHECK` expressions simple and deterministic.
* Document business intent near non-obvious constraints within schema comments or repo README.
Example names:
* `pk_orders`
* `uq_users_email`
* `fk_orders_customers`
* `chk_products_price_positive`

-----

## Example: Complete `CREATE TABLE` script :

-- Example schema for an e-commerce subset
CREATE TABLE customers (
  customer_id BIGSERIAL PRIMARY KEY,
  email VARCHAR(320) NOT NULL,
  full_name TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT uq_customers_email UNIQUE (email)
);

CREATE TABLE products (
  product_id BIGSERIAL PRIMARY KEY,
  sku VARCHAR(64) NOT NULL UNIQUE,
  name TEXT NOT NULL,
  price NUMERIC(10,2) NOT NULL CHECK (price >= 0),
  stock INT NOT NULL DEFAULT 0
);

CREATE TABLE orders (
  order_id BIGSERIAL PRIMARY KEY,
  customer_id BIGINT NOT NULL,
  order_date TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
  status VARCHAR(20) NOT NULL DEFAULT 'pending',
  CONSTRAINT fk_orders_customers FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE RESTRICT
);

CREATE TABLE order_items (
  order_id BIGINT NOT NULL,
  product_id BIGINT NOT NULL,
  unit_price NUMERIC(10,2) NOT NULL CHECK (unit_price >= 0),
  quantity INT NOT NULL CHECK (quantity > 0),
  PRIMARY KEY (order_id, product_id),
  CONSTRAINT fk_orderitems_order FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
  CONSTRAINT fk_orderitems_product FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE RESTRICT
);


