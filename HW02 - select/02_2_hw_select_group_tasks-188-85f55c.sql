/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.
Занятие "02 - Оператор SELECT и простые фильтры, GROUP BY, HAVING".

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
1. Все товары, в названии которых есть "urgent" или название начинается с "Animal".
Вывести: ИД товара (StockItemID), наименование товара (StockItemName).
Таблицы: Warehouse.StockItems.
*/

SELECT StockItemID, StockItemName  FROM Warehouse.StockItems
WHERE StockItemName like '%urgent%' OR StockItemName like 'Animal%'

/*
2. Поставщиков (Suppliers), у которых не было сделано ни одного заказа (PurchaseOrders).
Сделать через JOIN, с подзапросом задание принято не будет.
Вывести: ИД поставщика (SupplierID), наименование поставщика (SupplierName).
Таблицы: Purchasing.Suppliers, Purchasing.PurchaseOrders.
По каким колонкам делать JOIN подумайте самостоятельно.
*/

SELECT a.SupplierID, a.SupplierName 
FROM Purchasing.Suppliers a
LEFT JOIN Purchasing.PurchaseOrders b ON a.SupplierID = b.SupplierID
WHERE b.SupplierID is null
ORDER BY a.SupplierID

/*
3. Заказы (Orders) с ценой товара (UnitPrice) более 100$ 
либо количеством единиц (Quantity) товара более 20 штук
и присутствующей датой комплектации всего заказа (PickingCompletedWhen).
Вывести:
* OrderID
* дату заказа (OrderDate) в формате ДД.ММ.ГГГГ
* название месяца, в котором был сделан заказ
* номер квартала, в котором был сделан заказ
* треть года, к которой относится дата заказа (каждая треть по 4 месяца)
* имя заказчика (Customer)
Добавьте вариант этого запроса с постраничной выборкой,
пропустив первую 1000 и отобразив следующие 100 записей.

Сортировка должна быть по номеру квартала, трети года, дате заказа (везде по возрастанию).

Таблицы: Sales.Orders, Sales.OrderLines, Sales.Customers.
*/


/*
В таблице Sales.OrderLines нет отсутствующей даты комплектации(PickingCompletedWhen),
поэтому фильтр здесь не имеет смысла, но я всё равно поставила)
*/

SELECT
	a.OrderID,
	convert(nvarchar(16), a.OrderDate, 104) as DateAsString,

	CASE MONTH(a.OrderDate)
		WHEN 1 THEN 'January'
		WHEN 2 THEN 'February'
		WHEN 3 THEN 'March'
		WHEN 4 THEN 'April'
		WHEN 5 THEN 'May'
		WHEN 6 THEN 'June'
		WHEN 7 THEN 'July'
		WHEN 8 THEN 'August'
		WHEN 9 THEN 'August'
		WHEN 10 THEN 'October'
		WHEN 11 THEN 'November'
		WHEN 12 THEN 'December'
	END MonthOrderDate,

	DATEPART (qq, a.OrderDate )  AS quarterOrderDate,

	CASE 
		WHEN MONTH(a.OrderDate) <= 4 THEN '1'
		WHEN MONTH(a.OrderDate) >= 5 AND MONTH(a.OrderDate) <= 8 THEN '2'
		WHEN MONTH(a.OrderDate) >= 9 THEN '3'
	END thirdOfYear,

	d.CustomerName
FROM Sales.Orders a
JOIN Sales.OrderLines b ON a.OrderID = b.OrderID
JOIN Sales.Customers d ON a.CustomerID = d.CustomerID
WHERE (b.UnitPrice > 100 OR b.Quantity > 20) AND b.PickingCompletedWhen IS NOT NULL
ORDER BY a.OrderID, a.OrderDate
OFFSET 1000 ROWS FETCH FIRST 100 ROWS ONLY;



/*
4. Заказы поставщикам (Purchasing.Suppliers),
которые должны быть исполнены (ExpectedDeliveryDate) в январе 2013 года
с доставкой "Air Freight" или "Refrigerated Air Freight" (DeliveryMethodName)
и которые исполнены (IsOrderFinalized).
Вывести:
* способ доставки (DeliveryMethodName)
* дата доставки (ExpectedDeliveryDate)
* имя поставщика
* имя контактного лица принимавшего заказ (ContactPerson)

Таблицы: Purchasing.Suppliers, Purchasing.PurchaseOrders, Application.DeliveryMethods, Application.People.
*/

SELECT
	e.DeliveryMethodName,
	b.ExpectedDeliveryDate,
	a.SupplierName,
	f.FullName
FROM Purchasing.Suppliers a
JOIN Purchasing.PurchaseOrders b ON a.SupplierID = b.SupplierID
JOIN Application.DeliveryMethods e ON a.DeliveryMethodID = e.DeliveryMethodID
JOIN Application.People f ON b.ContactPersonID = f.PersonID
WHERE 1=1
AND b.ExpectedDeliveryDate >= '20130101' AND b.ExpectedDeliveryDate <= '20130131'
AND e.DeliveryMethodName IN ('Air Freight', 'Refrigerated Air Freight')
AND b.IsOrderFinalized = 1


/*
5. Десять последних продаж (по дате продажи) с именем клиента и именем сотрудника,
который оформил заказ (SalespersonPerson).
Сделать без подзапросов.
*/

SELECT TOP 10	
	a.OrderDate,
	b.CustomerName,
	d.FullName
FROM Sales.Orders a
JOIN Sales.Customers b ON a.CustomerID = b.CustomerID
JOIN Application.People d ON a.SalespersonPersonID = d.PersonID
ORDER BY a.OrderDate DESC


/*
6. Все ид и имена клиентов и их контактные телефоны,
которые покупали товар "Chocolate frogs 250g".
Имя товара смотреть в таблице Warehouse.StockItems.
*/

SELECT DISTINCT
	a.PersonID,
	a.FullName,
	a.PhoneNumber
FROM Application.People a
JOIN Purchasing.PurchaseOrders b ON a.PersonID = b.ContactPersonID
JOIN Warehouse.StockItems e ON b.SupplierID = e.SupplierID
WHERE e.StockItemName = 'Chocolate frogs 250g'

