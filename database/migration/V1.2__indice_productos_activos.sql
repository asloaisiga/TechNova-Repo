USE TechNova_Bodega;
GO

CREATE INDEX IX_Productos_Activo
ON inventario.Productos(Activo);
GO

SELECT
    name,
    type_desc
FROM sys.indexes
WHERE object_id = OBJECT_ID('inventario.Productos')
AND name = 'IX_Productos_Activo';