
/*
    TECHNOVA - BASES DE DATOS PARA PRÁCTICA DE DOCUMENTACIÓN TÉCNICA
    SIS 0211 - Administración y Gestión de Bases de Datos
    SQL Server 2025 / SSMS

    Incluye:
    - TechNova_Central
    - TechNova_Bodega
    - Schemas
    - Tablas
    - PK / FK
    - CHECK / DEFAULT
    - Índices
    - Datos de ejemplo
    - Vistas
    - Procedimientos almacenados
    - Propiedades extendidas (MS_Description)

    Nota:
    El script elimina y vuelve a crear ambas bases si ya existen.
*/

USE master;
GO

/* =========================================================
   1. ELIMINAR BASES SI EXISTEN
   ========================================================= */

IF DB_ID(N'TechNova_Central') IS NOT NULL
BEGIN
    ALTER DATABASE TechNova_Central SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE TechNova_Central;
END
GO

IF DB_ID(N'TechNova_Bodega') IS NOT NULL
BEGIN
    ALTER DATABASE TechNova_Bodega SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE TechNova_Bodega;
END
GO

/* =========================================================
   2. CREAR BASES
   ========================================================= */

CREATE DATABASE TechNova_Central;
GO

CREATE DATABASE TechNova_Bodega;
GO

/* =========================================================
   3. TECHNOVA BODEGA
   ========================================================= */

USE TechNova_Bodega;
GO

CREATE SCHEMA inventario;
GO

CREATE SCHEMA compras;
GO

/* -------------------------
   Categorías
   ------------------------- */
CREATE TABLE inventario.Categorias
(
    CategoriaID INT IDENTITY(1,1)
        CONSTRAINT PK_Categorias PRIMARY KEY,

    NombreCategoria NVARCHAR(80) NOT NULL,

    Descripcion NVARCHAR(250) NULL,

    Activo BIT NOT NULL
        CONSTRAINT DF_Categorias_Activo DEFAULT (1)
);
GO

/* -------------------------
   Proveedores
   ------------------------- */
CREATE TABLE compras.Proveedores
(
    ProveedorID INT IDENTITY(1,1)
        CONSTRAINT PK_Proveedores PRIMARY KEY,

    RazonSocial NVARCHAR(120) NOT NULL,
    Contacto NVARCHAR(100) NULL,
    Telefono NVARCHAR(30) NULL,
    Correo NVARCHAR(120) NULL,
    Ciudad NVARCHAR(80) NULL,
    Pais NVARCHAR(80) NULL,

    Activo BIT NOT NULL
        CONSTRAINT DF_Proveedores_Activo DEFAULT (1)
);
GO

/* -------------------------
   Productos
   ------------------------- */
CREATE TABLE inventario.Productos
(
    ProductoID INT IDENTITY(1,1)
        CONSTRAINT PK_Productos PRIMARY KEY,

    CategoriaID INT NOT NULL,
    ProveedorID INT NULL,

    NombreProducto NVARCHAR(120) NOT NULL,
    CodigoProducto NVARCHAR(25) NOT NULL,

    PrecioVenta DECIMAL(12,2) NOT NULL,
    CostoUnitario DECIMAL(12,2) NOT NULL,

    Stock INT NOT NULL,
    StockMinimo INT NOT NULL,
    StockMaximo INT NULL,

    Activo BIT NOT NULL
        CONSTRAINT DF_Productos_Activo DEFAULT (1),

    FechaRegistro DATETIME2 NOT NULL
        CONSTRAINT DF_Productos_FechaRegistro DEFAULT (SYSDATETIME()),

    CONSTRAINT UQ_Productos_CodigoProducto
        UNIQUE (CodigoProducto),

    CONSTRAINT FK_Productos_Categorias
        FOREIGN KEY (CategoriaID)
        REFERENCES inventario.Categorias(CategoriaID),

    CONSTRAINT FK_Productos_Proveedores
        FOREIGN KEY (ProveedorID)
        REFERENCES compras.Proveedores(ProveedorID),

    CONSTRAINT CK_Productos_PrecioVenta
        CHECK (PrecioVenta > 0),

    CONSTRAINT CK_Productos_CostoUnitario
        CHECK (CostoUnitario >= 0),

    CONSTRAINT CK_Productos_Stock
        CHECK (Stock >= 0),

    CONSTRAINT CK_Productos_StockMinimo
        CHECK (StockMinimo >= 0),

    CONSTRAINT CK_Productos_StockMaximo
        CHECK (StockMaximo IS NULL OR StockMaximo >= StockMinimo)
);
GO

