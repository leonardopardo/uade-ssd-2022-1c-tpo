/*
# Generate Database
*/

/*
## Database
*/

USE [master]
DROP DATABASE IF EXISTS DW2022
CREATE DATABASE DW2022
GO


/*
## Esquema
*/

-- DW schema
USE [DW2022]

DROP SCHEMA IF EXISTS [DW]
GO

CREATE SCHEMA [DW]
GO

-- STG schema
USE [DW2022]

DROP SCHEMA IF EXISTS [STG]
GO

CREATE SCHEMA [STG]
GO

/*
## Dimensiones
*/

-- drop dimension dim_curso
DROP TABLE IF EXISTS [DW2022].[DW].[dim_curso]
GO

-- create dimension dim_curso
IF NOT EXISTS (SELECT [name] FROM sys.tables WHERE [name] = 'dim_curso')
CREATE TABLE [DW2022].[DW].[dim_curso](
    [id]            INT IDENTITY(1,1) NOT NULL,
    [codigo]        NVARCHAR(50) NOT NULL,
    [titulo]        NVARCHAR(255) NOT NULL,
    [capacidad]     INT NOT NULL,
    [temporada]     VARCHAR(20) NOT NULL,
    [periodo]       INT NOT NULL,
    [fechaInicio]   DATETIME NULL,
    [fechaFin]      DATETIME NULL,
    CONSTRAINT [PK_Curso_Id] PRIMARY KEY NONCLUSTERED (id)
)
GO

-- drop dimension dim_sala
DROP TABLE IF EXISTS [DW2022].[DW].[dim_sala]
GO

-- create dimension dim_sala
IF NOT EXISTS (SELECT * FROM sys.tables WHERE [name] = 'dim_sala')
CREATE TABLE [DW2022].[DW].[dim_sala](
    [id]            INT IDENTITY(1,1) NOT NULL,
    [codigo]        VARCHAR(50) NOT NULL,
    [ubicacion]     VARCHAR(50) NOT NULL,
    [nombre]        VARCHAR(255) NOT NULL,
    [tipo]          VARCHAR(10) NOT NULL,
    [asientos]      INT NOT NULL,
    [fecha_inicio]   DATETIME NULL,
    [fecha_fin]      DATETIME NULL,
    CONSTRAINT [PK_Sala_Id] PRIMARY KEY NONCLUSTERED (id)
)
GO

-- drop dimension dim_profesor
DROP TABLE IF EXISTS [DW2022].[DW].[dim_profesor]
GO

-- create dimension dim_profesor
IF NOT EXISTS (SELECT * FROM sys.tables WHERE [name] = 'dim_profesor')
CREATE TABLE [DW2022].[DW].[dim_profesor](
    [id]                        INT IDENTITY(1,1) NOT NULL,
    [nombre]                    VARCHAR(255) UNIQUE NOT NULL,
    [fecha_contratacion]        DATETIME NOT NULL,
    [fecha_nacimiento]          INT NOT NULL,
    [cantidad_grupo_familiar]   INT NOT NULL,
    [cantidad_hijos]            INT NOT NULL,
    [comision]                  FLOAT NOT NULL,
    [razon]                     FLOAT NOT NULL,
    [zip]                       VARCHAR(50) NOT NULL,  
    [estado]                    VARCHAR(255) NOT NULL,
    [ciudad]                    VARCHAR(255) NOT NULL,
    [calle]                     VARCHAR(255) NOT NULL,
    [fecha_inicio]              DATETIME NULL,
    [fecha_fin]                 DATETIME NULL
    CONSTRAINT [PK_Profesor_Id] PRIMARY KEY NONCLUSTERED (id)
)
GO

-- drop dimension dim_tiempo
DROP TABLE IF EXISTS [DW2022].[DW].[dim_tiempo]
GO

-- create dimension dim_tiempo
IF NOT EXISTS (SELECT * FROM sys.tables WHERE [name] = 'dim_tiempo')
CREATE TABLE [DW2022].[DW].[dim_tiempo](
    [Id]         INT NOT NULL,
    [Fecha]      DATETIME NOT NULL,
    [Anio]       SMALLINT NOT NULL,
    [Semestre]   SMALLINT NOT NULL,
    [Trimestre]  SMALLINT NOT NULL,	  
    [Mes]        SMALLINT NOT NULL,
    [Semana]     SMALLINT NOT NULL,
    [Dia]        SMALLINT NOT NULL,
    [DiaSemana]  SMALLINT NOT NULL,
    [NSemestre]  VARCHAR(15) NOT NULL,
    [NTrimestre] VARCHAR(15) NOT NULL,
    [NMes]       VARCHAR(15) NOT NULL,
    [NMes3L]     VARCHAR(15) NOT NULL,
    [NSemana]    VARCHAR(15) NOT NULL,
    [NDia]       VARCHAR(15) NOT NULL,
    [NDiaSemana] VARCHAR(15) NOT NULL,
    [Temporada]  VARCHAR(15) NOT NULL,
    CONSTRAINT [PK_Tiempo_Id] PRIMARY KEY NONCLUSTERED (Id)
)
GO


