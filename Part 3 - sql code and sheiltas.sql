-- Step 1: Create Independent Tables

CREATE TABLE payments_ID (
    ID VARCHAR(50) PRIMARY KEY NOT NULL,
    First_Name VARCHAR(20) NOT NULL,
    Last_Name VARCHAR(20) NOT NULL
);

CREATE TABLE Payments (
    Credit_Card_Number VARCHAR(16) PRIMARY KEY NOT NULL CHECK (LEN(Credit_Card_Number) = 16),
    Exp_Date DATE NOT NULL,
    CVV VARCHAR(3) NOT NULL CHECK (ISNUMERIC(CVV) = 1 AND LEN(CVV) = 3),
    ID VARCHAR(50) NOT NULL,
	FOREIGN KEY (ID) REFERENCES payments_ID(ID)

);

-- Step 2: Lookup Tables
CREATE TABLE Insurance_Lookup (
    insur_type varchar(50) NOT NULL UNIQUE,
	price_per_day  decimal(10,2) NOT NULL
);

INSERT INTO Insurance_Lookup (insur_type, price_per_day)
VALUES
       ('Search and Rescue', 0.2), 
       ('Trip Cancellation/Shortening', 0.7), 
       ('Baggage', 0.5), 
       ('Mobile Phone', 1), 
       ('Laptop or Tablet', 0.8), 
       ('Sport (Adventurous)', 0.5), 
	   ('sport (Winter)', 10),
	   ('Sport (Competitive)', 25), -- This price is for the whole period
       ('Experience Card or Event', 5),-- This price is for the whole period
       ('Rental Car (Private)', 8), 
	   ('Rental Car (Jeep/Van)', 15),
       ('Camera', 1), 
       ('Medical Expenses in Israel', 0.5);

CREATE TABLE Gender_Lookup (
    Gender_ID INT PRIMARY KEY IDENTITY(1,1),
    Gender_Value VARCHAR(10) NOT NULL UNIQUE
);
INSERT INTO Gender_Lookup (Gender_Value)
VALUES ('Male'), ('Female'), ('Other');


-- Step 3: Dependent Tables
CREATE TABLE Passengers (
    ID VARCHAR(50) PRIMARY KEY NOT NULL,
    First_Name VARCHAR(20) NOT NULL,
    Last_Name VARCHAR(20) NOT NULL,
    Birthdate DATE NOT NULL CHECK (Birthdate <= GETDATE()),
    Gender VARCHAR(10) NOT NULL,
	FOREIGN KEY (Gender) REFERENCES Gender_Lookup(Gender_Value)

);

CREATE TABLE Main_Customer (
    ID VARCHAR(50) PRIMARY KEY NOT NULL,
    Phone VARCHAR(20) NOT NULL CHECK ((Phone LIKE '+%' OR Phone LIKE '[0-9]%') AND LEN(Phone) BETWEEN 5 AND 20),
    Email VARCHAR(50) NOT NULL CHECK (Email LIKE '%@%.%'),
    Adress_City VARCHAR(20) NOT NULL,
    Adress_Street VARCHAR(20) NOT NULL,
    Adress_Number VARCHAR(10) NOT NULL,
    FOREIGN KEY (ID) REFERENCES Passengers(ID)
);

CREATE TABLE Orders (
    Order_ID VARCHAR(50) PRIMARY KEY NOT NULL,
	Order_Date DATE NOT NULL,
    Dep_Date DATE NOT NULL, 
    Arriv_Date DATE NOT NULL,
    Credit_Card_number VARCHAR(16) NOT NULL,
	Payments SmallINT NOT NULL CHECK (Payments >= 0),
    FOREIGN KEY (Credit_Card_number) REFERENCES Payments(Credit_Card_Number)
);


CREATE TABLE Health_Status (
    Order_ID VARCHAR(50) NOT NULL,
    HEALTH_STATUS_ID VARCHAR(50) NOT NULL,
    ID VARCHAR(50) NOT NULL,
    Question_1 BIT NOT NULL CHECK (Question_1 IN (0, 1)),
    Question_2 BIT NOT NULL CHECK (Question_2 IN (0, 1)),
    Question_3 BIT NOT NULL CHECK (Question_3 IN (0, 1)),
    Question_4 BIT NOT NULL CHECK (Question_4 IN (0, 1)),
    PRIMARY KEY (Order_ID, HEALTH_STATUS_ID),
    FOREIGN KEY (Order_ID) REFERENCES Orders(Order_ID),
    FOREIGN KEY (ID) REFERENCES Passengers(ID)
);

CREATE TABLE Insurance (
    insurance_id VARCHAR(50) PRIMARY KEY NOT NULL,
    insur_type VARCHAR(50)  NOT NULL, 
    FOREIGN KEY (insur_type) REFERENCES Insurance_Lookup(insur_type)
);

