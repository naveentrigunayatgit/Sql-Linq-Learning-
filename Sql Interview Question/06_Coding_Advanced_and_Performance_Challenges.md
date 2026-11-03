# Section 3 (D): Advanced Coding & Real-Time Scenarios + Section 4: Performance Challenges

> Target audience: .NET Core / Dapper developer with ~7 years of experience preparing for SQL Server interviews.
> All expected outputs are computed from the shared sample data below. Where a question needs extra tables, they are created inside that question.

## Table of Contents

**Section 3 (D): Advanced Coding & Real-Time Scenarios**

- [Sample Data Used in This Section](#sample-data-used-in-this-section)
- [C41. Insert Employee with Transaction and Error Handling](#c41-insert-employee-with-transaction-and-error-handling)
- [C42. Accept Multiple EmployeeIds Using a Table-Valued Parameter](#c42-accept-multiple-employeeids-using-a-table-valued-parameter)
- [C43. Pagination Using OFFSET FETCH and Keyset Pagination](#c43-pagination-using-offset-fetch-and-keyset-pagination)
- [C44. Latest Record for Each EmployeeId](#c44-latest-record-for-each-employeeid)
- [C45. Second Latest Record for Each EmployeeId](#c45-second-latest-record-for-each-employeeid)
- [C46. Convert Rows into Columns Using PIVOT](#c46-convert-rows-into-columns-using-pivot)
- [C47. Convert Columns into Rows Using UNPIVOT](#c47-convert-columns-into-rows-using-unpivot)
- [C48. Dynamic Search with Optional Parameters](#c48-dynamic-search-with-optional-parameters)
- [C49. Find Missing Identity Values](#c49-find-missing-identity-values)
- [C50. Employees Not Logged In for the Last 90 Days](#c50-employees-not-logged-in-for-the-last-90-days)
- [C51. Monthly Attendance Percentage](#c51-monthly-attendance-percentage)
- [C52. Three Consecutive Absent Days](#c52-three-consecutive-absent-days)
- [C53. Department-wise Salary Report with Totals](#c53-department-wise-salary-report-with-totals)
- [C54. Delete Records in Batches of 10000](#c54-delete-records-in-batches-of-10000)
- [C55. Update One Table Using Another Table](#c55-update-one-table-using-another-table)
- [C56. Overlapping Date Ranges](#c56-overlapping-date-ranges)
- [C57. Longest Consecutive Attendance Streak](#c57-longest-consecutive-attendance-streak)
- [C58. Salary History Using an Audit Table](#c58-salary-history-using-an-audit-table)
- [C59. Salary Increased Three Consecutive Months](#c59-salary-increased-three-consecutive-months)
- [C60. Month-over-Month Sales Percentage Difference](#c60-month-over-month-sales-percentage-difference)

**Section 4: SQL Server Practical Performance Challenges**

- [P1. Query Returning 100 Million Records](#p1-query-returning-100-million-records)
- [P2. Stored Procedure Running Slowly](#p2-stored-procedure-running-slowly)
- [P3. Deadlock in Production](#p3-deadlock-in-production)
- [P4. Duplicate Records](#p4-duplicate-records)
- [P5. Large Data Deletion](#p5-large-data-deletion)
- [P6. Parameter Sniffing](#p6-parameter-sniffing)
- [P7. Slow JOIN Operations](#p7-slow-join-operations)
- [P8. High Database CPU](#p8-high-database-cpu)
- [P9. High TempDB Usage](#p9-high-tempdb-usage)
- [P10. Blocking Queries](#p10-blocking-queries)
- [Final Interview Tips for 7 Years Experience](#final-interview-tips-for-7-years-experience)

---

## Sample Data Used in This Section

```sql
-- Assumption: EmployeeId and EmployeeSalaryHistory.Id are IDENTITY columns
-- (seeded so the sample rows keep their ids). Salary columns are DECIMAL(12,2).
CREATE TABLE dbo.Department
(
    DepartmentId   INT           NOT NULL PRIMARY KEY,
    DepartmentName NVARCHAR(50)  NOT NULL
);

CREATE TABLE dbo.Employee
(
    EmployeeId   INT IDENTITY(101,1) NOT NULL PRIMARY KEY,
    EmployeeName NVARCHAR(100)       NOT NULL,
    DepartmentId INT                 NOT NULL REFERENCES dbo.Department(DepartmentId),
    ManagerId    INT                 NULL     REFERENCES dbo.Employee(EmployeeId),
    Salary       DECIMAL(12,2)       NOT NULL,
    JoiningDate  DATE                NOT NULL
);

CREATE TABLE dbo.EmployeeSalaryHistory
(
    Id            INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    EmployeeId    INT               NOT NULL REFERENCES dbo.Employee(EmployeeId),
    Salary        DECIMAL(12,2)     NOT NULL,
    EffectiveDate DATE              NOT NULL
);

CREATE TABLE dbo.EmployeeAttendance
(
    Id             INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    EmployeeId     INT               NOT NULL REFERENCES dbo.Employee(EmployeeId),
    AttendanceDate DATE              NOT NULL,
    Status         VARCHAR(10)       NOT NULL   -- 'Present' / 'Absent'
);

INSERT INTO dbo.Department VALUES (1,'IT'),(2,'HR'),(3,'Finance');

SET IDENTITY_INSERT dbo.Employee ON;
INSERT INTO dbo.Employee (EmployeeId, EmployeeName, DepartmentId, ManagerId, Salary, JoiningDate) VALUES
(101,'Amit', 1,NULL,80000,'2022-01-10'),
(102,'Rahul',1,101, 60000,'2023-03-15'),
(103,'Priya',2,NULL,90000,'2021-06-20'),
(104,'Sneha',2,103, 70000,'2024-01-05'),
(105,'Raj',  1,101, 60000,'2023-08-10');
SET IDENTITY_INSERT dbo.Employee OFF;

SET IDENTITY_INSERT dbo.EmployeeSalaryHistory ON;
INSERT INTO dbo.EmployeeSalaryHistory (Id, EmployeeId, Salary, EffectiveDate) VALUES
(1,101,50000,'2022-01-10'),(2,101,60000,'2023-01-10'),(3,101,80000,'2024-01-10'),
(4,102,40000,'2023-03-15'),(5,102,60000,'2024-03-15');
SET IDENTITY_INSERT dbo.EmployeeSalaryHistory OFF;

SET IDENTITY_INSERT dbo.EmployeeAttendance ON;
INSERT INTO dbo.EmployeeAttendance (Id, EmployeeId, AttendanceDate, Status) VALUES
(1,101,'2026-10-01','Present'),(2,101,'2026-10-02','Absent'),(3,101,'2026-10-03','Present'),
(4,102,'2026-10-01','Present'),(5,102,'2026-10-02','Present');
SET IDENTITY_INSERT dbo.EmployeeAttendance OFF;
```

---

### C41. Insert Employee with Transaction and Error Handling

**Concept / Definition:** A stored procedure that wraps related writes in one transaction so they all succeed or all roll back, and uses `TRY/CATCH` + `THROW` to surface errors to the caller.

**Real-world use:** Onboarding a new hire in HRMS must create the employee row and the opening salary-history row atomically.

**Solution:**

```sql
CREATE OR ALTER PROCEDURE dbo.usp_InsertEmployee
    @EmployeeName  NVARCHAR(100),
    @DepartmentId  INT,
    @ManagerId     INT           = NULL,
    @Salary        DECIMAL(12,2),
    @JoiningDate   DATE,
    @NewEmployeeId INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;     -- no "n rows affected" chatter to the client
    SET XACT_ABORT ON;  -- any runtime error dooms + rolls back the transaction

    BEGIN TRY
        ------------------------------------------------------------------
        -- 1. Business validation (before opening a transaction = shorter locks)
        ------------------------------------------------------------------
        IF @EmployeeName IS NULL OR LTRIM(RTRIM(@EmployeeName)) = N''
            THROW 50001, 'EmployeeName is required.', 1;

        IF @Salary IS NULL OR @Salary <= 0
            THROW 50002, 'Salary must be greater than zero.', 1;

        IF NOT EXISTS (SELECT 1 FROM dbo.Department WHERE DepartmentId = @DepartmentId)
            THROW 50003, 'Invalid DepartmentId.', 1;

        IF @ManagerId IS NOT NULL
           AND NOT EXISTS (SELECT 1 FROM dbo.Employee WHERE EmployeeId = @ManagerId)
            THROW 50004, 'Invalid ManagerId.', 1;

        ------------------------------------------------------------------
        -- 2. Atomic unit of work
        ------------------------------------------------------------------
        BEGIN TRANSACTION;

            INSERT INTO dbo.Employee (EmployeeName, DepartmentId, ManagerId, Salary, JoiningDate)
            VALUES (@EmployeeName, @DepartmentId, @ManagerId, @Salary, @JoiningDate);

            SET @NewEmployeeId = CAST(SCOPE_IDENTITY() AS INT);  -- not @@IDENTITY (trigger-safe)

            INSERT INTO dbo.EmployeeSalaryHistory (EmployeeId, Salary, EffectiveDate)
            VALUES (@NewEmployeeId, @Salary, @JoiningDate);

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        -- Optional: INSERT INTO dbo.ErrorLog(...) VALUES (ERROR_NUMBER(), ERROR_MESSAGE(), ...) here,
        -- AFTER the rollback so the log row is not rolled back too.

        THROW;  -- re-raise original error number/message/line to the caller
    END CATCH
END;
GO

-- Test
DECLARE @Id INT;
EXEC dbo.usp_InsertEmployee
     @EmployeeName = N'Kiran', @DepartmentId = 3, @ManagerId = NULL,
     @Salary = 75000, @JoiningDate = '2026-11-01', @NewEmployeeId = @Id OUTPUT;
SELECT @Id AS NewEmployeeId;
```

**C# Dapper call:**

```csharp
public async Task<int> InsertEmployeeAsync(EmployeeCreateDto dto)
{
    using var conn = new SqlConnection(_connectionString);

    var p = new DynamicParameters();
    p.Add("@EmployeeName", dto.EmployeeName, DbType.String, size: 100);
    p.Add("@DepartmentId", dto.DepartmentId, DbType.Int32);
    p.Add("@ManagerId",    dto.ManagerId,    DbType.Int32);
    p.Add("@Salary",       dto.Salary,       DbType.Decimal, precision: 12, scale: 2);
    p.Add("@JoiningDate",  dto.JoiningDate,  DbType.Date);
    p.Add("@NewEmployeeId", dbType: DbType.Int32, direction: ParameterDirection.Output);

    try
    {
        await conn.ExecuteAsync("dbo.usp_InsertEmployee", p,
                                commandType: CommandType.StoredProcedure);
        return p.Get<int>("@NewEmployeeId");
    }
    catch (SqlException ex) when (ex.Number is >= 50001 and <= 50004)
    {
        // Business validation errors thrown by THROW 5000x -> map to HTTP 400
        throw new ValidationException(ex.Message);
    }
}
```

**Output:**

| NewEmployeeId |
|---|
| 106 |

(Plus a new row in `EmployeeSalaryHistory`: Id 6, EmployeeId 106, Salary 75000.00, EffectiveDate 2026-11-01.)

**7-yr insight:** Do validation before `BEGIN TRANSACTION` to keep lock duration short, and always pair `XACT_ABORT ON` with `IF @@TRANCOUNT > 0 ROLLBACK` — without `XACT_ABORT`, a client command timeout (Dapper's default 30 s) can leave an open transaction holding locks on a pooled connection. Use custom error numbers ≥ 50000 so the .NET layer can distinguish business errors from system errors.

---

### C42. Accept Multiple EmployeeIds Using a Table-Valued Parameter

**Concept / Definition:** A Table-Valued Parameter (TVP) lets you pass a set of rows (a user-defined table type) to a stored procedure in a single call instead of a comma-separated string.

**Real-world use:** HR selects 50 employees on a grid and clicks "Generate payslips" — the API passes all selected ids at once.

**Solution:**

```sql
-- 1. User-defined table type (PK = no duplicates + better cardinality / seeks)
CREATE TYPE dbo.EmployeeIdList AS TABLE
(
    EmployeeId INT NOT NULL PRIMARY KEY
);
GO

-- 2. Procedure consuming the TVP (TVPs are always READONLY)
CREATE OR ALTER PROCEDURE dbo.usp_GetEmployeesByIds
    @EmployeeIds dbo.EmployeeIdList READONLY
AS
BEGIN
    SET NOCOUNT ON;

    SELECT  e.EmployeeId,
            e.EmployeeName,
            d.DepartmentName,
            e.Salary
    FROM    @EmployeeIds        AS ids
    JOIN    dbo.Employee        AS e ON e.EmployeeId   = ids.EmployeeId
    JOIN    dbo.Department      AS d ON d.DepartmentId = e.DepartmentId
    ORDER BY e.EmployeeId;
END;
GO

-- 3. Test from T-SQL
DECLARE @Ids dbo.EmployeeIdList;
INSERT INTO @Ids (EmployeeId) VALUES (101),(103),(105);
EXEC dbo.usp_GetEmployeesByIds @EmployeeIds = @Ids;
```

**C# Dapper call:**

```csharp
public async Task<IEnumerable<EmployeeDto>> GetEmployeesByIdsAsync(IEnumerable<int> ids)
{
    var table = new DataTable();
    table.Columns.Add("EmployeeId", typeof(int));          // name/order must match the type
    foreach (var id in ids.Distinct()) table.Rows.Add(id); // Distinct: type has a PK

    using var conn = new SqlConnection(_connectionString);
    return await conn.QueryAsync<EmployeeDto>(
        "dbo.usp_GetEmployeesByIds",
        new { EmployeeIds = table.AsTableValuedParameter("dbo.EmployeeIdList") },
        commandType: CommandType.StoredProcedure);
}
```

**Output:**

| EmployeeId | EmployeeName | DepartmentName | Salary |
|---|---|---|---|
| 101 | Amit | IT | 80000.00 |
| 103 | Priya | HR | 90000.00 |
| 105 | Raj | IT | 60000.00 |

**7-yr insight:** TVPs are strongly typed and injection-safe, unlike building `IN (1,2,3)` strings. Before SQL Server 2019 (compat level 150) table variables/TVPs are estimated at 1 row, so for thousands of ids consider copying into a `#temp` table (which has statistics) or `OPTION (RECOMPILE)`. Changing a table type requires dropping all dependent procedures first — version your types (e.g., `EmployeeIdList_v2`).

---

### C43. Pagination Using OFFSET FETCH and Keyset Pagination

**Concept / Definition:** `OFFSET … FETCH` skips N rows and returns the next page; keyset (seek) pagination instead remembers the last key seen and seeks directly past it, which stays fast on deep pages.

**Real-world use:** The Employee Directory grid in HRMS shows 20 employees per page with a total count for the pager.

**Solution:**

```sql
------------------------------------------------------------
-- A) OFFSET / FETCH with total count (two result sets)
------------------------------------------------------------
CREATE OR ALTER PROCEDURE dbo.usp_GetEmployeesPaged
    @PageNumber   INT = 1,
    @PageSize     INT = 20,
    @DepartmentId INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Defensive bounds (never trust UI input)
    IF @PageNumber < 1 SET @PageNumber = 1;
    IF @PageSize  < 1 OR @PageSize > 200 SET @PageSize = 20;

    -- Result set 1: total count for the pager
    SELECT COUNT(*) AS TotalCount
    FROM   dbo.Employee
    WHERE  (@DepartmentId IS NULL OR DepartmentId = @DepartmentId)
    OPTION (RECOMPILE);

    -- Result set 2: the requested page (ORDER BY must be deterministic/unique)
    SELECT  e.EmployeeId, e.EmployeeName, d.DepartmentName, e.Salary, e.JoiningDate
    FROM    dbo.Employee   AS e
    JOIN    dbo.Department AS d ON d.DepartmentId = e.DepartmentId
    WHERE   (@DepartmentId IS NULL OR e.DepartmentId = @DepartmentId)
    ORDER BY e.EmployeeId
    OFFSET (@PageNumber - 1) * @PageSize ROWS
    FETCH NEXT @PageSize ROWS ONLY
    OPTION (RECOMPILE);
END;
GO

EXEC dbo.usp_GetEmployeesPaged @PageNumber = 2, @PageSize = 2;

-- Single-result-set alternative: add  COUNT(*) OVER() AS TotalCount  to the page query
-- (simpler for the client, but SQL Server must still count all qualifying rows).

------------------------------------------------------------
-- B) Keyset / seek pagination ("Load more" / infinite scroll)
------------------------------------------------------------
CREATE OR ALTER PROCEDURE dbo.usp_GetEmployeesKeyset
    @LastEmployeeId INT = 0,   -- last id from the previous page (0 = first page)
    @PageSize       INT = 20
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP (@PageSize)
            e.EmployeeId, e.EmployeeName, d.DepartmentName, e.Salary, e.JoiningDate
    FROM    dbo.Employee   AS e
    JOIN    dbo.Department AS d ON d.DepartmentId = e.DepartmentId
    WHERE   e.EmployeeId > @LastEmployeeId          -- index SEEK, no rows skipped
    ORDER BY e.EmployeeId;
END;
GO

EXEC dbo.usp_GetEmployeesKeyset @LastEmployeeId = 102, @PageSize = 2;
```

**C# Dapper call:**

```csharp
public async Task<PagedResult<EmployeeDto>> GetEmployeesPagedAsync(int page, int size, int? deptId)
{
    using var conn = new SqlConnection(_connectionString);
    using var multi = await conn.QueryMultipleAsync(
        "dbo.usp_GetEmployeesPaged",
        new { PageNumber = page, PageSize = size, DepartmentId = deptId },
        commandType: CommandType.StoredProcedure);

    var total = await multi.ReadSingleAsync<int>();          // result set 1
    var items = (await multi.ReadAsync<EmployeeDto>()).ToList(); // result set 2
    return new PagedResult<EmployeeDto>(items, total, page, size);
}
```

**Output:**

`usp_GetEmployeesPaged @PageNumber = 2, @PageSize = 2`

| TotalCount |
|---|
| 5 |

| EmployeeId | EmployeeName | DepartmentName | Salary | JoiningDate |
|---|---|---|---|---|
| 103 | Priya | HR | 90000.00 | 2021-06-20 |
| 104 | Sneha | HR | 70000.00 | 2024-01-05 |

`usp_GetEmployeesKeyset @LastEmployeeId = 102, @PageSize = 2` returns the same two rows (103, 104) — but via a seek.

**7-yr insight:** `OFFSET 1000000` still reads and discards a million rows, so deep pages get linearly slower; keyset pagination is O(page size) but can't jump to "page 5000". The ORDER BY must be unique (add the PK as tie-breaker, e.g. `ORDER BY JoiningDate, EmployeeId`) or rows can repeat/disappear between pages; for big tables, cache the total count or show "1000+" instead of counting every request.

---

### C44. Latest Record for Each EmployeeId

**Concept / Definition:** Use `ROW_NUMBER()` partitioned by the employee and ordered by date descending, then keep row number 1.

**Real-world use:** Show each employee's current salary from the salary-history table.

**Solution:**

```sql
-- Approach 1: ROW_NUMBER (most common interview answer)
WITH Ranked AS
(
    SELECT  Id, EmployeeId, Salary, EffectiveDate,
            ROW_NUMBER() OVER (PARTITION BY EmployeeId
                               ORDER BY EffectiveDate DESC, Id DESC) AS rn  -- Id DESC = tie-breaker
    FROM    dbo.EmployeeSalaryHistory
)
SELECT Id, EmployeeId, Salary, EffectiveDate
FROM   Ranked
WHERE  rn = 1
ORDER BY EmployeeId;

-- Approach 2: CROSS APPLY TOP(1) – great when you drive from the Employee table
-- and have index (EmployeeId, EffectiveDate DESC) INCLUDE (Salary)
SELECT e.EmployeeId, e.EmployeeName, h.Salary, h.EffectiveDate
FROM   dbo.Employee AS e
CROSS APPLY (SELECT TOP (1) s.Salary, s.EffectiveDate
             FROM   dbo.EmployeeSalaryHistory AS s
             WHERE  s.EmployeeId = e.EmployeeId
             ORDER BY s.EffectiveDate DESC, s.Id DESC) AS h;

-- Supporting index
CREATE INDEX IX_EmpSalHist_Emp_EffDate
    ON dbo.EmployeeSalaryHistory (EmployeeId, EffectiveDate DESC) INCLUDE (Salary);
```

**Output:**

| Id | EmployeeId | Salary | EffectiveDate |
|---|---|---|---|
| 3 | 101 | 80000.00 | 2024-01-10 |
| 5 | 102 | 60000.00 | 2024-03-15 |

**7-yr insight:** Always add a unique tie-breaker in the ORDER BY, otherwise two rows on the same date return nondeterministically. `ROW_NUMBER` scans the whole history table; `CROSS APPLY TOP 1` does one seek per employee — better when there are few employees with many history rows each.

---

### C45. Second Latest Record for Each EmployeeId

**Concept / Definition:** Same pattern as C44 but filter `rn = 2`; use `DENSE_RANK` if you mean "second distinct value" rather than "second row".

**Real-world use:** Show previous salary vs current salary on the increment letter.

**Solution:**

```sql
WITH Ranked AS
(
    SELECT  Id, EmployeeId, Salary, EffectiveDate,
            ROW_NUMBER() OVER (PARTITION BY EmployeeId
                               ORDER BY EffectiveDate DESC, Id DESC) AS rn
    FROM    dbo.EmployeeSalaryHistory
)
SELECT Id, EmployeeId, Salary, EffectiveDate
FROM   Ranked
WHERE  rn = 2
ORDER BY EmployeeId;

-- Variant: current + previous on one row using LAG
WITH x AS
(
    SELECT EmployeeId, Salary, EffectiveDate,
           LAG(Salary) OVER (PARTITION BY EmployeeId ORDER BY EffectiveDate, Id) AS PreviousSalary,
           ROW_NUMBER() OVER (PARTITION BY EmployeeId ORDER BY EffectiveDate DESC, Id DESC) AS rn
    FROM   dbo.EmployeeSalaryHistory
)
SELECT EmployeeId, Salary AS CurrentSalary, PreviousSalary
FROM   x
WHERE  rn = 1;
```

**Output:**

| Id | EmployeeId | Salary | EffectiveDate |
|---|---|---|---|
| 2 | 101 | 60000.00 | 2023-01-10 |
| 4 | 102 | 40000.00 | 2023-03-15 |

LAG variant:

| EmployeeId | CurrentSalary | PreviousSalary |
|---|---|---|
| 101 | 80000.00 | 60000.00 |
| 102 | 60000.00 | 40000.00 |

**7-yr insight:** Employees with only one history row simply don't appear for `rn = 2` — clarify with the interviewer whether they should appear with NULL (then use the LAG variant or a LEFT JOIN). Mention the ROW_NUMBER vs RANK vs DENSE_RANK difference when ties exist.

---

### C46. Convert Rows into Columns Using PIVOT

**Concept / Definition:** `PIVOT` rotates distinct values of one column into separate columns, applying an aggregate (COUNT, SUM, MAX) to fill them.

**Real-world use:** Attendance summary report: one row per employee with Present/Absent counts, or a day-wise attendance register.

**Solution:**

```sql
-- A) Static PIVOT: Present / Absent count per employee
SELECT  p.EmployeeId,
        e.EmployeeName,
        p.[Present],
        p.[Absent]
FROM   (SELECT EmployeeId, Status, Id
        FROM   dbo.EmployeeAttendance) AS src     -- only the columns PIVOT needs
PIVOT  (COUNT(Id) FOR Status IN ([Present], [Absent])) AS p
JOIN    dbo.Employee AS e ON e.EmployeeId = p.EmployeeId
ORDER BY p.EmployeeId;

-- Same thing with conditional aggregation (often clearer and more flexible)
SELECT  a.EmployeeId,
        SUM(CASE WHEN a.Status = 'Present' THEN 1 ELSE 0 END) AS Present,
        SUM(CASE WHEN a.Status = 'Absent'  THEN 1 ELSE 0 END) AS Absent
FROM    dbo.EmployeeAttendance AS a
GROUP BY a.EmployeeId;

-- B) Dynamic PIVOT: one column per attendance date (dates unknown at design time)
DECLARE @cols NVARCHAR(MAX), @sql NVARCHAR(MAX);

SELECT @cols = STRING_AGG(QUOTENAME(CONVERT(CHAR(10), d.AttendanceDate, 23)), ',')
               WITHIN GROUP (ORDER BY d.AttendanceDate)
FROM  (SELECT DISTINCT AttendanceDate FROM dbo.EmployeeAttendance) AS d;

SET @sql = N'
SELECT EmployeeId, ' + @cols + N'
FROM  (SELECT EmployeeId, CONVERT(CHAR(10), AttendanceDate, 23) AS AttDate, Status
       FROM dbo.EmployeeAttendance) AS src
PIVOT (MAX(Status) FOR AttDate IN (' + @cols + N')) AS p
ORDER BY EmployeeId;';

EXEC sys.sp_executesql @sql;   -- QUOTENAME protects the generated column list
```

**Output (A – static):**

| EmployeeId | EmployeeName | Present | Absent |
|---|---|---|---|
| 101 | Amit | 2 | 1 |
| 102 | Rahul | 2 | 0 |

**Output (B – dynamic):**

| EmployeeId | 2026-10-01 | 2026-10-02 | 2026-10-03 |
|---|---|---|---|
| 101 | Present | Absent | Present |
| 102 | Present | Present | NULL |

**7-yr insight:** PIVOT groups by *every* column in the source that isn't aggregated or pivoted, so always feed it a derived table with only the needed columns. For dynamic pivots, build column names with `QUOTENAME` to avoid injection; in many APIs I'd rather return normalized rows and pivot in C# or the reporting tool.

---

### C47. Convert Columns into Rows Using UNPIVOT

**Concept / Definition:** `UNPIVOT` turns several columns into name/value rows; `CROSS APPLY (VALUES …)` does the same with more control (keeps NULLs, multiple value columns, mixed expressions).

**Real-world use:** Normalizing a legacy Excel-style salary import where each month is a column.

**Solution:**

```sql
-- Extra table for this question
CREATE TABLE dbo.EmployeeSalaryWide
(
    EmployeeId INT           NOT NULL PRIMARY KEY,
    Jan        DECIMAL(12,2) NULL,
    Feb        DECIMAL(12,2) NULL,
    Mar        DECIMAL(12,2) NULL
);
INSERT INTO dbo.EmployeeSalaryWide VALUES
(101, 80000, 80000, 85000),
(102, 60000, NULL,  62000);

-- A) UNPIVOT (all columns must have the same data type; NULLs are DROPPED)
SELECT  EmployeeId, SalaryMonth, Salary
FROM    dbo.EmployeeSalaryWide
UNPIVOT (Salary FOR SalaryMonth IN (Jan, Feb, Mar)) AS u
ORDER BY EmployeeId;

-- B) CROSS APPLY VALUES (keeps NULLs, preserves month order, allows extra columns)
SELECT  w.EmployeeId, v.SalaryMonth, v.Salary
FROM    dbo.EmployeeSalaryWide AS w
CROSS APPLY (VALUES (1, 'Jan', w.Jan),
                    (2, 'Feb', w.Feb),
                    (3, 'Mar', w.Mar)) AS v(MonthNo, SalaryMonth, Salary)
ORDER BY w.EmployeeId, v.MonthNo;
```

**Output (A – UNPIVOT):**

| EmployeeId | SalaryMonth | Salary |
|---|---|---|
| 101 | Jan | 80000.00 |
| 101 | Feb | 80000.00 |
| 101 | Mar | 85000.00 |
| 102 | Jan | 60000.00 |
| 102 | Mar | 62000.00 |

**Output (B – CROSS APPLY VALUES):**

| EmployeeId | SalaryMonth | Salary |
|---|---|---|
| 101 | Jan | 80000.00 |
| 101 | Feb | 80000.00 |
| 101 | Mar | 85000.00 |
| 102 | Jan | 60000.00 |
| 102 | Feb | NULL |
| 102 | Mar | 62000.00 |

**7-yr insight:** The silent NULL-dropping of UNPIVOT is a classic data-loss bug in migrations — I prefer `CROSS APPLY VALUES`, which also lets me unpivot pairs of columns (e.g., `JanAmount, JanCurrency`) in one pass. Both read the base table once, so performance is equivalent.

---

### C48. Dynamic Search with Optional Parameters

**Concept / Definition:** Build the WHERE clause only for parameters actually supplied, and execute with `sp_executesql` using real parameters so the query is injection-safe and plan-cache friendly.

**Real-world use:** Employee search screen with optional filters (name, department, salary range, joining date) and sortable columns.

**Solution:**

```sql
CREATE OR ALTER PROCEDURE dbo.usp_SearchEmployees
    @EmployeeName  NVARCHAR(100) = NULL,
    @DepartmentId  INT           = NULL,
    @MinSalary     DECIMAL(12,2) = NULL,
    @MaxSalary     DECIMAL(12,2) = NULL,
    @JoinedFrom    DATE          = NULL,
    @SortColumn    SYSNAME       = N'EmployeeId',
    @SortDirection VARCHAR(4)    = 'ASC'
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @sql NVARCHAR(MAX) = N'
SELECT  e.EmployeeId, e.EmployeeName, d.DepartmentName, e.Salary, e.JoiningDate
FROM    dbo.Employee   AS e
JOIN    dbo.Department AS d ON d.DepartmentId = e.DepartmentId
WHERE   1 = 1';

    -- Append ONLY the predicates that are needed; values stay as parameters
    IF @EmployeeName IS NOT NULL SET @sql += N' AND e.EmployeeName LIKE @EmployeeName + N''%''';
    IF @DepartmentId IS NOT NULL SET @sql += N' AND e.DepartmentId = @DepartmentId';
    IF @MinSalary    IS NOT NULL SET @sql += N' AND e.Salary >= @MinSalary';
    IF @MaxSalary    IS NOT NULL SET @sql += N' AND e.Salary <= @MaxSalary';
    IF @JoinedFrom   IS NOT NULL SET @sql += N' AND e.JoiningDate >= @JoinedFrom';

    -- ORDER BY cannot be parameterized -> WHITELIST, never concatenate user input
    SET @sql += N' ORDER BY ' +
        CASE @SortColumn
            WHEN N'EmployeeName' THEN N'e.EmployeeName'
            WHEN N'Salary'       THEN N'e.Salary'
            WHEN N'JoiningDate'  THEN N'e.JoiningDate'
            ELSE                      N'e.EmployeeId'
        END +
        CASE WHEN UPPER(@SortDirection) = 'DESC' THEN N' DESC' ELSE N' ASC' END +
        N', e.EmployeeId;';   -- deterministic tie-breaker

    EXEC sys.sp_executesql
         @sql,
         N'@EmployeeName NVARCHAR(100), @DepartmentId INT, @MinSalary DECIMAL(12,2),
           @MaxSalary DECIMAL(12,2), @JoinedFrom DATE',
         @EmployeeName = @EmployeeName,
         @DepartmentId = @DepartmentId,
         @MinSalary    = @MinSalary,
         @MaxSalary    = @MaxSalary,
         @JoinedFrom   = @JoinedFrom;
END;
GO

EXEC dbo.usp_SearchEmployees @DepartmentId = 1, @MinSalary = 60000;

-------------------------------------------------------------------
-- Alternative: static "catch-all" query + OPTION (RECOMPILE)
-------------------------------------------------------------------
-- SELECT ... FROM dbo.Employee e JOIN dbo.Department d ON ...
-- WHERE (@EmployeeName IS NULL OR e.EmployeeName LIKE @EmployeeName + N'%')
--   AND (@DepartmentId IS NULL OR e.DepartmentId = @DepartmentId)
--   AND (@MinSalary    IS NULL OR e.Salary >= @MinSalary)
--   AND (@MaxSalary    IS NULL OR e.Salary <= @MaxSalary)
--   AND (@JoinedFrom   IS NULL OR e.JoiningDate >= @JoinedFrom)
-- OPTION (RECOMPILE);   -- optimizer embeds actual values and removes dead branches
```

**C# Dapper call:**

```csharp
public async Task<IEnumerable<EmployeeDto>> SearchEmployeesAsync(EmployeeSearchRequest r)
{
    var p = new DynamicParameters();
    p.Add("@EmployeeName",  r.Name,         DbType.String, size: 100); // match NVARCHAR(100)
    p.Add("@DepartmentId",  r.DepartmentId, DbType.Int32);
    p.Add("@MinSalary",     r.MinSalary,    DbType.Decimal, precision: 12, scale: 2);
    p.Add("@MaxSalary",     r.MaxSalary,    DbType.Decimal, precision: 12, scale: 2);
    p.Add("@JoinedFrom",    r.JoinedFrom,   DbType.Date);
    p.Add("@SortColumn",    r.SortColumn ?? "EmployeeId");
    p.Add("@SortDirection", r.SortDesc ? "DESC" : "ASC", DbType.AnsiString, size: 4);

    using var conn = new SqlConnection(_connectionString);
    return await conn.QueryAsync<EmployeeDto>("dbo.usp_SearchEmployees", p,
                                              commandType: CommandType.StoredProcedure,
                                              commandTimeout: 30);
}
```

**Output:** (`@DepartmentId = 1, @MinSalary = 60000`)

| EmployeeId | EmployeeName | DepartmentName | Salary | JoiningDate |
|---|---|---|---|---|
| 101 | Amit | IT | 80000.00 | 2022-01-10 |
| 102 | Rahul | IT | 60000.00 | 2023-03-15 |
| 105 | Raj | IT | 60000.00 | 2023-08-10 |

**7-yr insight:** Dynamic SQL gives one cached plan *per filter combination* (each is index-friendly), while the catch-all + `OPTION (RECOMPILE)` is simpler but pays compile CPU on every call — fine for a search screen, bad for an endpoint hit 1,000 times/second. Never use `EXEC(@sql)` with concatenated values; and in Dapper set string `size`/`DbType.AnsiString` correctly to avoid implicit conversions and plan-cache bloat from varying parameter lengths.

---

### C49. Find Missing Identity Values

**Concept / Definition:** Finding gaps in a numeric sequence using `LEAD()`, tally tables, or recursive CTEs to identify missing identity or invoice numbers.

**Real-world use:** Auditing sequential invoice numbers, tax serial receipts, or biometric punch sequence IDs to detect deleted records or failed transactions.

**Solution:**
```sql
-- Technique: Using LEAD() to identify gap ranges in a single scan
WITH NumberSequence AS
(
    SELECT 
        Id AS CurrentVal,
        LEAD(Id) OVER (ORDER BY Id ASC) AS NextVal
    FROM dbo.EmployeeSalaryHistory
)
SELECT 
    (CurrentVal + 1) AS GapStart,
    (NextVal - 1)    AS GapEnd,
    (NextVal - CurrentVal - 1) AS MissingCount
FROM NumberSequence
WHERE NextVal > (CurrentVal + 1);
```

**7-yr insight:** `LEAD()` is by far the most efficient technique ($O(N)$ single index scan) to identify gap boundaries without generating a giant sequence table. If you must output *every individual missing number* rather than the start and end of the gap, join a Numbers/Tally table or a recursive CTE against the sequence table with `LEFT JOIN ... WHERE sequence.Id IS NULL`.

---

### C50. Employees Not Logged In for the Last 90 Days

**Concept / Definition:** Anti-semi-join using `NOT EXISTS` or `LEFT JOIN ... WHERE right.Key IS NULL` against an activity/login table with a date threshold.

**Real-world use:** Security deactivation audit: finding inactive employee user accounts that have had zero logins for 90 days to revoke system access.

**Solution:**
```sql
-- Sample Login Audit Table
IF OBJECT_ID('tempdb..#EmployeeLogins') IS NOT NULL DROP TABLE #EmployeeLogins;
CREATE TABLE #EmployeeLogins
(
    Id INT IDENTITY PRIMARY KEY,
    EmployeeId INT NOT NULL,
    LoginTime DATETIME2(3) NOT NULL
);

INSERT INTO #EmployeeLogins (EmployeeId, LoginTime) VALUES
(101, '2026-10-30 08:30:00'),
(102, '2026-06-01 10:15:00'), -- More than 90 days ago
(104, '2026-10-25 09:00:00');
-- 103 and 105 have NEVER logged in!

-- Query: Active employees with no login within the last 90 days
DECLARE @CutoffDate DATETIME2(3) = DATEADD(DAY, -90, GETDATE());

SELECT 
    e.EmployeeId,
    e.EmployeeName,
    e.JoiningDate,
    MAX(l.LoginTime) AS LastLoginDate
FROM dbo.Employee e
LEFT JOIN #EmployeeLogins l ON e.EmployeeId = l.EmployeeId
GROUP BY e.EmployeeId, e.EmployeeName, e.JoiningDate
HAVING MAX(l.LoginTime) < @CutoffDate OR MAX(l.LoginTime) IS NULL
ORDER BY e.EmployeeId;
```

**Output:**

| EmployeeId | EmployeeName | JoiningDate | LastLoginDate |
|---|---|---|---|
| 102 | Rahul | 2023-03-15 | 2026-06-01 10:15:00.000 |
| 103 | Priya | 2021-06-20 | NULL |
| 105 | Raj | 2023-08-10 | NULL |

**7-yr insight:** Always use `NOT EXISTS` or a `GROUP BY ... HAVING MAX(LoginTime) < @Cutoff OR MAX(LoginTime) IS NULL` pattern. Avoid `NOT IN` because if `#EmployeeLogins` contains a `NULL` `EmployeeId`, the query will return zero rows. In production, ensure an index exists on `#EmployeeLogins(EmployeeId, LoginTime DESC)` so the max login date is fetched via an instantaneous index seek.

---

### C51. Monthly Attendance Percentage

**Concept / Definition:** Aggregating attendance status flags using conditional aggregation (`SUM(CASE ...)` or `IIF`) divided by total working days in the month.

**Real-world use:** Payroll attendance normalization: calculating monthly payable salary percentage based on present days vs total scheduled days.

**Solution:**
```sql
SELECT 
    e.EmployeeId,
    e.EmployeeName,
    COUNT(*) AS TotalRecordedDays,
    SUM(CASE WHEN ea.Status = 'Present' THEN 1 ELSE 0 END) AS PresentDays,
    SUM(CASE WHEN ea.Status = 'Absent'  THEN 1 ELSE 0 END) AS AbsentDays,
    CAST(
        (SUM(CASE WHEN ea.Status = 'Present' THEN 1.0 ELSE 0.0 END) * 100.0) / COUNT(*)
        AS DECIMAL(5,2)
    ) AS AttendancePercentage
FROM dbo.Employee e
JOIN dbo.EmployeeAttendance ea ON e.EmployeeId = ea.EmployeeId
WHERE ea.AttendanceDate >= '2026-10-01' AND ea.AttendanceDate < '2026-11-01'
GROUP BY e.EmployeeId, e.EmployeeName
ORDER BY e.EmployeeId;
```

**Output:**

| EmployeeId | EmployeeName | TotalRecordedDays | PresentDays | AbsentDays | AttendancePercentage |
|---|---|---|---|---|---|
| 101 | Amit | 3 | 2 | 1 | 66.67 |
| 102 | Rahul | 2 | 2 | 0 | 100.00 |

**7-yr insight:** Watch out for integer division! In SQL Server, `2 / 3` evaluates to `0`. Always multiply by `1.0` or cast the numerator to `DECIMAL` before dividing. For calendar compliance where absent punches are not recorded as rows, cross join an employee master with a calendar date dimension table to account for missing punch days.

---

### C52. Three Consecutive Absent Days

**Concept / Definition:** Identifying sequences of 3 consecutive absences using `LEAD()` or the Gaps-and-Islands technique.

**Real-world use:** HR disciplinary automation: flagging employees with unauthorized absence for 3 or more consecutive working days.

**Solution:**
```sql
-- Sample extended attendance data
IF OBJECT_ID('tempdb..#ExtendedAttendance') IS NOT NULL DROP TABLE #ExtendedAttendance;
CREATE TABLE #ExtendedAttendance
(
    EmployeeId INT,
    AttendanceDate DATE,
    Status VARCHAR(10)
);

INSERT INTO #ExtendedAttendance VALUES
(101, '2026-10-01', 'Present'),
(101, '2026-10-02', 'Absent'),
(101, '2026-10-03', 'Absent'),
(101, '2026-10-04', 'Absent'), -- 3 consecutive absences!
(101, '2026-10-05', 'Present'),
(102, '2026-10-01', 'Absent'),
(102, '2026-10-02', 'Absent');

-- Solution using LEAD to inspect 2 subsequent days
WITH AbsenceStreaks AS
(
    SELECT 
        EmployeeId,
        AttendanceDate,
        Status,
        LEAD(Status, 1) OVER (PARTITION BY EmployeeId ORDER BY AttendanceDate) AS NextDayStatus,
        LEAD(Status, 2) OVER (PARTITION BY EmployeeId ORDER BY AttendanceDate) AS DayAfterStatus,
        LEAD(AttendanceDate, 2) OVER (PARTITION BY EmployeeId ORDER BY AttendanceDate) AS ThirdDayDate
    FROM #ExtendedAttendance
)
SELECT 
    EmployeeId,
    AttendanceDate AS AbsenceStartDate,
    ThirdDayDate   AS AbsenceThirdDayDate
FROM AbsenceStreaks
WHERE Status = 'Absent' 
  AND NextDayStatus = 'Absent' 
  AND DayAfterStatus = 'Absent'
  AND DATEDIFF(DAY, AttendanceDate, ThirdDayDate) = 2; -- Ensures strictly calendar consecutive
```

**Output:**

| EmployeeId | AbsenceStartDate | AbsenceThirdDayDate |
|---|---|---|
| 101 | 2026-10-02 | 2026-10-04 |

**7-yr insight:** The `DATEDIFF(DAY, AttendanceDate, ThirdDayDate) = 2` condition is crucial: without it, two absences separated by a weekend or holiday would falsely register as consecutive if non-working days are omitted from the table.

---

### C53. Department-wise Salary Report with Totals

**Concept / Definition:** Using `GROUP BY ROLLUP` or `GROUPING SETS` to produce hierarchical subtotals per department and a grand total row in a single query pass.

**Real-world use:** Executive payroll ledger: displaying total salaries per department alongside a final company-wide grand total line.

**Solution:**
```sql
SELECT 
    CASE 
        WHEN GROUPING(d.DepartmentName) = 1 THEN '=== GRAND TOTAL ==='
        ELSE d.DepartmentName 
    END AS DepartmentName,
    COUNT(e.EmployeeId) AS EmployeeCount,
    SUM(e.Salary)       AS TotalSalary,
    AVG(e.Salary)       AS AvgSalary,
    MIN(e.Salary)       AS MinSalary,
    MAX(e.Salary)       AS MaxSalary
FROM dbo.Department d
JOIN dbo.Employee e ON d.DepartmentId = e.DepartmentId
GROUP BY ROLLUP(d.DepartmentName);
```

**Output:**

| DepartmentName | EmployeeCount | TotalSalary | AvgSalary | MinSalary | MaxSalary |
|---|---|---|---|---|---|
| HR | 2 | 160000.00 | 80000.00 | 70000.00 | 90000.00 |
| IT | 3 | 200000.00 | 66666.66 | 60000.00 | 80000.00 |
| === GRAND TOTAL === | 5 | 360000.00 | 720000.00 | 60000.00 | 90000.00 |

**7-yr insight:** `GROUPING(ColumnName)` returns `1` when the row is an aggregated subtotal or grand total, and `0` for regular rows. This allows clean replacement of `NULL` subtotal headers. Using `ROLLUP` is vastly superior to `UNION ALL`-ing detail queries with summary queries because `ROLLUP` computes subtotals in a single scan of the base data.

---

### C54. Delete Records in Batches of 10000

**Concept / Definition:** Purging large volumes of historical rows using a `WHILE` loop with `DELETE TOP (N)` to prevent lock escalation, minimize transaction log spikes, and maintain high concurrency.

**Real-world use:** Nightly purging of expired application session tokens or historical biometric logs older than 3 years.

**Solution:**
```sql
SET NOCOUNT ON;

DECLARE @BatchSize INT = 10000;
DECLARE @RowsDeleted INT = @BatchSize;
DECLARE @CutoffDate DATE = '2024-01-01';

WHILE @RowsDeleted = @BatchSize
BEGIN
    BEGIN TRANSACTION;

    DELETE TOP (@BatchSize)
    FROM dbo.EmployeeAttendance WITH (ROWLOCK)
    WHERE AttendanceDate < @CutoffDate;

    SET @RowsDeleted = @@ROWCOUNT;

    COMMIT TRANSACTION;

    -- 200ms pause to allow disk flush and log backup truncation
    WAITFOR DELAY '00:00:00.200';
END;
```

**7-yr insight:** Keeping the batch size at 10,000 (or 5,000) prevents lock escalation from row-level locks to exclusive table locks (`LCK_M_X`), which triggers around 5,000 locks. The explicit `WAITFOR DELAY` yields CPU and gives concurrent OLTP transactions and scheduled transaction log backups room to execute smoothly.

---

### C55. Update One Table Using Another Table

**Concept / Definition:** Performing a joined `UPDATE` statement where values from a staging or dimension table are written to a target table based on a matching key.

**Real-world use:** Applying annual increment percentages or updated tax deductions from a payroll staging table into the live `Employee` master.

**Solution:**
```sql
-- Staging table with salary revisions
IF OBJECT_ID('tempdb..#SalaryRevisions') IS NOT NULL DROP TABLE #SalaryRevisions;
CREATE TABLE #SalaryRevisions
(
    EmployeeId INT PRIMARY KEY,
    NewSalary DECIMAL(12,2)
);

INSERT INTO #SalaryRevisions VALUES (102, 68000.00), (105, 65000.00);

-- Standard T-SQL Joined UPDATE
UPDATE e
SET e.Salary = s.NewSalary
FROM dbo.Employee e
JOIN #SalaryRevisions s ON e.EmployeeId = s.EmployeeId;

-- Verification
SELECT EmployeeId, EmployeeName, Salary FROM dbo.Employee WHERE EmployeeId IN (102, 105);
```

**7-yr insight:** When updating via a `JOIN`, ensure the source table has a unique key on the join column. If the source table contains duplicate rows for the same `EmployeeId`, SQL Server will update the target row non-deterministically using an arbitrary matching row from the source without throwing an error!

---

### C56. Overlapping Date Ranges

**Concept / Definition:** Detecting whether two date intervals $[S_1, E_1]$ and $[S_2, E_2]$ intersect using the universal interval overlap predicate: $S_1 \le E_2 \text{ AND } S_2 \le E_1$.

**Real-world use:** Leave management system: preventing an employee from booking overlapping annual leave requests or project allocations.

**Solution:**
```sql
IF OBJECT_ID('tempdb..#LeaveRequests') IS NOT NULL DROP TABLE #LeaveRequests;
CREATE TABLE #LeaveRequests
(
    LeaveId INT IDENTITY PRIMARY KEY,
    EmployeeId INT NOT NULL,
    StartDate DATE NOT NULL,
    EndDate DATE NOT NULL
);

INSERT INTO #LeaveRequests VALUES
(101, '2026-11-10', '2026-11-15'),
(101, '2026-11-14', '2026-11-20'), -- Overlaps with above!
(101, '2026-12-01', '2026-12-05');

-- Query to find all overlapping leave requests for an employee
SELECT 
    a.LeaveId AS Request1_Id,
    a.StartDate AS Req1_Start,
    a.EndDate   AS Req1_End,
    b.LeaveId AS Request2_Id,
    b.StartDate AS Req2_Start,
    b.EndDate   AS Req2_End
FROM #LeaveRequests a
JOIN #LeaveRequests b 
  ON a.EmployeeId = b.EmployeeId 
 AND a.LeaveId < b.LeaveId -- Avoid comparing to self and duplicate mirror pairs
WHERE a.StartDate <= b.EndDate 
  AND b.StartDate <= a.EndDate;
```

**Output:**

| Request1_Id | Req1_Start | Req1_End | Request2_Id | Req2_Start | Req2_End |
|---|---|---|---|---|---|
| 1 | 2026-11-10 | 2026-11-15 | 2 | 2026-11-14 | 2026-11-20 |

**7-yr insight:** Developers often write 4 complicated `BETWEEN` and `OR` clauses to detect overlaps. The mathematical formula for two intervals $[A, B]$ and $[C, D]$ overlapping is always simply `A <= D AND C <= B`. To prevent overlaps at the database level, implement an indexed view with schema binding or validate inside the booking transaction with `UPDLOCK, HOLDLOCK`.

---

### C57. Longest Consecutive Attendance Streak

**Concept / Definition:** Solving the Gaps-and-Islands problem and applying `MAX(StreakLength)` to find the longest uninterrupted sequence of working attendance.

**Real-world use:** Annual HR rewards: recognizing employees with the highest unbroken attendance streak of the year.

**Solution:**
```sql
WITH AttendanceGroups AS
(
    SELECT 
        EmployeeId,
        AttendanceDate,
        DATEADD(DAY, -ROW_NUMBER() OVER (PARTITION BY EmployeeId ORDER BY AttendanceDate), AttendanceDate) AS IslandKey
    FROM dbo.EmployeeAttendance
    WHERE Status = 'Present'
),
StreakLengths AS
(
    SELECT 
        EmployeeId,
        MIN(AttendanceDate) AS StreakStart,
        MAX(AttendanceDate) AS StreakEnd,
        COUNT(*) AS StreakDays
    FROM AttendanceGroups
    GROUP BY EmployeeId, IslandKey
),
RankedStreaks AS
(
    SELECT 
        EmployeeId,
        StreakStart,
        StreakEnd,
        StreakDays,
        DENSE_RANK() OVER (PARTITION BY EmployeeId ORDER BY StreakDays DESC) AS Rnk
    FROM StreakLengths
)
SELECT EmployeeId, StreakStart, StreakEnd, StreakDays AS LongestStreakDays
FROM RankedStreaks
WHERE Rnk = 1;
```

**7-yr insight:** In a true corporate setting, weekends and company holidays must be excluded so a Friday-to-Monday presence is treated as continuous. To achieve this, join with a `DimDate` calendar table and order by `WorkingDayNumber` rather than raw calendar `AttendanceDate`.

---

### C58. Salary History Using an Audit Table

**Concept / Definition:** Capturing historical data changes via an `AFTER UPDATE` trigger or modern System-Versioned Temporal Tables.

**Real-world use:** Legal and compensation compliance: maintaining an immutable ledger of every employee salary update with timestamps and modified-by users.

**Solution (Production Trigger Pattern):**
```sql
-- 1. Create Audit Table
CREATE TABLE dbo.EmployeeSalaryAudit
(
    AuditId        BIGINT IDENTITY(1,1) PRIMARY KEY,
    EmployeeId     INT NOT NULL,
    OldSalary      DECIMAL(12,2) NOT NULL,
    NewSalary      DECIMAL(12,2) NOT NULL,
    ModifiedBy     VARCHAR(100) NOT NULL,
    ModifiedDate   DATETIME2(3) NOT NULL
);
GO

-- 2. Create AFTER UPDATE Trigger handling multi-row sets!
CREATE OR ALTER TRIGGER dbo.trg_Employee_SalaryAudit
ON dbo.Employee
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Only audit if Salary column was actually updated and changed
    IF UPDATE(Salary)
    BEGIN
        INSERT INTO dbo.EmployeeSalaryAudit (EmployeeId, OldSalary, NewSalary, ModifiedBy, ModifiedDate)
        SELECT 
            i.EmployeeId,
            d.Salary AS OldSalary,
            i.Salary AS NewSalary,
            SYSTEM_USER,
            SYSDATETIME()
        FROM inserted i
        JOIN deleted d ON i.EmployeeId = d.EmployeeId
        WHERE i.Salary <> d.Salary; -- Filter out no-op updates
    END
END;
GO
```

**7-yr insight:** The #1 trigger interview mistake is writing `SELECT @EmpId = EmployeeId FROM inserted;`. That fails catastrophically on multi-row updates, capturing only one arbitrary row! A senior engineer always writes set-based triggers joining `inserted` and `deleted`. Check `IF UPDATE(Column)` and verify `i.Salary <> d.Salary` to prevent logging redundant writes.

---

### C59. Employees Whose Salary Increased Every Month for Three Consecutive Months

**Concept / Definition:** Using `LAG()` with offsets 1 and 2 to compare three consecutive salary records for strictly increasing progression.

**Real-world use:** Identifying fast-tracked high-potential talent or detecting payroll increment anomalies.

**Solution:**
```sql
WITH SalaryProgression AS
(
    SELECT 
        EmployeeId,
        EffectiveDate,
        Salary AS CurrentSalary,
        LAG(Salary, 1) OVER (PARTITION BY EmployeeId ORDER BY EffectiveDate ASC) AS PrevSalary1,
        LAG(Salary, 2) OVER (PARTITION BY EmployeeId ORDER BY EffectiveDate ASC) AS PrevSalary2
    FROM dbo.EmployeeSalaryHistory
)
SELECT 
    sp.EmployeeId,
    e.EmployeeName,
    sp.EffectiveDate AS ThirdIncrementDate,
    sp.PrevSalary2   AS InitialSalary,
    sp.PrevSalary1   AS IntermediateSalary,
    sp.CurrentSalary AS FinalSalary
FROM SalaryProgression sp
JOIN dbo.Employee e ON sp.EmployeeId = e.EmployeeId
WHERE sp.CurrentSalary > sp.PrevSalary1 
  AND sp.PrevSalary1 > sp.PrevSalary2;
```

**Output:**

| EmployeeId | EmployeeName | ThirdIncrementDate | InitialSalary | IntermediateSalary | FinalSalary |
|---|---|---|---|---|---|
| 101 | Amit | 2024-01-10 | 50000.00 | 60000.00 | 80000.00 |

**7-yr insight:** Evaluating `LAG(Salary, 1)` and `LAG(Salary, 2)` inside a single CTE evaluates in a single Window Spool step without needing self-joins. Ensure there are no NULLs in the evaluation, as any comparison with NULL yields UNKNOWN.

---

### C60. Month-over-Month Sales Percentage Difference

**Concept / Definition:** Using `LAG()` to calculate the percentage variance: $\frac{\text{Current} - \text{Previous}}{\text{Previous}} \times 100$.

**Real-world use:** Financial sales analytics: calculating month-over-month (MoM) revenue growth or contraction.

**Solution:**
```sql
-- Using the MonthlySales table from C35
WITH MonthlySalesGrowth AS
(
    SELECT 
        SalesMonth,
        TotalSales,
        LAG(TotalSales) OVER (ORDER BY SalesMonth ASC) AS PreviousMonthSales
    FROM #MonthlySales
)
SELECT 
    SalesMonth,
    TotalSales,
    PreviousMonthSales,
    (TotalSales - PreviousMonthSales) AS AbsoluteVariance,
    CAST(
        ((TotalSales - PreviousMonthSales) * 100.0) / NULLIF(PreviousMonthSales, 0)
        AS DECIMAL(6,2)
    ) AS MoMGrowthPercentage
FROM MonthlySalesGrowth
ORDER BY SalesMonth ASC;
```

**Output:**

| SalesMonth | TotalSales | PreviousMonthSales | AbsoluteVariance | MoMGrowthPercentage |
|---|---|---|---|---|
| 2026-01-01 | 150000.00 | NULL | NULL | NULL |
| 2026-02-01 | 180000.00 | 150000.00 | 30000.00 | 20.00 |
| 2026-03-01 | 220000.00 | 180000.00 | 40000.00 | 22.22 |
| 2026-04-01 | 190000.00 | 220000.00 | -30000.00 | -13.64 |

**7-yr insight:** Always wrap the denominator in `NULLIF(PreviousMonthSales, 0)`! If a previous month had zero sales, `NULLIF` cleanly returns `NULL` rather than crashing the query with a divide-by-zero runtime error (Error 8134).

---

# Section 4: SQL Server Practical Performance Challenges

### P1. Query Returning 100 Million Records

**What interviewer expects:** Pagination, filtering, batching, streaming, avoiding client memory crashes.

**Real-world story:** A developer wrote `SELECT * FROM Attendance` in a microservice without pagination. The application threw an `OutOfMemoryException`, and the database suffered from massive `ASYNC_NETWORK_IO` waits, bringing down other services.

**How I diagnose:**
- Check for `ASYNC_NETWORK_IO` wait types in `sys.dm_os_wait_stats`.
- Check if client application memory is spiking.

**How I fix:**
1. **Mandate Keyset Pagination:** Replace unbounded queries with seek-based pagination:
   ```sql
   SELECT TOP (50) EmployeeId, AttendanceDate, Status
   FROM dbo.EmployeeAttendance
   WHERE Id > @LastSeenId
   ORDER BY Id ASC;
   ```
2. **Stream in .NET:** If exporting a full dataset, never buffer into `List<T>`. Use Dapper's unbuffered stream or `SqlDataReader` with `CommandBehavior.SequentialAccess`:
   ```csharp
   // Dapper unbuffered streaming:
   var rows = connection.Query<AttendanceDto>(sql, buffered: false);
   foreach (var row in rows) { await csvWriter.WriteRecordAsync(row); }
   ```

**Interview answer (7 yrs experience):** "Returning 100 million records to an application is almost always an architectural defect. In our HRMS export module, a user attempted to dump 5 years of attendance logs. This pinned SQL Server threads on `ASYNC_NETWORK_IO` while the .NET API crashed with an `OutOfMemoryException`. I remediated this in two ways: For UI grids, I mandated Keyset Pagination (`WHERE Id > @LastSeenId`). For bulk CSV exports, I set `buffered: false` in Dapper so rows are streamed directly to the HTTP response stream without ever materializing into memory. On the SQL side, I created a covering index aligned with the seek key so zero base table lookups occur."

---

### P2. Stored Procedure Running Slowly

**What interviewer expects:** Execution plan analysis, statistics freshness, indexing, parameter sniffing.

**Real-world story:** A payroll calculation procedure that typically takes 3 seconds suddenly took 2 minutes during month-end payroll processing.

**How I diagnose:**
```sql
-- 1. Check runtime stats and logical reads
SET STATISTICS IO ON;
SET STATISTICS TIME ON;
EXEC dbo.usp_CalculateMonthlyPayroll @YearMonth = 202610;

-- 2. Inspect plan warnings in Query Store
SELECT q.query_id, p.plan_id, rs.avg_duration/1000.0 AS DurationMs, rs.avg_logical_io_reads
FROM sys.query_store_query q
JOIN sys.query_store_plan p ON q.query_id = p.query_id
JOIN sys.query_store_runtime_stats rs ON p.plan_id = rs.plan_id
WHERE q.object_id = OBJECT_ID('dbo.usp_CalculateMonthlyPayroll');
```

**How I fix:**
- Check if Actual rows $\gg$ Estimated rows (stale statistics $\rightarrow$ `UPDATE STATISTICS WITH FULLSCAN`).
- Eliminate Key Lookups by creating covering indexes with `INCLUDE`.
- Check if parameter sniffing occurred $\rightarrow$ add `OPTION (RECOMPILE)` or force stable plan in Query Store.

**Interview answer (7 yrs experience):** "When a stored procedure runs slowly, I never guess or blindly add indexes. I immediately check Query Store to see when the regression started and whether the execution plan changed. I examine the Actual Execution Plan comparing Estimated vs Actual rows: a 10x discrepancy indicates stale statistics or non-SARGable predicates. I look for yellow warning triangles indicating TempDB spills due to inadequate memory grants. If the plan flipped from an index seek to a clustered index scan due to parameter sniffing, I temporarily force the good plan in Query Store for an instant fix, then refactor the procedure with `OPTIMIZE FOR` or a covering index."

---

### P3. Deadlock in Production

**What interviewer expects:** Deadlock graph analysis, lock order standardization, transaction duration reduction, error handling.

**Real-world story:** Two background jobs updating `Employee` and `Department` concurrently encountered Deadlock Error 1205 during peak hours.

**How I diagnose:**
```sql
-- Extract deadlock graph XML from system_health default extended event session
SELECT 
    XEvent.value('(event/@timestamp)[1]', 'DATETIME2') AS DeadlockTime,
    XEvent.query('(event/data[@name="xml_report"]/value/deadlock)[1]') AS DeadlockGraph
FROM (
    SELECT CAST(target_data AS XML) AS TargetData
    FROM sys.dm_xe_session_targets st
    JOIN sys.dm_xe_sessions s ON s.address = st.event_session_address
    WHERE s.name = 'system_health' AND st.target_name = 'ring_buffer'
) AS Data
CROSS APPLY TargetData.nodes('RingBufferTarget/event[@name="xml_deadlock_report"]') AS XEventNode(XEvent);
```

**How I fix:**
1. **Enforce Consistent Lock Order:** Always update `Department` first, then `Employee` across all procedures.
2. **Shorten Transactions:** Move HTTP calls and logging outside the `BEGIN TRAN ... COMMIT`.
3. **Use `UPDLOCK`:** Acquire update locks early during the read phase to serialize access cleanly.

**Interview answer (7 yrs experience):** "When deadlocks hit production, my first step is extracting the deadlock XML graph from the built-in `system_health` Extended Events session. The graph shows the two victim and survivor SPIDs, the competing SQL statements, and the locked resources. In 90% of cases, deadlocks are caused by mismatched object access orders—Procedure A updates Table 1 then Table 2, while Procedure B updates Table 2 then Table 1. I enforce an identical access order across all stored procedures. If deadlocks are caused by read-then-update race conditions, I add `WITH (UPDLOCK, HOLDLOCK)` during the initial read. On the .NET application side, I implement Polly retry policies catching `SqlException` Error 1205 with exponential backoff."

---

### P4. Duplicate Records

**What interviewer expects:** Data cleansing via `ROW_NUMBER()`, constraints, preventing concurrency race conditions.

**Real-world story:** An e-commerce system inserted duplicate order payments when a user double-clicked 'Submit', because the check-then-insert code was not thread-safe.

**How I diagnose & fix:**
```sql
-- 1. Identify and purge existing duplicates safely
WITH Dups AS
(
    SELECT Id, ROW_NUMBER() OVER (PARTITION BY PaymentReference ORDER BY Id ASC) AS Rn
    FROM dbo.Payments
)
DELETE FROM Dups WHERE Rn > 1;

-- 2. Permanent Schema Constraint
ALTER TABLE dbo.Payments ADD CONSTRAINT UQ_Payment_Reference UNIQUE (PaymentReference);
```

**Interview answer (7 yrs experience):** "I treat duplicate records as both a data-cleaning and a concurrency-prevention challenge. To clean existing duplicates, I use a CTE with `ROW_NUMBER() OVER (PARTITION BY NaturalKey ORDER BY CreatedDate ASC)` and delete rows where `Rn > 1`. But cleaning alone is useless without preventing recurrence. In application code, the check-then-insert pattern (`IF NOT EXISTS ... INSERT`) has a race condition under concurrency. I resolve this by placing a unique constraint or unique index directly on the business key at the database level. For concurrent inserts, I use `UPDLOCK, SERIALIZABLE` hints or handle duplicate key violation Error 2627 gracefully in C#."

---

### P5. Large Data Deletion

**What interviewer expects:** Batch deletion, archiving, log management, partition switching.

**Real-world story:** Deleting 20 million audit logs in a single query locked the audit table for 45 minutes, exhausted the transaction log disk, and crashed SQL Server.

**How I fix:**
```sql
-- Batch deletion with delay
WHILE 1 = 1
BEGIN
    DELETE TOP (5000) FROM dbo.AuditLog WHERE CreatedDate < '2023-01-01';
    IF @@ROWCOUNT < 5000 BREAK;
    WAITFOR DELAY '00:00:00.200';
END;
```

**Interview answer (7 yrs experience):** "A single `DELETE` statement for millions of rows will escalate to an Exclusive Table Lock (`LCK_M_X`), saturate the transaction log disk, and cause an hours-long rollback if canceled. In our HRMS, we delete in batches of 5,000 rows with a 200ms `WAITFOR DELAY` between iterations. This prevents lock escalation, keeps individual transactions sub-second, and allows regular transaction log backups to truncate the log smoothly. For massive multi-million row tables partitioned by date, I bypass DML deletion entirely and use **Partition Switching**: I switch the historical partition out to an empty staging table and truncate the staging table in 10 milliseconds with zero transaction logging overhead."

---

### P6. Parameter Sniffing

**What interviewer expects:** Query Store, recompilation, plan analysis, `OPTIMIZE FOR`.

**Real-world story:** An HR department search ran in 10ms for Department 3 (10 rows) but timed out at 60s for Department 1 (200,000 rows) due to plan cache reuse.

**How I diagnose & fix:**
```sql
-- Fix with OPTION (OPTIMIZE FOR UNKNOWN) or OPTION (RECOMPILE)
SELECT EmployeeId, EmployeeName FROM dbo.Employee
WHERE DepartmentId = @DeptId
OPTION (OPTIMIZE FOR UNKNOWN);
```

**Interview answer (7 yrs experience):** "Parameter sniffing occurs when SQL Server creates an execution plan based on the first parameter passed after cache compilation, which turns toxic when data distribution is skewed. I identify it by comparing `ParameterCompiledValue` with `ParameterRuntimeValue` in Query Store. For reporting or infrequent queries with wildly variable filters, I add `OPTION (RECOMPILE)`. For high-throughput OLTP calls where CPU compilation overhead must be avoided, I use `OPTION (OPTIMIZE FOR UNKNOWN)` or copy the parameter to a local variable to force average density calculations. If an immediate production fix is required with zero code deployment, I use Query Store to force a known stable plan."

---

### P7. Slow JOIN Operations

**What interviewer expects:** Indexing join keys, cardinality estimation, join strategy understanding (Nested Loops vs Hash Match vs Merge Join).

**Real-world story:** A query joining `Employee` to `Attendance` suffered from a Nested Loops join running 5 million iterations because an index was missing on the foreign key.

**Join Strategy Guide:**
| Join Operator | When It Excels | Common Problem |
|---|---|---|
| **Nested Loops** | Small outer set seeking into indexed inner set | Disastrous if outer set is unexpectedly large |
| **Hash Match** | Large unsorted sets | High memory grant; spills to TempDB |
| **Merge Join** | Both inputs sorted on join key | Requires expensive sort if no index exists |

**How I diagnose & fix:**
```sql
-- Ensure Foreign Key is indexed!
CREATE NONCLUSTERED INDEX IX_Attendance_EmployeeId 
ON dbo.EmployeeAttendance (EmployeeId) 
INCLUDE (AttendanceDate, Status);
```

**Interview answer (7 yrs experience):** "When joins are slow, I examine the physical join operator chosen by the optimizer. A Nested Loops join is fantastic when the outer input is small and seeks into an indexed inner table; but if cardinality is miscalculated and 1 million rows enter the loop, performance collapses. Hash Joins handle massive unsorted sets well, but require memory grants that spill to TempDB if memory is insufficient. Merge Joins are the fastest for large inputs, but require both sides to be pre-sorted. In production, 80% of slow joins are solved simply by indexing the foreign key column on the child table with appropriate `INCLUDE` columns to eliminate key lookups."

---

### P8. High Database CPU

**What interviewer expects:** Query Store, expensive queries, compilation vs execution CPU, missing indexes, parallelism.

**Real-world story:** SQL Server CPU spiked to 98%, causing API timeouts across the entire platform.

**How I diagnose:**
```sql
-- Top 5 CPU-consuming queries across the entire server
SELECT TOP 5
    qs.total_worker_time / 1000.0 AS TotalCpuMs,
    qs.execution_count,
    (qs.total_worker_time / qs.execution_count) / 1000.0 AS AvgCpuMs,
    st.text AS QueryText
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) st
ORDER BY qs.total_worker_time DESC;
```

**How I fix:**
- Identify if CPU is spent on **compilation** (ad-hoc dynamic SQL without parameterization $\rightarrow$ enable 'Optimize for Ad hoc Workloads') or **execution** (scans, large sorts, scalar UDFs).
- Eliminate non-SARGable scalar functions wrapping columns.
- Adjust `MAXDOP` and `Cost Threshold for Parallelism` (default threshold of 5 is far too low; set to 50).

**Interview answer (7 yrs experience):** "When database CPU spikes to 100%, I first determine whether CPU is consumed by execution or query compilation. If `sys.dm_os_wait_stats` shows high `SOS_SCHEDULER_YIELD` or `CXPACKET`, I query `sys.dm_exec_query_stats` ordered by `total_worker_time`. The most frequent culprits are non-SARGable scalar functions executed row-by-row, implicit conversions (`VARCHAR` vs `NVARCHAR`), missing indexes forcing full table scans, or ad-hoc query plan cache bloat. In our cluster, enabling 'Optimize for Ad hoc Workloads' and adjusting `Cost Threshold for Parallelism` from 5 to 50 stopped small OLTP queries from triggering unnecessary multi-threaded parallelism, cutting overall CPU by 35%."

---

### P9. High TempDB Usage

**What interviewer expects:** TempDB spills, temporary objects, version store bloat, PFS/GAM latch contention.

**Real-world story:** TempDB disk space reached 99%, causing all user transactions to halt with 'Could not allocate space for object in database tempdb'.

**How I diagnose:**
```sql
-- Check what is consuming TempDB space: Internal objects vs User objects vs Version store
SELECT 
    SUM(user_object_reserved_page_count) * 8 / 1024.0 AS UserObjectsMB,
    SUM(internal_object_reserved_page_count) * 8 / 1024.0 AS InternalObjectsMB,
    SUM(version_store_reserved_page_count) * 8 / 1024.0 AS VersionStoreMB
FROM sys.dm_db_file_space_usage;
```

**How I fix:**
- **User Objects:** Replace large un-indexed `#temp` tables with set-based logic, or explicitly drop them when finished.
- **Internal Spills:** Increase memory grants or optimize queries with sort/hash spills.
- **Version Store:** Check for long-running uncommitted transactions holding the RCSI snapshot version store.

**Interview answer (7 yrs experience):** "TempDB space exhaustion usually falls into one of three buckets: First, **Version Store bloat** under RCSI or Snapshot Isolation, caused by an orphaned open transaction preventing version cleanup. Second, **Internal Object spills**: large Hash Match joins or Sort operations that received undersized memory grants and spilled millions of rows to TempDB worktables. Third, **User Objects**: developers populating massive `#temp` tables inside loops without dropping them. I inspect `sys.dm_db_file_space_usage` to identify the consumer. Architecturally, we configure TempDB with 8 equally sized data files on local PCIe NVMe storage and configure autogrowth in 1 GB chunks to prevent allocation contention."

---

### P10. Blocking Queries

**What interviewer expects:** DMVs (`sys.dm_exec_requests`), lock analysis, isolation levels (RCSI), lead blocker detection.

**Real-world story:** A slow monthly financial report acquired shared locks on the `Employee` table, blocking HR users from updating employee records for 15 minutes.

**How I diagnose:**
```sql
-- Identify the Lead Blocker in real-time
SELECT 
    r.session_id AS BlockedSession,
    r.blocking_session_id AS BlockerSession,
    r.wait_type,
    r.wait_time / 1000.0 AS WaitTimeSec,
    st.text AS BlockedSQL,
    blocker_st.text AS BlockerSQL
FROM sys.dm_exec_requests r
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) st
JOIN sys.dm_exec_connections c ON r.blocking_session_id = c.session_id
CROSS APPLY sys.dm_exec_sql_text(c.most_recent_sql_handle) blocker_st
WHERE r.blocking_session_id != 0;
```

**How I fix:**
- Enable **Read Committed Snapshot Isolation (RCSI)**: Readers do not block writers, and writers do not block readers!
- Shorten transactions and move non-database work outside `BEGIN TRAN`.
- Ensure indexes exist on filter columns to prevent row updates from locking the entire table.

**Interview answer (7 yrs experience):** "Blocking is normal in relational databases, but prolonged blocking destroys application responsiveness. When blocking alerts trigger, I immediately query `sys.dm_exec_requests` to trace the blocking chain back to the root lead blocker (the session where `blocking_session_id = 0` but is blocking others). Often, the lead blocker is an uncommitted transaction where the client application threw an unhandled exception or is waiting on an external HTTP call. The permanent architectural fix for reader-writer blocking is enabling **Read Committed Snapshot Isolation (RCSI)** at the database level: readers fetch row versions from TempDB without acquiring shared locks, allowing concurrent `SELECT` reports and `UPDATE` transactions to run simultaneously without interference."

---

## Final Interview Tips for 7 Years Experience

- [ ] **Frame Every Answer with the STAR-T Method:** Situation, Task, Action, Result, and Trade-off.
- [ ] **Talk Architecture, Not Just Syntax:** Differentiate between Relational Engine (optimization) and Storage Engine (buffer pool, logging, locking).
- [ ] **Lead with Metrics:** Quote specific metrics—'reduced logical reads from 2,000,000 to 450', 'dropped execution time from 40s to 80ms', 'lowered TempDB spills'.
- [ ] **Champion Modern Features:** Highlight Query Store plan forcing, Temporal Tables, RCSI, Keyset Pagination, and Table-Valued Parameters (TVPs).
- [ ] **Address Trade-offs Candidly:** Acknowledge that every non-clustered index adds an INSERT/UPDATE write tax, and RCSI shifts locking overhead to TempDB version stores.
- [ ] **Connect SQL with .NET Core:** Explain Dapper parameter typing (`DbType.AnsiString` to avoid implicit conversions), connection pooling lifecycle, and Polly deadlock retry policies.
