/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "05 - Операторы CROSS APPLY, PIVOT, UNPIVOT".

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
1. Требуется написать запрос, который в результате своего выполнения 
формирует сводку по количеству покупок в разрезе клиентов и месяцев.
В строках должны быть месяцы (дата начала месяца), в столбцах - клиенты.

Клиентов взять с ID 2-6, это все подразделение Tailspin Toys.
Имя клиента нужно поменять так чтобы осталось только уточнение.
Например, исходное значение "Tailspin Toys (Gasport, NY)" - вы выводите только "Gasport, NY".
Дата должна иметь формат dd.mm.yyyy, например, 25.12.2019.

Пример, как должны выглядеть результаты:
-------------+--------------------+--------------------+-------------+--------------+------------
InvoiceMonth | Peeples Valley, AZ | Medicine Lodge, KS | Gasport, NY | Sylvanite, MT | Jessie, ND
-------------+--------------------+--------------------+-------------+--------------+------------
01.01.2013   |      3             |        1           |      4      |      2        |     2
01.02.2013   |      7             |        3           |      4      |      2        |     1
-------------+--------------------+--------------------+-------------+--------------+------------
*/

;WITH PivotData AS 
(
SELECT 
	CONVERT(VARCHAR(30), dateadd("DAY", -(day(EOMONTH(Inv.InvoiceDate))-1), EOMONTH(Inv.InvoiceDate)), 104) AS firstdd, 
	substring(substring(Customs.CustomerName, 0, charindex(')', Customs.CustomerName)),16,20)  AS CustomerName
FROM Sales.Invoices AS Inv
JOIN Sales.Customers AS Customs ON Inv.CustomerID = Customs.CustomerID
WHERE Customs.CustomerID BETWEEN 2 AND 6
)
SELECT *
FROM PivotData
PIVOT ( count(CustomerName) 
	FOR CustomerName IN ([Gasport, NY], [Jessie, ND], [Medicine Lodge, KS], [Peeples Valley, AZ], [Sylvanite, MT])
) AS PivotTable
ORDER BY PivotTable.firstdd

/*
2. Для всех клиентов с именем, в котором есть "Tailspin Toys"
вывести все адреса, которые есть в таблице, в одной колонке.

Пример результата:
----------------------------+--------------------
CustomerName                | AddressLine
----------------------------+--------------------
Tailspin Toys (Head Office) | Shop 38
Tailspin Toys (Head Office) | 1877 Mittal Road
Tailspin Toys (Head Office) | PO Box 8975
Tailspin Toys (Head Office) | Ribeiroville
----------------------------+--------------------
*/

SELECT *
FROM (
	SELECT CustomerName, DeliveryAddressLine1, DeliveryAddressLine2
	FROM Sales.Customers
	WHERE CustomerName like '%Tailspin Toys%'
	--ORDER BY CustomerName
	) AS Addr
UNPIVOT (AddressLine FOR ColAddr IN (DeliveryAddressLine1, DeliveryAddressLine2)) AS unpt;

/*
3. В таблице стран (Application.Countries) есть поля с цифровым кодом страны и с буквенным.
Сделайте выборку ИД страны, названия и ее кода так, 
чтобы в поле с кодом был либо цифровой либо буквенный код.

Пример результата:
--------------------------------
CountryId | CountryName | Code
----------+-------------+-------
1         | Afghanistan | AFG
1         | Afghanistan | 4
3         | Albania     | ALB
3         | Albania     | 8
----------+-------------+-------
*/

SELECT *
FROM (
	SELECT CountryName, IsoAlpha3Code, cast(IsoNumericCode AS nvarchar(3)) AS IsoNumericCode
	FROM Application.Countries
	) AS cntr
UNPIVOT (Code FOR colCode IN (IsoAlpha3Code, IsoNumericCode)) AS unpt;


/*
4. Выберите по каждому клиенту два самых дорогих товара, которые он покупал.
В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки.
*/

SELECT C.CustomerName, Tbl.*
FROM Sales.Customers C
CROSS APPLY (
	SELECT TOP 2 ord.CustomerID, max(ordLine.UnitPrice) AS MX
	FROM Sales.OrderLines AS ordLine
	JOIN Sales.Orders AS ord ON ordLine.OrderID = ord.OrderID
	WHERE C.CustomerID = ord.CustomerID
	GROUP BY ord.CustomerID
	) AS Tbl
--ORDER BY C.CustomerName;
