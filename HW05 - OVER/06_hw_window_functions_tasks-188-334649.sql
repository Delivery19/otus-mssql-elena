/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "06 - Оконные функции".

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
1. Сделать расчет суммы продаж нарастающим итогом по месяцам с 2015 года 
(в рамках одного месяца он будет одинаковый, нарастать будет в течение времени выборки).
Выведите: id продажи, название клиента, дату продажи, сумму продажи, сумму нарастающим итогом

Пример:
-------------+----------------------------
Дата продажи | Нарастающий итог по месяцу
-------------+----------------------------
 2015-01-29   | 4801725.31
 2015-01-30	 | 4801725.31
 2015-01-31	 | 4801725.31
 2015-02-01	 | 9626342.98
 2015-02-02	 | 9626342.98
 2015-02-03	 | 9626342.98
Продажи можно взять из таблицы Invoices.
Нарастающий итог должен быть без оконной функции.
*/

SELECT TOP 5 * FROM Sales.Invoices 
SELECT TOP 5 * FROM Sales.CustomerTransactions
SELECT TOP 5 * FROM Application.People

set statistics time, io on

SELECT Invoices.InvoiceId, people.FullName, Invoices.InvoiceDate, Invoices.CustomerID, trans.TransactionAmount,
	(SELECT SUM(inr.TransactionAmount)
	FROM Sales.CustomerTransactions as inr
	join Sales.Invoices as InvoicesInner ON InvoicesInner.InvoiceID = inr.InvoiceID
	WHERE inr.CustomerID = trans.CustomerId AND InvoicesInner.InvoiceDate > '20150101'
	) AS TransactionAmount_SUM

FROM Sales.Invoices as Invoices
JOIN Sales.CustomerTransactions as trans ON Invoices.InvoiceID = trans.InvoiceID
JOIN Application.People AS people ON Invoices.SalespersonPersonID = people.PersonID
WHERE Invoices.InvoiceDate > '20150101'
ORDER BY TransactionAmount_SUM, Invoices.InvoiceDate

/*
2. Сделайте расчет суммы нарастающим итогом в предыдущем запросе с помощью оконной функции.
   Сравните производительность запросов 1 и 2 с помощью set statistics time, io on
*/

SELECT Invoices.InvoiceId, people.FullName, Invoices.InvoiceDate, Invoices.CustomerID, 
	SUM(trans.TransactionAmount) OVER (PARTITION BY trans.CustomerId) AS TransactionAmount_SUM
FROM Sales.Invoices as Invoices 
JOIN Sales.CustomerTransactions AS trans ON Invoices.InvoiceID = trans.InvoiceID
JOIN Application.People AS people ON Invoices.SalespersonPersonID = people.PersonID
WHERE Invoices.InvoiceDate > '20150101'
ORDER BY TransactionAmount_SUM, Invoices.InvoiceDate;

/*
3. Вывести список 2х самых популярных продуктов (по количеству проданных) 
в каждом месяце за 2016 год (по 2 самых популярных продукта в каждом месяце).
*/

SELECT TOP 5 * FROM Sales.CustomerTransactions
SELECT TOP 5 * FROM Sales.Invoices

SELECT *
FROM
	(
	SELECT InvoiceLines.[Description],  MONTH(Invoices.InvoiceDate) AS InvoiceDate_MONTH, 
		InvoiceLines.Quantity,
		ROW_NUMBER() OVER (PARTITION BY InvoiceLines.[Description] ORDER BY MONTH(Invoices.InvoiceDate),InvoiceLines.Quantity DESC) AS NUMBER
	FROM Sales.InvoiceLines AS InvoiceLines
	JOIN Sales.Invoices AS Invoices ON InvoiceLines.InvoiceID = Invoices.InvoiceID
	WHERE Invoices.InvoiceDate >= '20160101' AND Invoices.InvoiceDate <= '20161231'
	GROUP BY InvoiceLines.[Description] , MONTH(Invoices.InvoiceDate), InvoiceLines.Quantity
	--ORDER BY InvoiceLines.Description, InvoiceDate_MONTH , InvoiceLines.Quantity DESC
	) AS tbl
