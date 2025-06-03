/*
Today's Topic: Improved Stored Procedures
*/

-- Procedure 1: Show summary by JobTitle
CREATE OR ALTER PROCEDURE dbo.Temp_Employee
AS
BEGIN
    SET NOCOUNT ON;

    DROP TABLE IF EXISTS #temp_employee;

    CREATE TABLE #temp_employee (
        JobTitle NVARCHAR(100),
        EmployeesPerJob INT,
        AvgAge INT,
        AvgSalary INT
    );

    INSERT INTO #temp_employee (JobTitle, EmployeesPerJob, AvgAge, AvgSalary)
    SELECT 
        emp.JobTitle, 
        COUNT(*) AS EmployeesPerJob, 
        AVG(emp.Age) AS AvgAge, 
        AVG(sal.Salary) AS AvgSalary
    FROM SQLTutorial..EmployeeDemographics emp
    INNER JOIN SQLTutorial..EmployeeSalary sal
        ON emp.EmployeeID = sal.EmployeeID
    GROUP BY emp.JobTitle;

    SELECT * FROM #temp_employee;
END
GO

-- Procedure 2: Filter by JobTitle
CREATE OR ALTER PROCEDURE dbo.Temp_Employee_ByTitle
    @JobTitle NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    DROP TABLE IF EXISTS #temp_employee;

    CREATE TABLE #temp_employee (
        JobTitle NVARCHAR(100),
        EmployeesPerJob INT,
        AvgAge INT,
        AvgSalary INT
    );

    INSERT INTO #temp_employee (JobTitle, EmployeesPerJob, AvgAge, AvgSalary)
    SELECT 
        emp.JobTitle, 
        COUNT(*) AS EmployeesPerJob, 
        AVG(emp.Age) AS AvgAge, 
        AVG(sal.Salary) AS AvgSalary
    FROM SQLTutorial..EmployeeDemographics emp
    INNER JOIN SQLTutorial..EmployeeSalary sal
        ON emp.EmployeeID = sal.EmployeeID
    WHERE emp.JobTitle = @JobTitle
    GROUP BY emp.JobTitle;

    SELECT * FROM #temp_employee;
END
GO

-- Example calls
EXEC dbo.Temp_Employee;
EXEC dbo.Temp_Employee_ByTitle @JobTitle = 'Salesman';
EXEC dbo.Temp_Employee_ByTitle @JobTitle = 'Accountant';
