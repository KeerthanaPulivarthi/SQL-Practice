-- Day 1: SQL Fundamentals Practice

-- Create a sample table
CREATE TABLE employees (
    id INT PRIMARY KEY,
    name VARCHAR(50),
    department VARCHAR(30),
    salary DECIMAL(10,2),
    location VARCHAR(30)
);

-- Insert some sample data
INSERT INTO employees VALUES
(1, 'Keerthi', 'IT', 60000, 'Dallas'),
(2, 'Anya', 'HR', 50000, 'Austin'),
(3, 'Rahul', 'Finance', 55000, 'Dallas'),
(4, 'John', 'IT', 62000, 'Houston'),
(5, 'Mia', 'HR', 48000, 'Dallas');

-- SELECT
SELECT * FROM employees;
SELECT name, salary FROM employees;

-- WHERE
SELECT * FROM employees WHERE department = 'IT';
SELECT * FROM employees WHERE salary > 55000;

-- ORDER BY
SELECT * FROM employees ORDER BY salary DESC;

-- LIMIT / TOP (MySQL uses LIMIT)
SELECT * FROM employees LIMIT 3;

-- DISTINCT
SELECT DISTINCT location FROM employees;

-- ALIASES (AS)
SELECT name AS EmployeeName, department AS Dept FROM employees;

-- Arithmetic
SELECT name, salary + 5000 AS UpdatedSalary FROM employees;

-- String operations
SELECT CONCAT(name, ' - ', department) AS EmployeeDetails FROM employees;
SELECT UPPER(name), LOWER(department) FROM employees;

-- Comments
-- Single-line comment example
/* Multi-line comment example:
   Practicing SQL fundamentals */
