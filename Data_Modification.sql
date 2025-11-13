## 🧩 Data Manipulation (DML) Commands

DML (Data Manipulation Language) statements are used to manage data within tables — adding, updating, or removing records.



--1️⃣ INSERT INTO — Add New Records**

**Description:**
Used to insert new rows into a table.

**Syntax:**

INSERT INTO table_name (column1, column2, column3, ...)
VALUES (value1, value2, value3, ...);


**Example:**

INSERT INTO Employees (EmpID, FirstName, LastName, Department)
VALUES (101, 'John', 'Doe', 'HR');


Tip: *If you want to insert values into all columns in order, you can skip the column names:*


INSERT INTO Employees
VALUES (102, 'Emma', 'Smith', 'Finance');


--2️⃣ UPDATE — Modify Existing Records**

**Description:**
Used to change existing data in one or more rows.

**Syntax:**

UPDATE table_name
SET column1 = value1, column2 = value2, ...
WHERE condition;


Example:

UPDATE Employees
SET Department = 'Marketing'
WHERE EmpID = 101;


Note: *Always use a `WHERE` clause to avoid updating all records.*

---

### **3️⃣ DELETE — Remove Specific Records**

**Description:**
Deletes one or more rows from a table.

**Syntax:**

DELETE FROM table_name
WHERE condition;


**Example:**

DELETE FROM Employees
WHERE EmpID = 102;


⚠️ *Without a `WHERE` clause, **all rows** will be deleted.*

--4️⃣ TRUNCATE / DROP — Remove All Data or Table**

**Description:**
`TRUNCATE` removes all rows from a table but keeps the table structure.
`DROP` removes the entire table from the database.

Syntax:

-- Remove all rows (faster, resets identity)
TRUNCATE TABLE table_name;

-- Delete the table completely
DROP TABLE table_name;


--Example: 

TRUNCATE TABLE Employees;
DROP TABLE Employees;

##Easy Picturication btw Delete, truncate, drop;
Difference:

Command	          Removes_Data	    Removes_Table_Structure	    Rollback Possible
DELETE	           ✅ Yes	         ❌ No	                  ✅ Yes (if in transaction)
TRUNCATE	       ✅ Yes	         ❌ No	                  ❌ No
DROP	           ✅ Yes	         ✅ Yes	                  ❌ No