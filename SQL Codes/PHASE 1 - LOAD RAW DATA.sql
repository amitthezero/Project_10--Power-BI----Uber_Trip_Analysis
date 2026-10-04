/* ============================================================
   PROJECT 10 - UBER TRIP DASHBOARD
   PHASE 1: LOAD RAW DATA INTO SQL SERVER

   Steps:
   1. Create Database
   2. Create Tables
   3. Bulk Insert Data
   4. Validate Data
   5. Basic Data Quality Checks
   ============================================================ */


-- ============================================================
-- 1. CREATE DATABASE
-- ============================================================

IF DB_ID('UberDB') IS NULL
    CREATE DATABASE UberDB;
GO

USE UberDB;
GO


-- ============================================================
-- 2. CREATE TABLES
-- ============================================================

-- Dimension Table: Location
IF OBJECT_ID('dbo.Location', 'U') IS NOT NULL
    DROP TABLE dbo.Location;
GO

CREATE TABLE dbo.Location
(
    LocationID INT,
    Location   VARCHAR(100),
    City       VARCHAR(100)
);
GO

--Staging Fact Table

IF OBJECT_ID('dbo.UberTrip_Staging', 'U') IS NOT NULL
    DROP TABLE dbo.UberTrip_Staging;
GO

CREATE TABLE dbo.UberTrip_Staging
(
    TripID         VARCHAR(50),
    PickupTime     VARCHAR(50),
    DropOffTime    VARCHAR(50),
    PassengerCount VARCHAR(50),
    TripDistance   VARCHAR(50),
    PULocationID   VARCHAR(50),
    DOLocationID   VARCHAR(50),
    FareAmount     VARCHAR(50),
    SurgeFee       VARCHAR(50),
    Vehicle        VARCHAR(100),
    PaymentType    VARCHAR(100)
);
GO


-- Fact Table: Uber Trip Details
IF OBJECT_ID('dbo.UberTripDetails', 'U') IS NOT NULL
    DROP TABLE dbo.UberTripDetails;
GO

CREATE TABLE dbo.UberTripDetails
(
    TripID         INT,
    PickupTime     DATETIME2,
    DropOffTime    DATETIME2,
    PassengerCount INT,
    TripDistance   DECIMAL(10,2),
    PULocationID   INT,
    DOLocationID   INT,
    FareAmount     DECIMAL(10,2),
    SurgeFee       DECIMAL(10,2),
    Vehicle        VARCHAR(50),
    PaymentType    VARCHAR(50)
);
GO


-- ============================================================
-- 3. BULK INSERT DATA
-- ============================================================

-- Load Location Dimension
BULK INSERT dbo.Location
FROM 'C:\Users\Amit\OneDrive\Desktop\Data Analytics Projects\Power BI\Project_10 - Uber Trip Dashboard\Dataset\Location Table.csv'
WITH
(

    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK,
    KEEPNULLS
);
GO


-- Load Uber Trip Fact_Staging First
BULK INSERT dbo.UberTrip_Staging
FROM 'C:\Users\Amit\OneDrive\Desktop\Data Analytics Projects\Power BI\Project_10 - Uber Trip Dashboard\Dataset\Uber Trip Details.csv'
WITH
(

    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK,
    KEEPNULLS
);
GO

/* ============================================================
  CONVERT & LOAD DATA INTO FACT TABLE
   ============================================================ */

INSERT INTO dbo.UberTripDetails
(
    TripID,
    PickupTime,
    DropOffTime,
    PassengerCount,
    TripDistance,
    PULocationID,
    DOLocationID,
    FareAmount,
    SurgeFee,
    Vehicle,
    PaymentType
)
SELECT
    TRY_CONVERT(INT, TripID),
    TRY_CONVERT(DATETIME2, PickupTime, 105),
    TRY_CONVERT(DATETIME2, DropOffTime, 105),
    TRY_CONVERT(INT, PassengerCount),
    TRY_CONVERT(DECIMAL(10,2), TripDistance),
    TRY_CONVERT(INT, PULocationID),
    TRY_CONVERT(INT, DOLocationID),
    TRY_CONVERT(DECIMAL(10,2), FareAmount),
    TRY_CONVERT(DECIMAL(10,2), SurgeFee),
    Vehicle,
    PaymentType
FROM dbo.UberTrip_Staging;
GO


-- ============================================================
-- 4. VALIDATE DATA
-- ============================================================

SELECT COUNT(*) AS LocationRows
FROM dbo.Location;

SELECT COUNT(*) AS TripRows
FROM dbo.UberTripDetails;


-- Preview loaded data
SELECT TOP 10 *
FROM dbo.Location;

SELECT TOP 10 *
FROM dbo.UberTripDetails;


-- ============================================================
-- 5. BASIC DATA QUALITY CHECKS
-- ============================================================

-- Check NULL values in important Trip columns
SELECT
    COUNT(*) AS TotalRows,
    COUNT(TripID) AS TripIDs,
    COUNT(PickupTime) AS PickupTimes,
    COUNT(DropOffTime) AS DropOffTimes,
    COUNT(PULocationID) AS PickupLocations,
    COUNT(DOLocationID) AS DropoffLocations
FROM dbo.UberTripDetails;


-- Check duplicate Trip IDs
SELECT
    TripID,
    COUNT(*) AS DuplicateCount
FROM dbo.UberTripDetails
GROUP BY TripID
HAVING COUNT(*) > 1;


-- Check whether all Location IDs used in trips exist
-- in the Location dimension
SELECT DISTINCT PULocationID AS LocationID
FROM dbo.UberTripDetails
WHERE PULocationID NOT IN
(
    SELECT LocationID
    FROM dbo.Location
)

UNION

SELECT DISTINCT DOLocationID AS LocationID
FROM dbo.UberTripDetails
WHERE DOLocationID NOT IN
(
    SELECT LocationID
    FROM dbo.Location
);
GO