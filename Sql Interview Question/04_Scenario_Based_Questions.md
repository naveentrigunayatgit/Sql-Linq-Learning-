# Section 2: Scenario-Based Interview Questions (7 Years Experience)

> Sample tables used throughout:
> `Employee(EmployeeId, EmployeeCode, EmployeeName, DepartmentId, ManagerId, Salary, JoiningDate)`,
> `Department(DepartmentId, DepartmentName)`,
> `EmployeeSalaryHistory(Id, EmployeeId, Salary, EffectiveDate)`,
> `EmployeeAttendance(Id, EmployeeId, AttendanceDate, Status)`.

## Table of Contents

**A. Query Optimization and Performance**
- [S1. SP takes 2 seconds in dev but 45 seconds in production](#s1-a-stored-procedure-takes-2-seconds-in-development-but-45-seconds-in-production-how-will-you-troubleshoot-it)
- [S2. Query returns 10 million rows and takes 5 minutes](#s2-a-query-is-returning-10-million-records-and-taking-5-minutes-how-will-you-optimize-it)
- [S3. Slow responses after a new deployment](#s3-your-application-has-started-experiencing-slow-database-responses-after-deploying-new-code-how-will-you-identify-whether-the-issue-is-sql-related)
- [S4. Clustered Index Scan instead of Seek](#s4-an-execution-plan-shows-a-clustered-index-scan-instead-of-an-index-seek-how-will-you-investigate)
- [S5. Index is used but performance is still poor](#s5-a-query-is-using-an-index-but-performance-is-still-poor-what-could-be-the-reasons)
- [S6. Index design for 100 million rows](#s6-you-have-a-table-containing-100-million-records-you-need-to-search-employee-records-by-employeecode-departmentid-and-joiningdate-how-will-you-design-indexes)
- [S7. Fast for one EmployeeId, slow for another](#s7-a-stored-procedure-executes-quickly-for-one-employeeid-but-takes-30-seconds-for-another-employeeid-what-could-be-the-reason)
- [S8. Fast in SSMS, slow from .NET](#s8-a-query-performs-well-when-executed-directly-in-ssms-but-becomes-slow-when-called-from-a-net-application-how-will-you-investigate)
- [S9. 20 indexes and slow INSERTs](#s9-a-table-has-20-indexes-and-insert-operations-are-becoming-slow-how-will-you-optimize-the-table)
- [S10. Multiple OR conditions](#s10-your-query-uses-multiple-or-conditions-and-performs-poorly-how-would-you-rewrite-it)

**B. Transactions, Deadlocks and Concurrency**
- [S11. Two users update the same employee](#s11-two-users-update-the-same-employee-record-simultaneously-how-will-you-prevent-data-inconsistency)
- [S12. Deadlocks from different update order](#s12-two-stored-procedures-are-updating-the-same-tables-in-different-orders-causing-deadlocks-how-will-you-fix-this)
- [S13. Transaction never commits or rolls back](#s13-a-transaction-starts-but-never-commits-or-rolls-back-what-problems-can-occur)
- [S14. Report query blocks INSERT/UPDATE](#s14-a-report-query-is-blocking-insert-and-update-operations-how-will-you-resolve-it)
- [S15. NOLOCK everywhere](#s15-your-application-uses-nolock-everywhere-what-problems-can-occur-in-production)
- [S16. Second update fails in a financial transaction](#s16-a-financial-transaction-updates-two-tables-the-first-update-succeeds-but-the-second-fails-how-will-you-ensure-both-updates-are-rolled-back)
- [S17. Frequent deadlocks during peak hours](#s17-an-application-frequently-encounters-deadlocks-during-peak-hours-how-will-you-identify-the-root-cause)
- [S18. Isolation levels and concurrent reads](#s18-a-user-reads-data-while-another-transaction-is-updating-it-how-will-isolation-levels-affect-the-result)
- [S19. Booking the last available seat](#s19-how-would-you-handle-a-scenario-where-two-users-attempt-to-book-the-last-available-seat-simultaneously)
- [S20. Optimistic concurrency](#s20-how-would-you-implement-optimistic-concurrency-in-sql-server)

**C. Database Design and Large Data**
- [S21. Searching/reporting on 100 million employees](#s21-you-have-an-employee-table-containing-100-million-records-how-would-you-improve-searching-and-reporting)
- [S22. Deleting 50 million historical rows](#s22-you-need-to-delete-50-million-historical-records-without-affecting-production-performance-how-would-you-approach-it)
- [S23. Migrating 100 million rows](#s23-you-need-to-migrate-100-million-records-from-one-database-to-another-how-would-you-perform-this-migration)
- [S24. Removing duplicate employees](#s24-a-table-contains-duplicate-employee-records-how-will-you-identify-and-remove-duplicates-without-deleting-valid-records)
- [S25. Employee skills design](#s25-your-application-needs-to-store-employee-skills-where-one-employee-can-have-multiple-skills-how-would-you-design-the-database)
- [S26. Report from 15 tables](#s26-a-reporting-requirement-needs-data-from-15-tables-how-would-you-design-an-efficient-query)
- [S27. Partitioning or archiving](#s27-a-table-is-continuously-growing-and-slowing-down-how-would-you-implement-partitioning-or-archiving)
- [S28. Salary history design](#s28-you-need-to-maintain-historical-employee-salary-records-how-would-you-design-the-database)
- [S29. Passing thousands of EmployeeIds](#s29-a-stored-procedure-receives-thousands-of-employeeids-how-will-you-pass-these-values-efficiently)
- [S30. Monthly attendance report for 5 million employees](#s30-you-need-to-generate-monthly-employee-attendance-reports-for-5-million-employees-how-would-you-optimize-the-process)

**D. Stored Procedure and Production Scenarios**
- [S31. 1,000-line stored procedure](#s31-a-stored-procedure-contains-1000-lines-of-sql-and-is-difficult-to-maintain-how-would-you-improve-it)
- [S32. Nested IFs and repeated queries](#s32-a-stored-procedure-has-multiple-nested-if-conditions-and-repeated-queries-how-would-you-optimize-it)
- [S33. Wrong results for NULL values](#s33-a-stored-procedure-works-correctly-for-most-inputs-but-returns-incorrect-results-for-null-values-how-will-you-debug-it)
- [S34. Pagination on 50 million rows](#s34-you-need-to-implement-pagination-for-a-table-containing-50-million-records-which-approach-would-you-choose)
- [S35. Duplicates after joins](#s35-a-stored-procedure-returns-duplicate-records-after-joining-multiple-tables-how-will-you-identify-the-issue)
- [S36. Audit trail: triggers vs application](#s36-you-need-to-implement-an-audit-trail-whenever-employee-information-is-updated-would-you-use-triggers-or-application-level-auditing-why)
- [S37. Multiple SPs as one business operation](#s37-you-need-to-execute-multiple-stored-procedures-as-one-business-operation-how-would-you-handle-transaction-management)
- [S38. Different plans for different parameters](#s38-a-stored-procedure-is-generating-different-execution-plans-for-different-parameter-values-how-will-you-investigate)
- [S39. Batch processing 1 million rows](#s39-you-need-to-process-1-million-employee-records-in-batches-how-would-you-implement-batch-processing)
- [S40. Intermittent timeouts](#s40-a-stored-procedure-is-timing-out-intermittently-how-will-you-identify-whether-the-issue-is-blocking-execution-plan-parameter-sniffing-or-resource-contention)

---

## A. Query Optimization and Performance

### S1. A Stored Procedure takes 2 seconds in development but 45 seconds in production. How will you troubleshoot it?

**What the interviewer is checking:** Whether you understand that dev and prod differ in data volume, statistics, plans, blocking and hardware — and that you diagnose with evidence, not guesses.

**Real-world example:** `usp_GetMonthlyPayroll` ran in 2 seconds on the dev database (5,000 employees). In production (800,000 employees, 6 years of salary history) it took 45 seconds on payroll day, and HR users got timeouts.

**Step-by-step approach:**
1. Confirm the problem: is it slow every time, or only at certain times (payroll day, during ETL jobs)?
2. Check if it is *waiting* (blocking, I/O, memory grant) or *working* (CPU, reads) using `sys.dm_exec_requests` / `sp_WhoIsActive` while it runs.
3. Get the **actual production execution plan** (Query Store or the plan cache) and compare with dev. Look for scans, key lookups, spills, bad row estimates.
4. Compare data volume, statistics freshness, index differences, and compatibility level / server settings (MAXDOP, cost threshold) between environments.
5. Check for parameter sniffing — a plan compiled for a small value reused for a big one.
6. Fix the root cause (index, statistics update, rewrite, plan forcing), test on a prod-sized copy, and deploy.
7. Prevent: keep a prod-like dataset in UAT, enable Query Store, set up alerting on long-running queries.

**SQL example:**
```sql
-- 1. What is it doing right now? (or EXEC sp_WhoIsActive @get_plans = 1;)
SELECT r.session_id, r.status, r.wait_type, r.wait_time, r.blocking_session_id,
       r.cpu_time, r.logical_reads, r.total_elapsed_time,
       SUBSTRING(t.text, r.statement_start_offset/2 + 1,
         (CASE WHEN r.statement_end_offset = -1 THEN DATALENGTH(t.text)
               ELSE r.statement_end_offset END - r.statement_start_offset)/2 + 1) AS running_stmt,
       p.query_plan
FROM sys.dm_exec_requests r
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) t
CROSS APPLY sys.dm_exec_query_plan(r.plan_handle) p
WHERE r.session_id <> @@SPID AND r.session_id > 50;

-- 2. Historical stats for the procedure
SELECT OBJECT_NAME(ps.object_id) AS proc_name, ps.execution_count,
       ps.total_elapsed_time / ps.execution_count / 1000 AS avg_ms,
       ps.total_logical_reads / ps.execution_count AS avg_reads,
       ps.cached_time
FROM sys.dm_exec_procedure_stats ps
WHERE ps.object_id = OBJECT_ID('dbo.usp_GetMonthlyPayroll');

-- 3. Statistics freshness on the big tables
SELECT OBJECT_NAME(s.object_id) AS table_name, s.name AS stat_name,
       sp.last_updated, sp.rows, sp.modification_counter
FROM sys.stats s
CROSS APPLY sys.dm_db_stats_properties(s.object_id, s.stats_id) sp
WHERE s.object_id IN (OBJECT_ID('dbo.Employee'), OBJECT_ID('dbo.EmployeeSalaryHistory'));

-- 4. Measure the effect of a fix
SET STATISTICS IO, TIME ON;
EXEC dbo.usp_GetMonthlyPayroll @PayMonth = '2026-10-01';
SET STATISTICS IO, TIME OFF;

-- Typical fixes
UPDATE STATISTICS dbo.EmployeeSalaryHistory WITH FULLSCAN;

CREATE NONCLUSTERED INDEX IX_SalaryHistory_Employee_Effective
ON dbo.EmployeeSalaryHistory (EmployeeId, EffectiveDate DESC)
INCLUDE (Salary);
```

**Interview answer (7 yrs experience):** "First I check whether production is waiting or working — I run `sp_WhoIsActive` or query `sys.dm_exec_requests` while the procedure runs, so I immediately know if it is blocked, waiting on I/O, or burning CPU. Then I pull the actual production plan from Query Store, because a dev plan built on 5,000 rows tells me nothing about 800,000 rows. Most of the time the cause is one of four things: missing index that only hurts at scale, stale statistics, parameter sniffing, or blocking from another job. In production we had exactly this on payroll — the salary history table had no index on `(EmployeeId, EffectiveDate)`, so it was a full scan of 40 million rows; one covering index brought it to under 2 seconds. I always verify the fix with `SET STATISTICS IO` on a prod-sized copy before deploying. To prevent it, we keep a masked prod-size dataset in UAT and keep Query Store on in production."

**Key takeaway:** Dev speed proves nothing — diagnose production using its real plan, waits and statistics.

---

### S2. A query is returning 10 million records and taking 5 minutes. How will you optimize it?

**What the interviewer is checking:** Whether you question the requirement first, then know techniques for large result sets (filtering, paging, columns, aggregation, batching).

**Real-world example:** An "Export All Attendance" screen ran `SELECT * FROM EmployeeAttendance` joined to Employee. It returned 10 million rows to a web API, which then tried to build an Excel file in memory — and the app pool crashed.

**Step-by-step approach:**
1. Ask *why* 10 million rows are needed. No human reads 10 million rows. Usually the real need is a filtered list, a summary, or a file export.
2. Check where time goes: SQL execution vs network transfer (`ASYNC_NETWORK_IO` wait means the client is slow to consume).
3. Reduce the data: add filters (date range, department), select only needed columns, aggregate in SQL.
4. If all rows are truly needed (export/ETL), stream them in batches (keyset paging) or use a bulk tool (BCP/SSIS) and run off-hours or on a read replica.
5. Index for the filter and sort; avoid `SELECT *` so a covering index can be used.
6. Prevent: enforce mandatory filters and max page size in the API.

**SQL example:**
```sql
-- Diagnose: is SQL slow, or is the client slow to read?
SELECT session_id, wait_type, wait_time, last_wait_type
FROM sys.dm_exec_requests WHERE session_id = 87;   -- ASYNC_NETWORK_IO => client/network bottleneck

-- Bad
SELECT * FROM dbo.EmployeeAttendance a JOIN dbo.Employee e ON e.EmployeeId = a.EmployeeId;

-- Better: summarize in SQL instead of sending raw rows
SELECT a.EmployeeId, e.EmployeeName,
       SUM(CASE WHEN a.Status = 'P' THEN 1 ELSE 0 END) AS PresentDays,
       SUM(CASE WHEN a.Status = 'A' THEN 1 ELSE 0 END) AS AbsentDays
FROM dbo.EmployeeAttendance a
JOIN dbo.Employee e ON e.EmployeeId = a.EmployeeId
WHERE a.AttendanceDate >= '2026-10-01' AND a.AttendanceDate < '2026-11-01'
GROUP BY a.EmployeeId, e.EmployeeName;

-- If all rows are really needed: stream in keyset batches
DECLARE @LastId BIGINT = 0;
SELECT TOP (50000) Id, EmployeeId, AttendanceDate, Status
FROM dbo.EmployeeAttendance
WHERE Id > @LastId
ORDER BY Id;           -- app remembers the last Id and asks for the next batch

-- Supporting index
CREATE NONCLUSTERED INDEX IX_Attendance_Date
ON dbo.EmployeeAttendance (AttendanceDate) INCLUDE (EmployeeId, Status);
```

**Interview answer (7 yrs experience):** "My first question is a business one — who needs 10 million rows? In most cases the user wants a summary or a filtered list, so I push the aggregation into SQL and return a few thousand rows. I also check the wait type; if it is `ASYNC_NETWORK_IO`, the SQL part is fine and the application is the bottleneck, which is very common with big exports. If the full data really is needed, for example an export for a payroll vendor, I stream it in keyset batches or use BCP/SSIS off-hours or against a read-only replica, rather than loading everything into API memory. I remove `SELECT *` so a covering index can serve the query. In production we put a mandatory date-range filter and a page-size limit in the API so nobody can trigger this again."

**Key takeaway:** Challenge the requirement first; then filter, aggregate, page or bulk-export — never ship 10 million rows to a UI.

---

### S3. Your application has started experiencing slow database responses after deploying new code. How will you identify whether the issue is SQL-related?

**What the interviewer is checking:** A structured approach to isolate app vs database, and use of Query Store to compare before/after a deployment.

**Real-world example:** After the Friday release of the leave module, the "Apply Leave" API went from 200 ms to 6 seconds. The dev team blamed the database; the DBA blamed the code.

**Step-by-step approach:**
1. Check APM/application logs: how much of the request time is spent in the DB call vs elsewhere (serialization, external API, N+1 loops)?
2. On the SQL side, use Query Store "Regressed Queries" to compare before and after the deployment time.
3. Look for new queries, new plans, or a sudden jump in execution count (N+1 problem: one call became 500 calls).
4. Check waits and blocking at the time of slowness.
5. Check for data type mismatches introduced in code (e.g., Dapper sending `nvarchar` for a `varchar` column).
6. Fix: roll back or force the old plan, add index, fix the code pattern. Prevent: performance test before release, compare Query Store baselines.

**SQL example:**
```sql
-- Query Store: top queries by avg duration in the last 2 hours vs history
SELECT TOP 20 q.query_id, p.plan_id, qt.query_sql_text,
       rs.count_executions, rs.avg_duration/1000.0 AS avg_ms,
       rs.avg_logical_io_reads, rsi.start_time
FROM sys.query_store_query q
JOIN sys.query_store_query_text qt ON qt.query_text_id = q.query_text_id
JOIN sys.query_store_plan p        ON p.query_id = q.query_id
JOIN sys.query_store_runtime_stats rs ON rs.plan_id = p.plan_id
JOIN sys.query_store_runtime_stats_interval rsi ON rsi.runtime_stats_interval_id = rs.runtime_stats_interval_id
WHERE rsi.start_time > DATEADD(HOUR, -2, SYSUTCDATETIME())
ORDER BY rs.avg_duration DESC;

-- Execution count explosion (N+1 pattern)
SELECT TOP 20 qs.execution_count, qs.total_elapsed_time/1000 AS total_ms,
       SUBSTRING(st.text, 1, 200) AS query_text, qs.creation_time
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) st
ORDER BY qs.execution_count DESC;

-- If a plan regressed, force the previous good plan
EXEC sp_query_store_force_plan @query_id = 1234, @plan_id = 56;
```

```csharp
// The N+1 bug introduced in the release
foreach (var emp in employees)
{
    emp.LeaveBalance = await conn.QuerySingleAsync<decimal>(
        "SELECT Balance FROM dbo.LeaveBalance WHERE EmployeeId = @Id", new { Id = emp.EmployeeId });
}

// Fix: one round trip
var balances = (await conn.QueryAsync<(int EmployeeId, decimal Balance)>(
    "SELECT EmployeeId, Balance FROM dbo.LeaveBalance WHERE EmployeeId IN @Ids",
    new { Ids = employees.Select(e => e.EmployeeId) }))
    .ToDictionary(x => x.EmployeeId, x => x.Balance);

// Also log DB time separately so you can prove where time is spent
var sw = Stopwatch.StartNew();
var result = await conn.QueryAsync<Employee>(sql, param, commandTimeout: 30);
_logger.LogInformation("SQL {Name} took {Ms} ms", "GetEmployees", sw.ElapsedMilliseconds);
```

**Interview answer (7 yrs experience):** "I avoid the blame game by getting numbers from both sides. On the app side I check APM or our logs where we time each Dapper call — that tells me whether the request is slow inside SQL or around it. On the SQL side I open Query Store's Regressed Queries and Top Resource Consumers for the window after the deployment; new queries, new plans or a huge jump in execution count show up immediately. In one release, a single query was fine, but it was called 600 times per request inside a loop — classic N+1 — so we replaced it with one `IN @Ids` query. Another time Dapper was sending a string as `nvarchar` against a `varchar` column, causing an index scan. If a plan regressed I can force the old plan in Query Store as a quick fix while we correct the code. Going forward, we compare Query Store baselines in the performance-test environment before every release."

**Key takeaway:** Measure DB time vs app time, then use Query Store to compare before/after the release.

---

### S4. An execution plan shows a Clustered Index Scan instead of an Index Seek. How will you investigate?

**What the interviewer is checking:** That you know a scan is not always bad, and you know the common causes: no suitable index, non-SARGable predicate, implicit conversion, low selectivity, tipping point.

**Real-world example:** The employee search screen filtered `WHERE YEAR(JoiningDate) = 2024`. Even with an index on `JoiningDate`, the plan scanned the whole clustered index of 3 million rows.

**Step-by-step approach:**
1. Check if the scan is actually a problem: small table or query returning most rows — scan is correct.
2. Check if an index exists on the filter column(s), with the right key order.
3. Check the predicate is SARGable: no functions on the column, no leading `%` wildcard, no `ISNULL(col, ..)`.
4. Look for `CONVERT_IMPLICIT` warnings (data type mismatch).
5. Compare estimated vs actual rows — bad statistics can make the optimizer prefer a scan.
6. Check the tipping point: if too many key lookups are needed, the optimizer chooses a scan; make the index covering.
7. Fix and verify logical reads drop.

**SQL example:**
```sql
SET STATISTICS IO ON;

-- Non-SARGable: function on column => scan
SELECT EmployeeId, EmployeeName FROM dbo.Employee WHERE YEAR(JoiningDate) = 2024;

-- SARGable rewrite => seek
SELECT EmployeeId, EmployeeName FROM dbo.Employee
WHERE JoiningDate >= '2024-01-01' AND JoiningDate < '2025-01-01';

-- Other common culprits
WHERE EmployeeName LIKE '%kumar'          -- leading wildcard: scan
WHERE ISNULL(DepartmentId, 0) = 5         -- use DepartmentId = 5
WHERE EmployeeCode = N'E1001'             -- nvarchar vs varchar column => CONVERT_IMPLICIT

-- Is there a missing index suggestion?
SELECT d.statement, d.equality_columns, d.inequality_columns, d.included_columns,
       s.user_seeks, s.avg_user_impact
FROM sys.dm_db_missing_index_details d
JOIN sys.dm_db_missing_index_groups g ON g.index_handle = d.index_handle
JOIN sys.dm_db_missing_index_group_stats s ON s.group_handle = g.index_group_handle
WHERE d.database_id = DB_ID()
ORDER BY s.avg_user_impact * s.user_seeks DESC;

-- Covering index avoids the key-lookup tipping point
CREATE NONCLUSTERED INDEX IX_Employee_JoiningDate
ON dbo.Employee (JoiningDate) INCLUDE (EmployeeName, DepartmentId);
```

**Interview answer (7 yrs experience):** "First, I don't assume a scan is wrong — if the table is small or the query returns 40% of the rows, a scan is the cheapest option. If it should be a seek, I go through a checklist: is there an index with the filter column as the leading key, is the predicate SARGable, is there a `CONVERT_IMPLICIT` warning, and are estimated rows close to actual rows. In production the most common causes I've fixed are functions on columns like `YEAR(JoiningDate)` and nvarchar parameters against varchar columns. Another one is the tipping point — the index exists but would need too many key lookups, so the optimizer scans; adding INCLUDE columns fixes that. I check the missing index DMVs as hints but never create their suggestions blindly. I always confirm with `STATISTICS IO` that logical reads actually dropped."

**Key takeaway:** A scan is a symptom — check SARGability, data types, statistics, index key order and coverage.

---

### S5. A query is using an index, but performance is still poor. What could be the reasons?

**What the interviewer is checking:** Depth beyond "add an index" — key lookups, wrong index, scans on nonclustered index, fragmentation, bad estimates, spills, blocking.

**Real-world example:** The attendance dashboard used `IX_Attendance_EmployeeId`, but the query still took 8 seconds. The plan showed an index seek followed by 2 million key lookups because the query needed `Status` and `AttendanceDate`, which were not in the index.

**Step-by-step approach:**
1. Look at the actual plan: is it a seek or a *scan* of the nonclustered index? Seek with a residual predicate?
2. Check for Key Lookups with high execution counts.
3. Compare estimated vs actual rows (stale stats, parameter sniffing).
4. Look for spills to tempdb (sort/hash warnings) — memory grant too small.
5. Check if the query is waiting (blocking, I/O) rather than executing.
6. Check index key order (range column first makes equality seeks poor), fragmentation and page density.
7. Check if heavy work is elsewhere — scalar UDFs, sorts, multi-statement TVFs.

**SQL example:**
```sql
-- Index exists on EmployeeId only
-- CREATE INDEX IX_Attendance_EmployeeId ON dbo.EmployeeAttendance(EmployeeId);

SET STATISTICS IO, TIME ON;
SELECT AttendanceDate, Status
FROM dbo.EmployeeAttendance
WHERE EmployeeId = 1001 AND AttendanceDate >= '2026-01-01';
-- Plan: Index Seek + Key Lookup (once per row) + residual predicate on AttendanceDate

-- Fix: equality column first, range second, include output columns
CREATE NONCLUSTERED INDEX IX_Attendance_Emp_Date
ON dbo.EmployeeAttendance (EmployeeId, AttendanceDate)
INCLUDE (Status)
WITH (DROP_EXISTING = OFF, ONLINE = ON);   -- ONLINE requires Enterprise edition

-- Check usage and fragmentation of existing indexes
SELECT i.name, us.user_seeks, us.user_scans, us.user_lookups, us.user_updates
FROM sys.indexes i
LEFT JOIN sys.dm_db_index_usage_stats us
  ON us.object_id = i.object_id AND us.index_id = i.index_id AND us.database_id = DB_ID()
WHERE i.object_id = OBJECT_ID('dbo.EmployeeAttendance');

SELECT index_id, avg_fragmentation_in_percent, avg_page_space_used_in_percent, page_count
FROM sys.dm_db_index_physical_stats(DB_ID(), OBJECT_ID('dbo.EmployeeAttendance'), NULL, NULL, 'SAMPLED');
```

**Interview answer (7 yrs experience):** "'Using an index' doesn't mean 'using it well'. The most common issue I see is a seek followed by thousands of key lookups, so I make the index covering with INCLUDE columns. The second is wrong key order — if the range column is first and the equality column second, the seek reads a huge range and filters with a residual predicate. Then I compare estimated vs actual rows; a big gap points to stale statistics or parameter sniffing, which also causes memory grant spills to tempdb. I also check whether the query is actually blocked, because no index helps if it's waiting on a lock. Scalar UDFs in the SELECT list are another hidden killer on SQL 2016/2017. In production, fixing key order and adding includes on the attendance index took the dashboard from 8 seconds to 150 ms."

**Key takeaway:** Check key lookups, key order, estimates, spills and waits — not just whether an index appears in the plan.

---

### S6. You have a table containing 100 million records. You need to search employee records by EmployeeCode, DepartmentId and JoiningDate. How will you design indexes?

**What the interviewer is checking:** Understanding of selectivity, equality-before-range ordering, covering indexes, and the write cost of extra indexes.

**Real-world example:** A multi-tenant HRMS stores 100 million employee records (current and ex-employees across clients). Search patterns: by EmployeeCode (exact, very common), by DepartmentId + JoiningDate range (HR reports).

**Step-by-step approach:**
1. Identify the real query patterns and their frequency (from Query Store / application logs).
2. EmployeeCode is unique and highly selective — give it its own unique index.
3. For DepartmentId + JoiningDate: equality column (DepartmentId) first, range column (JoiningDate) second.
4. Add INCLUDE columns only for columns the search screen returns, to avoid lookups.
5. Keep the clustered key narrow, unique and ever-increasing (EmployeeId).
6. Consider filtered indexes (e.g., only active employees) and partitioning for maintenance.
7. Validate with actual plans and monitor index usage; drop unused indexes.

**SQL example:**
```sql
-- Clustered: narrow, unique, increasing
ALTER TABLE dbo.Employee ADD CONSTRAINT PK_Employee PRIMARY KEY CLUSTERED (EmployeeId);

-- Exact search by code (unique, very selective)
CREATE UNIQUE NONCLUSTERED INDEX UX_Employee_EmployeeCode
ON dbo.Employee (EmployeeCode)
INCLUDE (EmployeeName, DepartmentId);

-- Department + date range: equality first, range second
CREATE NONCLUSTERED INDEX IX_Employee_Dept_JoiningDate
ON dbo.Employee (DepartmentId, JoiningDate)
INCLUDE (EmployeeCode, EmployeeName);

-- Optional: filtered index if most searches are on active employees
CREATE NONCLUSTERED INDEX IX_Employee_Active_Dept_Date
ON dbo.Employee (DepartmentId, JoiningDate)
INCLUDE (EmployeeCode, EmployeeName)
WHERE IsActive = 1;

-- Queries that benefit
SELECT EmployeeId, EmployeeName FROM dbo.Employee WHERE EmployeeCode = 'E000123';
SELECT EmployeeId, EmployeeCode, EmployeeName
FROM dbo.Employee
WHERE DepartmentId = 12 AND JoiningDate >= '2025-01-01' AND JoiningDate < '2026-01-01';
```

**Interview answer (7 yrs experience):** "I design indexes from query patterns, not from column lists. EmployeeCode is unique, so it gets a unique nonclustered index — that's a 4-5 page seek even on 100 million rows. For DepartmentId plus JoiningDate, I put the equality column first and the range column second, so SQL seeks directly to department 12 and reads only the date range. I avoid one wide index on all three columns, because a composite index only helps when the leading column is in the filter. I add INCLUDE columns only for what the screen returns, since every index adds cost to inserts and updates on a 100-million-row table. If 90% of searches are for active employees, a filtered index is much smaller and faster. After deployment I watch `sys.dm_db_index_usage_stats` and drop what isn't used."

**Key takeaway:** Index per query pattern: selective unique column alone, equality-then-range for composites, INCLUDE only what's returned.

---

### S7. A Stored Procedure executes quickly for one EmployeeId but takes 30 seconds for another EmployeeId. What could be the reason?

**What the interviewer is checking:** Recognizing parameter sniffing and data skew, and knowing multiple fixes with their trade-offs.

**Real-world example:** `usp_GetEmployeeAttendance @EmployeeId` returns 200 rows for a normal employee. A "system/bulk" employee ID used for contract workers has 3 million attendance rows. Whichever ID runs first after a restart decides the cached plan for everyone.

**Step-by-step approach:**
1. Run both parameter values with actual plans and compare row counts and plan shapes.
2. Check data distribution — skewed values (one ID with millions of rows).
3. Check the cached plan's compiled parameter value (in plan XML `ParameterCompiledValue`).
4. Confirm by running with `OPTION (RECOMPILE)` — if both become fast, it's parameter sniffing.
5. Choose a fix: `OPTION(RECOMPILE)` on that statement, `OPTIMIZE FOR`, branching for known heavy values, or Query Store plan forcing. On SQL 2022, Parameter Sensitive Plan optimization can help automatically.
6. Also check blocking or lots of data for that employee (it may legitimately be heavy).

**SQL example:**
```sql
-- Data skew check
SELECT TOP 10 EmployeeId, COUNT(*) AS cnt
FROM dbo.EmployeeAttendance GROUP BY EmployeeId ORDER BY cnt DESC;

-- What value was the cached plan compiled with?
SELECT qp.query_plan   -- look for ParameterCompiledValue in the XML
FROM sys.dm_exec_procedure_stats ps
CROSS APPLY sys.dm_exec_query_plan(ps.plan_handle) qp
WHERE ps.object_id = OBJECT_ID('dbo.usp_GetEmployeeAttendance');

-- Fix options
ALTER PROCEDURE dbo.usp_GetEmployeeAttendance @EmployeeId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT AttendanceDate, Status
    FROM dbo.EmployeeAttendance
    WHERE EmployeeId = @EmployeeId
    OPTION (RECOMPILE);                         -- option 1: fresh plan per call (CPU cost)
    -- OPTION (OPTIMIZE FOR (@EmployeeId UNKNOWN)); -- option 2: average plan
END;

-- Option 3: force a plan that is good for all values
EXEC sp_query_store_force_plan @query_id = 321, @plan_id = 12;

-- Quick relief (not a fix): evict only this plan
DECLARE @h VARBINARY(64) = (SELECT plan_handle FROM sys.dm_exec_procedure_stats
                            WHERE object_id = OBJECT_ID('dbo.usp_GetEmployeeAttendance'));
DBCC FREEPROCCACHE(@h);
```

**Interview answer (7 yrs experience):** "This is almost always parameter sniffing combined with data skew. SQL Server compiles the plan with the first value it sees — if that's a small employee, it picks a nested loop with key lookups, which is terrible when reused for an ID with 3 million rows. I confirm by checking the compiled parameter value in the cached plan and running both values with `OPTION (RECOMPILE)`. For fixes, if the procedure runs a few hundred times a day, statement-level `RECOMPILE` is the simplest and most reliable. If it runs thousands of times per second, I'd rather use `OPTIMIZE FOR UNKNOWN`, separate code paths for the known heavy IDs, or force a stable plan via Query Store. I avoid clearing the whole plan cache in production — at most I evict that single plan handle. On SQL 2022 with compatibility level 160, PSP optimization can keep multiple plans automatically."

**Key takeaway:** Different speeds for different parameters = parameter sniffing on skewed data; confirm with RECOMPILE, then pick a fix by call frequency.

---

### S8. A query performs well when executed directly in SSMS but becomes slow when called from a .NET application. How will you investigate?

**What the interviewer is checking:** Knowledge of SET options (ARITHABORT) causing separate plan cache entries, parameter sniffing, and implicit conversions from Dapper string parameters.

**Real-world example:** The employee lookup by `EmployeeCode` took 20 ms in SSMS but 4 seconds from the .NET API. Two causes were found: Dapper sent `EmployeeCode` as `nvarchar(4000)` against a `varchar(20)` column (index scan), and the app's cached plan was compiled for a bad parameter while SSMS got its own fresh plan.

**Step-by-step approach:**
1. Understand that SSMS sets `ARITHABORT ON` by default and ADO.NET/SqlClient uses `OFF`. Different SET options = **different plan cache entries**, so SSMS gets a fresh plan and hides the problem.
2. Find the app's cached plan in `sys.dm_exec_query_stats` / Query Store and check its `set_options` and compiled parameter values.
3. Reproduce exactly as the app does: same SET options and same parameter types (capture with Extended Events or Profiler `rpc_completed`).
4. Check for `CONVERT_IMPLICIT` in the plan — `nvarchar` parameter vs `varchar` column.
5. Fix the root cause: pass correct `DbType.AnsiString` in Dapper, fix parameter sniffing (S7). Don't "fix" by just setting ARITHABORT in the app.

**SQL example:**
```sql
-- See multiple cached plans for the same query with different SET options
SELECT st.text, qs.plan_handle, pa.value AS set_options, qs.execution_count,
       qs.total_elapsed_time / qs.execution_count AS avg_us
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) st
CROSS APPLY sys.dm_exec_plan_attributes(qs.plan_handle) pa
WHERE pa.attribute = 'set_options'
  AND st.text LIKE '%FROM dbo.Employee WHERE EmployeeCode%';

-- Reproduce app behaviour in SSMS
SET ARITHABORT OFF;
EXEC sp_executesql
  N'SELECT EmployeeId, EmployeeName FROM dbo.Employee WHERE EmployeeCode = @code',
  N'@code nvarchar(4000)', @code = N'E000123';
-- Plan shows CONVERT_IMPLICIT + Index Scan

-- Find implicit conversions in cached plans
SELECT TOP 20 st.text, qp.query_plan
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) st
CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) qp
WHERE CAST(qp.query_plan AS NVARCHAR(MAX)) LIKE '%CONVERT_IMPLICIT%';
```

```csharp
// Problem: C# string => nvarchar(4000) by default in Dapper
var emp = await conn.QueryFirstOrDefaultAsync<Employee>(
    "SELECT EmployeeId, EmployeeName FROM dbo.Employee WHERE EmployeeCode = @code",
    new { code = employeeCode });

// Fix 1: DbString with IsAnsi = true => varchar
var emp2 = await conn.QueryFirstOrDefaultAsync<Employee>(
    "SELECT EmployeeId, EmployeeName FROM dbo.Employee WHERE EmployeeCode = @code",
    new { code = new DbString { Value = employeeCode, IsAnsi = true, Length = 20 } });

// Fix 2: DynamicParameters with explicit type
var p = new DynamicParameters();
p.Add("@code", employeeCode, DbType.AnsiString, size: 20);
var emp3 = await conn.QueryFirstOrDefaultAsync<Employee>(
    "dbo.usp_GetEmployeeByCode", p, commandType: CommandType.StoredProcedure);

// Global option (affects all string params - use only if the DB is fully varchar)
// Dapper.SqlMapper.AddTypeMap(typeof(string), DbType.AnsiString);
```

**Interview answer (7 yrs experience):** "The classic reason is that SSMS runs with `ARITHABORT ON` and .NET runs with it `OFF`, so they get separate plan cache entries — SSMS compiles a fresh plan for my test value, while the app keeps reusing a plan sniffed for a bad value. So 'fast in SSMS' is misleading; I pull the application's actual cached plan from Query Store or `dm_exec_query_stats` and reproduce with the same SET options and parameter types. The second big cause with Dapper is data types — a C# string becomes `nvarchar(4000)`, and against a `varchar` column that causes `CONVERT_IMPLICIT` and an index scan. In production we fixed this with `DbString { IsAnsi = true }` or `DbType.AnsiString` in `DynamicParameters`. I don't treat setting ARITHABORT in the app as a fix — it only hides the real issue, which is usually parameter sniffing or type mismatch."

**Key takeaway:** SSMS and .NET use different SET options and thus different plans; reproduce with the app's real plan and parameter types.

---

### S9. A table has 20 indexes, and INSERT operations are becoming slow. How will you optimize the table?

**What the interviewer is checking:** Understanding of index write overhead and how to consolidate/drop indexes safely using usage stats.

**Real-world example:** `EmployeeAttendance` got a new index every time someone complained about a report. After 3 years it had 20 indexes. Biometric devices pushing 50,000 punches every morning at 9 AM started timing out.

**Step-by-step approach:**
1. Measure: insert duration, waits (`WRITELOG`, `PAGELATCH_EX`, lock waits), and plan of the insert (each index is a separate write).
2. Use `sys.dm_db_index_usage_stats` to find indexes with zero/low reads but high writes (check over a full business cycle — month-end reports too!).
3. Find duplicate and overlapping indexes (same leading columns) and merge them.
4. Disable first, monitor, then drop — easy rollback.
5. Check other insert costs: triggers, foreign keys without indexes, page splits from random GUID keys, fill factor.
6. For bulk loads, batch inserts in a single transaction / use `SqlBulkCopy` or TVPs.
7. Prevent: index review process before adding new indexes.

**SQL example:**
```sql
-- Reads vs writes per index (stats reset on restart - check uptime!)
SELECT sqlserver_start_time FROM sys.dm_os_sys_info;

SELECT i.name AS index_name, i.type_desc,
       ISNULL(us.user_seeks + us.user_scans + us.user_lookups, 0) AS reads,
       ISNULL(us.user_updates, 0) AS writes,
       us.last_user_seek, us.last_user_scan
FROM sys.indexes i
LEFT JOIN sys.dm_db_index_usage_stats us
  ON us.object_id = i.object_id AND us.index_id = i.index_id AND us.database_id = DB_ID()
WHERE i.object_id = OBJECT_ID('dbo.EmployeeAttendance') AND i.type > 0
ORDER BY reads ASC, writes DESC;

-- Find overlapping indexes (same key columns)
SELECT i.name, STRING_AGG(c.name, ', ') WITHIN GROUP (ORDER BY ic.key_ordinal) AS key_cols
FROM sys.indexes i
JOIN sys.index_columns ic ON ic.object_id = i.object_id AND ic.index_id = i.index_id AND ic.is_included_column = 0
JOIN sys.columns c ON c.object_id = ic.object_id AND c.column_id = ic.column_id
WHERE i.object_id = OBJECT_ID('dbo.EmployeeAttendance')
GROUP BY i.name ORDER BY key_cols;

-- Consolidate: IX_A(EmployeeId) and IX_B(EmployeeId, AttendanceDate) -> keep only the wider one
ALTER INDEX IX_Attendance_EmployeeId ON dbo.EmployeeAttendance DISABLE;  -- monitor for a cycle
-- DROP INDEX IX_Attendance_EmployeeId ON dbo.EmployeeAttendance;        -- later
```

**Interview answer (7 yrs experience):** "Every nonclustered index is an extra write for every insert, plus extra log and locks, so 20 indexes means one logical insert is 21 physical writes. I start with `sys.dm_db_index_usage_stats` to find indexes with high updates and near-zero reads, making sure the server uptime covers a full month so I don't drop the index the month-end payroll report needs. Then I look for duplicates and overlaps — an index on `EmployeeId` is redundant if another index starts with `EmployeeId, AttendanceDate`. I disable rather than drop first, so rollback is just a rebuild. I also check other costs like triggers, untrusted or unindexed foreign keys, and page splits. In production we went from 20 to 8 indexes on the attendance table and the morning biometric load stopped timing out. Now any new index needs a review against existing ones."

**Key takeaway:** Use index usage stats to drop unused and merge overlapping indexes — every index taxes every write.

---

### S10. Your query uses multiple OR conditions and performs poorly. How would you rewrite it?

**What the interviewer is checking:** Knowing why OR across different columns prevents seeks, and rewrites with UNION ALL, IN, or dynamic SQL for "catch-all" searches.

**Real-world example:** The HR search screen had optional filters: `WHERE (@Code IS NULL OR EmployeeCode = @Code) OR (@Name IS NULL OR EmployeeName LIKE @Name + '%') ...`. Any search scanned all 2 million employees.

**Step-by-step approach:**
1. Identify the OR type: same column (`= 1 OR = 2` → use `IN`), different columns, or optional-parameter "catch-all".
2. For ORs across different columns: rewrite to `UNION` / `UNION ALL` so each branch can seek its own index.
3. For catch-all optional filters: use `OPTION (RECOMPILE)` (simple) or parameterized dynamic SQL with `sp_executesql` (best for high frequency).
4. Ensure each branch has a supporting index.
5. Compare logical reads before and after.

**SQL example:**
```sql
-- Bad: OR across different columns => scan
SELECT EmployeeId, EmployeeName FROM dbo.Employee
WHERE EmployeeCode = @Code OR ManagerId = @ManagerId;

-- Rewrite: each branch seeks its own index; UNION removes overlap
SELECT EmployeeId, EmployeeName FROM dbo.Employee WHERE EmployeeCode = @Code
UNION
SELECT EmployeeId, EmployeeName FROM dbo.Employee WHERE ManagerId = @ManagerId;

-- Same column ORs => IN
WHERE DepartmentId IN (1, 4, 7)

-- Catch-all search: Option A - RECOMPILE (embeds actual values, removes NULL branches)
SELECT EmployeeId, EmployeeName FROM dbo.Employee
WHERE (@Code IS NULL OR EmployeeCode = @Code)
  AND (@DeptId IS NULL OR DepartmentId = @DeptId)
  AND (@FromDate IS NULL OR JoiningDate >= @FromDate)
OPTION (RECOMPILE);

-- Option B - parameterized dynamic SQL (plan reuse per filter combination, injection-safe)
DECLARE @sql NVARCHAR(MAX) = N'SELECT EmployeeId, EmployeeName FROM dbo.Employee WHERE 1 = 1';
IF @Code     IS NOT NULL SET @sql += N' AND EmployeeCode = @Code';
IF @DeptId   IS NOT NULL SET @sql += N' AND DepartmentId = @DeptId';
IF @FromDate IS NOT NULL SET @sql += N' AND JoiningDate >= @FromDate';
EXEC sp_executesql @sql,
     N'@Code varchar(20), @DeptId int, @FromDate date',
     @Code, @DeptId, @FromDate;
```

**Interview answer (7 yrs experience):** "An OR across different columns usually forces a scan because no single index can satisfy both sides. My first rewrite is UNION — or UNION ALL if the branches can't overlap — so each branch seeks its own index. If the ORs are on the same column, `IN` is cleaner and optimizes fine. The trickiest case is the optional-filter search screen with `@Param IS NULL OR Col = @Param`; one cached plan can't be good for every combination. For low-frequency searches I add `OPTION (RECOMPILE)` so the optimizer removes the NULL branches. For high-frequency searches I build parameterized dynamic SQL with `sp_executesql`, which gives one reusable plan per combination and stays safe from SQL injection. In production that took our employee search from 6 seconds to under 100 ms."

**Key takeaway:** Split ORs into UNION branches that can seek; handle catch-all filters with RECOMPILE or parameterized dynamic SQL.

---

## B. Transactions, Deadlocks and Concurrency

### S11. Two users update the same employee record simultaneously. How will you prevent data inconsistency?

**What the interviewer is checking:** Understanding of the "lost update" problem and the choice between optimistic (ROWVERSION) and pessimistic (UPDLOCK) concurrency.

**Real-world example:** HR Executive A opens employee 1001 to change the department. HR Manager B opens the same record to change the salary. A saves, then B saves her stale copy — A's department change is silently overwritten (lost update).

**Step-by-step approach:**
1. Identify the pattern: read → user edits for minutes → write. Holding locks while a user thinks is not possible, so use **optimistic concurrency**.
2. Add a `ROWVERSION` column; return it with the read; include it in the UPDATE's WHERE clause.
3. If 0 rows are affected, someone else changed the row — tell the user to reload (HTTP 409 Conflict).
4. For short server-side read-modify-write (e.g., incrementing a balance), use pessimistic locking (`UPDLOCK`) inside a transaction, or a single atomic UPDATE.
5. Update only changed columns to reduce conflicts.

**SQL example:**
```sql
ALTER TABLE dbo.Employee ADD RowVer ROWVERSION;

-- Read
SELECT EmployeeId, EmployeeName, DepartmentId, Salary, RowVer
FROM dbo.Employee WHERE EmployeeId = @EmployeeId;

-- Save only if nobody changed it since our read
UPDATE dbo.Employee
SET DepartmentId = @DepartmentId, Salary = @Salary
WHERE EmployeeId = @EmployeeId AND RowVer = @RowVer;

IF @@ROWCOUNT = 0
    THROW 50001, 'Record was modified by another user. Please reload.', 1;

-- Pessimistic alternative for short server-side logic
BEGIN TRAN;
    SELECT Salary FROM dbo.Employee WITH (UPDLOCK, ROWLOCK) WHERE EmployeeId = @EmployeeId;
    -- calculate...
    UPDATE dbo.Employee SET Salary = @NewSalary WHERE EmployeeId = @EmployeeId;
COMMIT;

-- Best of all when possible: single atomic statement
UPDATE dbo.LeaveBalance SET Balance = Balance - @Days
WHERE EmployeeId = @EmployeeId AND Balance >= @Days;
```

**Interview answer (7 yrs experience):** "The risk here is the lost update — the last save wins and silently overwrites the first. For edit screens I use optimistic concurrency: a `ROWVERSION` column is returned with the record, and the UPDATE includes `WHERE RowVer = @RowVer`. If no row is affected, the API returns 409 and the UI asks the user to reload. I don't use pessimistic locks for UI edits because a user might keep the screen open for 20 minutes holding a lock. For short server-side read-modify-write logic, like leave balance deduction, I either write one atomic UPDATE with the condition in the WHERE clause, or use `UPDLOCK` inside a short transaction. In our HRMS, every master table has a RowVer column, and Dapper maps it as `byte[]`."

**Key takeaway:** Use ROWVERSION-based optimistic concurrency for user edits; UPDLOCK or atomic UPDATEs for short server logic.

---

### S12. Two Stored Procedures are updating the same tables in different orders, causing deadlocks. How will you fix this?

**What the interviewer is checking:** Understanding of the classic cycle deadlock and that consistent access order is the primary fix.

**Real-world example:** `usp_ApproveSalaryRevision` updates `Employee` then `EmployeeSalaryHistory`. `usp_CorrectSalaryHistory` updates `EmployeeSalaryHistory` then `Employee`. When both run for the same employee at the same time, each holds one lock and waits for the other — deadlock.

**Step-by-step approach:**
1. Confirm with the deadlock graph (system_health XE) which objects and procedures are involved.
2. Fix the root cause: make all procedures access tables in the **same order** (e.g., always Employee → SalaryHistory).
3. Keep transactions short: no user interaction, no external calls inside.
4. Take the right lock up front if you read then update (`UPDLOCK`) to avoid lock conversion deadlocks.
5. Make sure the UPDATE's WHERE clause uses an index, so fewer rows are locked.
6. Add retry logic for error 1205 in the app as a safety net.

**SQL example:**
```sql
-- BEFORE (proc 2 uses reverse order)
BEGIN TRAN;
  UPDATE dbo.EmployeeSalaryHistory SET Salary = @Salary WHERE Id = @HistoryId;
  UPDATE dbo.Employee SET Salary = @Salary WHERE EmployeeId = @EmployeeId;
COMMIT;

-- AFTER: same order as proc 1 -> Employee first, then history
CREATE OR ALTER PROCEDURE dbo.usp_CorrectSalaryHistory
    @EmployeeId INT, @HistoryId INT, @Salary DECIMAL(18,2)
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    BEGIN TRAN;
        UPDATE dbo.Employee
        SET Salary = @Salary WHERE EmployeeId = @EmployeeId;      -- 1st: Employee

        UPDATE dbo.EmployeeSalaryHistory
        SET Salary = @Salary WHERE Id = @HistoryId;               -- 2nd: History
    COMMIT;
END;

-- Ensure narrow locking via index
CREATE INDEX IX_SalaryHistory_EmployeeId ON dbo.EmployeeSalaryHistory (EmployeeId);
```

**Interview answer (7 yrs experience):** "A deadlock between two procedures touching the same tables in opposite order is a textbook cycle: each holds a lock the other needs. I first confirm it from the deadlock graph in the system_health session so I know the exact statements. The real fix is a consistent access order — we documented a rule in our team that parent tables are always touched before child tables, for example Employee before EmployeeSalaryHistory. I also keep the transaction as short as possible and make sure the WHERE clauses are indexed, so each statement locks one row instead of scanning and locking many. If the procedure reads before updating, I use `UPDLOCK` on the read to avoid shared-to-exclusive conversion deadlocks. Finally, the application retries error 1205 a couple of times, but retry is the safety net, not the fix."

**Key takeaway:** Access tables in the same order everywhere, keep transactions short and indexed, and retry 1205 as a safety net.

---

### S13. A transaction starts but never commits or rolls back. What problems can occur?

**What the interviewer is checking:** Awareness of orphaned/open transactions and their impact on blocking, log growth, version store and connection pooling.

**Real-world example:** A payroll SP did `BEGIN TRAN`, then hit an error and returned without `ROLLBACK`. The connection went back to the pool with an open transaction. For the next 2 hours, attendance inserts were blocked, and the transaction log grew from 5 GB to 120 GB.

**Step-by-step approach:**
1. Problems: locks held forever → **blocking chains**; transaction log can't truncate → **log growth / disk full**; with RCSI/snapshot the **tempdb version store grows**; later work on the same pooled connection silently joins the open transaction.
2. Find it: `DBCC OPENTRAN`, `sys.dm_tran_active_transactions`, sessions with `open_transaction_count > 0` and status `sleeping`.
3. Identify the host/app/login and last SQL text; decide to KILL (it will roll back — can take time).
4. Fix the code: `SET XACT_ABORT ON` + `TRY/CATCH` with `ROLLBACK` when `@@TRANCOUNT > 0`; in .NET use `using` blocks.
5. Prevent: alert on transactions open longer than N minutes.

**SQL example:**
```sql
-- Oldest active transaction in the database
DBCC OPENTRAN;

-- Sleeping sessions holding open transactions (the usual culprit)
SELECT s.session_id, s.login_name, s.host_name, s.program_name, s.status,
       s.open_transaction_count, s.last_request_end_time,
       at.transaction_begin_time, t.text AS last_sql
FROM sys.dm_exec_sessions s
JOIN sys.dm_tran_session_transactions st ON st.session_id = s.session_id
JOIN sys.dm_tran_active_transactions at ON at.transaction_id = st.transaction_id
JOIN sys.dm_exec_connections c ON c.session_id = s.session_id
CROSS APPLY sys.dm_exec_sql_text(c.most_recent_sql_handle) t
WHERE s.open_transaction_count > 0
ORDER BY at.transaction_begin_time;

-- Why can't the log truncate?
SELECT name, log_reuse_wait_desc FROM sys.databases WHERE name = DB_NAME();  -- ACTIVE_TRANSACTION

-- Last resort (rollback may take as long as the work done)
-- KILL 73;

-- Prevention pattern
CREATE OR ALTER PROCEDURE dbo.usp_ProcessPayroll @PayMonth DATE
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;              -- auto-rollback on most errors and on client timeout
    BEGIN TRY
        BEGIN TRAN;
            -- work...
        COMMIT;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        THROW;
    END CATCH
END;
```

**Interview answer (7 yrs experience):** "An open transaction is dangerous because it holds its locks indefinitely, so it becomes the head of a blocking chain. It also stops the transaction log from truncating, so the log keeps growing until the disk fills, and with RCSI it keeps the tempdb version store from being cleaned. With connection pooling it's even worse — the next request on that connection can silently run inside the old transaction. I find it with `DBCC OPENTRAN` and by looking for sleeping sessions with `open_transaction_count > 0`, then identify the app and host before deciding to kill it. The real fix is in the code: `SET XACT_ABORT ON` plus TRY/CATCH with rollback in every procedure, and `using` blocks for transactions in .NET. Note that a client command timeout does not roll back the transaction unless XACT_ABORT is on — that's what caused our incident. We now have an alert for any transaction open longer than 5 minutes."

**Key takeaway:** Open transactions cause blocking, log growth and pooled-connection side effects — always use XACT_ABORT ON with TRY/CATCH.

---

### S14. A report query is blocking INSERT and UPDATE operations. How will you resolve it?

**What the interviewer is checking:** Knowing reader-writer blocking under READ COMMITTED and solutions: RCSI/SNAPSHOT, indexing, read replicas — not NOLOCK.

**Real-world example:** The HR head runs a "Department-wise Headcount and Attendance" report at 10 AM. It scans `EmployeeAttendance` for 90 seconds, holding shared locks, and the biometric attendance inserts queue up behind it.

**Step-by-step approach:**
1. Confirm the blocking chain: who is the head blocker, what lock and resource (`sys.dm_exec_requests`, `sys.dm_tran_locks`, `sp_WhoIsActive`).
2. Tune the report so it runs faster and locks less (index, filter, avoid scans).
3. Enable **Read Committed Snapshot Isolation (RCSI)** so readers read row versions and don't take shared locks — readers and writers stop blocking each other.
4. Or use `SNAPSHOT` isolation only for report sessions.
5. Move heavy reporting to an Always On readable secondary or a reporting database.
6. Avoid `NOLOCK` as the fix (dirty and inconsistent reads — see S15).

**SQL example:**
```sql
-- Find blocking chain
SELECT r.session_id, r.blocking_session_id, r.wait_type, r.wait_time, r.wait_resource,
       t.text
FROM sys.dm_exec_requests r
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) t
WHERE r.blocking_session_id <> 0;

-- Or: EXEC sp_WhoIsActive @find_block_leaders = 1, @sort_order = '[blocked_session_count] DESC';

-- Locks held by the head blocker
SELECT resource_type, resource_description, request_mode, request_status
FROM sys.dm_tran_locks WHERE request_session_id = 64;

-- Option 1: RCSI (needs a short exclusive window; adds tempdb version store load)
ALTER DATABASE HRMS SET READ_COMMITTED_SNAPSHOT ON WITH ROLLBACK IMMEDIATE;

-- Option 2: SNAPSHOT only for reports
ALTER DATABASE HRMS SET ALLOW_SNAPSHOT_ISOLATION ON;
-- in report proc:
SET TRANSACTION ISOLATION LEVEL SNAPSHOT;
SELECT d.DepartmentName, COUNT(*) AS Headcount
FROM dbo.Employee e JOIN dbo.Department d ON d.DepartmentId = e.DepartmentId
GROUP BY d.DepartmentName;

-- Monitor version store after enabling
SELECT SUM(version_store_reserved_page_count) * 8 / 1024 AS version_store_mb
FROM tempdb.sys.dm_db_file_space_usage;
```

**Interview answer (7 yrs experience):** "Under the default READ COMMITTED, a long report scan takes shared locks that conflict with writers, so first I confirm the chain with `sp_WhoIsActive` and see what resource is locked. Step one is making the report cheaper — an index or a date filter often turns a 90-second scan into a 2-second seek, and the blocking disappears. The structural fix I prefer is Read Committed Snapshot Isolation: readers get the last committed version from tempdb, so readers don't block writers and writers don't block readers, without changing application code. The trade-off is extra tempdb usage and a 14-byte version pointer per row, so I monitor the version store. If reports are heavy, we route them to an Always On readable secondary. I don't use NOLOCK as a fix, because it gives dirty and even duplicated or missing rows."

**Key takeaway:** Tune the report, then use RCSI/SNAPSHOT or a read replica — not NOLOCK — to stop reader-writer blocking.

---

### S15. Your application uses NOLOCK everywhere. What problems can occur in production?

**What the interviewer is checking:** Knowing NOLOCK's real risks beyond "dirty reads" — missing/duplicate rows, error 601, and that it doesn't stop all locking.

**Real-world example:** A payslip summary used NOLOCK. During a page split caused by concurrent inserts, an employee was counted twice and the total salary payout on the report was off by ₹1.2 lakh. Another day, a rolled-back salary update was shown on a payslip PDF already emailed to the employee.

**Step-by-step approach:**
1. List the problems:
   - **Dirty reads**: reading uncommitted data that later rolls back.
   - **Missing rows or duplicate rows** during allocation-order scans and page splits.
   - Error **601** "Could not continue scan with NOLOCK due to data movement".
   - Inconsistent data across columns/rows (half-updated state).
   - It does **not** prevent Sch-S locks and is ignored on UPDATE/DELETE targets.
2. Find NOLOCK usage in code (`sys.sql_modules`, repo search).
3. Replace with RCSI at database level — consistent reads without blocking.
4. Remove hints gradually, starting with financial/payroll queries.

**SQL example:**
```sql
-- Find all modules using NOLOCK / READ UNCOMMITTED
SELECT OBJECT_SCHEMA_NAME(object_id) AS schema_name, OBJECT_NAME(object_id) AS object_name
FROM sys.sql_modules
WHERE definition LIKE '%NOLOCK%' OR definition LIKE '%READ UNCOMMITTED%';

-- Demonstrating a dirty read
-- Session 1
BEGIN TRAN;
UPDATE dbo.Employee SET Salary = Salary * 10 WHERE EmployeeId = 1001;
-- (not committed yet)

-- Session 2
SELECT Salary FROM dbo.Employee WITH (NOLOCK) WHERE EmployeeId = 1001;  -- sees 10x salary!

-- Session 1
ROLLBACK;   -- Session 2 reported a salary that never existed

-- Better replacement: RCSI gives committed data without blocking
ALTER DATABASE HRMS SET READ_COMMITTED_SNAPSHOT ON WITH ROLLBACK IMMEDIATE;
```

**Interview answer (7 yrs experience):** "Most developers know NOLOCK gives dirty reads, but the bigger production problem is that it can skip rows or read the same row twice when pages split during an allocation-order scan, so totals can simply be wrong. It can also fail with error 601 when data moves during the scan. For a payroll system that's unacceptable — we once had a salary summary that double-counted an employee. NOLOCK was usually added to fix blocking, so the right replacement is RCSI, which gives non-blocking reads of committed data. My approach is to enable RCSI after testing tempdb capacity, then remove the hints step by step, starting with financial queries. I'd still accept NOLOCK for rough monitoring queries like approximate row counts, where accuracy doesn't matter."

**Key takeaway:** NOLOCK can return uncommitted, missing or duplicated rows — use RCSI for non-blocking, correct reads.

---

### S16. A financial transaction updates two tables. The first update succeeds, but the second fails. How will you ensure both updates are rolled back?

**What the interviewer is checking:** Atomicity: explicit transactions, `SET XACT_ABORT ON`, TRY/CATCH, `@@TRANCOUNT`, and the fact that not every error rolls back automatically.

**Real-world example:** Salary revision: update `Employee.Salary` and insert into `EmployeeSalaryHistory`. The insert failed due to a CHECK constraint, but the Employee update stayed — salary changed with no history record, and auditors flagged it.

**Step-by-step approach:**
1. Wrap both statements in one explicit transaction.
2. Use `SET XACT_ABORT ON` — without it, many runtime errors (like constraint violations) only abort the statement, and the transaction continues and commits the first update!
3. Use TRY/CATCH: on error, `IF @@TRANCOUNT > 0 ROLLBACK`, then `THROW` to return the error to the caller.
4. Check business rules (`@@ROWCOUNT = 0`) and raise errors explicitly.
5. Log errors to an error table after rollback.

**SQL example:**
```sql
CREATE OR ALTER PROCEDURE dbo.usp_ReviseSalary
    @EmployeeId INT, @NewSalary DECIMAL(18,2), @EffectiveDate DATE
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;   -- any runtime error dooms and rolls back the whole transaction

    BEGIN TRY
        BEGIN TRAN;

        UPDATE dbo.Employee
        SET Salary = @NewSalary
        WHERE EmployeeId = @EmployeeId;

        IF @@ROWCOUNT = 0
            THROW 50010, 'Employee not found.', 1;

        INSERT INTO dbo.EmployeeSalaryHistory (EmployeeId, Salary, EffectiveDate)
        VALUES (@EmployeeId, @NewSalary, @EffectiveDate);

        COMMIT;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;

        INSERT INTO dbo.ErrorLog (ProcName, ErrorNumber, ErrorMessage, LoggedAt)
        VALUES (OBJECT_NAME(@@PROCID), ERROR_NUMBER(), ERROR_MESSAGE(), SYSDATETIME());

        THROW;   -- re-raise to the application
    END CATCH
END;
```

**Interview answer (7 yrs experience):** "I wrap both statements in one explicit transaction with TRY/CATCH, and — this is the part people miss — I always add `SET XACT_ABORT ON`. Without it, an error like a constraint violation only fails that one statement; the transaction stays open and if the code reaches COMMIT, the first update is committed alone. In the CATCH block I check `@@TRANCOUNT > 0` before rollback, log the error, and `THROW` so the application knows it failed. I also treat business failures, like zero rows updated, as errors. In production we had exactly this bug: salary updated but no history row, because an old procedure lacked XACT_ABORT. Now it's a standard part of our procedure template and code review checklist."

**Key takeaway:** Explicit transaction + SET XACT_ABORT ON + TRY/CATCH with ROLLBACK and THROW guarantees all-or-nothing.

---

### S17. An application frequently encounters deadlocks during peak hours. How will you identify the root cause?

**What the interviewer is checking:** Ability to capture and read deadlock graphs (system_health XE), and identify common patterns.

**Real-world example:** At 9:00–9:30 AM, 40,000 employees punch in, and the leave approval workflow runs too. The app log shows dozens of "Transaction (Process ID 87) was deadlocked… chosen as the deadlock victim" (error 1205) every day.

**Step-by-step approach:**
1. Collect deadlock graphs — the **system_health** Extended Events session captures them by default (no setup needed).
2. Read the graph: processes (victim and survivor), statements, resources (key/page/object), lock modes held and requested.
3. Find the pattern: opposite access order, lock conversion (S→X), missing index causing scans, parallelism, or key lookup deadlocks.
4. Fix: consistent order, add indexes so fewer rows are locked, shorter transactions, `UPDLOCK` for read-then-update, RCSI to remove reader-writer deadlocks.
5. Add retry logic for error 1205 in the app.
6. Monitor deadlock count trends after the fix.

**SQL example:**
```sql
-- Extract deadlock graphs from system_health
SELECT xed.value('@timestamp', 'datetime2') AS deadlock_time,
       xed.query('.') AS deadlock_graph          -- click to open; save as .xdl to view graphically
FROM (
    SELECT CAST(target_data AS XML) AS target_data
    FROM sys.dm_xe_session_targets st
    JOIN sys.dm_xe_sessions s ON s.address = st.event_session_address
    WHERE s.name = 'system_health' AND st.target_name = 'ring_buffer'
) AS data
CROSS APPLY target_data.nodes('RingBufferTarget/event[@name="xml_deadlock_report"]') AS x(xed)
ORDER BY deadlock_time DESC;

-- From the event file (keeps more history)
SELECT CAST(event_data AS XML).query('(event/data/value/deadlock)[1]') AS deadlock_graph,
       CAST(event_data AS XML).value('(event/@timestamp)[1]', 'datetime2') AS deadlock_time
FROM sys.fn_xe_file_target_read_file('system_health*.xel', NULL, NULL, NULL)
WHERE object_name = 'xml_deadlock_report';

-- Map a key resource in the graph (e.g., "KEY: 7:72057594043039744") to the index
SELECT OBJECT_NAME(p.object_id) AS table_name, i.name AS index_name
FROM sys.partitions p
JOIN sys.indexes i ON i.object_id = p.object_id AND i.index_id = p.index_id
WHERE p.hobt_id = 72057594043039744;

-- Track how many deadlocks happened
SELECT cntr_value FROM sys.dm_os_performance_counters
WHERE counter_name = 'Number of Deadlocks/sec' AND instance_name = '_Total';
```

**Interview answer (7 yrs experience):** "I don't guess with deadlocks — I pull the graphs from the system_health Extended Events session, which records every deadlock by default. The graph tells me the two statements, the exact index or key involved, and which locks each side held and wanted. From that I classify it: opposite table order, S-to-X lock conversion on read-then-update, a scan locking too many rows because of a missing index, or a key-lookup deadlock between a nonclustered and clustered index. In our attendance system the root cause was an UPDATE without an index on `(EmployeeId, AttendanceDate)` — it scanned and locked many rows; adding the index removed 90% of deadlocks. The rest were reader-writer deadlocks that RCSI eliminated. We also added Polly retry for error 1205 and track the deadlock counter on our dashboard."

**Key takeaway:** Read the deadlock graphs from system_health, classify the pattern, fix order/indexes/transaction length, and retry 1205.

---

### S18. A user reads data while another transaction is updating it. How will isolation levels affect the result?

**What the interviewer is checking:** Clear understanding of each isolation level, which anomalies they prevent, and their locking/versioning cost.

**Real-world example:** HR runs a salary report while payroll is applying a 10% increment to all employees in one transaction. What the report shows depends entirely on the isolation level.

**Step-by-step approach:**
1. Explain each level's behavior for this exact scenario.
2. Map anomalies: dirty read, non-repeatable read, phantom read.
3. Explain locking vs row versioning.
4. Recommend: RCSI as default for OLTP, SNAPSHOT for consistent reports, SERIALIZABLE only for specific critical ranges.

| Isolation level | Reader sees during update | Blocks? | Dirty | Non-repeatable | Phantom |
|---|---|---|---|---|---|
| READ UNCOMMITTED | New, uncommitted values | No | Yes | Yes | Yes |
| READ COMMITTED (locking) | Waits until update commits | Reader waits for writer | No | Yes | Yes |
| READ COMMITTED SNAPSHOT | Last committed (old) values | No | No | Yes | Yes |
| REPEATABLE READ | Waits; rows read stay locked | Yes | No | No | Yes |
| SERIALIZABLE | Waits; ranges locked | Yes (most) | No | No | No |
| SNAPSHOT | Values as of transaction start | No | No | No | No (update conflicts possible) |

**SQL example:**
```sql
-- Session 1: payroll increment (not yet committed)
BEGIN TRAN;
UPDATE dbo.Employee SET Salary = Salary * 1.10 WHERE DepartmentId = 5;

-- Session 2 variants:
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SELECT SUM(Salary) FROM dbo.Employee WHERE DepartmentId = 5;   -- returns new (uncommitted) total

SET TRANSACTION ISOLATION LEVEL READ COMMITTED;                 -- RCSI OFF
SELECT SUM(Salary) FROM dbo.Employee WHERE DepartmentId = 5;   -- blocks until Session 1 finishes

-- With READ_COMMITTED_SNAPSHOT ON: returns old committed total immediately

SET TRANSACTION ISOLATION LEVEL SNAPSHOT;
BEGIN TRAN;
SELECT SUM(Salary) FROM dbo.Employee WHERE DepartmentId = 5;   -- consistent as of tran start
-- ... more queries see the same point-in-time data
COMMIT;

-- Check current level of sessions
SELECT session_id, transaction_isolation_level FROM sys.dm_exec_sessions WHERE session_id = @@SPID;
-- 1=RU, 2=RC, 3=RR, 4=Serializable, 5=Snapshot
```

**Interview answer (7 yrs experience):** "It depends on the isolation level. Under READ UNCOMMITTED the report sees the half-done increment, which might roll back. Under default locking READ COMMITTED, the report waits until payroll commits. With RCSI, which is what we use in production, the report immediately gets the last committed values — old salaries — without blocking. REPEATABLE READ and SERIALIZABLE add more locking to prevent non-repeatable and phantom reads, but at a big concurrency cost. SNAPSHOT gives the whole report transaction a consistent point-in-time view, which is ideal for multi-query reports like payroll reconciliation. My default recommendation is RCSI for the database, SNAPSHOT for multi-statement reports, and SERIALIZABLE or `UPDLOCK, HOLDLOCK` only for narrow critical sections like seat booking."

**Key takeaway:** Isolation level decides whether a reader sees dirty, waits, or sees old committed data — RCSI is the best OLTP default.

---

### S19. How would you handle a scenario where two users attempt to book the last available seat simultaneously?

**What the interviewer is checking:** Handling race conditions with atomic conditional updates, UPDLOCK/HOLDLOCK, and unique constraints as the final guard.

**Real-world example:** An HRMS training module has a "Leadership Workshop" with 30 seats. With 1 seat left, two employees click "Register" at the same millisecond. Both read `AvailableSeats = 1`, both insert, and the workshop is overbooked to 31.

**Step-by-step approach:**
1. Understand the race: "check then act" in two separate statements without locking is unsafe.
2. Best fix: a single **atomic conditional UPDATE** (`WHERE AvailableSeats > 0`) and check `@@ROWCOUNT`.
3. If you need read-then-write logic, use `UPDLOCK, HOLDLOCK` in a short transaction so the second user waits.
4. Add a **unique constraint** (e.g., one booking per seat or per employee per session) as the final safety net.
5. Handle the loser gracefully: "Sorry, seats are full".

**SQL example:**
```sql
-- Option 1: atomic conditional update (simplest, recommended)
CREATE OR ALTER PROCEDURE dbo.usp_BookSeat @SessionId INT, @EmployeeId INT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    BEGIN TRAN;
        UPDATE dbo.TrainingSession
        SET AvailableSeats = AvailableSeats - 1
        WHERE SessionId = @SessionId AND AvailableSeats > 0;

        IF @@ROWCOUNT = 0
        BEGIN
            ROLLBACK;
            THROW 50020, 'No seats available.', 1;
        END

        INSERT INTO dbo.TrainingBooking (SessionId, EmployeeId, BookedAt)
        VALUES (@SessionId, @EmployeeId, SYSDATETIME());
    COMMIT;
END;

-- Option 2: pessimistic read-then-write
BEGIN TRAN;
    DECLARE @Seats INT;
    SELECT @Seats = AvailableSeats
    FROM dbo.TrainingSession WITH (UPDLOCK, HOLDLOCK)   -- second caller waits here
    WHERE SessionId = @SessionId;

    IF @Seats > 0
    BEGIN
        UPDATE dbo.TrainingSession SET AvailableSeats = @Seats - 1 WHERE SessionId = @SessionId;
        INSERT INTO dbo.TrainingBooking (SessionId, EmployeeId, BookedAt)
        VALUES (@SessionId, @EmployeeId, SYSDATETIME());
    END
COMMIT;

-- Final safety net: same employee can't book twice; specific seat can't be double-booked
ALTER TABLE dbo.TrainingBooking ADD CONSTRAINT UQ_Booking_Session_Employee UNIQUE (SessionId, EmployeeId);
-- For assigned seats: UNIQUE (SessionId, SeatNo)
```

**Interview answer (7 yrs experience):** "The bug is the check-then-act pattern — both users read 'one seat left' before either writes. My preferred fix is a single atomic UPDATE with the condition in the WHERE clause, `AvailableSeats > 0`, and then check `@@ROWCOUNT`; SQL Server's update lock means only one of the two can decrement, and the other gets zero rows and a 'seats full' message. If the logic needs a read first, I use `UPDLOCK, HOLDLOCK` so the second session waits until the first commits. `UPDLOCK` alone isn't enough when the row might not exist yet — `HOLDLOCK` adds the range lock. I always add a unique constraint as the last line of defense, because constraints are enforced no matter what code path writes the data. And I keep this transaction tiny — no payment gateway or email calls inside it."

**Key takeaway:** Use an atomic conditional UPDATE (or UPDLOCK+HOLDLOCK) plus a unique constraint — never check-then-act without locking.

---

### S20. How would you implement optimistic concurrency in SQL Server?

**What the interviewer is checking:** Practical implementation with ROWVERSION end-to-end, including Dapper and API conflict handling.

**Real-world example:** In the leave module, a manager and an HR admin both edit the same leave request. With optimistic concurrency, the second save is rejected with "This record was changed by someone else", instead of silently overwriting.

**Step-by-step approach:**
1. Add a `ROWVERSION` column — SQL Server auto-changes it on every update.
2. Return it on read; send it to the client (as Base64 or an ETag header).
3. On save, include `WHERE Id = @Id AND RowVer = @RowVer`.
4. If 0 rows affected → conflict (HTTP 409). Optionally check if the row was deleted vs modified.
5. Return the new RowVer to the client using `OUTPUT inserted.RowVer`.
6. Alternatives: compare all original values, or a `ModifiedDate`/version int column (less reliable).

**SQL example:**
```sql
ALTER TABLE dbo.LeaveRequest ADD RowVer ROWVERSION NOT NULL;

CREATE OR ALTER PROCEDURE dbo.usp_UpdateLeaveRequest
    @LeaveRequestId INT, @FromDate DATE, @ToDate DATE, @Reason NVARCHAR(500),
    @RowVer BINARY(8)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.LeaveRequest
    SET FromDate = @FromDate, ToDate = @ToDate, Reason = @Reason
    OUTPUT inserted.RowVer
    WHERE LeaveRequestId = @LeaveRequestId AND RowVer = @RowVer;

    IF @@ROWCOUNT = 0
    BEGIN
        IF EXISTS (SELECT 1 FROM dbo.LeaveRequest WHERE LeaveRequestId = @LeaveRequestId)
            THROW 50030, 'Concurrency conflict: record modified by another user.', 1;
        ELSE
            THROW 50031, 'Record not found (deleted).', 1;
    END
END;
```

```csharp
public class LeaveRequestDto
{
    public int LeaveRequestId { get; set; }
    public DateTime FromDate { get; set; }
    public DateTime ToDate { get; set; }
    public string Reason { get; set; }
    public byte[] RowVer { get; set; }   // ROWVERSION maps to byte[]
}

public async Task<byte[]> UpdateAsync(LeaveRequestDto dto)
{
    const string sql = @"
        UPDATE dbo.LeaveRequest
        SET FromDate = @FromDate, ToDate = @ToDate, Reason = @Reason
        OUTPUT inserted.RowVer
        WHERE LeaveRequestId = @LeaveRequestId AND RowVer = @RowVer;";

    using var conn = new SqlConnection(_connString);
    var newRowVer = await conn.QuerySingleOrDefaultAsync<byte[]>(sql, dto);

    if (newRowVer == null)
        throw new ConcurrencyException("Leave request was modified by another user. Please reload.");

    return newRowVer;   // send back to client (e.g., Convert.ToBase64String as ETag)
}

// Controller: catch ConcurrencyException => return Conflict(409)
```

**Interview answer (7 yrs experience):** "I implement it with a `ROWVERSION` column, which SQL Server updates automatically on every change, so nobody can forget to bump it. The read returns the RowVer — in Dapper it maps to `byte[]` — and the API sends it to the UI, usually as Base64 or an ETag. On save, the UPDATE includes `AND RowVer = @RowVer` and uses `OUTPUT inserted.RowVer` to return the new value. If nothing comes back, I check whether the row was deleted or modified and return HTTP 409 so the UI can reload or show a merge screen. I prefer this over a `ModifiedDate` column because datetime precision and manual updates make that unreliable. It doesn't hold any locks between read and save, so it scales well for web apps where conflicts are rare."

**Key takeaway:** ROWVERSION in the WHERE clause + OUTPUT the new version + 409 on zero rows = clean optimistic concurrency.

---

## C. Database Design and Large Data

### S21. You have an Employee table containing 100 million records. How would you improve searching and reporting?

**What the interviewer is checking:** Architecture for massive datasets, partitioning, indexing strategies, CQRS/read-replicas, and avoiding full table scans.

**Real-world example:** A multinational workforce directory with 100 million active and historical employee records across 50 countries where search queries freeze the HR portal.

**Step-by-step approach:**
1. **Segregate OLTP and Reporting:** Implement CQRS or use Always On Availability Group Readable Secondaries (`ApplicationIntent=ReadOnly`).
2. **Implement Table Partitioning:** Partition by `JoiningDate` (Year) or `TenantId`/`CountryId` so queries prune 90%+ of data via partition elimination.
3. **Targeted Composite & Filtered Indexes:** Index leading search columns (`EmployeeCode`, `DepartmentId`) and filter active records (`WHERE IsActive = 1`).
4. **Columnstore for Aggregations:** Add a Clustered Columnstore Index on reporting replica tables for real-time aggregation queries.
5. **Keyset Pagination:** Prohibit unbounded `SELECT *` queries; mandate `WHERE Id > @LastSeenId ORDER BY Id` pagination.

**SQL example:**
```sql
-- 1. Filtered index for 95% of operational searches (Active employees only)
CREATE NONCLUSTERED INDEX IX_Employee_Active_Search
ON dbo.Employee (DepartmentId, JoiningDate)
INCLUDE (EmployeeName, Salary)
WHERE IsActive = 1;

-- 2. Keyset pagination query (Zero OFFSET degradation)
SELECT TOP (20) EmployeeId, EmployeeName, DepartmentId, Salary
FROM dbo.Employee
WHERE DepartmentId = @DeptId
  AND EmployeeId > @LastSeenEmployeeId
ORDER BY EmployeeId ASC;
```

**Interview answer (7 yrs experience):** "At 100 million records, a single table cannot efficiently serve both low-latency single-row OLTP transactions and heavy aggregate reporting simultaneously. In our enterprise HRMS, we split the problem across three tiers. First, at the storage layer, we partitioned the table by year, enabling partition elimination so a 2026 query reads only 4 million rows rather than 100 million. Second, for OLTP searches, 90% of searches target active employees, so I created a filtered index with `WHERE IsActive = 1`, reducing index size from 18 GB to 1.2 GB and keeping it cached entirely in RAM. Third, for management reporting and payroll analytics, we offloaded queries to an Always On readable secondary replica configured with Clustered Columnstore indexes, which gave us 10x data compression and sub-second aggregation times without touching the primary OLTP engine."

**Key takeaway:** Combine partitioned storage, filtered indexes for active records, keyset pagination, and readable secondaries with columnstore for reporting.

---

### S22. You need to delete 50 million historical records without affecting production performance. How would you approach it?

**What the interviewer is checking:** Batch deletion, transaction log management, avoiding lock escalation, and minimal impact on live users.

**Real-world example:** Purging 5 years of obsolete biometric access logs from an attendance table during active business hours without locking the database or crashing the transaction log drive.

**Step-by-step approach:**
1. **Never run a single `DELETE`:** A single `DELETE FROM tbl WHERE Date < ...` will acquire a table lock, bloat the transaction log, and lock out all users for hours.
2. **Batching:** Delete in chunks of 5,000 to 10,000 rows inside a loop.
3. **Pause / Delay:** Insert a small `WAITFOR DELAY '00:00:01'` between batches to allow transactional writes to proceed and let checkpoint/log backups flush.
4. **Log Truncation Awareness:** Monitor log file size and ensure log backups run during the purge.
5. **Alternative (Metadata-only):** If the table is partitioned, use `ALTER TABLE ... SWITCH PARTITION` to drop 50 million rows in 5 milliseconds.

**SQL example:**
```sql
SET NOCOUNT ON;
DECLARE @BatchSize INT = 5000;
DECLARE @RowsDeleted INT = @BatchSize;
DECLARE @CutoffDate DATE = '2021-01-01';

WHILE @RowsDeleted = @BatchSize
BEGIN
    DELETE TOP (@BatchSize)
    FROM dbo.EmployeeAttendance WITH (ROWLOCK)
    WHERE AttendanceDate < @CutoffDate;

    SET @RowsDeleted = @@ROWCOUNT;

    -- Release locks and yield CPU to active users
    WAITFOR DELAY '00:00:00.500'; 
END;
```

**Interview answer (7 yrs experience):** "Deleting 50 million rows in one statement will immediately trigger lock escalation from row locks to an Exclusive Table Lock (X lock), blocking the entire company and filling the transaction log drive until the database crashes. In production, I always implement batch deletion. I delete in chunks of 5,000 rows using `DELETE TOP (5000)`, which stays well below the 5,000-lock threshold where lock escalation occurs. Inside the `WHILE` loop, I include a 500-millisecond `WAITFOR DELAY` to give live application threads breathing room and allow regular 15-minute log backups to truncate the inactive portion of the log. If the table is partitioned by date, my preferred approach is partition switching: I switch the historical partition into an empty staging table and truncate the staging table, purging 50 million rows in 10 milliseconds via metadata deallocation."

**Key takeaway:** Delete in small batches of 5,000 rows with pauses, or use partition switching for instant zero-log purges.

---

### S23. You need to migrate 100 million records from one database to another. How would you perform this migration?

**What the interviewer is checking:** Minimal downtime migration, ETL tools, minimal logging, bulk copy, and index handling.

**Real-world example:** Migrating legacy payroll records from an on-premise SQL 2012 server to an Azure SQL Managed Instance during a 4-hour weekend cutover window.

**Step-by-step approach:**
1. **Pre-Migration Preparation:** Create target tables; pre-size target data and log files to prevent autogrowth stalls.
2. **Drop Non-Clustered Indexes on Target:** Populate only the clustered index or heap, then recreate non-clustered indexes in parallel after data load.
3. **Use Minimal Logging:** Set database recovery model to `BULK_LOGGED` or `SIMPLE` during the migration window.
4. **Tooling:** Use `bcp` utility with parallel streams, SQL Server Integration Services (SSIS), or `SqlBulkCopy` in a multi-threaded C# worker.
5. **Batch Sizing:** Use batch sizes of 50,000 to 100,000 rows with `TABLOCK`.

**SQL / BCP example:**
```powershell
# 1. Export in fast native format via BCP (Run in 4 parallel threads by Id range)
bcp "SELECT * FROM HRMS.dbo.EmployeeAttendance WHERE Id BETWEEN 1 AND 25000000" queryout "D:\Dump\att_part1.bcp" -n -T -S SourceServer

# 2. Import into Target with TABLOCK and batch size of 100,000
bcp HRMS_Target.dbo.EmployeeAttendance in "D:\Dump\att_part1.bcp" -n -T -S TargetServer -b 100000 -h "TABLOCK"
```

**Interview answer (7 yrs experience):** "For a 100-million row migration within a tight cutover window, standard SSIS or linked servers are far too slow. I use a phased approach: First, migrate historical data (up to last week) ahead of time using parallel `bcp` native format streams (`-n`) with batch sizes of 100,000 and the `TABLOCK` hint under `BULK_LOGGED` recovery. I drop non-clustered indexes on the target before loading, and rebuild them with `SORT_IN_TEMPDB = ON` and `MAXDOP = 8` after the data is loaded. Second, for the final cutover, we capture the delta changes using Change Tracking or transaction log replication, syncing only the last few days of delta data in under 15 minutes. Finally, we execute `DBCC CHECKDB` and update statistics with `FULLSCAN` before cutting over application DNS."

**Key takeaway:** Chunk with parallel BCP, drop non-clustered indexes before load, use `TABLOCK` with `BULK_LOGGED` recovery, and sync deltas during the final cutover.

---

### S24. A table contains duplicate employee records. How will you identify and remove duplicates without deleting valid records?

**What the interviewer is checking:** CTE with `ROW_NUMBER()`, deterministic tie-breakers, and transaction safety.

**Real-world example:** A network glitch in an API caused double-submissions of employee records with identical `EmployeeCode`, resulting in duplicate entries with different primary keys.

**Step-by-step approach:**
1. **Identify Duplicates:** Group by natural business key (`EmployeeCode`) with `HAVING COUNT(*) > 1`.
2. **Deterministic Partitioning:** Use `ROW_NUMBER() OVER (PARTITION BY EmployeeCode ORDER BY ModifiedDate DESC, EmployeeId DESC)`.
3. **Preview Before Delete:** Inspect rows where `RowNum > 1`.
4. **Delete via CTE:** Execute `DELETE FROM CTE WHERE RowNum > 1` inside an explicit transaction.
5. **Prevent Recurrence:** Add a `UNIQUE CONSTRAINT` on the natural business key.

**SQL example:**
```sql
-- Step 1: Identify duplicates
SELECT EmployeeCode, COUNT(*) AS DuplicateCount
FROM dbo.Employee
GROUP BY EmployeeCode
HAVING COUNT(*) > 1;

-- Step 2 & 3: Delete duplicates safely inside a transaction
BEGIN TRANSACTION;

WITH DuplicateCTE AS
(
    SELECT 
        EmployeeId,
        EmployeeCode,
        ROW_NUMBER() OVER (
            PARTITION BY EmployeeCode 
            ORDER BY JoiningDate DESC, EmployeeId DESC -- Keep the latest record
        ) AS RowNum
    FROM dbo.Employee
)
DELETE FROM DuplicateCTE
WHERE RowNum > 1;

COMMIT TRANSACTION;

-- Step 4: Add permanent safeguard constraint
ALTER TABLE dbo.Employee 
ADD CONSTRAINT UQ_Employee_EmployeeCode UNIQUE (EmployeeCode);
```

**Interview answer (7 yrs experience):** "Deduplication is a routine production task. I always use a CTE with `ROW_NUMBER()`. I partition by the natural business key (such as `EmployeeCode` or `Email`) and order by a deterministic tie-breaker—typically `ModifiedDate DESC` or `EmployeeId DESC` to keep the newest active record. In SQL Server, you can execute a `DELETE` directly against the CTE: `DELETE FROM CTE WHERE RowNum > 1;`. Before running the delete in production, I run it as a `SELECT` to verify the exact rows to be purged and get sign-off from business stakeholders. Once purged, I immediately create a unique constraint or unique index on `EmployeeCode` so the application can never insert duplicate data again."

**Key takeaway:** Use `ROW_NUMBER() OVER (PARTITION BY BusinessKey ORDER BY TieBreaker DESC)` inside a CTE, delete `RowNum > 1`, and add a UNIQUE constraint.

---

### S25. Your application needs to store employee skills, where one employee can have multiple skills. How would you design the database?

**What the interviewer is checking:** Many-to-many relationship modeling, junction/associative tables, referential integrity, indexing, and JSON vs relational trade-offs.

**Real-world example:** An HRMS talent management system where an employee has skills like 'C#', 'SQL Server', 'Azure', and 'React', with proficiency levels and certification dates.

**Step-by-step approach:**
1. **Create Entity Tables:** `Employee` and `Skill`.
2. **Create Junction Table:** `EmployeeSkill` to resolve the M:N relationship to two 1:M relationships.
3. **Composite Primary Key:** `(EmployeeId, SkillId)` prevents assigning the same skill to an employee twice.
4. **Reverse Index:** Add an index on `(SkillId, EmployeeId)` so searches by skill (e.g. 'Find all C# developers') perform index seeks.
5. **Attributes on Junction:** Store relationship-specific data (e.g. `ProficiencyLevel`, `YearsOfExperience`, `CertifiedDate`).

**SQL example:**
```sql
-- 1. Dimension Tables
CREATE TABLE dbo.Skill
(
    SkillId   INT IDENTITY(1,1) CONSTRAINT PK_Skill PRIMARY KEY,
    SkillName VARCHAR(50) NOT NULL CONSTRAINT UQ_Skill_Name UNIQUE
);

-- 2. Junction Table (Many-to-Many)
CREATE TABLE dbo.EmployeeSkill
(
    EmployeeId       INT NOT NULL,
    SkillId          INT NOT NULL,
    ProficiencyLevel VARCHAR(20) NOT NULL CONSTRAINT CK_Proficiency CHECK (ProficiencyLevel IN ('Beginner','Intermediate','Expert')),
    YearsExperience  DECIMAL(3,1) NOT NULL DEFAULT 0.0,
    CreatedDate      DATETIME2(3) NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT PK_EmployeeSkill PRIMARY KEY CLUSTERED (EmployeeId, SkillId),
    CONSTRAINT FK_EmpSkill_Employee FOREIGN KEY (EmployeeId) REFERENCES dbo.Employee(EmployeeId) ON DELETE CASCADE,
    CONSTRAINT FK_EmpSkill_Skill    FOREIGN KEY (SkillId)    REFERENCES dbo.Skill(SkillId)
);

-- 3. Crucial Reverse Index: Fast search by Skill
CREATE NONCLUSTERED INDEX IX_EmployeeSkill_SkillId 
ON dbo.EmployeeSkill(SkillId) 
INCLUDE (EmployeeId, ProficiencyLevel);
```

**Interview answer (7 yrs experience):** "This is a classic many-to-many relational design. I create an `EmployeeSkill` junction table with a composite primary key on `(EmployeeId, SkillId)`. The composite PK automatically provides a clustered index for queries starting with `EmployeeId` (e.g. 'Show all skills for Amit'). However, the critical architectural step that junior developers miss is creating the reverse non-clustered index on `(SkillId)` with `INCLUDE (EmployeeId)`. Without that reverse index, an HR query searching for 'All employees with SQL Server skill' will perform a full clustered index scan of the entire table. While modern SQL Server supports storing skills as a JSON array (`['C#','SQL']`), I avoid JSON for core entities because relational junction tables enforce foreign key integrity, provide accurate column statistics, and index efficiently."

**Key takeaway:** Model M:N with a junction table, composite primary key, foreign keys, and a reverse index on `SkillId`.

---

### S26. A reporting requirement needs data from 15 tables. How would you design an efficient query?

**What the interviewer is checking:** Query complexity management, join explosion, TempDB spills, indexed views, and staging/denormalization.

**Real-world example:** A month-end consolidated payroll ledger report pulling employee demographics, attendance, salary revisions, allowances, deductions, tax slabs, bank details, and department hierarchies.

**Step-by-step approach:**
1. **Analyze Join Multiplicity:** Check whether 1-to-many joins cause Cartesian row multiplication before aggregating.
2. **Break into CTEs or `#Temp` Tables:** Pre-aggregate detail tables independently before joining to avoid joining large rowsets.
3. **Check Indexes on Join Keys:** Ensure foreign keys and join conditions have supporting non-clustered indexes.
4. **Select Only Needed Columns:** Avoid `SELECT *`; return only the 15 required report fields.
5. **Consider an Indexed View or Materialized Reporting Table:** If the 15-table query runs frequently, pre-calculate it nightly into a reporting datamart table.

**SQL example:**
```sql
-- Anti-pattern: Joining 15 tables directly causes massive intermediate rowsets
-- Best Practice: Pre-aggregate heavy detail tables into indexed temp tables

-- Step 1: Pre-aggregate attendance for the month
SELECT EmployeeId, COUNT(*) AS DaysPresent
INTO #MonthlyAttendance
FROM dbo.EmployeeAttendance
WHERE AttendanceDate >= '2026-10-01' AND AttendanceDate < '2026-11-01' AND Status = 'Present'
GROUP BY EmployeeId;

CREATE CLUSTERED INDEX CX_Temp_Attendance ON #MonthlyAttendance(EmployeeId);

-- Step 2: Final lean join of master data with pre-aggregated metrics
SELECT 
    e.EmployeeId,
    e.EmployeeName,
    d.DepartmentName,
    e.Salary,
    ISNULL(att.DaysPresent, 0) AS DaysPresent
FROM dbo.Employee e
JOIN dbo.Department d ON e.DepartmentId = d.DepartmentId
LEFT JOIN #MonthlyAttendance att ON e.EmployeeId = att.EmployeeId;

DROP TABLE #MonthlyAttendance;
```

**Interview answer (7 yrs experience):** "When a single query joins 15 tables, the Query Optimizer's search space explodes. It often times out during optimization and picks a sub-optimal plan with bad join orders and nested loops on unindexed tables. Furthermore, joining multiple one-to-many tables causes Cartesian row multiplication, producing duplicate data and requiring expensive `DISTINCT` operators. My approach is modular: I break the query down. I pre-aggregate large transactional tables (like monthly attendance or expense claims) into `#temp` tables with clustered indexes first. Then I join the small master tables to those pre-aggregated temp tables. If the report runs regularly, I advocate building a star-schema reporting datamart or an indexed view, populated nightly via an ETL job."

**Key takeaway:** Pre-aggregate heavy child tables into indexed `#temp` tables before joining, or build a dedicated reporting datamart table.

---

### S27. A table is continuously growing and slowing down. How would you implement partitioning or archiving?

**What the interviewer is checking:** Data lifecycle management, sliding-window partitioning, archiving strategies, and minimizing downtime.

**Real-world example:** An `EmployeeAuditLog` or `EmployeeAttendance` table growing by 10 million rows every month, causing backup delays, slow queries, and buffer pool exhaustion.

**Step-by-step approach:**
1. **Establish Retention Policy:** Agree with business that active data is 2 years; data older than 2 years is archived.
2. **Implement Sliding Window Partitioning:** Partition by `Date` (monthly or yearly boundaries).
3. **Partition Switching:** Every month, switch the oldest partition into an archive table (`ALTER TABLE ... SWITCH PARTITION 1 TO ArchiveTable`).
4. **Split / Merge Boundaries:** Split the partition function to add next month's empty partition boundary.
5. **Cold Storage:** Move the archive table to read-only filegroups on cheaper blob/cloud storage or compress it via page/columnstore compression.

**SQL example:**
```sql
-- Instant metadata archive using Partition Switching (0 seconds duration!)
-- Pre-requisite: Staging table must exist on the same filegroup with identical schema and constraints

-- 1. Switch partition 1 (Historical year 2023) out to archive staging table
ALTER TABLE dbo.EmployeeAttendance_Partitioned 
SWITCH PARTITION 1 TO dbo.EmployeeAttendance_Archive_2023;

-- 2. Compress the archived historical table to save 75% disk space
ALTER TABLE dbo.EmployeeAttendance_Archive_2023 
REBUILD WITH (DATA_COMPRESSION = PAGE);
```

**Interview answer (7 yrs experience):** "For rapidly growing tables, I implement a **Sliding Window Partitioning** strategy. We partition by date ranges (such as monthly or yearly intervals). The beauty of partitioning is that archiving historical data is a pure metadata operation: running `ALTER TABLE Source SWITCH PARTITION 1 TO ArchiveTable` moves 10 million records in under 100 milliseconds because SQL Server simply swaps page allocation pointers in the metadata catalog without writing single-row log records. Then we compress the archive table with `PAGE` or `COLUMNSTORE` compression and place it on cold storage. For tables where partitioning is not licensed or feasible, I schedule automated off-peak batch archiving jobs that copy rows to an archive database and delete from production in 5,000-row chunks."

**Key takeaway:** Use sliding-window partitioning with partition switching for sub-second, zero-logging data archiving.

---

### S28. You need to maintain historical employee salary records. How would you design the database?

**What the interviewer is checking:** Auditing design patterns, Temporal Tables (System-Versioned Tables in SQL 2016+), slowly changing dimensions (SCD Type 2), and performance implications.

**Real-world example:** HR compliance requires tracking every salary change in an employee's history: what the salary was, when it changed, and who approved it, with the ability to query 'What was Amit's salary on October 15, 2023?'.

**Design Approaches:**
1. **System-Versioned Temporal Tables (Modern Standard - SQL 2016+):** Engine automatically manages history table with `PERIOD FOR SYSTEM_TIME`.
2. **Explicit SCD Type 2 Table:** Custom table with `StartDate`, `EndDate`, and `IsCurrent` flag.
3. **Audit Trigger Table:** Trigger writes old values to an `EmployeeSalary_Audit` table.

**SQL example (Temporal Table - SQL Server 2016+):**
```sql
-- Modern System-Versioned Temporal Table
CREATE TABLE dbo.EmployeeCompensation
(
    EmployeeId   INT NOT NULL PRIMARY KEY CLUSTERED,
    EmployeeName VARCHAR(100) NOT NULL,
    Salary       DECIMAL(12,2) NOT NULL,
    SysStartTime DATETIME2(7) GENERATED ALWAYS AS ROW START NOT NULL,
    SysEndTime   DATETIME2(7) GENERATED ALWAYS AS ROW END NOT NULL,
    PERIOD FOR SYSTEM_TIME (SysStartTime, SysEndTime)
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.EmployeeCompensation_History));

-- Querying point-in-time historical data seamlessly:
SELECT EmployeeId, Salary, SysStartTime, SysEndTime
FROM dbo.EmployeeCompensation
FOR SYSTEM_TIME AS OF '2023-10-15 12:00:00'
WHERE EmployeeId = 101;
```

**Interview answer (7 yrs experience):** "For historical tracking in SQL Server 2016 and above, **System-Versioned Temporal Tables** are my default architecture. You simply add `PERIOD FOR SYSTEM_TIME` columns, and SQL Server automatically creates and manages a history table. When an `UPDATE` or `DELETE` occurs on the current table, the engine moves the prior row version into the history table seamlessly inside the same transaction. Querying historical data is trivial with the `FOR SYSTEM_TIME AS OF` clause. If I need custom business attributes (like `ApprovedByUserId` or `ReasonForIncrement`), I complement the temporal table with audit columns or an explicit `SalaryRevisionHistory` table with effective start and end dates. On the history table, I always add a clustered columnstore index or an index on `(SysEndTime, SysStartTime)` to keep historical time-travel queries fast."

**Key takeaway:** Leverage SQL Server System-Versioned Temporal Tables for out-of-the-box, tamper-proof historical auditing and point-in-time querying.

---

### S29. A Stored Procedure receives thousands of EmployeeIds. How will you pass these values efficiently?

**What the interviewer is checking:** Parameter passing mechanisms, Table-Valued Parameters (TVPs), string splitting anti-patterns, and Dapper/.NET integration.

**Real-world example:** An HR manager selects 10,000 employees in a grid and clicks 'Send Annual Bonus Notification' or 'Approve Overtime'. The web application must pass all 10,000 IDs to the database in a single call.

**Comparison of Passing Methods:**
| Method | Performance | Type Safety | Indexable? |
|---|---|---|---|
| Comma-separated string (`STRING_SPLIT`) | Slow; high CPU parsing; non-SARGable | No (plain text) | No |
| XML parameter (`.nodes()`) | High memory and CPU shredding | Moderate | No |
| Temporary table pre-population | Multiple round trips | Yes | Yes |
| **Table-Valued Parameter (TVP)** | **Fastest (streaming binary TDS)** | **Yes (strongly typed)** | **Yes (can have PK)** |

**SQL & Dapper C# example:**
```sql
-- 1. SQL Server Table Type
CREATE TYPE dbo.EmployeeIdListType AS TABLE
(
    EmployeeId INT NOT NULL PRIMARY KEY
);
GO

CREATE PROCEDURE dbo.usp_ProcessBulkBonus
    @EmpIds dbo.EmployeeIdListType READONLY,
    @BonusAmount DECIMAL(10,2)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE e
    SET e.Salary = e.Salary + @BonusAmount
    FROM dbo.Employee e
    JOIN @EmpIds ids ON e.EmployeeId = ids.EmployeeId;
END;
GO
```

```csharp
// 2. Dapper C# Implementation in .NET Core
public async Task ProcessBulkBonusAsync(List<int> employeeIds, decimal bonus)
{
    var dataTable = new DataTable();
    dataTable.Columns.Add("EmployeeId", typeof(int));
    foreach (var id in employeeIds)
        dataTable.Rows.Add(id);

    using var connection = new SqlConnection(_connectionString);
    await connection.ExecuteAsync(
        "dbo.usp_ProcessBulkBonus",
        new { 
            EmpIds = dataTable.AsTableValuedParameter("dbo.EmployeeIdListType"),
            BonusAmount = bonus 
        },
        commandType: CommandType.StoredProcedure
    );
}
```

**Interview answer (7 yrs experience):** "Passing thousands of IDs via comma-delimited strings with `STRING_SPLIT` or XML documents causes heavy CPU serialization and parsing overhead in SQL Server. The industry standard pattern in .NET Core with Dapper is a **Table-Valued Parameter (TVP)**. I define a User-Defined Table Type with a Primary Key on `EmployeeId`. In C#, I map a `List<int>` to a `DataTable` and pass it using Dapper's `.AsTableValuedParameter()`. In the stored procedure, the TVP joins directly to the `Employee` table as a hash or merge join using its primary key. For massive payloads of 100,000+ IDs, I bypass the stored procedure parameter and use `SqlBulkCopy` to stream rows directly into an indexed `#temp` table, then execute the processing stored procedure."

**Key takeaway:** Use Table-Valued Parameters (TVPs) with a Primary Key in SQL and `AsTableValuedParameter` in Dapper for optimal type safety and join performance.

---

### S30. You need to generate monthly employee attendance reports for 5 million employees. How would you optimize the process?

**What the interviewer is checking:** High-volume aggregation, batch processing, parallelism, indexed views, and pre-aggregation pipelines.

**Real-world example:** On the 1st of every month, payroll generates the monthly attendance summary (Total Days, Days Present, Absent, Paid Leave, Overtime Hours) for 5 million employees across 150 million punch records.

**Step-by-step approach:**
1. **Pre-Aggregation (Do Not Aggregate on the Fly):** Never aggregate 150 million raw punch rows during user report requests.
2. **Nightly Incremental Rollup:** Aggregate daily punch data into a summary table (`MonthlyAttendanceSummary`) every night via an off-peak job.
3. **Partition by Month:** Partition the summary table by `(Year, Month)`.
4. **Columnstore Index:** Place a Clustered Columnstore Index on the monthly summary table for instant reporting aggregations.
5. **Parallel Chunking by Department:** If generating individual PDF payslips, process in parallel batches grouped by `DepartmentId`.

**SQL example:**
```sql
-- Summary table populated incrementally by nightly batch
CREATE TABLE dbo.MonthlyAttendanceSummary
(
    YearMonthNumber INT NOT NULL, -- e.g. 202610
    EmployeeId      INT NOT NULL,
    DepartmentId    INT NOT NULL,
    TotalDays       TINYINT NOT NULL,
    DaysPresent     TINYINT NOT NULL,
    DaysAbsent      TINYINT NOT NULL,
    DaysOnLeave     TINYINT NOT NULL,
    CONSTRAINT PK_MonthlySummary PRIMARY KEY CLUSTERED (YearMonthNumber, EmployeeId)
);

-- Real-time report query touches only 5M summary rows instead of 150M raw punch rows!
SELECT 
    d.DepartmentName,
    SUM(mas.DaysPresent) AS TotalPresentDays,
    SUM(mas.DaysAbsent)  AS TotalAbsentDays
FROM dbo.MonthlyAttendanceSummary mas
JOIN dbo.Department d ON mas.DepartmentId = d.DepartmentId
WHERE mas.YearMonthNumber = 202610
GROUP BY d.DepartmentName;
```

**Interview answer (7 yrs experience):** "Attempting to calculate attendance metrics on the fly from 150 million raw punch records on the 1st of the month will bring the database to its knees with CPU and memory grant waits. In our HRMS, we architected an **Incremental Pre-Aggregation Pipeline**. Every night at 1:00 AM, a SQL Server Agent job processes only the previous day's biometric punches and updates a dedicated `MonthlyAttendanceSummary` table. On month-end, the monthly report simply queries the summary table, which contains exactly 5 million rows instead of 150 million raw events. By placing a Clustered Columnstore index on the summary table, executive department-level rollups run in under 2 seconds. For export jobs, we stream data using Dapper and unbuffered `SqlDataReader` to avoid loading 5 million objects into application RAM."

**Key takeaway:** Pre-aggregate raw events incrementally into a summary table with a Columnstore index rather than scanning raw logs on demand.

## D. Stored Procedure and Production Scenarios

### S31. A Stored Procedure contains 1,000 lines of SQL and is difficult to maintain. How would you improve it?

**What the interviewer is checking:** Code refactoring, Single Responsibility Principle in T-SQL, modular design, breaking down monolithic procedures, and testing.

**Real-world example:** A legacy `usp_CalculateMonthlyPayroll` stored procedure written 8 years ago containing 1,200 lines of nested cursors, 15 temporary tables, repeated calculations, and inline business logic that nobody dares to touch.

**Step-by-step approach:**
1. **Understand & Baseline:** Capture test cases and establish baseline execution time, I/O reads (`SET STATISTICS IO ON`), and output data checksums.
2. **Break into Modular Sub-Procedures:** Extract distinct business domains (e.g. `usp_CalculateOvertime`, `usp_CalculateTaxDeductions`, `usp_GeneratePaySlips`) following Single Responsibility.
3. **Eliminate Cursors:** Convert RBAR (Row-By-Agonizing-Row) loops into set-based statements using window functions or TVPs.
4. **Consolidate Temp Tables:** Eliminate redundant `#temp` tables that repeatedly read the same base tables.
5. **Standardize Error & Transaction Handling:** Add consistent `TRY...CATCH` blocks with `SET XACT_ABORT ON` and `THROW`.

**SQL example:**
```sql
-- Before: 1,000-line monolithic nightmare
-- After: Clean coordinator procedure calling focused sub-modules

CREATE OR ALTER PROCEDURE dbo.usp_CalculateMonthlyPayroll_Coordinator
    @YearMonthNumber INT,
    @ProcessedByUserId INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Sub-module 1: Attendance rollup
        EXEC dbo.usp_Payroll_RollupAttendance @YearMonthNumber;

        -- Sub-module 2: Gross earnings & overtime
        EXEC dbo.usp_Payroll_CalculateGrossSalary @YearMonthNumber;

        -- Sub-module 3: Tax and deductions
        EXEC dbo.usp_Payroll_CalculateDeductions @YearMonthNumber;

        -- Sub-module 4: Final ledger entry
        EXEC dbo.usp_Payroll_PostLedger @YearMonthNumber, @ProcessedByUserId;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO
```

**Interview answer (7 yrs experience):** "Refactoring a 1,000-line legacy procedure is a classic senior responsibility. My first step is establishing a baseline: I capture output datasets for 5 known edge-case inputs so I have automated regression validation. Then I map out the dependencies. Most 1,000-line procedures suffer from two anti-patterns: repeating the same 5-table join across 10 different `#temp` tables, and using procedural cursors for calculations that could be set-based. I refactor by decomposing the monolith into focused, single-purpose stored procedures coordinated by a parent wrapper. I replace RBAR cursors with window functions (`SUM() OVER()`), consolidate `#temp` tables, add `SET NOCOUNT ON` and `SET XACT_ABORT ON`, and introduce structured `TRY...CATCH` logging. In our HRMS, decomposing our month-end payroll procedure cut lines of code by 60% and reduced runtime from 45 minutes to 4 minutes."

**Key takeaway:** Baseline existing outputs, decompose the monolith into single-responsibility sub-procedures, convert cursors to set-based logic, and consolidate temp tables.

---

### S32. A Stored Procedure has multiple nested IF conditions and repeated queries. How would you optimize it?

**What the interviewer is checking:** Eliminating redundant database reads, simplifying control flow, Dynamic SQL vs branching, and avoiding sub-optimal execution plans.

**Real-world example:** A search procedure with 10 nested `IF @Status = 'Active' ... ELSE IF @DepartmentId IS NOT NULL ...` where each branch executes an almost identical 50-line query with slight filter variations.

**Step-by-step approach:**
1. **Identify Common Base Logic:** Extract common table joins and expressions into a single base query or Common Table Expression (CTE).
2. **Eliminate Redundant Scans:** Avoid running identical `SELECT` statements inside multiple `IF` branches.
3. **Dynamic SQL with `sp_executesql`:** For search procedures with varying filters, replace nested `IF` branches with parameterized dynamic SQL to generate an optimal execution plan for each specific parameter combination.
4. **Use `CASE` Expressions in Filters:** Where suitable, combine simple flag conditions using Boolean logic or `CASE` expressions.

**SQL example:**
```sql
-- Anti-Pattern: Repeating 90% of the same query inside nested IF branches
-- Optimized: Parameterized Dynamic SQL with sp_executesql

CREATE OR ALTER PROCEDURE dbo.usp_GetEmployees_Optimized
    @DeptId      INT          = NULL,
    @MinSalary   DECIMAL(10,2)= NULL,
    @Status      VARCHAR(10)  = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Sql NVARCHAR(MAX) = N'
        SELECT e.EmployeeId, e.EmployeeName, e.Salary, d.DepartmentName
        FROM dbo.Employee e
        JOIN dbo.Department d ON e.DepartmentId = d.DepartmentId
        WHERE 1 = 1';

    IF @DeptId IS NOT NULL
        SET @Sql += N' AND e.DepartmentId = @pDeptId';

    IF @MinSalary IS NOT NULL
        SET @Sql += N' AND e.Salary >= @pMinSalary';

    EXEC sys.sp_executesql 
        @Sql,
        N'@pDeptId INT, @pMinSalary DECIMAL(10,2)',
        @pDeptId = @DeptId,
        @pMinSalary = @MinSalary;
END;
GO
```

**Interview answer (7 yrs experience):** "Nested `IF` conditions in stored procedures usually indicate that the procedure is trying to do too many unrelated things or attempting to build a multi-purpose search query. The major problem with nested `IF` branches in SQL Server is plan compilation: the optimizer compiles a plan for the whole procedure on first execution, and plans for dormant branches can be poorly optimized. If the branches represent entirely different business operations, I split them into separate, dedicated stored procedures. If they represent optional search filters, I replace the nested `IF` spaghetti with parameterized dynamic SQL using `sp_executesql`. This ensures clean, maintainable code where SQL Server compiles and caches targeted execution plans for each specific combination of search criteria."

**Key takeaway:** Split unrelated business flows into separate procedures, and use parameterized dynamic SQL for optional filter variations.

---

### S33. A Stored Procedure works correctly for most inputs but returns incorrect results for NULL values. How will you debug it?

**What the interviewer is checking:** ANSI NULL behavior, three-valued logic (`TRUE`, `FALSE`, `UNKNOWN`), `NOT IN` with NULLs, outer joins, and debugging techniques.

**Real-world example:** An HR report calculates total manager compensation, but any employee whose `ManagerId` is `NULL` (like the CEO or VP) disappears from the report, or a `NOT IN` query returns zero rows.

**Root Causes of NULL Bugs:**
1. **`NOT IN` with Subquery returning NULL:** Evaluates to `UNKNOWN`, returning zero rows.
2. **Equality Comparison with NULL:** `WHERE ManagerId = @ManagerId` returns false when `@ManagerId` is NULL because NULL is unknown (requires `IS NULL`).
3. **String Concatenation:** `'Hello ' + NULL` results in `NULL` when `CONCAT_NULL_YIELDS_NULL` is ON.
4. **Outer Joins Demoted to Inner Joins:** `LEFT JOIN Department d ... WHERE d.DepartmentName = 'IT'` filters out unmatched left rows where `d.DepartmentName` is NULL.

**SQL example:**
```sql
-- Bug 1: Comparing NULL with equality fails!
-- Query returns 0 rows if @MgrId is NULL
DECLARE @MgrId INT = NULL;
SELECT * FROM dbo.Employee WHERE ManagerId = @MgrId; -- WRONG!

-- FIX 1: Handle NULL explicitly or use IS NOT DISTINCT FROM (SQL 2022+)
SELECT * FROM dbo.Employee 
WHERE (ManagerId = @MgrId OR (ManagerId IS NULL AND @MgrId IS NULL));

-- Bug 2: Left join demoted to inner join by WHERE clause
SELECT e.EmployeeName, d.DepartmentName
FROM dbo.Employee e
LEFT JOIN dbo.Department d ON e.DepartmentId = d.DepartmentId
WHERE d.DepartmentName = 'IT'; -- WRONG! Strips employees with NULL DepartmentId!

-- FIX 2: Move filter into the ON clause
SELECT e.EmployeeName, d.DepartmentName
FROM dbo.Employee e
LEFT JOIN dbo.Department d ON e.DepartmentId = d.DepartmentId AND d.DepartmentName = 'IT';
```

**Interview answer (7 yrs experience):** "Debugging NULL anomalies is about understanding ANSI three-valued logic. When a procedure behaves strangely with NULL inputs, I check four usual suspects: First, `NOT IN (SELECT Col FROM ...)`: if even one row in the subquery has a `NULL`, `NOT IN` returns zero rows; I rewrite it to `NOT EXISTS`. Second, equality comparisons: writing `WHERE Col = @Param` fails when `@Param` is NULL because `NULL = NULL` evaluates to `UNKNOWN`, not `TRUE`. Third, `LEFT JOIN` predicates placed in the `WHERE` clause instead of the `ON` clause, which silently converts outer joins into inner joins. And fourth, string concatenation: `FirstName + ' ' + MiddleName + ' ' + LastName` returns `NULL` if `MiddleName` is NULL; I replace it with `CONCAT()` or `COALESCE()`. In SQL Server 2022, I leverage the new ANSI `IS NOT DISTINCT FROM` predicate to compare nullable values cleanly."

**Key takeaway:** Remember that `NULL = NULL` is UNKNOWN; replace `NOT IN` with `NOT EXISTS`, check for outer joins demoted by WHERE clauses, and use `CONCAT()`.

---

### S34. You need to implement pagination for a table containing 50 million records. Which approach would you choose?

**What the interviewer is checking:** Deep pagination pitfalls, `OFFSET-FETCH` vs Keyset Pagination (Seek Method), and buffer cache efficiency.

**Real-world example:** An enterprise audit log grid displaying 50 records per page: Page 1 loads in 10ms, but when a user navigates to Page 100,000 (`OFFSET 5000000`), the query takes 35 seconds and causes high disk I/O.

| Method | Syntax | Mechanism | Performance at Page 100,000 |
|---|---|---|---|
| **OFFSET - FETCH** | `OFFSET 5000000 ROWS FETCH NEXT 50 ROWS ONLY` | Scans and discards 5,000,000 rows | **Extremely slow (linear degradation)** |
| **Keyset (Seek) Pagination** | `WHERE Id > @LastSeenId ORDER BY Id FETCH NEXT 50 ROWS ONLY` | Index seek directly to the starting key | **Constant $O(\log N)$ time (~10 ms)** |

**SQL example:**
```sql
-- 1. OFFSET-FETCH (Acceptable only for small tables or first few pages)
SELECT EmployeeId, EmployeeName, JoiningDate
FROM dbo.Employee
ORDER BY EmployeeId
OFFSET 0 ROWS FETCH NEXT 20 ROWS ONLY;

-- 2. KEYSET PAGINATION (Production Gold Standard for 50M rows):
-- Client UI sends the last seen EmployeeId from the current page
DECLARE @LastSeenId INT = 105;

SELECT TOP (20) EmployeeId, EmployeeName, JoiningDate
FROM dbo.Employee
WHERE EmployeeId > @LastSeenId -- Direct B-tree Seek!
ORDER BY EmployeeId ASC;
```

**Interview answer (7 yrs experience):** "For a table with 50 million rows, `OFFSET-FETCH` is a ticking time bomb. When a user requests page 10,000 with `OFFSET 500000 ROWS FETCH NEXT 50 ROWS`, SQL Server must physically read all 500,000 rows, sort them, discard 500,000 rows in memory, and return just 50 rows. As the offset increases, response times degrade linearly. In our production APIs, I mandate **Keyset Pagination** (also called Cursor-Based Pagination). The client passes the primary key or clustered key of the last item on the previous page (`WHERE Id > @LastSeenId ORDER BY Id ASC`). Because the filter operates on the clustered index, SQL Server performs an instant $O(\log N)$ Index Seek directly to that row. Page 1 and Page 1,000,000 both execute in under 10 milliseconds with only 3 logical page reads."

**Key takeaway:** Avoid `OFFSET-FETCH` on massive datasets; use Keyset Pagination (`WHERE Id > @LastSeenId ORDER BY Id`) for constant $O(\log N)$ performance.

---

### S35. A Stored Procedure returns duplicate records after joining multiple tables. How will you identify the issue?

**What the interviewer is checking:** Cartesian product detection, one-to-many relationship cardinality, foreign key joins, and avoiding lazy `DISTINCT` band-aids.

**Real-world example:** An HR report showing employee salaries and department names suddenly shows Amit three times with the same salary because three attendance punch records exist for Amit in the joined table.

**Step-by-step approach:**
1. **Do NOT blindly add `DISTINCT`:** `DISTINCT` masks the underlying join bug and adds an expensive Sort operator.
2. **Isolate Joins Progressively:** Comment out joins one by one until the row count matches the base table.
3. **Inspect Join Multiplicity:** Check for 1-to-many relationships where the child table contains multiple records per parent key.
4. **Pre-Aggregate Child Tables:** Use CTEs, `CROSS APPLY`, or subqueries to aggregate child records to 1 row per parent *before* joining.
5. **Verify Join Conditions:** Check for missing join predicates causing partial Cartesian products.

**SQL example:**
```sql
-- BUG: Joining Employee (1) to EmployeeSalaryHistory (M) causes row multiplication!
SELECT e.EmployeeId, e.EmployeeName, esh.Salary
FROM dbo.Employee e
JOIN dbo.EmployeeSalaryHistory esh ON e.EmployeeId = esh.EmployeeId; -- Returns 5 rows for 2 employees!

-- FIX: Pre-aggregate or use CROSS APPLY to retrieve only the latest salary record
SELECT e.EmployeeId, e.EmployeeName, latest.Salary
FROM dbo.Employee e
CROSS APPLY (
    SELECT TOP (1) esh.Salary
    FROM dbo.EmployeeSalaryHistory esh
    WHERE esh.EmployeeId = e.EmployeeId
    ORDER BY esh.EffectiveDate DESC
) latest;
```

**Interview answer (7 yrs experience):** "When a procedure returns unexpected duplicate records, the junior reaction is slapping a `DISTINCT` on the query. In production, `DISTINCT` is a dangerous band-aid: it consumes memory grants, introduces TempDB sort spills, and masks incorrect join cardinality. To diagnose the issue, I comment out joined tables one by one until the row count matches the parent table's expected count. Almost always, the culprit is joining to a 1-to-many relationship without aggregating (for example, joining `Employee` to `EmployeeAttendance` or `SalaryHistory`). Once I identify the child table, I rewrite the query using `CROSS APPLY (SELECT TOP 1 ...)` or pre-aggregate the child table in a CTE before joining to preserve strict 1:1 row cardinality."

**Key takeaway:** Never use `DISTINCT` to hide join duplicates; isolate the multi-row child join and pre-aggregate using `CROSS APPLY` or CTEs.

---

### S36. You need to implement an audit trail whenever employee information is updated. Would you use triggers or application-level auditing? Why?

**What the interviewer is checking:** Architectural trade-offs between database triggers, application middleware, Change Data Capture (CDC), and Temporal Tables.

**Real-world example:** Compliance requires logging every salary or bank account change: who changed it, from what IP address, old value, new value, and timestamp.

| Auditing Mechanism | Pros | Cons | Best For |
|---|---|---|---|
| **DML Triggers** | Catches 100% of changes (SSMS, scripts, API); guaranteed transaction consistency | Synchronous write overhead; can cause blocking; hard to capture app user context | Absolute regulatory compliance where direct DB updates must be caught |
| **System-Versioned Temporal Tables** | Native SQL Server engine feature; zero maintenance; point-in-time time-travel querying | Captures data history, but not custom app metadata (e.g. user session reason) | Historical point-in-time auditing |
| **Application-Level Auditing (.NET / EF / Dapper)** | Rich business context (User Id, Tenant, IP, Request Path, Business Reason); non-blocking | Bypassed completely if someone updates data directly in SSMS or via ETL scripts | Business-driven audit logs |

**SQL example (Hybrid Best Practice - Temporal Table with Audit Columns):**
```sql
-- Audit columns inside the main table updated by Dapper/.NET
ALTER TABLE dbo.Employee 
ADD LastModifiedBy VARCHAR(100) NOT NULL DEFAULT 'SYSTEM',
    LastModifiedDate DATETIME2(3) NOT NULL DEFAULT SYSDATETIME(),
    ChangeReason NVARCHAR(250) NULL;
```

**Interview answer (7 yrs experience):** "At 7 years of experience, I advocate a **defense-in-depth hybrid architecture**. If you rely purely on application-level auditing in C#, any direct update executed by a DBA in SSMS, data migration script, or third-party service bypasses the audit trail completely. On the other hand, heavy DML triggers execute synchronously inside the user transaction, extending lock duration and causing blocking. My preferred architecture in modern SQL Server is using **Temporal Tables** at the database layer to guarantee an immutable, tamper-proof record of every single data change regardless of where it originates. Then, at the application layer, our .NET Core API passes `ModifiedByUserId` and `CorrelationId` into the transaction context (using `SESSION_CONTEXT()`) so the database audit automatically reflects the true logged-in application user."

**Key takeaway:** Use Temporal Tables for tamper-proof database-level history and `SESSION_CONTEXT()` to capture application user identity without trigger overhead.

---

### S37. You need to execute multiple Stored Procedures as one business operation. How would you handle transaction management?

**What the interviewer is checking:** Transaction boundaries, nested transactions vs `@@TRANCOUNT`, `SET XACT_ABORT ON`, and orchestrating transactions in .NET Core / Dapper.

**Real-world example:** Onboarding an employee: Procedure 1 creates the user login, Procedure 2 inserts employee master data, Procedure 3 allocates initial leave balances, and Procedure 4 assigns department assets. If Procedure 4 fails, all previous steps must roll back.

**Step-by-step approach:**
1. **Decide Transaction Boundary:** Prefer managing the transaction boundary in the .NET application layer via `SqlTransaction` or a coordinator stored procedure.
2. **Avoid Nested `BEGIN TRAN` Antipattern:** Nested `BEGIN TRAN` statements only increment `@@TRANCOUNT`; an inner `COMMIT` does nothing, while an inner `ROLLBACK` rolls back everything and sets `@@TRANCOUNT = 0`, causing outer commits to fail with Error 266.
3. **Mandate `SET XACT_ABORT ON`:** Automatically rolls back the entire transaction if a runtime error occurs.
4. **Inspect `XACT_STATE()`:** Check if transaction is doomed before rolling back.

**Dapper C# Transaction Orchestration Example:**
```csharp
public async Task OnboardEmployeeAsync(EmployeeOnboardingDto dto)
{
    using var connection = new SqlConnection(_connectionString);
    await connection.OpenAsync();

    // Application-managed transaction across multiple procedures
    using var transaction = connection.BeginTransaction(IsolationLevel.ReadCommitted);

    try
    {
        // Step 1: Create Employee Record
        var empId = await connection.ExecuteScalarAsync<int>(
            "dbo.usp_CreateEmployee", 
            new { dto.EmployeeName, dto.DepartmentId, dto.Salary, dto.JoiningDate }, 
            transaction, commandType: CommandType.StoredProcedure);

        // Step 2: Allocate Leave Balances
        await connection.ExecuteAsync(
            "dbo.usp_AllocateInitialLeaves", 
            new { EmployeeId = empId, dto.LeaveYear }, 
            transaction, commandType: CommandType.StoredProcedure);

        // Step 3: Assign Department Assets
        await connection.ExecuteAsync(
            "dbo.usp_AssignAssets", 
            new { EmployeeId = empId, dto.AssetId }, 
            transaction, commandType: CommandType.StoredProcedure);

        // All steps succeeded - Commit as a single atomic operation
        transaction.Commit();
    }
    catch (Exception ex)
    {
        // Any failure rolls back all procedures!
        transaction.Rollback();
        _logger.LogError(ex, "Employee onboarding failed; transaction rolled back.");
        throw;
    }
}
```

**Interview answer (7 yrs experience):** "I manage cross-procedure transactions at the **application layer using a single `SqlTransaction` in .NET Core with Dapper**. When you attempt to manage transactions inside nested stored procedures in T-SQL, SQL Server does not support true autonomous nested transactions—it only increments `@@TRANCOUNT`. If an inner procedure calls `ROLLBACK`, it rolls back the entire transaction and resets `@@TRANCOUNT` to 0, which causes the outer procedure's subsequent `COMMIT` to crash with runtime Error 266 ('Transaction count after EXECUTE indicates a mismatching number of BEGIN and COMMIT statements'). By keeping individual stored procedures clean and transaction-neutral, and orchestrating the `BeginTransaction()`, `Commit()`, and `Rollback()` in Dapper, the business transaction boundary is explicit, testable, and completely resilient."

**Key takeaway:** Orchestrate multi-procedure business transactions in the .NET application layer via `SqlTransaction` or use a single parent coordinator procedure with `SET XACT_ABORT ON`.

---

### S38. A Stored Procedure is generating different execution plans for different parameter values. How will you investigate?

**What the interviewer is checking:** Parameter sniffing diagnosis, Query Store plan comparison, plan cache inspection, and cardinality skew.

**Real-world example:** `usp_GetAttendanceByStatus`: Passing `@Status = 'Present'` (which matches 90% of rows) takes 25 seconds; passing `@Status = 'Leave'` (which matches 0.1% of rows) takes 5 milliseconds.

**Step-by-step approach:**
1. **Enable Query Store:** Open the 'Queries With High Variation' report.
2. **Compare Plans Side-by-Side:** In SSMS Query Store, compare Plan A (Index Seek + Key Lookup) with Plan B (Clustered Index Scan).
3. **Inspect XML Plan Attributes:** Look at `ParameterCompiledValue` vs `ParameterRuntimeValue`.
4. **Inspect Table Data Distribution:** Check the histogram using `DBCC SHOW_STATISTICS` to verify if data is heavily skewed.
5. **Decide Remediation:** Use `OPTION (RECOMPILE)`, `OPTIMIZE FOR`, or plan forcing.

**SQL Diagnostic Query:**
```sql
-- Find plans for the procedure in Query Store and compare metrics
SELECT 
    q.query_id,
    p.plan_id,
    p.is_forced_plan,
    rs.count_executions,
    rs.avg_duration / 1000.0 AS AvgDurationMs,
    rs.avg_logical_io_reads,
    p.query_plan
FROM sys.query_store_query q
JOIN sys.query_store_plan p ON q.query_id = p.query_id
JOIN sys.query_store_runtime_stats rs ON p.plan_id = rs.plan_id
WHERE q.object_id = OBJECT_ID('dbo.usp_GetAttendanceByStatus')
ORDER BY rs.avg_duration DESC;
```

**Interview answer (7 yrs experience):** "When a procedure generates different plans or exhibits wild duration variance across parameters, the root cause is data skew causing parameter sniffing. In our HRMS, status columns like `AttendanceStatus` are 95% 'Present' and 1% 'Suspended'. If compiled with 'Suspended', the optimizer picks an Index Seek with Key Lookup. If compiled with 'Present', it picks a Clustered Index Scan. I open **Query Store**, find the query ID, and compare the two plan IDs side by side. I check the XML properties `ParameterCompiledValue` and `ParameterRuntimeValue`. If the query is executed infrequently, I append `OPTION (RECOMPILE)`. If it is executed thousands of times per minute where compilation CPU is a concern, I use `OPTIMIZE FOR (@Status = 'Present')` to force the scan plan that guarantees predictable, stable execution regardless of input."

**Key takeaway:** Use Query Store to compare plan IDs and parameter compiled values, then stabilize with `OPTION (RECOMPILE)` or `OPTIMIZE FOR`.

---

### S39. You need to process 1 million employee records in batches. How would you implement batch processing?

**What the interviewer is checking:** Chunking, cursor alternatives, transaction log management, preventing blocking, and restartability.

**Real-world example:** Nightly calculation of annual leave accrual balances for 1 million employees at fiscal year-end.

**Step-by-step approach:**
1. **Keyset / Range-Based Chunking:** Never use a cursor or `OFFSET-FETCH`; process by primary key chunks (e.g. `EmployeeId BETWEEN @StartId AND @EndId`).
2. **Small Atomic Transactions:** Wrap only the individual batch in a transaction, not the whole million records.
3. **Throttle:** Add a brief pause between batches (`WAITFOR DELAY '00:00:00.100'`) to allow log flushes and live OLTP queries to proceed.
4. **Idempotency & Restartability:** Store batch progress in a control table so if the server restarts at record 600,000, the job resumes seamlessly without duplicating work.

**SQL example:**
```sql
CREATE OR ALTER PROCEDURE dbo.usp_ProcessLeaveAccrual_Batched
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @BatchSize INT = 5000;
    DECLARE @CurrentId INT = 0;
    DECLARE @MaxId INT = (SELECT MAX(EmployeeId) FROM dbo.Employee);

    WHILE @CurrentId < @MaxId
    BEGIN
        BEGIN TRANSACTION;

        -- Process batch of 5,000 employees based on Primary Key range
        UPDATE dbo.Employee
        SET Salary = Salary * 1.05 -- Example calculation
        WHERE EmployeeId > @CurrentId AND EmployeeId <= (@CurrentId + @BatchSize);

        COMMIT TRANSACTION;

        SET @CurrentId += @BatchSize;

        -- Yield CPU and allow log truncation
        WAITFOR DELAY '00:00:00.100';
    END;
END;
GO
```

**Interview answer (7 yrs experience):** "For batch processing 1 million records, I avoid single giant transactions and procedural cursors. A single transaction modifying 1 million rows causes lock escalation to an exclusive table lock, stalls transaction log backups, and risks an hour-long rollback if canceled. My pattern is **Keyset Chunking**: I process in chunks of 5,000 to 10,000 rows based on clustered primary key ranges (`EmployeeId BETWEEN @Min AND @Max`). Each chunk commits independently. I also log progress to a `BatchJobControl` table with the last processed ID so the batch is idempotent and restartable. If a failure occurs halfway through, the job simply resumes from where it left off rather than starting from scratch."

**Key takeaway:** Process by primary key ranges in chunks of 5,000 with independent commits, short pauses, and an idempotent restart mechanism.

---

### S40. A Stored Procedure is timing out intermittently. How will you identify whether the issue is blocking, execution plan, parameter sniffing or resource contention?

**What the interviewer is checking:** Systematic triage methodology, reading DMVs, Wait Statistics, Extended Events, and identifying the true root cause under pressure.

**Real-world example:** An intermittent timeout error (`SqlException: Execution Timeout Expired`) reported by the web API twice a day during peak hours on a critical employee lookup procedure.

**Step-by-step Diagnostic Decision Matrix:**
1. **Is it Blocking?**
   Query `sys.dm_exec_requests` when the timeout occurs. If `blocking_session_id != 0` and wait type is `LCK_M_...`, the query is innocent; another uncommitted transaction is holding a lock on the required table.
2. **Is it Parameter Sniffing?**
   Check Query Store for multiple plan IDs. Compare `ParameterCompiledValue` vs `ParameterRuntimeValue`. If running the query text in SSMS with local variables runs instantly, it is parameter sniffing.
3. **Is it Resource Contention (CPU / Memory Grant / Disk)?**
   Check wait types:
   - `SOS_SCHEDULER_YIELD` $\rightarrow$ CPU starvation.
   - `RESOURCE_SEMAPHORE` $\rightarrow$ Waiting for query memory grant (TempDB spill / undersized memory).
   - `PAGEIOLATCH_SH` $\rightarrow$ Storage subsystem bottleneck / memory pressure forcing disk reads.
4. **Is it Client-Side Slowness?**
   `ASYNC_NETWORK_IO` wait type indicates the database finished processing, but the .NET app is consuming rows slowly.

**SQL Diagnostic Query:**
```sql
-- Comprehensive live diagnostic query for timing-out requests
SELECT 
    r.session_id,
    r.status,
    r.blocking_session_id AS BlockedBy,
    r.wait_type,
    r.wait_time / 1000.0 AS WaitTimeSeconds,
    r.cpu_time,
    r.total_elapsed_time / 1000.0 AS ElapsedSeconds,
    r.reads,
    r.writes,
    t.text AS ExecutingSQL,
    qp.query_plan AS LivePlan
FROM sys.dm_exec_requests r
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) t
CROSS APPLY sys.dm_exec_query_plan(r.plan_handle) qp
WHERE r.session_id > 50 AND r.session_id != @@SPID;
```

**Interview answer (7 yrs experience):** "When intermittent timeouts occur, I follow a disciplined triage tree:
1. **First, I rule out blocking:** I run a query on `sys.dm_exec_requests`. If `blocking_session_id` is populated with a `LCK_M_` wait type, the procedure isn't slow—it is simply blocked waiting for a lock held by an open transaction elsewhere.
2. **Second, I check Query Store for plan regressions:** If execution duration has sudden spikes with identical row counts, I look at plan IDs to see if parameter sniffing caused an index seek to flip to a full scan.
3. **Third, I examine wait statistics:** If wait type is `RESOURCE_SEMAPHORE`, other massive queries are monopolizing server memory grants, forcing incoming requests into an execution queue. If it is `PAGEIOLATCH_SH`, disk I/O latency is spiking.
4. **Fourth, I check `system_health` Extended Events:** The default session automatically records timeouts, deadlocks, and severe wait anomalies. This structured approach lets me definitively isolate whether the fix requires indexing, transaction refactoring, or infrastructure scaling within 10 minutes."

**Key takeaway:** Follow a structured elimination path: Check blocking (`sys.dm_exec_requests`), plan instability (Query Store), resource waits (`RESOURCE_SEMAPHORE` / `PAGEIOLATCH`), and network consumption (`ASYNC_NETWORK_IO`).
