# SQL Joins 

## 1. Overview

A **JOIN** in SQL is used to combine rows from two or more tables based on a related column between them. Joins support relational database design by eliminating duplication and enabling scalable querying.

Joins do **not modify data** — they are part of a `SELECT` query and return combined result sets.

Common join types:

* `INNER JOIN` — return matched records only.
* `LEFT JOIN` — return all records from left table + matched records from right.
* `RIGHT JOIN` — return all records from right table + matched records from left.
* `FULL JOIN` — return all matched & unmatched records from both tables.
* `CROSS JOIN` — Cartesian product of two tables.
* `SELF JOIN` — join table to itself.
* `NATURAL JOIN` — join using matching column names automatically.

---

## 2. Why Joins Are Needed

Relational databases use **normalization** — storing logically separated data in different tables. Joins allow combining those tables to answer business questions.

Example queries requiring joins:

* Get customer details and order history.
* Retrieve product pricing with supplier information.
* Generate reports across transaction, user, and location tables.

---

## 3. Sample Dataset Used in Examples


CREATE TABLE customers (
  customer_id INT PRIMARY KEY,
  full_name VARCHAR(150),
  country VARCHAR(80)
);

CREATE TABLE orders (
  order_id INT PRIMARY KEY,
  customer_id INT,
  order_date DATE,
  amount DECIMAL(10,2),
  FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

Sample Data:

INSERT INTO customers VALUES
(1, 'Alice Johnson', 'USA'),
(2, 'David Lee', 'Canada'),
(3, 'Sara Kim', 'USA');

INSERT INTO orders VALUES
(101, 1, '2024-02-01', 350.00),
(102, 1, '2024-02-10', 120.00),
(103, 3, '2024-02-12', 550.00);

---

## 4. INNER JOIN : Returns rows where matching values exist in both tables.

**Syntax:**

SELECT columns
FROM tableA
INNER JOIN tableB
  ON tableA.column = tableB.column;

**Example:**


SELECT c.full_name, o.order_id, o.amount
FROM customers c
INNER JOIN orders o
  ON c.customer_id = o.customer_id;

**Result:** Only customers who placed orders.

---

## 5. LEFT JOIN /LEFT OUTER JOIN :Returns all rows from the left table, plus matching rows from right. Unmatched rows return `NULL`.

**Syntax:**

SELECT columns
FROM tableA
LEFT JOIN tableB
  ON tableA.column = tableB.column;


**Example:**

SELECT c.full_name, o.order_id, o.amount
FROM customers c
LEFT JOIN orders o
  ON c.customer_id = o.customer_id;

**Result:** Includes customers with **no orders** → `NULL` values.

---

## 6. RIGHT JOIN /RIGHT OUTER JOIN : Returns all rows from the right table, plus matched rows from left.

**Syntax:**

SELECT columns
FROM tableA
RIGHT JOIN tableB
  ON tableA.column = tableB.column;

**Example:**

SELECT c.full_name, o.order_id, o.amount
FROM customers c
RIGHT JOIN orders o
  ON c.customer_id = o.customer_id;

**Notes:** Same output as LEFT JOIN if tables swapped. Many SQL developers avoid RIGHT JOIN for readability.

---

## 7. FULL JOIN /FULL OUTER JOIN : Returns all rows when there is a match in either table; unmatched values return `NULL`.

**Syntax:**

SELECT columns
FROM tableA
FULL JOIN tableB
  ON tableA.column = tableB.column;

**Example:**

SELECT c.full_name, o.order_id, o.amount
FROM customers c
FULL JOIN orders o
  ON c.customer_id = o.customer_id;

**Notes:** MySQL does not support FULL JOIN directly — requires `UNION` workaround.

---

## 8. CROSS JOIN

**Definition:** Produces Cartesian product — every row in tableA paired with every row in tableB.

**Syntax:**

SELECT columns
FROM tableA
CROSS JOIN tableB;

**Example:**

SELECT c.full_name, o.order_id
FROM customers c
CROSS JOIN orders o;


**Use cases:** combinations, calendars, matrix reports — use cautiously due to exponential growth.

---

## 9. SELF JOIN : Join a table to itself — useful for hierarchies.

**Syntax:**

SELECT a.column, b.column
FROM tableName a
JOIN tableName b
  ON a.column = b.related_column;

**Example — employees reporting to managers:**

SELECT e.employee_name AS employee,
       m.employee_name AS manager
FROM employees e
LEFT JOIN employees m
  ON e.manager_id = m.employee_id;

---

## 10. NATURAL JOIN

**Definition:** Automatically joins tables using columns with the same name.

**Syntax:**

SELECT columns
FROM tableA
NATURAL JOIN tableB;

**Notes:**

* Not recommended for production — implicit joins reduce clarity.
* Behavior changes if schema changes.

---

## 11. USING Clause : Shorter syntax when join column names are identical.

**Syntax:**


SELECT columns
FROM tableA
JOIN tableB USING (column_name);

**Example:**

SELECT full_name, order_id, amount
FROM customers
JOIN orders USING (customer_id);

**Notes:** Supported in PostgreSQL, MySQL — not in SQL Server.

---

## 12. Multiple Table Joins

**Example — customers + orders + products:**

SELECT c.full_name, o.order_id, p.name, p.price
FROM customers c
JOIN orders o
  ON c.customer_id = o.customer_id
JOIN order_items oi
  ON o.order_id = oi.order_id
JOIN products p
  ON oi.product_id = p.product_id;

**Best rule:** Join one table at a time — ensure join conditions are explicit.

---

## 13. Join Conditions & Filtering

**Filter in ON clause:** affects join result

SELECT c.full_name, o.order_id
FROM customers c
LEFT JOIN orders o
  ON c.customer_id = o.customer_id
  AND o.amount > 300;

**Filter in WHERE clause:** removes non-matching rows


SELECT c.full_name, o.order_id
FROM customers c
LEFT JOIN orders o
  ON c.customer_id = o.customer_id
WHERE o.amount > 300;

**Important difference:** WHERE turns LEFT JOIN into INNER JOIN.

---

## 16. End-to-End Example Query

SELECT c.customer_id,
       c.full_name,
       COUNT(o.order_id) AS total_orders,
       SUM(o.amount) AS total_spent
FROM customers c
LEFT JOIN orders o
  ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.full_name
ORDER BY total_spent DESC;

**Purpose:** Return each customer's total order count and revenue — includes customers with no orders.





