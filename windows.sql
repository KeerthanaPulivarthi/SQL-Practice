## What are window functions?

Window functions (sometimes called *analytic functions*) compute values over a set of rows related to the current row without collapsing the result set. Unlike aggregate functions used with `GROUP BY` (which reduce rows), window functions return a value for each input row while allowing calculations across partitions (groups) of rows.

Use cases:

* Running totals and moving averages
* Row numbering and rankings
* Finding previous/next row values (`LAG`, `LEAD`)
* Calculating percentiles and distribution buckets
* Comparing rows in the same partition without self-joins

Supported by major SQL engines (PostgreSQL, SQL Server, MySQL, Oracle, BigQuery, etc.). Syntax may vary slightly between engines, but concepts are portable.

---

## General syntax

<window_function>(<expression>) OVER (
    [ PARTITION BY <expr1>, <expr2>, ... ]
    [ ORDER BY <order_expr1> [ASC|DESC], ... ]
    [ ROWS|RANGE <frame_spec> ]  -- optional framing clause
)

* `OVER(...)` identifies the window specification.
* `PARTITION BY` splits rows into independent windows (like groups).
* `ORDER BY` defines order inside each partition (required for ranking and framing).
* `ROWS` / `RANGE` define the frame (which rows relative to current row are considered).
---
## Common window functions

### Ranking

* `ROW_NUMBER()` — unique increasing number per partition (ties broken by ORDER BY).
* `RANK()` — assigns same rank to tied rows, gaps after ties.
* `DENSE_RANK()` — assigns same rank to tied rows, no gaps.
* `NTILE(n)` — distributes rows into `n` buckets (useful for quartiles).

### Value access

* `LAG(expr [, offset [, default]])` — previous row value.
* `LEAD(expr [, offset [, default]])` — next row value.
* `FIRST_VALUE(expr)`, `LAST_VALUE(expr)` — first/last value in the frame.

### Aggregates as window functions

Aggregate functions used with `OVER()`:

* `SUM()`, `AVG()`, `MIN()`, `MAX()`, `COUNT()` — provide running totals, rolling averages, etc.

### Statistical / percentiles (engine-dependent)

* `PERCENT_RANK()`, `CUME_DIST()`, `PERCENTILE_CONT()` (or equivalent) — for distribution analysis.

---

## Example dataset
We will use a simple `sales` table for examples:

CREATE TABLE sales (
  sale_id      INT PRIMARY KEY,
  sales_date   DATE,
  region       VARCHAR(20),
  salesperson  VARCHAR(50),
  amount       NUMERIC(10,2)
);

INSERT INTO sales (sale_id, sales_date, region, salesperson, amount) VALUES
(1, '2025-01-01', 'East', 'Alice', 100.00),
(2, '2025-01-02', 'East', 'Bob', 200.00),
(3, '2025-01-03', 'West', 'Carol', 150.00),
(4, '2025-01-04', 'East', 'Alice', 120.00),
(5, '2025-01-05', 'West', 'Dave', 300.00),
(6, '2025-01-06', 'East', 'Bob', 80.00),
(7, '2025-01-07', 'West', 'Carol', 50.00);


## Examples

### 1) Row numbering within partitions

Number each sale per region in chronological order:

SELECT
  sale_id,
  sales_date,
  region,
  salesperson,
  amount,
  ROW_NUMBER() OVER (PARTITION BY region ORDER BY sales_date) AS row_in_region
FROM sales
ORDER BY region, sales_date;

**Result:** every row gets a 1..n integer per `region`.

---

### 2) Ranking top sellers per region

Find ranking of sales amounts per salesperson within each region:

SELECT
  salesperson,
  region,
  amount,
  RANK() OVER (PARTITION BY region ORDER BY amount DESC) AS rank_in_region,
  DENSE_RANK() OVER (PARTITION BY region ORDER BY amount DESC) AS dense_rank_in_region
FROM sales
ORDER BY region, rank_in_region;

**Note:** `RANK()` leaves gaps when ties occur; `DENSE_RANK()` does not.

---

### 3) Running total (cumulative sum)

Compute cumulative sales per region by date:

SELECT
  sale_id,
  sales_date,
  region,
  amount,
  SUM(amount) OVER (
    PARTITION BY region
    ORDER BY sales_date
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
  ) AS cumulative_sales
FROM sales
ORDER BY region, sales_date;