-- sp pupulate dimension tiempo
USE [DW2022]
GO

CREATE OR ALTER PROCEDURE sp_pop_dim_tiempo @desde AS CHAR(8), @hasta AS CHAR(8)
AS
BEGIN

    IF(SELECT COUNT(1) FROM [DW2022].[DW].[dim_tiempo]) <> 0 BEGIN
        RETURN
    END

    DECLARE @FechaDesde as datetime, @FechaHasta as datetime
    DECLARE @FechaAAAAMMDD int
    DECLARE @Anio as smallint,@Semestre as smallint, @Trimestre smallint, @Mes smallint
    DECLARE @Semana smallint, @Dia smallint, @DiaSemana smallint
    DECLARE @NSemestre varchar(15), @NTrimestre varchar(15), @NMes varchar(15)
    DECLARE @NMes3l varchar(15)
    DECLARE @NSemana varchar(15), @NDia varchar(15), @NDiaSemana varchar(15)
    DECLARE @Temporada varchar(15)
    
    --Set inicial por si no coincide con los del servidor
    SET DATEFORMAT DMY;

    SELECT @FechaDesde = CAST(@desde AS Datetime)
    SELECT @FechaHasta = CAST(@hasta AS Datetime)

    WHILE (@FechaDesde <= @FechaHasta) BEGIN
        SELECT @FechaAAAAMMDD = YEAR(@FechaDesde)*10000 + MONTH(@FechaDesde)*100 + DATEPART(dd, @FechaDesde)
        SELECT @Anio = DATEPART(yy, @FechaDesde)
        SELECT @Semestre=((DATEPART(quarter,@FechaDesde)-1)/2)+1
        SELECT @Trimestre = DATEPART(qq, @FechaDesde)
        SELECT @Mes = DATEPART(m, @FechaDesde)
        SELECT @Semana = DATEPART(wk, @FechaDesde)
        SELECT @Dia = RIGHT('0' + DATEPART(dd, @FechaDesde),2)
        SELECT @DiaSemana = DATEPART(DW, @FechaDesde)
        SELECT @NMes = DATENAME(mm, @FechaDesde)
        SELECT @NMes3l = LEFT(@NMes, 3)
        SELECT @NSemestre=concat('Semestre ',@SEMESTRE)
        SELECT @NTrimestre = 'T' + CAST(@Trimestre as CHAR(1)) + '/' + RIGHT(@Anio, 2)
        SELECT @NSemana = 'Sem ' + CAST(@Semana AS CHAR(2)) + '/' + RIGHT(RTRIM(CAST(@Anio as CHAR(4))),2)
        SELECT @NDia = CAST(@Dia as CHAR(2)) + ' ' + RTRIM(@NMes)
        SELECT @NDiaSemana = DATENAME(dw, @FechaDesde)



        SELECT @Temporada = case 
                                when month(@FechaDesde) in (12, 1, 2) then 'WINTER'
                                when month(@FechaDesde) in (3, 4, 5) then 'SPRING'
                                when month(@FechaDesde) in (6, 7, 8) then 'SUMMER'
                                when month(@FechaDesde) in (9, 10, 11) then 'FALL'
                            end
        
        INSERT INTO [DW2022].[DW].[dim_tiempo]
        (
            [Id],
            [Fecha],
            [Anio],
            [Semestre],
            [Trimestre],
            [Mes],
            [Semana],
            [Dia],
            [DiaSemana],
            [NSemestre],
            [NTrimestre],
            [NMes],
            [NMes3L],
            [NSemana],
            [NDia],
            [NDiaSemana],
            [Temporada]
        ) 
        VALUES
        (
            @FechaAAAAMMDD,
            @FechaDesde,
            @Anio,
            @Semestre,
            @Trimestre,
            @Mes,
            @Semana,
            @Dia,
            @DiaSemana,
            @NSemestre,
            @NTrimestre,
            @NMes,
            @NMes3l,
            @NSemana,
            @NDia,
            @NDiaSemana,
            @Temporada
        )
    
        --Incremento del bucle
        SELECT @FechaDesde = DATEADD(DAY, 1, @FechaDesde)
    END    
