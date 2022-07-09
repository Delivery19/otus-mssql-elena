/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "12 - Хранимые процедуры, функции, триггеры, курсоры".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0
Нужен WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

USE WideWorldImporters

/*
Во всех заданиях написать хранимую процедуру / функцию и продемонстрировать ее использование.
*/

/*
1) Написать функцию возвращающую Клиента с наибольшей суммой покупки.
*/

CREATE FUNCTION Client_MAXAmount(@customerid int)
RETURNS TABLE  
AS  
RETURN 
(
	SELECT TOP 1 Customers.CustomerName, trans.TransactionAmount
	FROM Sales.Invoices AS Invoices
	JOIN Sales.CustomerTransactions AS trans ON Invoices.InvoiceID = trans.InvoiceID
	JOIN Sales.Customers AS Customers ON Invoices.CustomerID = Customers.CustomerID
	WHERE Customers.CustomerID = @customerid
	ORDER BY trans.TransactionAmount DESC 
);
GO 

SELECT * FROM Client_MAXAmount (2);

/*
2) Написать хранимую процедуру с входящим параметром СustomerID, выводящую сумму покупки по этому клиенту.
Использовать таблицы :
Sales.Customers
Sales.Invoices
Sales.InvoiceLines
*/

CREATE OR ALTER Procedure Сustomer_summ(@customerid int)
AS  
    SET NOCOUNT OFF;    
	SELECT Customers.CustomerName, InvoiceLines.TaxAmount
	FROM Sales.Invoices AS Invoices
	JOIN Sales.InvoiceLines AS InvoiceLines ON Invoices.InvoiceID = InvoiceLines.InvoiceID
	JOIN Sales.Customers AS Customers ON Invoices.CustomerID = Customers.CustomerID
	WHERE Customers.CustomerID = @customerid 
GO 

exec Сustomer_summ @customerid=2;

/*
3) Создать одинаковую функцию и хранимую процедуру, посмотреть в чем разница в производительности и почему.
*/

--Создаю такую же функцию, как во 2 упражнении
CREATE FUNCTION Сustomer_summ2(@customerid int)
RETURNS TABLE  
AS  
RETURN 
( 
	SELECT Customers.CustomerName, InvoiceLines.TaxAmount
	FROM Sales.Invoices AS Invoices
	JOIN Sales.InvoiceLines AS InvoiceLines ON Invoices.InvoiceID = InvoiceLines.InvoiceID
	JOIN Sales.Customers AS Customers ON Invoices.CustomerID = Customers.CustomerID
	WHERE Customers.CustomerID = @customerid 
)
GO 


SELECT * FROM Сustomer_summ2 (2);

/*
4) Создайте табличную функцию покажите как ее можно вызвать для каждой строки result set'а без использования цикла. 
*/

	SELECT Customers.CustomerName
	FROM  Sales.Customers AS Customers
	CROSS APPLY Сustomer_summ2(Customers.CustomerID)
	--OUTER APPLY Сustomer_summ2(2)





/*
5) Опционально. Во всех процедурах укажите какой уровень изоляции транзакций вы бы использовали и почему. 
*/
