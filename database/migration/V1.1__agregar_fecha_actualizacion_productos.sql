USE TechNova_Bodega;
GO

ALTER TABLE inventario.Productos
ADD FechaUltimaActualizacion DATETIME2 NULL;
GO

SELECT
    name AS Columna,
    TYPE_NAME(user_type_id) AS TipoDato
FROM sys.columns
WHERE object_id = OBJECT_ID('inventario.Productos');