END

-- drop dimension dim_time
DROP TABLE IF EXISTS [DW2022].[DW].[dim_time]
GO

-- create dimension dim_tiempo
IF NOT EXISTS (SELECT * FROM sys.tables WHERE [name] = 'dim_time')
CREATE TABLE [DW2022].[DW].[dim_time](
    [Id]         INT IDENTITY(1,1) NOT NULL,
    [Anio]       SMALLINT NOT NULL,
    [Temporada]  VARCHAR(15) NOT NULL,
    CONSTRAINT [PK_Tiempo_Id] PRIMARY KEY NONCLUSTERED (Id)
)
GO

-- sp pupulate dimension time
USE [DW2022]
GO

CREATE OR ALTER PROCEDURE sp_pop_dim_tiempo_simple @desde AS INT, @hasta AS INT
AS
BEGIN

    IF(SELECT COUNT(1) FROM [DW2022].[DW].[dim_time]) <> 0 BEGIN
        RETURN
    END

    DECLARE @i INT, @Anio INT
    DECLARE @Temporada VARCHAR(15)
    
    SET @i = 1

    WHILE (@desde < @hasta)  BEGIN
        SET @Anio = @desde
        WHILE(@i <= 4) BEGIN
            SELECT @Temporada = CASE 
                                    WHEN @i = 1 THEN 'WINTER'
                                    WHEN @i = 2 THEN 'SPRING'
                                    WHEN @i = 3 THEN 'SUMMER'
                                    WHEN @i = 4 THEN 'FALL'
                                END
            
            INSERT INTO [DW2022].[DW].[dim_time]
            (
                [Anio],
                [Temporada]
            ) 
            VALUES
            (
                @Anio,
                @Temporada
            )
    
            SET @i = @i + 1
        END
        
        SET @i = 1
        SET @desde = @desde + 1
    END    
END

/*
## Hechos
*/

-- drop fact_inscripciones
DROP TABLE IF EXISTS [DW2022].[DW].[fact_inscripciones]
GO

-- create fact_inscripciones
IF NOT EXISTS (SELECT * FROM sys.tables WHERE [name] = 'fact_inscripciones')
CREATE TABLE [DW2022].[DW].[fact_inscripciones](
    [curso_id]       INT NOT NULL,
    [sala_id]        INT NOT NULL,
    [profesor_id]    INT NOT NULL,
    [tiempo_id]      INT NOT NULL,
    [modalidad]      CHAR(1) NOT NULL,
    [turno]          CHAR(1) NOT NULL,
    [inscriptos_m]   INT NOT NULL,
    [inscriptos_f]   INT NOT NULL,
    [inscriptos_t]   INT NOT NULL,
    CONSTRAINT [Fk_Curso_Id] FOREIGN KEY ([curso_id]) REFERENCES [DW2022].[DW].[dim_curso](id),
    CONSTRAINT [Fk_Sala_Id] FOREIGN KEY ([sala_id]) REFERENCES [DW2022].[DW].[dim_sala](id),
    CONSTRAINT [Fk_Profesor_Id] FOREIGN KEY ([profesor_id]) REFERENCES [DW2022].[DW].[dim_profesor](id),
    CONSTRAINT [Fk_Tiempo_Id] FOREIGN KEY ([tiempo_id]) REFERENCES [DW2022].[DW].[dim_time](id),
)

/*
## Staging
*/

-- drop stg_inscripciones
DROP TABLE IF EXISTS [DW2022].[STG].[stg_inscripciones]
GO

-- drop stg_inscripciones
IF NOT EXISTS (SELECT * FROM sys.tables WHERE [name] = 'staging_inscripciones')
CREATE TABLE [DW2022].[STG].[stg_inscripciones](
    [curso]         NVARCHAR(50) NOT NULL,
    [curso_nombre]  NVARCHAR(255) NOT NULL,
    [instructor]    NVARCHAR(50) NOT NULL,
    [room]          NVARCHAR(50) NOT NULL,
    [season]        NVARCHAR(20) NOT NULL,
    [modalidad]     CHAR(1) NOT NULL,
    [turno]         CHAR(1) NOT NULL,
    [male]          INT NOT NULL,
    [female]        INT NOT NULL,
    [total]         INT NOT NULL,
    [anio]          INT NOT NULL,
)