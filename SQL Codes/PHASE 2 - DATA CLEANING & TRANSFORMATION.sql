/* ============================================================
   UBER TRIP DASHBOARD
   PHASE 2: DATA CLEANING & TRANSFORMATION

   Steps:
   1. Missing Value Analysis
   2. Text Cleaning & Standardization
   3. Duplicate Detection
   4. Date/Time Validation
   5. Numeric & Business Rule Validation
   6. Load/Validate Clean Data
   ============================================================ */

USE UberDB;
GO


-- ============================================================
-- STEP 1: MISSING VALUE ANALYSIS
-- ============================================================

SELECT
    COUNT(*) AS TotalRows,
    COUNT(TripID) AS TripIDFilled,
    COUNT(PickupTime) AS PickupTimeFilled,
    COUNT(DropOffTime) AS DropOffTimeFilled,
    COUNT(PassengerCount) AS PassengerCountFilled,
    COUNT(TripDistance) AS TripDistanceFilled,
    COUNT(PULocationID) AS PickupLocationFilled,
    COUNT(DOLocationID) AS DropoffLocationFilled,
    COUNT(FareAmount) AS FareFilled,
    COUNT(SurgeFee) AS SurgeFilled,
    COUNT(Vehicle) AS VehicleFilled,
    COUNT(PaymentType) AS PaymentFilled
FROM dbo.UberTripDetails;


-- NULL Analysis
SELECT
    SUM(CASE WHEN TripID IS NULL THEN 1 ELSE 0 END) AS TripIDNulls,
    SUM(CASE WHEN PickupTime IS NULL THEN 1 ELSE 0 END) AS PickupTimeNulls,
    SUM(CASE WHEN DropOffTime IS NULL THEN 1 ELSE 0 END) AS DropOffTimeNulls,
    SUM(CASE WHEN PassengerCount IS NULL THEN 1 ELSE 0 END) AS PassengerNulls,
    SUM(CASE WHEN TripDistance IS NULL THEN 1 ELSE 0 END) AS DistanceNulls,
    SUM(CASE WHEN FareAmount IS NULL THEN 1 ELSE 0 END) AS FareNulls
FROM dbo.UberTripDetails;


-- ============================================================
-- STEP 2: TEXT CLEANING & STANDARDIZATION
-- ============================================================

UPDATE dbo.UberTripDetails
SET
    Vehicle = LTRIM(RTRIM(Vehicle)),
    PaymentType = LTRIM(RTRIM(PaymentType));
GO


-- Standardize text
UPDATE dbo.UberTripDetails
SET
    Vehicle = UPPER(Vehicle),
    PaymentType = UPPER(PaymentType);
GO


-- ============================================================
-- STEP 3: DUPLICATE DETECTION
-- ============================================================

SELECT
    TripID,
    COUNT(*) AS DuplicateCount
FROM dbo.UberTripDetails
GROUP BY TripID
HAVING COUNT(*) > 1;


-- ============================================================
-- STEP 4: DATE & TIME VALIDATION
-- ============================================================

-- Check invalid trip chronology
SELECT
    TripID,
    PickupTime,
    DropOffTime
FROM dbo.UberTripDetails
WHERE DropOffTime <= PickupTime;


-- Check unusually long trips
SELECT
    TripID,
    DATEDIFF(MINUTE, PickupTime, DropOffTime) AS TripDurationMinutes
FROM dbo.UberTripDetails
WHERE DATEDIFF(MINUTE, PickupTime, DropOffTime) > 1440;


-- ============================================================
-- STEP 5: NUMERIC & BUSINESS RULE VALIDATION
-- ============================================================

-- Passenger count should be positive
SELECT *
FROM dbo.UberTripDetails
WHERE PassengerCount <= 0;


-- Trip distance should be positive
SELECT *
FROM dbo.UberTripDetails
WHERE TripDistance <= 0;


-- Fare should not be negative
SELECT *
FROM dbo.UberTripDetails
WHERE FareAmount < 0;


-- Surge fee should not be negative
SELECT *
FROM dbo.UberTripDetails
WHERE SurgeFee < 0;


-- ============================================================
-- STEP 6: LOCATION VALIDATION
-- ============================================================

SELECT DISTINCT
    PULocationID AS LocationID
FROM dbo.UberTripDetails
WHERE PULocationID NOT IN
(
    SELECT LocationID
    FROM dbo.Location
)

UNION

SELECT DISTINCT
    DOLocationID AS LocationID
FROM dbo.UberTripDetails
WHERE DOLocationID NOT IN
(
    SELECT LocationID
    FROM dbo.Location
);


-- ============================================================
-- STEP 7: FINAL TRANSFORMATION CHECK
-- ============================================================

SELECT
    TripID,
    PickupTime,
    DropOffTime,
    DATEDIFF(MINUTE, PickupTime, DropOffTime) AS TripDurationMinutes,
    PassengerCount,
    TripDistance,
    FareAmount,
    SurgeFee,
    FareAmount + SurgeFee AS TotalTripAmount,
    Vehicle,
    PaymentType
FROM dbo.UberTripDetails;
GO