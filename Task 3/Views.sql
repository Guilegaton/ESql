USE Shipment;
GO
CREATE VIEW vwCTE AS
WITH cte (StartCity, EndCity, TruckBrand, StartDate, EndDate, TotalWeight, TotalVolume, TotalFuelConsamption) as
(
    SELECT 
	    WHStart.City,
	    WHEnd.City,
	    Truck.BrandName,
	    Shipment.StartDate,
	    Shipment.EndDate,
	    CargoSum.TotalWeight,
	    CargoSum.TotalVolume,
	    (RT.Distance * Truck.FuelConsumption)/100 Fuel
    from (SELECT 
			SUM(CR.[Weight]) AS TotalWeight,
			SUM(CR.Volume) AS TotalVolume
			FROM Cargo AS CR) AS CargoSum,
        Shipment
    LEFT JOIN Cargo ON Cargo.CargoId = Shipment.CargoId
    LEFT JOIN Truck ON Shipment.TruckId = Truck.TruckId
    LEFT JOIN [Route] RT ON RT.RouteId = Cargo.Destination
    LEFT JOIN Wharehouse WHStart ON WHStart.WharehouseId = RT.WharehouseStart
    LEFT JOIN Wharehouse WHEnd ON WHEnd.WharehouseId = RT.WharehouseEnd
)
SELECT StartCity, EndCity, TruckBrand, StartDate, EndDate, TotalWeight, TotalVolume, TotalFuelConsamption
FROM cte
GO

/* In this case most optimal is the CTE query, because we have a loosely coupled data. Only Truck and Cargo tables have direct links with Shipment table*/

CREATE VIEW vwCrossApply AS
SELECT Details.StartCity, Details.EndCity, Details.TruckBrand, Shipment.StartDate, Shipment.EndDate, Details.TotalWeight, Details.TotalVolume, Details.TotalFuelConsamption
FROM Shipment
CROSS APPLY (
	SELECT  WHStart.City StartCity,
	    WHEnd.City EndCity,
	    TR.BrandName TruckBrand,
	    CargoSum.TotalWeight,
	    CargoSum.TotalVolume,
	    (RT.Distance * TR.FuelConsumption)/100 TotalFuelConsamption
	FROM 
		Truck TR,
		(SELECT 
			SUM(CR.[Weight]) AS TotalWeight,
			SUM(CR.Volume) AS TotalVolume
			FROM Cargo AS CR) AS CargoSum,
		Cargo CR
    LEFT JOIN [Route] RT ON RT.RouteId = CR.Destination
    LEFT JOIN Wharehouse WHStart ON WHStart.WharehouseId = RT.WharehouseStart
    LEFT JOIN Wharehouse WHEnd ON WHEnd.WharehouseId = RT.WharehouseEnd
	WHERE TR.TruckId = Shipment.TruckId AND CR.CargoId = Shipment.CargoId
) AS Details
GO