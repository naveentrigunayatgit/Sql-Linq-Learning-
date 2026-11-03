/* =====================================================================
   SQL Server Interview Prep - Sample Tables (Section 5)
   Run this once in SSMS before practicing the coding questions.
   ===================================================================== */
IF DB_ID('InterviewPrep') IS NULL CREATE DATABASE InterviewPrep;
GO
USE InterviewPrep;
GO

DROP TABLE IF EXISTS dbo.EmployeeAttendance, dbo.EmployeeSalaryHistory, dbo.Employee, dbo.Department;
GO

CREATE TABLE dbo.Department
(
    DepartmentId   INT          NOT NULL CONSTRAINT PK_Department PRIMARY KEY,
    DepartmentName VARCHAR(50)  NOT NULL CONSTRAINT UQ_Department_Name UNIQUE
);

CREATE TABLE dbo.Employee
(
    EmployeeId   INT           NOT NULL CONSTRAINT PK_Employee PRIMARY KEY,
    EmployeeName VARCHAR(100)  NOT NULL,
    DepartmentId INT           NULL CONSTRAINT FK_Employee_Department REFERENCES dbo.Department(DepartmentId),
    ManagerId    INT           NULL CONSTRAINT FK_Employee_Manager    REFERENCES dbo.Employee(EmployeeId),
    Salary       DECIMAL(12,2) NOT NULL CONSTRAINT CK_Employee_Salary CHECK (Salary >= 0),
    JoiningDate  DATE          NOT NULL
);

CREATE TABLE dbo.EmployeeSalaryHistory
(
    Id            INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_EmployeeSalaryHistory PRIMARY KEY,
    EmployeeId    INT           NOT NULL CONSTRAINT FK_ESH_Employee REFERENCES dbo.Employee(EmployeeId),
    Salary        DECIMAL(12,2) NOT NULL,
    EffectiveDate DATE          NOT NULL
);

CREATE TABLE dbo.EmployeeAttendance
(
    Id             INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_EmployeeAttendance PRIMARY KEY,
    EmployeeId     INT         NOT NULL CONSTRAINT FK_EA_Employee REFERENCES dbo.Employee(EmployeeId),
    AttendanceDate DATE        NOT NULL,
    Status         VARCHAR(10) NOT NULL CONSTRAINT CK_EA_Status CHECK (Status IN ('Present','Absent','Leave','Holiday')),
    CONSTRAINT UQ_EA_Employee_Date UNIQUE (EmployeeId, AttendanceDate)
);
GO

INSERT INTO dbo.Department (DepartmentId, DepartmentName)
VALUES (1,'IT'), (2,'HR'), (3,'Finance');

-- Managers first (self-referencing FK)
INSERT INTO dbo.Employee (EmployeeId, EmployeeName, DepartmentId, ManagerId, Salary, JoiningDate)
VALUES (101,'Amit', 1, NULL, 80000,'2022-01-10'),
       (103,'Priya',2, NULL, 90000,'2021-06-20');

INSERT INTO dbo.Employee (EmployeeId, EmployeeName, DepartmentId, ManagerId, Salary, JoiningDate)
VALUES (102,'Rahul',1, 101, 60000,'2023-03-15'),
       (104,'Sneha',2, 103, 70000,'2024-01-05'),
       (105,'Raj',  1, 101, 60000,'2023-08-10');

INSERT INTO dbo.EmployeeSalaryHistory (EmployeeId, Salary, EffectiveDate)
VALUES (101,50000,'2022-01-10'),
       (101,60000,'2023-01-10'),
       (101,80000,'2024-01-10'),
       (102,40000,'2023-03-15'),
       (102,60000,'2024-03-15');

INSERT INTO dbo.EmployeeAttendance (EmployeeId, AttendanceDate, Status)
VALUES (101,'2026-10-01','Present'),
       (101,'2026-10-02','Absent'),
       (101,'2026-10-03','Present'),
       (102,'2026-10-01','Present'),
       (102,'2026-10-02','Present');
GO

-- Helpful supporting indexes (discussed in the theory/scenario sections)
CREATE NONCLUSTERED INDEX IX_Employee_DepartmentId ON dbo.Employee(DepartmentId) INCLUDE (EmployeeName, Salary);
CREATE NONCLUSTERED INDEX IX_ESH_Employee_Date     ON dbo.EmployeeSalaryHistory(EmployeeId, EffectiveDate DESC) INCLUDE (Salary);
GO

SELECT * FROM dbo.Employee;
SELECT * FROM dbo.Department;
SELECT * FROM dbo.EmployeeSalaryHistory;
SELECT * FROM dbo.EmployeeAttendance;
