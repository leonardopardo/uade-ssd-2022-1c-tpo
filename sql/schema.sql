-- drop database
use [master]
drop database if exists datawarehouse
create database if not exists datawarehouse
go

-- create database
use [master]
drop schema if exists dw
create schema if not exists dw
go

-- ////////////////////////////////////////////////////////////////////////////////////////////////

-- create dimension dim_curso
drop table if not exists [datawarehouse].[dw].[dim_curso]
go

if not exists (select [name] from sys.tables where [name] = [dim_curso])
create table [datawarehouse].[dw].[dim_curso](
    [id]            int identity(1,1) not null,
    [codigo]        varchar(50) not null,
    [titulo]        varchar(255) not null,
    [capacidad]     int not null,
    [modalidad]     char not null,
    [fechaInicio]   date null,
    [fechaFin]      date null,
    constraint [PK_Curso_Id] primary key nonclustered (id)
)
go

-- create dimension dim_sala
drop table if not exists [datawarehouse].[dw].[dim_sala]
go

if not exists (select * from sys.tables where [name] = [dim_sala])
create table [datawarehouse].[dw].[dim_sala](
    [id]        int identity(1,1) not null,
    [codigo]    varchar(50) not null,
    [ubicacion] varchar(50) not null,
    [nombre]    varchar(255) not null,
    [tipo]      varchar(10) not null,
    [asientos]  int not null,
    constraint [PK_Sala_Id] primary key nonclustered (id)
)
go

-- create dimension dim_profesor
drop table if not exists [datawarehouse].[dw].[dim_profesor]
go

if not exists (select * from sys.tables where [name] = [dim_profesor])
create table [datawarehouse].[dw].[dim_profesor](
    [id]                    int identity(1,1) not null,
    [codigo]                varchar(50) not null,
    [nombre]                varchar(255) not null,
    [fechaNacimiento]       int not null,
    [cantidadGrupoFamiliar] int not null,
    [cantidadHijos]         int not null,
    [comision]              float not null,
    [razon]                 float not null,
    [zip]                   varchar(50) not null,  
    [estado]                varchar(255) not null,
    [ciudad]                varchar(255) not null,
    [calle]                 varchar(255) not null,
    [fechaInicio]           date not null,
    [fechaFin]              date not null
    constraint [PK_Profesor_Id] primary key nonclustered (id)
)
go

-- create dimension dim_tiempo
drop table if not exists [datawarehouse].[dw].[dim_tiempo]
go

if not exists (select * from sys.tables where [name] = [dim_tiempo])
create table [datawarehouse].[dw].[dim_tiempo](
    [id]    int identity(1,1) not null,
    -- [fecha] datetime not null,
    [anio]  smallint not null,
    [temporada] varchar(15) not null
    constraint [PK_Tiempo_Id] primary key nonclustered (id)
)
go

-- ////////////////////////////////////////////////////////////////////////////////////////////////

-- create fact_inscripciones
drop table if not exists [datawarehouse].[dw].[fact_inscripciones]
go

if not exists (select * from sys.tables where [name] = [fact_inscripciones])
create table fact_inscripciones(
    [cursoId]       int not null,
    [salaId]        int not null,
    [profesorId]    int not null,
    [tiempoId]      int not null,
    [inscriptosM]   int not null,
    [inscriptosF]   int not null,
    [inscriptosT]   int not null,
    constraint [Fk_Curso_Id] foreign key ([cursoId]) references [datawarehouse].[dw].[dim_curso](id),
    constraint [Fk_Sala_Id] foreign key ([salaId]) references [datawarehouse].[dw].[dim_sala](id),
    constraint [Fk_Profesor_Id] foreign key ([profesorId]) references [datawarehouse].[dw].[dim_profesor](id),
    constraint [Fk_Tiempo_Id] foreign key ([tiempoId]) references [datawarehouse].[dw].[dim_tiempo](id),
)


-- ////////////////////////////////////////////////////////////////////////////////////////////////