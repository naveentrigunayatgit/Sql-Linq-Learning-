# Section 1 (E & F): Transactions, Locking, Concurrency & Advanced Production Knowledge

> Sample tables used throughout: `Employee(EmployeeId, EmployeeName, DepartmentId, ManagerId, Salary, JoiningDate)`, `Department(DepartmentId, DepartmentName)`, `EmployeeSalaryHistory(Id, EmployeeId, Salary, EffectiveDate)`, `EmployeeAttendance(Id, EmployeeId, AttendanceDate, Status)`.

## Table of Contents

**E. Transactions, Locking and Concurrency**

- [Q76. What is a Transaction?](#q76-what-is-a-transaction-in-sql-server)
- [Q77. ACID properties](#q77-explain-acid-properties)
- [Q78. Transactions in Stored Procedures](#q78-how-do-you-implement-transactions-in-stored-procedures)
- [Q79. COMMIT and ROLLBACK](#q79-what-is-commit-and-rollback)
- [Q80. SAVE TRANSACTION](#q80-what-is-save-transaction)
- [Q81. TRY...CATCH](#q81-what-is-trycatch-in-sql-server)
- [Q82. XACT_STATE()](#q82-what-is-xact_state)
- [Q83. @@TRANCOUNT](#q83-what-is-trancount)
- [Q84. Deadlock](#q84-what-is-a-deadlock)
- [Q85. Identify and resolve a Deadlock](#q85-how-do-you-identify-and-resolve-a-deadlock)
- [Q86. Blocking](#q86-what-is-blocking-in-sql-server)
- [Q87. Blocking vs Deadlock](#q87-blocking-vs-deadlock)
- [Q88. WITH (NOLOCK)](#q88-what-is-with-nolock)
- [Q89. Disadvantages of NOLOCK](#q89-what-are-the-disadvantages-of-nolock)
- [Q90. Isolation Levels](#q90-explain-all-sql-server-isolation-levels)
- [Q91. Dirty Read](#q91-what-is-dirty-read)
- [Q92. Non-Repeatable Read](#q92-what-is-non-repeatable-read)
- [Q93. Phantom Read](#q93-what-is-phantom-read)
- [Q94. Snapshot Isolation](#q94-what-is-snapshot-isolation)
- [Q95. RCSI](#q95-what-is-read-committed-snapshot-isolation-rcsi)
- [Q96. Optimistic vs Pessimistic Concurrency](#q96-what-is-optimistic-vs-pessimistic-concurrency)
- [Q97. Shared, Exclusive and Update Locks](#q97-what-are-shared-exclusive-and-update-locks)
- [Q98. Lock Escalation](#q98-what-is-lock-escalation)
- [Q99. Row vs Page vs Table Locking](#q99-what-is-the-difference-between-row-level-page-level-and-table-level-locking)
- [Q100. Avoiding deadlocks](#q100-how-can-you-avoid-deadlocks-in-sql-server)

**F. Advanced SQL Server and Production Knowledge**

- [Q101. Internal query execution](#q101-what-happens-internally-when-a-sql-query-is-executed)
- [Q102. Query Optimizer](#q102-what-is-query-optimizer)
- [Q103. Parameter Sniffing](#q103-what-is-parameter-sniffing)
- [Q104. Identify and resolve Parameter Sniffing](#q104-how-do-you-identify-and-resolve-parameter-sniffing)
- [Q105. Query Store](#q105-what-is-query-store)
- [Q106. Wait Types](#q106-what-is-a-sql-server-wait-type)
- [Q107. TempDB](#q107-what-is-tempdb-why-is-it-important)
- [Q108. Connection Pooling](#q108-what-is-connection-pooling)
- [Q109. Checkpoint](#q109-what-is-a-checkpoint-in-sql-server)
- [Q110. Transaction Log](#q110-what-is-transaction-log)
- [Q111. Recovery Models](#q111-what-is-the-difference-between-full-simple-and-bulk-logged-recovery-models)
- [Q112. Log Shipping](#q112-what-is-log-shipping)
- [Q113. Database Mirroring](#q113-what-is-database-mirroring)
- [Q114. Always On Availability Group](#q114-what-is-always-on-availability-group)
- [Q115. Database Partitioning](#q115-what-is-database-partitioning)
- [Q116. Table vs Index Partitioning](#q116-what-is-table-partitioning-vs-index-partitioning)
- [Q117. Change Data Capture](#q117-what-is-change-data-capture-cdc)
- [Q118. Change Tracking](#q118-what-is-change-tracking)
- [Q119. SQL Server Agent](#q119-what-is-sql-server-agent)
- [Q120. Full vs Differential vs Log Backup](#q120-what-is-the-difference-between-full-backup-differential-backup-and-transaction-log-backup)

---

# E. Transactions, Locking and Concurrency

### Q76. What is a Transaction in SQL Server?

**Definition:** A transaction is a group of one or more SQL statements that run as a single unit of work. Either all of them succeed (commit) or none of them take effect (rollback).

**Real-world example:** An ATM transfer of ₹5,000 from Savings to Current: debit Savings and credit Current must both happen. If the credit fails, the debit must be undone — otherwise money "disappears".

**SQL example:**
```sql
BEGIN TRANSACTION;

    UPDATE Employee
    SET    Salary = Salary * 1.10
    WHERE  EmployeeId = 101;

    INSERT INTO EmployeeSalaryHistory (EmployeeId, Salary, EffectiveDate)
    SELECT EmployeeId, Salary, CAST(GETDATE() AS date)
    FROM   Employee
    WHERE  EmployeeId = 101;

COMMIT TRANSACTION;   -- both changes become permanent together
```

**Interview answer (7 yrs experience):** A transaction is SQL Server's way to guarantee that a set of changes is all-or-nothing. In our HRMS, a salary revision updates `Employee.Salary` and inserts a row into `EmployeeSalaryHistory`; if only one of these succeeded, payroll and audit would disagree. SQL Server has three modes: autocommit (default — each statement is its own transaction), explicit (`BEGIN TRAN ... COMMIT`), and implicit transactions (`SET IMPLICIT_TRANSACTIONS ON`). I always keep transactions as short as possible because every open transaction holds locks and prevents log truncation. A classic pitfall I've seen is opening a transaction in .NET, then calling an external API before committing — that held locks for seconds and caused blocking across the attendance module.

**Follow-up / Pro tip:**
- In Dapper, pass the `IDbTransaction` to every `Execute/Query` call (`conn.Execute(sql, param, transaction: tx)`); otherwise you get "ExecuteNonQuery requires the command to have a transaction" errors.
- `TransactionScope` can silently escalate to a distributed (MSDTC) transaction if you open two connections — be careful.

---

### Q77. Explain ACID properties.

**Definition:** ACID is the set of four guarantees a reliable transaction provides: **A**tomicity, **C**onsistency, **I**solation and **D**urability.

**Real-world example:** Train ticket booking (IRCTC): the seat is reserved and payment is taken together (Atomic); a seat can't be sold twice (Consistent); two people booking at the same time don't see each other's half-done booking (Isolated); once you get the PNR, it survives a server crash (Durable).

| Property | Meaning | How SQL Server enforces it |
|---|---|---|
| Atomicity | All or nothing | Transaction log + rollback |
| Consistency | Data moves from one valid state to another | Constraints (PK, FK, CHECK), triggers |
| Isolation | Concurrent transactions don't interfere | Locks / row versioning, isolation levels |
| Durability | Committed data survives crashes | Write-ahead logging (log hardened to disk on commit) |

**SQL example:**
```sql
-- Consistency: a CHECK constraint rejects invalid data, and the whole tran rolls back
ALTER TABLE Employee ADD CONSTRAINT CK_Employee_Salary CHECK (Salary > 0);

BEGIN TRY
    BEGIN TRAN;
        UPDATE Employee SET Salary = Salary + 5000 WHERE EmployeeId = 101;  -- OK
        UPDATE Employee SET Salary = -1          WHERE EmployeeId = 102;  -- violates CHECK
    COMMIT;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK;   -- Atomicity: employee 101's change is undone too
    THROW;
END CATCH;
```

**Interview answer (7 yrs experience):** ACID is what makes a relational database trustworthy for things like payroll. Atomicity and durability come from the transaction log — SQL Server uses write-ahead logging, so the log record is hardened to disk before the commit returns. Consistency is partly the database's job (constraints, FKs) and partly ours as developers (business rules in procs). Isolation is the tunable one — we choose between locking and row-versioning isolation levels, trading accuracy for concurrency. In our HRMS, we moved to RCSI for read-heavy dashboards while keeping critical payroll processing under stricter control. One nuance worth mentioning: Delayed Durability (SQL 2014+) relaxes the "D" for performance, which we never enable for financial data.

**Follow-up / Pro tip:**
- If asked "which property is most relaxed in practice?" — Isolation, since most systems run READ COMMITTED, not SERIALIZABLE.

---

### Q78. How do you implement transactions in Stored Procedures?

**Definition:** Wrap the data-modifying statements in `BEGIN TRAN ... COMMIT` inside a `TRY...CATCH` block, roll back in the `CATCH`, and re-throw the error to the caller. Use `SET XACT_ABORT ON` so any runtime error dooms the transaction.

**Real-world example:** An HR clerk processing an employee transfer: change department, log history, update the manager. If any step fails, the clerk tears up the whole form and starts fresh rather than leaving half the paperwork done.

**SQL example:**
```sql
CREATE OR ALTER PROCEDURE dbo.usp_TransferEmployee
    @EmployeeId      INT,
    @NewDepartmentId INT,
    @NewManagerId    INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;   -- any error => whole transaction rolled back, also on client timeout

    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (SELECT 1 FROM Department WHERE DepartmentId = @NewDepartmentId)
            THROW 50001, 'Department does not exist.', 1;

        UPDATE Employee
        SET    DepartmentId = @NewDepartmentId,
               ManagerId    = @NewManagerId
        WHERE  EmployeeId   = @EmployeeId;

        IF @@ROWCOUNT = 0
            THROW 50002, 'Employee not found.', 1;

        INSERT INTO EmployeeSalaryHistory (EmployeeId, Salary, EffectiveDate)
        SELECT EmployeeId, Salary, CAST(GETDATE() AS date)
        FROM   Employee WHERE EmployeeId = @EmployeeId;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        -- optional: log to an error table here (AFTER rollback, so the log row isn't rolled back)
        THROW;   -- re-raise original error to the .NET caller
    END CATCH
END;
```

**Interview answer (7 yrs experience):** My standard template is `SET NOCOUNT ON`, `SET XACT_ABORT ON`, `BEGIN TRY / BEGIN TRAN / COMMIT`, and in the `CATCH`: `IF @@TRANCOUNT > 0 ROLLBACK; THROW;`. `XACT_ABORT ON` is important because without it, some errors only abort the statement and the transaction stays open — and if the .NET client hits a command timeout, the transaction can remain open on a pooled connection holding locks. I log errors into an error table only after rollback, otherwise the log row gets rolled back too. I use `THROW` instead of `RAISERROR` because it preserves the original error number and line. In our HRMS, we also decided that either the proc or the Dapper layer owns the transaction, not both, to avoid nested-transaction confusion.

**Follow-up / Pro tip:**
- If the proc may be called inside an outer transaction, use the "savepoint pattern" (see Q80) instead of blindly rolling back the caller's transaction.

---

### Q79. What is COMMIT and ROLLBACK?

**Definition:** `COMMIT` makes all changes in the current transaction permanent and releases its locks. `ROLLBACK` undoes all changes since `BEGIN TRAN` (or since a savepoint) and releases locks.

**Real-world example:** Online shopping cart: "Place Order" = COMMIT; "Cancel / Payment failed" = ROLLBACK, the items go back to stock.

**SQL example:**
```sql
BEGIN TRAN;
    DELETE FROM EmployeeAttendance WHERE AttendanceDate = '2026-10-31';
    SELECT @@ROWCOUNT AS RowsDeleted;   -- Oops, 5,000 rows instead of 50!
ROLLBACK TRAN;  -- nothing deleted

BEGIN TRAN;
    UPDATE EmployeeAttendance SET Status = 'Present'
    WHERE  EmployeeId = 101 AND AttendanceDate = '2026-10-31';
COMMIT TRAN;    -- permanent
```

| | COMMIT | ROLLBACK |
|---|---|---|
| Effect | Saves changes | Undoes changes |
| Effect on @@TRANCOUNT | Decrements by 1 | Sets to 0 (unless to a savepoint) |
| Nested transactions | Only the outermost COMMIT really commits | Any ROLLBACK (without savepoint name) rolls back everything |
| Locks | Released | Released |

**Interview answer (7 yrs experience):** COMMIT hardens the log records to disk and releases locks; ROLLBACK uses the log to reverse the changes. An important detail is that in nested transactions, an inner `COMMIT` only decrements `@@TRANCOUNT` — nothing is actually committed until the outermost commit — whereas a plain `ROLLBACK` always rolls back everything to the outermost `BEGIN TRAN`. Also, a long-running ROLLBACK can take as long as or longer than the original work, which I've seen when someone killed a huge purge job — killing it didn't free the system immediately. For manual production fixes I always wrap changes in `BEGIN TRAN`, check `@@ROWCOUNT`, and only then commit.

**Follow-up / Pro tip:**
- `KILL <spid> WITH STATUSONLY` shows rollback progress of a killed session.

---

### Q80. What is SAVE TRANSACTION?

**Definition:** `SAVE TRANSACTION <name>` creates a savepoint inside a transaction. You can later `ROLLBACK TRANSACTION <name>` to undo only the work done after that savepoint, while keeping the earlier work and the transaction open.

**Real-world example:** A video game checkpoint: if you die in level 3, you restart from the checkpoint at level 3, not from level 1.

**SQL example:**
```sql
BEGIN TRAN;

    INSERT INTO EmployeeAttendance (EmployeeId, AttendanceDate, Status)
    VALUES (101, '2026-11-01', 'Present');

    SAVE TRANSACTION BeforeBonus;

    UPDATE Employee SET Salary = Salary + 100000 WHERE EmployeeId = 101;  -- wrong bonus

    ROLLBACK TRANSACTION BeforeBonus;   -- undo only the salary update
    SELECT @@TRANCOUNT AS TranCount;    -- still 1, transaction still open

COMMIT;   -- attendance insert is saved

-- Pattern for a proc that may run inside a caller's transaction
CREATE OR ALTER PROCEDURE dbo.usp_SafeChild
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @StartedTran BIT = 0;
    IF @@TRANCOUNT = 0 BEGIN BEGIN TRAN; SET @StartedTran = 1; END
    ELSE SAVE TRANSACTION usp_SafeChild;

    BEGIN TRY
        UPDATE Employee SET Salary = Salary * 1.05 WHERE DepartmentId = 10;
        IF @StartedTran = 1 COMMIT;
    END TRY
    BEGIN CATCH
        IF @StartedTran = 1 AND @@TRANCOUNT > 0 ROLLBACK;
        ELSE IF XACT_STATE() = 1 ROLLBACK TRANSACTION usp_SafeChild;
        THROW;
    END CATCH
END;
```

**Interview answer (7 yrs experience):** Savepoints let me do partial rollbacks. The most practical use I've had is in nested procedure calls — a child proc saves a savepoint if a transaction already exists, so on error it can undo only its own work and let the parent decide. Rolling back to a savepoint does not decrement `@@TRANCOUNT` and does not release locks taken after the savepoint. A pitfall: you cannot roll back to a savepoint if the transaction is doomed (`XACT_STATE() = -1`), and savepoints don't work with `XACT_ABORT ON` errors since the whole transaction is doomed. In batch imports of attendance, we used savepoints per row group so one bad group didn't kill the whole file.

**Follow-up / Pro tip:**
- Savepoints are not supported in distributed transactions.

---

### Q81. What is TRY...CATCH in SQL Server?

**Definition:** `TRY...CATCH` is structured error handling in T-SQL. If an error with severity 11–19 occurs inside `BEGIN TRY`, control jumps to `BEGIN CATCH`, where you can inspect the error with `ERROR_NUMBER()`, `ERROR_MESSAGE()`, etc.

**Real-world example:** A safety net under a trapeze artist — if they fall (error), the net (CATCH) handles it instead of a crash on the floor (unhandled error).

**SQL example:**
```sql
BEGIN TRY
    BEGIN TRAN;
        INSERT INTO Employee (EmployeeId, EmployeeName, DepartmentId, Salary, JoiningDate)
        VALUES (101, 'Duplicate PK', 10, 50000, GETDATE());  -- PK violation
    COMMIT;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK;

    SELECT ERROR_NUMBER()    AS ErrNo,      -- 2627
           ERROR_SEVERITY()  AS Severity,
           ERROR_STATE()     AS State,
           ERROR_PROCEDURE() AS ProcName,
           ERROR_LINE()      AS LineNo,
           ERROR_MESSAGE()   AS Msg;

    -- INSERT INTO dbo.ErrorLog(...) VALUES (...);
    THROW;   -- re-throw to the application
END CATCH;
```

**Interview answer (7 yrs experience):** TRY...CATCH is my default for any proc that modifies data. Inside CATCH I roll back if `@@TRANCOUNT > 0` (or check `XACT_STATE()`), log details, and `THROW` so the .NET layer gets a real `SqlException` — swallowing errors silently is a bug I've had to hunt down in legacy code where payroll "succeeded" but nothing was saved. Limitations to know: it does not catch compile errors or object-name resolution errors in the same scope (deferred name resolution), severity ≤ 10 informational messages, or severity ≥ 20 errors that kill the connection. Attention events like client timeouts also bypass CATCH, which is exactly why I pair it with `SET XACT_ABORT ON`.

**Follow-up / Pro tip:**
- `THROW` (2012+) vs `RAISERROR`: THROW always uses severity 16, respects XACT_ABORT, and re-throws the original error number with no arguments.

---

### Q82. What is XACT_STATE()?

**Definition:** `XACT_STATE()` returns the state of the current transaction: `1` = active and committable, `0` = no transaction, `-1` = active but **uncommittable (doomed)** — you can only roll it back.

**Real-world example:** A traffic light for your transaction: green (1) you can commit, no light (0) nothing to do, red (-1) you must roll back.

**SQL example:**
```sql
SET XACT_ABORT ON;
BEGIN TRY
    BEGIN TRAN;
        UPDATE Employee SET Salary = Salary + 1000 WHERE EmployeeId = 101;
        SELECT 1/0;   -- error; with XACT_ABORT ON the transaction becomes doomed
    COMMIT;
END TRY
BEGIN CATCH
    IF XACT_STATE() = -1
    BEGIN
        PRINT 'Transaction is doomed - must roll back';
        ROLLBACK;
    END
    ELSE IF XACT_STATE() = 1
    BEGIN
        PRINT 'Transaction still committable - decide commit or rollback';
        ROLLBACK;   -- or COMMIT partial work if business allows
    END
    THROW;
END CATCH;
```

| Value | Meaning | @@TRANCOUNT | Allowed actions |
|---|---|---|---|
| 1 | Active, committable | ≥ 1 | COMMIT / ROLLBACK / save points |
| 0 | No active transaction | 0 | Nothing |
| -1 | Active, uncommittable | ≥ 1 | ROLLBACK only (no writes allowed) |

**Interview answer (7 yrs experience):** `@@TRANCOUNT` tells me *whether* a transaction exists, but `XACT_STATE()` tells me *whether I can still commit it*. That matters in CATCH blocks: if the transaction is doomed and I try to commit or even write to a log table, I get error 3930. So in my error-handling template I check `XACT_STATE() = -1` → full rollback; `= 1` → I can roll back to a savepoint or commit partial work. It's especially useful in nested procedures with savepoints, because you can only roll back to a savepoint when the state is 1.

---

### Q83. What is @@TRANCOUNT?

**Definition:** `@@TRANCOUNT` returns the number of active `BEGIN TRANSACTION` statements on the current connection. `BEGIN TRAN` increments it, `COMMIT` decrements it by 1, and `ROLLBACK` sets it to 0.

**Real-world example:** Like counting nested boxes: every BEGIN opens a box; every COMMIT closes one box; ROLLBACK throws away all boxes at once.

**SQL example:**
```sql
SELECT @@TRANCOUNT;    -- 0
BEGIN TRAN;            
SELECT @@TRANCOUNT;    -- 1
    BEGIN TRAN;        
    SELECT @@TRANCOUNT; -- 2
        UPDATE Employee SET Salary = Salary + 1 WHERE EmployeeId = 101;
    COMMIT;            -- inner commit: nothing really committed yet
    SELECT @@TRANCOUNT; -- 1
ROLLBACK;              -- rolls back EVERYTHING, including "committed" inner work
SELECT @@TRANCOUNT;    -- 0

-- Find sessions with open transactions (production troubleshooting)
SELECT s.session_id, s.login_name, s.host_name, s.program_name,
       st.transaction_id, at.transaction_begin_time
FROM   sys.dm_tran_session_transactions st
JOIN   sys.dm_exec_sessions s       ON s.session_id = st.session_id
JOIN   sys.dm_tran_active_transactions at ON at.transaction_id = st.transaction_id
ORDER BY at.transaction_begin_time;
```

**Interview answer (7 yrs experience):** `@@TRANCOUNT` is the guard I use before ROLLBACK/COMMIT in CATCH blocks — `IF @@TRANCOUNT > 0 ROLLBACK` avoids error 3903 ("ROLLBACK has no corresponding BEGIN"). It also proves that SQL Server doesn't truly support nested transactions: inner commits just decrement the counter. Error 266 ("Transaction count after EXECUTE indicates mismatching number of BEGIN and COMMIT") is a common symptom when a child proc rolls back the caller's transaction. In production, I've used `DBCC OPENTRAN` and the DMVs above to find a forgotten open transaction from an SSMS window that was blocking the payroll job.

---

### Q84. What is a Deadlock?

**Definition:** A deadlock happens when two (or more) sessions each hold a lock the other needs, so neither can proceed. SQL Server's deadlock monitor detects the cycle (about every 5 seconds) and kills one session — the "victim" — with error **1205**.

**Real-world example:** Two cars meet on a narrow one-lane bridge from opposite ends; neither can move forward until the other backs up. A traffic cop (deadlock monitor) forces one car to reverse.

**SQL example (Session 1 / Session 2):**
```sql
-- Step | Session 1                                         | Session 2
-- 1    | BEGIN TRAN;                                        |
--      | UPDATE Employee SET Salary = Salary + 100          |
--      | WHERE EmployeeId = 101;   -- X lock on emp 101     |
-- 2    |                                                    | BEGIN TRAN;
--      |                                                    | UPDATE Department SET DepartmentName = 'HR Ops'
--      |                                                    | WHERE DepartmentId = 10; -- X lock on dept 10
-- 3    | UPDATE Department SET DepartmentName = 'HR'        |
--      | WHERE DepartmentId = 10;  -- WAITS for Session 2   |
-- 4    |                                                    | UPDATE Employee SET Salary = Salary + 200
--      |                                                    | WHERE EmployeeId = 101; -- WAITS for Session 1
-- 5    | ---- DEADLOCK: SQL Server kills one session ----   |
--      | Msg 1205: Transaction (Process ID 63) was deadlocked on lock resources
--      | with another process and has been chosen as the deadlock victim. Rerun the transaction.
```

**Interview answer (7 yrs experience):** A deadlock is a circular wait — unlike blocking, it never resolves on its own, so SQL Server picks a victim, usually the transaction that's cheapest to roll back, unless `SET DEADLOCK_PRIORITY` says otherwise. Common types I've seen are the classic opposite-order update deadlock, key lookup deadlocks (a SELECT using a nonclustered index plus key lookup versus an UPDATE on the clustered index), and parallelism deadlocks. In our HRMS, the month-end attendance job and the leave-approval API updated `EmployeeAttendance` and `Employee` in opposite order, which caused 1205 errors daily. The fix was standardizing access order and adding a covering index. Our .NET layer also retries on error 1205 with a small back-off.

---

### Q85. How do you identify and resolve a Deadlock?

**Definition:** Identify deadlocks by capturing the deadlock graph (XML) — from the built-in `system_health` Extended Events session, a custom XE session, or trace flag 1222. Resolve by analyzing the graph and fixing access order, indexing, transaction length, or isolation level.

**Real-world example:** After a traffic jam, police review the CCTV (deadlock graph) to see which cars blocked which, then redesign the junction (code/index fix).

**SQL example:**
```sql
-- 1) Read deadlock graphs from the built-in system_health session (always on, 2012+)
SELECT  xed.value('@timestamp', 'datetime2') AS DeadlockTimeUtc,
        xed.query('.')                       AS DeadlockGraph
FROM (
    SELECT CAST(target_data AS XML) AS TargetData
    FROM   sys.dm_xe_session_targets t
    JOIN   sys.dm_xe_sessions s ON s.address = t.event_session_address
    WHERE  s.name = 'system_health' AND t.target_name = 'ring_buffer'
) AS src
CROSS APPLY TargetData.nodes('RingBufferTarget/event[@name="xml_deadlock_report"]') AS x(xed)
ORDER BY DeadlockTimeUtc DESC;

-- Or from the event file target (survives longer than ring buffer)
SELECT CAST(event_data AS XML) AS DeadlockGraph
FROM   sys.fn_xe_file_target_read_file('system_health*.xel', NULL, NULL, NULL)
WHERE  object_name = 'xml_deadlock_report';

-- 2) Optional: write deadlocks to the error log
DBCC TRACEON (1222, -1);

-- 3) Typical fixes
-- a. Covering index to avoid key-lookup deadlocks
CREATE NONCLUSTERED INDEX IX_EmployeeAttendance_Emp_Date
ON EmployeeAttendance (EmployeeId, AttendanceDate) INCLUDE (Status);

-- b. Lower priority for a background job so the user request wins
SET DEADLOCK_PRIORITY LOW;

-- c. Enable RCSI to remove reader/writer deadlocks
ALTER DATABASE HRMS SET READ_COMMITTED_SNAPSHOT ON WITH ROLLBACK IMMEDIATE;
```

**Interview answer (7 yrs experience):** First I pull the deadlock XML from `system_health` — no setup needed — and open it as `.xdl` in SSMS to see the graph. The graph shows the victim, the processes, the exact statements, the resources (key, page, object), and the lock modes held and requested. Then I fix the root cause: access tables in the same order, make transactions shorter, add a covering index so reads don't touch the clustered index, use `UPDLOCK` for read-then-update patterns, or enable RCSI so readers stop taking shared locks. In our HRMS, a reader/writer deadlock between the dashboard and the payroll update disappeared after enabling RCSI. And since deadlocks can never be reduced to zero, our Dapper repository has a retry policy (Polly) for `SqlException.Number == 1205`.

**Follow-up / Pro tip:**
- The ring buffer may lose old events; for persistent tracking create a dedicated XE session with an `event_file` target for `xml_deadlock_report`.
- Azure SQL: query `sys.event_log` / database-scoped XE instead of system_health.

---

### Q86. What is Blocking in SQL Server?

**Definition:** Blocking happens when one session holds a lock on a resource and another session needs an incompatible lock on the same resource, so it waits. It's normal and temporary — it ends when the first session commits or rolls back.

**Real-world example:** A single ATM: you have to wait in the queue while the person in front finishes. You're blocked, not stuck forever.

**SQL example (Session 1 / Session 2):**
```sql
-- Session 1
BEGIN TRAN;
UPDATE Employee SET Salary = Salary + 500 WHERE EmployeeId = 101;
-- (no commit yet)

-- Session 2
SELECT * FROM Employee WHERE EmployeeId = 101;   -- waits (under default READ COMMITTED)

-- Session 3: find who is blocking whom
SELECT r.session_id, r.blocking_session_id, r.wait_type, r.wait_time,
       r.wait_resource, t.text AS running_sql
FROM   sys.dm_exec_requests r
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) t
WHERE  r.blocking_session_id <> 0;

-- What locks are held/waited on
SELECT request_session_id, resource_type, resource_description,
       request_mode, request_status
FROM   sys.dm_tran_locks
WHERE  resource_database_id = DB_ID();

-- Head blocker's last statement (it may be idle, i.e. "sleeping" with open tran)
SELECT s.session_id, s.status, s.open_transaction_count, t.text
FROM   sys.dm_exec_sessions s
JOIN   sys.dm_exec_connections c ON c.session_id = s.session_id
CROSS APPLY sys.dm_exec_sql_text(c.most_recent_sql_handle) t
WHERE  s.session_id = 55;  -- head blocker
```

**Interview answer (7 yrs experience):** Blocking is the expected side effect of locking — a problem only when it's long. Typical causes I've seen are long transactions, missing indexes causing scans that lock many rows, lock escalation, and "sleeping sessions with open transactions" where the app forgot to commit. I use `sys.dm_exec_requests` (blocking_session_id), `sys.dm_tran_locks`, `sp_WhoIsActive`, and the blocked process report (`blocked process threshold`) to find the head blocker. In one incident, a Dapper call threw an exception before commit and the transaction wasn't disposed, leaving a sleeping session blocking the entire `Employee` table for 20 minutes. Fixes were `using` blocks for transactions, `XACT_ABORT ON`, proper indexes, and RCSI for readers.

**Follow-up / Pro tip:**
- `sp_configure 'blocked process threshold (s)', 10` + XE `blocked_process_report` captures blocking longer than 10 seconds.

---

### Q87. Blocking vs Deadlock.

**Definition:** Blocking is one session waiting for another to release a lock — it resolves itself. A deadlock is a circular wait where sessions wait for each other forever, so SQL Server must kill one.

**Real-world example:** Blocking = waiting in a queue at a bank counter. Deadlock = two people at a doorway each saying "you first" forever, until a guard forces one to move.

| Aspect | Blocking | Deadlock |
|---|---|---|
| Nature | One-way wait (A waits for B) | Circular wait (A waits B, B waits A) |
| Resolves itself? | Yes, when blocker commits/rolls back | No — SQL Server kills a victim |
| Error | None (or app timeout) | Error 1205 |
| Duration | Can be ms to hours | Detected within ~5 seconds |
| Detection | `sys.dm_exec_requests.blocking_session_id`, blocked process report | Deadlock graph via `system_health` XE |
| Typical fix | Shorter transactions, indexes, RCSI | Consistent access order, indexes, RCSI, retry logic |

**SQL example:**
```sql
-- Blocking check
SELECT session_id, blocking_session_id, wait_type, wait_time
FROM   sys.dm_exec_requests WHERE blocking_session_id > 0;

-- Deadlock count since restart
SELECT cntr_value AS DeadlocksSinceRestart
FROM   sys.dm_os_performance_counters
WHERE  counter_name = 'Number of Deadlocks/sec' AND instance_name = '_Total';
```

**Interview answer (7 yrs experience):** I explain it simply: every deadlock involves blocking, but most blocking is not a deadlock. Blocking is a performance issue — users see slow screens or command timeouts in .NET (default 30 seconds). A deadlock is a correctness issue — one transaction is actually rolled back and the app must retry. For blocking I chase the head blocker and long transactions; for deadlocks I read the graph and fix access order or indexes. In our HRMS, payroll timeouts were blocking from a long-running report, while the 1205 errors were a separate access-order issue — treating them differently was key.

---

### Q88. What is WITH (NOLOCK)?

**Definition:** `WITH (NOLOCK)` is a table hint equivalent to `READUNCOMMITTED`. The query doesn't take shared locks and isn't blocked by exclusive locks, so it can read uncommitted ("dirty") data.

**Real-world example:** Reading a colleague's draft email over their shoulder before they hit Send — they may still edit or delete it.

**SQL example (Session 1 / Session 2):**
```sql
-- Session 1
BEGIN TRAN;
UPDATE Employee SET Salary = 999999 WHERE EmployeeId = 101;
-- not committed

-- Session 2
SELECT EmployeeId, Salary FROM Employee WITH (NOLOCK) WHERE EmployeeId = 101;
-- returns 999999 immediately (dirty read), not blocked

-- Session 1
ROLLBACK;   -- Session 2 reported a salary that never existed

-- Equivalent session-level setting
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
```

**Interview answer (7 yrs experience):** NOLOCK makes a SELECT ignore locks held by others, so it avoids blocking — that's why it's popular in legacy code. But it's not "free performance": it trades correctness for concurrency. Note it still takes a schema stability (Sch-S) lock, so it can be blocked by DDL like index rebuilds, and it's ignored on target tables of UPDATE/DELETE. In our HRMS I inherited hundreds of NOLOCK hints; we replaced them by enabling RCSI, which gives non-blocking reads of committed data. I only accept NOLOCK for rough monitoring queries where approximate numbers are fine, never for payroll or financial figures.

---

### Q89. What are the disadvantages of NOLOCK?

**Definition:** NOLOCK can return incorrect results: dirty reads, missing rows, duplicate rows, and even error 601 ("could not continue scan with NOLOCK due to data movement").

**Real-world example:** Counting people in a moving queue while people are still joining and switching positions — you may count someone twice or miss someone.

| Problem | What happens |
|---|---|
| Dirty reads | Reads data that is later rolled back |
| Missing rows | Allocation-order scans skip rows moved by page splits |
| Duplicate rows | Same row read twice after it moves during the scan |
| Inconsistent reads | Half of a multi-row update visible |
| Error 601 | Query fails due to data movement |
| False sense of safety | Still blocked by Sch-M locks (DDL, index rebuild) |

**SQL example:**
```sql
-- Session 1: page splits move rows while scanning
BEGIN TRAN;
UPDATE Employee SET EmployeeName = REPLICATE('X', 400) WHERE DepartmentId = 10; -- rows grow, pages split

-- Session 2: totals may double-count or skip moved rows
SELECT COUNT(*), SUM(Salary) FROM Employee WITH (NOLOCK);

-- Better alternative: RCSI (database level) - readers see last committed version
ALTER DATABASE HRMS SET READ_COMMITTED_SNAPSHOT ON WITH ROLLBACK IMMEDIATE;
```

**Interview answer (7 yrs experience):** Most developers know about dirty reads, but the bigger risk is missing or duplicate rows during scans, because NOLOCK allows allocation-order scans while pages split. Imagine a payroll total that's off because an employee was counted twice — that's a real audit risk. In our HRMS, a headcount report occasionally showed numbers that didn't match the detail screen, and the cause was NOLOCK on a table with heavy inserts. We moved to RCSI, removed the hints, and the mismatch disappeared. My rule: NOLOCK is a code smell; fix blocking with indexes, short transactions and row versioning instead.

---

### Q90. Explain all SQL Server Isolation Levels.

**Definition:** An isolation level controls how much one transaction is isolated from changes made by other concurrent transactions. SQL Server has four pessimistic (locking) levels — READ UNCOMMITTED, READ COMMITTED, REPEATABLE READ, SERIALIZABLE — and two optimistic (row-versioning) options — SNAPSHOT and READ COMMITTED SNAPSHOT (RCSI).

**Real-world example:** Think of privacy levels in a shared office: open desk (Read Uncommitted — anyone sees your drafts), cubicle (Read Committed), locked cabin (Repeatable Read), entire floor reserved (Serializable), and a photocopy of the documents taken at a point in time (Snapshot).

| Isolation level | Dirty read | Non-repeatable read | Phantom read | Mechanism | Concurrency |
|---|---|---|---|---|---|
| READ UNCOMMITTED | Yes | Yes | Yes | No shared locks | Highest |
| READ COMMITTED (default) | No | Yes | Yes | S locks released after each read | High |
| READ COMMITTED SNAPSHOT (RCSI) | No | Yes | Yes | Row versions, statement-level | High, readers don't block writers |
| REPEATABLE READ | No | No | Yes | S locks held until end of tran | Lower |
| SNAPSHOT | No | No | No | Row versions, transaction-level; update conflicts detected | High |
| SERIALIZABLE | No | No | No | Key-range locks held until end | Lowest |

**SQL example:**
```sql
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;     -- default
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

ALTER DATABASE HRMS SET ALLOW_SNAPSHOT_ISOLATION ON;
SET TRANSACTION ISOLATION LEVEL SNAPSHOT;

ALTER DATABASE HRMS SET READ_COMMITTED_SNAPSHOT ON WITH ROLLBACK IMMEDIATE; -- RCSI

-- Check isolation level of current sessions
SELECT session_id,
       CASE transaction_isolation_level
            WHEN 1 THEN 'ReadUncommitted' WHEN 2 THEN 'ReadCommitted'
            WHEN 3 THEN 'RepeatableRead'  WHEN 4 THEN 'Serializable'
            WHEN 5 THEN 'Snapshot' END AS IsolationLevel
FROM sys.dm_exec_sessions WHERE is_user_process = 1;

-- Check database settings
SELECT name, is_read_committed_snapshot_on, snapshot_isolation_state_desc
FROM sys.databases;
```

**Interview answer (7 yrs experience):** The default is READ COMMITTED, which in a locking implementation means readers and writers block each other. Higher levels (REPEATABLE READ, SERIALIZABLE) prevent more anomalies but hold locks longer, increasing blocking and deadlocks. The optimistic options use row versions in tempdb (or the PVS with ADR in 2019+), so readers don't block writers. In our HRMS we turned on RCSI database-wide, which removed most reader/writer blocking, and we use SERIALIZABLE (or `UPDLOCK, HOLDLOCK`) only for very specific critical sections like generating unique employee codes. One trap: `TransactionScope` in .NET defaults to SERIALIZABLE, so we always explicitly set `IsolationLevel.ReadCommitted`.

**Follow-up / Pro tip:**
- The isolation level persists on a pooled connection in older versions — a SERIALIZABLE set in one request could leak into the next. Always set it explicitly.

---

### Q91. What is Dirty Read?

**Definition:** A dirty read occurs when a transaction reads data that another transaction has modified but not yet committed. If that change is rolled back, the reader has used data that never officially existed.

**Real-world example:** An HR manager sees a draft salary hike of 50% on screen and announces it, but Finance cancels the change a minute later.

**SQL example (Session 1 / Session 2):**
```sql
-- Session 1
BEGIN TRAN;
UPDATE Employee SET Salary = 150000 WHERE EmployeeId = 101;  -- was 100000

-- Session 2
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SELECT Salary FROM Employee WHERE EmployeeId = 101;   -- 150000 (dirty)

-- Session 1
ROLLBACK;  -- actual salary stays 100000; Session 2 used wrong data
```

**Interview answer (7 yrs experience):** A dirty read is only possible under READ UNCOMMITTED or with NOLOCK hints. It's dangerous in financial systems — imagine generating a payslip based on an uncommitted salary revision that is later rolled back. READ COMMITTED and above prevent it; RCSI prevents it without blocking by reading the last committed version. In our HRMS code reviews, any NOLOCK on salary or payroll tables is rejected.

---

### Q92. What is Non-Repeatable Read?

**Definition:** A non-repeatable read happens when a transaction reads the same row twice and gets different values, because another transaction updated and committed that row in between.

**Real-world example:** You check a flight's price, then check again while booking — the price changed because someone else updated it in between.

**SQL example (Session 1 / Session 2):**
```sql
-- Session 1 (READ COMMITTED)
BEGIN TRAN;
SELECT Salary FROM Employee WHERE EmployeeId = 101;   -- 100000

-- Session 2
UPDATE Employee SET Salary = 120000 WHERE EmployeeId = 101;  -- commits (autocommit)

-- Session 1
SELECT Salary FROM Employee WHERE EmployeeId = 101;   -- 120000 (different!)
COMMIT;

-- Prevent it: REPEATABLE READ holds S locks until end of transaction
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;   -- Session 2's update would WAIT
-- or SNAPSHOT: Session 1 keeps seeing 100000 without blocking Session 2
```

**Interview answer (7 yrs experience):** Under READ COMMITTED, shared locks are released immediately after each read, so values can change within my transaction. That matters when a proc reads a salary, does calculations, and then reads again for validation. REPEATABLE READ prevents it by holding shared locks, at the cost of blocking writers; SNAPSHOT prevents it with versioning. In payroll calculation we used SNAPSHOT isolation so the whole calculation saw one consistent view of employee data without blocking HR updates during the run.

---

### Q93. What is Phantom Read?

**Definition:** A phantom read happens when a transaction runs the same query twice and the second time gets extra (or fewer) rows, because another transaction inserted or deleted rows that match the filter.

**Real-world example:** You count the guests on a party list (20), and while you order food someone adds two more names — a recount shows 22 "phantom" guests.

**SQL example (Session 1 / Session 2):**
```sql
-- Session 1 (REPEATABLE READ)
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
BEGIN TRAN;
SELECT COUNT(*) FROM Employee WHERE DepartmentId = 10;   -- 20

-- Session 2
INSERT INTO Employee (EmployeeId, EmployeeName, DepartmentId, Salary, JoiningDate)
VALUES (999, 'New Joiner', 10, 40000, GETDATE());        -- succeeds

-- Session 1
SELECT COUNT(*) FROM Employee WHERE DepartmentId = 10;   -- 21 (phantom row)
COMMIT;

-- Prevent it: SERIALIZABLE takes key-range locks (needs an index on DepartmentId)
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;   -- Session 2's insert would WAIT
```

**Interview answer (7 yrs experience):** REPEATABLE READ locks only rows already read, so new rows matching the range can still appear. SERIALIZABLE prevents this with key-range locks, and SNAPSHOT prevents it with a consistent point-in-time view. A pitfall: without a suitable index on the filter column, SERIALIZABLE may lock the whole table instead of a key range, killing concurrency. In our HRMS, department headcount budgeting needed a stable count during approval, so we used `WITH (UPDLOCK, HOLDLOCK)` on a narrow index range instead of making the whole transaction serializable.

---

### Q94. What is Snapshot Isolation?

**Definition:** Snapshot isolation gives a transaction a consistent view of the data as it was when the transaction started, using row versions stored in tempdb. Readers don't block writers and writers don't block readers; if two transactions update the same row, the second gets an update-conflict error (3960).

**Real-world example:** Taking a photo of the notice board at 9 AM — you read from the photo all day, even if someone changes the board later.

**SQL example (Session 1 / Session 2):**
```sql
ALTER DATABASE HRMS SET ALLOW_SNAPSHOT_ISOLATION ON;

-- Session 1
SET TRANSACTION ISOLATION LEVEL SNAPSHOT;
BEGIN TRAN;
SELECT Salary FROM Employee WHERE EmployeeId = 101;   -- 100000

-- Session 2 (not blocked)
UPDATE Employee SET Salary = 120000 WHERE EmployeeId = 101;   -- commits

-- Session 1
SELECT Salary FROM Employee WHERE EmployeeId = 101;   -- still 100000 (consistent snapshot)
UPDATE Employee SET Salary = Salary + 1000 WHERE EmployeeId = 101;
-- Msg 3960: Snapshot isolation transaction aborted due to update conflict.
ROLLBACK;

-- Monitor version store
SELECT * FROM sys.dm_tran_version_store_space_usage;
SELECT * FROM sys.dm_tran_active_snapshot_database_transactions;
```

**Interview answer (7 yrs experience):** Snapshot isolation is transaction-level consistency without locking reads. It must be enabled at the database level with `ALLOW_SNAPSHOT_ISOLATION ON` and then requested per session. I use it for long reports or payroll calculations that need a consistent view across many queries. Trade-offs: every update writes a version into tempdb (plus 14 bytes per row overhead), long-running snapshot transactions grow the version store, and writers must handle error 3960 with retry logic. So I don't use it for heavily write-contended updates — there, pessimistic locking with `UPDLOCK` is simpler.

---

### Q95. What is Read Committed Snapshot Isolation (RCSI)?

**Definition:** RCSI is a database option that changes the default READ COMMITTED level to use row versioning instead of shared locks. Each **statement** sees the last committed data as of the moment the statement started, so readers never block writers and vice versa.

**Real-world example:** A live cricket scoreboard that refreshes each time you look at it — you always see the last confirmed score, never the umpire's undecided review.

**SQL example:**
```sql
-- Enable (needs exclusive access briefly)
ALTER DATABASE HRMS SET READ_COMMITTED_SNAPSHOT ON WITH ROLLBACK IMMEDIATE;

-- Session 1
BEGIN TRAN;
UPDATE Employee SET Salary = 120000 WHERE EmployeeId = 101;

-- Session 2 (default READ COMMITTED, now RCSI)
SELECT Salary FROM Employee WHERE EmployeeId = 101;  -- returns 100000 immediately, no blocking

-- Need locking read for a specific case under RCSI
SELECT Salary FROM Employee WITH (READCOMMITTEDLOCK) WHERE EmployeeId = 101;
```

| | RCSI | Snapshot Isolation |
|---|---|---|
| Consistency scope | Per statement | Per transaction |
| Enable | `READ_COMMITTED_SNAPSHOT ON` | `ALLOW_SNAPSHOT_ISOLATION ON` + `SET TRANSACTION ISOLATION LEVEL SNAPSHOT` |
| Code change needed | No (transparent) | Yes |
| Update conflicts (3960) | No | Yes |
| Default in | Azure SQL Database | — |

**Interview answer (7 yrs experience):** RCSI is usually my first recommendation for OLTP blocking problems because it requires no code change and removes reader/writer blocking and most NOLOCK usage. In our HRMS, enabling it cut timeout errors on the attendance dashboard dramatically. The trade-offs: extra tempdb version store usage, 14-byte row overhead, and a subtle behavior change — code that relied on readers blocking (e.g., "read then update" queue patterns) can now read stale data, so those need `UPDLOCK` or `READCOMMITTEDLOCK`. We tested such logic before switching. Writers still block writers under RCSI.

---

### Q96. What is Optimistic vs Pessimistic Concurrency?

**Definition:** Pessimistic concurrency assumes conflicts are likely, so it locks data before using it. Optimistic concurrency assumes conflicts are rare, so it doesn't lock — it checks at save time whether the data changed and handles the conflict.

**Real-world example:** Pessimistic = locking a meeting room key while you use it. Optimistic = editing a shared Google Doc and getting a "this version has changed" warning on conflict.

| Aspect | Pessimistic | Optimistic |
|---|---|---|
| Assumption | Conflicts are frequent | Conflicts are rare |
| Mechanism | Locks (UPDLOCK, HOLDLOCK, REPEATABLE READ, SERIALIZABLE) | Row versioning (SNAPSHOT/RCSI), `rowversion` column checks |
| Blocking | Yes | Minimal |
| Conflict handling | Prevented by waiting | Detected, app retries or shows message |
| Best for | High-contention, short critical sections | Web apps, long user think-time |

**SQL example:**
```sql
-- Pessimistic: lock row while deciding
BEGIN TRAN;
SELECT Salary FROM Employee WITH (UPDLOCK, ROWLOCK) WHERE EmployeeId = 101;
UPDATE Employee SET Salary = Salary + 5000 WHERE EmployeeId = 101;
COMMIT;

-- Optimistic: rowversion column
ALTER TABLE Employee ADD RowVer ROWVERSION;

-- App reads EmployeeId, Salary, RowVer ... user edits for 2 minutes ... then:
UPDATE Employee
SET    Salary = @NewSalary
WHERE  EmployeeId = @EmployeeId
  AND  RowVer = @OriginalRowVer;

IF @@ROWCOUNT = 0
    THROW 50010, 'Record was modified by another user. Please reload.', 1;
```

**Interview answer (7 yrs experience):** For web screens in our HRMS, like editing an employee profile, we use optimistic concurrency with a `rowversion` column — Dapper passes the original version and if `@@ROWCOUNT = 0` we tell the user someone else changed it. Holding locks during user think-time would be terrible for concurrency. For short server-side critical sections — like allocating the next leave-request number or deducting leave balance — we use pessimistic `UPDLOCK` so two requests can't both deduct from the same balance. Choosing the right one per use case is the real skill.

---

### Q97. What are Shared, Exclusive and Update Locks?

**Definition:** **Shared (S)** locks are taken for reading; many sessions can hold them together. **Exclusive (X)** locks are taken for modifying data; only one session can hold one and it's incompatible with all others. **Update (U)** locks are taken when a row is read with intent to update; only one session can hold U, which prevents the common conversion deadlock.

**Real-world example:** A library book: many people can read the reference copy at the same time (S). Someone booking it for repair takes it away exclusively (X). A U lock is like putting a "reserved for repair" tag — others can still read it, but no one else can reserve it.

| Requested ↓ / Held → | S | U | X |
|---|---|---|---|
| **S** | ✅ | ✅ | ❌ |
| **U** | ✅ | ❌ | ❌ |
| **X** | ❌ | ❌ | ❌ |

Other locks: Intent locks (IS, IX, IU) at page/table level, Schema locks (Sch-S, Sch-M), Key-range locks (Serializable), Bulk Update (BU).

**SQL example (Session 1 / Session 2):**
```sql
-- Without U lock: conversion deadlock
-- Session 1: BEGIN TRAN; SELECT Salary FROM Employee WITH (HOLDLOCK) WHERE EmployeeId=101; -- S
-- Session 2: BEGIN TRAN; SELECT Salary FROM Employee WITH (HOLDLOCK) WHERE EmployeeId=101; -- S
-- Session 1: UPDATE Employee SET Salary=1 WHERE EmployeeId=101;  -- needs X, waits for S2
-- Session 2: UPDATE Employee SET Salary=2 WHERE EmployeeId=101;  -- needs X, waits for S1 => DEADLOCK

-- With U lock: second session simply waits
-- Session 1: BEGIN TRAN; SELECT Salary FROM Employee WITH (UPDLOCK) WHERE EmployeeId=101;  -- U
-- Session 2: BEGIN TRAN; SELECT Salary FROM Employee WITH (UPDLOCK) WHERE EmployeeId=101;  -- waits
-- Session 1: UPDATE ...; COMMIT;   -- Session 2 proceeds afterwards

-- View locks
SELECT request_session_id, resource_type, resource_description,
       request_mode, request_status
FROM   sys.dm_tran_locks
WHERE  resource_database_id = DB_ID()
ORDER BY request_session_id;
```

**Interview answer (7 yrs experience):** S locks for reads, X for writes, and U is the clever one used internally by UPDATE statements while searching for rows, then converted to X. When I write "read then update" logic, like checking leave balance before deducting, I use `WITH (UPDLOCK)` to explicitly take a U lock — this serializes competing requests without the S→X conversion deadlock. I also explain intent locks: an X on a row puts IX on the page and table, so SQL Server can quickly check table-level compatibility. And Sch-M locks during index rebuilds or ALTER TABLE block even NOLOCK readers, which surprises many developers.

---

### Q98. What is Lock Escalation?

**Definition:** Lock escalation is when SQL Server converts many fine-grained locks (row/page) into a single table-level (or partition-level) lock to save memory. It's triggered at roughly **5,000 locks** on one object by a single statement, or under lock memory pressure.

**Real-world example:** Instead of putting "reserved" tags on 5,000 individual seats in a stadium, the manager just locks the entire stadium gate — simpler, but nobody else can get in.

**SQL example:**
```sql
-- A large update can escalate to a table X lock, blocking everyone
UPDATE EmployeeAttendance SET Status = 'Absent'
WHERE  AttendanceDate < '2025-01-01';   -- touches 2 million rows

-- Batch it to stay below the threshold
WHILE 1 = 1
BEGIN
    UPDATE TOP (4000) EmployeeAttendance
    SET    Status = 'Archived'
    WHERE  AttendanceDate < '2025-01-01' AND Status <> 'Archived';
    IF @@ROWCOUNT = 0 BREAK;
END;

-- Control escalation per table
ALTER TABLE EmployeeAttendance SET (LOCK_ESCALATION = AUTO);    -- partition-level if partitioned
ALTER TABLE EmployeeAttendance SET (LOCK_ESCALATION = DISABLE); -- use carefully
-- default = TABLE

-- Monitor escalations
SELECT OBJECT_NAME(object_id) AS TableName, index_id,
       index_lock_promotion_attempt_count, index_lock_promotion_count
FROM   sys.dm_db_index_operational_stats(DB_ID(), NULL, NULL, NULL)
WHERE  index_lock_promotion_count > 0;
```

**Interview answer (7 yrs experience):** Lock escalation protects memory but hurts concurrency, because one big statement suddenly holds a table lock. In our HRMS, a nightly attendance archive job escalated to a table X lock and blocked the morning check-in API for employees in another time zone. We fixed it by batching updates in chunks of ~4,000 rows with short transactions, and adding an index so the statement didn't scan and lock more rows than needed. SQL Server escalates directly to table (or partition with `AUTO`), never row-to-page. Disabling escalation is possible but risks lock memory pressure, so batching is my preferred fix.

**Follow-up / Pro tip:**
- XE event `lock_escalation` captures exactly which statement escalated.

---

### Q99. What is the difference between Row-Level, Page-Level and Table-Level Locking?

**Definition:** These are lock granularities. Row-level locks a single row (best concurrency, most overhead); page-level locks an 8 KB page containing many rows; table-level locks the whole table (least overhead, worst concurrency). SQL Server chooses automatically, but you can hint it.

**Real-world example:** In a hotel: lock one room (row), one floor (page), or the whole hotel (table).

| Aspect | Row (RID/KEY) | Page (PAGE) | Table (OBJECT) |
|---|---|---|---|
| Granularity | Single row | 8 KB page | Entire table |
| Concurrency | Highest | Medium | Lowest |
| Lock overhead / memory | Highest | Medium | Lowest |
| Typical use | OLTP single-row updates | Range scans | Bulk loads, escalation, TABLOCK |
| Hint | `ROWLOCK` | `PAGLOCK` | `TABLOCK` / `TABLOCKX` |

**SQL example:**
```sql
UPDATE Employee WITH (ROWLOCK) SET Salary = Salary + 100 WHERE EmployeeId = 101;
SELECT * FROM Employee WITH (PAGLOCK) WHERE DepartmentId = 10;
INSERT INTO EmployeeSalaryHistory WITH (TABLOCK) (EmployeeId, Salary, EffectiveDate)
SELECT EmployeeId, Salary, GETDATE() FROM Employee;   -- enables minimal logging in some cases

-- See granularity being used
SELECT resource_type, request_mode, COUNT(*) AS LockCount
FROM   sys.dm_tran_locks
WHERE  request_session_id = @@SPID
GROUP BY resource_type, request_mode;

-- Index-level options
ALTER INDEX PK_Employee ON Employee SET (ALLOW_PAGE_LOCKS = ON, ALLOW_ROW_LOCKS = ON);
```

**Interview answer (7 yrs experience):** SQL Server dynamically picks the granularity, usually starting with row/key locks for OLTP, and escalates to table when locks exceed the threshold. I rarely use hints; `ROWLOCK` doesn't prevent escalation and can even increase lock memory. Where I do use them: `TABLOCK` for bulk inserts into staging tables to get minimal logging and parallel insert, and `UPDLOCK, ROWLOCK` for single-row critical sections. Turning off page locks on an index also breaks `ALTER INDEX REORGANIZE`, a gotcha I hit once with maintenance jobs.

---

### Q100. How can you avoid deadlocks in SQL Server?

**Definition:** You can't eliminate deadlocks 100%, but you can minimize them by accessing objects in a consistent order, keeping transactions short, using proper indexes, choosing the right isolation level, and adding retry logic in the application.

**Real-world example:** In a city, traffic rules like "everyone drives on the left" and "one-way streets" prevent cars from facing each other head-on.

**SQL example:**
```sql
-- 1. Consistent access order: always Employee first, then EmployeeSalaryHistory
BEGIN TRAN;
    UPDATE Employee SET Salary = @NewSalary WHERE EmployeeId = @EmpId;
    INSERT INTO EmployeeSalaryHistory (EmployeeId, Salary, EffectiveDate)
    VALUES (@EmpId, @NewSalary, GETDATE());
COMMIT;

-- 2. UPDLOCK for read-then-write patterns
BEGIN TRAN;
    SELECT @Bal = Salary FROM Employee WITH (UPDLOCK, ROWLOCK) WHERE EmployeeId = @EmpId;
    UPDATE Employee SET Salary = @Bal + 1000 WHERE EmployeeId = @EmpId;
COMMIT;

-- 3. Covering index to avoid key lookups
CREATE INDEX IX_Employee_Dept ON Employee (DepartmentId) INCLUDE (EmployeeName, Salary);

-- 4. Row versioning for readers
ALTER DATABASE HRMS SET READ_COMMITTED_SNAPSHOT ON WITH ROLLBACK IMMEDIATE;

-- 5. Retry in T-SQL (or better in the app via Polly)
DECLARE @Retry INT = 3;
WHILE @Retry > 0
BEGIN
    BEGIN TRY
        BEGIN TRAN;
            UPDATE Employee SET Salary = Salary + 100 WHERE EmployeeId = 101;
        COMMIT;
        BREAK;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        IF ERROR_NUMBER() = 1205 AND @Retry > 1
        BEGIN SET @Retry -= 1; WAITFOR DELAY '00:00:00.200'; END
        ELSE THROW;
    END CATCH
END;
```

**Interview answer (7 yrs experience):** My checklist is: same object access order across all procs; short transactions with no user interaction or API calls inside; covering indexes so reads and writes touch fewer resources; `UPDLOCK` for read-then-update; batch big updates to avoid escalation; RCSI to eliminate reader/writer deadlocks; and set `DEADLOCK_PRIORITY LOW` for background jobs. Finally, I accept that some deadlocks will still happen, so the application retries on error 1205 — in our .NET Core HRMS we used a Polly policy around Dapper calls. I also monitor `system_health` weekly so new deadlock patterns are caught early after releases.

---

## F. Advanced SQL Server and Production Knowledge

### Q101. What happens internally when a SQL query is executed?

**Definition:** When a client application sends a T-SQL query, SQL Server processes it through two core engines: the **Relational Engine** (which parses, binds, compiles, and optimizes the execution plan) and the **Storage Engine** (which reads/writes 8 KB data pages in the buffer pool, acquires locks, and logs changes to the transaction log).

**Real-world example:** Ordering custom furniture: The architect drafts blueprints, reviews material costs, and selects the most efficient construction plan (Relational Engine / Optimizer). The workshop carpenter then retrieves wood planks from the storage warehouse, cuts and assembles the table, and logs the inventory change in the ledger (Storage Engine).

**Internal Execution Lifecycle:**
```
Client App (Dapper/.NET) 
  --> TDS Protocol (Tabular Data Stream) over TCP/IP (SNI Network Interface)
  --> Relational Engine:
      1. Parsing (Syntax check)
      2. Binding / Algebrizer (Semantic check: validates tables & columns exist, produces parse tree)
      3. Plan Cache Lookup (Checks if hash of query text already has compiled plan)
      4. Query Optimization (If cache miss: cost-based optimization evaluates candidate plans using statistics)
  --> Storage Engine:
      1. Buffer Pool Manager (Checks if required 8 KB data pages are in RAM; if not, triggers disk read)
      2. Lock Manager (Acquires appropriate locks: Shared, Exclusive, Intent)
      3. Transaction Log Manager (Writes WAL - Write-Ahead Logging to LDF before dirty pages flush to MDF)
  --> Return results via TDS to Client
```

**SQL example:**
```sql
-- View cached execution plan and query text in the plan cache
SELECT 
    cp.objtype,
    cp.usecounts,
    cp.size_in_bytes,
    st.text AS QueryText,
    qp.query_plan AS ExecutionPlanXML
FROM sys.dm_exec_cached_plans cp
CROSS APPLY sys.dm_exec_sql_text(cp.plan_handle) st
CROSS APPLY sys.dm_exec_query_plan(cp.plan_handle) qp
WHERE st.text LIKE '%Employee%' AND st.text NOT LIKE '%sys.dm%';
```

**Interview answer (7 yrs experience):** "Understanding the separation between the Relational Engine and the Storage Engine is vital for diagnosing production latency. When a Dapper call arrives via TDS, the Relational Engine first checks the plan cache using a query hash. If missing, it compiles a plan using the Cost-Based Optimizer, which consumes CPU. Once compiled, execution passes to the Storage Engine. The Storage Engine checks the Buffer Pool (RAM); if pages are missing, an asynchronous physical disk read is dispatched, causing `PAGEIOLATCH_SH` waits. If pages are modified, SQL Server adheres strictly to Write-Ahead Logging (WAL): the change must harden to the transaction log file (`.ldf`) on disk before the dirty page is written to the `.mdf` file or the transaction is committed. Knowing this pipeline helps me pinpoint whether query slowness is caused by CPU compilation, memory pressure, or disk I/O bottlenecks."

---

### Q102. What is Query Optimizer?

**Definition:** The Query Optimizer is a cost-based software component within SQL Server's Relational Engine that evaluates multiple candidate physical execution plans for a given declarative SQL query and selects the plan with the lowest estimated computing cost.

**Real-world example:** A GPS navigation app like Google Maps: you declare *where* you want to go (declarative query), and the navigation engine calculates toll costs, traffic delays, and distance across 10 possible routes to pick the fastest route in under 2 seconds.

| Optimization Phase | What Happens |
|---|---|
| **Simplification** | Removes redundant logic (e.g. `1=1`, unneeded joins, contradictions like `WHERE 1=0`) |
| **Trivial Plan** | If there is only one obvious path (e.g. `SELECT * FROM tbl WHERE PK = 1`), skips full cost optimization |
| **Search Stage 0 (Transaction)** | Quick search for simple OLTP patterns |
| **Search Stage 1 (Quick Plan)** | Evaluates common join orders and index seeks; stops early if good enough |
| **Search Stage 2 (Full Optimization)** | Explores parallel plans, complex hash joins, and bushy trees (time-bound heuristic) |

**SQL example:**
```sql
-- View optimizer compile time and cost metrics
SET STATISTICS TIME ON;
SELECT e.EmployeeName, d.DepartmentName 
FROM dbo.Employee e
JOIN dbo.Department d ON e.DepartmentId = d.DepartmentId;
SET STATISTICS TIME OFF;
```

**Interview answer (7 yrs experience):** "SQL is declarative: we tell SQL Server *what* data we want, not *how* to physically retrieve it. The Query Optimizer doesn't seek the absolute theoretically perfect plan; it seeks a 'good enough plan in a reasonable amount of time'. It operates on cost heuristics driven by statistics. If the table is trivial, it outputs a Trivial Plan immediately. For complex queries, it moves through Optimization Stages 0, 1, and 2. If optimization time exceeds a threshold, it terminates with a 'Good Enough Plan Found' or 'Time Out' reason. A senior engineer knows that when the optimizer produces poor plans, 90% of the time it is due to inaccurate statistics, parameter sniffing, or non-SARGable syntax preventing cardinality estimation."

---

### Q103. What is Parameter Sniffing?

**Definition:** Parameter Sniffing is the default behavior where SQL Server inspects (sniffs) the parameter values passed during the *first* execution (compilation) of a stored procedure and creates an execution plan optimized specifically for those initial values, caching it for all subsequent executions.

**Real-world example:** Packing a travel suitcase: If your first trip is to Alaska in winter, you pack heavy thermal parkas. If SQL Server caches that exact packing plan for all future trips, you will end up wearing heavy winter parkas to a beach trip in Miami in July, causing extreme discomfort and sweating (resource waste).

**SQL example:**
```sql
-- Stored procedure vulnerable to parameter sniffing
CREATE OR ALTER PROCEDURE dbo.usp_GetEmployeesByDept
    @DeptId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT EmployeeId, EmployeeName, Salary 
    FROM dbo.Employee 
    WHERE DepartmentId = @DeptId;
END;
GO

-- Scenario:
-- 1. First execution: DeptId = 3 (Finance - only 0 rows).
--    Optimizer compiles a plan using an INDEX SEEK + Key Lookup (ideal for 0 rows).
EXEC dbo.usp_GetEmployeesByDept @DeptId = 3;

-- 2. Subsequent execution: DeptId = 1 (IT - 100,000 rows in production).
--    SQL Server reuses the cached plan! 100,000 Index Seeks + 100,000 Key Lookups cause massive CPU and I/O.
EXEC dbo.usp_GetEmployeesByDept @DeptId = 1;
```

**Interview answer (7 yrs experience):** "Parameter sniffing is designed to save CPU compilation time by reusing cached plans. It becomes a major production incident when data distribution is uneven (skewed data). In our HRMS, 95% of employees belonged to 2 major operational departments, while tiny executive departments had only 5 employees. If the procedure was first compiled after a server restart with the executive department parameter, the optimizer compiled a plan with an Index Seek and Key Lookup. When payroll ran for the 50,000-employee department, it reused that seek plan instead of scanning, turning a 2-second query into a 45-second timeout with millions of page reads. Identifying parameter sniffing is straightforward: if passing local variables or running `WITH RECOMPILE` makes a 40-second procedure run in 100 milliseconds, you have diagnosed parameter sniffing."

---

### Q104. How do you identify and resolve Parameter Sniffing?

**Definition:** Identifying parameter sniffing involves comparing the 'Parameter Compiled Value' against the 'Parameter Runtime Value' in execution plans; resolving it involves techniques like query hints, local variables, or plan forcing.

**Diagnostic Queries:**
```sql
-- Check Query Store for queries with multiple plan IDs and high variance in duration
SELECT 
    q.query_id,
    p.plan_id,
    rs.count_executions,
    rs.avg_duration / 1000.0 AS avg_duration_ms,
    rs.avg_logical_io_reads,
    p.query_plan
FROM sys.query_store_query q
JOIN sys.query_store_plan p ON q.query_id = p.query_id
JOIN sys.query_store_runtime_stats rs ON p.plan_id = rs.plan_id
WHERE q.query_id = 1234 -- Target query
ORDER BY rs.avg_duration DESC;
```

**Resolution Techniques (from least intrusive to most robust):**
```sql
-- Solution 1: OPTION (RECOMPILE) - Best for reports run infrequently with wild variance
SELECT EmployeeId, EmployeeName FROM dbo.Employee WHERE DepartmentId = @DeptId
OPTION (RECOMPILE);

-- Solution 2: OPTION (OPTIMIZE FOR (@DeptId = value)) - Target the most common bulk value
SELECT EmployeeId, EmployeeName FROM dbo.Employee WHERE DepartmentId = @DeptId
OPTION (OPTIMIZE FOR (@DeptId = 1));

-- Solution 3: OPTION (OPTIMIZE FOR UNKNOWN) - Uses average density vector instead of histogram
SELECT EmployeeId, EmployeeName FROM dbo.Employee WHERE DepartmentId = @DeptId
OPTION (OPTIMIZE FOR UNKNOWN);

-- Solution 4: Local Variable Masking (Disables sniffing by forcing average density)
CREATE OR ALTER PROCEDURE dbo.usp_GetEmployeesByDept_Safe
    @DeptId INT
AS
BEGIN
    DECLARE @LocalDeptId INT = @DeptId; -- Optimizer cannot sniff @LocalDeptId at compile time!
    SELECT EmployeeId, EmployeeName FROM dbo.Employee WHERE DepartmentId = @LocalDeptId;
END;
GO

-- Solution 5: Query Store Plan Forcing (Zero code changes on production)
-- Force a known stable plan via SSMS GUI or EXEC sp_query_store_force_plan @query_id, @plan_id;
```

**Interview answer (7 yrs experience):** "In production, my remediation path depends on execution frequency and code access:
1. **Emergency production fix:** If code deployment is restricted, I open **Query Store**, locate the stable plan that performs well across all inputs, and click **Force Plan** (or `sp_query_store_force_plan`). This immediately stabilizes production without a code release.
2. **For low-frequency, high-variance queries (e.g. search filters or reports):** I add `OPTION (RECOMPILE)`. The 5ms compile overhead is well worth saving 30 seconds of execution time.
3. **For high-frequency OLTP (1,000 calls/sec):** `RECOMPILE` burns too much CPU. Here I use `OPTIMIZE FOR UNKNOWN` or local variables to produce a reliable average plan, or split the stored procedure into two specialized procedures branched by an `IF` statement (e.g. one for small departments, one for company-wide bulk scans)."

---

### Q105. What is Query Store?

**Definition:** Query Store is an integrated database-level flight recorder introduced in SQL Server 2016 that automatically captures history of queries, execution plans, runtime performance statistics, and wait statistics, persisting them inside the user database across server restarts.

**Real-world example:** An aircraft flight data recorder ('black box'): it continuously records airspeed, altitude, and engine temperatures on every flight. If a crash or turbulence occurs, engineers replay the flight data to see the exact moment problems started.

| Feature | Dynamic Management Views (DMVs) | Query Store |
|---|---|---|
| Persistence | Cleared on server restart or failover | Persisted inside database files; survives restarts |
| Plan Regression Detection | Manual comparison | Automated GUI reports (Regressed Queries) |
| Plan Forcing | Requires brittle plan guides | One-click plan forcing via GUI or T-SQL |
| Wait Statistics | Server-level global aggregate | Query-level wait statistics linked to specific plans |

**SQL example:**
```sql
-- 1. Enable Query Store on modern database
ALTER DATABASE HRMS SET QUERY_STORE = ON (
    OPERATION_MODE = READ_WRITE,
    CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 30),
    DATA_FLUSH_INTERVAL_SECONDS = 900,
    MAX_STORAGE_SIZE_MB = 2048,
    QUERY_CAPTURE_MODE = AUTO
);

-- 2. Identify top 5 queries consuming highest CPU over the last 24 hours
SELECT TOP 5
    q.query_id,
    t.query_sql_text,
    rs.count_executions,
    rs.avg_cpu_time / 1000.0 AS AvgCpuMs,
    rs.max_cpu_time / 1000.0 AS MaxCpuMs
FROM sys.query_store_query q
JOIN sys.query_store_query_text t ON q.query_text_id = t.query_text_id
JOIN sys.query_store_plan p ON q.query_id = p.query_id
JOIN sys.query_store_runtime_stats rs ON p.plan_id = rs.plan_id
ORDER BY rs.avg_cpu_time DESC;
```

**Interview answer (7 yrs experience):** "Query Store is the single most valuable troubleshooting tool Microsoft has added to SQL Server in the last decade. Before Query Store, if someone restarted the SQL instance or cleared the buffer cache, all execution plans and DMV history were lost. Query Store persists plan history and runtime statistics directly in internal tables within the user database. In our production environment, the **Regressed Queries** dashboard is my first stop on Monday mornings: it instantly highlights queries whose duration increased after a weekend code release or statistics update. Best of all, I can force a good previous plan with one click using `sp_query_store_force_plan`, giving the development team time to properly investigate the root cause without production suffering."

---

### Q106. What is a SQL Server Wait Type?

**Definition:** A Wait Type is an instrumented event recorded by SQL Server whenever an executing thread must pause and wait for a required resource (such as reading a page from disk, acquiring a lock, or waiting for CPU quantum) before continuing execution.

**Real-world example:** Visiting a government office: If your total visit takes 2 hours, 10 minutes was spent talking to the clerk (CPU time), 45 minutes was waiting in line for a document stamp (Lock wait), and 65 minutes was waiting for a file clerk to bring a folder from the basement archive (I/O wait).

**Core Wait Formula:**
$$\text{Total Elapsed Time (Duration)} = \text{CPU Time (Working)} + \text{Wait Time (Waiting)}$$

**Top Production Wait Types and Meanings:**
| Wait Type | What It Means | Common Root Cause |
|---|---|---|
| `CXPACKET` / `CXCONSUMER` | Parallelism synchronization | Normal for parallel queries; check `MAXDOP` and `Cost Threshold for Parallelism` if excessive |
| `PAGEIOLATCH_SH` / `PAGEIOLATCH_EX` | Waiting to read/write 8 KB page from disk into RAM | Memory pressure (missing buffer pool RAM), missing indexes, huge table scans |
| `LCK_M_...` | Waiting for lock release (blocking) | Long transactions, lack of indexing, bad isolation levels |
| `ASYNC_NETWORK_IO` | Waiting for client app to consume data | .NET client fetching 100k rows with `SqlDataReader` and processing row-by-row slowly |
| `WRITELOG` | Waiting for transaction log flush to disk | Slow disk hosting `.ldf` file, excessive small commits inside loops |
| `PAGELATCH_UP` / `PAGELATCH_EX` | In-memory latch contention on 8 KB page | TempDB allocation bottleneck (PFS/GAM/SGAM pages) |

**SQL example:**
```sql
-- Find top cumulative wait types on the server (excluding benign system waits)
SELECT TOP 10
    wait_type,
    wait_time_ms / 1000.0 AS WaitTimeSeconds,
    100.0 * wait_time_ms / SUM(wait_time_ms) OVER() AS PercentOfTotalWait
FROM sys.dm_os_wait_stats
WHERE wait_type NOT IN (
    'CLR_SEMAPHORE','LAZYWRITER_SLEEP','RESOURCE_QUEUE','SLEEP_TASK',
    'SLEEP_SYSTEMTASK','SQLTRACE_BUFFER_FLUSH','WAITFOR','CHECKPOINT_QUEUE',
    'REQUEST_FOR_DEADLOCK_SEARCH','XE_TIMER_EVENT','BROKER_TO_FLUSH','DIRTY_PAGE_POLL'
)
ORDER BY wait_time_ms DESC;
```

**Interview answer (7 yrs experience):** "Wait statistics are the foundation of SQL Server performance tuning methodology. When a database is slow, I never guess—I ask SQL Server what it is waiting for using `sys.dm_os_wait_stats`. If I see high `PAGEIOLATCH_SH`, I know the server is waiting on disk I/O, meaning either missing indexes are causing table scans or the buffer cache is undersized. If I see `ASYNC_NETWORK_IO`, the database is innocent; the .NET application is fetching millions of rows into a `DataReader` and iterating through them one by one while keeping the SQL TDS buffer open. If I see `WRITELOG`, our transaction log storage volume lacks adequate write IOPS. Knowing wait types lets me pinpoint the bottleneck within minutes."

---

### Q107. What is TempDB? Why is it important?

**Definition:** `TempDB` is a globally shared system database that SQL Server recreates on every service restart, used to store temporary user objects, internal engine worktables, and row versioning stores.

**Real-world example:** A shared kitchen prep counter in a busy restaurant: every chef uses it temporarily to chop vegetables, knead dough, and hold dirty bowls. If one chef clutters the entire counter or if chefs fight over the same cutting board, all cooking in the restaurant stops.

**What Uses TempDB?**
1. **User Objects:** `#temp` tables, `@table` variables, global `##temp` tables, Table-Valued Parameters (TVPs).
2. **Internal Objects:** Sort spills, Hash Match join worktables, Spool operators, window function spools.
3. **Version Stores:** RCSI (Read Committed Snapshot Isolation), Snapshot Isolation, Online Index rebuilds, Triggers.

**SQL example:**
```sql
-- Check current TempDB space utilization by category
SELECT 
    SUM(user_object_reserved_page_count) * 8 / 1024.0 AS UserObjectsMB,
    SUM(internal_object_reserved_page_count) * 8 / 1024.0 AS InternalObjectsMB,
    SUM(version_store_reserved_page_count) * 8 / 1024.0 AS VersionStoreMB,
    SUM(unallocated_extent_page_count) * 8 / 1024.0 AS FreeSpaceMB
FROM sys.dm_db_file_space_usage;
```

**Interview answer (7 yrs experience):** "TempDB is the public utility of SQL Server. Because all databases on the instance share TempDB, a bottleneck in TempDB degrades the entire server. In our 7-year production lifecycle, the two biggest TempDB issues we managed were allocation contention and version store bloat. To resolve metadata and allocation contention (PFS/GAM/SGAM page latch waits), we configure TempDB with multiple equally sized data files (matching logical CPU cores up to 8), enable trace flag 1118 (default in SQL 2016+), and place TempDB on ultra-fast local NVMe drives. When enabling RCSI for concurrency, I always monitor version store growth in TempDB to ensure long-running update transactions don't exhaust disk space."

---

### Q108. What is Connection Pooling?

**Definition:** Connection Pooling is an optimization technique managed by client-side data providers (such as `Microsoft.Data.SqlClient` in .NET Core) where database physical connections are kept alive in a pool and reused across HTTP requests rather than being repeatedly opened and closed.

**Real-world example:** A fleet of taxis waiting at an airport rank: when a passenger arrives, they jump into an already running taxi immediately. When the ride ends, the taxi returns to the airport rank for the next passenger, rather than purchasing and registering a brand-new car for every single trip.

| Setting | Default | Recommended Production Practice |
|---|---|---|
| `Pooling` | `true` | Keep `true` (never set to `false`) |
| `Min Pool Size` | `0` | Set to 10-20 for high-traffic APIs to avoid cold start lag |
| `Max Pool Size` | `100` | Size according to database CPU capacity (e.g. 100-200); avoid 1,000+ |
| `Connection Timeout` | `15` seconds | 15-30 seconds |

**C# / .NET Connection String Example:**
```csharp
// Production .NET Core Connection String
string connectionString = 
    "Server=sql-prod-cluster;Database=HRMS;Trusted_Connection=True;TrustServerCertificate=True;" +
    "MultipleActiveResultSets=false;Min Pool Size=10;Max Pool Size=200;Connection Timeout=30;";
```

**Interview answer (7 yrs experience):** "Establishing a physical TCP connection, SSL handshake, authentication, and SQL Server session creation costs 30 to 100 milliseconds and heavy CPU overhead. In .NET Core with Dapper, connection pooling is enabled by default. When you execute `using (var conn = new SqlConnection(...))`, `conn.Close()` or `Dispose()` does NOT sever the physical TCP link; it simply resets the session (`sp_reset_connection`) and returns the connection to the pool. The common production bugs I see are connection leaks—where code throws an exception before `Dispose()` or forgets `using` statements, exhausting the pool and causing 'Timeout expired. The timeout period elapsed prior to obtaining a connection from the pool' errors. I also caution teams about connection string variance: if two connection strings differ by even one character or space, .NET creates two completely isolated connection pools."

---

### Q109. What is a Checkpoint in SQL Server?

**Definition:** A Checkpoint is a background engine process that flushes all modified in-memory 8 KB data pages ('dirty pages') from the buffer pool to physical disk data files (`.mdf`/`.ndf`), writing a checkpoint record in the transaction log to minimize recovery time during unexpected restarts.

**Real-world example:** An auto-save feature in Microsoft Word: while typing, your edits are in RAM; every 5 minutes Word saves changes to disk in the background. If power cuts out, you only lose work done since the last auto-save.

**Checkpoint Types:**
1. **Automatic Checkpoint:** Runs automatically based on the `recovery interval` server configuration (defaults to 1 minute target recovery time).
2. **Indirect Checkpoint (Default in SQL 2016+):** Configured at database level (`TARGET_RECOVERY_TIME = 60 SECONDS`), flushes dirty pages smoothly and continuously to eliminate sudden disk I/O spikes.
3. **Manual Checkpoint:** Executed manually via `CHECKPOINT [duration]`.
4. **Internal Checkpoint:** Triggered by backups, database snapshots, or graceful server shutdown.

**SQL example:**
```sql
-- Check target recovery time (Indirect Checkpoint setting)
SELECT name, target_recovery_time_in_seconds 
FROM sys.databases 
WHERE name = 'InterviewPrep';

-- Set modern indirect checkpoint (60 seconds) to smooth disk writes
ALTER DATABASE InterviewPrep SET TARGET_RECOVERY_TIME = 60 SECONDS;

-- Manually trigger a checkpoint
CHECKPOINT;
```

**Interview answer (7 yrs experience):** "Checkpoint is the mechanism that guarantees recovery boundaries. SQL Server does not flush dirty data pages to disk every time a transaction commits; that would generate unbearable random disk I/O. Instead, changes are hardened immediately to the sequential transaction log (Write-Ahead Logging). The Checkpoint process periodically writes dirty pages to the `.mdf` files. In SQL Server 2014 and older, Automatic Checkpoints caused sudden massive I/O bursts every few minutes that froze disk queues. Since SQL Server 2016, Microsoft defaults to **Indirect Checkpoints** (`TARGET_RECOVERY_TIME = 60 SECONDS`), which spreads page writes steadily and predictably, preventing disk latency spikes."

---

### Q110. What is Transaction Log?

**Definition:** The Transaction Log (`.ldf` file) is a circular append-only binary file that records every modification made to the database before the changes are written to data pages, ensuring full ACID compliance and point-in-time recovery.

**Real-world example:** An accountant's double-entry audit journal: every rupee received or spent is written in pen in the bound journal first. The main bank ledger balances are updated later. If the accountant gets interrupted, the journal provides an undisputed record to reconstruct or undo any transaction.

**Internal Architecture:**
- Divided logically into smaller units called **Virtual Log Files (VLFs)**.
- If a transaction log file grows in small increments (e.g. 1 MB chunks), it generates thousands of tiny VLFs, causing slow database startup, backup delays, and insert lag.

**SQL example:**
```sql
-- Check log file size and percentage used
DBCC SQLPERF(LOGSPACE);

-- Check why transaction log cannot truncate (log_reuse_wait_desc)
SELECT 
    name, 
    recovery_model_desc, 
    log_reuse_wait_desc 
FROM sys.databases 
WHERE name = 'InterviewPrep';

-- Check VLF count (High VLF count > 1000 causes performance issues)
SELECT 
    [name] AS DatabaseName,
    COUNT(li.database_id) AS TotalVLFs
FROM sys.databases db
CROSS APPLY sys.dm_db_log_info(db.database_id) li
GROUP BY [name];
```

**Interview answer (7 yrs experience):** "The transaction log is the heartbeat of SQL Server durability. In high-throughput HRMS databases, transaction log management is critical. A classic production issue is the transaction log filling up disk space unexpectedly. When that happens, I query `sys.databases.log_reuse_wait_desc`. If it says `LOG_BACKUP`, it means the database is in FULL recovery model but someone forgot to schedule regular log backups. If it says `ACTIVE_TRANSACTION`, an uncommitted open transaction or orphaned distributed transaction is holding the log truncation point. Another issue I regularly audit is VLF (Virtual Log File) bloat: if autogrowth is set to small increments, a 50 GB log file can develop 20,000 VLFs, severely degrading server boot and recovery times. We pre-size the log file and grow in 1 GB to 4 GB chunks."

### Q111. What is the difference between Full, Simple and Bulk-Logged Recovery Models?

**Definition:** A recovery model is a database configuration property that controls how transaction log records are maintained, whether the log is automatically truncated, and whether point-in-time recovery is supported.

**Real-world example:**
- **Simple**: A whiteboard where notes are erased as soon as a meeting ends. You cannot recover what was written an hour ago.
- **Full**: A continuous 24/7 video recording of the meeting room. You can rewind and pause at any exact minute and second.
- **Bulk-Logged**: The video recorder pauses during high-speed freight delivery to save tape, only noting that boxes arrived.

| Feature | Simple Recovery Model | Full Recovery Model | Bulk-Logged Recovery Model |
|---|---|---|---|
| Log Truncation | Automatically truncated on Checkpoint | Truncated **only after a Transaction Log Backup** | Truncated **only after a Transaction Log Backup** |
| Point-in-Time Recovery | **No** (data loss up to last full/diff backup) | **Yes** (to the exact second/LSN) | Limited (not supported if bulk operations occurred) |
| Log File Growth | Small, self-managing | Grows continuously until log backup runs | Similar to Full, but bulk ops generate minimal log |
| Bulk Operations | Fully logged (or minimally logged without restore point) | Fully logged | Minimally logged (`bcp`, `BULK INSERT`, `SELECT INTO`) |
| Best For | Dev, QA, Staging, Data Warehouses | Mission-critical Production OLTP | Temporary ETL windows during large bulk loads |

**SQL example:**
```sql
-- Check current recovery model
SELECT name, recovery_model_desc FROM sys.databases WHERE name = 'InterviewPrep';

-- Switch recovery model (Production should always be FULL)
ALTER DATABASE InterviewPrep SET RECOVERY FULL;
```

**Interview answer (7 yrs experience):** "In production OLTP systems like our enterprise HRMS, the database is always in **FULL** recovery model with automated transaction log backups every 15 minutes. This gives us an RPO (Recovery Point Objective) of at most 15 minutes and allows point-in-time recovery to the second in case an accidental `UPDATE` or corrupted release happens. The classic disaster scenario is setting a database to FULL without scheduling log backups—the log file grows indefinitely until the disk runs out of space and the database goes into SUSPECT or READ-ONLY mode. For Dev and QA environments, we set the recovery model to **SIMPLE** so TempDB and log files truncate on checkpoint automatically without administrative overhead."

---

### Q112. What is Log Shipping?

**Definition:** Log Shipping is a basic, automated high-availability and disaster recovery (HA/DR) feature where SQL Server takes transaction log backups on a primary server, copies them across the network, and restores them onto one or more secondary standby servers.

**Real-world example:** Mailing daily carbon copies of business receipts from a head branch in Mumbai to a backup archive office in Delhi every night via express courier.

| Component | Responsibility |
|---|---|
| **Primary Server** | Production database; generates transaction log backups via SQL Agent job |
| **Secondary Server** | Standby database (in `NORECOVERY` or `STANDBY` read-only mode); restores logs |
| **Monitor Server** | Third server that records job history and raises alerts if latency thresholds breach |

**SQL example:**
```sql
-- Restore log on secondary with STANDBY option to allow read-only reporting
RESTORE LOG HRMS_Standby 
FROM DISK = '\\backup-share\HRMS_20261103_1400.trn'
WITH STANDBY = 'D:\undo\HRMS_Standby_Undo.ldf';
```

**Interview answer (7 yrs experience):** "Log Shipping is a database-level disaster recovery technology operating at scheduled intervals (typically every 15 minutes). Its primary advantages are simplicity, support across all SQL Server editions (including Standard edition), and the ability to maintain a read-only reporting standby (`WITH STANDBY`). However, failover is completely manual, and RPO is bounded by the log shipping interval (e.g. up to 15 minutes of data loss if the primary dies before the latest log is copied). In our architecture, we use Log Shipping as an off-site tertiary disaster recovery copy across geographical regions where network bandwidth is too constrained for synchronous Always On replication."

---

### Q113. What is Database Mirroring?

**Definition:** Database Mirroring is an older database-level high availability feature that maintains an exact real-time standby copy of a database on a secondary server via continuous stream of transaction log records.

**Important Note:** Database Mirroring is **deprecated** by Microsoft in favor of Always On Availability Groups.

| Mode | Safety Level | Failover | Data Loss |
|---|---|---|---|
| **High Safety with Witness** | Synchronous | Automatic failover | Zero data loss |
| **High Safety without Witness** | Synchronous | Manual failover | Zero data loss |
| **High Performance** | Asynchronous | Manual failover | Possible minimal data loss |

**Interview answer (7 yrs experience):** "Database Mirroring was the standard 2-node HA solution in SQL Server 2005 through 2008 R2. It streamed log records synchronously or asynchronously between a principal and mirror server, with an optional witness server providing automatic failover. However, Microsoft officially deprecated Database Mirroring starting in SQL Server 2012. Its limitations were severe: it operated strictly on a single database (no multi-database transaction coordination), could only have a single secondary mirror, and the secondary mirror database was completely inaccessible to users (offline in recovery) unless you created a database snapshot. In modern environments, we migrate all legacy mirrored databases to **Always On Availability Groups**."

---

### Q114. What is Always On Availability Group?

**Definition:** Always On Availability Groups (AG) is the premier enterprise High Availability and Disaster Recovery (HA/DR) solution introduced in SQL Server 2012 that provides multi-database failover across a group of primary and secondary replicas, supporting both synchronous and asynchronous replication and readable secondaries.

**Real-world example:** A hospital emergency power grid: Main generators power the building. If the primary transformer fails, secondary generators take over seamlessly within seconds without cutting power to operating rooms (automatic failover via AG Listener). Simultaneously, air conditioning and non-critical laundry use power from a secondary line (readable secondary offloading).

**Core Concepts:**
- **Availability Group Listener:** A virtual DNS name and virtual IP that automatically routes client traffic to the active primary replica or to read-only secondaries (Read-Only Routing).
- **Synchronous-Commit:** Primary waits for secondary to harden log before committing (Zero data loss, HA).
- **Asynchronous-Commit:** Primary commits immediately without waiting (Minimal data loss, DR across distant data centers).
- **Readable Secondaries:** Secondary replicas can be accessed by reporting queries (`ApplicationIntent=ReadOnly`), offloading heavy read workloads from the primary OLTP engine.

**Client Connection String with AG Listener:**
```csharp
// Connecting to AG with automatic read-only routing to secondary replicas
string connStr = "Server=tcp:AG-Listener,1433;Database=HRMS;Integrated Security=True;" +
                 "ApplicationIntent=ReadOnly;MultiSubnetFailover=True;";
```

**Interview answer (7 yrs experience):** "Always On Availability Groups is the gold standard for enterprise SQL Server infrastructure. In our enterprise HRMS, our AG spans 3 nodes: two synchronous replicas in our primary data center with automatic failover, and one asynchronous replica in a remote Azure region for disaster recovery. The architectural game-changer for us was readable secondaries and the AG Listener: by setting `ApplicationIntent=ReadOnly` in our .NET Core reporting microservices connection strings, all heavy Power BI and monthly payroll export queries are automatically routed to the secondary replica. This completely isolated our production transactional API from reporting locks and CPU spikes."

---

### Q115. What is Database Partitioning?

**Definition:** Database Partitioning is the process of splitting very large database objects (tables or indexes) into smaller, manageable, independent physical subsets (partitions) while retaining a single, unified logical view for queries and applications.

**Real-world example:** An office filing room with 10 million invoices: instead of stuffing all 10 million sheets into one giant warehouse pile, you allocate 12 physical filing cabinets—one cabinet for each calendar year. When auditing 2024 invoices, you walk directly to Cabinet 2024 and completely ignore the other 11 cabinets (Partition Elimination).

**Components of Partitioning:**
1. **Partition Function:** Defines the boundary values and data type (e.g. partitioning by year or date range).
2. **Partition Scheme:** Maps each partition defined in the function to a specific physical Filegroup / Storage volume.
3. **Partitioned Table / Index:** Created on top of the partition scheme using the partition key column.

**SQL example:**
```sql
-- 1. Create Partition Function (Range Right: boundaries belong to upper bucket)
CREATE PARTITION FUNCTION pf_AttendanceYear (DATE)
AS RANGE RIGHT FOR VALUES ('2024-01-01', '2025-01-01', '2026-01-01');

-- 2. Create Partition Scheme mapping partitions to filegroups
CREATE PARTITION SCHEME ps_AttendanceYear
AS PARTITION pf_AttendanceYear ALL TO ([PRIMARY]);

-- 3. Create Partitioned Table
CREATE TABLE dbo.EmployeeAttendance_Partitioned
(
    Id             BIGINT IDENTITY(1,1),
    EmployeeId     INT NOT NULL,
    AttendanceDate DATE NOT NULL,
    Status         VARCHAR(10) NOT NULL,
    CONSTRAINT PK_AttendancePart PRIMARY KEY (AttendanceDate, Id)
) ON ps_AttendanceYear(AttendanceDate);
```

**Interview answer (7 yrs experience):** "A common interview misconception is that partitioning automatically makes all queries faster. In reality, table partitioning is primarily a **data management and lifecycle** tool rather than a query performance silver bullet. Its greatest feature is **Partition Switching** (metadata-only instant data archiving): we can move 20 million rows from an active production table to an archive table in 10 milliseconds via `ALTER TABLE ... SWITCH PARTITION` because it only swaps page pointers in system catalog tables. For queries, performance benefits occur through **Partition Elimination**: if a query filters on `AttendanceDate >= '2026-01-01'`, the optimizer reads only Partition 4 and completely ignores the other partitions. However, if queries do not filter on the partition key, the engine must scan all partitions, which can actually be slower than an unpartitioned table."

---

### Q116. What is Table Partitioning vs Index Partitioning?

**Definition:** Table Partitioning divides the underlying table data pages into partitions; Index Partitioning divides index pages into partitions. When an index uses the same partition scheme and partition key as the base table, it is called an **Aligned Index**.

| Feature | Aligned Index | Non-Aligned Index |
|---|---|---|
| Partition Scheme | Identical to base table | Different scheme or unpartitioned |
| Partition Key | Must include table partition key | Can use different columns |
| Partition Switching | **Supported** (instant `SWITCH`) | **Blocked** (prevents partition switching) |
| Maintenance | Independent rebuild per partition | Whole index must be rebuilt |

**SQL example:**
```sql
-- Aligned Non-Clustered Index (shares same partition scheme and partition key)
CREATE NONCLUSTERED INDEX IX_Attendance_EmpId
ON dbo.EmployeeAttendance_Partitioned (EmployeeId, AttendanceDate)
ON ps_AttendanceYear(AttendanceDate); -- Aligned!

-- Rebuild only a single partition (e.g. partition 1) without touching other years:
ALTER INDEX IX_Attendance_EmpId ON dbo.EmployeeAttendance_Partitioned 
REBUILD PARTITION = 1 WITH (ONLINE = ON);
```

**Interview answer (7 yrs experience):** "In production, we strictly enforce **Index Alignment**. An index is aligned when it is created on the same partition scheme as the base table and includes the partition key. The major operational benefit of aligned indexes is that they permit **Partition Switching**. If even a single non-clustered index on the table is non-aligned, SQL Server blocks partition switching with an error. Furthermore, aligned indexes enable partition-level index maintenance: after historical data from 2024 becomes read-only, we never need to defragment or rebuild Partition 1 again; we only rebuild the current year's active partition."

---

### Q117. What is Change Data Capture (CDC)?

**Definition:** Change Data Capture (CDC) is a built-in asynchronous feature in SQL Server that reads the transaction log using an agent capture job and records all `INSERT`, `UPDATE`, and `DELETE` activity on tracked tables into dedicated change tables with full historical audit details.

**Real-world example:** A security surveillance camera at a bank vault: rather than checking inventory every 5 minutes, the camera records every time someone enters, what boxes they took, and what boxes they put back, providing a full chronological change timeline.

**SQL example:**
```sql
-- 1. Enable CDC at Database level
EXEC sys.sp_cdc_enable_db;

-- 2. Enable CDC on Employee table
EXEC sys.sp_cdc_enable_table
    @source_schema = N'dbo',
    @source_name   = N'Employee',
    @role_name     = N'cdc_admin',
    @supports_net_changes = 1;

-- 3. Query CDC change table for historical modifications
-- (CDC creates cdc.dbo_Employee_CT containing _$operation: 1=Delete, 2=Insert, 3=Before Update, 4=After Update)
SELECT * FROM cdc.dbo_Employee_CT;
```

**Interview answer (7 yrs experience):** "CDC is an enterprise ETL and auditing mechanism. Unlike triggers, CDC does not execute inside the user's transactional thread—it is asynchronous. An agent job inspects the transaction log via `sp_replcmds` and writes old and new values to system change tables (`cdc.<schema>_<table_name>_CT`). We use CDC to feed Kafka and downstream data lake pipelines without slowing down our OLTP API. The trade-offs a senior engineer must manage: CDC increases transaction log size because log truncation is delayed until the capture job reads the entries, and change cleanup jobs must be monitored so CDC tables do not consume unlimited disk space."

---

### Q118. What is Change Tracking?

**Definition:** Change Tracking is a lightweight, synchronous tracking mechanism that records only the fact that a row in a table was changed (along with its primary key value), without capturing the historical before/after column data.

**Real-world example:** A package delivery tracker showing only: *'Package #101 was updated at 2:00 PM'*. It does not record what items were placed in or removed from the box, only that a change occurred.

| Feature | Change Data Capture (CDC) | Change Tracking (CT) |
|---|---|---|
| What is Captured | Entire row image (Before & After values) | Primary key only + type of change (I/U/D) |
| Architecture | Asynchronous (reads Transaction Log via SQL Agent) | Synchronous (written inline during user transaction) |
| Storage Cost | High (persists copies of modified data) | Extremely low (small internal tracking table) |
| Edition Support | Standard & Enterprise (SQL 2016 SP1+) | Standard & Enterprise |
| Primary Use Case | Auditing, Data Warehousing, Historical ETL | Two-way data synchronization (Sync Framework, mobile caches) |

**SQL example:**
```sql
-- 1. Enable Change Tracking at Database level
ALTER DATABASE InterviewPrep
SET CHANGE_TRACKING = ON
(CHANGE_RETENTION = 2 DAYS, AUTO_CLEANUP = ON);

-- 2. Enable Change Tracking on Employee table
ALTER TABLE dbo.Employee
ENABLE CHANGE_TRACKING
WITH (TRACK_COLUMNS_UPDATED = ON);

-- 3. Query changed rows since last sync version (e.g. version 0)
SELECT 
    ct.EmployeeId,
    ct.SYS_CHANGE_OPERATION,
    ct.SYS_CHANGE_VERSION,
    e.EmployeeName,
    e.Salary
FROM CHANGETABLE(CHANGES dbo.Employee, 0) AS ct
LEFT JOIN dbo.Employee e ON ct.EmployeeId = e.EmployeeId;
```

**Interview answer (7 yrs experience):** "Change Tracking is our preferred solution when a client application or mobile cache simply needs to know: 'Which employee records were modified since my last sync timestamp?' Because it only logs the Primary Key and the DML operation type (`I`, `U`, `D`), overhead is negligible compared to CDC. However, if business requirements demand a complete audit trail of *what the salary was before the change vs after the change*, Change Tracking cannot help—you must use CDC, Temporal Tables, or an explicit Audit Trigger."

---

### Q119. What is SQL Server Agent?

**Definition:** SQL Server Agent is a background Windows service that automates and schedules administrative and operational tasks in SQL Server by executing multi-step Jobs, Alerts, and Operators.

**Real-world example:** An automated alarm clock and night-shift custodian in an office building: at 2:00 AM every night, it turns on vacuum cleaners (database maintenance jobs), takes out the trash (log cleanup), checks if fire alarms are triggered (alerts), and sends an email to the property manager if an emergency occurs (operators).

**Core Components:**
- **Jobs:** A specified sequence of actions (T-SQL scripts, PowerShell commands, SSIS packages, Operating System batch commands).
- **Schedules:** When the job runs (daily, weekly, on CPU idle, on agent startup).
- **Alerts:** Automated responses to specific SQL Server event errors (e.g. Error 823/824 disk corruption, Error 1205 deadlocks) or performance counter thresholds.
- **Operators:** Contact metadata (email addresses, pager notifications) used with Database Mail to alert on-call DBAs on job failure.

**SQL example:**
```sql
-- Query job status and failure history
SELECT 
    j.name AS JobName,
    h.step_name AS StepName,
    h.run_date,
    h.run_time,
    CASE h.run_status 
        WHEN 0 THEN 'Failed' 
        WHEN 1 THEN 'Succeeded' 
        WHEN 2 THEN 'Retry' 
        WHEN 3 THEN 'Canceled' 
    END AS ExecutionStatus,
    h.message AS ErrorMessage
FROM msdb.dbo.sysjobs j
JOIN msdb.dbo.sysjobhistory h ON j.job_id = h.job_id
WHERE h.run_status = 0 -- Filter failed jobs
ORDER BY h.run_date DESC, h.run_time DESC;
```

**Interview answer (7 yrs experience):** "SQL Server Agent is the automation backbone of SQL Server. In our production environment, SQL Agent manages automated index maintenance, nightly statistics updates, transactional log backup schedules every 15 minutes, CDC capture jobs, and partition switching automation. When configuring jobs, a senior engineer always configures **Database Mail** and failure alert operators: if a critical job fails at 3:00 AM, the on-call team receives an alert before business users log in at 8:00 AM. In cloud-hosted Azure SQL Database, note that SQL Agent is replaced by Azure Elastic Jobs or Azure Logic Apps / Data Factory."

---

### Q120. What is the difference between Full Backup, Differential Backup and Transaction Log Backup?

**Definition:** A Full Backup copies the entire database; a Differential Backup captures only data pages that have changed since the last Full Backup; a Transaction Log Backup captures all log records generated since the previous log backup to support point-in-time recovery.

**Real-world example:**
- **Full Backup (Sunday night)**: Photocopying a 500-page book in full.
- **Differential Backup (Wednesday night)**: Photocopying only the 20 pages that were edited between Sunday and Wednesday.
- **Transaction Log Backup (Every 15 mins)**: Saving the exact minute-by-minute audio dictation of edits made since the last recording.

| Backup Type | What is Backed Up | Size & Speed | Can Restore To Point in Time? | Truncates Log? |
|---|---|---|---|---|
| **Full Backup** | Entire database (all data + partial log to be consistent) | Largest / Slowest | Only to backup completion point | No |
| **Differential Backup** | Pages modified since last Full Backup | Medium / Fast | Only to backup completion point | No |
| **Transaction Log Backup** | All log records since last Log Backup | Smallest / Fastest (seconds) | **Yes (exact second/LSN)** | **Yes (truncates inactive log)** |

**Restore Sequence Formula:**
$$\text{Restore Full} \rightarrow \text{Restore Latest Differential} \rightarrow \text{Restore All Subsequent Log Backups in Order}$$

**SQL example:**
```sql
-- 1. Full Backup (Sunday)
BACKUP DATABASE HRMS TO DISK = 'D:\Backups\HRMS_Full.bak' WITH INIT, COMPRESSION, STATS = 10;

-- 2. Differential Backup (Wednesday)
BACKUP DATABASE HRMS TO DISK = 'D:\Backups\HRMS_Diff.bak' WITH DIFFERENTIAL, INIT, COMPRESSION;

-- 3. Transaction Log Backup (Every 15 minutes)
BACKUP LOG HRMS TO DISK = 'D:\Backups\HRMS_Log_1415.trn' WITH INIT, COMPRESSION;

-- RESTORE SEQUENCE TO RECOVER DATABASE AFTER CRASH AT 2:20 PM:
RESTORE DATABASE HRMS FROM DISK = 'D:\Backups\HRMS_Full.bak' WITH NORECOVERY;
RESTORE DATABASE HRMS FROM DISK = 'D:\Backups\HRMS_Diff.bak' WITH NORECOVERY;
RESTORE LOG HRMS FROM DISK = 'D:\Backups\HRMS_Log_1400.trn' WITH NORECOVERY;
RESTORE LOG HRMS FROM DISK = 'D:\Backups\HRMS_Log_1415.trn' WITH STOPAT = '2026-11-03 14:18:00', RECOVERY;
```

**Interview answer (7 yrs experience):** "Our production backup strategy is designed around an RPO of 15 minutes and an RTO of under 2 hours:
1. **Full Backup:** Every Sunday at 1:00 AM with backup compression enabled.
2. **Differential Backup:** Nightly Monday through Saturday at 1:00 AM.
3. **Transaction Log Backup:** Every 15 minutes 24/7.
This strategy optimizes restore times: if a crash happens on Thursday at 2:20 PM, instead of restoring Sunday's Full backup and 300 sequential log backups, we restore Sunday's Full backup with `NORECOVERY`, Thursday morning's Differential backup with `NORECOVERY`, and only the few log backups taken between 1:00 AM and 2:20 PM. We also test our backup recovery on an isolated staging server every month using `RESTORE VERIFYONLY` and test restores, because an untested backup is not a backup."