Common for dashboards showing progress over time.

---

### 4) Moving average (3-period) per region

A 3-period moving average of amount per region:

SELECT
  sale_id,
  sales_date,
  region,
  amount,
  AVG(amount) OVER (
    PARTITION BY region
    ORDER BY sales_date
    ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
  ) AS moving_avg_3
FROM sales
ORDER BY region, sales_date;

ROWS BETWEEN 2 PRECEDING AND CURRENT ROW includes the current row and two previous rows.

---

### 5) Previous and next values

Show previous and next sale amount for each salesperson (useful for churn/change detection):

SELECT
  sale_id,
  sales_date,
  salesperson,
  amount,
  LAG(amount, 1) OVER (PARTITION BY salesperson ORDER BY sales_date) AS prev_amount,
  LEAD(amount, 1) OVER (PARTITION BY salesperson ORDER BY sales_date) AS next_amount
FROM sales
ORDER BY salesperson, sales_date;

If there is no previous/next row, these functions return `NULL` (or the provided default).

---

### 6) Top-N per group (e.g., top 2 sales per region)

A pattern that avoids subqueries:

SELECT *
FROM (
  SELECT
    sale_id,
    region,
    salesperson,
    amount,
    ROW_NUMBER() OVER (PARTITION BY region ORDER BY amount DESC) AS rn
  FROM sales
) t
WHERE rn <= 2
ORDER BY region, rn;

This is efficient and readable compared to correlated subqueries.

---

### 7) Percentiles and distribution (example: percentile rank)

SELECT
  sale_id,
  region,
  amount,
  PERCENT_RANK() OVER (PARTITION BY region ORDER BY amount) AS pct_rank,
  CUME_DIST() OVER (PARTITION BY region ORDER BY amount) AS cume_dist
FROM sales;

PERCENT_RANK() gives relative standing between 0 and 1. `CUME_DIST()` gives the proportion of rows with value <= current row.

---

## Framing: `ROWS` vs `RANGE`

* `ROWS` frames are based on physical offsets (e.g., "2 PRECEDING").
* `RANGE` frames are value-based (e.g., "BETWEEN INTERVAL '7 days' PRECEDING AND CURRENT ROW" when ORDER BY a date) and treat rows with the same ORDER BY value as peers.

Example subtlety: when ORDER BY contains ties, `RANGE` may include all tied rows; `ROWS` uses precise positional offsets.

---

## Performance considerations & best practices

1. Indexing:For large tables, ensure indexes support ordering/partitioning columns where possible. This helps sort performance.
2. Avoid unnecessary `ORDER BY`: Window `ORDER BY` is required for many functions — but don't order by extra columns you don't need.
3. Limit dataset early: Use `WHERE` to reduce rows before window calculations if business logic permits.
4. Materialize heavy intermediate results: In complex pipelines, create temporary tables or CTEs to break work into smaller steps; some engines optimize better with staged materialization.
5. Be conscious of memory and sorting costs: Window functions often require sorting; with very large partitions, memory and I/O can grow. Consider batching or summarizing when possible.
6. Prefer ROW_NUMBER() for Top-N queries: Its deterministic with tie-breaking in ORDER BY; if ties must be retained, use RANK()/DENSE_RANK() intentionally.

---

## Portability notes

* Syntax for window functions is standardized in SQL:2003 and widely supported.
* Differences between DB engines:

  * Precise behavior of `RANGE` with non-numeric ORDER BY values may differ.
  * Some analytic functions have different names or additional features (e.g., `PERCENTILE_CONT` in Oracle/Postgres).
  * MySQL added window functions in 8.0; older versions do not support them.

When writing cross-engine SQL, test the queries on the target engine and prefer standard constructs when possible.

---

## Summary (quick reference)

* Window functions compute over a set of rows related to the current row without collapsing rows.
* Core parts of a window spec: `PARTITION BY`, `ORDER BY`, and optional frame (`ROWS` / `RANGE`).
* Common functions: `ROW_NUMBER()`, `RANK()`, `DENSE_RANK()`, `NTILE()`, `LAG()`, `LEAD()`, `FIRST_VALUE()`, `LAST_VALUE()`, `SUM()`, `AVG()`.
* Use window functions for rankings, running totals, moving aggregates, and neighbor comparisons — they simplify complex SQL and often increase performance versus joins.

-