/* -------------------------
   Movimientos de inventario
   ------------------------- */
CREATE TABLE inventario.MovimientosInventario
(
    MovimientoID BIGINT IDENTITY(1,1)
        CONSTRAINT PK_MovimientosInventario PRIMARY KEY,

    ProductoID INT NOT NULL,

    FechaMovimiento DATETIME2 NOT NULL
        CONSTRAINT DF_Movimientos_Fecha DEFAULT (SYSDATETIME()),

    TipoMovimiento VARCHAR(10) NOT NULL,

    Cantidad INT NOT NULL,

    Referencia NVARCHAR(100) NULL,
    Observacion NVARCHAR(250) NULL,

    CONSTRAINT FK_Movimientos_Productos
        FOREIGN KEY (ProductoID)
        REFERENCES inventario.Productos(ProductoID),

    CONSTRAINT CK_Movimientos_Tipo
        CHECK (TipoMovimiento IN ('ENTRADA','SALIDA')),

    CONSTRAINT CK_Movimientos_Cantidad
        CHECK (Cantidad > 0)
);
GO

/* -------------------------
   Índices Bodega
   ------------------------- */

CREATE INDEX IX_Productos_CategoriaID
ON inventario.Productos(CategoriaID);
GO

CREATE INDEX IX_Productos_ProveedorID
ON inventario.Productos(ProveedorID);
GO

CREATE INDEX IX_Productos_NombreProducto
ON inventario.Productos(NombreProducto);
GO

CREATE INDEX IX_Movimientos_ProductoID
ON inventario.MovimientosInventario(ProductoID);
GO

CREATE INDEX IX_Movimientos_Fecha
ON inventario.MovimientosInventario(FechaMovimiento);
GO

/* =========================================================
   4. DATOS DE TECHNOVA BODEGA
   ========================================================= */

INSERT INTO inventario.Categorias
(NombreCategoria, Descripcion)
VALUES
(N'Computadoras', N'Equipos portátiles y de escritorio'),
(N'Monitores', N'Monitores y dispositivos de visualización'),
(N'Accesorios', N'Periféricos y accesorios de cómputo'),
(N'Redes', N'Equipos de comunicación y conectividad'),
(N'Almacenamiento', N'Dispositivos de almacenamiento de datos');
GO

INSERT INTO compras.Proveedores
(RazonSocial, Contacto, Telefono, Correo, Ciudad, Pais)
VALUES
(N'TechSupply Global', N'Ana Rivera', N'505-2222-1001', N'ventas@techsupply.test', N'Managua', N'Nicaragua'),
(N'Digital Import', N'Carlos López', N'505-2222-1002', N'contacto@digitalimport.test', N'Managua', N'Nicaragua'),
(N'Network Solutions', N'María Gómez', N'505-2222-1003', N'ventas@networksolutions.test', N'León', N'Nicaragua'),
(N'Storage Center', N'Luis Pérez', N'505-2222-1004', N'info@storagecenter.test', N'Granada', N'Nicaragua');
GO

INSERT INTO inventario.Productos
(
    CategoriaID,
    ProveedorID,
    NombreProducto,
    CodigoProducto,
    PrecioVenta,
    CostoUnitario,
    Stock,
    StockMinimo,
    StockMaximo
)
VALUES
(1, 1, N'Laptop Empresarial 15 pulgadas', N'PC-001', 850.00, 700.00, 20, 5, 40),
(1, 1, N'Laptop Profesional 14 pulgadas', N'PC-002', 1200.00, 980.00, 4, 5, 30),
(2, 2, N'Monitor LED 24 pulgadas', N'MON-001', 220.00, 170.00, 15, 5, 35),
(2, 2, N'Monitor LED 27 pulgadas', N'MON-002', 350.00, 280.00, 7, 5, 25),
(3, 2, N'Mouse Inalámbrico', N'ACC-001', 25.00, 14.00, 50, 10, 100),
(3, 2, N'Teclado Mecánico', N'ACC-002', 45.00, 30.00, 8, 10, 60),
(3, 2, N'Hub USB-C', N'ACC-003', 35.00, 22.00, 3, 5, 50),
(4, 3, N'Router Empresarial', N'RED-001', 240.00, 185.00, 4, 5, 20),
(4, 3, N'Switch Gigabit 24 puertos', N'RED-002', 320.00, 250.00, 8, 3, 15),
(5, 4, N'SSD NVMe 1 TB', N'ALM-001', 95.00, 68.00, 25, 8, 50),
(5, 4, N'Disco Externo 2 TB', N'ALM-002', 110.00, 82.00, 12, 5, 30),
(5, 4, N'SSD SATA 512 GB', N'ALM-003', 60.00, 42.00, 30, 10, 60);
GO