WHERE tbl.NUMBER <=2

/*
4. Функции одним запросом
Посчитайте по таблице товаров (в вывод также должен попасть ид товара, название, брэнд и цена):
* пронумеруйте записи по названию товара, так чтобы при изменении буквы алфавита нумерация начиналась заново
* посчитайте общее количество товаров и выведете полем в этом же запросе
* посчитайте общее количество товаров в зависимости от первой буквы названия товара
* отобразите следующий id товара исходя из того, что порядок отображения товаров по имени 
* предыдущий ид товара с тем же порядком отображения (по имени)
* названия товара 2 строки назад, в случае если предыдущей строки нет нужно вывести "No items"
* сформируйте 30 групп товаров по полю вес товара на 1 шт

Для этой задачи НЕ нужно писать аналог без аналитических функций.
*/

SELECT StockItemID, StockItemName, UnitPrice,
	ROW_NUMBER() OVER (PARTITION BY StockItemName ORDER BY StockItemName) AS Rn,
	COUNT(StockItemName) OVER() AS Total,
	COUNT(StockItemName) OVER(PARTITION BY StockItemName ORDER BY StockItemName) AS Total_Name,
	LEAD(StockItemName) OVER (ORDER BY StockItemName) AS leadv,
	LAG(StockItemName) OVER (ORDER BY StockItemName) AS lagv,
	LAG(StockItemName,2,'No items') OVER (ORDER BY StockItemName) AS lagv2,
	NTILE(30) OVER (PARTITION BY TypicalWeightPerUnit ORDER BY TypicalWeightPerUnit) AS GroupNumber
FROM Warehouse.StockItems
--WHERE SupplierID in (5, 7)
ORDER By StockItemName

/*
5. По каждому сотруднику выведите последнего клиента, которому сотрудник что-то продал.
   В результатах должны быть ид и фамилия сотрудника, ид и название клиента, дата продажи, сумму сделки.
*/

SELECT * 
FROM (
SELECT DENSE_RANK() OVER (partition by tbl.PersonID order by tbl.InvoiceDate DESC) AS DRANK,
	tbl.PersonID,  tbl.FullName, tbl.CustomerID, tbl.CustomerName, tbl.InvoiceDate, tbl.UnitPrice
FROM (
SELECT p.PersonID,  p.FullName, c.CustomerID, c.CustomerName, i.InvoiceDate, ol.UnitPrice
FROM Sales.Invoices i
JOIN Sales.OrderLines ol ON i.OrderID = ol.OrderID
JOIN Sales.Customers c ON i.CustomerID = c.CustomerID
JOIN Application.People p ON i.PackedByPersonID = p.PersonID
WHERE p.IsSalesPerson = 1
--ORDER BY p.PersonID, i.InvoiceDate DESC
) AS tbl
) AS tbl2
WHERE tbl2.DRANK = 1

/*
6. Выберите по каждому клиенту два самых дорогих товара, которые он покупал.
В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки.
*/

SELECT *
FROM 
	(
	SELECT Invoices.CustomerID, Customers.CustomerName, trans.TransactionAmount,
		ROW_NUMBER() OVER (PARTITION BY Invoices.CustomerId ORDER BY trans.TransactionAmount DESC) AS CustomerTransRank
	FROM Sales.Invoices AS Invoices
	JOIN Sales.CustomerTransactions AS trans ON Invoices.InvoiceID = trans.InvoiceID
	JOIN Sales.Customers AS Customers ON Invoices.CustomerID = Customers.CustomerID
	) AS tbl
WHERE CustomerTransRank <= 2
order by CustomerID, TransactionAmount desc;


Опционально можете для каждого запроса без оконных функций сделать вариант запросов с оконными функциями и сравнить их производительность. 