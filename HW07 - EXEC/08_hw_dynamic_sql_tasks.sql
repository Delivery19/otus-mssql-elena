/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "07 - Динамический SQL".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0
Нужен WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

-- ---------------------------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*

Это задание из занятия "Операторы CROSS APPLY, PIVOT, UNPIVOT."
Нужно для него написать динамический PIVOT, отображающий результаты по всем клиентам.
Имя клиента указывать полностью из поля CustomerName.

Требуется написать запрос, который в результате своего выполнения 
формирует сводку по количеству покупок в разрезе клиентов и месяцев.
В строках должны быть месяцы (дата начала месяца), в столбцах - клиенты.

Дата должна иметь формат dd.mm.yyyy, например, 25.12.2019.

Пример, как должны выглядеть результаты:
-------------+--------------------+--------------------+----------------+----------------------
InvoiceMonth | Aakriti Byrraju    | Abel Spirlea       | Abel Tatarescu | ... (другие клиенты)
-------------+--------------------+--------------------+----------------+----------------------
01.01.2013   |      3             |        1           |      4         | ...
01.02.2013   |      7             |        3           |      4         | ...
-------------+--------------------+--------------------+----------------+----------------------
*/


DECLARE @dml AS NVARCHAR(MAX)
DECLARE @ColumnName AS NVARCHAR(MAX)

SELECT @ColumnName= ISNULL(@ColumnName + ',','') + QUOTENAME(names.CustomerName)
FROM
	(
	select distinct substring(substring(CustomerName, 0, charindex(')', CustomerName)),16,20)  AS CustomerName
	from Sales.Customers
	WHERE CustomerID BETWEEN 2 AND 6
	) AS names

SELECT @ColumnName as ColumnName

SET @dml =  
N';WITH PivotData AS 
(
SELECT 
	CONVERT(VARCHAR(30), dateadd("DAY", -(day(EOMONTH(Inv.InvoiceDate))-1), EOMONTH(Inv.InvoiceDate)), 104) AS firstdd,
	substring(substring(Customs.CustomerName, 0, charindex('')'', Customs.CustomerName)),16,20)  AS CustomerName
	FROM Sales.Invoices AS Inv
JOIN Sales.Customers AS Customs ON Inv.CustomerID = Customs.CustomerID
WHERE Customs.CustomerID BETWEEN 2 AND 6
)
SELECT *
FROM PivotData
PIVOT ( count(CustomerName) 
	FOR CustomerName IN (' + @ColumnName + ')) AS PivotTable
ORDER BY PivotTable.firstdd'

EXEC sp_executesql @dml


---2-ой вариант с параметрами @CustomerIDFrom, @CustomerIDTo
--сделала через Хранимую процедуру
CREATE OR ALTER PROCEDURE [dbo].[DynamicSql]
     @CustomerIDFrom    int,     
	 @CustomerIDTo      int
AS
BEGIN
  SET NOCOUNT ON;
  
DECLARE @dml AS NVARCHAR(MAX)
DECLARE @ColumnName AS NVARCHAR(MAX)
DECLARE @params nvarchar(max)

 SET @params = N'
     @CustomerIDFrom    int,     
	 @CustomerIDTo      int';

SELECT @ColumnName= ISNULL(@ColumnName + ',','') + QUOTENAME(names.CustomerName)
FROM
	(
	select distinct substring(substring(CustomerName, 0, charindex(')', CustomerName)),16,20)  AS CustomerName
	from Sales.Customers
	WHERE CustomerID BETWEEN  @CustomerIDFrom  AND  @CustomerIDTo 
	) AS names


SELECT @ColumnName as ColumnName

SET @dml =  
N';WITH PivotData AS 
(
SELECT 
	CONVERT(VARCHAR(30), dateadd("DAY", -(day(EOMONTH(Inv.InvoiceDate))-1), EOMONTH(Inv.InvoiceDate)), 104) AS firstdd,
	substring(substring(Customs.CustomerName, 0, charindex('')'', Customs.CustomerName)),16,20)  AS CustomerName
	FROM Sales.Invoices AS Inv
JOIN Sales.Customers AS Customs ON Inv.CustomerID = Customs.CustomerID
WHERE Customs.CustomerID BETWEEN 2 AND 6
)
SELECT *
FROM PivotData
PIVOT ( count(CustomerName) 
	FOR CustomerName IN (' + @ColumnName + ')) AS PivotTable
ORDER BY PivotTable.firstdd'

EXEC sp_executesql @dml, @params, 
       @CustomerIDFrom,
       @CustomerIDTo;

END



exec [dbo].[DynamicSql]
  @CustomerIDFrom = 2,
  @CustomerIDTo = 6          