CREATE TABLE Extra_Insurances (
    insurance_id VARCHAR(50) PRIMARY KEY,
    Starting_Date DATE NOT NULL,
    End_Date DATE NOT NULL,
    Model VARCHAR(50) NULL,
	FOREIGN KEY (insurance_id) REFERENCES Insurance(insurance_id),
);

CREATE TABLE Covers (
    Insurance_ID VARCHAR(50) NULL,
    Order_ID VARCHAR(50) NULL,
	ID VARCHAR(50) NULL,
    HEALTH_STATUS_ID VARCHAR(50) NOT NULL,
    Extra_Price DECIMAL(10,2) NULL CHECK (Extra_Price > 0),
    FOREIGN KEY (Insurance_ID) REFERENCES Insurance(Insurance_ID),
	FOREIGN KEY (ID) REFERENCES Passengers(ID),
    FOREIGN KEY (Order_ID, HEALTH_STATUS_ID) REFERENCES Health_Status(Order_ID, HEALTH_STATUS_ID)
);

CREATE TABLE Price_Per_Country (
    Country_ID VARCHAR(50) PRIMARY KEY NOT NULL,
    Price_Per_Day DECIMAL(10,2) NOT NULL CHECK (Price_Per_Day > 0)
);

CREATE TABLE Days_In_Country (
    Order_ID VARCHAR(50) NOT NULL,
    Country_ID VARCHAR(50) NOT NULL,
    Total_Days SMALLINT NOT NULL,
    PRIMARY KEY (Order_ID, Country_ID),
    FOREIGN KEY (Order_ID) REFERENCES Orders(Order_ID),
    FOREIGN KEY (Country_ID) REFERENCES Price_Per_Country(Country_ID)
);

-- Drop Dependent Tables
DROP TABLE IF EXISTS Days_In_Country;
DROP TABLE IF EXISTS Price_Per_Country;
DROP TABLE IF EXISTS Covers;
DROP TABLE IF EXISTS Extra_Insurances;
DROP TABLE IF EXISTS Insurance;
DROP TABLE IF EXISTS Health_Status;
DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS Main_Customer;
DROP TABLE IF EXISTS Passengers;

-- Drop Lookup Tables
DROP TABLE IF EXISTS Gender_Lookup;
DROP TABLE IF EXISTS Insurance_Lookup;

-- Drop Independent Tables
DROP TABLE IF EXISTS Payments;
DROP TABLE IF EXISTS payments_ID;



-- Task 1 - SELECT - Q1
-- Business Logic:
-- The purpose of this query is to identify countries with a high number of risky trips 
-- (trips by passengers who marked '1' in at least one health-related question). 
-- These countries may pose a higher risk for insurance purposes. 
-- The company might consider strengthening collaborations with local healthcare providers 
-- in these countries to ensure efficient and quick service for its clients.

SELECT TOP 10 
    DIC.country_id AS CountryID,  
    COUNT(DIC.order_id) AS RiskyTrips
FROM 
    Days_In_Country DIC
JOIN 
    ORDERS O
    ON DIC.order_id = O.order_id
JOIN 
    HEALTH_STATUS HS
    ON O.order_id = HS.order_id
WHERE 
    HS.Question_1 = 1 
    OR HS.Question_2 = 1  
    OR HS.Question_3 = 1  
    OR HS.Question_4 = 1  
GROUP BY 
    DIC.country_id
ORDER BY 
    RiskyTrips DESC; 



-- Task 1 - SELECT - Q2
-- Business Logic:
-- The goal of this query is to identify passengers who visited multiple countries (more than one) in a single trip.
-- Additionally, the query calculates the trip duration using the DATEDIFF() system function.
-- These insights can help the company identify high-value customers who take complex, long trips and design tailored premium services for them.

SELECT 
    P.ID AS PassengerID,              
    P.First_Name AS FirstName,    
    P.Last_Name AS LastName,      
    O.order_id AS OrderID,         
    O.dep_date AS DepartureDate,  
    O.arriv_date AS ArrivalDate,    
    DATEDIFF(DAY, O.dep_date, O.arriv_date) AS TripDurationDays,
    COUNT(DISTINCT DIC.country_id) AS CountryCount 
FROM 
    PASSENGERS P
JOIN 
    Health_Status HS
    ON P.ID = HS.ID
JOIN
	Orders o
	on HS.Order_ID = O.Order_ID
JOIN 
    DAYS_IN_COUNTRY DIC
    ON O.order_id = DIC.order_id
WHERE 
    O.dep_date >= '2025-01-01'
GROUP BY 
    P.ID, P.First_Name, P.Last_Name, O.order_id, O.dep_date, O.arriv_date
HAVING 
    COUNT(DISTINCT DIC.country_id) > 1 
ORDER BY 
    CountryCount DESC, TripDurationDays DESC; 




-- Task 1 - SELECT - Q3
-- Business Logic:
-- This query identifies the top 5 passengers with the most critical health status (based on the number of health questions marked as "1") 
-- who have visited the largest number of countries in a single trip. It provides details about their travel and health risks.

