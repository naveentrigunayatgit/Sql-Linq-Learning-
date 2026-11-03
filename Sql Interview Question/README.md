# SQL Server Interview Preparation - 7 Years Experience

Comprehensive interview preparation guide tailored for a senior **.NET Core / Dapper / SQL Server / HRMS** developer with ~7 years of experience.

Every single question across Theory, Scenarios, Coding, and Practical Performance Challenges is fully answered with:
1. **Easy-to-understand Definition** (1-3 simple sentences)
2. **Real-world Analogy / Scenario** (HRMS, banking, e-commerce, attendance, logistics)
3. **Production T-SQL Example** (using consistent sample schema: Employee, Department, SalaryHistory, Attendance)
4. **7-Year Experienced Senior Answer** (first-person conversational tone with STAR-T format: Situation, Task, Action, Result, and Trade-offs)
5. **Comparison Tables & Follow-up Pro Tips**

---

## 📂 Master Navigation & File Index

| # | File Name | Topics & Coverage | Question Range |
|---|---|---|---|
| **0** | [00_Setup_SampleTables.sql](file:///C:/Users/user/.gemini/antigravity/scratch/sql-interview-prep/00_Setup_SampleTables.sql) | Complete DDL + DML script to set up `InterviewPrep` database with sample data and indexes in SSMS | Master Schema |
| **1** | [01_Theory_Fundamentals_Indexing.md](file:///C:/Users/user/.gemini/antigravity/scratch/sql-interview-prep/01_Theory_Fundamentals_Indexing.md) | Normalization (1NF-BCNF), Denormalization, Keys, Constraints, Data Types, Indexes (Clustered, Non-Clustered, Filtered, Columnstore), Fragmentation, SARGability, Key Lookups, Statistics, Execution Plans | **Q1 - Q35** (35 Questions) |
| **2** | [02_Theory_Joins_Objects_WindowFunctions.md](file:///C:/Users/user/.gemini/antigravity/scratch/sql-interview-prep/02_Theory_Joins_Objects_WindowFunctions.md) | Joins (Inner, Outer, Cross, Self), Subqueries vs CTEs, #Temp vs @Table, Stored Procs vs Functions, Triggers, Views, Window Functions (ROW_NUMBER, RANK, DENSE_RANK, LAG/LEAD, NTILE), PIVOT, MERGE, TVPs with Dapper | **Q36 - Q75** (40 Questions) |
| **3** | [03_Theory_Transactions_Production.md](file:///C:/Users/user/.gemini/antigravity/scratch/sql-interview-prep/03_Theory_Transactions_Production.md) | Transactions, ACID, Deadlocks & Resolution, Isolation Levels (Dirty/Non-Repeatable/Phantom Reads, RCSI, Snapshot), Parameter Sniffing, Query Store, Wait Types, TempDB, Connection Pooling, HA/DR, Recovery Models, Backups | **Q76 - Q120** (45 Questions) |
| **4** | [04_Scenario_Based_Questions.md](file:///C:/Users/user/.gemini/antigravity/scratch/sql-interview-prep/04_Scenario_Based_Questions.md) | Real-time production troubleshooting: Dev vs Prod speed discrepancies, 100M-row table design, batch deletions, deadlock triage, optimistic concurrency with ROWVERSION, C# Dapper transactions, TVPs, and intermittent timeouts | **S1 - S40** (40 Scenarios) |
| **5** | [05_Coding_Questions_Part1.md](file:///C:/Users/user/.gemini/antigravity/scratch/sql-interview-prep/05_Coding_Questions_Part1.md) | Basic to Intermediate queries, Nth highest salary, duplicate detection/removal, Joins, Relational Division, Window Functions, Running totals, Cumulative sales, Gaps & Islands consecutive logins | **C1 - C40** (40 Coding Queries) |
| **6** | [06_Coding_Advanced_and_Performance_Challenges.md](file:///C:/Users/user/.gemini/antigravity/scratch/sql-interview-prep/06_Coding_Advanced_and_Performance_Challenges.md) | Advanced stored procedures with TVP & Dapper, pagination (OFFSET vs Keyset), Dynamic SQL, 10,000-row batching, attendance streaks + **Section 4: 10 Practical Performance Challenges (P1-P10)** + Senior Interview Checklist | **C41 - C60** + **P1 - P10** (30 Challenges) |

---

## 🗄️ Standard Sample Tables (Section 5)

All coding questions and SQL examples are executed against this standardized schema:

### 1. `dbo.Employee`
| EmployeeId | EmployeeName | DepartmentId | ManagerId | Salary | JoiningDate |
|---|---|---|---|---|---|
| 101 | Amit | 1 | NULL | 80000.00 | 2022-01-10 |
| 102 | Rahul | 1 | 101 | 60000.00 | 2023-03-15 |
| 103 | Priya | 2 | NULL | 90000.00 | 2021-06-20 |
| 104 | Sneha | 2 | 103 | 70000.00 | 2024-01-05 |
| 105 | Raj | 1 | 101 | 60000.00 | 2023-08-10 |

### 2. `dbo.Department`
| DepartmentId | DepartmentName |
|---|---|
| 1 | IT |
| 2 | HR |
| 3 | Finance |

### 3. `dbo.EmployeeSalaryHistory`
| Id | EmployeeId | Salary | EffectiveDate |
|---|---|---|---|
| 1 | 101 | 50000.00 | 2022-01-10 |
| 2 | 101 | 60000.00 | 2023-01-10 |
| 3 | 101 | 80000.00 | 2024-01-10 |
| 4 | 102 | 40000.00 | 2023-03-15 |
| 5 | 102 | 60000.00 | 2024-03-15 |

### 4. `dbo.EmployeeAttendance`
| Id | EmployeeId | AttendanceDate | Status |
|---|---|---|---|
| 1 | 101 | 2026-10-01 | Present |
| 2 | 101 | 2026-10-02 | Absent |
| 3 | 101 | 2026-10-03 | Present |
| 4 | 102 | 2026-10-01 | Present |
| 5 | 102 | 2026-10-02 | Present |

---

## 🎯 Senior Engineer Interview Delivery: The STAR-T Method

When answering scenario and performance questions for a 7-year experience role, avoid reciting textbook definitions. Structure answers using **STAR-T**:
1. **Situation:** *"In our HRMS payroll module with 20 million biometric records..."*
2. **Task:** *"We had to reduce month-end processing duration from 45 minutes to under 5 minutes without changing the database schema."*
3. **Action:** *"I inspected Query Store, identified that parameter sniffing flipped an index seek to a clustered index scan, added a covering index with `INCLUDE`, and stabilized the plan using `OPTIMIZE FOR`."*
4. **Result:** *"Logical reads dropped from 14,000,000 to 2,400, and execution duration dropped to 400 milliseconds."*
5. **Trade-off:** *"We accepted a ~4% write overhead on employee attendance inserts in exchange for sub-second query performance."*
