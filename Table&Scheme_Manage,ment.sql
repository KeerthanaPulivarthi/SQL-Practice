--Table & Schema Management

--1. CREATE DATABASE: You use this when you want to create a new database (a schema/container for tables and other objects) in your RDBMS. It’s one of the foundational steps in schema setup. 
--Formal Syntax
CREATE DATABASE database_name;

--Example : Suppose you’re starting a new analytics project and want to create a database to hold all your tables:

CREATE DATABASE analyticsDB;

--2. CREATE TABLe: This command creates a new table inside a database, defining its columns (names + data types) and optionally constraints. This is how you model entities in your data-warehouse or transactional schema. 
--Formal Syntax

CREATE TABLE table_name (
    column1 datatype,
    column2 datatype,
    …
);


--Example : Let’s say you want to store user info:

CREATE TABLE Users (
    UserID int,
    FirstName varchar(100),
    LastName varchar(100),
    SignUpDate date
);

--3. ALTER TABLE: When you already have a table and want to change its structure (add/drop/modify columns, or add/drop constraints) you use ALTER TABLE. It’s your go-to for schema evolution. 

--Formal Syntax

--Add a column:

ALTER TABLE table_name
  ADD column_name datatype;


--Drop a column:

ALTER TABLE table_name
  DROP COLUMN column_name;


--Modify data type or rename column (varies by dialect):

ALTER TABLE table_name
  ALTER COLUMN column_name datatype;


--or in MySQL:

ALTER TABLE table_name
  MODIFY COLUMN column_name datatype;


--Examples: Suppose you have a Customers table and you now want to add an Email field:

ALTER TABLE Customers
  ADD Email varchar(255);


--Later you decide you don’t need that column:

ALTER TABLE Customers
  DROP COLUMN Email;

--Tip: For production systems, altering tables can be heavy (locking, downtime) depending on DB-engine—plan accordingly.

--4. DROP TABLE: This command deletes an entire table (structure + data). Use with caution because all the table’s data will be gone. 

--Formal Syntax
DROP TABLE table_name;

--Example : If you created a table for a temporary experiment and now you want to remove it:

DROP TABLE TempSales;

--Always ensure you’re dropping the correct table (backups help). Dropping a table is usually irreversible (unless you have logs/backups).

--5. RENAME TABLE: Sometimes you want to change the name of an existing table, e.g., you built OldOrders but want to call it ArchivedOrders. Depending on your dialect, you may use RENAME TABLE or an ALTER TABLE … RENAME TO command. 

--Formal Syntax (MySQL style)

RENAME TABLE old_table_name TO new_table_name;


--Formal Syntax (ALTER TABLE style)

ALTER TABLE old_table_name
  RENAME TO new_table_name;

--Example: You built UsersTemp while testing; now rename it to UsersProd:

RENAME TABLE UsersTemp TO UsersProd;

or

ALTER TABLE UsersTemp
  RENAME TO UsersProd;

--Tip: After renaming, update any code/views/stored-procedures that reference the old table name.

--6. DATA TYPES: Every column in a table has a data type which defines what kind of data can go into it: integer numbers, character strings, dates, decimals, binary data, etc. Choosing the right data type helps with correctness, performance, and storage. 

--Common Data Types 

/* INT (or INTEGER): whole numbers (e.g., 0, -10, 42)

VARCHAR(n): variable-length string up to n characters (e.g., names, emails)

DATE: calendar date (e.g. 2025-11-09)

DECIMAL(p, s): exact numeric with precision p and scale s (good for money)  */

--Example: In the Orders table you might have:

OrderID int,
CustomerName varchar(200),
OrderDate date,
OrderTotal decimal(10,2)


/* Here:

OrderID uses int

CustomerName uses varchar(200) so you can store up to 200 characters

OrderDate uses date

OrderTotal uses decimal(10,2) meaning up to 10 digits in total, with 2 after the decimal point (e.g., 12345678.90)

Tip: Over-allocating sizes (e.g., varchar(1000) when you need varchar(100)) may waste space or reduce performance; using the “tight but safe” size is a good habit.