SELECT TOP 5
    P.ID AS PassengerID,            
    P.First_Name AS FirstName,       
    P.Last_Name AS LastName,    
    O.order_id AS OrderID,      
    O.dep_date AS DepartureDate, 
    O.arriv_date AS ArrivalDate,   
    H.TotalHealthRisks,              
    COUNT(DISTINCT DIC.country_id) AS CountryCount 
FROM 
    PASSENGERS P
JOIN 
    Health_Status HS
    ON P.ID = HS.ID
JOIN
    Orders O
    ON HS.Order_ID = O.Order_ID
JOIN 
    DAYS_IN_COUNTRY DIC
    ON O.order_id = DIC.order_id
JOIN 
    (
        SELECT 
            HS.Health_status_id AS order_id,
            (
                ISNULL(CAST(HS.Question_1 AS INT), 0) + 
                ISNULL(CAST(HS.Question_2 AS INT), 0) + 
                ISNULL(CAST(HS.Question_3 AS INT), 0) + 
                ISNULL(CAST(HS.Question_4 AS INT), 0)
            ) AS TotalHealthRisks
        FROM 
            HEALTH_STATUS HS
    ) H
    ON H.order_id = O.order_id 
WHERE 
    O.dep_date >= '2024-01-09'
GROUP BY 
    P.ID, P.First_Name, P.Last_Name, O.order_id, O.dep_date, O.arriv_date, H.TotalHealthRisks
HAVING 
    COUNT(DISTINCT DIC.country_id) > 1 
ORDER BY 
    H.TotalHealthRisks DESC, CountryCount DESC; 





-- Task 1 - SELECT - Q4
-- Business Logic:
-- This query identifies the passenger(s) who took the longest trip (in days) in 2025, 
-- using a scalar subquery to calculate the maximum trip duration across all trips in that year.

SELECT 
    P.ID AS PassengerID,  
    P.First_Name AS FirstName,     
    P.Last_Name AS LastName,     
    O.order_id AS OrderID,         
    O.dep_date AS DepartureDate,   
    O.arriv_date AS ArrivalDate,   
    DATEDIFF(DAY, O.dep_date, O.arriv_date) AS TripDurationDays 
FROM 
    PASSENGERS P
JOIN 
    Health_Status HS
    ON P.ID = HS.ID
JOIN
    Orders O
    ON HS.Order_ID = O.Order_ID
WHERE 
    YEAR(O.dep_date) = 2025 
    AND DATEDIFF(DAY, O.dep_date, O.arriv_date) = (
       
        SELECT MAX(DATEDIFF(DAY, O2.dep_date, O2.arriv_date))
        FROM ORDERS O2
        WHERE YEAR(O2.dep_date) = 2025
    )
ORDER BY 
    P.ID; 




-- Task 1 - Window Functions - Q5
-- Business Logic:
-- This query identifies orders with the highest total costs of extra insurance (summed for each order),
-- ranks the orders by their extra insurance costs within each year, and compares the cost of each order to the average for that year.
-- It also divides the orders into quartiles based on their costs, helping to identify high-value customers 
-- and understand spending patterns on extra insurance products.

SELECT 
    O.order_id AS OrderID,                    
    YEAR(O.dep_date) AS OrderYear,            
    P.ID AS PassengerID,                     
    P.First_Name AS FirstName,              
    P.Last_Name AS LastName,               
    SUM(C.Extra_Price) AS TotalExtraInsuranceCost, 
    RANK() OVER (PARTITION BY YEAR(O.dep_date) ORDER BY SUM(C.Extra_Price) DESC) AS RankByYear, 
    AVG(SUM(C.Extra_Price)) OVER (PARTITION BY YEAR(O.dep_date)) AS AvgExtraInsuranceCostPerYear,
    NTILE(4) OVER (PARTITION BY YEAR(O.dep_date) ORDER BY SUM(C.Extra_Price) DESC) AS Quartile,
    CASE 
        WHEN SUM(C.Extra_Price) > AVG(SUM(C.Extra_Price)) OVER (PARTITION BY YEAR(O.dep_date)) THEN 'Above Average'
        WHEN SUM(C.Extra_Price) = AVG(SUM(C.Extra_Price)) OVER (PARTITION BY YEAR(O.dep_date)) THEN 'Average'
        ELSE 'Below Average'
    END AS PerformanceCategory 
FROM 
    PASSENGERS P
JOIN 
    Health_Status HS
    ON P.ID = HS.ID
JOIN
    Orders O
    ON HS.Order_ID = O.Order_ID
JOIN 
    COVERS C
    ON O.order_id = C.order_id 
WHERE 
    C.Extra_Price > 0 
GROUP BY 
    O.order_id, YEAR(O.dep_date), P.ID, P.First_Name, P.Last_Name 
ORDER BY 
    OrderYear, RankByYear;






