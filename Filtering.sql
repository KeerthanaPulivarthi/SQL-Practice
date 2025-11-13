## 🧩 2. Filtering & Conditions in SQL

Filtering allows us to retrieve only the rows that meet certain conditions. It’s one of the most important parts of data analysis, as it helps us focus on relevant data.

---

### 🔹 1. `AND`, `OR`, `NOT`

**Description:**
These logical operators help combine multiple conditions in a `WHERE` clause.

* `AND` returns rows when **all** conditions are true.
* `OR` returns rows when **any** condition is true.
* `NOT` excludes rows that match a condition.

**Syntax:**

SELECT column1, column2
FROM table_name
WHERE condition1 AND/OR/NOT condition2;


**Example:**

-- Find employees who work in 'Sales' department and earn more than 50000
SELECT name, department, salary
FROM employees
WHERE department = 'Sales' AND salary > 50000;


---

### 🔹 2. `IN`, `BETWEEN`, `LIKE`

**Description:**
These are special filtering operators that make queries cleaner and more readable.

* `IN` checks if a value matches any value in a list.
* `BETWEEN` checks if a value is within a range.
* `LIKE` is used for pattern matching in text (with `%` or `_`).

**Syntax:**

-- IN
SELECT column_name FROM table_name WHERE column_name IN (value1, value2, ...);

-- BETWEEN
SELECT column_name FROM table_name WHERE column_name BETWEEN value1 AND value2;

-- LIKE
SELECT column_name FROM table_name WHERE column_name LIKE 'pattern';

**Example:**

-- Find customers from specific cities
SELECT customer_name, city
FROM customers
WHERE city IN ('New York', 'Chicago', 'Boston');

-- Find orders placed between two dates
SELECT order_id, order_date
FROM orders
WHERE order_date BETWEEN '2024-01-01' AND '2024-12-31';

-- Find employees whose names start with 'A'
SELECT name
FROM employees
WHERE name LIKE 'A%';

### 🔹 3. `IS NULL` / `IS NOT NULL`

**Description:**
Used to filter records with missing (NULL) values.
You can’t use `= NULL` or `!= NULL` because NULL represents *unknown* data.

**Syntax:**
SELECT column_name
FROM table_name
WHERE column_name IS NULL;

SELECT column_name
FROM table_name
WHERE column_name IS NOT NULL;


**Example:**

-- Find employees who don’t have a manager assigned
SELECT name, manager_id
FROM employees
WHERE manager_id IS NULL;

---

### 🔹 4. `CASE WHEN THEN ELSE END`

**Description:**
`CASE` is like an IF-ELSE statement in SQL. It allows you to apply conditional logic and create new columns based on conditions.

**Syntax:**

SELECT column1,
       CASE
           WHEN condition1 THEN result1
           WHEN condition2 THEN result2
           ELSE default_result
       END AS new_column
FROM table_name;


**Example:**
-- Categorize employees based on salary
SELECT name, salary,
       CASE
           WHEN salary > 80000 THEN 'High'
           WHEN salary BETWEEN 50000 AND 80000 THEN 'Medium'
           ELSE 'Low'
       END AS salary_category
FROM employees;

### 💡 Summary

| Operator       | Purpose                     | Example                                |
| -------------- | --------------------------- | -------------------------------------- |
| AND / OR / NOT | Combine multiple conditions | `salary > 50000 AND department = 'HR'` |
| IN             | Match any value in a list   | `city IN ('Dallas', 'Austin')`         |
| BETWEEN        | Match values in a range     | `age BETWEEN 25 AND 40`                |
| LIKE           | Pattern match               | `name LIKE 'A%'`                       |
| IS NULL        | Find missing data           | `email IS NULL`                        |
| CASE           | Apply conditional logic     | `CASE WHEN score > 90 THEN 'A'`        |

