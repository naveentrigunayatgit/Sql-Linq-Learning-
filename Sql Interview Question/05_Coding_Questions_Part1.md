# Section 3 (A, B, C): Coding Questions – Basic, Joins/Subqueries, Window Functions

> [!IMPORTANT]
> Run **`00_Setup_SampleTables.sql`** first. It creates and fills `Employee`, `Department`, `EmployeeSalaryHistory` and `EmployeeAttendance`. If a question needs another table (for example `Training`, `Project`, `Sales`, `Transactions` or `EmployeeLogin`), that question includes its own `CREATE TABLE` and `INSERT` script.

**Sample data used for every expected output below**

| EmployeeId | EmployeeName | DepartmentId | ManagerId | Salary | JoiningDate |
|---|---|---|---|---|---|
| 101 | Amit | 1 | NULL | 80000 | 2022-01-10 |
| 102 | Rahul | 1 | 101 | 60000 | 2023-03-15 |
| 103 | Priya | 2 | NULL | 90000 | 2021-06-20 |
| 104 | Sneha | 2 | 103 | 70000 | 2024-01-05 |
| 105 | Raj | 1 | 101 | 60000 | 2023-08-10 |

Department: (1, IT), (2, HR), (3, Finance). Salary history and attendance are as defined in the setup script.

---

## Table of Contents