-- Task 1 - Window Functions - Q6
-- Business Logic:
-- This query identifies customers with the highest divide payments for a single order,
-- ranks orders by total payment amount within each year, and compares the payment amount to the annual average.
-- It helps identify high-value customers and analyze payment patterns.

SELECT 
    O.order_id AS OrderID,                     
    YEAR(O.dep_date) AS OrderYear,              
    P.ID AS PassengerID,                       
    P.First_Name AS FirstName,                 
    P.Last_Name AS LastName,                     
    O.payments AS TotalPayment,                  
    RANK() OVER (PARTITION BY YEAR(O.dep_date) ORDER BY O.payments DESC) AS RankByYear, 
    AVG(O.payments) OVER (PARTITION BY YEAR(O.dep_date)) AS AvgPaymentPerYear, 
    NTILE(4) OVER (PARTITION BY YEAR(O.dep_date) ORDER BY O.payments DESC) AS Quartile, 
    CASE 
        WHEN O.payments > AVG(O.payments) OVER (PARTITION BY YEAR(O.dep_date)) THEN 'Above Average'
        WHEN O.payments = AVG(O.payments) OVER (PARTITION BY YEAR(O.dep_date)) THEN 'Average'
        ELSE 'Below Average'
    END AS PerformanceCategory 
FROM 
    PASSENGERS P
JOIN 
    Health_Status HS
    ON P.ID = HS.ID
JOIN
    Orders O
    ON HS.Order_ID = O.Order_ID
JOIN 
    PAYMENTS PY
    ON O.Credit_Card_number = PY.Credit_Card_number 
WHERE 
    O.Payments > 0 
ORDER BY 
    OrderYear, RankByYear;





-- Task 1 - With - Q7
-- business logic – the goal of this query is to find the top 5 customers with the highest insurance price.
WITH 
TripDays AS (
    SELECT 
        DIC.order_id AS OrderID,
        DIC.country_id AS CountryID,
        DIC.Total_Days AS TotalDaysInCountry,
        PPC.price_per_day * DIC.Total_Days AS CountryInsuranceCost
    FROM 
        DAYS_IN_COUNTRY DIC
    JOIN 
        PRICE_PER_COUNTRY PPC
    ON 
        DIC.country_id = PPC.country_id
),
BaseInsurance AS (
    SELECT 
        O.order_id AS OrderID,
        O.dep_date AS DepartureDate,
        O.arriv_date AS ArrivalDate,
        DATEDIFF(DAY, O.dep_date, O.arriv_date) AS TripDays,
        SUM(IL.price_per_day * DATEDIFF(DAY, O.dep_date, O.arriv_date)) AS TotalBaseInsuranceCost,
        SUM(C.Extra_Price) AS ExtraPriceBaseInsurance
    FROM 
        ORDERS O
    JOIN 
        COVERS C
    ON 
        O.order_id = C.order_id
    JOIN 
        INSURANCE I
    ON 
        C.insurance_id = I.insurance_id
    JOIN 
        INSURANCE_LOOKUP IL
    ON 
        I.insur_type = IL.insur_type
    GROUP BY 
        O.order_id, O.dep_date, O.arriv_date
),
ExtraInsurance AS (
    SELECT 
        C.order_id AS OrderID,
        EI.Starting_Date AS ExtraStartDate,
        EI.end_date AS ExtraEndDate,
        DATEDIFF(DAY, EI.Starting_Date, EI.end_date) AS ExtraTripDays,
        SUM(IL.price_per_day * DATEDIFF(DAY, EI.Starting_Date, EI.end_date)) AS TotalExtraInsuranceBaseCost,
        SUM(C.Extra_Price) AS ExtraPriceExtraInsurance
    FROM 
        ORDERS O
    JOIN 
        COVERS C
    ON 
        O.order_id = C.order_id
    JOIN 
        INSURANCE I
    ON 
        C.Insurance_id = I.Insurance_id
    join
		Extra_Insurances EI
	on
		EI.insurance_id = i.insurance_id
	JOIN 
        INSURANCE_LOOKUP IL
    ON 
        I.Insur_Type = IL.insur_type
    GROUP BY 
        C.order_id, EI.Starting_Date, EI.end_date
),
TotalInsurance AS (
    SELECT 
        BI.OrderID,
        BI.DepartureDate,
        BI.ArrivalDate,
        BI.TripDays,
        COALESCE(SUM(TD.CountryInsuranceCost), 0) AS TotalCountryInsuranceCost,
        COALESCE(BI.TotalBaseInsuranceCost, 0) AS TotalBaseInsuranceCost,
        COALESCE(SUM(EI.TotalExtraInsuranceBaseCost), 0) AS TotalExtraInsuranceCost,
        COALESCE(BI.ExtraPriceBaseInsurance, 0) + COALESCE(SUM(EI.ExtraPriceExtraInsurance), 0) AS TotalExtraPrice,
        COALESCE(SUM(TD.CountryInsuranceCost), 0) + 
        COALESCE(BI.TotalBaseInsuranceCost, 0) + 
        COALESCE(SUM(EI.TotalExtraInsuranceBaseCost), 0) + 
        COALESCE(BI.ExtraPriceBaseInsurance, 0) + 
        COALESCE(SUM(EI.ExtraPriceExtraInsurance), 0) AS TotalInsuranceCost
    FROM 
        BaseInsurance BI
    LEFT JOIN 
        ExtraInsurance EI
    ON 
        BI.OrderID = EI.OrderID
    LEFT JOIN 
        TripDays TD
    ON 
        BI.OrderID = TD.OrderID
    GROUP BY 
        BI.OrderID, BI.DepartureDate, BI.ArrivalDate, BI.TripDays, BI.TotalBaseInsuranceCost, BI.ExtraPriceBaseInsurance
),
CustomerInsuranceSummary AS (
    SELECT 
        P.ID AS PassengerID,
        P.First_Name + ' ' + P.Last_Name AS PassengerName,
        MIN(TI.DepartureDate) AS FirstDepartureDate,
        MAX(TI.ArrivalDate) AS LastArrivalDate,
        SUM(TI.TripDays) AS TotalTripDays,
        SUM(TI.TotalInsuranceCost) AS TotalInsurancePaid
    FROM 
        HEALTH_STATUS HS
    JOIN 
        PASSENGERS P
    ON 
        HS.ID = P.ID
    JOIN 
        ORDERS O
    ON 
        HS.order_id = O.order_id
    JOIN 
        TotalInsurance TI
    ON 
        O.order_id = TI.OrderID
    GROUP BY 
        P.ID, P.First_Name, P.Last_Name
),
TopCustomers AS (
    SELECT 
        CIS.PassengerID,
        CIS.PassengerName,
        CIS.FirstDepartureDate,
        CIS.LastArrivalDate,
        CIS.TotalTripDays,
        CIS.TotalInsurancePaid,
        RANK() OVER (ORDER BY CIS.TotalInsurancePaid DESC) AS RankByInsurance
    FROM 
        CustomerInsuranceSummary CIS
)
SELECT 
    TC.PassengerID,
    TC.PassengerName,
    TC.FirstDepartureDate,
    TC.LastArrivalDate,
    TC.TotalTripDays,
    TC.TotalInsurancePaid,
    TC.RankByInsurance
