## 📊 Aggregation & Grouping

Aggregate functions are used to perform calculations on multiple rows of a table’s column and return a single value.
They are often used with the `GROUP BY` and `HAVING` clauses to summarize data.

---

### **1️⃣ COUNT(), SUM(), AVG(), MIN(), MAX() — Aggregate Functions**

**Description:**
Used to perform calculations on a set of values (like counting, totaling, or averaging).

**Syntax:**

SELECT 
    AGGREGATE_FUNCTION(column_name)
FROM 
    table_name
WHERE 
    condition;


**Example:**

-- Count number of employees
SELECT COUNT(EmpID) AS TotalEmployees
FROM Employees;

-- Find total and average salary
SELECT 
    SUM(Salary) AS TotalSalary,
    AVG(Salary) AS AverageSalary
FROM Employees;

-- Find minimum and maximum salary
SELECT 
    MIN(Salary) AS MinSalary,
    MAX(Salary) AS MaxSalary
FROM Employees;


💡 *Aggregate functions ignore `NULL` values.*

### **2️⃣ GROUP BY — Group Results by One or More Columns**

**Description:**
Used to group rows that have the same values in specified columns into summary rows.

**Syntax:**

SELECT 
    column_name, 
    AGGREGATE_FUNCTION(column_name)
FROM 
    table_name
GROUP BY 
    column_name;

**Example:**

-- Find total salary by department
SELECT 
    Department, 
    SUM(Salary) AS TotalSalary
FROM Employees
GROUP BY Department;


💡 *`GROUP BY` is used **after WHERE** and **before HAVING** in a query.*


### **3️⃣ HAVING — Filter Grouped Results**

**Description:**
Used to filter the results of `GROUP BY` based on an aggregate condition.
(Unlike `WHERE`, which filters rows before grouping.)

**Syntax:**

SELECT 
    column_name, 
    AGGREGATE_FUNCTION(column_name)
FROM 
    table_name
GROUP BY 
    column_name
HAVING 
    condition;


**Example:

-- Show departments where total salary is greater than 50,000
SELECT 
    Department, 
    SUM(Salary) AS TotalSalary
FROM Employees
GROUP BY Department
HAVING SUM(Salary) > 50000;


🧠 **Key Difference:**

| Clause | Used For               | Applies To | Example                      |
| ------ | ---------------------- | ---------- | ---------------------------- |
| WHERE  | Filter before grouping | Rows       | `WHERE Department = 'HR'`    |
| HAVING | Filter after grouping  | Groups     | `HAVING SUM(Salary) > 50000` |



