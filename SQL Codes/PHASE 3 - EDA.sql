/* ============================================================
   UBER TRIP DASHBOARD
   PHASE 3: EXPLORATORY DATA ANALYSIS (EDA)

   Steps:
   1. Overall Dataset Overview
   2. Trip Volume Analysis
   3. Revenue Analysis
   4. Trip Distance Analysis
   5. Trip Duration Analysis
   6. Passenger Analysis
   7. Vehicle Analysis
   8. Payment Analysis
   9. Location Analysis
   10. Time-Based Analysis
   11. Trip-Level Performance Analysis
   ============================================================ */

USE UberDB;
GO


/* ============================================================
   STEP 1: OVERALL DATASET OVERVIEW
   ============================================================ */

SELECT
    COUNT(*) AS TotalTrips,
    COUNT(DISTINCT PULocationID) AS PickupLocations,
    COUNT(DISTINCT DOLocationID) AS DropoffLocations,
    COUNT(DISTINCT Vehicle) AS VehicleTypes,
    COUNT(DISTINCT PaymentType) AS PaymentTypes,
    MIN(PickupTime) AS FirstTrip,
    MAX(PickupTime) AS LastTrip
FROM dbo.UberTripDetails;
GO


/* ============================================================
   STEP 2: TRIP VOLUME ANALYSIS
   ============================================================ */

-- Trips by Year
SELECT
    YEAR(PickupTime) AS TripYear,
    COUNT(*) AS TotalTrips
FROM dbo.UberTripDetails
GROUP BY YEAR(PickupTime)
ORDER BY TripYear;
GO


-- Trips by Month
SELECT
    YEAR(PickupTime) AS TripYear,
    MONTH(PickupTime) AS TripMonth,
    COUNT(*) AS TotalTrips
FROM dbo.UberTripDetails
GROUP BY
    YEAR(PickupTime),
    MONTH(PickupTime)
ORDER BY
    TripYear,
    TripMonth;
GO


-- Trips by Day of Week
SELECT
    DATENAME(WEEKDAY, PickupTime) AS DayName,
    COUNT(*) AS TotalTrips
FROM dbo.UberTripDetails
GROUP BY DATENAME(WEEKDAY, PickupTime)
ORDER BY TotalTrips DESC;
GO


/* ============================================================
   STEP 3: REVENUE ANALYSIS
   ============================================================ */

SELECT
    COUNT(*) AS TotalTrips,
    SUM(FareAmount) AS TotalFare,
    SUM(SurgeFee) AS TotalSurgeFee,
    SUM(FareAmount + SurgeFee) AS TotalRevenue,
    AVG(FareAmount + SurgeFee) AS AverageTripRevenue,
    MIN(FareAmount + SurgeFee) AS MinimumTripRevenue,
    MAX(FareAmount + SurgeFee) AS MaximumTripRevenue
FROM dbo.UberTripDetails;
GO


-- Revenue by Vehicle
SELECT
    Vehicle,
    COUNT(*) AS TotalTrips,
    SUM(FareAmount + SurgeFee) AS TotalRevenue,
    AVG(FareAmount + SurgeFee) AS AverageRevenue
FROM dbo.UberTripDetails
GROUP BY Vehicle
ORDER BY TotalRevenue DESC;
GO


/* ============================================================
   STEP 4: TRIP DISTANCE ANALYSIS
   ============================================================ */

SELECT
    SUM(TripDistance) AS TotalDistance,
    AVG(TripDistance) AS AverageDistance,
    MIN(TripDistance) AS MinimumDistance,
    MAX(TripDistance) AS MaximumDistance
FROM dbo.UberTripDetails;
GO


-- Distance by Vehicle
SELECT
    Vehicle,
    COUNT(*) AS TotalTrips,
    AVG(TripDistance) AS AverageDistance,
    SUM(TripDistance) AS TotalDistance
FROM dbo.UberTripDetails
GROUP BY Vehicle
ORDER BY AverageDistance DESC;
GO


/* ============================================================
   STEP 5: TRIP DURATION ANALYSIS
   ============================================================ */

