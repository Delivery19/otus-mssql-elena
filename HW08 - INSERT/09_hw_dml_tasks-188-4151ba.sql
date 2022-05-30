/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "10 - Операторы изменения данных".

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
1. Довставлять в базу пять записей используя insert в таблицу Customers или Suppliers 
*/

--Select count(*) from Sales.Customers
--order by CustomerID desc

/* Добавлю 5 записей из этой же таблицы*/
INSERT INTO Sales.Customers
	(
	[CustomerName],
	[BillToCustomerID],
	[CustomerCategoryID],
	[BuyingGroupID],
	[PrimaryContactPersonID],
	[AlternateContactPersonID],
	[DeliveryMethodID],
	[DeliveryCityID],
	[PostalCityID],
	[CreditLimit],
	[AccountOpenedDate],
	[StandardDiscountPercentage],
	[IsStatementSent],
	[IsOnCreditHold],
	[PaymentDays],
	[PhoneNumber],
	[FaxNumber],
	[DeliveryRun],
	[RunPosition],
	[WebsiteURL],
	[DeliveryAddressLine1],
	[DeliveryAddressLine2],
	[DeliveryPostalCode],
	[DeliveryLocation],
	[PostalAddressLine1],
	[PostalAddressLine2],
	[PostalPostalCode],
	[LastEditedBy],
	[CustomerCategoryName])
SELECT TOP 5  
	'TEST',
	[BillToCustomerID],
	[CustomerCategoryID],
	[BuyingGroupID],
	[PrimaryContactPersonID],
	[AlternateContactPersonID],
	[DeliveryMethodID],
	[DeliveryCityID],
	[PostalCityID],
	[CreditLimit],
	[AccountOpenedDate],
	[StandardDiscountPercentage],
	[IsStatementSent],
	[IsOnCreditHold],
	[PaymentDays],
	[PhoneNumber],
	[FaxNumber],
	[DeliveryRun],
	[RunPosition],
	[WebsiteURL],
	[DeliveryAddressLine1],
	[DeliveryAddressLine2],
	[DeliveryPostalCode],
	[DeliveryLocation],
	[PostalAddressLine1],
	[PostalAddressLine2],
	[PostalPostalCode],
	[LastEditedBy],
	[CustomerCategoryName]
FROM Sales.Customers;


--Select top 1 * from Purchasing.Suppliers
/*
2. Удалите одну запись из Customers, которая была вами добавлена
*/

напишите здесь свое решение


/*
3. Изменить одну запись, из добавленных через UPDATE
*/

напишите здесь свое решение

/*
4. Написать MERGE, который вставит вставит запись в клиенты, если ее там нет, и изменит если она уже есть
*/

напишите здесь свое решение

/*
5. Напишите запрос, который выгрузит данные через bcp out и загрузить через bulk insert
*/

напишите здесь свое решение