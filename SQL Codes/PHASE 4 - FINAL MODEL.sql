/* ============================================================
   UBER TRIP DASHBOARD
   PHASE 4: FINAL DATA MODEL FOR POWER BI

   Final Tables:
   1. dim_location
   2. fact_ubertrip

   Steps:
   1. Create Dimension Table
   2. Load Dimension Data
   3. Create Fact Table
   4. Load Fact Data
   5. Validate Final Tables
   ============================================================ */

USE UberDB;
GO


/* ============================================================
   STEP 1: CREATE DIMENSION TABLE
   ============================================================ */

IF OBJECT_ID('dbo.dim_location', 'U') IS NOT NULL
    DROP TABLE dbo.dim_location;
GO

CREATE TABLE dbo.dim_location
(   LocationID  INT PRIMARY KEY,
    Location    VARCHAR(100),
    City        VARCHAR(100)
);
GO


/* ============================================================
   STEP 2: LOAD DIMENSION DATA
   ============================================================ */

INSERT INTO dbo.dim_location
(
    LocationID,
    Location,
    City
)
SELECT
    LocationID,
    LTRIM(RTRIM(Location)),
    LTRIM(RTRIM(City))
FROM dbo.Location;
GO


/* ============================================================
   STEP 3: CREATE FACT TABLE
   ============================================================ */

IF OBJECT_ID('dbo.fact_ubertrip', 'U') IS NOT NULL
    DROP TABLE dbo.fact_ubertrip;
GO

CREATE TABLE dbo.fact_ubertrip
(
    TripID          INT,
    PickupTime      DATETIME2,
    DropOffTime     DATETIME2,
    PassengerCount  INT,
    TripDistance    DECIMAL(10,2),
    PULocationID    INT,
    DOLocationID    INT,
    FareAmount      DECIMAL(10,2),
    SurgeFee        DECIMAL(10,2),
    Vehicle         VARCHAR(50),
    PaymentType     VARCHAR(50)
);
GO


/* ============================================================
   STEP 4: LOAD FACT TABLE
   ============================================================ */

INSERT INTO dbo.fact_ubertrip
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
FROM dbo.UberTripDetails;
GO


/* ============================================================
   STEP 5: VALIDATE FINAL TABLES
   ============================================================ */

SELECT COUNT(*) AS LocationRows
FROM dbo.dim_location;

SELECT COUNT(*) AS TripRows
FROM dbo.fact_ubertrip;


SELECT TOP 10 *
FROM dbo.dim_location;

SELECT TOP 10 *
FROM dbo.fact_ubertrip;
GO