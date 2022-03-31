/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "03 - Подзапросы, CTE, временные таблицы".

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
-- Для всех заданий, где возможно, сделайте два варианта запросов:
--  1) через вложенный запрос
--  2) через WITH (для производных таблиц)
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. Выберите сотрудников (Application.People), которые являются продажниками (IsSalesPerson), 
и не сделали ни одной продажи 04 июля 2015 года. 
Вывести ИД сотрудника и его полное имя. 
Продажи смотреть в таблице Sales.Invoices.
*/


-- 1) через вложенный запрос
SELECT TOP 5 * FROM Application.People
SELECT TOP 5 * FROM Sales.Invoices

SELECT PersonID, FullName
FROM Application.People
WHERE IsSalesperson = 1 
	AND EXISTS ( 
    SELECT SalespersonPersonID
	FROM Sales.Invoices b
	WHERE SalespersonPersonID = People.PersonID AND InvoiceDate <> '20150704')

--2) через WITH (для производных таблиц)
;WITH InvoicesCTE AS 
(
	SELECT SalespersonPersonID 
	FROM Sales.Invoices
	WHERE InvoiceDate <> '20150704' 
	GROUP BY SalespersonPersonID
)
SELECT P.PersonID, P.FullName
FROM [Application].People AS P
JOIN InvoicesCTE AS I ON P.PersonID = I.SalespersonPersonID
ORDER BY P.PersonID


/*
2. Выберите товары с минимальной ценой (подзапросом). Сделайте два варианта подзапроса. 
Вывести: ИД товара, наименование товара, цена.
*/

-- 1) через вложенный запрос
-- ВАРИАНТ 1
SELECT StockItemID, StockItemName, UnitPrice 
FROM Warehouse.StockItems
WHERE UnitPrice = (SELECT min(UnitPrice) FROM Warehouse.StockItems);

--ВАРИАНТ 2
SELECT StockItemID, StockItemName, UnitPrice 
FROM Warehouse.StockItems
WHERE UnitPrice <= ALL (SELECT UnitPrice FROM Warehouse.StockItems);

/*
3. Выберите информацию по клиентам, которые перевели компании пять максимальных платежей 
из Sales.CustomerTransactions. 
Представьте несколько способов (в том числе с CTE). 
*/
SELECT TOP 5 * FROM Sales.Customers
SELECT TOP 5 * FROM Sales.CustomerTransactions

SELECT TOP 5 CustomerID, CustomerName,
	(SELECT MAX(b.AmountExcludingTax) 
	FROM Sales.CustomerTransactions b
	WHERE a.CustomerID = b.CustomerID) AS MAX_TAX
FROM Sales.Customers a
ORDER BY MAX_TAX DESC

--CTE
;WITH CustomerTransactionsCTE AS 
(
	SELECT CustomerID, MAX(AmountExcludingTax) AS MAX_TAX
	FROM Sales.CustomerTransactions 
	GROUP BY CustomerID
)
SELECT TOP 5 P.CustomerID, P.CustomerName, I.MAX_TAX
FROM Sales.Customers AS P
JOIN CustomerTransactionsCTE AS I ON P.CustomerID = I.CustomerID
ORDER BY I.MAX_TAX DESC


/*
4. Выберите города (ид и название), в которые были доставлены товары, 
входящие в тройку самых дорогих товаров, а также имя сотрудника, 
который осуществлял упаковку заказов (PickedByPersonID).
*/

/*
Как связать с таблицой сотрудников Application.People
и таблицей Sales.Orders (--PickedByPersonID) ?
*/


SELECT TOP 5 * FROM Sales.Orders --PickedByPersonID
SELECT TOP 5 * FROM Application.People


;WITH StockItemsCTE AS 
(
	SELECT DISTINCT TOP 3 SupplierID, UnitPrice
	FROM Warehouse.StockItems
	ORDER by UnitPrice DESC
),
SuppliersCTE AS 
(
	SELECT StockItemsCTE.UnitPrice, Suppliers.SupplierID, Suppliers.DeliveryCityID, Suppliers.AlternateContactPersonID
	FROM Purchasing.Suppliers Suppliers
	JOIN StockItemsCTE ON Suppliers.SupplierID = StockItemsCTE.SupplierID
)--,
--CitiesCTE AS 
--(
	SELECT SuppliersCTE.UnitPrice, SuppliersCTE.AlternateContactPersonID, Cities.CityID, Cities.CityName
	FROM Application.Cities Cities
	JOIN SuppliersCTE ON SuppliersCTE.DeliveryCityID = Cities.CityID
--)




-- ---------------------------------------------------------------------------
-- Опциональное задание
-- ---------------------------------------------------------------------------
-- Можно двигаться как в сторону улучшения читабельности запроса, 
-- так и в сторону упрощения плана\ускорения. 
-- Сравнить производительность запросов можно через SET STATISTICS IO, TIME ON. 
-- Если знакомы с планами запросов, то используйте их (тогда к решению также приложите планы). 
-- Напишите ваши рассуждения по поводу оптимизации. 

-- 5. Объясните, что делает и оптимизируйте запрос

SELECT 
	Invoices.InvoiceID, 
	Invoices.InvoiceDate,
	(SELECT People.FullName
		FROM Application.People
		WHERE People.PersonID = Invoices.SalespersonPersonID
	) AS SalesPersonName,
	SalesTotals.TotalSumm AS TotalSummByInvoice, 
	(SELECT SUM(OrderLines.PickedQuantity*OrderLines.UnitPrice)
		FROM Sales.OrderLines
		WHERE OrderLines.OrderId = (SELECT Orders.OrderId 
			FROM Sales.Orders
			WHERE Orders.PickingCompletedWhen IS NOT NULL	
				AND Orders.OrderId = Invoices.OrderId)	
	) AS TotalSummForPickedItems
FROM Sales.Invoices 
	JOIN
	(SELECT InvoiceId, SUM(Quantity*UnitPrice) AS TotalSumm
	FROM Sales.InvoiceLines
	GROUP BY InvoiceId
	HAVING SUM(Quantity*UnitPrice) > 27000) AS SalesTotals
		ON Invoices.InvoiceID = SalesTotals.InvoiceID
ORDER BY TotalSumm DESC

-- --

TODO: напишите здесь свое решение
