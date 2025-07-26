

--List All Tables and column

SELECT TABLE_NAME, COLUMN_NAME 
FROM INFORMATION_SCHEMA.COLUMNS;

--table informations

SELECT * From Customers;
SELECT * From ['HotelRooms'];
SELECT * From ['ReservationActivities'];
SELECT * From Reservations;
SELECT * From ['TicketActivities'];
SELECT * From Tickets;


--1. relationships among all the tables in a dataset 

SELECT
    fk.name AS ForeignKeyName,
    tp.name AS ParentTable,
    cp.name AS ParentColumn,
    tr.name AS ReferencedTable,
    cr.name AS ReferencedColumn
FROM 
    sys.foreign_keys AS fk
INNER JOIN 
    sys.foreign_key_columns AS fkc ON fk.object_id = fkc.constraint_object_id
INNER JOIN 
    sys.tables AS tp ON fkc.parent_object_id = tp.object_id
INNER JOIN 
    sys.columns AS cp ON fkc.parent_object_id = cp.object_id AND fkc.parent_column_id = cp.column_id
INNER JOIN 
    sys.tables AS tr ON fkc.referenced_object_id = tr.object_id
INNER JOIN 
    sys.columns AS cr ON fkc.referenced_object_id = cr.object_id AND fkc.referenced_column_id = cr.column_id;


-- 2.total number of unique customers

	SELECT COUNT(DISTINCT [Customer Number]) AS UniqueCustomers
FROM Customers;

--3.calculate the occupancy rate

SELECT
    SUM(Nights) AS OccupiedNights,
    COUNT(DISTINCT [Room Number]) * DATEDIFF(DAY, MIN([Check-In Date]), MAX([Check-Out Date])) AS TotalAvailableNights,
    (CAST(SUM(Nights) AS FLOAT) / 
    (COUNT(DISTINCT [Room Number]) * DATEDIFF(DAY, MIN([Check-In Date]), MAX([Check-Out Date])))) * 100 AS OccupancyRate
FROM Reservations;


--4. distribution of customer complaints be analyzed room-wise

SELECT 
    r.[Room Number], 
    COUNT(t.[Ticket ID]) AS ComplaintCount
FROM Tickets t
INNER JOIN Reservations r ON t.[Reservation ID] = r.[Reservation ID]
GROUP BY r.[Room Number]
ORDER BY ComplaintCount DESC;

--5. the key complaints identified in customer feedback

SELECT 
    [Description] as  Complain,
    COUNT([Ticket ID]) AS Frequency
FROM Tickets
GROUP BY [Description]
ORDER BY Frequency DESC;

--6.  customer retention rate

WITH RepeatCustomers AS (
    SELECT [Customer Number]
    FROM Reservations
    GROUP BY [Customer Number]
    HAVING COUNT([Reservation ID]) > 1
)
SELECT 
    (CAST(COUNT(*) AS FLOAT) / (SELECT COUNT(*) FROM Customers)) * 100 AS RetentionRate
FROM RepeatCustomers;

--7. total number of complaints be identified for each room(similar like question 4)

SELECT 
    r.[Room Number], 
    COUNT(t.[Ticket ID]) AS TotalComplaints
FROM Tickets t
INNER JOIN Reservations r ON t.[Reservation ID] = r.[Reservation ID]
GROUP BY r.[Room Number]
ORDER BY TotalComplaints DESC;

--8. region-wise breakdown of offers sent and customer engagement

SELECT 
    c.[Country of Origin] AS Region,
    COUNT(t.[Ticket ID]) AS TotalTickets,
    SUM(CASE WHEN TRY_CAST(t.[Priority] AS INT) = 1 THEN 1 ELSE 0 END) AS HighPriorityTickets
FROM Tickets t
INNER JOIN Reservations r ON t.[Reservation ID] = r.[Reservation ID]
INNER JOIN Customers c ON r.[Customer Number] = c.[Customer Number]
GROUP BY c.[Country of Origin];


--9. revenue for each room

SELECT 
    r.[Room Number], 
    SUM(r.Price) AS TotalRevenue
FROM Reservations r
GROUP BY r.[Room Number]
ORDER BY TotalRevenue DESC;