INSERT INTO inventario.MovimientosInventario
(ProductoID, FechaMovimiento, TipoMovimiento, Cantidad, Referencia, Observacion)
VALUES
(1, '2026-09-01T08:00:00', 'ENTRADA', 25, N'COMPRA-001', N'Ingreso inicial'),
(1, '2026-09-05T10:20:00', 'SALIDA', 5, N'PEDIDO-1001', N'Venta'),
(2, '2026-09-02T09:00:00', 'ENTRADA', 10, N'COMPRA-002', N'Reposición'),
(2, '2026-09-10T14:30:00', 'SALIDA', 6, N'PEDIDO-1004', N'Venta'),
(5, '2026-09-03T11:15:00', 'ENTRADA', 60, N'COMPRA-003', N'Ingreso accesorios'),
(5, '2026-09-12T16:40:00', 'SALIDA', 10, N'PEDIDO-1002', N'Venta'),
(6, '2026-09-04T08:30:00', 'ENTRADA', 15, N'COMPRA-004', N'Reposición'),
(6, '2026-09-15T13:10:00', 'SALIDA', 7, N'PEDIDO-1005', N'Venta'),
(8, '2026-09-04T15:00:00', 'ENTRADA', 8, N'COMPRA-005', N'Reposición redes'),
(8, '2026-09-20T10:00:00', 'SALIDA', 4, N'PEDIDO-1003', N'Venta'),
(10, '2026-09-06T08:00:00', 'ENTRADA', 30, N'COMPRA-006', N'Almacenamiento'),
(10, '2026-09-22T11:40:00', 'SALIDA', 5, N'PEDIDO-1006', N'Venta');
GO

/* =========================================================
   5. VISTAS Y PROCEDIMIENTOS BODEGA
   ========================================================= */

CREATE VIEW inventario.vw_CatalogoProductos
AS
SELECT
    p.ProductoID,
    p.CodigoProducto,
    p.NombreProducto,
    c.NombreCategoria,
    pr.RazonSocial AS Proveedor,
    p.PrecioVenta,
    p.CostoUnitario,
    p.Stock,
    p.StockMinimo,
    p.StockMaximo,
    p.Activo
FROM inventario.Productos AS p
INNER JOIN inventario.Categorias AS c
    ON p.CategoriaID = c.CategoriaID
LEFT JOIN compras.Proveedores AS pr
    ON p.ProveedorID = pr.ProveedorID;
GO

CREATE VIEW inventario.vw_StockCritico
AS
SELECT
    ProductoID,
    CodigoProducto,
    NombreProducto,
    Stock,
    StockMinimo,
    StockMaximo
FROM inventario.Productos
WHERE Stock <= StockMinimo;
GO

CREATE PROCEDURE inventario.usp_ProductosPorCategoria
    @CategoriaID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        ProductoID,
        CodigoProducto,
        NombreProducto,
        PrecioVenta,
        Stock,
        StockMinimo
    FROM inventario.Productos
    WHERE CategoriaID = @CategoriaID
    ORDER BY NombreProducto;
END
GO

CREATE PROCEDURE inventario.usp_MovimientosPorProducto
    @ProductoID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        MovimientoID,
        FechaMovimiento,
        TipoMovimiento,
        Cantidad,
        Referencia,
        Observacion
    FROM inventario.MovimientosInventario
    WHERE ProductoID = @ProductoID
    ORDER BY FechaMovimiento DESC;
END
GO

/* =========================================================
   6. PROPIEDADES EXTENDIDAS BODEGA
   ========================================================= */

EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Catálogo de productos disponibles en la bodega de TechNova.',
    @level0type=N'SCHEMA', @level0name=N'inventario',
    @level1type=N'TABLE', @level1name=N'Productos';
GO

EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Identificador único del producto.',
    @level0type=N'SCHEMA', @level0name=N'inventario',
    @level1type=N'TABLE', @level1name=N'Productos',
    @level2type=N'COLUMN', @level2name=N'ProductoID';
GO

EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Cantidad disponible actualmente en inventario.',
    @level0type=N'SCHEMA', @level0name=N'inventario',
    @level1type=N'TABLE', @level1name=N'Productos',
    @level2type=N'COLUMN', @level2name=N'Stock';
GO

EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Registra entradas y salidas físicas de productos.',
    @level0type=N'SCHEMA', @level0name=N'inventario',
    @level1type=N'TABLE', @level1name=N'MovimientosInventario';
GO

/* =========================================================
   7. TECHNOVA CENTRAL
   ========================================================= */

USE TechNova_Central;
GO

CREATE SCHEMA comercial;
GO

CREATE SCHEMA ventas;
GO

CREATE SCHEMA integracion;
GO

/* -------------------------
   Clientes
   ------------------------- */
CREATE TABLE comercial.Clientes
(
    ClienteID INT IDENTITY(1,1)
        CONSTRAINT PK_Clientes PRIMARY KEY,

    RazonSocial NVARCHAR(120) NOT NULL,
    Contacto NVARCHAR(100) NULL,
    Ciudad NVARCHAR(80) NULL,
    Telefono NVARCHAR(30) NULL,
    Correo NVARCHAR(120) NULL,

    LimiteCredito DECIMAL(12,2) NOT NULL
        CONSTRAINT DF_Clientes_LimiteCredito DEFAULT (0),

    Activo BIT NOT NULL
        CONSTRAINT DF_Clientes_Activo DEFAULT (1),

    FechaRegistro DATETIME2 NOT NULL
        CONSTRAINT DF_Clientes_FechaRegistro DEFAULT (SYSDATETIME()),

    CONSTRAINT CK_Clientes_LimiteCredito
        CHECK (LimiteCredito >= 0)
);
GO

/* -------------------------
   Pedidos
   ------------------------- */
CREATE TABLE ventas.Pedidos
(
    PedidoID INT IDENTITY(1001,1)
        CONSTRAINT PK_Pedidos PRIMARY KEY,

    ClienteID INT NOT NULL,

    FechaPedido DATE NOT NULL
        CONSTRAINT DF_Pedidos_Fecha DEFAULT (CAST(GETDATE() AS DATE)),

    Estado VARCHAR(20) NOT NULL
        CONSTRAINT DF_Pedidos_Estado DEFAULT ('Pendiente'),

    Total DECIMAL(12,2) NOT NULL
        CONSTRAINT DF_Pedidos_Total DEFAULT (0),

    Observacion NVARCHAR(250) NULL,

    CONSTRAINT FK_Pedidos_Clientes
        FOREIGN KEY (ClienteID)
        REFERENCES comercial.Clientes(ClienteID),

    CONSTRAINT CK_Pedidos_Estado
        CHECK (Estado IN ('Pendiente','Procesando','Facturado','Entregado','Cancelado')),

    CONSTRAINT CK_Pedidos_Total
        CHECK (Total >= 0)
);
GO

/* -------------------------
   Detalle pedido
   ProductoID referencia lógicamente a TechNova_Bodega.
   No se crea FK física entre bases/instancias.
   ------------------------- */
CREATE TABLE ventas.DetallePedido
(
    DetalleID INT IDENTITY(1,1)
        CONSTRAINT PK_DetallePedido PRIMARY KEY,

    PedidoID INT NOT NULL,
    ProductoID INT NOT NULL,

    Cantidad INT NOT NULL,
    PrecioUnitario DECIMAL(12,2) NOT NULL,
    Descuento DECIMAL(5,2) NOT NULL
        CONSTRAINT DF_DetallePedido_Descuento DEFAULT (0),

    CONSTRAINT FK_DetallePedido_Pedidos
        FOREIGN KEY (PedidoID)
        REFERENCES ventas.Pedidos(PedidoID),

    CONSTRAINT CK_DetallePedido_Cantidad
        CHECK (Cantidad > 0),

    CONSTRAINT CK_DetallePedido_Precio
        CHECK (PrecioUnitario >= 0),

    CONSTRAINT CK_DetallePedido_Descuento
        CHECK (Descuento >= 0 AND Descuento <= 100)
);
GO

