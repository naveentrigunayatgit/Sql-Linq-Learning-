# Section 1 (A & B): Database Fundamentals, Normalization, Indexing & Query Performance

> Sample tables used throughout:
> `Employee(EmployeeId, EmployeeName, DepartmentId, ManagerId, Salary, JoiningDate)`, `Department(DepartmentId, DepartmentName)`, `EmployeeSalaryHistory(Id, EmployeeId, Salary, EffectiveDate)`, `EmployeeAttendance(Id, EmployeeId, AttendanceDate, Status)`

## Table of Contents

**A. Database Fundamentals and Normalization**
- [Q1. What is Normalization? Explain all normal forms](#q1-what-is-normalization-explain-all-normal-forms-with-examples)
- [Q2. What is 1NF, 2NF, 3NF and BCNF?](#q2-what-is-1nf-2nf-3nf-and-bcnf)
- [Q3. What is BCNF?](#q3-what-is-boyce-codd-normal-form-bcnf)
- [Q4. What is Denormalization?](#q4-what-is-denormalization-when-would-you-use-it)
- [Q5. OLTP vs OLAP](#q5-what-is-the-difference-between-oltp-and-olap)
- [Q6. Primary Key vs Unique Key vs Foreign Key](#q6-what-is-the-difference-between-a-primary-key-unique-key-and-foreign-key)
- [Q7. Candidate vs Composite vs Alternate Key](#q7-what-is-the-difference-between-candidate-key-composite-key-and-alternate-key)
- [Q8. Referential Integrity](#q8-what-is-referential-integrity)
- [Q9. Constraints](#q9-what-are-constraints-in-sql-server-explain-all-types)
- [Q10. CHAR vs VARCHAR vs NCHAR vs NVARCHAR](#q10-what-is-the-difference-between-char-varchar-nchar-and-nvarchar)
- [Q11. VARCHAR(MAX) vs VARCHAR(8000)](#q11-what-is-the-difference-between-varcharmax-and-varchar8000)
- [Q12. NULL vs 0 vs empty string](#q12-what-is-the-difference-between-null-0-and-an-empty-string)
- [Q13. Schema](#q13-what-is-a-schema-in-sql-server)
- [Q14. Table vs View](#q14-what-is-the-difference-between-a-table-and-a-view)
- [Q15. Materialized View](#q15-what-is-a-materialized-view-does-sql-server-support-it-directly)

**B. Indexing and Query Performance**
- [Q16. What are Indexes?](#q16-what-are-indexes-in-sql-server-why-are-they-required)
- [Q17. Clustered vs Non-Clustered](#q17-explain-clustered-vs-non-clustered-index)
- [Q18. Multiple clustered indexes?](#q18-can-a-table-have-multiple-clustered-indexes-why)
- [Q19. How many non-clustered indexes?](#q19-how-many-non-clustered-indexes-can-a-table-have)
- [Q20. Composite Index](#q20-what-is-a-composite-index)
- [Q21. Covering Index](#q21-what-is-a-covering-index)
- [Q22. Included Column](#q22-what-is-an-included-column-in-an-index)
- [Q23. Unique Index](#q23-what-is-a-unique-index)
- [Q24. Filtered Index](#q24-what-is-a-filtered-index)
- [Q25. Columnstore Index](#q25-what-is-a-columnstore-index)
- [Q26. Heap Table](#q26-what-is-a-heap-table)
- [Q27. Index Fragmentation](#q27-what-is-index-fragmentation)
- [Q28. Rebuild vs Reorganize](#q28-what-is-the-difference-between-index-rebuild-and-index-reorganize)
- [Q29. Seek vs Scan vs Table Scan](#q29-what-is-index-seek-vs-index-scan-vs-table-scan)
- [Q30. SARGable query](#q30-what-is-a-sargable-query)
- [Q31. Key Lookup](#q31-what-is-a-key-lookup-how-can-you-avoid-it)
- [Q32. Missing Index Recommendation](#q32-what-is-a-missing-index-recommendation)
- [Q33. Too many indexes and DML](#q33-can-creating-too-many-indexes-affect-insert-update-and-delete-performance)
- [Q34. Statistics](#q34-what-is-statistics-in-sql-server)
- [Q35. Execution Plan: Actual vs Estimated](#q35-what-is-an-execution-plan-explain-actual-vs-estimated-execution-plan)

---

# A. Database Fundamentals and Normalization

### Q1. What is Normalization? Explain all normal forms with examples.

**Definition:** Normalization is the process of organizing tables so that each fact is stored only once. It removes duplicate data and prevents insert, update and delete anomalies by splitting big tables into smaller related tables.

**Real-world example:** Think of an HR office that writes the department name and department head on every employee's paper file. If the department head changes, someone must update 500 files. Normalization says: keep one "Department" register and just write the department number on each employee file.

**Normal forms at a glance:**

| Normal Form | Rule (simple English) | Removes |
|---|---|---|
| 1NF | Atomic values, no repeating groups, each row unique | Multi-valued columns (e.g., "Phone1, Phone2" or "a,b,c" lists) |
| 2NF | 1NF + every non-key column depends on the **whole** key | Partial dependency (on part of composite key) |
| 3NF | 2NF + no non-key column depends on another non-key column | Transitive dependency |
| BCNF | Every determinant must be a candidate key | Remaining anomalies 3NF misses |
| 4NF | No multi-valued dependencies (independent lists in one table) | e.g., Employee-Skills and Employee-Languages in one table |
| 5NF | No join dependency; table can't be split further without loss | Rare, complex many-to-many-to-many cases |

**SQL example:**
```sql
-- UNNORMALIZED: repeating values, department info duplicated
-- EmpId | EmpName | DeptName | DeptHead | Phones
-- 1     | Ravi    | HR       | Meena    | 98111,98222
-- 2     | Anil    | HR       | Meena    | 98333

-- NORMALIZED (3NF)
CREATE TABLE Department (
    DepartmentId   INT IDENTITY PRIMARY KEY,
    DepartmentName NVARCHAR(100) NOT NULL
);

CREATE TABLE Employee (
    EmployeeId   INT IDENTITY PRIMARY KEY,
    EmployeeName NVARCHAR(100) NOT NULL,
    DepartmentId INT NOT NULL REFERENCES Department(DepartmentId),
    ManagerId    INT NULL REFERENCES Employee(EmployeeId),
    Salary       DECIMAL(18,2) NOT NULL,
    JoiningDate  DATE NOT NULL
);

CREATE TABLE EmployeePhone (
    EmployeeId INT REFERENCES Employee(EmployeeId),
    Phone      VARCHAR(15),
    PRIMARY KEY (EmployeeId, Phone)
);
```

**Interview answer (7 yrs experience):** "Normalization is about storing each fact in exactly one place so we avoid update, insert and delete anomalies. In practice, I normalize transactional schemas to 3NF by default — in our HRMS, Employee, Department, Designation and Location are all separate master tables, and the Employee table only holds foreign keys. That saved us real pain when departments got renamed during a re-org: one row update instead of thousands. BCNF I apply when I see overlapping candidate keys; 4NF and 5NF rarely come up, but 4NF shows up when someone tries to store skills and certifications in the same table. The trade-off is more joins, so for reporting tables or read-heavy dashboards I deliberately denormalize. My rule is: normalize for writes and correctness, denormalize consciously for reads."

**Follow-up / Pro tip:**
- Remember the classic line: "The key, the whole key, and nothing but the key" = 1NF, 2NF, 3NF.
- Storing comma-separated values (e.g., `RoleIds = '1,4,7'`) violates 1NF and kills indexing — a very common interview red flag.

---

### Q2. What is 1NF, 2NF, 3NF and BCNF?

**Definition:**
- **1NF:** Each column holds a single (atomic) value, no repeating groups, and each row is uniquely identifiable.
- **2NF:** In 1NF, and no non-key column depends on only part of a composite primary key.
- **3NF:** In 2NF, and no non-key column depends on another non-key column (no transitive dependency).
- **BCNF:** A stricter 3NF — every column that determines another column must be a candidate key.

**Real-world example:** A school attendance register: 1NF = one student per line, one date per column cell; 2NF = don't repeat student address on every attendance line (it depends only on the student, not student+date); 3NF = don't store the class teacher's phone on student rows (it depends on the teacher, not the student).

**SQL example:**
```sql
-- Violates 1NF
-- EmployeeId | Skills
-- 1          | 'C#, SQL, Azure'

-- Violates 2NF: PK = (EmployeeId, AttendanceDate); EmployeeName depends only on EmployeeId
-- EmployeeAttendance(EmployeeId, AttendanceDate, Status, EmployeeName)

-- Fix for 2NF: move EmployeeName to Employee table
CREATE TABLE EmployeeAttendance (
    Id             BIGINT IDENTITY PRIMARY KEY,
    EmployeeId     INT NOT NULL REFERENCES Employee(EmployeeId),
    AttendanceDate DATE NOT NULL,
    Status         CHAR(1) NOT NULL,   -- P / A / L
    CONSTRAINT UQ_Attendance UNIQUE (EmployeeId, AttendanceDate)
);

-- Violates 3NF: DepartmentName depends on DepartmentId (non-key), not on EmployeeId
-- Employee(EmployeeId, EmployeeName, DepartmentId, DepartmentName)
-- Fix: keep DepartmentName only in Department table.
```

| Form | Question to ask | Example violation |
|---|---|---|
| 1NF | Is every cell a single value? | `Skills = 'C#,SQL'` |
| 2NF | Does every non-key column need the *full* composite key? | `EmployeeName` in Attendance keyed by (EmpId, Date) |
| 3NF | Does any non-key column depend on another non-key column? | `DepartmentName` in Employee |
| BCNF | Is every determinant a candidate key? | See Q3 |

**Interview answer (7 yrs experience):** "1NF is atomic values, 2NF removes partial dependency on a composite key, 3NF removes transitive dependency, and BCNF says every determinant must be a candidate key. A real example from our HRMS: an early attendance table had the composite key EmployeeId + AttendanceDate but also carried EmployeeName and DepartmentName for 'convenience'. When an employee transferred, old attendance rows showed the wrong department in some reports and correct in others — classic anomaly. We moved those columns out and joined to Employee instead. 2NF only matters when you have a composite key; with a surrogate IDENTITY key, people think they're safe, but the logical dependency still exists, so I check the natural key too."

**Follow-up / Pro tip:**
- A table with a single-column primary key that is in 1NF is automatically in 2NF.

---

### Q3. What is Boyce-Codd Normal Form (BCNF)?

**Definition:** BCNF is a stronger version of 3NF. A table is in BCNF if, for every functional dependency X → Y, X is a candidate key (a super key). It fixes rare cases where 3NF still allows anomalies, usually with overlapping composite candidate keys.

**Real-world example:** In a training institute, each trainer teaches only one course, but a course can have many trainers. If you store (Student, Course, Trainer), "Trainer → Course" is a dependency where Trainer is not a key — so if a trainer switches course you must update many rows.

**SQL example:**
```sql
-- Violates BCNF
-- EmployeeTraining(EmployeeId, CourseName, TrainerName)
-- Candidate key: (EmployeeId, CourseName)
-- But TrainerName -> CourseName  (TrainerName is not a candidate key)

-- BCNF decomposition
CREATE TABLE Trainer (
    TrainerId   INT PRIMARY KEY,
    TrainerName NVARCHAR(100) NOT NULL,
    CourseName  NVARCHAR(100) NOT NULL       -- Trainer determines course
);

CREATE TABLE EmployeeTraining (
    EmployeeId INT REFERENCES Employee(EmployeeId),
    TrainerId  INT REFERENCES Trainer(TrainerId),
    PRIMARY KEY (EmployeeId, TrainerId)
);
```

**Interview answer (7 yrs experience):** "BCNF says every determinant must be a candidate key. 3NF allows a non-key attribute to be determined by a key attribute; BCNF does not. Honestly, in most OLTP designs, if you're in 3NF with surrogate keys you're usually in BCNF too. Where I've seen it matter is in mapping tables — in our HRMS training module, trainer determined the course, so storing employee-course-trainer in one table caused update anomalies when a trainer was reassigned. Splitting it into Trainer and EmployeeTraining fixed that. The trade-off is that BCNF decomposition can sometimes lose the ability to enforce a dependency with a simple constraint, so occasionally 3NF is the pragmatic stop."

**Follow-up / Pro tip:**
- Every BCNF table is in 3NF, but not every 3NF table is in BCNF.

---

### Q4. What is Denormalization? When would you use it?

**Definition:** Denormalization is intentionally adding redundant data (or merging tables) to reduce joins and speed up reads. It trades extra storage and write complexity for faster queries.

**Real-world example:** An e-commerce order stores the product price and name *at the time of order*, even though the product table has them. It's faster to show the invoice, and the order must not change when the product price changes later.

**SQL example:**
```sql
-- Reporting table for a payroll dashboard (denormalized)
CREATE TABLE rpt.EmployeeMonthlySummary (
    EmployeeId      INT,
    EmployeeName    NVARCHAR(100),  -- duplicated from Employee
    DepartmentName  NVARCHAR(100),  -- duplicated from Department
    [Month]         DATE,
    PresentDays     INT,
    AbsentDays      INT,
    Salary          DECIMAL(18,2),
    PRIMARY KEY (EmployeeId, [Month])
);

-- Populated nightly by a job
INSERT INTO rpt.EmployeeMonthlySummary
SELECT e.EmployeeId, e.EmployeeName, d.DepartmentName,
       DATEFROMPARTS(YEAR(a.AttendanceDate), MONTH(a.AttendanceDate), 1),
       SUM(CASE WHEN a.Status = 'P' THEN 1 ELSE 0 END),
       SUM(CASE WHEN a.Status = 'A' THEN 1 ELSE 0 END),
       e.Salary
FROM Employee e
JOIN Department d ON d.DepartmentId = e.DepartmentId
JOIN EmployeeAttendance a ON a.EmployeeId = e.EmployeeId
GROUP BY e.EmployeeId, e.EmployeeName, d.DepartmentName,
         DATEFROMPARTS(YEAR(a.AttendanceDate), MONTH(a.AttendanceDate), 1), e.Salary;
```

**When to use:** read-heavy reports/dashboards, data warehouses (star schema), historical snapshots (invoice/payslip values), computed totals that are expensive to recalculate.

**Interview answer (7 yrs experience):** "Denormalization is a deliberate decision to duplicate data for read performance. In our HRMS, the payslip table stores the employee name, designation, department and every salary component as they were in that month — that's not just performance, it's a legal requirement because a payslip must not change if the employee gets promoted later. We also had a monthly attendance summary table refreshed by a SQL Agent job, which took the dashboard from 8 seconds to under 200 ms. The risk is data drift, so I always define one source of truth and a clear refresh mechanism — triggers, jobs, or application-level updates in the same transaction. I avoid denormalizing the core OLTP tables unless profiling proves the join is the bottleneck."

**Follow-up / Pro tip:**
- Alternatives before denormalizing: proper indexes, indexed views, computed persisted columns, or a read replica.

---

### Q5. What is the difference between OLTP and OLAP?

**Definition:** OLTP (Online Transaction Processing) systems handle many small, fast insert/update/delete operations for day-to-day business. OLAP (Online Analytical Processing) systems handle large, complex read queries over historical data for reporting and analysis.

**Real-world example:** A bank ATM withdrawal is OLTP (one quick transaction). The bank's yearly report "average withdrawal by city by month for 5 years" is OLAP.

| Feature | OLTP | OLAP |
|---|---|---|
| Purpose | Run the business (transactions) | Analyze the business (reports, BI) |
| Operations | Short INSERT/UPDATE/DELETE, point SELECTs | Large aggregations, scans |
| Data | Current, detailed | Historical, summarized |
| Schema | Highly normalized (3NF) | Denormalized (star/snowflake) |
| Indexing | B-tree (rowstore) clustered/non-clustered | Columnstore, partitioning |
| Response time | Milliseconds | Seconds to minutes |
| Users | Thousands of app users | Fewer analysts |
| Example | HRMS leave apply, attendance punch | Attrition trend by department over 5 years |

**SQL example:**
```sql
-- OLTP: mark today's attendance
INSERT INTO EmployeeAttendance (EmployeeId, AttendanceDate, Status)
VALUES (101, CAST(GETDATE() AS DATE), 'P');

-- OLAP: department-wise average salary trend across years
SELECT d.DepartmentName, YEAR(h.EffectiveDate) AS [Year], AVG(h.Salary) AS AvgSalary
FROM EmployeeSalaryHistory h
JOIN Employee e   ON e.EmployeeId = h.EmployeeId
JOIN Department d ON d.DepartmentId = e.DepartmentId
GROUP BY d.DepartmentName, YEAR(h.EffectiveDate);
```

**Interview answer (7 yrs experience):** "OLTP is optimized for many small concurrent writes; OLAP is optimized for big reads over history. In our HRMS, the main database is OLTP — leave requests, attendance punches, payroll runs — normalized and indexed for point lookups via Dapper. When management wanted multi-year attrition and salary analytics, running those queries on the OLTP database caused blocking during payroll. We moved analytics to a separate reporting database populated by ETL, with a star schema and clustered columnstore indexes on the fact tables. That isolated workloads and made reports 10x faster. For lighter needs, I've also used a readable secondary in an Always On availability group or a nonclustered columnstore index for real-time operational analytics."

---

### Q6. What is the difference between a Primary Key, Unique Key and Foreign Key?

**Definition:** A **Primary Key** uniquely identifies each row and cannot be NULL. A **Unique Key** also guarantees uniqueness but allows one NULL (in SQL Server). A **Foreign Key** links a column to the primary/unique key of another table to enforce valid relationships.

**Real-world example:** In a company, Employee ID is the primary key; the official email is a unique key (no two people share it, a new joiner may not have one yet); the Department ID on an employee record is a foreign key pointing to the department list.

| Feature | Primary Key | Unique Key | Foreign Key |
|---|---|---|---|
| Purpose | Identify a row | Prevent duplicates | Link to parent table |
| NULL allowed | No | Yes — only **one** NULL (standard UNIQUE constraint) | Yes (multiple) |
| Count per table | Only 1 | Many | Many |
| Default index | Clustered index (if none exists) | Non-clustered unique index | **No index created automatically** |
| Duplicates | Not allowed | Not allowed | Allowed |

**SQL example:**
```sql
CREATE TABLE Employee (
    EmployeeId    INT IDENTITY(1,1) CONSTRAINT PK_Employee PRIMARY KEY,
    EmployeeName  NVARCHAR(100) NOT NULL,
    OfficialEmail VARCHAR(150) NULL CONSTRAINT UQ_Employee_Email UNIQUE,
    DepartmentId  INT NOT NULL
        CONSTRAINT FK_Employee_Department REFERENCES Department(DepartmentId),
    ManagerId     INT NULL,
    Salary        DECIMAL(18,2),
    JoiningDate   DATE
);

-- Index the foreign key manually (SQL Server doesn't do it for you)
CREATE INDEX IX_Employee_DepartmentId ON Employee(DepartmentId);
```

**Interview answer (7 yrs experience):** "Primary key identifies a row, unique key prevents duplicates on alternate business columns, and foreign key enforces relationships. One pitfall I always mention: a UNIQUE constraint in SQL Server allows only one NULL, so for something like PAN or official email where many employees might not have it yet, we use a filtered unique index `WHERE OfficialEmail IS NOT NULL` instead. Another one: SQL Server doesn't automatically index foreign keys. We had a slow employee delete because the FK check scanned the whole attendance table; adding an index on EmployeeAttendance.EmployeeId fixed it. And PK doesn't have to be clustered — but by default it is, so I choose a narrow, ever-increasing key like INT IDENTITY."

**Follow-up / Pro tip:**
- A foreign key can reference a UNIQUE constraint, not only a PK.

---

### Q7. What is the difference between Candidate Key, Composite Key and Alternate Key?

**Definition:** A **Candidate Key** is any minimal set of columns that can uniquely identify a row. The one chosen becomes the Primary Key; the remaining candidate keys are **Alternate Keys**. A **Composite Key** is any key made of two or more columns.

**Real-world example:** An employee can be uniquely identified by Employee ID, Aadhaar/SSN number, or official email — all are candidate keys. HR picks Employee ID as primary; Aadhaar and email become alternate keys. For attendance, (EmployeeId + Date) together is a composite key.

| Key | Meaning | HRMS example |
|---|---|---|
| Super Key | Any column set that is unique (may have extra columns) | (EmployeeId, EmployeeName) |
| Candidate Key | Minimal unique column set | EmployeeId, NationalId, OfficialEmail |
| Primary Key | The chosen candidate key | EmployeeId |
| Alternate Key | Candidate keys not chosen as PK | NationalId, OfficialEmail |
| Composite Key | Key with 2+ columns | (EmployeeId, AttendanceDate) |
| Surrogate Key | System-generated key with no business meaning | IDENTITY Id |

**SQL example:**
```sql
CREATE TABLE EmployeeAttendance (
    EmployeeId     INT  NOT NULL,
    AttendanceDate DATE NOT NULL,
    Status         CHAR(1) NOT NULL,
    CONSTRAINT PK_EmployeeAttendance PRIMARY KEY (EmployeeId, AttendanceDate)  -- composite key
);

-- Alternate key enforced via UNIQUE
ALTER TABLE Employee ADD NationalId VARCHAR(20) NULL;
CREATE UNIQUE INDEX UX_Employee_NationalId ON Employee(NationalId) WHERE NationalId IS NOT NULL;
```

**Interview answer (7 yrs experience):** "Candidate keys are all the minimal unique identifiers; one becomes the PK and the rest are alternate keys, which I always enforce with unique constraints — otherwise you lose data integrity silently. Composite keys are multi-column keys. In our HRMS, we use surrogate INT IDENTITY primary keys for most tables because they're narrow and stable, which keeps clustered and non-clustered indexes small, and works nicely with Dapper mapping. But we still put a unique constraint on the natural key, like (EmployeeId, AttendanceDate) — that prevented duplicate attendance rows when the biometric device sync retried. Composite PKs are fine for pure mapping tables like EmployeeRole."

---

### Q8. What is Referential Integrity?

**Definition:** Referential integrity means relationships between tables always stay valid — a child row cannot point to a parent row that doesn't exist. SQL Server enforces it with foreign key constraints.

**Real-world example:** A library should not have a borrowing record for a member ID that doesn't exist. And you shouldn't delete a member who still has books checked out.

**SQL example:**
```sql
ALTER TABLE EmployeeAttendance
ADD CONSTRAINT FK_Attendance_Employee
    FOREIGN KEY (EmployeeId) REFERENCES Employee(EmployeeId)
    ON DELETE NO ACTION      -- default: block delete if attendance exists
    ON UPDATE NO ACTION;

-- This fails if EmployeeId 9999 doesn't exist:
INSERT INTO EmployeeAttendance (EmployeeId, AttendanceDate, Status) VALUES (9999, '2024-01-01', 'P');
-- Msg 547: The INSERT statement conflicted with the FOREIGN KEY constraint "FK_Attendance_Employee".
```

| Referential action | Behavior on parent DELETE/UPDATE |
|---|---|
| NO ACTION (default) | Error if child rows exist |
| CASCADE | Delete/update child rows too |
| SET NULL | Set child FK to NULL |
| SET DEFAULT | Set child FK to its default value |

**Interview answer (7 yrs experience):** "Referential integrity guarantees no orphan records, and I enforce it in the database with foreign keys, not only in the C# layer — application checks can be bypassed by scripts, bulk imports or race conditions. In our HRMS we use NO ACTION for most relationships and soft delete (IsActive flag) for employees, because employee history must be kept for compliance. I avoid ON DELETE CASCADE on big tables like attendance since a single delete can lock millions of rows and blow the log. One more pitfall: if someone disables FKs for a bulk load and re-enables them `WITH NOCHECK`, the constraint becomes 'untrusted' and the optimizer can't use it for join elimination — so I always re-enable `WITH CHECK`."

**Follow-up / Pro tip:**
- Check untrusted FKs: `SELECT name FROM sys.foreign_keys WHERE is_not_trusted = 1;`

---

### Q9. What are Constraints in SQL Server? Explain all types.

**Definition:** Constraints are rules on table columns that SQL Server enforces automatically to keep data valid. If data breaks a rule, the statement fails.

**Real-world example:** An HR form that won't let you submit without a name (NOT NULL), won't accept a negative salary (CHECK), auto-fills today's date (DEFAULT), and rejects duplicate employee codes (UNIQUE).

| Constraint | Purpose | Example |
|---|---|---|
| PRIMARY KEY | Unique + NOT NULL row identifier | `EmployeeId` |
| FOREIGN KEY | Valid reference to parent table | `DepartmentId → Department` |
| UNIQUE | No duplicate values | `OfficialEmail` |
| CHECK | Value must satisfy a condition | `Salary > 0` |
| DEFAULT | Value used when none supplied | `JoiningDate DEFAULT GETDATE()` |
| NOT NULL | Column must have a value | `EmployeeName` |

**SQL example:**
```sql
CREATE TABLE Employee (
    EmployeeId    INT IDENTITY CONSTRAINT PK_Employee PRIMARY KEY,
    EmployeeCode  VARCHAR(20) NOT NULL CONSTRAINT UQ_Employee_Code UNIQUE,
    EmployeeName  NVARCHAR(100) NOT NULL,
    DepartmentId  INT NOT NULL CONSTRAINT FK_Employee_Dept REFERENCES Department(DepartmentId),
    ManagerId     INT NULL CONSTRAINT FK_Employee_Manager REFERENCES Employee(EmployeeId),
    Salary        DECIMAL(18,2) NOT NULL CONSTRAINT CK_Employee_Salary CHECK (Salary > 0),
    JoiningDate   DATE NOT NULL CONSTRAINT DF_Employee_JoiningDate DEFAULT (CAST(GETDATE() AS DATE)),
    CONSTRAINT CK_Employee_NotOwnManager CHECK (ManagerId <> EmployeeId)
);

ALTER TABLE EmployeeAttendance
ADD CONSTRAINT CK_Attendance_Status CHECK (Status IN ('P','A','L','H'));
```

**Interview answer (7 yrs experience):** "SQL Server has six main constraints: primary key, foreign key, unique, check, default and not null. I always name them explicitly — like CK_Employee_Salary — because auto-generated names differ across environments and break our migration scripts. In our HRMS, check constraints guard things like attendance status codes and salary ranges, so even a bad bulk import from Excel can't insert garbage. On the .NET side we catch SqlException number 547 (FK/check violation) and 2627/2601 (unique violation) and translate them into friendly messages. Trusted check constraints also help the optimizer skip partitions or tables, so they're not just about validation."

**Follow-up / Pro tip:**
- Avoid scalar UDFs inside CHECK constraints — they run row-by-row and can block parallelism.

---

### Q10. What is the difference between CHAR, VARCHAR, NCHAR and NVARCHAR?

**Definition:** CHAR and NCHAR are fixed-length; VARCHAR and NVARCHAR are variable-length. The "N" types store Unicode (multi-language) text using 2 bytes per character (UTF-16); non-N types use 1 byte per character in a code page (or UTF-8 with a `_UTF8` collation in SQL Server 2019+).

**Real-world example:** CHAR is like a parking slot of fixed size — a bike still takes the whole slot. VARCHAR is like a flexible parking line — each vehicle takes only its length. NVARCHAR is a slot that can fit vehicles from any country (Hindi, Arabic, Chinese names).

| Type | Length | Unicode | Storage | Max | Use for |
|---|---|---|---|---|---|
| CHAR(n) | Fixed (pads spaces) | No | n bytes | 8000 | Fixed codes: `Status CHAR(1)`, country code |
| VARCHAR(n) | Variable | No* | actual + 2 bytes | 8000 / MAX | English-only codes, emails |
| NCHAR(n) | Fixed | Yes | 2 × n bytes | 4000 | Fixed Unicode codes (rare) |
| NVARCHAR(n) | Variable | Yes | 2 × actual + 2 bytes | 4000 / MAX | Names, addresses, multilingual text |

\*VARCHAR can store Unicode with a UTF-8 collation in SQL Server 2019+.

**SQL example:**
```sql
DECLARE @c CHAR(10) = 'Ravi', @v VARCHAR(10) = 'Ravi',
        @nv NVARCHAR(10) = N'रवि', @v2 VARCHAR(10) = 'रवि';

SELECT DATALENGTH(@c) AS CharBytes,    -- 10
       DATALENGTH(@v) AS VarcharBytes, -- 4
       @nv AS NVarcharValue,           -- रवि
       @v2 AS VarcharValue;            -- ??? (data lost without N prefix/Unicode type)
```

| CharBytes | VarcharBytes | NVarcharValue | VarcharValue |
|---|---|---|---|
| 10 | 4 | रवि | ??? |

**Interview answer (7 yrs experience):** "CHAR/NCHAR are fixed-length, VARCHAR/NVARCHAR are variable, and N means Unicode. In our HRMS, employee names and addresses are NVARCHAR because we have employees across regions with native-script names; codes like status, gender, and country are CHAR. A big production pitfall I've fixed: Dapper sends C# strings as NVARCHAR(4000) by default. When the column is VARCHAR, SQL Server has to implicitly convert the column side, which can turn an index seek into a scan. We fixed it by using `new DbString { Value = code, IsAnsi = true, Length = 20 }` or `DynamicParameters` with `DbType.AnsiString`. Also always use the N prefix for Unicode literals, otherwise characters are lost."

**Follow-up / Pro tip:**
- Don't use NVARCHAR everywhere "just in case" — it doubles storage and memory grants for large tables.

---

### Q11. What is the difference between VARCHAR(MAX) and VARCHAR(8000)?

**Definition:** VARCHAR(8000) can store up to 8,000 bytes and is always stored in the data row. VARCHAR(MAX) can store up to 2 GB; values up to 8,000 bytes stay in-row by default, but larger values move to separate LOB pages.

**Real-world example:** VARCHAR(8000) is a filing drawer — fits a lot, but limited. VARCHAR(MAX) is the drawer plus a warehouse: small files stay in the drawer, huge ones go to the warehouse and the drawer just holds a pointer.

| Feature | VARCHAR(8000) | VARCHAR(MAX) |
|---|---|---|
| Max size | 8,000 bytes | 2 GB |
| Storage | In-row (row-overflow if row > 8060) | In-row ≤ 8000 bytes, else LOB pages |
| Can be index key | Yes (up to 1700 bytes for NCI key / 900 clustered) | **No** (only as INCLUDE column) |
| Memory grant estimate | Based on half declared size | Larger estimates, can cause excess grants |
| Online index rebuild | Supported | Supported since SQL 2012 |
| Performance | Faster | Slower for large values, more I/O |

**SQL example:**
```sql
CREATE TABLE EmployeeDocument (
    Id          INT IDENTITY PRIMARY KEY,
    EmployeeId  INT NOT NULL,
    Remarks     VARCHAR(500),      -- short, indexable
    ResumeText  NVARCHAR(MAX)      -- large text, not indexable as key
);

-- Fails: MAX columns can't be index keys
-- CREATE INDEX IX_Doc_Resume ON EmployeeDocument(ResumeText);
-- Msg 1919: Column 'ResumeText' ... is of a type that is invalid for use as a key column in an index.
```

**Interview answer (7 yrs experience):** "VARCHAR(8000) is limited to 8,000 bytes and stays in the row; VARCHAR(MAX) goes up to 2 GB and moves big values off-row. I only use MAX when the data genuinely can exceed 8,000 bytes — like JSON payloads, audit logs or resume text. In one code review I found every string column in a new module declared as NVARCHAR(MAX) because Entity Framework migrations defaulted it; we couldn't index them, and memory grants for sorts were huge. We right-sized them to realistic lengths. Also, in Dapper, passing a string longer than 4,000 characters gets sent as NVARCHAR(MAX), which is fine, but mismatched sizes cause plan cache bloat, so I specify parameter lengths."

---

### Q12. What is the difference between NULL, 0 and an empty string?

**Definition:** NULL means "unknown or missing value". 0 is a known numeric value (zero). An empty string `''` is a known text value with zero characters. NULL is not equal to anything, not even another NULL.

**Real-world example:** On a leave form: "Bonus = 0" means no bonus; "Bonus = NULL" means it hasn't been decided yet; "Middle name = ''" means the person has no middle name; "Middle name = NULL" means we don't know.

| Value | Meaning | `= NULL` works? | Counted by `COUNT(col)` | In `SUM/AVG` |
|---|---|---|---|---|
| NULL | Unknown/missing | No — use `IS NULL` | No | Ignored |
| 0 | Numeric zero | Yes | Yes | Included |
| '' | Empty text | Yes | Yes | N/A |

**SQL example:**
```sql
-- Bonus: 1000, 0, NULL
SELECT COUNT(*) AS AllRows, COUNT(Bonus) AS NonNullRows,
       AVG(Bonus) AS AvgIgnoringNull, AVG(ISNULL(Bonus,0)) AS AvgTreatingNullAsZero
FROM (VALUES (1000),(0),(NULL)) t(Bonus);
```

| AllRows | NonNullRows | AvgIgnoringNull | AvgTreatingNullAsZero |
|---|---|---|---|
| 3 | 2 | 500 | 333 |

```sql
-- Common bug
SELECT * FROM Employee WHERE ManagerId = NULL;   -- returns nothing
SELECT * FROM Employee WHERE ManagerId IS NULL;  -- correct: top-level managers

-- NOT IN with NULL returns no rows!
SELECT * FROM Employee WHERE EmployeeId NOT IN (SELECT ManagerId FROM Employee); -- empty if any ManagerId is NULL
SELECT * FROM Employee e WHERE NOT EXISTS (SELECT 1 FROM Employee m WHERE m.ManagerId = e.EmployeeId); -- safe
```

**Interview answer (7 yrs experience):** "NULL is unknown, 0 is a number, and empty string is a known blank text. NULL uses three-valued logic, so `= NULL` never matches and aggregates silently ignore it. A real bug I fixed in our payroll: average incentive per department was overstated because employees with no incentive had NULL instead of 0, so AVG ignored them. Another classic one is NOT IN against a subquery containing NULL returning zero rows — I default to NOT EXISTS. On the .NET side, Dapper maps NULL to `null` so nullable columns must map to `int?`/`DateTime?`, otherwise you get runtime exceptions. I decide at design time whether a column should be nullable and use defaults to avoid ambiguity."

**Follow-up / Pro tip:**
- `ISNULL` takes the data type of the first argument; `COALESCE` uses data type precedence and accepts many arguments.

---

### Q13. What is a Schema in SQL Server?

**Definition:** A schema is a named container (namespace) inside a database that groups objects like tables, views and procedures. It helps organize objects and manage security. The default schema is `dbo`.

**Real-world example:** A company building (database) with floors (schemas) — HR floor, Payroll floor, Reports floor. Access cards (permissions) can be given per floor instead of per room.

**SQL example:**
```sql
CREATE SCHEMA hr;
GO
CREATE SCHEMA payroll;
GO
CREATE TABLE hr.Employee (EmployeeId INT PRIMARY KEY, EmployeeName NVARCHAR(100));
CREATE TABLE payroll.SalarySlip (Id INT PRIMARY KEY, EmployeeId INT, NetPay DECIMAL(18,2));

-- Grant permission on a whole schema
GRANT SELECT ON SCHEMA::hr TO ReportingUser;
DENY  SELECT ON SCHEMA::payroll TO ReportingUser;

-- Move an object to another schema
ALTER SCHEMA hr TRANSFER dbo.Department;
```

**Interview answer (7 yrs experience):** "A schema is a logical namespace and a security boundary within a database. In our HRMS we split objects into hr, payroll, attendance, audit and rpt schemas. The biggest win was security: the reporting service account gets SELECT on rpt and hr, but is denied on payroll, which holds salary data — one GRANT on the schema instead of hundreds of object-level grants. I always schema-qualify object names, like `hr.Employee` in Dapper queries and procedures; it avoids name-resolution overhead and prevents plan cache issues when users have different default schemas."

---

### Q14. What is the difference between a Table and a View?

**Definition:** A table physically stores data in rows and columns. A view is a saved SELECT query that acts like a virtual table; it usually doesn't store data itself — it reads from the underlying tables each time.

**Real-world example:** A table is the actual warehouse of goods. A view is a shop window that displays selected items from the warehouse — you see a filtered, nicely arranged subset without moving stock.

| Feature | Table | View |
|---|---|---|
| Stores data | Yes | No (except indexed view) |
| Defined by | CREATE TABLE | CREATE VIEW AS SELECT |
| Indexes | Any | Only if indexed view (unique clustered first) |
| DML | Full | Allowed only if it maps to one base table (or via INSTEAD OF trigger) |
| ORDER BY | N/A | Not allowed (without TOP/OFFSET) |
| Use | Persist data | Simplify queries, security, abstraction |

**SQL example:**
```sql
CREATE VIEW hr.vw_EmployeeDirectory
AS
SELECT e.EmployeeId, e.EmployeeName, d.DepartmentName, m.EmployeeName AS ManagerName
FROM dbo.Employee e
JOIN dbo.Department d     ON d.DepartmentId = e.DepartmentId
LEFT JOIN dbo.Employee m  ON m.EmployeeId = e.ManagerId;   -- Salary intentionally hidden
GO
SELECT * FROM hr.vw_EmployeeDirectory WHERE DepartmentName = 'IT';
```

| EmployeeId | EmployeeName | DepartmentName | ManagerName |
|---|---|---|---|
| 5 | Anil | IT | Ravi |

**Interview answer (7 yrs experience):** "A table stores data; a view is a stored query. I use views mainly for security and abstraction — in our HRMS the employee directory view exposes name, department and manager but hides salary, so the intranet app's login only has SELECT on the view. Views don't improve performance by themselves; the optimizer expands them into the outer query. The pitfall I've seen is nested views — view on view on view — which generate huge plans and unnecessary joins; I've flattened those into single views or inline table-valued functions. I also use `WITH SCHEMABINDING` on important views so nobody drops a dependent column accidentally."

**Follow-up / Pro tip:**
- `SELECT *` in a view doesn't auto-pick up new columns; run `sp_refreshview` or avoid `*`.

---

### Q15. What is a Materialized View? Does SQL Server support it directly?

**Definition:** A materialized view stores the result of a query physically on disk, so reads are fast. SQL Server doesn't use the term "materialized view"; its equivalent is an **Indexed View** — a view with a unique clustered index, which SQL Server keeps automatically in sync with base tables.

**Real-world example:** Instead of counting every attendance register each morning, HR keeps a running tally board that updates the moment someone punches in — always ready to read.

**SQL example:**
```sql
CREATE VIEW dbo.vw_DeptSalarySummary
WITH SCHEMABINDING                            -- required
AS
SELECT e.DepartmentId,
       COUNT_BIG(*)  AS EmployeeCount,        -- COUNT_BIG required with GROUP BY
       SUM(e.Salary) AS TotalSalary           -- Salary must be NOT NULL for SUM in indexed view
FROM dbo.Employee e                           -- two-part names required
GROUP BY e.DepartmentId;
GO
CREATE UNIQUE CLUSTERED INDEX UCX_DeptSalarySummary
    ON dbo.vw_DeptSalarySummary (DepartmentId);   -- this "materializes" it
GO
-- Standard/Express edition: use NOEXPAND to guarantee index use
SELECT DepartmentId, EmployeeCount, TotalSalary
FROM dbo.vw_DeptSalarySummary WITH (NOEXPAND);
```

| Materialized View (Oracle/PostgreSQL) | SQL Server Indexed View |
|---|---|
| Can refresh on schedule or on demand | Always updated synchronously with DML |
| Fewer restrictions | Many restrictions: SCHEMABINDING, no OUTER JOIN, no subqueries, no AVG/MIN/MAX, no non-deterministic functions, COUNT_BIG(*) with GROUP BY |

**Interview answer (7 yrs experience):** "SQL Server's version of a materialized view is the indexed view: create the view WITH SCHEMABINDING, then a unique clustered index on it. We used one for department-level headcount and salary totals on the HR dashboard; it turned a multi-second aggregation into a single-row seek. The trade-off is write cost — every insert or update on Employee now also updates the view index, and on hot tables that can cause blocking. There are also many restrictions: no outer joins, no MIN/MAX, required SET options like ARITHABORT ON. In Standard edition I always add the NOEXPAND hint. When the restrictions or write overhead are too much, I use a summary table refreshed by a scheduled job instead."

**Follow-up / Pro tip:**
- Connections that modify base tables must have the correct SET options (e.g., `ANSI_NULLS`, `QUOTED_IDENTIFIER`, `ARITHABORT` ON), or DML fails.

---

# B. Indexing and Query Performance

### Q16. What are Indexes in SQL Server? Why are they required?

**Definition:** An index is a separate, sorted data structure (a B-tree) that helps SQL Server find rows quickly without reading the whole table. Indexes speed up SELECT, JOIN, WHERE, ORDER BY and GROUP BY, but add overhead to writes.

**Real-world example:** The index at the back of a textbook — to find "Payroll", you look it up alphabetically and jump to page 245, instead of reading all 600 pages.

**SQL example:**
```sql
-- Without an index on DepartmentId: full scan of Employee
SELECT EmployeeId, EmployeeName FROM dbo.Employee WHERE DepartmentId = 3;

-- Create an index
CREATE NONCLUSTERED INDEX IX_Employee_DepartmentId
    ON dbo.Employee (DepartmentId)
    INCLUDE (EmployeeName);

-- Compare reads
SET STATISTICS IO ON;
SELECT EmployeeId, EmployeeName FROM dbo.Employee WHERE DepartmentId = 3;
-- Before: logical reads 4,500 (scan)   After: logical reads 4 (seek)
```

**Interview answer (7 yrs experience):** "An index is a B-tree structure that lets SQL Server seek directly to the rows it needs instead of scanning the table. In our HRMS, the attendance table grows by millions of rows a year; the 'my attendance for this month' screen was doing a clustered index scan until we added an index on (EmployeeId, AttendanceDate) — logical reads dropped from hundreds of thousands to single digits. But indexes aren't free: each one is updated on every insert, update and delete, takes storage, and needs maintenance. So I design indexes based on actual query patterns from Query Store and the execution plan, not by guessing, and I review unused indexes periodically."

**Follow-up / Pro tip:**
- Use `SET STATISTICS IO, TIME ON` to compare logical reads before and after an index — it's more reliable than elapsed time.

---

### Q17. Explain Clustered vs Non-Clustered Index.

**Definition:** A **clustered index** sorts and stores the actual table rows in the order of the index key — the leaf level *is* the data. A **non-clustered index** is a separate structure holding the key columns plus a pointer (the clustered key, or a RID for heaps) back to the full row.

**Real-world example:** A clustered index is a phone book: the entries themselves are sorted by surname. A non-clustered index is the index at the back of a textbook: sorted topics with page numbers pointing to the real content.

| Feature | Clustered Index | Non-Clustered Index |
|---|---|---|
| Leaf level contains | Entire data row | Key + included cols + row locator |
| Number per table | 1 | Up to 999 |
| Physical order of data | Logically ordered by key | Separate structure, data unaffected |
| Created by default with | PRIMARY KEY | UNIQUE constraint |
| Extra lookup needed | No | Yes, if non-covered columns needed (Key Lookup) |
| Best for | Range queries, ordered retrieval, narrow increasing keys | Selective searches on other columns |
| Size | No extra copy of data | Extra storage |

**SQL example:**
```sql
CREATE TABLE dbo.EmployeeAttendance (
    Id             BIGINT IDENTITY NOT NULL,
    EmployeeId     INT NOT NULL,
    AttendanceDate DATE NOT NULL,
    Status         CHAR(1) NOT NULL,
    CONSTRAINT PK_EmployeeAttendance PRIMARY KEY CLUSTERED (Id)
);

CREATE NONCLUSTERED INDEX IX_Attendance_Employee_Date
    ON dbo.EmployeeAttendance (EmployeeId, AttendanceDate)
    INCLUDE (Status);
```

**Interview answer (7 yrs experience):** "A clustered index is the table itself sorted by the key; a non-clustered index is a separate sorted copy of some columns with a pointer back. For the clustered key, I follow the 'narrow, unique, static, ever-increasing' rule — usually INT or BIGINT IDENTITY — because the clustered key is copied into every non-clustered index, so a wide key bloats everything. I've seen a table clustered on a GUID with NEWID() suffer heavy page splits and 99% fragmentation; switching to an IDENTITY clustered key (keeping the GUID as a unique non-clustered key) fixed insert performance. Then I add non-clustered indexes for the real search patterns, like EmployeeId + AttendanceDate."

**Follow-up / Pro tip:**
- The primary key and the clustered index are different concepts; you can have a non-clustered PK and cluster on another column.

---

### Q18. Can a table have multiple clustered indexes? Why?

**Definition:** No. A table can have only one clustered index because the clustered index defines the physical (logical) order of the data rows, and data can be stored in only one order.

**Real-world example:** A bookshelf can be arranged by author **or** by title, but not both at the same time. For the other order, you need a separate catalog card (non-clustered index).

**SQL example:**
```sql
CREATE CLUSTERED INDEX CX_Employee_Id ON dbo.Employee (EmployeeId);
CREATE CLUSTERED INDEX CX_Employee_Name ON dbo.Employee (EmployeeName);
-- Msg 1902: Cannot create more than one clustered index on table 'dbo.Employee'.
-- Drop the other clustered index before creating another.

-- Alternative: a covering non-clustered index on the other order
CREATE NONCLUSTERED INDEX IX_Employee_Name ON dbo.Employee (EmployeeName)
    INCLUDE (DepartmentId, Salary);
```

**Interview answer (7 yrs experience):** "Only one, because the clustered index *is* the table data, and rows can only be ordered one way. If I need another ordering to be fast, I create a covering non-clustered index, which effectively acts like a second copy sorted differently. An indexed view with its own clustered index is another option for specific aggregations. Since you only get one, I choose the clustered key carefully — on our attendance table we debated clustering on (AttendanceDate, EmployeeId) for range reports versus an IDENTITY; we chose IDENTITY for insert performance and used a non-clustered index for the date-range queries."

---

### Q19. How many non-clustered indexes can a table have?

**Definition:** A table can have up to **999** non-clustered indexes in SQL Server 2008 and later (it was 249 in SQL Server 2005). Practically, you should keep far fewer.

**Real-world example:** A library *could* print 999 different catalogs (by author, title, year, color...), but every new book would then need 999 catalog updates.

**SQL example:**
```sql
-- List indexes and their usage on a table
SELECT i.name, i.type_desc,
       s.user_seeks, s.user_scans, s.user_lookups, s.user_updates
FROM sys.indexes i
LEFT JOIN sys.dm_db_index_usage_stats s
       ON s.object_id = i.object_id AND s.index_id = i.index_id AND s.database_id = DB_ID()
WHERE i.object_id = OBJECT_ID('dbo.Employee');
```

| Limit | Value |
|---|---|
| Clustered indexes | 1 |
| Non-clustered indexes | 999 |
| Key columns per index | 32 |
| Max non-clustered key size | 1,700 bytes (900 for clustered) |
| Included columns | Up to 1,023 |

**Interview answer (7 yrs experience):** "The limit is 999, but that number is irrelevant in practice. For OLTP tables I aim for roughly five to ten well-designed indexes. In one HRMS audit, the Employee table had 27 indexes, many duplicates created from missing-index suggestions; DMVs showed several with zero seeks but millions of updates. We dropped or consolidated them, which reduced the payroll batch update time noticeably and cut the database size. I check `sys.dm_db_index_usage_stats` before dropping, remembering it resets on instance restart, so I look at data covering a full business cycle, like month-end payroll."

---

### Q20. What is a Composite Index?

**Definition:** A composite index is an index built on two or more columns. The column order matters: the index is sorted by the first column, then the second within it, and so on, so it helps queries that filter on the leading column(s).

**Real-world example:** A phone book sorted by Last Name, then First Name. Finding "Sharma, Ravi" is fast; finding everyone named "Ravi" (first name only) means scanning the whole book.

**SQL example:**
```sql
CREATE NONCLUSTERED INDEX IX_Attendance_Emp_Date
    ON dbo.EmployeeAttendance (EmployeeId, AttendanceDate);

-- Uses index SEEK (leading column present)
SELECT * FROM dbo.EmployeeAttendance WHERE EmployeeId = 101 AND AttendanceDate >= '2024-01-01';
SELECT * FROM dbo.EmployeeAttendance WHERE EmployeeId = 101;

-- Cannot seek (leading column missing) -> scan
SELECT * FROM dbo.EmployeeAttendance WHERE AttendanceDate = '2024-01-15';
```

| Query filter | Seek possible? |
|---|---|
| EmployeeId = x | ✅ |
| EmployeeId = x AND AttendanceDate range | ✅ |
| AttendanceDate only | ❌ (scan) |

**Interview answer (7 yrs experience):** "A composite index covers multiple columns, and column order is everything because only the leftmost prefix is seekable. My rule: equality columns first, then range or sort columns. For our attendance screen — 'employee X, between date A and B' — (EmployeeId, AttendanceDate) is perfect: a seek on EmployeeId, then a range scan on the date within it. If I had put AttendanceDate first, the range would cover all employees. Selectivity matters too, but query patterns matter more than the 'most selective first' myth. I also consolidate: an index on (EmployeeId, AttendanceDate) makes a separate index on EmployeeId alone redundant."

---

### Q21. What is a Covering Index?

**Definition:** A covering index contains all the columns a query needs (in the key or INCLUDE list), so SQL Server can answer the query from the index alone without going back to the base table.

**Real-world example:** A restaurant menu that shows dish name, price and photo — you can decide without asking the waiter for details. If the menu only had dish names, you'd need to ask (a "lookup") for every item.

**SQL example:**
```sql
-- Query
SELECT EmployeeId, AttendanceDate, Status
FROM dbo.EmployeeAttendance
WHERE EmployeeId = 101 AND AttendanceDate BETWEEN '2024-03-01' AND '2024-03-31';

-- Covering index: keys for filtering, Status included for output
CREATE NONCLUSTERED INDEX IX_Attendance_Emp_Date_Covering
    ON dbo.EmployeeAttendance (EmployeeId, AttendanceDate)
    INCLUDE (Status);
-- Plan: Index Seek only, no Key Lookup
```

**Interview answer (7 yrs experience):** "A covering index has every column the query references, so the plan is a pure index seek without key lookups. This is one of the most effective tuning techniques I use. In our HRMS, the monthly attendance API returned date and status; the index on (EmployeeId, AttendanceDate) didn't include Status, so for each row it did a key lookup into the clustered index. Adding `INCLUDE (Status)` removed the lookups and cut CPU on that endpoint by a lot. The trade-off is index size and write overhead, so I cover only hot, frequent queries — and that's another reason to avoid `SELECT *` in Dapper queries; listing exact columns makes covering possible."

---

### Q22. What is an Included Column in an index?

**Definition:** Included columns are non-key columns added to the leaf level of a non-clustered index using `INCLUDE`. They aren't sorted or searchable as keys, but they let the index cover a query without increasing the key size.

**Real-world example:** A contact list sorted by name (key) where each entry also shows the phone number (included). You don't search by phone number, but it's right there when you find the name.

| Key Column | Included Column |
|---|---|
| Stored at all B-tree levels | Stored only at leaf level |
| Sorted, can be used for seek/order | Not sorted, used only for output/residual filter |
| Counts towards 1,700-byte / 32-column limit | Doesn't count; up to 1,023 columns |
| Cannot be (N)VARCHAR(MAX) | Can be (N)VARCHAR(MAX), XML, etc. |

**SQL example:**
```sql
CREATE NONCLUSTERED INDEX IX_Employee_Dept
    ON dbo.Employee (DepartmentId)            -- key: used in WHERE
    INCLUDE (EmployeeName, Salary);           -- included: used in SELECT

SELECT EmployeeName, Salary FROM dbo.Employee WHERE DepartmentId = 2;
```

**Interview answer (7 yrs experience):** "INCLUDE adds columns only to the leaf level, so the key stays narrow while the index still covers the query. I put columns used in WHERE, JOIN and ORDER BY as keys, and columns only in the SELECT list as includes. Includes also avoid the key-size limit and allow MAX types. A pitfall: including too many columns essentially makes a second copy of the table, doubling write cost — I've seen missing-index suggestions that include 20 columns. I trim those down to what the hot query actually needs."

---

### Q23. What is a Unique Index?

**Definition:** A unique index guarantees that no two rows have the same value in the indexed column(s). It's both a data-integrity rule and a performance structure. Creating a PRIMARY KEY or UNIQUE constraint creates a unique index behind the scenes.

**Real-world example:** A company's employee badge system refuses to issue two badges with the same number.

**SQL example:**
```sql
CREATE UNIQUE NONCLUSTERED INDEX UX_Employee_Code ON dbo.Employee (EmployeeCode);

-- Prevent duplicate attendance per employee per day
CREATE UNIQUE NONCLUSTERED INDEX UX_Attendance_Emp_Date
    ON dbo.EmployeeAttendance (EmployeeId, AttendanceDate);

INSERT INTO dbo.EmployeeAttendance (EmployeeId, AttendanceDate, Status) VALUES (101, '2024-03-01', 'P');
INSERT INTO dbo.EmployeeAttendance (EmployeeId, AttendanceDate, Status) VALUES (101, '2024-03-01', 'A');
-- Msg 2601: Cannot insert duplicate key row ... with unique index 'UX_Attendance_Emp_Date'.
```

| Unique Constraint | Unique Index |
|---|---|
| Logical rule (backed by a unique index) | Physical structure |
| Can be referenced by FK | Can also be referenced by FK |
| Cannot have filter or INCLUDE | Can be filtered and have INCLUDE columns |

**Interview answer (7 yrs experience):** "A unique index enforces uniqueness and also helps the optimizer — it knows a seek returns at most one row, which gives better cardinality estimates and plans. In our HRMS, the unique index on (EmployeeId, AttendanceDate) was the real fix for duplicate attendance rows caused by biometric device retries; application-level 'check then insert' had race conditions. In .NET we catch SqlException 2601/2627 and treat it as idempotent success. I prefer a unique index over a constraint when I need a filter or included columns."

**Follow-up / Pro tip:**
- `IGNORE_DUP_KEY = ON` silently discards duplicates on insert — use carefully, it hides data issues.

---

### Q24. What is a Filtered Index?

**Definition:** A filtered index is a non-clustered index with a `WHERE` clause, so it only contains a subset of rows. It is smaller, faster to maintain, and has more accurate statistics for that subset.

**Real-world example:** Instead of a list of all 10,000 employees, the security desk keeps a short list of only "currently active contractors" because that's what they check daily.

**SQL example:**
```sql
-- Only 2% of employees are active-pending-approval; queries target only them
CREATE NONCLUSTERED INDEX IX_Leave_Pending
    ON dbo.LeaveRequest (ApproverId, RequestDate)
    INCLUDE (EmployeeId)
    WHERE Status = 'Pending';

-- Unique only for non-NULL values (multiple NULLs allowed)
CREATE UNIQUE NONCLUSTERED INDEX UX_Employee_NationalId
    ON dbo.Employee (NationalId)
    WHERE NationalId IS NOT NULL;

-- Uses the filtered index
SELECT EmployeeId, RequestDate FROM dbo.LeaveRequest
WHERE ApproverId = 7 AND Status = 'Pending';
```

**Interview answer (7 yrs experience):** "A filtered index indexes only rows matching a predicate. I use it in two classic cases: hot subsets like pending leave approvals or active employees, and 'unique if not null' rules like national ID. Our pending-approval index was a tiny fraction of the full table size and made the manager inbox instant. The big pitfall is parameterization: if the query uses `WHERE Status = @Status`, the optimizer can't guarantee the parameter matches the filter, so it won't use the index in a cached plan. With Dapper, I write the literal `Status = 'Pending'` in the SQL for those queries. Also, filtered indexes require specific SET options like QUOTED_IDENTIFIER ON for DML to succeed."

---

### Q25. What is a Columnstore Index?

**Definition:** A columnstore index stores data column-by-column instead of row-by-row, with heavy compression and batch-mode processing. It's designed for analytics queries that scan and aggregate millions of rows.

**Real-world example:** A rowstore is like reading each employee's full file to total salaries. A columnstore is like having one sheet with just the Salary column for everyone — you add it up instantly without touching other details.

| Feature | Rowstore (B-tree) | Columnstore |
|---|---|---|
| Storage | Rows on 8 KB pages | Column segments in rowgroups (~1M rows) |
| Compression | Optional page/row | Very high (often 5-10x) |
| Best for | OLTP, point lookups, seeks | Large scans, aggregations, reporting |
| Execution | Row mode (mostly) | Batch mode |
| Types | Clustered / Non-clustered | Clustered (CCI) / Non-clustered (NCCI) |

**SQL example:**
```sql
-- Data warehouse fact table
CREATE CLUSTERED COLUMNSTORE INDEX CCI_AttendanceFact ON rpt.AttendanceFact;

-- Real-time operational analytics on an OLTP table (SQL 2016+)
CREATE NONCLUSTERED COLUMNSTORE INDEX NCCI_SalaryHistory
    ON dbo.EmployeeSalaryHistory (EmployeeId, Salary, EffectiveDate);

SELECT YEAR(EffectiveDate) AS [Year], AVG(Salary) AS AvgSalary
FROM dbo.EmployeeSalaryHistory
GROUP BY YEAR(EffectiveDate);
```

**Interview answer (7 yrs experience):** "Columnstore stores each column separately in compressed segments and processes rows in batches, which is ideal for aggregations over millions of rows. In our HRMS reporting database, the attendance fact table had around 200 million rows; with a clustered columnstore the yearly attrition and attendance reports went from minutes to a few seconds, and storage dropped dramatically. For OLTP tables I'm more careful — a non-clustered columnstore adds write overhead and the delta store needs maintenance. Also, singleton updates on columnstore are expensive (delete + insert), so it's best for append-mostly data. Bulk loads of 102,400+ rows go straight into compressed rowgroups, which is something I plan ETL batch sizes around."

**Follow-up / Pro tip:**
- SQL Server 2019+ supports batch mode on rowstore too, so some analytic queries get batch benefits without columnstore.

---

### Q26. What is a Heap Table?

**Definition:** A heap is a table without a clustered index. Its rows are not stored in any particular order, and new rows are inserted into whichever data page has free space.

**Real-world example:** Think of a physical cardboard box where documents are tossed in randomly as they arrive. If you need document #104, you have to dig through the entire box from top to bottom unless you keep a separate index card notebook on your desk.

| Feature | Heap Table | Clustered Index Table |
|---|---|---|
| Physical Order | None (unordered collection of 8 KB pages) | B-tree ordered by clustered key |
| Row Identifier (RID) | 8-byte RID (File:Page:Slot) | Clustered Index Key |
| Non-clustered Index pointers | Point to RID | Point to Clustered Key value |
| Page Splits on Insert | None (new rows go to any free page) | Can split leaf pages when ordered inserts arrive out of sequence |
| Forwarded Records | Occur when row expansion outgrows page | None (handled via page splits / overflow) |

**SQL example:**
```sql
-- Create a staging heap table for bulk loads
CREATE TABLE dbo.EmployeeAttendance_Staging
(
    EmployeeId     INT NOT NULL,
    AttendanceDate DATE NOT NULL,
    Status         VARCHAR(10) NOT NULL
); -- Notice: No PRIMARY KEY or CLUSTERED INDEX defined

-- Check if a table is a heap (index_id = 0 means Heap, index_id = 1 means Clustered)
SELECT 
    t.name AS TableName,
    i.type_desc AS StorageType
FROM sys.tables t
JOIN sys.indexes i ON t.object_id = i.object_id
WHERE t.name = 'EmployeeAttendance_Staging';
```

**Interview answer (7 yrs experience):** "In SQL Server, a heap table has `index_id = 0`. In our HRMS, we intentionally use heaps for high-speed staging and logging tables where we stream biometric punch data via bulk copy (bcp/SqlBulkCopy). Because there is no B-tree ordering to maintain on write, inserts are blazing fast without page splits. However, heaps are dangerous for transactional OLTP tables. The biggest production issue I have encountered with heaps is forwarded records: when variable-length columns like `NVARCHAR` expand on update, the row outgrows its original 8 KB page, leaving a forward pointer. Over time, queries scanning the heap do massive extra I/O chasing forwarded pointers. Also, space reclamation on DELETE is poor unless a TABLOCK is acquired. For 99% of OLTP tables, a clustered index is mandatory; I reserve heaps strictly for staging and dump-and-truncate pipelines."

**Follow-up / Pro tip:**
- You can fix forwarded records on a heap by running `ALTER TABLE TableName REBUILD;` or by adding a clustered index.

---

### Q27. What is Index Fragmentation?

**Definition:** Index fragmentation occurs when the logical ordering of index pages does not match the physical ordering on disk (external fragmentation), or when data pages contain significant unused empty space due to page splits (internal fragmentation).

**Real-world example:** Imagine a ring binder of employee personnel files sorted alphabetically. If you hire 10 employees whose names start with 'M', that folder runs out of room. You have to split the folder into two separate loose binders placed across different shelves, leaving half-empty binders and forcing you to walk back and forth.

| Type | Internal Fragmentation | External (Logical) Fragmentation |
|---|---|---|
| Cause | Page splits leave pages 30-50% empty | Leaf pages are out of physical contiguous order |
| Symptom | Wasted disk and buffer cache RAM | High disk head movement (mainly magnetic disks) |
| Impact | More pages read into memory for same rows | Slower sequential table scans |

**SQL example:**
```sql
-- Check fragmentation percentage of indexes on Employee table
SELECT 
    dbs.name AS DatabaseName,
    tbl.name AS TableName,
    ix.name AS IndexName,
    ps.index_type_desc,
    ps.avg_fragmentation_in_percent,
    ps.page_count
FROM sys.dm_db_index_physical_stats(DB_ID(), OBJECT_ID('dbo.Employee'), NULL, NULL, 'LIMITED') ps
JOIN sys.indexes ix ON ps.object_id = ix.object_id AND ps.index_id = ix.index_id
JOIN sys.tables tbl ON ps.object_id = tbl.object_id
JOIN sys.databases dbs ON ps.database_id = dbs.database_id;
```

**Interview answer (7 yrs experience):** "Index fragmentation happens when random `INSERT`, `UPDATE`, and `DELETE` operations cause 8 KB pages to split. In our production HRMS, we have two types: internal (half-empty pages wasting buffer pool memory) and external (out-of-order leaf pages). When index fragmentation exceeds 30% on tables with more than 1,000 pages, index scans suffer because SQL Server must read significantly more pages from disk and memory. However, at 7 years of experience, I don't blindly rebuild every fragmented index. On modern NVMe SSDs, random I/O latency is negligible, so seek-heavy workloads rarely notice 20% fragmentation. We follow Microsoft's best practice: 5% to 30% fragmentation gets an online `REORGANIZE`, and above 30% gets an `ALTER INDEX ... REBUILD WITH (ONLINE = ON)`. For GUID-based primary keys, we mitigate the root cause by using `NEWSEQUENTIALID()` or clustered indexes on monotonically increasing integer identity columns."

---

### Q28. What is the difference between Index Rebuild and Index Reorganize?

**Definition:** Reorganize defragments the leaf level of an index in-place with minimal locking, while Rebuild drops and re-creates the entire B-tree structure from scratch.

**Real-world example:** Reorganizing is like tidying your desk while working: moving pens, sliding papers together, keeping quiet. Rebuilding is like buying a brand new desk, setting up a fresh drawer organizer, moving everything over, and throwing the old desk away.

| Feature | Index Reorganize | Index Rebuild |
|---|---|---|
| Command | `ALTER INDEX ... REORGANIZE` | `ALTER INDEX ... REBUILD` |
| Operation | Always online, in-place compaction | Drops and rebuilds whole B-tree (can be ONLINE/OFFLINE) |
| Locking | Short-term page-level locks; non-blocking | Schema-modification (Sch-M) lock; can block unless ONLINE = ON |
| Transaction Log | Minimally logged; can be stopped safely | Fully logged (unless simple/bulk-logged); generates large logs |
| TempDB Usage | Low | High if `SORT_IN_TEMPDB = ON` |
| Statistics | Does NOT update statistics | Updates index statistics automatically (`FULLSCAN` equivalent) |
| Recommended Threshold | 5% to 30% fragmentation | > 30% fragmentation (on tables > 1,000 pages) |

**SQL example:**
```sql
-- 1. Reorganize (lightweight, safe during business hours)
ALTER INDEX IX_Employee_DepartmentId ON dbo.Employee REORGANIZE;

-- 2. Rebuild Online (SQL Server Enterprise / 2016 SP1+ Standard)
ALTER INDEX IX_Employee_DepartmentId ON dbo.Employee 
REBUILD WITH (ONLINE = ON, SORT_IN_TEMPDB = ON, MAXDOP = 4);
```

**Interview answer (7 yrs experience):** "I use `REORGANIZE` for moderate fragmentation (5% to 30%) because it operates strictly at the leaf level, acquires brief page latches, and never causes user blocking. It is completely safe during working hours. For fragmentation above 30%, I use `REBUILD` with `ONLINE = ON`. An important distinction interviewers look for is statistics: a `REBUILD` automatically updates the index statistics with a full scan equivalent, whereas `REORGANIZE` leaves statistics untouched, meaning you must manually execute `UPDATE STATISTICS` afterward. In our production maintenance window, we use Ola Hallengren's maintenance solution, which dynamically evaluates page count and fragmentation thresholds to decide between Reorganize and Rebuild, avoiding wasteful log generation on small or unfragmented tables."

---

### Q29. What is Index Seek vs Index Scan vs Table Scan?

**Definition:** An Index Seek navigates the B-tree directly to qualifying rows using search arguments; an Index Scan reads all leaf pages of an index; and a Table Scan reads every page of a heap table.

**Real-world example:** 
- **Index Seek:** Opening a dictionary directly to the 'S' section using thumb notches to find 'Salary'.
- **Index Scan:** Flipping through every page of the dictionary's index section from page 1 to the end.
- **Table Scan:** Reading an unsorted pile of loose notebook pages one by one to find a name.

| Operator | When It Occurs | I/O Cost | Scalability |
|---|---|---|---|
| **Index Seek** | Query filter matches index leading column with equality/range operator | Very Low ($O(\log N)$) | Extremely scalable as table grows |
| **Index Scan** | Query lacks index predicate, or index is used to satisfy covering columns without a seek | Moderate to High ($O(N)$) | Degrading linearly with row count |
| **Table Scan** | Table has no clustered index (heap) and query must examine all rows | Highest ($O(N)$ full heap read) | Terrible on large tables |

**SQL example:**
```sql
-- 1. INDEX SEEK: Direct B-tree dive using clustered key
SELECT EmployeeId, EmployeeName, Salary 
FROM dbo.Employee 
WHERE EmployeeId = 101;

-- 2. INDEX SCAN: Query reads all rows of the index to find matching pattern
SELECT EmployeeId, EmployeeName 
FROM dbo.Employee 
WHERE EmployeeName LIKE '%mit%'; -- Leading wildcard prevents Seek

-- 3. TABLE SCAN: On a heap table without any clustered index
SELECT * FROM dbo.EmployeeAttendance_Staging 
WHERE Status = 'Present';
```

**Interview answer (7 yrs experience):** "In execution plans, an Index Seek is our gold standard for OLTP: SQL Server traverses root and intermediate B-tree nodes in 3-4 page reads to find exact rows. An Index Scan touches every single leaf page of the index. Junior developers often assume an Index Scan is fast simply because it uses an index; in reality, scanning an index with 10 million rows still reads millions of pages and saturates disk I/O. However, an Index Scan isn't always a bug: if a query requests 80% of a table's rows, the query optimizer deliberately chooses a scan over thousands of individual seeks and key lookups because sequential I/O is cheaper. I always evaluate seeks vs scans alongside estimated vs actual row counts to identify cardinality miscalculations."

---

### Q30. What is a SARGable query?

**Definition:** SARGable stands for **S**earch **ARG**ument **able**. A query predicate is SARGable when SQL Server can utilize an index seek directly along the B-tree rather than evaluating an expression across every row.

**Real-world example:** If a phone directory is alphabetized by last name, searching for `LastName = 'Sharma'` allows you to open directly to the 'S' section. But searching for `REVERSE(LastName) = 'amrahS'` forces you to read every single name in the entire phonebook and reverse it in your head to check for a match.

**SQL example:**
```sql
-- NON-SARGable (Forces Index Scan / High CPU)
SELECT EmployeeId, EmployeeName, JoiningDate
FROM dbo.Employee
WHERE YEAR(JoiningDate) = 2023; -- Function wraps the indexed column!

-- SARGable Rewrite (Enables Index Seek)
SELECT EmployeeId, EmployeeName, JoiningDate
FROM dbo.Employee
WHERE JoiningDate >= '2023-01-01' AND JoiningDate < '2024-01-01';

-- NON-SARGable string matching:
SELECT * FROM dbo.Employee WHERE SUBSTRING(EmployeeName, 1, 1) = 'A';
-- SARGable rewrite:
SELECT * FROM dbo.Employee WHERE EmployeeName LIKE 'A%';
```

**Interview answer (7 yrs experience):** "Writing non-SARGable queries is the #1 query design anti-pattern I remediate in .NET / Dapper codebases. When developers wrap indexed columns inside functions—such as `YEAR(JoiningDate)`, `CONVERT(VARCHAR, DateCol, 101)`, `ISNULL(DepartmentId, 0) = 1`, or leading wildcards like `LIKE '%Sharma'`—the query optimizer cannot seek on the B-tree index. It is forced to evaluate the scalar function for every row in the table, degrading an $O(\log N)$ seek to an $O(N)$ full index scan with high CPU cost. In our HRMS attendance module, changing `WHERE CONVERT(DATE, AttendanceDate) = @Date` to a half-open date interval `WHERE AttendanceDate >= @Start AND AttendanceDate < @NextDay` reduced query time on 50 million records from 42 seconds to 12 milliseconds."

**Common Non-SARGable Patterns and Fixes:**
- `YEAR(Col) = 2024` $\rightarrow$ `Col >= '20240101' AND Col < '20250101'`
- `ISNULL(Status, 'A') = 'A'` $\rightarrow$ `(Status = 'A' OR Status IS NULL)`
- `Col + 10 > 100` $\rightarrow$ `Col > 90` (Keep the column alone on one side of the operator)
- Implicit type conversion: comparing `VARCHAR` column to `NVARCHAR` parameter (e.g. Dapper default `DbType.String` instead of `DbType.AnsiString`).

---

### Q31. What is a Key Lookup? How can you avoid it?

**Definition:** A Key Lookup occurs when a non-clustered index satisfies the query's filter predicate, but does not contain all columns required by the `SELECT` list, forcing SQL Server to traverse the clustered index for each matching row to fetch missing columns.

**Real-world example:** You check a library subject catalog card (non-clustered index) to get a list of 5 book call numbers. For each card, you must walk down the hallway to the physical shelf (clustered index) to check the publishing year and author biography because that detail wasn't written on the card.

```
Query -> Non-Clustered Index Seek (Finds rows) -> Key Lookup (B-tree dive to Clustered Index for missing columns) -> Output
```

**SQL example:**
```sql
-- Existing Index on DepartmentId only
CREATE NONCLUSTERED INDEX IX_Emp_Dept ON dbo.Employee(DepartmentId);

-- Query requesting extra columns not in IX_Emp_Dept
SELECT EmployeeName, Salary 
FROM dbo.Employee 
WHERE DepartmentId = 1; -- Causes Non-Clustered Index Seek + KEY LOOKUP on PK

-- FIX: Create a COVERING index with INCLUDE clause
CREATE NONCLUSTERED INDEX IX_Emp_Dept_Covering 
ON dbo.Employee(DepartmentId) 
INCLUDE (EmployeeName, Salary); -- Eliminates Key Lookup completely!
```

**Interview answer (7 yrs experience):** "A Key Lookup is an operator where SQL Server takes the clustered index key found in a non-clustered index leaf and performs a secondary point-seek into the base clustered table to retrieve missing columns. If the query returns 5 rows, 5 key lookups cost almost nothing. But if the query returns 20,000 rows, that means 20,000 individual random lookups into the clustered index. At a certain tipping point, the optimizer simply abandons the non-clustered index and executes a full clustered index scan instead. I eliminate key lookups by creating covering indexes using the `INCLUDE` clause for non-predicate columns. This gives us the best of both worlds: a lean index key for fast seeking, and covered leaf pages so the engine never touches the base table."

---

### Q32. What is a Missing Index Recommendation?

**Definition:** SQL Server's query optimizer automatically identifies missing indexes during query compilation and writes advisory metadata to Dynamic Management Views (DMVs) such as `sys.dm_db_missing_index_details`.

**Real-world example:** A GPS navigation app suggesting: *'If there were a direct bypass highway here, you would save 15 minutes on your commute.'* It provides a suggestion based on your single trip, but city planners still have to evaluate the financial cost before building it.

**SQL example:**
```sql
-- Query to identify top missing indexes by user impact
SELECT 
    mid.statement AS TableName,
    mid.equality_columns,
    mid.inequality_columns,
    mid.included_columns,
    migs.unique_compiles,
    migs.user_seeks,
    migs.avg_user_impact AS ExpectedImprovementPercent,
    (migs.user_seeks * migs.avg_user_impact * (migs.avg_total_user_cost)) AS OverallScore
FROM sys.dm_db_missing_index_group_stats migs
JOIN sys.dm_db_missing_index_groups mig ON migs.group_handle = mig.index_group_handle
JOIN sys.dm_db_missing_index_details mid ON mig.index_handle = mid.index_handle
ORDER BY OverallScore DESC;
```

**Interview answer (7 yrs experience):** "Green missing index recommendations in SSMS graphical execution plans are helpful hints, but implementing them blindly in production is a major mistake. The optimizer evaluates missing index requests on an isolated query-by-query basis. If you create every recommended index, you will quickly end up with 30 overlapping indexes on a single table, destroying insert and update performance. When I review missing index DMVs, I look for consolidation opportunities: can I add an `INCLUDE` column to an existing index rather than creating a brand-new one? I also verify column ordering (equality columns first, then inequality columns) because the optimizer's suggested ordering is not always optimal for multi-predicate queries."

---

### Q33. Can creating too many indexes affect INSERT, UPDATE and DELETE performance?

**Definition:** Yes. Every non-clustered index on a table is an independent copy of data that SQL Server must synchronously update inside the transaction whenever rows are inserted, deleted, or indexed columns are modified.

**Real-world example:** If you maintain 15 different address books sorted by first name, last name, phone number, pin code, city, etc., whenever a new colleague joins, you must open and write their name in all 15 books. Writing 1 record takes 15 times the effort.

| DML Operation | Impact of Excessive Indexes |
|---|---|
| **INSERT** | Must add a new leaf entry in every single index B-tree; causes page splits |
| **DELETE** | Must locate and remove the row's entry from every single index B-tree |
| **UPDATE** | If an updated column belongs to an index, that specific index must be modified |
| **Storage & RAM** | Ballooning database size; buffer pool memory wasted caching redundant indexes |

**SQL example:**
```sql
-- Check unused indexes that cost writes but provide zero seeks/scans
SELECT 
    tbl.name AS TableName,
    ix.name AS IndexName,
    ius.user_seeks,
    ius.user_scans,
    ius.user_lookups,
    ius.user_updates AS TotalWrites
FROM sys.dm_db_index_usage_stats ius
JOIN sys.indexes ix ON ius.object_id = ix.object_id AND ius.index_id = ix.index_id
JOIN sys.tables tbl ON ix.object_id = tbl.object_id
WHERE ius.database_id = DB_ID()
  AND ix.is_primary_key = 0
  AND ix.is_unique = 0
  AND ius.user_seeks = 0 AND ius.user_scans = 0 -- Never read
  AND ius.user_updates > 1000                    -- Constantly written to
ORDER BY ius.user_updates DESC;
```

**Interview answer (7 yrs experience):** "Every index has a write tax. On our core `EmployeeAttendance` table, which receives 200,000 punch records every morning, inserts were experiencing severe lock escalation and disk write stalls. During our audit, we discovered 14 non-clustered indexes created by different developers over 4 years. Querying `sys.dm_db_index_usage_stats` revealed that 6 of those indexes had zero user seeks over 90 days of uptime, yet had millions of `user_updates`. By dropping those 6 redundant indexes and consolidating 3 others into covering indexes, our bulk punch insert runtime dropped from 18 minutes to under 4 minutes. A good senior guideline for OLTP is 4 to 8 well-targeted indexes per table; anything over 10 requires strong justification."

---

### Q34. What is Statistics in SQL Server?

**Definition:** Statistics are binary system objects containing statistical information about the distribution of values in one or more columns of a table or index. The Query Optimizer relies on statistics to estimate how many rows will be returned (cardinality estimation) and choose the best execution plan.

**Real-world example:** A road traffic report telling you how many cars usually travel on Highway 101 between 9 AM and 10 AM. If the report says 5 cars, Google Maps routes you through the highway; if the report is outdated and 50,000 cars are there, you get stuck in gridlock because of bad data.

**Key Components of Statistics:**
1. **Header:** Metadata (last updated time, total rows, rows sampled).
2. **Density Vector:** Measures column uniqueness ($1 / \text{distinct values}$). Used for multi-column joins and group-by estimates.
3. **Histogram:** Up to 200 steps showing frequency and distribution of data values across the column range.

**SQL example:**
```sql
-- View statistics histogram for Employee table's salary
DBCC SHOW_STATISTICS ('dbo.Employee', 'PK_Employee');

-- Manually update statistics with full scan on critical tables
UPDATE STATISTICS dbo.Employee WITH FULLSCAN;

-- Check when statistics were last updated
SELECT 
    obj.name AS TableName,
    stat.name AS StatName,
    sp.last_updated,
    sp.rows,
    sp.rows_sampled,
    sp.modification_counter -- Number of changes since last stat update
FROM sys.stats stat
CROSS APPLY sys.dm_db_stats_properties(stat.object_id, stat.stats_id) sp
JOIN sys.objects obj ON stat.object_id = obj.object_id
WHERE obj.name = 'Employee';
```

**Interview answer (7 yrs experience):** "Statistics are the brain fuel of the Cost-Based Query Optimizer. Without accurate statistics, the optimizer cannot estimate cardinality correctly. For example, if a table has 5 million attendance rows but statistics say it only has 50 rows due to outdated stats, the engine will pick a Nested Loops join with memory grants for 50 rows. At runtime, 5 million rows arrive, causing massive TempDB spill warnings and catastrophic performance. In SQL Server 2016+, dynamic thresholding automatically triggers updates based on $\sqrt{1000 \times \text{table rows}}$. In production, I always schedule nightly statistics maintenance with `FULLSCAN` for volatile high-volume tables to avoid sub-optimal plans."

---

### Q35. What is an Execution Plan? Explain Actual vs Estimated Execution Plan.

**Definition:** An Execution Plan is the graphical or XML roadmap generated by the Query Optimizer detailing the physical operations (such as Clustered Index Seek, Hash Match Join, Sort) used to execute a T-SQL query.

**Real-world example:**
- **Estimated Plan:** A planned flight itinerary before takeoff: takes into account theoretical flight paths, expected winds, and scheduled arrival time.
- **Actual Plan:** The pilot's flight recorder log after landing: reveals actual headwinds encountered, holding patterns flown, and true fuel burned.

| Feature | Estimated Execution Plan | Actual Execution Plan |
|---|---|---|
| Shortcut | `Ctrl + L` | `Ctrl + M` (then execute query) |
| Query Execution | Query is NOT executed | Query is physically executed to completion |
| Safety | Safe for destructive queries (`DELETE`, `DROP`) | Dangerous for uncommitted `DELETE`/`UPDATE` |
| Metrics Included | Estimated rows, estimated cost, estimated memory | Actual rows read, actual elapsed time, actual I/O reads, memory grant spills |
| Cardinality Feedback | Cannot compare actual vs estimated | Immediately flags cardinality estimation discrepancies |

**SQL example:**
```sql
-- Turn on runtime statistics to inspect execution metrics in text format
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT e.EmployeeName, d.DepartmentName, e.Salary
FROM dbo.Employee e
JOIN dbo.Department d ON e.DepartmentId = d.DepartmentId
WHERE e.Salary >= 70000;

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
```

**Interview answer (7 yrs experience):** "I use estimated plans (`Ctrl + L`) when diagnosing heavy queries on production that I cannot afford to run, or when reviewing high-risk `DELETE` statements. However, for true performance tuning, I rely on the Actual Execution Plan (`Ctrl + M`). What I immediately examine in an actual plan is the difference between Estimated Number of Rows and Actual Number of Rows. If the estimated count is 1 and the actual count is 500,000, that is an immediate red flag pointing to stale statistics, non-SARGable functions, or parameter sniffing. I also inspect warning icons: yellow exclamation triangles indicating excessive memory grant spills to TempDB, implicit data type conversions causing index scans, or missing index recommendations."

**Follow-up / Pro tip:**
- You can capture actual execution plans on production without user impact or profiler overhead by enabling SQL Server **Query Store** or using Extended Events with the `query_post_execution_showplan` event.