SELECT
    AVG(DATEDIFF(MINUTE, PickupTime, DropOffTime))
        AS AverageTripDurationMinutes,

    MIN(DATEDIFF(MINUTE, PickupTime, DropOffTime))
        AS MinimumTripDurationMinutes,

    MAX(DATEDIFF(MINUTE, PickupTime, DropOffTime))
        AS MaximumTripDurationMinutes
FROM dbo.UberTripDetails;
GO


/* ============================================================
   STEP 6: PASSENGER ANALYSIS
   ============================================================ */

SELECT
    PassengerCount,
    COUNT(*) AS TotalTrips,
    AVG(FareAmount + SurgeFee) AS AverageRevenue
FROM dbo.UberTripDetails
GROUP BY PassengerCount
ORDER BY PassengerCount;
GO


/* ============================================================
   STEP 7: VEHICLE ANALYSIS
   ============================================================ */

SELECT
    Vehicle,
    COUNT(*) AS TotalTrips,
    SUM(FareAmount + SurgeFee) AS TotalRevenue,
    AVG(TripDistance) AS AverageDistance,
    AVG(DATEDIFF(MINUTE, PickupTime, DropOffTime))
        AS AverageDurationMinutes
FROM dbo.UberTripDetails
GROUP BY Vehicle
ORDER BY TotalTrips DESC;
GO


/* ============================================================
   STEP 8: PAYMENT ANALYSIS
   ============================================================ */

SELECT
    PaymentType,
    COUNT(*) AS TotalTrips,
    SUM(FareAmount + SurgeFee) AS TotalRevenue,
    AVG(FareAmount + SurgeFee) AS AverageTransactionValue
FROM dbo.UberTripDetails
GROUP BY PaymentType
ORDER BY TotalTrips DESC;
GO


/* ============================================================
   STEP 9: LOCATION ANALYSIS
   ============================================================ */

-- Top Pickup Locations
SELECT TOP 10
    L.LocationID,
    L.Location,
    L.City,
    COUNT(*) AS PickupTrips
FROM dbo.UberTripDetails U
JOIN dbo.Location L
    ON U.PULocationID = L.LocationID
GROUP BY
    L.LocationID,
    L.Location,
    L.City
ORDER BY PickupTrips DESC;
GO


-- Top Drop-off Locations
SELECT TOP 10
    L.LocationID,
    L.Location,
    L.City,
    COUNT(*) AS DropoffTrips
FROM dbo.UberTripDetails U
JOIN dbo.Location L
    ON U.DOLocationID = L.LocationID
GROUP BY
    L.LocationID,
    L.Location,
    L.City
ORDER BY DropoffTrips DESC;
GO


/* ============================================================
   STEP 10: TIME-BASED ANALYSIS
   ============================================================ */

-- Trips by Hour
SELECT
    DATEPART(HOUR, PickupTime) AS PickupHour,
    COUNT(*) AS TotalTrips
FROM dbo.UberTripDetails
GROUP BY DATEPART(HOUR, PickupTime)
ORDER BY PickupHour;
GO


-- Revenue by Hour
SELECT
    DATEPART(HOUR, PickupTime) AS PickupHour,
    COUNT(*) AS TotalTrips,
    SUM(FareAmount + SurgeFee) AS TotalRevenue,
    AVG(FareAmount + SurgeFee) AS AverageRevenue
FROM dbo.UberTripDetails
GROUP BY DATEPART(HOUR, PickupTime)
ORDER BY PickupHour;
GO


/* ============================================================
   STEP 11: TRIP-LEVEL PERFORMANCE ANALYSIS
   ============================================================ */

-- Highest Revenue Trips
SELECT TOP 10
    TripID,
    Vehicle,
    TripDistance,
    PassengerCount,
    FareAmount,
    SurgeFee,
    FareAmount + SurgeFee AS TotalRevenue
FROM dbo.UberTripDetails
ORDER BY TotalRevenue DESC;
GO


-- Longest Trips
SELECT TOP 10
    TripID,
    Vehicle,
    TripDistance,
    DATEDIFF(MINUTE, PickupTime, DropOffTime)
        AS TripDurationMinutes
FROM dbo.UberTripDetails
ORDER BY TripDistance DESC;
GO