USE Shipment;
GO

BULK INSERT Driver
FROM 'C:\Users\yulii\source\repos\ESql\Sources\Drivers.csv'
WITH
(
    FORMAT = 'CSV', 
    FIELDQUOTE = '"',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);
GO

BULK INSERT Truck
FROM 'C:\Users\yulii\source\repos\ESql\Sources\Trucks.csv'
WITH
(
    FORMAT = 'CSV', 
    FIELDQUOTE = '"',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);
GO

BULK INSERT Wharehouse
FROM 'C:\Users\yulii\source\repos\ESql\Sources\Wharehouse.csv'
WITH
(
    FORMAT = 'CSV', 
    FIELDQUOTE = '"',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);
GO

BULK INSERT TruckDriver
FROM 'C:\Users\yulii\source\repos\ESql\Sources\TruckDriver.csv'
WITH
(
    FORMAT = 'CSV', 
    FIELDQUOTE = '"',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);
GO

INSERT INTO [Route]
    ([Name], Distance, WharehouseStart, WharehouseEnd)
SELECT * FROM(
    SELECT
        CONCAT('Route-', CAST(WharehouseStart as NVARCHAR(155)),'-', CAST(WharehouseEnd as NVARCHAR(155))) AS [Name],
        Distance,
        WharehouseStart,
        WharehouseEnd
    FROM (
        SELECT 
			WH1.WharehouseId AS WharehouseStart,
			WH2.WharehouseId AS WharehouseEnd,
			ABS(CHECKSUM(NEWID()))%2900 + 100 AS Distance
			FROM Wharehouse AS WH1, Wharehouse AS WH2
        WHERE WH2.WharehouseId <> WH1.WharehouseId
    ) AS WHRoutes
) AS [Data];
GO


INSERT INTO Contact
    (FirstName, LastName, CellPhone)
VALUES 
    ('TEST USER', '1', '+388888888'),
    ('TEST USER', '2', '+388888888'),
    ('TEST USER', '3', '+388888888'),
    ('TEST USER', '4', '+388888888'),
    ('TEST USER', '5', '+388888888'),
    ('TEST USER', '6', '+388888888'),
    ('TEST USER', '7', '+388888888'),
    ('TEST USER', '8', '+388888888'),
    ('TEST USER', '9', '+3888888888'),
    ('TEST USER', '10', '+388888888'),
    ('TEST USER', '11', '+388888888'),
    ('TEST USER', '12', '+388888888');
GO

DECLARE @Counter INT
SET @Counter=1
WHILE ( @Counter <= 10000)
BEGIN
    INSERT INTO Cargo
        ([Weight], Volume, CustomerId, RecipientId, Destination)
    VALUES (
		ABS(CHECKSUM(NEWID()))%21000 + 5000,
		ABS(CHECKSUM(NEWID()))%70 + 30,
		(SELECT TOP 1 Contact.ContactId FROM Contact ORDER BY NEWID()),
		(SELECT TOP 1 Contact.ContactId FROM Contact ORDER BY NEWID()),
		(SELECT TOP 1 [Route].RouteId FROM [Route] ORDER BY NEWID()));
	SET @Counter  = @Counter  + 1;
END

DECLARE c CURSOR FOR
SELECT
    CargoId, [Weight], Volume, Destination
FROM Cargo

DECLARE @CargoId INT;
DECLARE @Destination INT;
DECLARE @Weight NUMERIC(18,0);
DECLARE @Volume NUMERIC(18,0);

--get the first agent id and place it into a variable
OPEN c
FETCH NEXT FROM c INTO @CargoId, @Weight, @Volume, @Destination


--for each agent id, select some data where the agent id equals the current agent id in the cursor
WHILE (SELECT COUNT(*) FROM Shipment) < 1000
    BEGIN
		INSERT INTO Shipment(TruckId, DriverId, CargoId, RouteId)
         SELECT TOP 1
		 TR.TruckId,
		 TRD.DriverId,
         @CargoId CargoId,
		 @Destination RouteId
		 FROM Truck TR
		 INNER JOIN TruckDriver TRD ON TRD.TruckId = TR.TruckId
         WHERE TR.Volume >= @Volume AND TR.Payload >= @Weight
		 ORDER BY NEWID()

        --get the next agent
        FETCH NEXT FROM c INTO @CargoId, @Weight, @Volume, @Destination
    END
--clean up
CLOSE c
DEALLOCATE c