/* -------------------------
   Índices Central
   ------------------------- */

CREATE INDEX IX_Clientes_RazonSocial
ON comercial.Clientes(RazonSocial);
GO

CREATE INDEX IX_Clientes_Ciudad
ON comercial.Clientes(Ciudad);
GO

CREATE INDEX IX_Pedidos_ClienteID
ON ventas.Pedidos(ClienteID);
GO

CREATE INDEX IX_Pedidos_FechaPedido
ON ventas.Pedidos(FechaPedido);
GO

CREATE INDEX IX_Pedidos_Estado
ON ventas.Pedidos(Estado);
GO

CREATE INDEX IX_DetallePedido_PedidoID
ON ventas.DetallePedido(PedidoID);
GO

CREATE INDEX IX_DetallePedido_ProductoID
ON ventas.DetallePedido(ProductoID);
GO

/* =========================================================
   8. DATOS TECHNOVA CENTRAL
   ========================================================= */

INSERT INTO comercial.Clientes
(RazonSocial, Contacto, Ciudad, Telefono, Correo, LimiteCredito)
VALUES
(N'Comercial Alfa', N'Carlos Pérez', N'Managua', N'505-2222-2001', N'compras@alfa.test', 15000),
(N'Distribuidora Beta', N'María López', N'León', N'505-2222-2002', N'contacto@beta.test', 20000),
(N'Servicios Gamma', N'José Castillo', N'Masaya', N'505-2222-2003', N'compras@gamma.test', 12000),
(N'Corporación Delta', N'Ana Martínez', N'Granada', N'505-2222-2004', N'admin@delta.test', 25000),
(N'Soluciones Integrales', N'Luis Gómez', N'Managua', N'505-2222-2005', N'ventas@soluciones.test', 18000),
(N'Tecnología Moderna', N'Rosa Díaz', N'Estelí', N'505-2222-2006', N'compras@tecnologia.test', 30000);
GO

INSERT INTO ventas.Pedidos
(ClienteID, FechaPedido, Estado, Observacion)
VALUES
(1, '2026-09-20', 'Facturado', N'Entrega Managua'),
(2, '2026-09-21', 'Procesando', N'Entrega León'),
(3, '2026-09-22', 'Entregado', N'Entrega completada'),
(4, '2026-09-23', 'Facturado', N'Pedido corporativo'),
(5, '2026-09-24', 'Pendiente', N'Pendiente confirmación'),
(6, '2026-09-25', 'Procesando', N'Preparando despacho'),
(1, '2026-09-27', 'Entregado', N'Segundo pedido cliente Alfa'),
(2, '2026-09-28', 'Pendiente', N'Pendiente de inventario');
GO

INSERT INTO ventas.DetallePedido
(PedidoID, ProductoID, Cantidad, PrecioUnitario, Descuento)
VALUES
(1001, 1, 2, 850.00, 0),
(1001, 5, 4, 25.00, 0),

(1002, 5, 10, 25.00, 5),
(1002, 6, 4, 45.00, 0),

(1003, 8, 2, 240.00, 0),
(1003, 9, 1, 320.00, 0),

(1004, 2, 1, 1200.00, 0),
(1004, 4, 2, 350.00, 10),

(1005, 6, 3, 45.00, 0),
(1005, 7, 2, 35.00, 0),

(1006, 10, 5, 95.00, 5),
(1006, 11, 2, 110.00, 0),

(1007, 3, 3, 220.00, 0),
(1007, 5, 5, 25.00, 0),

(1008, 2, 2, 1200.00, 5),
(1008, 8, 1, 240.00, 0);
GO

/* Calcular total de pedidos */
UPDATE P
SET Total = X.TotalCalculado
FROM ventas.Pedidos AS P
INNER JOIN
(
    SELECT
        PedidoID,
        SUM(Cantidad * PrecioUnitario * (1 - Descuento / 100.0)) AS TotalCalculado
    FROM ventas.DetallePedido
    GROUP BY PedidoID
) AS X
    ON P.PedidoID = X.PedidoID;