FROM 
    TopCustomers TC
WHERE 
    TC.RankByInsurance <= 5
ORDER BY 
    TC.RankByInsurance;



-- Task 2 - View - Q1
-- the goal of this view function is to show the highest risk customer along side their trip duration
CREATE VIEW vw_HighRiskOrders AS
SELECT 
    O.order_id AS OrderID,
    P.ID AS PassengerID,
    P.First_Name + ' ' + P.Last_Name AS PassengerName,
    HS.Health_status_id AS HealthStatusID,
    (ISNULL(CAST(HS.Question_1 AS INT), 0) + 
     ISNULL(CAST(HS.Question_2 AS INT), 0) + 
     ISNULL(CAST(HS.Question_3 AS INT), 0) + 
     ISNULL(CAST(HS.Question_4 AS INT), 0)) AS TotalHealthRisks,
    O.dep_date AS DepartureDate,
    O.arriv_date AS ArrivalDate,
    DATEDIFF(DAY, O.dep_date, O.arriv_date) AS TripDuration
FROM 
    PASSENGERS P
JOIN 
    HEALTH_STATUS HS
    ON P.ID = HS.ID
JOIN 
    ORDERS O
    ON HS.order_id = O.order_id
WHERE 
    (ISNULL(CAST(HS.Question_1 AS INT), 0) + 
     ISNULL(CAST(HS.Question_2 AS INT), 0) + 
     ISNULL(CAST(HS.Question_3 AS INT), 0) + 
     ISNULL(CAST(HS.Question_4 AS INT), 0)) > 2;

-- Operate the view function
SELECT * FROM vw_HighRiskOrders ORDER BY TotalHealthRisks DESC;
--delete table
DROP VIEW IF EXISTS vw_HighRiskOrders;

-- Task 2 - Function - Q2.1
-- the goal of this function is to find the risk score for a specific customer
CREATE FUNCTION dbo.fn_GetHighRiskOrders
(
    @PassengerID varchar(50) 
)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        OrderID,
        PassengerName,
        TotalHealthRisks,
        DepartureDate,
        ArrivalDate,
        TripDuration
    FROM 
        vw_HighRiskOrders 
    WHERE 
        PassengerID = @PassengerID
);

-- Operate the fn_GetHighRiskOrders function
SELECT * 
FROM dbo.fn_GetHighRiskOrders('1000000171');

-- ***insert screen shot in the word file!!!

DROP function IF EXISTS fn_GetHighRiskOrders;



