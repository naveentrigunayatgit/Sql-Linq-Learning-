# Section 1 (C & D): Joins, Subqueries, SQL Objects, Window Functions & Advanced SQL

## Table of Contents

- [Sample Data Used in This Section](#sample-data-used-in-this-section)
- [C. Joins, Subqueries and SQL Objects (Q36–Q55)](#c-joins-subqueries-and-sql-objects)
  - [Q36 Types of Joins](#q36-explain-all-types-of-joins-with-examples) · [Q37 INNER vs LEFT vs RIGHT vs FULL](#q37-inner-join-vs-left-join-vs-right-join-vs-full-outer-join) · [Q38 CROSS JOIN](#q38-what-is-cross-join) · [Q39 SELF JOIN](#q39-what-is-self-join) · [Q40 JOIN vs Subquery](#q40-what-is-the-difference-between-join-and-subquery)
  - [Q41 Correlated Subquery](#q41-what-is-correlated-subquery) · [Q42 Subquery vs CTE](#q42-subquery-vs-cte) · [Q43 CTE / Recursive CTE](#q43-what-is-a-cte-explain-recursive-cte) · [Q44 CTE vs Temp Table](#q44-cte-vs-temporary-table) · [Q45 #Temp vs @Table](#q45-temporary-table-temp-vs-table-variable-table)
  - [Q46 Temp vs Permanent](#q46-temporary-table-vs-permanent-table) · [Q47 SP vs Function](#q47-stored-procedure-vs-function) · [Q48 Scalar vs TVF](#q48-scalar-function-vs-table-valued-function) · [Q49 Inline TVF](#q49-what-is-an-inline-table-valued-function) · [Q50 Triggers](#q50-what-are-triggers-explain-after-and-instead-of-triggers)
  - [Q51 Magic Tables](#q51-what-are-magic-tables-inserted-and-deleted) · [Q52 Views](#q52-what-is-a-view-can-we-update-data-through-a-view) · [Q53 Indexed View](#q53-what-is-an-indexed-view) · [Q54 Synonym](#q54-what-is-a-synonym-in-sql-server) · [Q55 Dynamic SQL](#q55-what-is-a-dynamic-sql-query-when-should-you-use-it)
- [D. Window Functions and Advanced SQL (Q56–Q75)](#d-window-functions-and-advanced-sql)
  - [Q56 ROW_NUMBER](#q56-what-is-row_number) · [Q57 ROW_NUMBER vs RANK vs DENSE_RANK](#q57-difference-between-row_number-rank-and-dense_rank) · [Q58 PARTITION BY](#q58-what-is-partition-by) · [Q59 PARTITION BY vs GROUP BY](#q59-what-is-the-difference-between-partition-by-and-group-by) · [Q60 Ties](#q60-what-are-ties-in-ranking-functions)
  - [Q61 NTILE](#q61-what-is-ntile) · [Q62 LAG/LEAD](#q62-what-are-lag-and-lead-functions) · [Q63 FIRST_VALUE/LAST_VALUE](#q63-what-is-first_value-and-last_value) · [Q64 ROWS vs RANGE](#q64-what-is-the-difference-between-rows-and-range-in-window-functions) · [Q65 PIVOT/UNPIVOT](#q65-what-is-pivot-and-unpivot)
  - [Q66 UNION vs UNION ALL](#q66-what-is-the-difference-between-union-and-union-all) · [Q67 INTERSECT vs EXCEPT](#q67-what-is-the-difference-between-intersect-and-except) · [Q68 ISNULL vs COALESCE](#q68-what-is-the-difference-between-isnull-and-coalesce) · [Q69 CASE vs IIF](#q69-what-is-the-difference-between-case-and-iif) · [Q70 EXISTS vs IN](#q70-what-is-the-difference-between-exists-and-in)
  - [Q71 COUNT variants](#q71-what-is-the-difference-between-count-count1-and-countcolumnname) · [Q72 DELETE vs TRUNCATE vs DROP](#q72-what-is-the-difference-between-delete-truncate-and-drop) · [Q73 MERGE](#q73-what-is-merge-in-sql-server-what-are-its-limitations-and-potential-risks) · [Q74 Dynamic Pivoting](#q74-what-is-dynamic-pivoting) · [Q75 TVP](#q75-how-can-you-pass-unlimited-parameters-to-a-stored-procedure-explain-table-valued-parameters-tvp)

---

## Sample Data Used in This Section

```sql
CREATE TABLE Department (DepartmentId INT PRIMARY KEY, DepartmentName VARCHAR(50));
INSERT INTO Department VALUES (1,'IT'),(2,'HR'),(3,'Finance');

CREATE TABLE Employee (
    EmployeeId   INT PRIMARY KEY,
    EmployeeName VARCHAR(50),
    DepartmentId INT REFERENCES Department(DepartmentId),
    ManagerId    INT NULL,
    Salary       DECIMAL(10,2),
    JoiningDate  DATE
);
INSERT INTO Employee VALUES
(101,'Amit', 1,NULL,80000,'2022-01-10'),
(102,'Rahul',1,101, 60000,'2023-03-15'),
(103,'Priya',2,NULL,90000,'2021-06-20'),
(104,'Sneha',2,103, 70000,'2024-01-05'),
(105,'Raj',  1,101, 60000,'2023-08-10');

CREATE TABLE EmployeeSalaryHistory (Id INT IDENTITY PRIMARY KEY, EmployeeId INT, Salary DECIMAL(10,2), EffectiveDate DATE);
INSERT INTO EmployeeSalaryHistory (EmployeeId, Salary, EffectiveDate) VALUES
(102,50000,'2023-03-15'),(102,55000,'2024-04-01'),(102,60000,'2025-04-01'),
(104,65000,'2024-01-05'),(104,70000,'2025-01-05');

CREATE TABLE EmployeeAttendance (Id INT IDENTITY PRIMARY KEY, EmployeeId INT, AttendanceDate DATE, Status VARCHAR(10));
INSERT INTO EmployeeAttendance (EmployeeId, AttendanceDate, Status) VALUES
(101,'2025-06-02','Present'),(101,'2025-06-03','Absent'),
(102,'2025-06-02','Present'),(102,'2025-06-03','Present'),
(104,'2025-06-02','Leave');
```

> Note: Department 3 (Finance) has **no employees** — this is useful for showing outer-join behaviour.

---

## C. Joins, Subqueries and SQL Objects

### Q36. Explain all types of Joins with examples.

**Definition:** A JOIN combines rows from two or more tables based on a related column. SQL Server supports INNER, LEFT OUTER, RIGHT OUTER, FULL OUTER, CROSS and SELF joins (plus `CROSS APPLY` / `OUTER APPLY` for row-by-row correlated joins).

**Real-world example:** Think of an HR office with two registers: one for employees and one for departments. Joining them is like matching each employee card with the correct department card. INNER = only matched pairs; LEFT = all employee cards even if department is missing; FULL = every card from both registers.

**SQL example:**
```sql
-- INNER JOIN: only matching rows
SELECT e.EmployeeName, d.DepartmentName
FROM Employee e
INNER JOIN Department d ON d.DepartmentId = e.DepartmentId;

-- LEFT JOIN: all departments, employees if any
SELECT d.DepartmentName, e.EmployeeName
FROM Department d
LEFT JOIN Employee e ON e.DepartmentId = d.DepartmentId;

-- CROSS JOIN: every combination (5 x 3 = 15 rows)
SELECT e.EmployeeName, d.DepartmentName FROM Employee e CROSS JOIN Department d;

-- SELF JOIN: employee with manager
SELECT e.EmployeeName, m.EmployeeName AS ManagerName
FROM Employee e
LEFT JOIN Employee m ON m.EmployeeId = e.ManagerId;

-- OUTER APPLY: latest salary-history row per employee
SELECT e.EmployeeName, h.Salary, h.EffectiveDate
FROM Employee e
OUTER APPLY (SELECT TOP (1) Salary, EffectiveDate
             FROM EmployeeSalaryHistory s
             WHERE s.EmployeeId = e.EmployeeId
             ORDER BY EffectiveDate DESC) h;
```

Output of the LEFT JOIN (Department → Employee):

| DepartmentName | EmployeeName |
|---|---|
| IT | Amit |
| IT | Rahul |
| IT | Raj |
| HR | Priya |
| HR | Sneha |
| Finance | NULL |

**Interview answer (7 yrs experience):** "In our HRMS, joins are everywhere — employee with department, manager, payroll, attendance. I use INNER JOIN when the relationship is mandatory, like an employee and their payroll run, and LEFT JOIN when it's optional, like 'show all departments with headcount including empty ones'. A common bug I've seen in code reviews is putting a filter on the right table in the WHERE clause of a LEFT JOIN, which silently turns it into an INNER JOIN — the filter must go into the ON clause. For 'top N per group' like the latest salary revision, I prefer `OUTER APPLY` with `TOP 1` or a `ROW_NUMBER()` CTE. RIGHT JOIN I almost never write; I just swap the table order and use LEFT JOIN because it reads better."

**Follow-up / Pro tip:**
- `LEFT JOIN ... WHERE right.Col = 'X'` behaves like INNER JOIN; move the condition into `ON` to keep unmatched rows.
- Joining on columns of different data types causes implicit conversion and can kill index seeks.

---

### Q37. INNER JOIN vs LEFT JOIN vs RIGHT JOIN vs FULL OUTER JOIN.

**Definition:** They differ in which **unmatched** rows are kept. INNER keeps only matches; LEFT keeps all left rows; RIGHT keeps all right rows; FULL keeps all rows from both sides, filling missing parts with NULL.

**Real-world example:** A bank matching customers to loans: INNER = customers who have a loan; LEFT (Customer→Loan) = all customers, with loan info if any; RIGHT = all loans even if the customer record is missing; FULL = everything, useful for reconciliation.

**SQL example:**
```sql
SELECT e.EmployeeName, d.DepartmentName
FROM Employee e
FULL OUTER JOIN Department d ON d.DepartmentId = e.DepartmentId;
```

| Join type (Employee e ⟷ Department d) | Rows returned | Finance appears? |
|---|---|---|
| `INNER JOIN` | 5 | No |
| `LEFT JOIN` (Employee left) | 5 | No |
| `RIGHT JOIN` (Department right) | 6 | Yes, EmployeeName = NULL |
| `FULL OUTER JOIN` | 6 | Yes, EmployeeName = NULL |

| Feature | INNER | LEFT | RIGHT | FULL OUTER |
|---|---|---|---|---|
| Matched rows | ✔ | ✔ | ✔ | ✔ |
| Unmatched left rows | ✘ | ✔ (NULLs on right) | ✘ | ✔ |
| Unmatched right rows | ✘ | ✘ | ✔ (NULLs on left) | ✔ |
| Typical use | Mandatory relation | Optional relation, "find missing" | Rarely (rewrite as LEFT) | Reconciliation / data comparison |

> If an employee had `DepartmentId = NULL`, that employee would appear only in LEFT and FULL results.

**Interview answer (7 yrs experience):** "INNER JOIN gives the intersection, LEFT keeps everything from the left table, RIGHT is the mirror, and FULL keeps both sides. In our HRMS, I used LEFT JOIN with `WHERE a.Id IS NULL` to find employees who didn't mark attendance on a given day — an anti-join pattern. FULL OUTER JOIN was very useful when we migrated payroll data from a legacy system; we compared old and new tables to find rows missing on either side. One pitfall is row multiplication — if the right table has multiple matches, a LEFT JOIN returns more rows than the left table, which can double-count SUMs in reports. I always check the grain of each table before joining."

**Follow-up / Pro tip:**
- For "find missing rows", `NOT EXISTS` is usually as fast or faster than `LEFT JOIN ... IS NULL` and is clearer.

---

### Q38. What is CROSS JOIN?

**Definition:** A CROSS JOIN returns the Cartesian product — every row of the first table combined with every row of the second. It has no ON clause.

**Real-world example:** A clothing store combining 3 sizes with 4 colours to generate all 12 product variants.

**SQL example:**
```sql
-- Generate an attendance grid: every employee x every day of a week
WITH Days AS (
    SELECT CAST('2025-06-02' AS DATE) AS D
    UNION ALL SELECT DATEADD(DAY, 1, D) FROM Days WHERE D < '2025-06-06'
)
SELECT e.EmployeeId, e.EmployeeName, d.D AS AttendanceDate,
       ISNULL(a.Status, 'Not Marked') AS Status
FROM Employee e
CROSS JOIN Days d
LEFT JOIN EmployeeAttendance a
       ON a.EmployeeId = e.EmployeeId AND a.AttendanceDate = d.D;
-- 5 employees x 5 days = 25 rows
```

**Interview answer (7 yrs experience):** "CROSS JOIN gives all combinations, so the row count is the product of both tables. I use it deliberately in HRMS for attendance and leave calendars: cross-join employees with a calendar/date table and then LEFT JOIN actual attendance to show 'Not Marked' days. Another use is building matrices like department × month for reports. The risk is accidental Cartesian products — a missing join condition on two large tables can produce millions of rows and fill tempdb. So I only use it when the second set is small and known."

---

### Q39. What is SELF JOIN?

**Definition:** A SELF JOIN is a table joined to itself using two different aliases. It is used when rows in a table relate to other rows in the same table.

**Real-world example:** An employee list where each employee's manager is also an employee in the same list.

**SQL example:**
```sql
SELECT e.EmployeeName, ISNULL(m.EmployeeName, 'No Manager') AS ManagerName
FROM Employee e
LEFT JOIN Employee m ON m.EmployeeId = e.ManagerId;
```

| EmployeeName | ManagerName |
|---|---|
| Amit | No Manager |
| Rahul | Amit |
| Priya | No Manager |
| Sneha | Priya |
| Raj | Amit |

**Interview answer (7 yrs experience):** "A self join is just a normal join where both sides are the same table, distinguished by aliases. In our HRMS the classic case is `ManagerId` pointing to `EmployeeId`, so to show the reporting manager's name we self-join Employee. I use LEFT JOIN so top-level managers with NULL ManagerId aren't dropped. Self joins are also handy for finding duplicates or comparing rows, like employees in the same department with the same salary. For multi-level hierarchies, a single self join only goes one level, so I switch to a recursive CTE."

**Follow-up / Pro tip:**
- Find employees earning more than their manager: `... JOIN Employee m ON m.EmployeeId = e.ManagerId WHERE e.Salary > m.Salary`.

---

### Q40. What is the difference between JOIN and Subquery?

**Definition:** A JOIN combines columns from multiple tables into one result set. A subquery is a query nested inside another query, typically used to filter or compute a value.

**Real-world example:** JOIN is like putting two lists side by side to read both; a subquery is like first asking "which departments are in Mumbai?" and then using that answer to filter employees.

**SQL example:**
```sql
-- JOIN: need columns from both tables
SELECT e.EmployeeName, d.DepartmentName
FROM Employee e JOIN Department d ON d.DepartmentId = e.DepartmentId
WHERE d.DepartmentName = 'IT';

-- Subquery: only filtering
SELECT EmployeeName FROM Employee
WHERE DepartmentId IN (SELECT DepartmentId FROM Department WHERE DepartmentName = 'IT');
-- Both return: Amit, Rahul, Raj
```

| Aspect | JOIN | Subquery |
|---|---|---|
| Columns from both tables | Yes | Only from outer query (unless in SELECT list) |
| Readability | Better for many tables | Better for "exists / in" logic |
| Duplicates | Can multiply rows if 1-to-many | `IN`/`EXISTS` never duplicate outer rows |
| Performance | Optimizer often produces the same plan | Same plan in most cases; correlated scalar subqueries can be slower |
| Used in | FROM clause | SELECT, FROM, WHERE, HAVING |

**Interview answer (7 yrs experience):** "Functionally many subqueries can be rewritten as joins, and SQL Server's optimizer usually converts `IN`/`EXISTS` subqueries into semi-joins, so performance is often identical. I choose based on intent: if I need columns from the other table I join; if I only need to check existence I use `EXISTS` because it avoids duplicate rows from one-to-many relationships. I've fixed reports in our HRMS where someone joined Employee to Attendance just to filter 'employees with any attendance' and got duplicated salary totals — `EXISTS` fixed it. Scalar subqueries in the SELECT list that run per row can be costly, so there I'd consider a join with aggregation or `OUTER APPLY`."

---

### Q41. What is Correlated Subquery?

**Definition:** A correlated subquery refers to columns of the outer query, so logically it is evaluated once for every outer row. It cannot run independently.

**Real-world example:** For each student, the teacher checks "is this student's mark above *their own class's* average?" — the average changes depending on the student's class.

**SQL example:**
```sql
-- Employees earning more than their department average
SELECT e.EmployeeName, e.DepartmentId, e.Salary
FROM Employee e
WHERE e.Salary > (SELECT AVG(e2.Salary)
                  FROM Employee e2
                  WHERE e2.DepartmentId = e.DepartmentId);
```

| EmployeeName | DepartmentId | Salary |
|---|---|---|
| Amit | 1 | 80000 |
| Priya | 2 | 90000 |

(IT avg = 66,666.67; HR avg = 80,000)

**Interview answer (7 yrs experience):** "A correlated subquery depends on the outer row — here the department average is computed per employee's department. Logically it runs once per row, but in practice SQL Server's optimizer often rewrites it into a join or a stream aggregate, so it isn't always slow. Where it hurts is in the SELECT list on large tables when the optimizer can't decorrelate it — then it becomes a nested loop with repeated scans. In our HRMS reports I usually rewrite such logic using a window function like `AVG(Salary) OVER (PARTITION BY DepartmentId)`, which scans the table once. `EXISTS` / `NOT EXISTS` are also correlated subqueries and those perform very well with proper indexes."

---

### Q42. Subquery vs CTE.

**Definition:** A subquery is a query nested inline inside another statement. A CTE (Common Table Expression) is a named temporary result defined with `WITH` before the main statement, which improves readability and supports recursion.

**Real-world example:** A subquery is like writing a note in the margin of a page; a CTE is like writing a named footnote at the top that you can refer to by name.

**SQL example:**
```sql
-- Subquery (derived table)
SELECT * FROM (
    SELECT DepartmentId, AVG(Salary) AS AvgSal FROM Employee GROUP BY DepartmentId
) x WHERE x.AvgSal > 70000;

-- Same with CTE
WITH DeptAvg AS (
    SELECT DepartmentId, AVG(Salary) AS AvgSal FROM Employee GROUP BY DepartmentId
)
SELECT * FROM DeptAvg WHERE AvgSal > 70000;
-- Result: DepartmentId 2, AvgSal 80000
```

| Aspect | Subquery | CTE |
|---|---|---|
| Naming / reuse | No name; must repeat to reuse | Named; can be referenced multiple times in the same statement |
| Readability | Hard when deeply nested | Top-down, readable |
| Recursion | Not possible | Supported (recursive CTE) |
| Scope | The statement it's in | Only the immediately following statement |
| Performance | Same — CTE is inlined like a derived table, **not** materialized | Same; referencing it twice executes it twice |

**Interview answer (7 yrs experience):** "Performance-wise a non-recursive CTE and a derived-table subquery are the same — SQL Server inlines the CTE into the main query. The difference is readability and recursion. I use CTEs when a query has multiple logical steps, like filtering, then ranking with ROW_NUMBER, then picking rank 1 — that's much cleaner than three nested subqueries. One misconception I correct in interviews and code reviews is that a CTE caches results; if you reference it twice, it's evaluated twice. If I need reuse of an expensive result, I put it into a temp table instead."

---

### Q43. What is a CTE? Explain Recursive CTE.

**Definition:** A CTE is a temporary named result set defined with `WITH` that exists only for the next statement. A recursive CTE references itself: an **anchor** query gives the starting rows and a **recursive** member (joined with `UNION ALL`) repeatedly adds rows until no new rows are returned.

**Real-world example:** An organization chart — start with the CEO (anchor), then find people reporting to them, then people reporting to those, and so on.

**SQL example:**
```sql
WITH OrgChart AS (
    -- Anchor: top-level managers
    SELECT EmployeeId, EmployeeName, ManagerId, 1 AS Lvl,
           CAST(EmployeeName AS VARCHAR(500)) AS Path
    FROM Employee
    WHERE ManagerId IS NULL
    UNION ALL
    -- Recursive member
    SELECT e.EmployeeId, e.EmployeeName, e.ManagerId, o.Lvl + 1,
           CAST(o.Path + ' > ' + e.EmployeeName AS VARCHAR(500))
    FROM Employee e
    INNER JOIN OrgChart o ON e.ManagerId = o.EmployeeId
)
SELECT EmployeeId, EmployeeName, Lvl, Path
FROM OrgChart
ORDER BY Path
OPTION (MAXRECURSION 100);   -- default is 100; 0 = unlimited
```

| EmployeeId | EmployeeName | Lvl | Path |
|---|---|---|---|
| 101 | Amit | 1 | Amit |
| 102 | Rahul | 2 | Amit > Rahul |
| 105 | Raj | 2 | Amit > Raj |
| 103 | Priya | 1 | Priya |
| 104 | Sneha | 2 | Priya > Sneha |

**Interview answer (7 yrs experience):** "A CTE is a named query scoped to one statement; the recursive form has an anchor and a recursive member combined with UNION ALL. In our HRMS we used a recursive CTE for the reporting hierarchy — for example, a manager should see leave requests of everyone under them at any depth, not just direct reports. We also used it to generate date ranges for leave calculation. The key pitfalls are infinite loops due to bad data — like an employee accidentally set as their own manager's manager — which hits the MAXRECURSION limit of 100 and throws an error. We added a cycle check using the Path column and a data validation constraint. For very large or frequently queried hierarchies, we considered `hierarchyid` or a closure table for performance."

**Follow-up / Pro tip:**
- The recursive member cannot use `GROUP BY`, `TOP`, `DISTINCT`, or outer joins to the CTE itself.
- Statement before `WITH` must be terminated with `;` — many devs write `;WITH` defensively.

---

### Q44. CTE vs Temporary Table.

**Definition:** A CTE is a logical, non-materialized named query that lives for one statement. A temporary table (`#Temp`) is a physical table in tempdb that stores data and lives for the session/procedure scope.

**Real-world example:** A CTE is like a formula in a spreadsheet cell — recalculated each time it's used. A temp table is like copy-pasting the values into a new sheet that you can reuse and even index.

**SQL example:**
```sql
-- CTE: single use
WITH ITEmp AS (SELECT * FROM Employee WHERE DepartmentId = 1)
SELECT AVG(Salary) FROM ITEmp;          -- 66666.67

-- Temp table: reuse in multiple statements, add index
SELECT * INTO #ITEmp FROM Employee WHERE DepartmentId = 1;
CREATE INDEX IX_ITEmp_Salary ON #ITEmp(Salary);
SELECT AVG(Salary) FROM #ITEmp;
SELECT * FROM #ITEmp WHERE Salary > 60000;   -- Amit
DROP TABLE #ITEmp;
```

| Aspect | CTE | Temp Table (#) |
|---|---|---|
| Storage | Not stored (inlined) | Physically stored in tempdb |
| Scope | Next single statement | Session / procedure (and nested procs) |
| Reuse | Only within one statement | Across many statements |
| Indexes / statistics | No | Yes |
| Recursion | Yes | No |
| Best for | Readability, small/one-time logic, recursion | Large intermediate results reused, breaking complex queries |

**Interview answer (7 yrs experience):** "A CTE is just syntax; it doesn't store data. A temp table materializes the data and gets statistics, so the optimizer can make better decisions for the next steps. In our payroll processing procedure, a single giant query with five CTEs had terrible cardinality estimates and ran for minutes; splitting it into two temp table steps with an index brought it down to seconds. On the other hand, for simple one-shot logic, a CTE avoids tempdb writes. My rule: CTE for readability, temp table when the intermediate result is large, reused, or the plan goes bad."

---

### Q45. Temporary Table (#Temp) vs Table Variable (@Table).

**Definition:** Both store temporary data in tempdb. A `#Temp` table behaves like a real table with statistics and full indexing; a `@Table` variable is a variable with limited statistics and batch scope.

**Real-world example:** A `#Temp` table is like a rented warehouse with a full inventory system; a `@Table` variable is like a small locker — quick for a few items, but nobody keeps statistics on what's inside.

**SQL example:**
```sql
-- Temp table
CREATE TABLE #Emp (EmployeeId INT PRIMARY KEY, Salary DECIMAL(10,2));
INSERT INTO #Emp SELECT EmployeeId, Salary FROM Employee;

-- Table variable
DECLARE @Emp TABLE (EmployeeId INT PRIMARY KEY, Salary DECIMAL(10,2));
INSERT INTO @Emp SELECT EmployeeId, Salary FROM Employee;

-- Transaction behaviour
BEGIN TRAN;
    DELETE FROM #Emp;
    DELETE FROM @Emp;
ROLLBACK;
SELECT COUNT(*) FROM #Emp;   -- 5 (rollback restored rows)
SELECT COUNT(*) FROM @Emp;   -- 0 (table variables ignore rollback)
```

| Aspect | #Temp Table | @Table Variable |
|---|---|---|
| Storage | tempdb | tempdb (not purely in memory!) |
| Scope | Session / proc; visible to nested procs | Current batch/proc/function only |
| Statistics | Yes (column stats) | No column statistics; row estimate was 1 before SQL 2019; SQL 2019+ uses deferred compilation to get actual row count |
| Indexes | Any, can be added after creation | Only inline (PK, UNIQUE, inline INDEX since 2014) |
| Transaction rollback | Respects rollback | Not affected by rollback |
| Recompilations | Can cause recompiles | Fewer recompiles |
| ALTER / TRUNCATE | Allowed | Not allowed |
| Use inside functions | No | Yes |
| Parallelism | Yes | Modifying statements can't use parallel plan |
| Best for | Large data sets (> ~1000 rows), joins | Small sets, functions, logging that must survive rollback |

**Interview answer (7 yrs experience):** "The biggest myth is that table variables are in memory — both live in tempdb. The real difference is statistics: before SQL Server 2019, a table variable was estimated at one row, so joining it with 50,000 rows gave a nested-loop plan that crawled. In our HRMS bulk leave-accrual job, switching from `@table` to `#temp` cut runtime drastically. I still use table variables for small lists and for one neat trick: since they ignore rollback, I can capture error-log rows inside a transaction and still insert them into the log table after rolling back. On SQL 2019 compatibility level 150+, table variable deferred compilation narrows the gap, but they still lack column statistics."

**Follow-up / Pro tip:**
- Global temp tables `##Temp` are visible to all sessions and dropped when the creating session ends and no one else references them.
- Memory-optimized table variables (In-Memory OLTP) actually avoid tempdb.

---

### Q46. Temporary Table vs Permanent Table.

**Definition:** A permanent table is stored in a user database and exists until explicitly dropped. A temporary table (`#` local or `##` global) lives in tempdb and is automatically dropped when its session or procedure scope ends.

**Real-world example:** A permanent table is the company's employee master file kept in the cabinet; a temp table is a rough sheet an HR executive uses while preparing this month's report and throws away afterwards.

**SQL example:**
```sql
-- Permanent
CREATE TABLE dbo.PayrollRun (RunId INT IDENTITY PRIMARY KEY, RunMonth DATE);

-- Temporary: auto-dropped at end of session/proc
CREATE TABLE #PayrollCalc (EmployeeId INT, GrossSalary DECIMAL(10,2));
INSERT INTO #PayrollCalc SELECT EmployeeId, Salary / 12 FROM Employee;
```

| Aspect | Temporary Table | Permanent Table |
|---|---|---|
| Location | tempdb | User database |
| Lifetime | Session / procedure scope | Until `DROP TABLE` |
| Visibility | `#` = own session; `##` = all sessions | All users with permission |
| Backup / recovery | Not backed up; lost on restart | Backed up, fully recoverable |
| Logging | Reduced logging in tempdb (no redo needed) | Full logging per recovery model |
| Foreign keys | FK constraints are not enforced on temp tables | Supported |
| Use | Intermediate processing | Business data |

**Interview answer (7 yrs experience):** "Permanent tables hold business data and are part of backups and the schema; temp tables are scratch space in tempdb scoped to my session. In our payroll procedures we stage calculations in temp tables, then write the final results to permanent tables in a short transaction — this keeps locks on the real tables brief. I avoid creating 'temporary' permanent tables like `dbo.Temp_Payroll` because multiple users running the same process collide with each other, and they get forgotten. One thing to watch is tempdb contention when many sessions create temp tables simultaneously — SQL 2019's memory-optimized tempdb metadata helps there."

---

### Q47. Stored Procedure vs Function.

**Definition:** A stored procedure is a precompiled set of T-SQL statements that can perform any operation including data changes and transactions. A function (UDF) must return a value or a table, and is used inside queries; it cannot change database state.

**Real-world example:** A stored procedure is like an HR clerk who can process an entire joining workflow (create records, send updates). A function is like a calculator — you give it inputs, it returns an answer, but it can't change any files.

**SQL example:**
```sql
-- Stored procedure: can modify data
CREATE OR ALTER PROCEDURE dbo.usp_GiveIncrement @DeptId INT, @Pct DECIMAL(5,2)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Employee SET Salary = Salary * (1 + @Pct/100) WHERE DepartmentId = @DeptId;
END;
GO
-- Function: returns a value, usable in SELECT
CREATE OR ALTER FUNCTION dbo.fn_AnnualSalary (@MonthlySalary DECIMAL(10,2))
RETURNS DECIMAL(12,2)
AS
BEGIN
    RETURN @MonthlySalary * 12;
END;
GO
SELECT EmployeeName, dbo.fn_AnnualSalary(Salary) AS Annual FROM Employee;
EXEC dbo.usp_GiveIncrement @DeptId = 1, @Pct = 10;
```

| Aspect | Stored Procedure | Function |
|---|---|---|
| Return | 0..n result sets, OUTPUT params, INT return code | Must return a scalar or a table |
| DML (INSERT/UPDATE/DELETE) on tables | Yes | No (only on local table variables) |
| Use in SELECT / WHERE / JOIN | No | Yes |
| Transactions, TRY...CATCH | Yes | No |
| Call the other | Can call functions | Cannot call stored procedures |
| Dynamic SQL (`EXEC`/`sp_executesql`) | Yes | No |
| Temp tables (#) | Yes | No (table variables only) |
| Parameters | Input & OUTPUT | Input only |

**Interview answer (7 yrs experience):** "In our .NET Core HRMS with Dapper, all writes go through stored procedures — things like applying leave, running payroll — because they support transactions, TRY/CATCH and multiple result sets that Dapper's `QueryMultiple` reads nicely. Functions I use for reusable read logic that I need inside a SELECT, preferably inline table-valued functions. A big pitfall is scalar UDFs in the SELECT list over large tables: before SQL 2019 they run row-by-row and block parallelism. SQL Server 2019 introduced scalar UDF inlining which helps, but not every function qualifies, so I still prefer inline TVFs or plain expressions in hot paths."

---

### Q48. Scalar Function vs Table-Valued Function.

**Definition:** A scalar function returns a single value (e.g., INT, VARCHAR). A table-valued function (TVF) returns a table and is used in the FROM clause; it can be **inline** (single SELECT) or **multi-statement** (fills a table variable).

**Real-world example:** A scalar function is like asking "what is this employee's age?" — one answer. A TVF is like asking "give me the list of employees in this department" — a list of rows.

**SQL example:**
```sql
-- Scalar
CREATE OR ALTER FUNCTION dbo.fn_YearsOfService (@JoiningDate DATE)
RETURNS INT AS
BEGIN
    RETURN DATEDIFF(YEAR, @JoiningDate, GETDATE());
END;
GO
-- Multi-statement TVF
CREATE OR ALTER FUNCTION dbo.fn_DeptEmployees_MS (@DeptId INT)
RETURNS @Result TABLE (EmployeeId INT, EmployeeName VARCHAR(50))
AS
BEGIN
    INSERT INTO @Result SELECT EmployeeId, EmployeeName FROM Employee WHERE DepartmentId = @DeptId;
    RETURN;
END;
GO
SELECT EmployeeName, dbo.fn_YearsOfService(JoiningDate) FROM Employee;
SELECT * FROM dbo.fn_DeptEmployees_MS(2);   -- Priya, Sneha
```

| Aspect | Scalar Function | Inline TVF | Multi-statement TVF |
|---|---|---|---|
| Returns | One value | Table (one SELECT) | Table variable |
| Used in | SELECT, WHERE, computed columns | FROM / JOIN / APPLY | FROM / JOIN / APPLY |
| Optimizer | Row-by-row (unless 2019 inlining) | Expanded like a view — best | Fixed estimate (1 row pre-2014, 100 rows 2014+); interleaved execution in 2017+ helps |
| Performance | Often poor at scale | Excellent | Often poor at scale |

**Interview answer (7 yrs experience):** "Scalar returns one value, TVF returns rows. From a performance angle, inline TVFs are the clear winner because the optimizer merges them into the outer query. Multi-statement TVFs act as black boxes with fixed cardinality guesses, and scalar UDFs historically executed once per row and forced serial plans. In our HRMS we had a scalar function computing leave balance called in a report over 20,000 employees — replacing it with an inline TVF via `CROSS APPLY` cut report time from around 40 seconds to under 2. Now I default to inline TVFs whenever possible."

---

### Q49. What is an Inline Table-Valued Function?

**Definition:** An inline TVF is a function whose body is a single `RETURN (SELECT ...)` statement. It acts like a **parameterized view** and is expanded into the calling query by the optimizer.

**Real-world example:** A library's "show books by author X" search screen — the same query template, just different input each time.

**SQL example:**
```sql
CREATE OR ALTER FUNCTION dbo.fn_EmployeesByDept (@DeptId INT)
RETURNS TABLE
AS
RETURN
(
    SELECT EmployeeId, EmployeeName, Salary
    FROM dbo.Employee
    WHERE DepartmentId = @DeptId
);
GO
SELECT * FROM dbo.fn_EmployeesByDept(1);

-- With CROSS APPLY for each department
SELECT d.DepartmentName, f.EmployeeName
FROM Department d
CROSS APPLY dbo.fn_EmployeesByDept(d.DepartmentId) f;
```

| EmployeeId | EmployeeName | Salary |
|---|---|---|
| 101 | Amit | 80000 |
| 102 | Rahul | 60000 |
| 105 | Raj | 60000 |

**Interview answer (7 yrs experience):** "An inline TVF is basically a parameterized view — no BEGIN/END, just one SELECT. Because SQL Server inlines it, it gets accurate statistics, uses indexes and can go parallel, unlike multi-statement TVFs. In our HRMS we used inline TVFs for row-level security style filters, like 'employees visible to this manager', and reused them across many procedures. With `CROSS APPLY`, they're also a clean way to replace correlated scalar subqueries. The only limitation is it must be a single statement, but with CTEs inside the RETURN you can still express fairly complex logic."

---

### Q50. What are Triggers? Explain AFTER and INSTEAD OF triggers.

**Definition:** A trigger is special code that runs automatically in response to an event — DML (INSERT/UPDATE/DELETE), DDL (CREATE/ALTER/DROP), or LOGON. An **AFTER** trigger fires after the statement succeeds (before commit); an **INSTEAD OF** trigger replaces the original operation.

**Real-world example:** AFTER trigger = a CCTV camera recording after someone enters the building. INSTEAD OF trigger = a security guard who stops you at the door and decides what actually happens.

**SQL example:**
```sql
-- AFTER trigger: audit salary changes
CREATE OR ALTER TRIGGER trg_Employee_SalaryAudit
ON dbo.Employee
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF UPDATE(Salary)
        INSERT INTO dbo.EmployeeSalaryHistory (EmployeeId, Salary, EffectiveDate)
        SELECT i.EmployeeId, i.Salary, CAST(GETDATE() AS DATE)
        FROM inserted i
        JOIN deleted d ON d.EmployeeId = i.EmployeeId
        WHERE i.Salary <> d.Salary;          -- set-based, handles multi-row updates
END;
GO
-- INSTEAD OF trigger: soft delete instead of hard delete
-- (assumes an IsActive BIT column exists)
CREATE OR ALTER TRIGGER trg_Employee_SoftDelete
ON dbo.Employee
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE e SET IsActive = 0
    FROM dbo.Employee e JOIN deleted d ON d.EmployeeId = e.EmployeeId;
END;
```

| Aspect | AFTER Trigger | INSTEAD OF Trigger |
|---|---|---|
| When it fires | After the DML succeeds and constraints pass | In place of the DML |
| Original action | Happens | Does not happen unless the trigger does it |
| Allowed on | Tables only | Tables and views |
| Per table/action | Multiple allowed | Only one per action |
| Typical use | Auditing, history, sync | Soft deletes, updatable complex views, validation |

**Interview answer (7 yrs experience):** "Triggers fire automatically on events. We used an AFTER UPDATE trigger in our HRMS to write salary changes into a history table, so every change was audited regardless of whether it came from the app, a script, or a DBA. The most common bug I've seen is triggers written assuming one row — using `SELECT @id = EmployeeId FROM inserted` — which breaks on bulk updates; triggers fire once per statement, so they must be set-based. Triggers also run inside the caller's transaction, so slow trigger logic extends lock duration and an error rolls back the whole statement. Because they're 'hidden logic', I keep them minimal and documented; for new work I often prefer temporal tables or explicit logic in stored procedures."

**Follow-up / Pro tip:**
- Bulk inserts (`BULK INSERT`, `SqlBulkCopy`) don't fire triggers unless `FIRE_TRIGGERS` is specified.
- `TRUNCATE TABLE` never fires DELETE triggers.

---

### Q51. What are Magic Tables (Inserted and Deleted)?

**Definition:** `inserted` and `deleted` are special virtual tables that SQL Server makes available inside triggers (and in the `OUTPUT` clause). `inserted` holds new row values, `deleted` holds old row values.

**Real-world example:** When a bank updates your address, `deleted` is the old address card and `inserted` is the new card — both available so an auditor can compare.

| Operation | `inserted` contains | `deleted` contains |
|---|---|---|
| INSERT | New rows | Empty |
| DELETE | Empty | Removed rows |
| UPDATE | New values (after) | Old values (before) |

**SQL example:**
```sql
-- OUTPUT clause using magic tables (no trigger needed)
UPDATE Employee
SET Salary = Salary + 5000
OUTPUT deleted.EmployeeId, deleted.Salary AS OldSalary, inserted.Salary AS NewSalary
WHERE DepartmentId = 2;
```

| EmployeeId | OldSalary | NewSalary |
|---|---|---|
| 103 | 90000 | 95000 |
| 104 | 70000 | 75000 |

**Interview answer (7 yrs experience):** "Inserted and deleted are the 'magic tables' — virtual, read-only tables with the same structure as the base table. In triggers, an UPDATE is represented as a delete of old values plus an insert of new values, so I join both on the primary key to compare before/after values for auditing. Outside triggers, I use them very often with the `OUTPUT` clause — for example, returning newly generated identity values for a batch insert to Dapper, which is safer than `SCOPE_IDENTITY()` for multiple rows. They're built from the row versions in tempdb, so heavy triggers on large updates add tempdb load."

---

### Q52. What is a View? Can we update data through a View?

**Definition:** A view is a saved SELECT query that behaves like a virtual table; it stores no data (unless indexed). Yes, you can INSERT/UPDATE/DELETE through a view if the change affects **only one base table** and the view has no aggregates, DISTINCT, GROUP BY, TOP, UNION, or computed columns for the modified columns.

**Real-world example:** A view is like a window in a bank showing only the counters you're allowed to see — the bank's full vault (base tables) stays hidden.

**SQL example:**
```sql
CREATE OR ALTER VIEW dbo.vw_ITEmployees
AS
SELECT EmployeeId, EmployeeName, DepartmentId, Salary
FROM dbo.Employee
WHERE DepartmentId = 1
WITH CHECK OPTION;   -- prevents updates that move rows out of the view
GO
UPDATE dbo.vw_ITEmployees SET Salary = 65000 WHERE EmployeeId = 102;  -- works
UPDATE dbo.vw_ITEmployees SET DepartmentId = 2 WHERE EmployeeId = 102; -- fails due to CHECK OPTION
```

| View can be updated when... | Cannot be updated when... |
|---|---|
| Modification touches columns of one base table | Columns come from multiple tables in one statement |
| Columns are direct references | Columns are aggregates/computed (SUM, AVG, expressions) |
| No DISTINCT / GROUP BY / HAVING / TOP (+CHECK OPTION) / UNION | Any of those exist (use INSTEAD OF trigger) |

**Interview answer (7 yrs experience):** "A view is a stored query used for abstraction and security — in our HRMS we exposed `vw_EmployeeDirectory` without salary columns to the reporting team and granted permissions only on the view. Views are updatable if the change maps to a single base table; for multi-table views, an INSTEAD OF trigger can route changes. I use `WITH CHECK OPTION` when a view filters data so users can't update a row out of their visible scope. Pitfalls: `SELECT *` in a view doesn't automatically pick up new columns — you need `sp_refreshview` or `SCHEMABINDING` — and nesting views on views creates very hard-to-tune plans."

---

### Q53. What is an Indexed View?

**Definition:** An indexed view (materialized view) is a view with a unique clustered index, so its result is physically stored and automatically maintained when base tables change. It requires `WITH SCHEMABINDING`.

**Real-world example:** Instead of counting every invoice each time the manager asks for monthly sales totals, a clerk keeps a running tally sheet updated with each new invoice.

**SQL example:**
```sql
CREATE OR ALTER VIEW dbo.vw_DeptSalarySummary
WITH SCHEMABINDING
AS
SELECT DepartmentId,
       COUNT_BIG(*)            AS EmpCount,      -- required with GROUP BY
       SUM(ISNULL(Salary, 0))  AS TotalSalary    -- SUM over nullable expr not allowed
FROM dbo.Employee                                -- two-part names required
GROUP BY DepartmentId;
GO
CREATE UNIQUE CLUSTERED INDEX IX_vw_DeptSalarySummary
ON dbo.vw_DeptSalarySummary (DepartmentId);
GO
SELECT * FROM dbo.vw_DeptSalarySummary WITH (NOEXPAND);
```

| DepartmentId | EmpCount | TotalSalary |
|---|---|---|
| 1 | 3 | 200000 |
| 2 | 2 | 160000 |

**Interview answer (7 yrs experience):** "An indexed view materializes the result with a unique clustered index, so aggregate dashboards read pre-computed data. The rules are strict: SCHEMABINDING, two-part names, COUNT_BIG(*) with GROUP BY, no outer joins, no subqueries, deterministic expressions, and specific SET options like ANSI_NULLS and QUOTED_IDENTIFIER ON. The trade-off is write cost — every insert/update on Employee now also updates the view, and it can cause blocking on hot tables. In our HRMS we used it for a headcount dashboard on a mostly-read table, which worked well; I'd avoid it on high-write tables like attendance punches. Also, only Enterprise edition auto-matches indexed views; on Standard you must use the `NOEXPAND` hint."

---

### Q54. What is a Synonym in SQL Server?

**Definition:** A synonym is an alternate name (alias) for a database object such as a table, view, procedure or function — possibly in another schema, database or linked server.

**Real-world example:** A speed-dial on your phone — you press "2" instead of typing the full number; if the number changes, you only update the speed-dial.

**SQL example:**
```sql
-- Point to a table in another database
CREATE SYNONYM dbo.PayrollEmployee FOR PayrollDB.dbo.Employee;

SELECT * FROM dbo.PayrollEmployee WHERE DepartmentId = 1;

-- Later, if the database is renamed, just recreate the synonym
DROP SYNONYM dbo.PayrollEmployee;
CREATE SYNONYM dbo.PayrollEmployee FOR PayrollDB_v2.dbo.Employee;
```

**Interview answer (7 yrs experience):** "A synonym is a layer of indirection over an object name. In our HRMS, the payroll module lived in a separate database, and hard-coding `PayrollDB.dbo.X` in dozens of procedures made environment moves painful — DEV, QA and PROD had different database names. We replaced them with synonyms, so deployment only recreated synonyms per environment. They're also useful during table refactoring or for hiding linked-server four-part names. Limitations: synonyms are bound late, so a broken target only errors at runtime, you can't use them in DDL like ALTER TABLE, and they can't point to another synonym."

---

### Q55. What is a Dynamic SQL query? When should you use it?

**Definition:** Dynamic SQL is a T-SQL statement built as a string at runtime and executed with `sp_executesql` (preferred) or `EXEC()`. It's used when parts of the query — like columns, tables, or optional filters — aren't known until runtime.

**Real-world example:** An e-commerce search page where users may filter by any combination of brand, price, and rating — the query is assembled based on which filters are selected.

**SQL example:**
```sql
CREATE OR ALTER PROCEDURE dbo.usp_SearchEmployees
    @DeptId INT = NULL, @MinSalary DECIMAL(10,2) = NULL,
    @SortColumn SYSNAME = 'EmployeeName'
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @sql NVARCHAR(MAX) = N'SELECT EmployeeId, EmployeeName, Salary FROM dbo.Employee WHERE 1 = 1';

    IF @DeptId    IS NOT NULL SET @sql += N' AND DepartmentId = @DeptId';
    IF @MinSalary IS NOT NULL SET @sql += N' AND Salary >= @MinSalary';

    -- Whitelist + QUOTENAME for identifiers (cannot be parameterized)
    IF @SortColumn NOT IN ('EmployeeName','Salary','JoiningDate') SET @SortColumn = 'EmployeeName';
    SET @sql += N' ORDER BY ' + QUOTENAME(@SortColumn);

    EXEC sys.sp_executesql @sql,
         N'@DeptId INT, @MinSalary DECIMAL(10,2)',
         @DeptId = @DeptId, @MinSalary = @MinSalary;
END;
GO
EXEC dbo.usp_SearchEmployees @DeptId = 1, @MinSalary = 65000;  -- Amit
```

| `sp_executesql` | `EXEC('...')` |
|---|---|
| Supports parameters | No parameters (only concatenation) |
| Plan reuse for different values | New plan per distinct string |
| Protects values from SQL injection | Vulnerable if user input concatenated |

**Interview answer (7 yrs experience):** "I use dynamic SQL for search screens with many optional filters, dynamic sorting, dynamic pivots, and admin scripts that loop over tables. In our HRMS employee search with 10+ optional filters, the 'catch-all' `WHERE (@x IS NULL OR Col = @x)` pattern produced one bad cached plan; dynamic SQL generated a tailored, index-friendly query per filter combination. The non-negotiable rules: always use `sp_executesql` with parameters for values, and `QUOTENAME` plus a whitelist for identifiers like column names — never concatenate raw user input. Other trade-offs: dynamic SQL runs with the caller's permissions on the underlying tables (ownership chaining breaks), and it's harder to read and debug, so I always print the generated SQL in debug mode."

**Follow-up / Pro tip:**
- `OPTION (RECOMPILE)` is an alternative for catch-all queries when execution frequency is low.

---

## D. Window Functions and Advanced SQL

### Q56. What is ROW_NUMBER()?

**Definition:** `ROW_NUMBER()` is a window function that assigns a sequential, unique integer to each row within a query result set or within specified partitions, ordered by a given `ORDER BY` clause.

**Real-world example:** Assigning queue tokens at a clinic or bank counter: the first patient who arrives gets ticket #1, the next gets #2, and so on. Even if two patients arrive with identical priority, each receives a distinct sequential number.

**SQL example:**
```sql
-- Assign unique row numbers ordered by Salary descending
SELECT 
    EmployeeId, 
    EmployeeName, 
    DepartmentId, 
    Salary,
    ROW_NUMBER() OVER (ORDER BY Salary DESC) AS GlobalRowNum,
    ROW_NUMBER() OVER (PARTITION BY DepartmentId ORDER BY Salary DESC) AS DeptRowNum
FROM dbo.Employee;
```

**Output:**
| EmployeeId | EmployeeName | DepartmentId | Salary | GlobalRowNum | DeptRowNum |
|---|---|---|---|---|---|
| 103 | Priya | 2 | 90000.00 | 1 | 1 |
| 101 | Amit | 1 | 80000.00 | 2 | 1 |
| 104 | Sneha | 2 | 70000.00 | 3 | 2 |
| 102 | Rahul | 1 | 60000.00 | 4 | 2 |
| 105 | Raj | 1 | 60000.00 | 5 | 3 |

**Interview answer (7 yrs experience):** "`ROW_NUMBER()` is the most frequently used window function in my day-to-day work. In our HRMS, its two primary use cases are deduplication and offset pagination. For deduplication, we partition by natural business keys (like `EmployeeCode` and `AttendanceDate`), order by `ModifiedDate DESC`, and delete rows where `ROW_NUMBER() > 1`. For web grid pagination, prior to SQL Server 2012's `OFFSET-FETCH`, we wrapped `ROW_NUMBER()` inside a CTE to slice pages. The key architectural detail to understand is that `ROW_NUMBER()` is deterministic only if your `ORDER BY` clause contains a unique key or unique combination of columns; if ordering by a non-unique column like `Salary`, two rows with equal salary (like Rahul and Raj) can arbitrarily receive either #2 or #3 unless a deterministic tie-breaker like `EmployeeId` is appended."

---

### Q57. Difference between ROW_NUMBER(), RANK() and DENSE_RANK().

**Definition:** All three are ranking window functions, but they handle duplicate values (ties) differently: `ROW_NUMBER()` always assigns consecutive unique numbers; `RANK()` assigns the same rank to ties and skips subsequent numbers; `DENSE_RANK()` assigns the same rank to ties without skipping numbers.

**Real-world example:** In a marathon race where two runners tie for 2nd place:
- **`ROW_NUMBER()`**: 1, 2, 3, 4 (arbitrary tie-break).
- **`RANK()`**: 1, 2, 2, 4 (Olympic podium: no 3rd place ribbon awarded).
- **`DENSE_RANK()`**: 1, 2, 2, 3 (next runner gets 3rd place; no numbers skipped).

| Function | Handling of Ties | Skips Ranks After Ties? | Sequence Example with Ties |
|---|---|---|---|
| **`ROW_NUMBER()`** | Generates unique sequence arbitrarily | No | 1, 2, 3, 4, 5 |
| **`RANK()`** | Identical values get same rank | Yes (skips by number of ties) | 1, 2, 2, 4, 5 |
| **`DENSE_RANK()`** | Identical values get same rank | No (consecutive integers) | 1, 2, 2, 3, 4 |

**SQL example:**
```sql
SELECT 
    EmployeeId,
    EmployeeName,
    Salary,
    ROW_NUMBER() OVER (ORDER BY Salary DESC) AS [Row_Number],
    RANK()       OVER (ORDER BY Salary DESC) AS [Rank],
    DENSE_RANK() OVER (ORDER BY Salary DESC) AS [Dense_Rank]
FROM dbo.Employee;
```

**Output:**
| EmployeeId | EmployeeName | Salary | Row_Number | Rank | Dense_Rank |
|---|---|---|---|---|---|
| 103 | Priya | 90000.00 | 1 | 1 | 1 |
| 101 | Amit | 80000.00 | 2 | 2 | 2 |
| 104 | Sneha | 70000.00 | 3 | 3 | 3 |
| 102 | Rahul | 60000.00 | 4 | 4 | 4 |
| 105 | Raj | 60000.00 | 5 | 4 | 4 |

**Interview answer (7 yrs experience):** "This is a classic senior interview scenario. In our payroll system, when HR requests the 'Top 3 highest salaries in the company', I specifically ask whether they mean the top 3 distinct salary figures or the top 3 employee records. If we have ties (for example, Rahul and Raj both earning 60,000), using `ROW_NUMBER() <= 3` arbitrarily excludes Raj; using `RANK() <= 3` skips ranks, so if three people tied for 1st place, rank 2 and 3 would be skipped completely. `DENSE_RANK()` is the mathematically correct tool for 'N-th highest salary' problems because it groups equal salaries together into rank tiers (1, 2, 3) without skipping any tier numbers. In execution plans, all three share the same Segment and Sequence Project operators, so their performance profile is identical."

---

### Q58. What is PARTITION BY?

**Definition:** `PARTITION BY` is a sub-clause of the `OVER()` clause that divides a query result set into independent logical subsets (partitions) over which a window function calculates its results.

**Real-world example:** Classifying students in a school: instead of ranking all 1,000 students in the school on one giant list, `PARTITION BY ClassName` ranks students within Class 10A (1 to 40), then restarts the counter from 1 for Class 10B.

**SQL example:**
```sql
-- Compute each employee's salary and the total salary expenditure of their department
SELECT 
    EmployeeId,
    EmployeeName,
    DepartmentId,
    Salary,
    SUM(Salary) OVER (PARTITION BY DepartmentId) AS DepartmentTotalSalary,
    COUNT(*)    OVER (PARTITION BY DepartmentId) AS DepartmentHeadCount
FROM dbo.Employee;
```

**Output:**
| EmployeeId | EmployeeName | DepartmentId | Salary | DepartmentTotalSalary | DepartmentHeadCount |
|---|---|---|---|---|---|
| 101 | Amit | 1 | 80000.00 | 200000.00 | 3 |
| 102 | Rahul | 1 | 60000.00 | 200000.00 | 3 |
| 105 | Raj | 1 | 60000.00 | 200000.00 | 3 |
| 103 | Priya | 2 | 90000.00 | 160000.00 | 2 |
| 104 | Sneha | 2 | 70000.00 | 160000.00 | 2 |

**Interview answer (7 yrs experience):** "`PARTITION BY` is the foundation of analytical windowing. Before window functions, if a screen needed to display an employee's salary alongside their department's average or total salary, we had to write a `JOIN` to an aggregated subquery or CTE, reading the table twice. With `SUM(Salary) OVER (PARTITION BY DepartmentId)`, SQL Server scans the data once, sorts or hashes by `DepartmentId`, and computes the aggregate without collapsing rows. If an index already exists on `(DepartmentId, Salary)`, SQL Server avoids an explicit Sort operator in the execution plan, streaming the window calculations at memory speed."

---

### Q59. What is the difference between PARTITION BY and GROUP BY?

**Definition:** `GROUP BY` collapses multiple rows into a single summary row per group; `PARTITION BY` calculates aggregate or ranking values across groups while retaining every individual row in the output.

**Real-world example:**
- **`GROUP BY`**: A monthly financial summary showing 1 row per department: *'IT Department: 3 Employees, Total Salary = \$200,000'*.
- **`PARTITION BY`**: A payroll slip printed for each individual employee showing their own name and salary, with a small footnote at the bottom: *'Your department total is \$200,000'*.

| Feature | `GROUP BY` | `PARTITION BY` |
|---|---|---|
| Output Row Count | Collapsed (1 row per distinct group) | Preserved (exact same row count as input) |
| Detail Columns | Cannot select non-aggregated columns unless in `GROUP BY` | Can freely select any individual row column |
| Where Used | In the main query `GROUP BY` clause | Inside the `OVER(...)` clause of window functions |
| Common Purpose | Summarization, reporting tables, charts | Running totals, rankings, moving averages alongside detail rows |

**SQL example:**
```sql
-- 1. GROUP BY: Collapses 5 rows down to 2 department summary rows
SELECT DepartmentId, COUNT(*) AS HeadCount, SUM(Salary) AS TotalSalary
FROM dbo.Employee
GROUP BY DepartmentId;

-- 2. PARTITION BY: Returns all 5 employee rows with department aggregates attached
SELECT EmployeeName, DepartmentId, Salary,
       SUM(Salary) OVER (PARTITION BY DepartmentId) AS DeptTotalSalary
FROM dbo.Employee;
```

**Interview answer (7 yrs experience):** "The core difference is row granularity. `GROUP BY` reduces granularity by collapsing rows; you cannot view Amit and Rahul individually because they are merged into the IT department row. In contrast, `PARTITION BY` calculates aggregates without collapsing individual rows. In our HRMS API, when building a dashboard showing employee compensation compared to their department average, developers used to do a self-join to a `GROUP BY` subquery. Replacing that with `AVG(Salary) OVER (PARTITION BY DepartmentId)` cut the query execution time in half and removed a Hash Match join from the execution plan."

---

### Q60. What are Ties in ranking functions?

**Definition:** A 'tie' occurs when two or more rows have identical values in the columns specified by the `ORDER BY` clause of a ranking window function.

**Real-world example:** In a high school exam, two students both score 98%. Deciding who gets 1st place and whether the next student gets 2nd or 3rd place is the classic problem of handling ties.

**SQL example:**
```sql
-- Rahul (102) and Raj (105) both have Salary = 60000 (A Tie)
SELECT 
    EmployeeId, EmployeeName, Salary,
    RANK() OVER (ORDER BY Salary DESC) AS Rnk,
    DENSE_RANK() OVER (ORDER BY Salary DESC) AS DenseRnk
FROM dbo.Employee
WHERE Salary = 60000;
```

**Interview answer (7 yrs experience):** "Handling ties is an essential requirement in reporting queries. For example, Rahul and Raj both earn 60,000. If an interviewer asks for the 'top 2 earners in IT', using `ROW_NUMBER() <= 2` will nondeterministically pick one and discard the other based on storage order or parallelism. A senior developer always asks: 'How should ties be resolved?' If both should be included, we use `DENSE_RANK() <= 2`. If exactly one must be picked deterministically, we must add a secondary tie-breaker column to the `ORDER BY` clause, such as `ORDER BY Salary DESC, JoiningDate ASC, EmployeeId ASC`."

---

### Q61. What is NTILE()?

**Definition:** `NTILE(n)` is a window function that distributes rows of an ordered partition into a specified number of approximately equal groups (buckets), numbered from 1 to `n`.

**Real-world example:** Dividing employees into performance appraisal quartiles: the top 25% performers get placed in Bucket 1, the next 25% in Bucket 2, down to the bottom 25% in Bucket 4 for performance improvement plans.

**SQL example:**
```sql
-- Divide our 5 employees into 3 salary buckets
SELECT 
    EmployeeId, EmployeeName, Salary,
    NTILE(3) OVER (ORDER BY Salary DESC) AS SalaryBucket
FROM dbo.Employee;
```

**Output:**
| EmployeeId | EmployeeName | Salary | SalaryBucket |
|---|---|---|---|
| 103 | Priya | 90000.00 | 1 |
| 101 | Amit | 80000.00 | 1 |
| 104 | Sneha | 70000.00 | 2 |
| 102 | Rahul | 60000.00 | 2 |
| 105 | Raj | 60000.00 | 3 |

**Interview answer (7 yrs experience):** "`NTILE(n)` is used for statistical bucketing, percentiles, deciles, and batch work distribution. If the total row count is not evenly divisible by $n$, SQL Server assigns extra rows to the earlier buckets (for example, with 5 rows and `NTILE(3)`, the group sizes are 2, 2, and 1). In our production batch processing, when we have to distribute 100,000 notification emails across 4 parallel background worker threads in .NET, we tag records with `NTILE(4) OVER (ORDER BY EmployeeId)` and have each worker process its specific bucket ID. One thing to be careful about: if rows have identical values in the `ORDER BY` column, `NTILE` does not guarantee they end up in the same bucket; it strictly enforces equal bucket counts."

---

### Q62. What are LAG() and LEAD() functions?

**Definition:** `LAG()` accesses data from a previous row at a specified physical offset without using a self-join; `LEAD()` accesses data from a subsequent row within the same partition.

**Real-world example:** Comparing an employee's current salary against their previous salary to calculate pay raise percentage, or comparing today's attendance swipe time with yesterday's swipe time.

**SQL example:**
```sql
-- Track salary changes over time for employee 101
SELECT 
    EmployeeId,
    EffectiveDate,
    Salary AS CurrentSalary,
    LAG(Salary, 1, 0)  OVER (PARTITION BY EmployeeId ORDER BY EffectiveDate) AS PreviousSalary,
    LEAD(Salary, 1, 0) OVER (PARTITION BY EmployeeId ORDER BY EffectiveDate) AS NextSalary,
    Salary - LAG(Salary, 1, Salary) OVER (PARTITION BY EmployeeId ORDER BY EffectiveDate) AS IncrementAmount
FROM dbo.EmployeeSalaryHistory
WHERE EmployeeId = 101;
```

**Output:**
| EmployeeId | EffectiveDate | CurrentSalary | PreviousSalary | NextSalary | IncrementAmount |
|---|---|---|---|---|---|
| 101 | 2022-01-10 | 50000.00 | 0.00 | 60000.00 | 0.00 |
| 101 | 2023-01-10 | 60000.00 | 50000.00 | 80000.00 | 10000.00 |
| 101 | 2024-01-10 | 80000.00 | 60000.00 | 0.00 | 20000.00 |

**Interview answer (7 yrs experience):** "Before SQL Server 2012, calculating period-over-period differences required expensive, error-prone self-joins on `RowNumber = RowNumber + 1`. `LAG()` and `LEAD()` completely transformed time-series and audit queries. In our HRMS compensation module, we use `LAG(Salary, 1, Salary) OVER (PARTITION BY EmployeeId ORDER BY EffectiveDate)` to calculate salary increment percentages. The third argument is the default value if the offset falls outside the partition, which saves you from writing extra `ISNULL()` wrappers. Because `LAG` and `LEAD` operate purely in-memory over the window frame, they execute in a single linear pass."

---

### Q63. What is FIRST_VALUE() and LAST_VALUE()?

**Definition:** `FIRST_VALUE()` returns the first value in an ordered set of rows; `LAST_VALUE()` returns the last value in an ordered set of rows within the defined window frame.

**Real-world example:** On an employee's career progression report: `FIRST_VALUE(Salary)` shows their starting salary when they joined the company, and `LAST_VALUE(Salary)` shows their most recent salary.

**SQL example:**
```sql
-- Show employee's initial joining salary alongside their current salary
SELECT 
    EmployeeId,
    EffectiveDate,
    Salary,
    FIRST_VALUE(Salary) OVER (
        PARTITION BY EmployeeId 
        ORDER BY EffectiveDate
    ) AS StartingSalary,
    LAST_VALUE(Salary) OVER (
        PARTITION BY EmployeeId 
        ORDER BY EffectiveDate
        ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING -- Crucial frame!
    ) AS LatestSalary
FROM dbo.EmployeeSalaryHistory
WHERE EmployeeId = 101;
```

**Interview answer (7 yrs experience):** "`FIRST_VALUE()` is straightforward, but `LAST_VALUE()` is a notorious trap in SQL Server interviews. By default, when an `ORDER BY` is present without an explicit frame, SQL Server defaults to `RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW`. Under this default, `LAST_VALUE()` evaluates up to the *current row*, meaning it simply returns the current row's value rather than the true last row of the partition! To make `LAST_VALUE()` work as expected, you must explicitly specify the frame: `ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING` or `ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING`."

---

### Q64. What is the difference between ROWS and RANGE in window functions?

**Definition:** `ROWS` defines the window frame by counting physical rows relative to the current row, whereas `RANGE` defines the frame logically by value offsets, including all tied peer values.

**Real-world example:**
- **`ROWS 2 PRECEDING`**: Exactly 2 physical people standing ahead of you in line.
- **`RANGE`**: Everyone in line who was born in the same calendar year as you (logical peers).

| Feature | `ROWS` | `RANGE` |
|---|---|---|
| Framing Basis | Physical row count | Logical value equality (peer values) |
| Performance | Fast, memory-efficient in-memory iteration | Significantly slower; writes spool to on-disk TempDB |
| Default in SQL Server | Used if specified | **Default when `ORDER BY` is used without frame specification** |
| Supported with non-integers | Yes | In T-SQL, `RANGE` only supports `UNBOUNDED` or `CURRENT ROW` |

**SQL example:**
```sql
-- 1. Using ROWS: Fast, stream-based running total
SELECT EmployeeId, Salary,
       SUM(Salary) OVER (ORDER BY Salary ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS RunningTotalRows
FROM dbo.Employee;

-- 2. Omitting frame: Defaults to RANGE! Causes TempDB spool and groups ties together
SELECT EmployeeId, Salary,
       SUM(Salary) OVER (ORDER BY Salary) AS RunningTotalRangeDefault
FROM dbo.Employee;
```

**Interview answer (7 yrs experience):** "This is one of the biggest hidden performance killers in T-SQL. When developers write `SUM(Salary) OVER (ORDER BY JoiningDate)` without specifying a frame, SQL Server defaults to `RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW`. Under the hood, `RANGE` uses an on-disk TempDB Worktable spool because it must check for tied values on every row. By simply rewriting it to `ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW`, SQL Server switches to an in-memory Stream Aggregate / Window Spool. In a production billing query processing 2 million rows, adding `ROWS` cut elapsed execution time from 18 seconds to 1.2 seconds and eliminated hundreds of thousands of TempDB writes."

---

### Q65. What is PIVOT and UNPIVOT?

**Definition:** `PIVOT` rotates row-level values into distinct column headers (cross-tabulation); `UNPIVOT` rotates column headers into row-level values (normalization).

**Real-world example:**
- **`PIVOT`**: Converting a vertical attendance punch log into a monthly calendar timesheet where employee names are on the left and days (Day 1, Day 2, Day 3) become horizontal column headers.
- **`UNPIVOT`**: Taking a quarterly spreadsheet with columns `[Q1]`, `[Q2]`, `[Q3]`, `[Q4]` and converting it into a clean database table with rows: `QuarterName` and `SalesAmount`.

**SQL example:**
```sql
-- 1. PIVOT: Total salary expenditure pivoted by Department Name
SELECT [IT], [HR], [Finance]
FROM (
    SELECT d.DepartmentName, e.Salary
    FROM dbo.Employee e
    JOIN dbo.Department d ON e.DepartmentId = d.DepartmentId
) src
PIVOT (
    SUM(Salary)
    FOR DepartmentName IN ([IT], [HR], [Finance])
) pvt;

-- 2. UNPIVOT: Converting columns back to rows
-- (e.g. pivoting contact columns MobilePhone, OfficePhone into ContactType / ContactNumber)
```

**Output:**
| IT | HR | Finance |
|---|---|---|
| 200000.00 | 160000.00 | NULL |

**Interview answer (7 yrs experience):** "In HRMS and financial reporting, business users constantly request pivoted cross-tab views (e.g., Attendance status across days of the month). Static `PIVOT` is fine when column values are fixed (like months of the year or quarters). However, static PIVOT requires hardcoding the column list inside the query. If a new department or pay component is added, the query must be rewritten. For dynamic reporting, we build dynamic SQL that queries the dimension table to build the column list at runtime. For UNPIVOT, I often prefer `CROSS APPLY (VALUES ...)` over the native `UNPIVOT` keyword because `CROSS APPLY` is cleaner, handles data type conversions better, and doesn't discard NULLs unless explicitly told to."

### Q66. What is the difference between UNION and UNION ALL?

**Definition:** `UNION` combines the result sets of two queries and removes all duplicate rows (via an implicit sort or hash distinct); `UNION ALL` combines results and retains all rows, including duplicates, without sorting.

**Real-world example:** Merging two mailing lists:
- **`UNION ALL`**: Stacking both lists together as-is (fast, instant).
- **`UNION`**: Reading through the merged stack, sorting alphabetically, and throwing away duplicate envelopes (slow, high effort).

| Feature | `UNION` | `UNION ALL` |
|---|---|---|
| Duplicate Handling | Removes duplicate rows | Preserves all rows (including duplicates) |
| Performance | Slower (requires an expensive Sort / Distinct operator) | Fast (simple concatenation; zero sort cost) |
| Memory Grant | High memory required for sort/hash | Minimal / Zero memory overhead |
| When to Use | Only when business logic strictly requires unique rows | Whenever result sets are already disjoint or duplicates are allowed |

**SQL example:**
```sql
-- UNION: Sorts and eliminates duplicate salary values (60000 appears once)
SELECT Salary FROM dbo.Employee WHERE DepartmentId = 1
UNION
SELECT Salary FROM dbo.Employee WHERE DepartmentId = 2;

-- UNION ALL: Instant concatenation; Rahul and Raj's 60000 are both returned
SELECT Salary FROM dbo.Employee WHERE DepartmentId = 1
UNION ALL
SELECT Salary FROM dbo.Employee WHERE DepartmentId = 2;
```

**Interview answer (7 yrs experience):** "Defaulting to `UNION` instead of `UNION ALL` is an immediate sign of inexperience. In execution plans, `UNION` inserts a Sort (Distinct) or Hash Match operator that consumes memory grants and can spill to TempDB on large datasets. If the two queries pull from mutually exclusive partitions (for example, active employees from `dbo.Employee` and archived records from `dbo.Employee_Archive`), duplicates are impossible by definition, so paying the sort penalty of `UNION` is pure waste. In our HRMS reporting procedures, changing unnecessary `UNION` statements to `UNION ALL` reduced query duration from 14 seconds to under 1 second on large audit logs."

---

### Q67. What is the difference between INTERSECT and EXCEPT?

**Definition:** `INTERSECT` returns distinct rows that are common to both query results; `EXCEPT` returns distinct rows from the left query that do not exist in the right query.

**Real-world example:** Comparing two teams:
- **`INTERSECT`**: Employees who attended training on both Monday AND Tuesday.
- **`EXCEPT`**: Employees who attended training on Monday but missed Tuesday.

| Operator | Set Theory Equivalent | Returns |
|---|---|---|
| **`INTERSECT`** | $A \cap B$ | Only rows present in **both** sets |
| **`EXCEPT`** | $A - B$ | Rows present in **Set A** that are **not in Set B** |

**SQL example:**
```sql
-- Find employees who were present on 2026-10-01 AND 2026-10-02
SELECT EmployeeId FROM dbo.EmployeeAttendance WHERE AttendanceDate = '2026-10-01' AND Status = 'Present'
INTERSECT
SELECT EmployeeId FROM dbo.EmployeeAttendance WHERE AttendanceDate = '2026-10-02' AND Status = 'Present';
-- Returns EmployeeId: 102

-- Find employees who were present on 2026-10-01 but NOT present on 2026-10-02
SELECT EmployeeId FROM dbo.EmployeeAttendance WHERE AttendanceDate = '2026-10-01' AND Status = 'Present'
EXCEPT
SELECT EmployeeId FROM dbo.EmployeeAttendance WHERE AttendanceDate = '2026-10-02' AND Status = 'Present';
-- Returns EmployeeId: 101
```

**Interview answer (7 yrs experience):** "Both `INTERSECT` and `EXCEPT` return distinct rows and handle `NULL` values properly—treating two `NULL`s as equal, unlike standard equality operators. `EXCEPT` is fantastic for comparing entire tables during database migrations or ETL verification (e.g. `SELECT * FROM Source EXCEPT SELECT * FROM Target`). However, for standard single-key queries, I often compare `EXCEPT` with `NOT EXISTS`. In some query plans, `NOT EXISTS` allows the optimizer to perform an early anti-semi-join seek, whereas `EXCEPT` requires distinct sorting across all compared columns."

---

### Q68. What is the difference between ISNULL() and COALESCE()?

**Definition:** `ISNULL()` is a T-SQL specific proprietary function taking 2 parameters; `COALESCE()` is an ANSI-SQL standard expression that accepts 2 or more parameters and returns the first non-null value.

**Real-world example:** Trying to call an employee: first try mobile phone; if empty, try office phone; if empty, try home phone; if all are empty, display 'No Phone Provided'.

| Feature | `ISNULL(check_exp, replace_val)` | `COALESCE(val1, val2, ..., valN)` |
|---|---|---|
| Standards | T-SQL proprietary | ANSI-SQL standard (portable) |
| Arguments | Exactly 2 | 2 or more |
| Return Data Type | Data type of the **1st argument** (can truncate!) | Data type with the **highest precedence** |
| Execution | Evaluated once | Translated internally to a `CASE` expression (can evaluate subqueries twice!) |

**SQL example:**
```sql
-- Danger of data truncation with ISNULL:
DECLARE @Short VARCHAR(3) = NULL;
SELECT 
    ISNULL(@Short, 'Antigravity')   AS Result_ISNULL,    -- Truncates to 'Ant' (length 3)!
    COALESCE(@Short, 'Antigravity') AS Result_COALESCE;  -- Returns 'Antigravity' (full length)

-- COALESCE evaluates expressions as CASE WHEN:
SELECT COALESCE(e.ManagerId, 0) AS ManagerCode FROM dbo.Employee e;
```

**Interview answer (7 yrs experience):** "This is a favorite senior trick question. Most developers think `COALESCE` is just a multi-argument `ISNULL`. There are two critical production differences: First is data typing: `ISNULL` strictly adopts the data type and length of the first argument, which causes silent string truncation if the fallback is longer. `COALESCE` uses SQL data type precedence rules, preventing truncation. Second is evaluation: `COALESCE` is rewritten under the hood as a `CASE` statement. If you write `COALESCE((SELECT ExpensiveSubquery), 0)`, the subquery can actually be evaluated multiple times. For simple 2-parameter replacements on indexed columns, `ISNULL` is slightly faster and produces cleaner cardinality estimates in query plans."

---

### Q69. What is the difference between CASE and IIF()?

**Definition:** `CASE` is an ANSI-SQL compliant conditional statement that supports multiple `WHEN...THEN` branches; `IIF()` is a shorthand function introduced in SQL Server 2012 that evaluates a single boolean expression and returns one of two values.

**Real-world example:**
- **`IIF`**: Simple binary check: *'Is attendance Present? If yes, 1; else 0.'*
- **`CASE`**: Multi-tier grading: *'If score > 90 Grade A; if > 80 Grade B; if > 70 Grade C; else Grade F.'*

**SQL example:**
```sql
-- IIF shorthand:
SELECT EmployeeName, IIF(Salary >= 75000, 'High Earner', 'Standard Earner') AS Bracket
FROM dbo.Employee;

-- Full CASE statement:
SELECT EmployeeName,
    CASE 
        WHEN Salary >= 80000 THEN 'Executive Tier'
        WHEN Salary >= 65000 THEN 'Senior Tier'
        ELSE 'Associate Tier'
    END AS Tier
FROM dbo.Employee;
```

**Interview answer (7 yrs experience):** "`IIF(condition, true_val, false_val)` was introduced in SQL Server 2012 primarily to ease migrations from Microsoft Access and Excel. Under the covers, SQL Server parses `IIF` directly into a standard `CASE` expression. I use `IIF` for simple binary flags in queries (like `SUM(IIF(Status = 'Present', 1, 0))`), but for any complex business logic with multiple branches, I stick to `CASE` for readability, ANSI standard compliance, and consistency across database engines."

---

### Q70. What is the difference between EXISTS and IN?

**Definition:** `IN` evaluates whether a value matches any value in a list or subquery result; `EXISTS` tests for the existence of any qualifying row in a subquery and stops evaluating as soon as the first matching row is found (short-circuit).

**Real-world example:** Checking if a company has any employees in HR:
- **`EXISTS`**: Walk into the HR room. As soon as you see 1 person sitting at a desk, you turn around and say 'Yes, HR exists' (instant stop).
- **`IN`**: Collect every single HR employee ID into a bucket, then check if your target ID is inside that bucket.

| Feature | `IN` | `EXISTS` |
|---|---|---|
| Evaluation | Evaluates all values (creates set) | Short-circuits on first matching row |
| NULL Handling with `NOT` | **`NOT IN` returns 0 rows if subquery contains ANY NULL!** | **`NOT EXISTS` handles NULLs safely and correctly** |
| Subquery Select List | Must specify exact column (e.g. `SELECT Id`) | Select list ignored (convention is `SELECT 1`) |

**SQL example:**
```sql
-- 1. EXISTS: Returns employees with at least one salary revision
SELECT e.EmployeeName
FROM dbo.Employee e
WHERE EXISTS (
    SELECT 1 
    FROM dbo.EmployeeSalaryHistory esh 
    WHERE esh.EmployeeId = e.EmployeeId
);

-- 2. DANGER of NOT IN with NULLs:
-- If Department contains a row with DepartmentId IS NULL, this returns ZERO rows!
SELECT * FROM dbo.Employee 
WHERE DepartmentId NOT IN (SELECT DepartmentId FROM dbo.Department);

-- SAFE rewrite using NOT EXISTS:
SELECT * FROM dbo.Employee e
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.Department d WHERE d.DepartmentId = e.DepartmentId
);
```

**Interview answer (7 yrs experience):** "For positive checks (`IN` vs `EXISTS`), the modern query optimizer usually generates the identical Left Semi-Join plan. The massive production pitfall is negative checks: `NOT IN` vs `NOT EXISTS`. In ANSI SQL three-valued logic, if the subquery in a `NOT IN` clause returns even a single `NULL` value, the entire predicate evaluates to `UNKNOWN`, resulting in zero rows returned silently! This has caused severe production reporting bugs. In contrast, `NOT EXISTS` uses two-valued Boolean logic and handles `NULL` values safely. In our team's code review guidelines, `NOT IN` on subqueries is strictly prohibited; we mandate `NOT EXISTS` or a `LEFT JOIN ... WHERE right.Key IS NULL`."

---

### Q71. What is the difference between COUNT(*), COUNT(1) and COUNT(ColumnName)?

**Definition:** `COUNT(*)` and `COUNT(1)` count all rows in a result set including rows with NULL values; `COUNT(ColumnName)` counts only rows where the specified column is not `NULL`.

**Real-world example:** Taking attendance in a room of 5 people:
- **`COUNT(*)`**: Counting total heads sitting in seats (5 people).
- **`COUNT(ManagerId)`**: Counting how many people have a manager listed on their badge (Amit and Priya have NULL, so count is 3).

| Syntax | Counts NULLs? | Uses Index? | Performance Difference? |
|---|---|---|---|
| `COUNT(*)` | Yes (counts rows) | Optimizer picks narrowest non-clustered index | Identical to `COUNT(1)` |
| `COUNT(1)` | Yes (counts rows) | Optimizer internally converts `1` to `*` | Identical to `COUNT(*)` |
| `COUNT(Column)` | **No (skips NULLs)** | Must read pages containing that specific column | Slower if forced to read wider index/table |

**SQL example:**
```sql
SELECT 
    COUNT(*)           AS TotalRows,         -- 5 rows
    COUNT(1)           AS CountOne,          -- 5 rows
    COUNT(ManagerId)   AS CountWithManager   -- 3 rows (Amit and Priya have NULL ManagerId!)
FROM dbo.Employee;
```

**Interview answer (7 yrs experience):** "There is an enduring myth that `COUNT(1)` is faster than `COUNT(*)`. In SQL Server, the query parser internally transforms `COUNT(1)` into `COUNT(*)`. The optimizer simply chooses the narrowest non-clustered index on the table to count rows with the least possible logical I/O reads. However, `COUNT(ColumnName)` is fundamentally different: it evaluates the column expression and excludes `NULL` values. This requires SQL Server to access that specific column, which can force a wider index scan or clustered table scan. I always use `COUNT(*)` for row counts and reserve `COUNT(ColumnName)` strictly when business requirements mandate excluding nulls."

---

### Q72. What is the difference between DELETE, TRUNCATE and DROP?

**Definition:** `DELETE` removes specific rows row-by-row and is fully logged; `TRUNCATE` empties the entire table by deallocating 8 KB pages with minimal logging; `DROP` removes both the table data and the table schema definition permanently from the database.

**Real-world example:**
- **`DELETE`**: Taking specific folders out of a filing cabinet one by one and shredding them.
- **`TRUNCATE`**: Emptying all drawers instantly by dumping the contents into a recycling bin, leaving the empty cabinet intact.
- **`DROP`**: Demolishing the filing cabinet with a sledgehammer and hauling the metal away.

| Feature | `DELETE` | `TRUNCATE` | `DROP` |
|---|---|---|---|
| Command Type | DML | DDL (fast DML equivalent) | DDL |
| Filter (`WHERE`) | Supported (can delete 1 row) | Not supported (all rows removed) | Not supported |
| Logging | Full logging (each row in log file) | Minimal logging (page deallocations) | Schema and allocation logged |
| Identity Reset | Does NOT reset identity seed | **Resets identity to initial seed** | Table destroyed completely |
| Triggers | Fires `AFTER DELETE` triggers | **Does NOT fire triggers** | Does not fire DML triggers |
| Foreign Keys | Allowed even if referenced | **Blocked if referenced by FK constraint** | Blocked if referenced by FK constraint |
| Rollback? | Yes (within transaction) | **Yes (fully rollback-able!)** | **Yes (fully rollback-able!)** |

**SQL example:**
```sql
-- 1. DELETE (Row-level, fires triggers, keeps identity counter)
DELETE FROM dbo.Employee WHERE EmployeeId = 105;

-- 2. TRUNCATE (Instant page deallocation, resets identity to 1)
TRUNCATE TABLE dbo.EmployeeAttendance_Staging;

-- 3. DROP (Completely removes table structure)
DROP TABLE dbo.EmployeeAttendance_Staging;
```

**Interview answer (7 yrs experience):** "A common junior mistake is claiming that `TRUNCATE` cannot be rolled back. In SQL Server, if executed inside a `BEGIN TRANSACTION`, `TRUNCATE` can be completely rolled back because the extent and page deallocations are recorded in the transaction log. `TRUNCATE` acquires an exclusive table-level schema-modification (Sch-M) lock and releases data pages directly to the allocation maps (GAM/SGAM), making it orders of magnitude faster than `DELETE` on millions of rows. However, `TRUNCATE` has strict prerequisites: it fails if the table is referenced by an active Foreign Key constraint (even if the parent table is empty), and it bypasses `DELETE` triggers. For large batch archiving in our HRMS where foreign keys prevent `TRUNCATE`, we delete in chunks of 5,000 to 10,000 rows inside a loop to prevent log explosion and lock escalation."

---

### Q73. What is MERGE in SQL Server? What are its limitations and potential risks?

**Definition:** `MERGE` (also known as Upsert) is a single statement that synchronizes target and source tables by executing `INSERT`, `UPDATE`, or `DELETE` operations based on match conditions.

**Real-world example:** Daily synchronization of biometric punch data from attendance machines: if punch record #101 already exists for today, update the logout time; if it does not exist, insert a new record.

**SQL example:**
```sql
-- Upsert attendance records
MERGE dbo.EmployeeAttendance AS Target
USING dbo.EmployeeAttendance_Staging AS Source
ON (Target.EmployeeId = Source.EmployeeId AND Target.AttendanceDate = Source.AttendanceDate)
WHEN MATCHED THEN
    UPDATE SET Target.Status = Source.Status
WHEN NOT MATCHED BY TARGET THEN
    INSERT (EmployeeId, AttendanceDate, Status)
    VALUES (Source.EmployeeId, Source.AttendanceDate, Source.Status);
```

**Interview answer (7 yrs experience):** "While `MERGE` syntax is elegant, senior SQL Server engineers approach it with extreme caution. Historically, `MERGE` in SQL Server has suffered from documented concurrency bugs, race conditions leading to primary key violations, and deadlocks under concurrent multi-threaded execution. Furthermore, `MERGE` acquires table-level and range locks aggressively. In high-concurrency production systems, we often replace `MERGE` with explicit separate `UPDATE` and `INSERT` statements wrapped in a transaction, or use `UPDLOCK, HOLDLOCK` hints:
```sql
UPDATE target WITH (UPDLOCK, SERIALIZABLE) SET ... FROM ...;
INSERT INTO target SELECT ... WHERE NOT EXISTS (...);
```
This avoids known `MERGE` edge-case anomalies while giving us precise control over concurrency locking."

---

### Q74. What is Dynamic Pivoting?

**Definition:** Dynamic Pivoting is an advanced T-SQL technique that uses Dynamic SQL and `STRING_AGG` (or `FOR XML PATH`) to query distinct values from a dimension table at runtime, build a comma-separated column list, and execute a dynamic `PIVOT` query without hardcoded column names.

**Real-world example:** Generating an attendance matrix report for an HR department where columns represent every day in the current month (Day 1, Day 2, ..., Day 31), or every department name, which changes dynamically as new departments are opened.

**SQL example:**
```sql
-- Dynamic Pivot for Department Names
DECLARE @Columns NVARCHAR(MAX) = N'';
DECLARE @Sql     NVARCHAR(MAX) = N'';

-- 1. Construct distinct quoted column list dynamically
SELECT @Columns = STRING_AGG(QUOTENAME(DepartmentName), ',') WITHIN GROUP (ORDER BY DepartmentName)
FROM (SELECT DISTINCT DepartmentName FROM dbo.Department) d;

-- 2. Build the dynamic pivot query
SET @Sql = N'
SELECT ' + @Columns + N'
FROM (
    SELECT d.DepartmentName, e.Salary
    FROM dbo.Employee e
    JOIN dbo.Department d ON e.DepartmentId = d.DepartmentId
) src
PIVOT (
    SUM(Salary)
    FOR DepartmentName IN (' + @Columns + N')
) pvt;';

-- 3. Safely execute dynamic SQL
EXEC sys.sp_executesql @Sql;
```

**Interview answer (7 yrs experience):** "Static `PIVOT` statements require hardcoding column names, which fails in production reporting where attributes (like months, pay components, or project codes) change dynamically. To solve this, I implement dynamic pivoting. In SQL Server 2017+, we use `STRING_AGG(QUOTENAME(ColumnVal), ',')` to build the pivot header list cleanly; on older versions, we used `FOR XML PATH('')`. In production, I always sanitize column names using `QUOTENAME()` to guard against SQL injection, check for `NULL` string concatenation issues, and execute via `sp_executesql`. When the pivoted dataset is massive, doing the pivot in C# Linq / application memory is often faster and leaves the database CPU free for transactional queries."

---

### Q75. How can you pass unlimited parameters to a Stored Procedure? Explain Table-Valued Parameters (TVP).

**Definition:** A Table-Valued Parameter (TVP) allows a client application (such as .NET Core via Dapper or ADO.NET) to pass strongly typed, tabular datasets (arrays or lists of objects) directly into a SQL Server stored procedure as a single parameter.

**Real-world example:** Submitting a bulk payroll approval for 5,000 employees with one click in the web UI. Instead of making 5,000 separate database round-trips or passing a fragile comma-delimited string (`'101,102,103'`), you pass a single TVP containing all 5,000 rows.

**SQL example:**
```sql
-- 1. Create a User-Defined Table Type
CREATE TYPE dbo.EmployeeIdListType AS TABLE
(
    EmployeeId INT NOT NULL PRIMARY KEY
);
GO

-- 2. Create Stored Procedure accepting the TVP (Must be READONLY!)
CREATE PROCEDURE dbo.usp_GetEmployeesByIds
    @EmpIds dbo.EmployeeIdListType READONLY
AS
BEGIN
    SET NOCOUNT ON;

    SELECT e.EmployeeId, e.EmployeeName, e.Salary, d.DepartmentName
    FROM dbo.Employee e
    JOIN @EmpIds ids ON e.EmployeeId = ids.EmployeeId
    LEFT JOIN dbo.Department d ON e.DepartmentId = d.DepartmentId;
END;
GO
```

**C# / .NET Core with Dapper Implementation:**
```csharp
using System.Data;
using Dapper;
using Microsoft.Data.SqlClient;

public async Task<IEnumerable<EmployeeDto>> GetEmployeesBulkAsync(List<int> employeeIds)
{
    // 1. Convert List to DataTable matching the SQL Type
    var table = new DataTable();
    table.Columns.Add("EmployeeId", typeof(int));
    foreach (var id in employeeIds)
        table.Rows.Add(id);

    using var connection = new SqlConnection(_connectionString);

    // 2. Pass as TVP using Dapper's AsTableValuedParameter
    var result = await connection.QueryAsync<EmployeeDto>(
        "dbo.usp_GetEmployeesByIds",
        new { EmpIds = table.AsTableValuedParameter("dbo.EmployeeIdListType") },
        commandType: CommandType.StoredProcedure
    );

    return result;
}
```

**Interview answer (7 yrs experience):** "Table-Valued Parameters are the cleanest and most performant pattern for passing collections from .NET to SQL Server. Before TVPs, developers used comma-separated strings with `STRING_SPLIT` or XML payloads, which had CPU parsing overhead and no compile-time schema validation. TVPs are backed by TempDB table variables, are strongly typed, and must be declared with the `READONLY` keyword in the stored procedure. In our HRMS bulk attendance punch module, passing batches of 10,000 records via TVP reduced network payload size and eliminated 10,000 individual round trips, turning an 8-minute process into a 400-millisecond execution. Additionally, because the TVP can have an inline primary key, join performance with base tables is lightning fast."
