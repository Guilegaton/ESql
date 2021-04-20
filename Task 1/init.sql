DROP DATABASE IF EXISTS [Shipment];
GO

CREATE DATABASE Shipment;
GO

USE Shipment;
GO

CREATE TABLE Contact(
    ContactId INT PRIMARY KEY IDENTITY(1,1),
    FirstName NVARCHAR(55) NOT NULL,
    LastName NVARCHAR(55) NOT NULL,
    CellPhone NVARCHAR(12) NOT NULL 
);
GO

CREATE TABLE Wharehouse(
    WharehouseId INT PRIMARY KEY IDENTITY(1,1),
    [City] NVARCHAR(155) NOT NULL,
    [State] NVARCHAR(155) NOT NULL
);
GO

CREATE TABLE [Route](
    RouteId INT PRIMARY KEY IDENTITY(1,1),
    [Name] NVARCHAR(155) NOT NULL,
    Distance NUMERIC CHECK (Distance >= 0) NOT NULL,
    WharehouseStart INT NOT NULL,
    WharehouseEnd INT NOT NULL,
    CONSTRAINT fk_Route_Wharehouse_WharehouseStart FOREIGN KEY (WharehouseStart) REFERENCES Wharehouse(WharehouseId),
    CONSTRAINT fk_Route_Wharehouse_WharehouseEnd FOREIGN KEY (WharehouseEnd) REFERENCES Wharehouse(WharehouseId)
);
GO

CREATE TABLE Cargo(
    CargoId INT PRIMARY KEY IDENTITY(1,1),
    [Weight] NUMERIC CHECK ([Weight] >= 0) NOT NULL,
    Volume NUMERIC CHECK (Volume >= 0) NOT NULL,
    CustomerId INT NOT NULL,
    RecipientId INT NOT NULL,
    Destination INT NOT NULL,
    CONSTRAINT fk_Cargo_Contact_CustomerId FOREIGN KEY (CustomerId) REFERENCES Contact(ContactId),
    CONSTRAINT fk_Cargo_Contact_RecipientId FOREIGN KEY (RecipientId) REFERENCES Contact(ContactId),
    CONSTRAINT fk_Cargo_Route_Destination FOREIGN KEY (Destination) REFERENCES [Route](RouteId)
);
GO

CREATE TABLE Driver(
    DriverId INT PRIMARY KEY IDENTITY(1,1),
    FirstName NVARCHAR(24) NOT NULL,
    LastName NVARCHAR(24) NOT NULL,
    Birthdate DATE NOT NULL
);

CREATE TABLE Truck(
    TruckId INT PRIMARY KEY IDENTITY(1,1),
    BrandName NVARCHAR(24) NOT NULL,
    RegistrationNumber NVARCHAR(12) NOT NULL,
    [Year] INT CHECK ([Year] >= 0) NOT NULL,
    Payload NUMERIC CHECK (Payload >= 0) NOT NULL,
    FuelConsumption NUMERIC CHECK (FuelConsumption >= 0) NOT NULL,
    Volume NUMERIC CHECK (Volume >= 0) NOT NULL,
);
GO

CREATE TABLE TruckDriver(
    TruckId INT NOT NULL,
    DriverId INT NOT NULL,
    CONSTRAINT PK_TruckDriver_TruckId_DriverId PRIMARY KEY (TruckId, DriverId),
    CONSTRAINT fk_TruckDriver_Truck_TruckId FOREIGN KEY (TruckId) REFERENCES Truck(TruckId),
    CONSTRAINT fk_TruckDriver_Driver_DriverId FOREIGN KEY (DriverId) REFERENCES Driver(DriverId)
);
GO

CREATE TABLE Shipment(
    ShipmentId INT PRIMARY KEY IDENTITY(1,1),
    TruckId INT NOT NULL,
    DriverId INT NOT NULL,
    CargoId INT NOT NULL,
    RouteId INT NOT NULL,
    CONSTRAINT fk_Shipment_Truck_TruckId FOREIGN KEY (TruckId) REFERENCES Truck(TruckId),
    CONSTRAINT fk_Shipment_Driver_DriverId FOREIGN KEY (DriverId) REFERENCES Driver(DriverId),
    CONSTRAINT fk_Shipment_Cargo_CargoId FOREIGN KEY (CargoId) REFERENCES Cargo(CargoId),
    CONSTRAINT fk_Shipment_Route_RouteId FOREIGN KEY (RouteId) REFERENCES [Route](RouteId)
);
GO

USE master;
GO