-- Task 2 - Function - Q2.2
-- the goal of this function is to find the number of payments that the company expect in a specific month duration
CREATE FUNCTION dbo.fn_ExpectedPaymentsByMonth
(
    @MonthOffset INT 
)
RETURNS INT
AS
BEGIN
    DECLARE @ExpectedPayments INT;
    DECLARE @TargetDate DATE;

    SET @TargetDate = DATEADD(MONTH, @MonthOffset, GETDATE());

    SELECT 
        @ExpectedPayments = COUNT(*)
    FROM 
        PASSENGERS P
    JOIN 
        HEALTH_STATUS HS
    ON 
        P.ID = HS.ID
    JOIN 
        ORDERS O
    ON 
        HS.ORDER_ID = O.ORDER_ID
    JOIN 
        PAYMENTS PMT
    ON 
        O.Credit_Card_Number = PMT.Credit_Card_Number 
    WHERE 
        DATEADD(MONTH, O.Payments - 1, O.Order_Date) >= EOMONTH(@TargetDate, -1) 
        AND O.Order_Date <= @TargetDate 
        AND DATEDIFF(MONTH, O.Order_Date, @TargetDate) + 1 <= O.Payments;

    RETURN @ExpectedPayments;
END;

-- Operate the fn_GetHighRiskOrders
-- Calculate expected payments for two months ahead
SELECT dbo.fn_ExpectedPaymentsByMonth(2) AS PaymentsInTwoMonths;

-- ***insert screen shot in the word file!!!
DROP function IF EXISTS fn_ExpectedPaymentsByMonth;


-- Task 2 - TRIGGER - Q3
-- the goal of the trigger is to check that the dep_date is before the arriv_date and that the order date is before the dep_date

-- Viewing the Orders table before implementing the Trigger
Select * From Orders

CREATE TRIGGER trg_ValidateDates
ON Orders
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM inserted
        WHERE Dep_Date <= Order_Date
           OR Arriv_Date <= Dep_Date
    )
    BEGIN
        ROLLBACK TRANSACTION;
        THROW 50000, 'Validation Error: Dep_Date must be after Order_Date and Arriv_Date must be after Dep_Date.', 1;
    END
END;

-- Example of the Trriger use
INSERT INTO Payments_ID (ID, First_Name, Last_Name) VALUES ('1100000002', 'Yaara', 'Sadeh');
INSERT INTO Payments (Credit_Card_Number, Exp_Date, CVV, ID) VALUES ('9460000000000002',  '01/09/2025', '323', '1100000002');
--Wrong isertions
INSERT INTO Orders (Order_ID, Order_Date, Dep_Date, Arriv_Date, Credit_Card_Number, Payments) VALUES ('88', '2024-09-30', '2024-02-09', '2024-04-08', '9460000000000002', 7);
INSERT INTO Orders (Order_ID, Order_Date, Dep_Date, Arriv_Date, Credit_Card_Number, Payments) VALUES ('88', '2024-01-30', '2024-02-09', '2024-02-08', '9460000000000002', 7);
--Correct insertion
INSERT INTO Orders (Order_ID, Order_Date, Dep_Date, Arriv_Date, Credit_Card_Number, Payments) VALUES ('88', '2024-01-30', '2024-02-09', '2024-05-08', '9460000000000002', 7);



-- Task 2 - Stored Procedure - Q4
-- the goal of this procedure is to automated system to identify high-risk trips and notify passengers, enhancing safety and customer trust.
CREATE TABLE dbo.Notifications
(
    NotificationID INT IDENTITY(1,1) PRIMARY KEY,
    NotificationDate DATETIME NOT NULL,
    PassengerID INT NOT NULL,
    OrderID INT NOT NULL,
    NotificationMessage NVARCHAR(255) NOT NULL
);
CREATE PROCEDURE dbo.sp_GenerateHighRiskTripNotifications
(
    @PassengerID INT 
)
AS
BEGIN
    -- Step 1: Create a temporary table to store high-risk orders for the passenger
    CREATE TABLE #HighRiskOrders
    (
        OrderID INT,
        PassengerName NVARCHAR(100),
        TotalHealthRisks INT,
        DepartureDate DATE,
        ArrivalDate DATE,
        TripDuration INT
    );

    -- Step 2: Insert high-risk orders for the given passenger into the temporary table
    INSERT INTO #HighRiskOrders
    SELECT 
        OrderID,
        PassengerName,
        TotalHealthRisks,
        DepartureDate,
        ArrivalDate,
        TripDuration
    FROM 
        dbo.fn_GetHighRiskOrders(@PassengerID); 

    -- Step 3: Insert high-risk trip notifications into the Notifications table
    INSERT INTO dbo.Notifications
    (
        NotificationDate,
        PassengerID,
        OrderID,
        NotificationMessage
    )
    SELECT 
        GETDATE() AS NotificationDate,
        @PassengerID AS PassengerID, 
        HRO.OrderID AS OrderID,
        CONCAT('High-risk trip detected. Total health risks: ', HRO.TotalHealthRisks, 
               '. Trip duration: ', HRO.TripDuration, ' days.') AS NotificationMessage
    FROM 
        #HighRiskOrders HRO;

    -- Step 4: Return a summary of the notifications inserted
    SELECT 
        N.NotificationDate,
        N.PassengerID,
        N.OrderID,
        N.NotificationMessage
    FROM 
        dbo.Notifications N
    WHERE 
        N.PassengerID = @PassengerID;

    -- Step 5: Cleanup temporary table
    DROP TABLE #HighRiskOrders;