**A. Basic to Intermediate**
- [C1. Second-highest salary](#c1-second-highest-salary)
- [C2. Nth highest salary](#c2-nth-highest-salary)
- [C3. Third-highest salary without TOP](#c3-third-highest-salary-without-top)
- [C4. Find duplicate records based on EmployeeCode](#c4-find-duplicate-records-based-on-employeecode)
- [C5. Delete duplicates keeping one record](#c5-delete-duplicates-keeping-one-record)
- [C6. Employees who do not belong to any department](#c6-employees-who-do-not-belong-to-any-department)
- [C7. Departments that have no employees](#c7-departments-that-have-no-employees)
- [C8. Employees earning above the average salary](#c8-employees-earning-above-the-average-salary)
- [C9. Employees earning more than their manager](#c9-employees-earning-more-than-their-manager)
- [C10. Employees who joined in the last 30 days](#c10-employees-who-joined-in-the-last-30-days)
- [C11. Names starting with A and ending with N](#c11-names-starting-with-a-and-ending-with-n)
- [C12. Employees who have the same salary](#c12-employees-who-have-the-same-salary)
- [C13. Maximum salary in each department](#c13-maximum-salary-in-each-department)
- [C14. Top three highest-paid employees in each department](#c14-top-three-highest-paid-employees-in-each-department)
- [C15. Employees who joined in the same month and year](#c15-employees-who-joined-in-the-same-month-and-year)

**B. Joins and Subqueries**
- [C16. Employee details with department names](#c16-employee-details-with-department-names)
- [C17. Employees with no attendance record](#c17-employees-with-no-attendance-record)
- [C18. Employees who completed all mandatory trainings](#c18-employees-who-completed-all-mandatory-trainings)
- [C19. Departments with more than five employees](#c19-departments-with-more-than-five-employees)
- [C20. Salary above the department average](#c20-salary-above-the-department-average)
- [C21. Employees who have the same manager](#c21-employees-who-have-the-same-manager)
- [C22. Employees who joined before their managers](#c22-employees-who-joined-before-their-managers)
- [C23. Highest-paid employee per department using a subquery](#c23-highest-paid-employee-per-department-using-a-subquery)
- [C24. Highest-paid employee per department using a CTE](#c24-highest-paid-employee-per-department-using-a-cte)
- [C25. Records in Table A but missing in Table B](#c25-records-in-table-a-but-missing-in-table-b)
- [C26. Common records between two tables](#c26-common-records-between-two-tables)
- [C27. Employees with at least one completed project using EXISTS](#c27-employees-with-at-least-one-completed-project-using-exists)

**C. Window Functions**
- [C28. Unique sequence with ROW_NUMBER](#c28-unique-sequence-with-row_number)
- [C29. Top two salaries per department with DENSE_RANK](#c29-top-two-salaries-per-department-with-dense_rank)
- [C30. Top three salaries per department with RANK](#c30-top-three-salaries-per-department-with-rank)
- [C31. Find duplicates with ROW_NUMBER](#c31-find-duplicates-with-row_number)
- [C32. Previous salary with LAG](#c32-previous-salary-with-lag)
- [C33. Next salary with LEAD](#c33-next-salary-with-lead)
- [C34. Running total of salaries](#c34-running-total-of-salaries)
- [C35. Cumulative monthly sales](#c35-cumulative-monthly-sales)
- [C36. First and last transaction per employee](#c36-first-and-last-transaction-per-employee)
- [C37. Salary higher than the previous salary](#c37-salary-higher-than-the-previous-salary)
- [C38. Top 10 percent of employees with NTILE](#c38-top-10-percent-of-employees-with-ntile)
- [C39. Department percentage of total salary](#c39-department-percentage-of-total-salary)
- [C40. Consecutive login dates (gaps and islands)](#c40-consecutive-login-dates-gaps-and-islands)

---

## A. Basic to Intermediate

### C1. Second-highest salary

**Concept / Definition:** Find the largest salary that is smaller than the maximum. Another way is to rank the distinct salaries and pick rank 2.

**Real-world use:** HR wants the second-highest salary for a bonus review.

**Solution:**
```sql
-- Approach 1: MAX below MAX (handles ties, returns NULL if there is no 2nd salary)
SELECT MAX(Salary) AS SecondHighestSalary
FROM dbo.Employee
WHERE Salary < (SELECT MAX(Salary) FROM dbo.Employee);

-- Approach 2: OFFSET/FETCH over DISTINCT salaries (handles ties; returns 0 rows if there is no 2nd salary)
SELECT DISTINCT Salary AS SecondHighestSalary
FROM dbo.Employee
WHERE Salary IS NOT NULL
ORDER BY Salary DESC
OFFSET 1 ROW FETCH NEXT 1 ROW ONLY;

-- Approach 2b: classic TOP version
SELECT TOP (1) Salary AS SecondHighestSalary
FROM (SELECT DISTINCT TOP (2) Salary
      FROM dbo.Employee
      WHERE Salary IS NOT NULL
      ORDER BY Salary DESC) AS t
ORDER BY Salary ASC;   -- caution: if only 1 distinct salary exists, this returns the HIGHEST

-- Approach 3: DENSE_RANK (handles ties and also returns WHO earns it)
WITH Ranked AS (
    SELECT EmployeeId, EmployeeName, Salary,
           DENSE_RANK() OVER (ORDER BY Salary DESC) AS SalaryRank
    FROM dbo.Employee
    WHERE Salary IS NOT NULL
)
SELECT EmployeeId, EmployeeName, Salary
FROM Ranked
WHERE SalaryRank = 2;
```

**Output:** (Approach 1 and 2 return `80000`. Approach 3 returns:)

| EmployeeId | EmployeeName | Salary |
|---|---|---|
| 101 | Amit | 80000 |

**7-yr insight:** Without `DISTINCT`, `TOP`/`OFFSET` returns the wrong value when the top salary is tied. Use `DENSE_RANK` (not `ROW_NUMBER` or `RANK`) when ties should share a position. An index on `Salary DESC` turns all three approaches into short index seeks or scans. `MAX` ignores NULLs. In a `DESC` sort, SQL Server puts NULLs last, but filtering them out explicitly makes the intent clear.

---

### C2. Nth highest salary

**Concept / Definition:** This generalises C1 with a parameter `@N`. Rank the distinct salaries and return the one at position N.

**Real-world use:** Payroll needs a reusable query, for example "show the 3rd highest salary band".

**Solution:**
```sql
DECLARE @N INT = 3;

-- Approach 1: DENSE_RANK (recommended – correct with ties, returns employees too)
WITH Ranked AS (
    SELECT EmployeeId, EmployeeName, Salary,
           DENSE_RANK() OVER (ORDER BY Salary DESC) AS SalaryRank
    FROM dbo.Employee
    WHERE Salary IS NOT NULL
)
SELECT EmployeeId, EmployeeName, Salary
FROM Ranked
WHERE SalaryRank = @N;

-- Approach 2: OFFSET/FETCH over DISTINCT salaries (value only)
SELECT DISTINCT Salary
FROM dbo.Employee
WHERE Salary IS NOT NULL
ORDER BY Salary DESC
OFFSET (@N - 1) ROWS FETCH NEXT 1 ROW ONLY;

-- Approach 3: Correlated subquery (portable to any SQL engine, but O(n^2))
SELECT DISTINCT e1.Salary
FROM dbo.Employee AS e1
WHERE @N - 1 = (SELECT COUNT(DISTINCT e2.Salary)
                FROM dbo.Employee AS e2
                WHERE e2.Salary > e1.Salary);

-- Reusable inline table-valued function (iTVF is inlined by the optimizer)
GO
CREATE OR ALTER FUNCTION dbo.fn_NthHighestSalary (@N INT)
RETURNS TABLE
AS
RETURN
(
    SELECT DISTINCT Salary
    FROM (SELECT Salary, DENSE_RANK() OVER (ORDER BY Salary DESC) AS rnk
          FROM dbo.Employee WHERE Salary IS NOT NULL) AS r
    WHERE rnk = @N
);
GO
SELECT * FROM dbo.fn_NthHighestSalary(3);
```

**Output (N = 3):**

| EmployeeId | EmployeeName | Salary |
|---|---|---|
| 104 | Sneha | 70000 |

**7-yr insight:** Validate `@N` (must be 1 or more). Return an empty set or NULL when N is larger than the number of distinct salaries. Prefer an **inline** TVF over a scalar UDF, because scalar UDFs block parallelism before SQL 2019 (scalar UDF inlining arrived in 2019). The correlated `COUNT(DISTINCT)` approach scales quadratically, so mention that as the trade-off.

---

### C3. Third-highest salary without TOP

**Concept / Definition:** Solve it with ranking, nested aggregates, or a correlated count instead of the `TOP` keyword.

**Real-world use:** An interviewer wants to test whether you know alternatives to `TOP`.

**Solution:**
```sql
-- Approach 1: DENSE_RANK (ties-safe)
SELECT DISTINCT Salary AS ThirdHighestSalary
FROM (SELECT Salary, DENSE_RANK() OVER (ORDER BY Salary DESC) AS rnk
      FROM dbo.Employee) AS r
WHERE rnk = 3;

-- Approach 2: Nested MAX (ties-safe, but gets ugly for large N)
SELECT MAX(Salary) AS ThirdHighestSalary
FROM dbo.Employee
WHERE Salary < (SELECT MAX(Salary) FROM dbo.Employee
                WHERE Salary < (SELECT MAX(Salary) FROM dbo.Employee));

-- Approach 3: Correlated count – exactly 2 distinct salaries are greater
SELECT DISTINCT e1.Salary AS ThirdHighestSalary
FROM dbo.Employee AS e1
WHERE 2 = (SELECT COUNT(DISTINCT e2.Salary)
           FROM dbo.Employee AS e2
           WHERE e2.Salary > e1.Salary);

-- Approach 4: OFFSET/FETCH (no TOP keyword)
SELECT DISTINCT Salary AS ThirdHighestSalary
FROM dbo.Employee
ORDER BY Salary DESC
OFFSET 2 ROWS FETCH NEXT 1 ROW ONLY;
```

**Output:**

| ThirdHighestSalary |
|---|
| 70000 |

**7-yr insight:** All four approaches handle ties because they work on *distinct* salaries. Nested `MAX` returns NULL instead of an empty set when no 3rd salary exists, which matters to application code that expects a row. Each nesting level in Approach 2 is another index seek on `Salary`, so it is cheap for small N.

---

### C4. Find duplicate records based on EmployeeCode

**Concept / Definition:** `GROUP BY` the business key and keep the groups with `HAVING COUNT(*) > 1`.

**Real-world use:** A nightly HR import loaded the same employee more than once, and you must find the duplicates before payroll runs.

**Solution:**
```sql
-- Demo table (staging data that has an EmployeeCode column)
DROP TABLE IF EXISTS dbo.EmployeeStaging;
CREATE TABLE dbo.EmployeeStaging (
    Id           INT IDENTITY(1,1) PRIMARY KEY,
    EmployeeCode VARCHAR(10) NOT NULL,
    EmployeeName VARCHAR(50) NOT NULL
);
INSERT INTO dbo.EmployeeStaging (EmployeeCode, EmployeeName) VALUES
('E001','Amit'),('E002','Rahul'),('E001','Amit'),
('E003','Priya'),('E002','Rahul'),('E002','Rahul');

-- Approach 1: GROUP BY / HAVING (which codes are duplicated, and how many times)
SELECT EmployeeCode, COUNT(*) AS DuplicateCount
FROM dbo.EmployeeStaging
GROUP BY EmployeeCode
HAVING COUNT(*) > 1;

-- Approach 2: Window COUNT (returns every duplicate ROW with all its columns)
SELECT Id, EmployeeCode, EmployeeName
FROM (SELECT *, COUNT(*) OVER (PARTITION BY EmployeeCode) AS cnt
      FROM dbo.EmployeeStaging) AS x
WHERE cnt > 1
ORDER BY EmployeeCode, Id;
```

**Output (Approach 1):**

| EmployeeCode | DuplicateCount |
|---|---|
| E001 | 2 |
| E002 | 3 |

**7-yr insight:** First agree on what "duplicate" means: the business key only, or every column. After cleanup, add a `UNIQUE` constraint or index on `EmployeeCode` so it cannot happen again. Detecting duplicates without preventing them only treats the symptom. An index on `EmployeeCode` lets the `GROUP BY` use a stream aggregate.

---

### C5. Delete duplicates keeping one record

**Concept / Definition:** Number the rows inside each duplicate group with `ROW_NUMBER()`, then delete every row whose number is greater than 1. You can delete through the CTE.

**Real-world use:** Clean up the staging table from C4 and keep the first-loaded row for each EmployeeCode.

**Solution:**
```sql
-- Approach 1: CTE + ROW_NUMBER (recommended; works even when rows are fully identical)
WITH Dups AS (
    SELECT Id,
           ROW_NUMBER() OVER (PARTITION BY EmployeeCode ORDER BY Id) AS rn
    FROM dbo.EmployeeStaging
)
DELETE FROM Dups
WHERE rn > 1;

-- Approach 2: Keep MIN(Id) per group (needs a unique Id column)
DELETE FROM dbo.EmployeeStaging
WHERE Id NOT IN (SELECT MIN(Id) FROM dbo.EmployeeStaging GROUP BY EmployeeCode);

-- Approach 3: Self-join delete
DELETE s1
FROM dbo.EmployeeStaging AS s1
JOIN dbo.EmployeeStaging AS s2
  ON s1.EmployeeCode = s2.EmployeeCode
 AND s1.Id > s2.Id;

SELECT * FROM dbo.EmployeeStaging ORDER BY Id;
```

**Output (rows left; Ids 3, 5 and 6 were deleted):**

| Id | EmployeeCode | EmployeeName |
|---|---|---|
| 1 | E001 | Amit |
| 2 | E002 | Rahul |
| 4 | E003 | Priya |

**7-yr insight:** In production, run the `SELECT` version first, wrap the delete in a transaction, and record row counts with `@@ROWCOUNT`. For millions of rows, delete in batches (`DELETE TOP (5000) ... WHILE @@ROWCOUNT > 0`) to avoid log growth and lock escalation. The `ORDER BY` inside `ROW_NUMBER` decides which row survives (oldest, newest, or most complete), so it is a business decision, not a technical one.

---

### C6. Employees who do not belong to any department

**Concept / Definition:** Find rows with a NULL foreign key, plus "orphans" whose DepartmentId does not exist in `Department`. Use `LEFT JOIN ... IS NULL` or `NOT EXISTS`.

**Real-world use:** A data-quality report lists staff who are not mapped to a cost centre.

**Solution:**
```sql
-- Approach 1: LEFT JOIN anti-join (catches NULL DepartmentId AND orphaned ids)
SELECT e.EmployeeId, e.EmployeeName, e.DepartmentId
FROM dbo.Employee AS e
LEFT JOIN dbo.Department AS d
       ON d.DepartmentId = e.DepartmentId
WHERE d.DepartmentId IS NULL;

-- Approach 2: NOT EXISTS (same result, often the cleanest plan)
SELECT e.EmployeeId, e.EmployeeName, e.DepartmentId
FROM dbo.Employee AS e
WHERE NOT EXISTS (SELECT 1 FROM dbo.Department AS d
                  WHERE d.DepartmentId = e.DepartmentId);

-- Only NULL-mapped employees:
SELECT EmployeeId, EmployeeName FROM dbo.Employee WHERE DepartmentId IS NULL;
```

**Output:** *(0 rows)*. Every sample employee belongs to department 1 or 2. To test, insert `(106,'Neha',NULL,NULL,50000,'2025-05-01')` and Neha appears.

| EmployeeId | EmployeeName | DepartmentId |
|---|---|---|

**7-yr insight:** `= NULL` never matches, so always use `IS NULL`. Orphans should not exist if a `FOREIGN KEY` constraint is in place. Mention that the FK prevents them, and that a NULL FK is still allowed unless the column is `NOT NULL`.

---

### C7. Departments that have no employees

**Concept / Definition:** This is the reverse anti-join: departments with no matching rows in `Employee`.

**Real-world use:** Finance wants to find empty departments to merge or close.

**Solution:**
```sql
-- Approach 1: NOT EXISTS
SELECT d.DepartmentId, d.DepartmentName
FROM dbo.Department AS d
WHERE NOT EXISTS (SELECT 1 FROM dbo.Employee AS e
                  WHERE e.DepartmentId = d.DepartmentId);

-- Approach 2: LEFT JOIN ... IS NULL
SELECT d.DepartmentId, d.DepartmentName
FROM dbo.Department AS d
LEFT JOIN dbo.Employee AS e ON e.DepartmentId = d.DepartmentId
WHERE e.EmployeeId IS NULL;

-- Approach 3: NOT IN – safe here only because we filter NULLs out
SELECT d.DepartmentId, d.DepartmentName
FROM dbo.Department AS d
WHERE d.DepartmentId NOT IN (SELECT e.DepartmentId FROM dbo.Employee AS e
                             WHERE e.DepartmentId IS NOT NULL);
```

**Output:**

| DepartmentId | DepartmentName |
|---|---|
| 3 | Finance |

**7-yr insight:** This is the classic `NOT IN` trap. If the subquery returns even one NULL, `NOT IN` returns **no rows**. `NOT EXISTS` is NULL-safe and usually produces a Left Anti Semi Join. Index `Employee(DepartmentId)`, because SQL Server does **not** index foreign keys automatically.

---

### C8. Employees earning above the average salary

**Concept / Definition:** Compare each row with a scalar aggregate, using either a subquery or a window `AVG() OVER()`.

**Real-world use:** Compensation team lists above-average earners.

**Solution:**
```sql
-- Approach 1: Scalar subquery
SELECT EmployeeId, EmployeeName, Salary
FROM dbo.Employee
WHERE Salary > (SELECT AVG(Salary) FROM dbo.Employee);

-- Approach 2: Window function (one pass, can also show the average)
SELECT EmployeeId, EmployeeName, Salary, AvgSalary
FROM (SELECT EmployeeId, EmployeeName, Salary,
             AVG(CAST(Salary AS DECIMAL(18,2))) OVER () AS AvgSalary
      FROM dbo.Employee) AS x
WHERE Salary > AvgSalary;
```

**Output (average = 360000 / 5 = 72000):**

| EmployeeId | EmployeeName | Salary | AvgSalary |
|---|---|---|---|
| 101 | Amit | 80000 | 72000.00 |
| 103 | Priya | 90000 | 72000.00 |

**7-yr insight:** `AVG` on an `INT` column returns an `INT` (integer division), so cast to `DECIMAL` when precision matters. `AVG` ignores NULL salaries. Decide whether NULLs should count as 0 (`AVG(ISNULL(Salary,0))`).

---

### C9. Employees earning more than their manager

**Concept / Definition:** A **self-join** treats `Employee` as two roles, employee and manager, linked by `ManagerId = EmployeeId`.

**Real-world use:** An audit flags pay inversions, where a report earns more than their manager.

**Solution:**
```sql
SELECT e.EmployeeId,
       e.EmployeeName,
       e.Salary        AS EmployeeSalary,
       m.EmployeeName  AS ManagerName,
       m.Salary        AS ManagerSalary
FROM dbo.Employee AS e
JOIN dbo.Employee AS m              -- INNER JOIN drops employees with no manager
  ON m.EmployeeId = e.ManagerId
WHERE e.Salary > m.Salary;
```

**Output:** *(0 rows)*. Rahul (60000) and Raj (60000) earn less than Amit (80000), and Sneha (70000) earns less than Priya (90000). If Rahul's salary were raised to 85000, he would appear.

| EmployeeId | EmployeeName | EmployeeSalary | ManagerName | ManagerSalary |
|---|---|---|---|---|

**7-yr insight:** Top-level managers (`ManagerId IS NULL`) drop out naturally with an INNER JOIN. Index `Employee(ManagerId)` to support the self-join. For indirect chains (skip-level managers), you would need a recursive CTE.

---

### C10. Employees who joined in the last 30 days

**Concept / Definition:** Filter on a date range relative to `GETDATE()`. Write the filter so the column is not wrapped in a function, which keeps it **sargable** (able to use an index).

**Real-world use:** The onboarding team sends welcome kits to recent joiners.

**Solution:**
```sql
-- Recommended: sargable range (index on JoiningDate can be used)
SELECT EmployeeId, EmployeeName, JoiningDate
FROM dbo.Employee
WHERE JoiningDate >= DATEADD(DAY, -30, CAST(GETDATE() AS DATE))
  AND JoiningDate <  DATEADD(DAY, 1,  CAST(GETDATE() AS DATE));   -- excludes future-dated rows

-- Avoid: function on the column => index scan
-- WHERE DATEDIFF(DAY, JoiningDate, GETDATE()) <= 30
```

**Output:** *(0 rows)*. The latest joining date in the sample data is 2024-01-05, which is far more than 30 days before today.

| EmployeeId | EmployeeName | JoiningDate |
|---|---|---|

**7-yr insight:** `CAST(GETDATE() AS DATE)` removes the time part so "30 days" means whole calendar days. If `JoiningDate` is `DATETIME`, use the half-open `>= start AND < end` pattern. Ask whether "last 30 days" includes today and future-dated hires.

---

### C11. Names starting with A and ending with N

**Concept / Definition:** Pattern matching with `LIKE`. `%` matches any sequence of characters. Case sensitivity depends on the column **collation**.

**Real-world use:** A search screen filters employees by name pattern.

**Solution:**
```sql
-- Case-insensitive under the default collation (SQL_Latin1_General_CP1_CI_AS)
SELECT EmployeeId, EmployeeName
FROM dbo.Employee
WHERE EmployeeName LIKE 'A%N';

-- Force case-sensitive matching (uppercase A, lowercase n)
SELECT EmployeeId, EmployeeName
FROM dbo.Employee
WHERE EmployeeName COLLATE Latin1_General_CS_AS LIKE 'A%n';

-- Alternative without LIKE
SELECT EmployeeId, EmployeeName
FROM dbo.Employee
WHERE LEFT(EmployeeName, 1) = 'A' AND RIGHT(RTRIM(EmployeeName), 1) = 'N';
```

**Output:** *(0 rows)*. Amit starts with A but ends with "t". A name such as "Arjun" or "Aman" would match.

| EmployeeId | EmployeeName |
|---|---|

**7-yr insight:** `LIKE 'A%'` can use an index seek because the prefix is fixed. A leading wildcard (`'%n'`) forces a scan. Trailing spaces in `CHAR` columns can break "ends with" checks, so use `RTRIM` or `VARCHAR`. For heavy suffix searches, consider a persisted computed column `REVERSE(EmployeeName)` with an index on it.

---

### C12. Employees who have the same salary

**Concept / Definition:** Find salary values that appear more than once, then return the employees with those salaries.

**Real-world use:** A pay-equity review groups people with identical pay.

**Solution:**
```sql
-- Approach 1: Window COUNT (single pass, recommended)
SELECT EmployeeId, EmployeeName, Salary
FROM (SELECT EmployeeId, EmployeeName, Salary,
             COUNT(*) OVER (PARTITION BY Salary) AS SameSalaryCount
      FROM dbo.Employee) AS x
WHERE SameSalaryCount > 1
ORDER BY Salary, EmployeeId;

-- Approach 2: IN + GROUP BY/HAVING
SELECT EmployeeId, EmployeeName, Salary
FROM dbo.Employee
WHERE Salary IN (SELECT Salary FROM dbo.Employee
                 GROUP BY Salary HAVING COUNT(*) > 1);

-- Approach 3: Self-join pairs (e1.Id < e2.Id avoids mirror pairs and self-matches)
SELECT e1.EmployeeName AS Employee1, e2.EmployeeName AS Employee2, e1.Salary
FROM dbo.Employee AS e1
JOIN dbo.Employee AS e2
  ON e1.Salary = e2.Salary
 AND e1.EmployeeId < e2.EmployeeId;
```

**Output (Approach 1):**

| EmployeeId | EmployeeName | Salary |
|---|---|---|
| 102 | Rahul | 60000 |
| 105 | Raj | 60000 |

**7-yr insight:** In the self-join, `<` instead of `<>` prevents duplicate mirror pairs (Rahul–Raj and Raj–Rahul). With N employees on the same salary, the self-join produces N·(N−1)/2 rows, so the window approach scales better. NULL salaries never match each other under `=`.

---

### C13. Maximum salary in each department

**Concept / Definition:** Use `GROUP BY` with the `MAX()` aggregate, and join to `Department` for readable names.

**Real-world use:** A management dashboard shows the salary ceiling per department.

**Solution:**
```sql
-- Departments that have employees
SELECT d.DepartmentName, MAX(e.Salary) AS MaxSalary
FROM dbo.Employee AS e
JOIN dbo.Department AS d ON d.DepartmentId = e.DepartmentId
GROUP BY d.DepartmentId, d.DepartmentName
ORDER BY d.DepartmentName;

-- Include empty departments (MaxSalary = NULL for Finance)
SELECT d.DepartmentName, MAX(e.Salary) AS MaxSalary
FROM dbo.Department AS d
LEFT JOIN dbo.Employee AS e ON e.DepartmentId = d.DepartmentId
GROUP BY d.DepartmentId, d.DepartmentName;
```

**Output (INNER JOIN version):**

| DepartmentName | MaxSalary |
|---|---|
| HR | 90000 |
| IT | 80000 |

**7-yr insight:** Group by `DepartmentId` as well as the name, because names may not be unique. A covering index `Employee(DepartmentId, Salary DESC)` supports this and the "top N per group" queries that follow. Interviewers often ask next: "now show *who* earns it" (see C23/C24).

---

### C14. Top three highest-paid employees in each department

**Concept / Definition:** This is the "Top-N per group" pattern: rank within `PARTITION BY DepartmentId`, then filter on the rank.

**Real-world use:** Each department head nominates the top three earners for a retention plan.

**Solution:**
```sql
-- Approach 1: DENSE_RANK (top 3 distinct salary levels – ties included)
WITH Ranked AS (
    SELECT e.EmployeeId, e.EmployeeName, d.DepartmentName, e.Salary,
           DENSE_RANK() OVER (PARTITION BY e.DepartmentId
                              ORDER BY e.Salary DESC) AS SalaryRank
    FROM dbo.Employee AS e
    JOIN dbo.Department AS d ON d.DepartmentId = e.DepartmentId
)
SELECT DepartmentName, EmployeeName, Salary, SalaryRank
FROM Ranked
WHERE SalaryRank <= 3
ORDER BY DepartmentName, SalaryRank, EmployeeName;

-- Approach 2: ROW_NUMBER (exactly 3 people max, ties broken arbitrarily -> add tiebreaker)
--   ROW_NUMBER() OVER (PARTITION BY e.DepartmentId ORDER BY e.Salary DESC, e.EmployeeId)

-- Approach 3: CROSS APPLY + TOP (great with index on (DepartmentId, Salary DESC))
SELECT d.DepartmentName, t.EmployeeName, t.Salary
FROM dbo.Department AS d
CROSS APPLY (SELECT TOP (3) WITH TIES e.EmployeeName, e.Salary
             FROM dbo.Employee AS e
             WHERE e.DepartmentId = d.DepartmentId
             ORDER BY e.Salary DESC) AS t;
```

**Output (Approach 1):**

| DepartmentName | EmployeeName | Salary | SalaryRank |
|---|---|---|---|
| HR | Priya | 90000 | 1 |
| HR | Sneha | 70000 | 2 |
| IT | Amit | 80000 | 1 |
| IT | Rahul | 60000 | 2 |
| IT | Raj | 60000 | 2 |

**7-yr insight:** Clarify "top 3 people" (`ROW_NUMBER`) versus "top 3 salary levels" (`DENSE_RANK`). `RANK` sits in between because it skips numbers after ties. When there are few departments and many employees, `CROSS APPLY TOP` with a supporting index does a small seek per department instead of ranking the whole table.

---

### C15. Employees who joined in the same month and year

**Concept / Definition:** Group or self-join on the (year, month) of `JoiningDate`. A window `COUNT` over that key works too.

**Real-world use:** HR plans joint work-anniversary celebrations for each joining cohort.

**Solution:**
```sql
-- Approach 1: Window COUNT on month bucket
SELECT EmployeeId, EmployeeName, JoiningDate
FROM (SELECT EmployeeId, EmployeeName, JoiningDate,
             COUNT(*) OVER (PARTITION BY YEAR(JoiningDate), MONTH(JoiningDate)) AS Cohort
      FROM dbo.Employee) AS x
WHERE Cohort > 1
ORDER BY JoiningDate;

-- Approach 2: Self-join pairs
SELECT e1.EmployeeName AS Employee1, e2.EmployeeName AS Employee2,
       FORMAT(e1.JoiningDate, 'yyyy-MM') AS JoinMonth
FROM dbo.Employee AS e1
JOIN dbo.Employee AS e2
  ON YEAR(e1.JoiningDate)  = YEAR(e2.JoiningDate)
 AND MONTH(e1.JoiningDate) = MONTH(e2.JoiningDate)
 AND e1.EmployeeId < e2.EmployeeId;

-- Variant: same MONTH regardless of year
--   PARTITION BY MONTH(JoiningDate)
```

**Output:** *(0 rows)*. The sample year-months (2022-01, 2023-03, 2021-06, 2024-01, 2023-08) are all different. The **same-month-any-year** variant returns:

| EmployeeId | EmployeeName | JoiningDate |
|---|---|---|
| 101 | Amit | 2022-01-10 |
| 104 | Sneha | 2024-01-05 |

**7-yr insight:** `YEAR()`/`MONTH()` on the column are not sargable. If this is a hot query, add a persisted computed column such as `JoinMonth AS DATEFROMPARTS(YEAR(JoiningDate), MONTH(JoiningDate), 1)` and index it. `FORMAT()` is slow (it runs through CLR), so keep it for display only.

---

## B. Joins and Subqueries

### C16. Employee details with department names

**Concept / Definition:** An `INNER JOIN` returns only matching rows. A `LEFT JOIN` keeps every employee even when the department is missing.

**Real-world use:** An employee directory page shows each person with their department.

**Solution:**
```sql
SELECT e.EmployeeId,
       e.EmployeeName,
       ISNULL(d.DepartmentName, 'Unassigned') AS DepartmentName,
       e.Salary,
       e.JoiningDate
FROM dbo.Employee AS e
LEFT JOIN dbo.Department AS d          -- LEFT keeps employees with NULL/orphan DepartmentId
       ON d.DepartmentId = e.DepartmentId
ORDER BY e.EmployeeId;
```

**Output:**

| EmployeeId | EmployeeName | DepartmentName | Salary | JoiningDate |
|---|---|---|---|---|
| 101 | Amit | IT | 80000 | 2022-01-10 |
| 102 | Rahul | IT | 60000 | 2023-03-15 |
| 103 | Priya | HR | 90000 | 2021-06-20 |
| 104 | Sneha | HR | 70000 | 2024-01-05 |
| 105 | Raj | IT | 60000 | 2023-08-10 |

**7-yr insight:** Choose `LEFT JOIN` on purpose so unmapped employees do not silently disappear. Avoid `SELECT *` in production joins: it breaks covering indexes and changes shape when the schema changes. Putting a filter on the right-hand table in `WHERE` instead of `ON` quietly turns a LEFT JOIN into an INNER JOIN.

---

### C17. Employees with no attendance record

**Concept / Definition:** An anti-join returns employees with no matching row in `EmployeeAttendance`.

**Real-world use:** HR chases employees who have never marked attendance.

**Solution:**
```sql
-- Approach 1: NOT EXISTS (recommended)
SELECT e.EmployeeId, e.EmployeeName
FROM dbo.Employee AS e
WHERE NOT EXISTS (SELECT 1 FROM dbo.EmployeeAttendance AS a
                  WHERE a.EmployeeId = e.EmployeeId);

-- Approach 2: LEFT JOIN ... IS NULL
SELECT e.EmployeeId, e.EmployeeName
FROM dbo.Employee AS e
LEFT JOIN dbo.EmployeeAttendance AS a ON a.EmployeeId = e.EmployeeId
WHERE a.Id IS NULL;

-- Approach 3: EXCEPT (set-based; returns only the compared columns)
SELECT EmployeeId FROM dbo.Employee
EXCEPT
SELECT EmployeeId FROM dbo.EmployeeAttendance;
```

**Output:**

| EmployeeId | EmployeeName |
|---|---|
| 103 | Priya |
| 104 | Sneha |
| 105 | Raj |

**7-yr insight:** `NOT EXISTS` stops at the first match, so it does not multiply rows the way a LEFT JOIN against a large child table can. An index on `EmployeeAttendance(EmployeeId)` (or `(EmployeeId, AttendanceDate)`) is essential. Avoid `NOT IN` when the subquery column is nullable.

---

### C18. Employees who completed all mandatory trainings

**Concept / Definition:** **Relational division** answers "find X related to *all* Y". Two common methods are (1) matching counts with `HAVING COUNT = total` and (2) double `NOT EXISTS`, which reads as "there is no mandatory training the employee has not completed".

**Real-world use:** Compliance lists employees who are fully certified on all mandatory courses.

**Solution:**
```sql
DROP TABLE IF EXISTS dbo.EmployeeTraining, dbo.Training;
CREATE TABLE dbo.Training (
    TrainingId   INT PRIMARY KEY,
    TrainingName VARCHAR(50) NOT NULL,
    IsMandatory  BIT NOT NULL
);
CREATE TABLE dbo.EmployeeTraining (
    EmployeeId INT NOT NULL,
    TrainingId INT NOT NULL REFERENCES dbo.Training(TrainingId),
    Status     VARCHAR(20) NOT NULL,
    PRIMARY KEY (EmployeeId, TrainingId)
);
INSERT INTO dbo.Training VALUES
(1,'Security Awareness',1),(2,'POSH',1),(3,'Advanced SQL',0);
INSERT INTO dbo.EmployeeTraining VALUES
(101,1,'Completed'),(101,2,'Completed'),
(102,1,'Completed'),(102,3,'Completed'),
(103,1,'Completed'),(103,2,'Completed'),(103,3,'Completed'),
(104,1,'Completed'),(104,2,'InProgress');

-- Approach 1: COUNT matching (readable, fast)
SELECT e.EmployeeId, e.EmployeeName
FROM dbo.Employee AS e
JOIN dbo.EmployeeTraining AS et ON et.EmployeeId = e.EmployeeId
JOIN dbo.Training         AS t  ON t.TrainingId  = et.TrainingId
WHERE t.IsMandatory = 1
  AND et.Status = 'Completed'
GROUP BY e.EmployeeId, e.EmployeeName
HAVING COUNT(DISTINCT et.TrainingId) = (SELECT COUNT(*) FROM dbo.Training WHERE IsMandatory = 1);

-- Approach 2: Double NOT EXISTS ("no mandatory training is missing")
SELECT e.EmployeeId, e.EmployeeName
FROM dbo.Employee AS e
WHERE NOT EXISTS (
        SELECT 1
        FROM dbo.Training AS t
        WHERE t.IsMandatory = 1
          AND NOT EXISTS (SELECT 1
                          FROM dbo.EmployeeTraining AS et
                          WHERE et.EmployeeId = e.EmployeeId
                            AND et.TrainingId = t.TrainingId
                            AND et.Status = 'Completed'));
```

**Output:**

| EmployeeId | EmployeeName |
|---|---|
| 101 | Amit |
| 103 | Priya |

**7-yr insight:** The two methods differ when there are **zero** mandatory trainings. The COUNT version returns nobody, while double `NOT EXISTS` returns everybody (vacuous truth). State which behaviour the business wants. Use `COUNT(DISTINCT ...)` in case the table allows repeated completions.

---

### C19. Departments with more than five employees

**Concept / Definition:** `HAVING` filters groups after aggregation, while `WHERE` filters rows before it.

**Real-world use:** Leadership identifies large departments that need an extra manager.

**Solution:**
```sql
SELECT d.DepartmentId, d.DepartmentName, COUNT(e.EmployeeId) AS EmployeeCount
FROM dbo.Department AS d
JOIN dbo.Employee   AS e ON e.DepartmentId = d.DepartmentId
GROUP BY d.DepartmentId, d.DepartmentName
HAVING COUNT(e.EmployeeId) > 5
ORDER BY EmployeeCount DESC;
```

**Output:** *(0 rows)*. IT has 3 employees and HR has 2. With the threshold changed to `> 1`, the result is:

| DepartmentId | DepartmentName | EmployeeCount |
|---|---|---|
| 1 | IT | 3 |
| 2 | HR | 2 |

**7-yr insight:** `COUNT(e.EmployeeId)` instead of `COUNT(*)` matters if you switch to a LEFT JOIN, because empty departments then correctly count as 0, not 1. Make the threshold a parameter. Count only active employees if the table has soft deletes.

---

### C20. Salary above the department average

**Concept / Definition:** Compare each employee with an aggregate *of their own group*. You can use a correlated subquery, a window `AVG() OVER (PARTITION BY ...)`, or a join to a derived table.

**Real-world use:** Identify employees paid above their department norm.

**Solution:**
```sql
-- Approach 1: Window function (single scan – recommended)
WITH DeptAvg AS (
    SELECT e.EmployeeId, e.EmployeeName, e.DepartmentId, e.Salary,
           AVG(CAST(e.Salary AS DECIMAL(18,2))) OVER (PARTITION BY e.DepartmentId) AS DeptAvgSalary
    FROM dbo.Employee AS e
)
SELECT da.EmployeeName, d.DepartmentName, da.Salary,
       CAST(da.DeptAvgSalary AS DECIMAL(18,2)) AS DeptAvgSalary
FROM DeptAvg AS da
JOIN dbo.Department AS d ON d.DepartmentId = da.DepartmentId
WHERE da.Salary > da.DeptAvgSalary;

-- Approach 2: Correlated subquery
SELECT e.EmployeeName, e.Salary
FROM dbo.Employee AS e
WHERE e.Salary > (SELECT AVG(CAST(e2.Salary AS DECIMAL(18,2)))
                  FROM dbo.Employee AS e2
                  WHERE e2.DepartmentId = e.DepartmentId);

-- Approach 3: Join to aggregated derived table
SELECT e.EmployeeName, e.Salary, a.DeptAvg
FROM dbo.Employee AS e
JOIN (SELECT DepartmentId, AVG(CAST(Salary AS DECIMAL(18,2))) AS DeptAvg
      FROM dbo.Employee GROUP BY DepartmentId) AS a
  ON a.DepartmentId = e.DepartmentId
WHERE e.Salary > a.DeptAvg;
```

**Output:**

| EmployeeName | DepartmentName | Salary | DeptAvgSalary |
|---|---|---|---|
| Amit | IT | 80000 | 66666.67 |
| Priya | HR | 90000 | 80000.00 |

**7-yr insight:** Without the cast, IT's average becomes the integer 66666, which would make the comparison wrong for borderline values. The optimizer often rewrites the correlated subquery into a join, but the window version is the clearest. Index `(DepartmentId) INCLUDE (Salary)` helps.

---

### C21. Employees who have the same manager

**Concept / Definition:** Group by `ManagerId`, or self-join on `ManagerId`, to find peers who report to the same person.

**Real-world use:** Build a team roster for each manager to plan a team outing.

**Solution:**
```sql
-- Approach 1: Window COUNT + manager name via self-join
SELECT x.EmployeeId, x.EmployeeName, m.EmployeeName AS ManagerName
FROM (SELECT EmployeeId, EmployeeName, ManagerId,
             COUNT(*) OVER (PARTITION BY ManagerId) AS PeerCount
      FROM dbo.Employee
      WHERE ManagerId IS NOT NULL) AS x
JOIN dbo.Employee AS m ON m.EmployeeId = x.ManagerId
WHERE x.PeerCount > 1
ORDER BY ManagerName, x.EmployeeId;

-- Approach 2: Self-join pairs of peers
SELECT e1.EmployeeName AS Employee1, e2.EmployeeName AS Employee2, e1.ManagerId
FROM dbo.Employee AS e1
JOIN dbo.Employee AS e2
  ON e1.ManagerId = e2.ManagerId
 AND e1.EmployeeId < e2.EmployeeId;
```

**Output (Approach 1):**

| EmployeeId | EmployeeName | ManagerName |
|---|---|---|
| 102 | Rahul | Amit |
| 105 | Raj | Amit |

**7-yr insight:** Exclude `ManagerId IS NULL`. Otherwise the window function groups all top-level managers (Amit and Priya) together as "peers", which is a classic bug. In the self-join, NULL never equals NULL, so they are excluded automatically.

---

### C22. Employees who joined before their managers

**Concept / Definition:** Self-join employee to manager and compare their `JoiningDate` values.

**Real-world use:** Find staff who were promoted over, or whose manager was hired later from outside.

**Solution:**
```sql
SELECT e.EmployeeName,
       e.JoiningDate AS EmployeeJoined,
       m.EmployeeName AS ManagerName,
       m.JoiningDate AS ManagerJoined
FROM dbo.Employee AS e
JOIN dbo.Employee AS m ON m.EmployeeId = e.ManagerId
WHERE e.JoiningDate < m.JoiningDate;
```

**Output:** *(0 rows)*. Rahul (2023-03-15) and Raj (2023-08-10) joined after Amit (2022-01-10), and Sneha (2024-01-05) joined after Priya (2021-06-20).

| EmployeeName | EmployeeJoined | ManagerName | ManagerJoined |
|---|---|---|---|

**7-yr insight:** This is the same self-join shape as C9 with a different predicate. A strong candidate notices the pattern and mentions that the `ManagerId` index serves both. In a real HR system you would compare with the manager's *role start date* from a history table, not their company joining date.

---

### C23. Highest-paid employee per department using a subquery

**Concept / Definition:** Use a correlated subquery that finds the department's `MAX(Salary)`, or join to a grouped derived table.

**Real-world use:** Show the top earner of each department on the HR dashboard.

**Solution:**
```sql
-- Approach 1: Correlated subquery
SELECT d.DepartmentName, e.EmployeeName, e.Salary
FROM dbo.Employee AS e
JOIN dbo.Department AS d ON d.DepartmentId = e.DepartmentId
WHERE e.Salary = (SELECT MAX(e2.Salary)
                  FROM dbo.Employee AS e2
                  WHERE e2.DepartmentId = e.DepartmentId);

-- Approach 2: Join to derived table of maxima
SELECT d.DepartmentName, e.EmployeeName, e.Salary
FROM dbo.Employee AS e
JOIN (SELECT DepartmentId, MAX(Salary) AS MaxSalary
      FROM dbo.Employee GROUP BY DepartmentId) AS mx
  ON mx.DepartmentId = e.DepartmentId AND mx.MaxSalary = e.Salary
JOIN dbo.Department AS d ON d.DepartmentId = e.DepartmentId;
```

**Output:**

| DepartmentName | EmployeeName | Salary |
|---|---|---|
| IT | Amit | 80000 |
| HR | Priya | 90000 |

**7-yr insight:** Both approaches return **all tied** top earners, which is usually what the business wants. The common wrong answer is `SELECT DepartmentId, EmployeeName, MAX(Salary) ... GROUP BY DepartmentId`, which fails to compile in SQL Server (and gives arbitrary names in MySQL). Index `(DepartmentId, Salary DESC)`.

---

### C24. Highest-paid employee per department using a CTE

**Concept / Definition:** A CTE (Common Table Expression) names an intermediate result so the query reads top-down. Here it holds a ranked list.

**Real-world use:** The same dashboard query as C23, written so the next developer can maintain it easily.

**Solution:**
```sql
-- Approach 1: CTE + RANK (keeps ties)
WITH RankedSalary AS (
    SELECT e.EmployeeId, e.EmployeeName, e.DepartmentId, e.Salary,
           RANK() OVER (PARTITION BY e.DepartmentId ORDER BY e.Salary DESC) AS rnk
    FROM dbo.Employee AS e
)
SELECT d.DepartmentName, r.EmployeeName, r.Salary
FROM RankedSalary AS r
JOIN dbo.Department AS d ON d.DepartmentId = r.DepartmentId
WHERE r.rnk = 1;

-- Approach 2: CTE with aggregate, then join
WITH DeptMax AS (
    SELECT DepartmentId, MAX(Salary) AS MaxSalary
    FROM dbo.Employee
    GROUP BY DepartmentId
)
SELECT d.DepartmentName, e.EmployeeName, e.Salary
FROM DeptMax AS dm
JOIN dbo.Employee   AS e ON e.DepartmentId = dm.DepartmentId AND e.Salary = dm.MaxSalary
JOIN dbo.Department AS d ON d.DepartmentId = dm.DepartmentId;
```

**Output:**

| DepartmentName | EmployeeName | Salary |
|---|---|---|
| IT | Amit | 80000 |
| HR | Priya | 90000 |

**7-yr insight:** A CTE is **not materialized** in SQL Server. It is inlined like a view, so referencing it twice runs it twice. Use a `#temp` table when you need to reuse an expensive result. Use `RANK`/`DENSE_RANK` to keep ties, or `ROW_NUMBER` with a tiebreaker to get exactly one row per department.

---

### C25. Records in Table A but missing in Table B

**Concept / Definition:** Set difference: `NOT EXISTS`, `LEFT JOIN ... IS NULL`, or `EXCEPT`. Here, Table A = `Employee` and Table B = `EmployeeSalaryHistory`.

**Real-world use:** Find employees with no salary-revision history, for example because the migration missed them.

**Solution:**
```sql
-- Approach 1: NOT EXISTS (NULL-safe, returns any columns)
SELECT e.EmployeeId, e.EmployeeName
FROM dbo.Employee AS e
WHERE NOT EXISTS (SELECT 1 FROM dbo.EmployeeSalaryHistory AS h
                  WHERE h.EmployeeId = e.EmployeeId);

-- Approach 2: LEFT JOIN anti-join
SELECT e.EmployeeId, e.EmployeeName
FROM dbo.Employee AS e
LEFT JOIN dbo.EmployeeSalaryHistory AS h ON h.EmployeeId = e.EmployeeId
WHERE h.Id IS NULL;

-- Approach 3: EXCEPT (distinct; compares ALL selected columns; treats NULL = NULL)
SELECT EmployeeId FROM dbo.Employee
EXCEPT
SELECT EmployeeId FROM dbo.EmployeeSalaryHistory;

-- Trap: NOT IN returns nothing if the subquery yields a NULL
-- WHERE e.EmployeeId NOT IN (SELECT EmployeeId FROM dbo.EmployeeSalaryHistory)
```

**Output:**

| EmployeeId | EmployeeName |
|---|---|
| 103 | Priya |
| 104 | Sneha |
| 105 | Raj |

**7-yr insight:** `EXCEPT` is very convenient for **full-row comparison** (data reconciliation between environments) because it treats NULLs as equal. It also removes duplicates. For a key-based check that returns extra columns, `NOT EXISTS` is the senior choice.

---

### C26. Common records between two tables

**Concept / Definition:** Set intersection: `INTERSECT`, `EXISTS`, or `INNER JOIN` (with `DISTINCT` when the child table has many rows per key).

**Real-world use:** Find employees who exist in the master table *and* have attendance data.

**Solution:**
```sql
-- Approach 1: INTERSECT (distinct result, NULL-safe comparison)
SELECT EmployeeId FROM dbo.Employee
INTERSECT
SELECT EmployeeId FROM dbo.EmployeeAttendance;

-- Approach 2: EXISTS (no duplicates, returns any column from Employee)
SELECT e.EmployeeId, e.EmployeeName
FROM dbo.Employee AS e
WHERE EXISTS (SELECT 1 FROM dbo.EmployeeAttendance AS a
              WHERE a.EmployeeId = e.EmployeeId);

-- Approach 3: INNER JOIN – needs DISTINCT because attendance has many rows/employee
SELECT DISTINCT e.EmployeeId, e.EmployeeName
FROM dbo.Employee AS e
JOIN dbo.EmployeeAttendance AS a ON a.EmployeeId = e.EmployeeId;
```

**Output:**

| EmployeeId | EmployeeName |
|---|---|
| 101 | Amit |
| 102 | Rahul |

**7-yr insight:** A join plus `DISTINCT` is a code smell, because it means you used a join where a **semi-join** (`EXISTS`) was intended. Without `DISTINCT`, the join would return Amit 3 times and Rahul 2 times. `EXISTS` avoids building and then removing duplicates.

---

### C27. Employees with at least one completed project using EXISTS

**Concept / Definition:** `EXISTS` is a semi-join. It returns the outer row as soon as one matching inner row is found.

**Real-world use:** Appraisal: shortlist employees who delivered at least one completed project.

**Solution:**
```sql
DROP TABLE IF EXISTS dbo.EmployeeProject, dbo.Project;
CREATE TABLE dbo.Project (
    ProjectId   INT PRIMARY KEY,
    ProjectName VARCHAR(50) NOT NULL,
    Status      VARCHAR(20) NOT NULL    -- 'Completed' / 'InProgress'
);
CREATE TABLE dbo.EmployeeProject (
    EmployeeId INT NOT NULL,
    ProjectId  INT NOT NULL REFERENCES dbo.Project(ProjectId),
    PRIMARY KEY (EmployeeId, ProjectId)
);
INSERT INTO dbo.Project VALUES
(1,'Payroll Revamp','Completed'),(2,'HR Portal','Completed'),(3,'Audit Automation','InProgress');
INSERT INTO dbo.EmployeeProject VALUES
(101,1),(102,1),(102,3),(103,2),(104,3),(105,3);

-- EXISTS (recommended)
SELECT e.EmployeeId, e.EmployeeName
FROM dbo.Employee AS e
WHERE EXISTS (SELECT 1
              FROM dbo.EmployeeProject AS ep
              JOIN dbo.Project         AS p ON p.ProjectId = ep.ProjectId
              WHERE ep.EmployeeId = e.EmployeeId
                AND p.Status = 'Completed');

-- Alternative: IN
SELECT e.EmployeeId, e.EmployeeName
FROM dbo.Employee AS e
WHERE e.EmployeeId IN (SELECT ep.EmployeeId
                       FROM dbo.EmployeeProject AS ep
                       JOIN dbo.Project AS p ON p.ProjectId = ep.ProjectId
                       WHERE p.Status = 'Completed');
```

**Output:**

| EmployeeId | EmployeeName |
|---|---|
| 101 | Amit |
| 102 | Rahul |
| 103 | Priya |

**7-yr insight:** `SELECT 1`, `SELECT *` and `SELECT NULL` inside `EXISTS` perform the same, because the select list is ignored. `IN` and `EXISTS` usually produce the same semi-join plan. The real difference is `NOT IN` versus `NOT EXISTS` with NULLs. Index `EmployeeProject(EmployeeId, ProjectId)`, plus a filtered index on `Project(Status)` if completed projects are a small subset.

---

## C. Window Function Coding

### C28. Write a query using ROW_NUMBER() to generate a unique sequence for each employee.

**Concept / Definition:** `ROW_NUMBER()` is an analytical window function that generates a contiguous, non-repeating integer starting from 1 for each row in a partition or across the entire query result set based on a specified ordering.

**Real-world use:** Generating unique row numbers for a paginated employee grid in an HR portal or creating serial numbers on payroll reports.

**Solution:**
```sql
SELECT 
    ROW_NUMBER() OVER (ORDER BY JoiningDate ASC, EmployeeId ASC) AS SequenceNo,
    EmployeeId,
    EmployeeName,
    DepartmentId,
    Salary,
    JoiningDate
FROM dbo.Employee;
```

**Output:**

| SequenceNo | EmployeeId | EmployeeName | DepartmentId | Salary | JoiningDate |
|---|---|---|---|---|---|
| 1 | 103 | Priya | 2 | 90000.00 | 2021-06-20 |
| 2 | 101 | Amit | 1 | 80000.00 | 2022-01-10 |
| 3 | 102 | Rahul | 1 | 60000.00 | 2023-03-15 |
| 4 | 105 | Raj | 1 | 60000.00 | 2023-08-10 |
| 5 | 104 | Sneha | 2 | 70000.00 | 2024-01-05 |

**7-yr insight:** Always ensure the `ORDER BY` clause contains a unique tie-breaker (like `EmployeeId`). If ordering only by non-unique columns like `Salary` or `JoiningDate`, the sequence numbers for identical values are non-deterministic, meaning SQL Server could swap rows between two runs. If an index exists on `(JoiningDate, EmployeeId)`, SQL Server avoids an explicit Sort operator in the execution plan and streams row numbers directly from the index.

---

### C29. Find the top two salaries in each department using DENSE_RANK().

**Concept / Definition:** `DENSE_RANK()` assigns rank tiers based on ordered values without skipping numbers when ties occur, making it ideal for retrieving top distinct salary brackets within groups.

**Real-world use:** HR wants to identify the top 2 salary grades in each department for executive compensation reviews, ensuring all employees at those top pay grades are included even if they share the same salary.

**Solution:**
```sql
WITH RankedSalaries AS
(
    SELECT 
        e.EmployeeId,
        e.EmployeeName,
        d.DepartmentName,
        e.Salary,
        DENSE_RANK() OVER (
            PARTITION BY e.DepartmentId 
            ORDER BY e.Salary DESC
        ) AS SalaryRank
    FROM dbo.Employee e
    JOIN dbo.Department d ON e.DepartmentId = d.DepartmentId
)
SELECT 
    EmployeeId,
    EmployeeName,
    DepartmentName,
    Salary,
    SalaryRank
FROM RankedSalaries
WHERE SalaryRank <= 2
ORDER BY DepartmentName, SalaryRank, EmployeeName;
```

**Output:**

| EmployeeId | EmployeeName | DepartmentName | Salary | SalaryRank |
|---|---|---|---|---|
| 103 | Priya | HR | 90000.00 | 1 |
| 104 | Sneha | HR | 70000.00 | 2 |
| 101 | Amit | IT | 80000.00 | 1 |
| 102 | Rahul | IT | 60000.00 | 2 |
| 105 | Raj | IT | 60000.00 | 2 |

**7-yr insight:** Notice in Department 1 (IT), Rahul and Raj both earn 60,000 and share `SalaryRank = 2`. Because `DENSE_RANK()` was used, both employees are correctly returned. Had we used `ROW_NUMBER()`, one would be arbitrarily discarded. Had we used `RANK()`, both would get rank 2, but if three people tied for rank 1, rank 2 would be skipped entirely. For performance on large tables, an index on `dbo.Employee(DepartmentId, Salary DESC) INCLUDE (EmployeeName)` completely eliminates the sort operator.

---

### C30. Find the top three salaries in each department using RANK().

**Concept / Definition:** `RANK()` assigns identical ranks to tied rows, but skips subsequent rank numbers by the count of tied rows, mimicking Olympic podium medal rules.

**Real-world use:** Determining eligibility for department performance bonuses where a fixed quota of 3 podium spots is available, and ties consume subsequent rank spots.

**Solution:**
```sql
WITH RankedSalaries AS
(
    SELECT 
        e.EmployeeId,
        e.EmployeeName,
        d.DepartmentName,
        e.Salary,
        RANK() OVER (
            PARTITION BY e.DepartmentId 
            ORDER BY e.Salary DESC
        ) AS Rnk
    FROM dbo.Employee e
    JOIN dbo.Department d ON e.DepartmentId = d.DepartmentId
)
SELECT 
    EmployeeId,
    EmployeeName,
    DepartmentName,
    Salary,
    Rnk
FROM RankedSalaries
WHERE Rnk <= 3
ORDER BY DepartmentName, Rnk, EmployeeName;
```

**Output:**

| EmployeeId | EmployeeName | DepartmentName | Salary | Rnk |
|---|---|---|---|---|
| 103 | Priya | HR | 90000.00 | 1 |
| 104 | Sneha | HR | 70000.00 | 2 |
| 101 | Amit | IT | 80000.00 | 1 |
| 102 | Rahul | IT | 60000.00 | 2 |
| 105 | Raj | IT | 60000.00 | 2 |

**7-yr insight:** In this data, IT has Amit (Rank 1), then Rahul and Raj tie at Rank 2. If IT had a fourth employee earning 50,000, their rank would be 4 (not 3), so they would be excluded by `WHERE Rnk <= 3`. Be prepared to explain this skipping behavior to interviewers: `RANK()` reflects the exact count of employees earning more than the current row plus one.

---

### C31. Find duplicate records using ROW_NUMBER().

**Concept / Definition:** Partitioning by the natural business key and ordering by a timestamp/ID allows `ROW_NUMBER()` to assign sequential numbers to duplicate occurrences, where `RowNum > 1` identifies duplicates.

**Real-world use:** Identifying duplicate biometric attendance swipes or duplicate employee registrations caused by API retries.

**Solution:**
```sql
-- Using EmployeeSalaryHistory to find duplicate salary entries for an employee on the same date
WITH DuplicateRecords AS
(
    SELECT 
        Id,
        EmployeeId,
        Salary,
        EffectiveDate,
        ROW_NUMBER() OVER (
            PARTITION BY EmployeeId, EffectiveDate 
            ORDER BY Id DESC
        ) AS RowNum
    FROM dbo.EmployeeSalaryHistory
)
SELECT 
    Id,
    EmployeeId,
    Salary,
    EffectiveDate,
    RowNum
FROM DuplicateRecords
WHERE RowNum > 1;
```

**7-yr insight:** This is the standard senior SQL pattern for both finding and deleting duplicates. To delete duplicates in production, you can directly execute `DELETE FROM DuplicateRecords WHERE RowNum > 1;` inside the CTE. Wrapping the operation in a transaction and checking `@@ROWCOUNT` ensures safety. Always add a unique index on the partitioned columns afterward to enforce data integrity at the schema level.

---

### C32. Find the previous month's salary using LAG().

**Concept / Definition:** `LAG(column, offset, default)` is an analytical window function that accesses data from a previous row at a specified physical offset within the same partition without requiring a self-join.

**Real-world use:** Calculating month-over-month salary growth or detecting compensation adjustments over an employee's tenure.

**Solution:**
```sql
SELECT 
    Id,
    EmployeeId,
    EffectiveDate,
    Salary AS CurrentSalary,
    LAG(Salary, 1, NULL) OVER (
        PARTITION BY EmployeeId 
        ORDER BY EffectiveDate ASC
    ) AS PreviousSalary,
    Salary - LAG(Salary, 1, Salary) OVER (
        PARTITION BY EmployeeId 
        ORDER BY EffectiveDate ASC
    ) AS SalaryDifference
FROM dbo.EmployeeSalaryHistory
WHERE EmployeeId = 101
ORDER BY EffectiveDate ASC;
```

**Output:**

| Id | EmployeeId | EffectiveDate | CurrentSalary | PreviousSalary | SalaryDifference |
|---|---|---|---|---|---|
| 1 | 101 | 2022-01-10 | 50000.00 | NULL | 0.00 |
| 2 | 101 | 2023-01-10 | 60000.00 | 50000.00 | 10000.00 |
| 3 | 101 | 2024-01-10 | 80000.00 | 60000.00 | 20000.00 |

**7-yr insight:** Before SQL Server 2012, this required an expensive self-join on `RowNum = RowNum - 1`. `LAG()` is processed entirely in memory via the Window Spool operator in a single scan of the data. Always provide the third argument (default value) to avoid unwanted `NULL` results when doing arithmetic operations.

---

### C33. Find the next month's salary using LEAD().

**Concept / Definition:** `LEAD(column, offset, default)` accesses data from a subsequent row within the same partition at a given forward offset without an outer join.

**Real-world use:** Projecting upcoming compensation changes or auditing future-scheduled salary revisions.

**Solution:**
```sql
SELECT 
    Id,
    EmployeeId,
    EffectiveDate,
    Salary AS CurrentSalary,
    LEAD(Salary, 1, NULL) OVER (
        PARTITION BY EmployeeId 
        ORDER BY EffectiveDate ASC
    ) AS NextSalary
FROM dbo.EmployeeSalaryHistory
WHERE EmployeeId = 101
ORDER BY EffectiveDate ASC;
```

**Output:**

| Id | EmployeeId | EffectiveDate | CurrentSalary | NextSalary |
|---|---|---|---|---|
| 1 | 101 | 2022-01-10 | 50000.00 | 60000.00 |
| 2 | 101 | 2023-01-10 | 60000.00 | 80000.00 |
| 3 | 101 | 2024-01-10 | 80000.00 | NULL |

**7-yr insight:** Notice that for the most recent record (2024-01-10), `LEAD()` evaluates past the partition boundary and returns `NULL`. In production pipelines, combining `LAG` and `LEAD` in the same query requires only a single Sort operator, as SQL Server reuses the same window buffer for both evaluations.

---

### C34. Calculate the running total of employee salaries.

**Concept / Definition:** An aggregate window function (`SUM()`) evaluated over an ordered partition using the `ROWS` framing clause computes a cumulative running total.

**Real-world use:** Cumulative payroll burn-rate analysis showing total salary expenditure as employees join the company chronologically.

**Solution:**
```sql
SELECT 
    EmployeeId,
    EmployeeName,
    JoiningDate,
    Salary,
    SUM(Salary) OVER (
        ORDER BY JoiningDate ASC, EmployeeId ASC
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS RunningTotalSalary
FROM dbo.Employee
ORDER BY JoiningDate ASC, EmployeeId ASC;
```

**Output:**

| EmployeeId | EmployeeName | JoiningDate | Salary | RunningTotalSalary |
|---|---|---|---|---|
| 103 | Priya | 2021-06-20 | 90000.00 | 90000.00 |
| 101 | Amit | 2022-01-10 | 80000.00 | 170000.00 |
| 102 | Rahul | 2023-03-15 | 60000.00 | 230000.00 |
| 105 | Raj | 2023-08-10 | 60000.00 | 290000.00 |
| 104 | Sneha | 2024-01-05 | 70000.00 | 360000.00 |

**7-yr insight:** Always explicitly specify `ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW`. If you omit the frame and simply write `SUM(Salary) OVER (ORDER BY JoiningDate)`, SQL Server defaults to `RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW`. Under the hood, `RANGE` uses an on-disk TempDB Worktable spool to group duplicate dates together, which performs 10x slower on large tables than the in-memory stream processing of `ROWS`.

---

### C35. Calculate cumulative monthly sales.

**Concept / Definition:** Aggregating monthly sales figures using a running `SUM()` window function ordered by year and month.

**Real-world use:** Financial CFO revenue tracking: monitoring cumulative year-to-date (YTD) company revenue across calendar months.

**Solution:**
```sql
-- Define sample MonthlySales table
IF OBJECT_ID('tempdb..#MonthlySales') IS NOT NULL DROP TABLE #MonthlySales;
CREATE TABLE #MonthlySales
(
    SalesMonth DATE NOT NULL PRIMARY KEY,
    TotalSales DECIMAL(12,2) NOT NULL
);

INSERT INTO #MonthlySales VALUES
('2026-01-01', 150000.00),
('2026-02-01', 180000.00),
('2026-03-01', 220000.00),
('2026-04-01', 190000.00);

-- Query cumulative sales
SELECT 
    SalesMonth,
    TotalSales,
    SUM(TotalSales) OVER (
        ORDER BY SalesMonth ASC
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS CumulativeSalesYTD
FROM #MonthlySales
ORDER BY SalesMonth ASC;
```

**Output:**

| SalesMonth | TotalSales | CumulativeSalesYTD |
|---|---|---|
| 2026-01-01 | 150000.00 | 150000.00 |
| 2026-02-01 | 180000.00 | 330000.00 |
| 2026-03-01 | 220000.00 | 550000.00 |
| 2026-04-01 | 190000.00 | 740000.00 |

**7-yr insight:** To compute running totals that reset at the beginning of each calendar year (Year-To-Date), add `PARTITION BY YEAR(SalesMonth)` to the `OVER()` clause: `SUM(TotalSales) OVER (PARTITION BY YEAR(SalesMonth) ORDER BY SalesMonth ROWS UNBOUNDED PRECEDING)`.

---

### C36. Find the first and last transaction for each employee.

**Concept / Definition:** Using `FIRST_VALUE()` and `LAST_VALUE()` (with proper framing) or `ROW_NUMBER()` ascending and descending to identify boundary transactions.

**Real-world use:** In an expense claim or salary payment system, auditing each employee's initial joining salary and their most recent salary.

**Solution:**
```sql
-- Solution using FIRST_VALUE and LAST_VALUE with explicit framing
SELECT DISTINCT
    EmployeeId,
    FIRST_VALUE(Salary) OVER (
        PARTITION BY EmployeeId 
        ORDER BY EffectiveDate ASC
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS FirstSalary,
    FIRST_VALUE(EffectiveDate) OVER (
        PARTITION BY EmployeeId 
        ORDER BY EffectiveDate ASC
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS FirstDate,
    LAST_VALUE(Salary) OVER (
        PARTITION BY EmployeeId 
        ORDER BY EffectiveDate ASC
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS LatestSalary,
    LAST_VALUE(EffectiveDate) OVER (
        PARTITION BY EmployeeId 
        ORDER BY EffectiveDate ASC
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS LatestDate
FROM dbo.EmployeeSalaryHistory;
```

**Output:**

| EmployeeId | FirstSalary | FirstDate | LatestSalary | LatestDate |
|---|---|---|---|---|
| 101 | 50000.00 | 2022-01-10 | 80000.00 | 2024-01-10 |
| 102 | 40000.00 | 2023-03-15 | 60000.00 | 2024-03-15 |

**7-yr insight:** When using `LAST_VALUE()`, the default frame is `RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW`, which causes `LAST_VALUE()` to return the *current row's* value instead of the true last row! You must explicitly append `ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING` to expand the window to the entire partition.

---

### C37. Find employees whose salary is higher than the previous month's salary.

**Concept / Definition:** Comparing the current row's salary with the preceding row's salary using `LAG()` inside a CTE or subquery.

**Real-world use:** HR audit report identifying employees who received pay raises in their latest compensation revision.

**Solution:**
```sql
WITH SalaryComparison AS
(
    SELECT 
        esh.EmployeeId,
        e.EmployeeName,
        esh.EffectiveDate,
        esh.Salary AS CurrentSalary,
        LAG(esh.Salary) OVER (
            PARTITION BY esh.EmployeeId 
            ORDER BY esh.EffectiveDate ASC
        ) AS PreviousSalary
    FROM dbo.EmployeeSalaryHistory esh
    JOIN dbo.Employee e ON esh.EmployeeId = e.EmployeeId
)
SELECT 
    EmployeeId,
    EmployeeName,
    EffectiveDate,
    CurrentSalary,
    PreviousSalary,
    (CurrentSalary - PreviousSalary) AS IncrementAmount
FROM SalaryComparison
WHERE CurrentSalary > PreviousSalary
ORDER BY EmployeeId, EffectiveDate;
```

**Output:**

| EmployeeId | EmployeeName | EffectiveDate | CurrentSalary | PreviousSalary | IncrementAmount |
|---|---|---|---|---|---|
| 101 | Amit | 2023-01-10 | 60000.00 | 50000.00 | 10000.00 |
| 101 | Amit | 2024-01-10 | 80000.00 | 60000.00 | 20000.00 |
| 102 | Rahul | 2024-03-15 | 60000.00 | 40000.00 | 20000.00 |

**7-yr insight:** Window functions cannot appear directly inside a `WHERE` clause because the `WHERE` clause is processed in logical query processing step 2, while window functions are evaluated in step 5 (`SELECT`). Wrapping the window function inside a CTE or derived table is mandatory.

---

### C38. Find the top 10% of employees based on salary using NTILE().

**Concept / Definition:** `NTILE(10)` divides ordered rows into 10 decile buckets; bucket 1 represents the top 10% bracket.

**Real-world use:** Identifying the top 10% executive compensation earners for board governance compliance and tax reporting.

**Solution:**
```sql
-- Method 1: Using NTILE(10)
WITH SalaryDeciles AS
(
    SELECT 
        EmployeeId,
        EmployeeName,
        Salary,
        NTILE(10) OVER (ORDER BY Salary DESC) AS DecileBucket
    FROM dbo.Employee
)
SELECT EmployeeId, EmployeeName, Salary
FROM SalaryDeciles
WHERE DecileBucket = 1;

-- Method 2: Using TOP (10) PERCENT WITH TIES (Guarantees handling ties)
SELECT TOP (10) PERCENT WITH TIES
    EmployeeId,
    EmployeeName,
    Salary
FROM dbo.Employee
ORDER BY Salary DESC;
```

**Output:**

| EmployeeId | EmployeeName | Salary |
|---|---|---|
| 103 | Priya | 90000.00 |

**7-yr insight:** Be prepared to explain the difference: `NTILE(10)` strictly enforces bucket counts. If you have 5 rows, `NTILE(10)` puts row 1 in bucket 1 and rows 2-5 in subsequent buckets. If multiple employees tie for the top salary, `NTILE` may arbitrarily split tied employees into different buckets. In production, `TOP (10) PERCENT WITH TIES` is preferred when ties must be preserved.

---

### C39. Calculate the percentage contribution of each department to total salary expenditure.

**Concept / Definition:** Combining `SUM(Salary)` grouped by department with an unrestricted window aggregate `SUM(SUM(Salary)) OVER ()` to compute percentage of total in a single pass.

**Real-world use:** Financial budget breakdown: what percentage of overall company payroll is consumed by IT vs HR vs Finance?

**Solution:**
```sql
SELECT 
    d.DepartmentId,
    d.DepartmentName,
    SUM(e.Salary) AS DepartmentTotalSalary,
    SUM(SUM(e.Salary)) OVER () AS CompanyTotalSalary,
    CAST(
        (SUM(e.Salary) * 100.0) / SUM(SUM(e.Salary)) OVER () 
        AS DECIMAL(5,2)
    ) AS ContributionPercentage
FROM dbo.Department d
JOIN dbo.Employee e ON d.DepartmentId = e.DepartmentId
GROUP BY d.DepartmentId, d.DepartmentName
ORDER BY ContributionPercentage DESC;
```

**Output:**

| DepartmentId | DepartmentName | DepartmentTotalSalary | CompanyTotalSalary | ContributionPercentage |
|---|---|---|---|---|
| 1 | IT | 200000.00 | 360000.00 | 55.56 |
| 2 | HR | 160000.00 | 360000.00 | 44.44 |

**7-yr insight:** `SUM(SUM(e.Salary)) OVER ()` is a window aggregate over a grouped aggregate. It computes the grand total across all department rows without requiring a second query or a subquery join to the table. Multiplying by `100.0` (with a decimal) forces floating-point decimal division and prevents integer truncation in SQL Server.

---

### C40. Find consecutive login dates for employees (gaps-and-islands).

**Concept / Definition:** The classic **Gaps and Islands** problem: subtracting a sequential `ROW_NUMBER()` from the actual date produces a constant grouping date (`IslandGroup`) for any contiguous sequence of consecutive dates.

**Real-world use:** Detecting employee attendance streaks, consecutive daily logins, or identifying employees who logged in 3 or more days in a row.

**Solution:**
```sql
-- Step 1: Define sample login dates (including consecutive streaks and gaps)
IF OBJECT_ID('tempdb..#EmployeeLogins') IS NOT NULL DROP TABLE #EmployeeLogins;
CREATE TABLE #EmployeeLogins
(
    EmployeeId INT NOT NULL,
    LoginDate  DATE NOT NULL,
    PRIMARY KEY (EmployeeId, LoginDate)
);

INSERT INTO #EmployeeLogins VALUES
(101, '2026-10-01'),
(101, '2026-10-02'),
(101, '2026-10-03'), -- Streak 1: 3 days (Oct 1 to Oct 3)
(101, '2026-10-06'), -- Gap on Oct 4, 5
(101, '2026-10-07'), -- Streak 2: 2 days (Oct 6 to Oct 7)
(102, '2026-10-01'),
(102, '2026-10-02'); -- Streak 1: 2 days

-- Step 2: Solve Islands using DATEADD and ROW_NUMBER()
WITH LoginStreaks AS
(
    SELECT 
        EmployeeId,
        LoginDate,
        -- The magic formula: LoginDate minus row number generates an identical anchor date for consecutive days
        DATEADD(DAY, -ROW_NUMBER() OVER (PARTITION BY EmployeeId ORDER BY LoginDate), LoginDate) AS IslandGroup
    FROM #EmployeeLogins
)
SELECT 
    EmployeeId,
    MIN(LoginDate) AS StreakStartDate,
    MAX(LoginDate) AS StreakEndDate,
    COUNT(*)       AS ConsecutiveDaysCount
FROM LoginStreaks
GROUP BY EmployeeId, IslandGroup
ORDER BY EmployeeId, StreakStartDate;
```

**Output:**

| EmployeeId | StreakStartDate | StreakEndDate | ConsecutiveDaysCount |
|---|---|---|---|
| 101 | 2026-10-01 | 2026-10-03 | 3 |
| 101 | 2026-10-06 | 2026-10-07 | 2 |
| 102 | 2026-10-01 | 2026-10-02 | 2 |

**7-yr insight:** The 'Gaps and Islands' problem is a hallmark senior interview question. The mathematical principle is brilliant: if dates are strictly consecutive (Day 1, Day 2, Day 3) and `ROW_NUMBER()` is strictly consecutive (1, 2, 3), their difference (`Date - RowNum`) remains constant. The moment a gap occurs (e.g. jumping from Oct 3 to Oct 6), the difference shifts, cleanly creating a new `IslandGroup`. Once grouped by `IslandGroup`, a simple `MIN(LoginDate)`, `MAX(LoginDate)`, and `COUNT(*)` gives streak boundaries and lengths in a single, high-speed set-based pass without procedural cursors.