GO

/* =========================================================
   9. VISTAS Y PROCEDIMIENTOS CENTRAL
   ========================================================= */

CREATE VIEW ventas.vw_ResumenPedidos
AS
SELECT
    p.PedidoID,
    p.FechaPedido,
    c.RazonSocial AS Cliente,
    c.Ciudad,
    p.Estado,
    p.Total
FROM ventas.Pedidos AS p
INNER JOIN comercial.Clientes AS c
    ON p.ClienteID = c.ClienteID;
GO

CREATE VIEW ventas.vw_VentasPorCliente
AS
SELECT
    c.ClienteID,
    c.RazonSocial,
    COUNT(p.PedidoID) AS CantidadPedidos,
    ISNULL(SUM(p.Total), 0) AS TotalComprado
FROM comercial.Clientes AS c
LEFT JOIN ventas.Pedidos AS p
    ON c.ClienteID = p.ClienteID
GROUP BY
    c.ClienteID,
    c.RazonSocial;
GO

CREATE PROCEDURE ventas.usp_PedidosPorCliente
    @ClienteID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        PedidoID,
        FechaPedido,
        Estado,
        Total,
        Observacion
    FROM ventas.Pedidos
    WHERE ClienteID = @ClienteID
    ORDER BY FechaPedido DESC;
END
GO

CREATE PROCEDURE ventas.usp_DetallePedido
    @PedidoID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        DetalleID,
        ProductoID,
        Cantidad,
        PrecioUnitario,
        Descuento,
        Cantidad * PrecioUnitario * (1 - Descuento / 100.0) AS Subtotal
    FROM ventas.DetallePedido
    WHERE PedidoID = @PedidoID;
END
GO

/* =========================================================
   10. PROPIEDADES EXTENDIDAS CENTRAL
   ========================================================= */

EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Catálogo de clientes de TechNova.',
    @level0type=N'SCHEMA', @level0name=N'comercial',
    @level1type=N'TABLE', @level1name=N'Clientes';
GO

EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Pedidos comerciales registrados por TechNova.',
    @level0type=N'SCHEMA', @level0name=N'ventas',
    @level1type=N'TABLE', @level1name=N'Pedidos';
GO

EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Detalle de productos asociados a cada pedido. ProductoID referencia lógicamente al catálogo remoto en TechNova_Bodega.',
    @level0type=N'SCHEMA', @level0name=N'ventas',
    @level1type=N'TABLE', @level1name=N'DetallePedido';
GO

EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Identificador del producto ubicado en la base TechNova_Bodega.',
    @level0type=N'SCHEMA', @level0name=N'ventas',
    @level1type=N'TABLE', @level1name=N'DetallePedido',
    @level2type=N'COLUMN', @level2name=N'ProductoID';
GO

/* =========================================================
   11. CONSULTAS DE VERIFICACIÓN
   ========================================================= */

PRINT 'TechNova_Central y TechNova_Bodega creadas correctamente.';
GO

USE TechNova_Central;
GO

SELECT DB_NAME() AS BaseActual;

SELECT
    s.name AS Esquema,
    t.name AS Tabla
FROM sys.tables AS t
INNER JOIN sys.schemas AS s
    ON t.schema_id = s.schema_id
ORDER BY s.name, t.name;

SELECT COUNT(*) AS Clientes FROM comercial.Clientes;
SELECT COUNT(*) AS Pedidos FROM ventas.Pedidos;
SELECT COUNT(*) AS DetallesPedido FROM ventas.DetallePedido;
GO

USE TechNova_Bodega;
GO

SELECT DB_NAME() AS BaseActual;

SELECT
    s.name AS Esquema,
    t.name AS Tabla
FROM sys.tables AS t
INNER JOIN sys.schemas AS s
    ON t.schema_id = s.schema_id
ORDER BY s.name, t.name;

SELECT COUNT(*) AS Categorias FROM inventario.Categorias;
SELECT COUNT(*) AS Proveedores FROM compras.Proveedores;
SELECT COUNT(*) AS Productos FROM inventario.Productos;
SELECT COUNT(*) AS Movimientos FROM inventario.MovimientosInventario;
GO