END;
-- Operate the sp_GenerateHighRiskTripNotifications Stored Procedure
EXEC dbo.sp_GenerateHighRiskTripNotifications @PassengerID = '1000000171';
--delete
DROP TABLE IF EXISTS dbo.Notifications;
DROP TABLE IF EXISTS #HighRiskOrders;
DROP PROCEDURE IF EXISTS dbo.sp_GenerateHighRiskTripNotifications;



-- Task 4 - Generative AI - Improved Q1
-- Create indexes to optimize the query

-- Index on Days_In_Country for faster aggregation and filtering
CREATE INDEX IDX_DaysInCountry_OrderID_CountryID ON Days_In_Country (Order_ID, Country_ID);

-- Index on Orders for filtering by Dep_Date
CREATE INDEX IDX_Orders_DepDate ON Orders (Dep_Date);

-- Index on Orders for joining with Days_In_Country
CREATE INDEX IDX_Orders_OrderID ON Orders (Order_ID);

-- Index on Passengers for joining with Health_Status
CREATE INDEX IDX_Passengers_ID ON Passengers (ID);

-- Index on Health_Status for joining with Orders and Passengers
CREATE INDEX IDX_HealthStatus_OrderID_ID ON Health_Status (Order_ID, ID);


-- Optimized Query for identifying high-value passengers with complex trips
SELECT 
    P.ID AS PassengerID,              
    P.First_Name AS FirstName,        
    P.Last_Name AS LastName,          
    O.Order_ID AS OrderID,            
    O.Dep_Date AS DepartureDate,      
    O.Arriv_Date AS ArrivalDate,      
    DATEDIFF(DAY, O.Dep_Date, O.Arriv_Date) AS TripDurationDays, 
    CountryStats.CountryCount -- Pre-computed country count
FROM 
    PASSENGERS P
INNER JOIN 
    Health_Status HS
    ON P.ID = HS.ID
INNER JOIN 
    Orders O
    ON HS.Order_ID = O.Order_ID
-- Subquery to precompute country counts for each order
INNER JOIN (
    SELECT 
        DIC.Order_ID, 
        COUNT(DISTINCT DIC.Country_ID) AS CountryCount
    FROM 
        Days_In_Country DIC
    GROUP BY 
        DIC.Order_ID
    HAVING 
        COUNT(DISTINCT DIC.Country_ID) > 1
) AS CountryStats
ON O.Order_ID = CountryStats.Order_ID
WHERE 
    O.Dep_Date >= '2025-01-01'
ORDER BY 
    CountryStats.CountryCount DESC, 
    TripDurationDays DESC;




-- Task 4 - Generative AI - Improved Q5
-- Create indexes to optimize the query

-- Index on Covers for filtering and joining by Order_ID and Extra_Price
CREATE INDEX IDX_Covers_OrderID_ExtraPrice ON Covers (Order_ID, Extra_Price);

-- Optimized Query for identifying orders with the highest extra insurance costs
WITH ExtraInsuranceCosts AS (
    -- Pre-compute total extra insurance costs per order
    SELECT 
        C.Order_ID, 
        YEAR(O.Dep_Date) AS OrderYear, 
        SUM(C.Extra_Price) AS TotalExtraInsuranceCost
    FROM 
        Covers C
    JOIN 
        Orders O
        ON C.Order_ID = O.Order_ID
    WHERE 
        C.Extra_Price > 0 -- Include only orders with extra insurance costs
    GROUP BY 
        C.Order_ID, YEAR(O.Dep_Date)
),
RankedOrders AS (
    -- Rank orders by total extra insurance cost within each year
    SELECT 
        EIC.Order_ID, 
        EIC.OrderYear, 
        EIC.TotalExtraInsuranceCost,
        RANK() OVER (PARTITION BY EIC.OrderYear ORDER BY EIC.TotalExtraInsuranceCost DESC) AS RankByYear,
        AVG(EIC.TotalExtraInsuranceCost) OVER (PARTITION BY EIC.OrderYear) AS AvgExtraInsuranceCostPerYear,
        NTILE(4) OVER (PARTITION BY EIC.OrderYear ORDER BY EIC.TotalExtraInsuranceCost DESC) AS Quartile
    FROM 
        ExtraInsuranceCosts EIC
)
SELECT 
    R.Order_ID AS OrderID, 
    R.OrderYear, 
    P.ID AS PassengerID, 
    P.First_Name AS FirstName, 
    P.Last_Name AS LastName, 
    R.TotalExtraInsuranceCost,
    R.RankByYear, 
    R.AvgExtraInsuranceCostPerYear,
    R.Quartile,
    CASE 
        WHEN R.TotalExtraInsuranceCost > R.AvgExtraInsuranceCostPerYear THEN 'Above Average'
        WHEN R.TotalExtraInsuranceCost = R.AvgExtraInsuranceCostPerYear THEN 'Average'
        ELSE 'Below Average'
    END AS PerformanceCategory
FROM 
    RankedOrders R
JOIN 
    Health_Status HS
    ON R.Order_ID = HS.Order_ID
JOIN 
    Passengers P
    ON HS.ID = P.ID
ORDER BY 
    R.OrderYear, R.RankByYear;

-- bonus part
-- first q, temporary tables
--The business idea is to enable the manager to assign employees to upcoming shifts in a convenient, organized, and responsible manner.
CREATE PROCEDURE dbo.sp_CalculateTravelersAndWorkersByDate
(
    @InputDate DATE
)
AS
BEGIN
    CREATE TABLE #TravelersCount
    (
        TravelersInAir INT
    );
    INSERT INTO #TravelersCount
    SELECT 
        COUNT(DISTINCT P.ID) AS TravelersInAir
    FROM 
        PASSENGERS P
    JOIN HEALTH_STATUS HS
        ON P.ID = HS.ID
    JOIN ORDERS O
        ON HS.order_id = O.order_id
    WHERE 
        @InputDate BETWEEN O.dep_date AND O.arriv_date; 

    DECLARE @ActiveTravelers INT;
    SELECT 
        @ActiveTravelers = TravelersInAir
    FROM 
        #TravelersCount;

    DECLARE @RequiredWorkers INT;
    SET @RequiredWorkers = CASE
        WHEN @ActiveTravelers <= 50 THEN 2 
        WHEN @ActiveTravelers BETWEEN 51 AND 100 THEN 4
        ELSE 6
    END;

    SELECT 
        @ActiveTravelers AS ActiveTravelers,
        @RequiredWorkers AS RequiredWorkers;
END;
--input
EXEC dbo.sp_CalculateTravelersAndWorkersByDate @InputDate = '2025-03-20';

--delete
DROP TABLE #TravelersCount;
drop PROCEDURE dbo.sp_CalculateTravelersAndWorkersByDate;

-- second q with Error Handling with TRY...CATCH
-- this code is meant to verify that the departure date is before the arrival date
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'ErrorLogs')
BEGIN
    CREATE TABLE ErrorLogs (
        LogID INT IDENTITY(1,1) PRIMARY KEY,
        ErrorMessage NVARCHAR(4000) NOT NULL,
        ErrorSeverity INT NOT NULL,
        ErrorState INT NOT NULL,
        LogDate DATETIME NOT NULL DEFAULT GETDATE()
    );
END;
CREATE PROCEDURE dbo.sp_InsertValidatedOrder
(
    @OrderID VARCHAR(50),
    @PassengerID VARCHAR(50),
    @DepDate DATE,
    @ArrivDate DATE,
    @CreditCardNumber VARCHAR(16),
    @Payments SMALLINT
)
AS
BEGIN
    BEGIN TRY
        -- בדיקות לוגיות נוספות
        IF @DepDate > @ArrivDate
            THROW 50001, 'Departure date cannot be later than arrival date.', 1;
		
        IF LEN(@CreditCardNumber) <> 16 OR ISNUMERIC(@CreditCardNumber) = 0
            THROW 50002, 'Invalid credit card number format.', 1;

        -- הוספת נתונים לטבלאות
        INSERT INTO Orders (Order_ID, Order_Date, Dep_Date, Arriv_Date, Credit_Card_Number, Payments)
        VALUES (@OrderID, GETDATE(), @DepDate, @ArrivDate, @CreditCardNumber, @Payments);

        PRINT 'Order inserted successfully.';
    END TRY
    BEGIN CATCH
        -- טיפול בשגיאה
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        -- שמירת השגיאה בטבלת לוגים
        INSERT INTO ErrorLogs (ErrorMessage, ErrorSeverity, ErrorState, LogDate)
        VALUES (@ErrorMessage, @ErrorSeverity, @ErrorState, GETDATE());

        -- הצגת הודעה
        PRINT 'Error occurred: ' + @ErrorMessage;
    END CATCH;
END;

--working check
EXEC dbo.sp_InsertValidatedOrder 
    @OrderID = '81', 
    @PassengerID = '1000000789',
    @DepDate = '2025-02-21',
    @ArrivDate = '2025-02-23',
    @CreditCardNumber = '5410000000000000',
    @Payments = 2;
-- error check
EXEC dbo.sp_InsertValidatedOrder 
    @OrderID = '2', 
    @PassengerID = '1000000002',
    @DepDate = '2025-01-20',
    @ArrivDate = '2025-01-15',
    @CreditCardNumber = '1234567812345678',
    @Payments = 2;

drop PROCEDURE dbo.sp_InsertValidatedOrder
drop TABLE ErrorLogs