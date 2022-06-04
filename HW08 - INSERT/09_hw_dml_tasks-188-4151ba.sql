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
	[LastEditedBy])
SELECT TOP 5  
	'TEST ' +  cast(newid() as nchar(36)),
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
	[LastEditedBy]
FROM Sales.Customers;


/*
2. Удалите одну запись из Customers, которая была вами добавлена
*/

DELETE TOP (1) FROM	 Sales.Customers
WHERECustomerName like '%TEST%';


/*
3. Изменить одну запись, из добавленных через UPDATE
*/

UPDATE TOP (1)	 Sales.Customers
SET CustomerName = 'Test_Flowers'
WHERE CustomerName like '%TEST%';

/*
4. Написать MERGE, который вставит вставит запись в клиенты, если ее там нет, и изменит если она уже есть
*/

MERGE Sales.Customers AS target 
USING (SELECT top 10 * from Sales.Customers
		WHERE CustomerName like '%TEST%'
		) 
		AS source  
		ON
	 (target.CustomerID = source.CustomerID) 
	WHEN MATCHED 
		THEN UPDATE SET target.CreditLimit = 0
	WHEN NOT MATCHED 
		THEN INSERT ([CustomerID], [CustomerName], [BillToCustomerID], [CustomerCategoryID], [BuyingGroupID], [PrimaryContactPersonID], [AlternateContactPersonID],[DeliveryMethodID],[DeliveryCityID], [PostalCityID], [CreditLimit], [AccountOpenedDate]) 
		VALUES (source.[CustomerID], source.[CustomerName], source.[BillToCustomerID], source.[CustomerCategoryID], source.[BuyingGroupID], source.[PrimaryContactPersonID], source.[AlternateContactPersonID], source.[DeliveryMethodID], source.[DeliveryCityID], source.[PostalCityID], source.[CreditLimit], source.[AccountOpenedDate]) 
	OUTPUT deleted.*, $action, inserted.*;

/*
5. Напишите запрос, который выгрузит данные через bcp out и загрузить через bulk insert
*/

-- To allow advanced options to be changed.  
EXEC sp_configure 'show advanced options', 1;  
GO  
-- To update the currently configured value for advanced options.  
RECONFIGURE;  
GO  
-- To enable the feature.  
EXEC sp_configure 'xp_cmdshell', 1;  
GO  
-- To update the currently configured value for this feature.  
RECONFIGURE;  
GO  

SELECT @@SERVERNAME

exec master..xp_cmdshell 'bcp "[WideWorldImporters].Sales.Customers" out  "D:\1\Customers.txt" -T -w -t"!!!" -S DESKTOP-83GPC9J\SQL2017'
-----------
drop table if exists [Sales].[Customers_BulkDemo]


CREATE TABLE [Sales].[Customers_BulkDemo](
	[CustomerID] [int] NOT NULL,
	[CustomerName] [nvarchar](100) NOT NULL,
	[BillToCustomerID] [int] NOT NULL,
	[CustomerCategoryID] [int] NOT NULL,
	[BuyingGroupID] [int] NULL,
	[PrimaryContactPersonID] [int] NOT NULL,
	[AlternateContactPersonID] [int] NULL,
	[DeliveryMethodID] [int] NOT NULL,
	[DeliveryCityID] [int] NOT NULL,
	[PostalCityID] [int] NOT NULL,
	[CreditLimit] [decimal](18, 2) NULL,
	[AccountOpenedDate] [date] NOT NULL,
	[StandardDiscountPercentage] [decimal](18, 3) NOT NULL,
	[IsStatementSent] [bit] NOT NULL,
	[IsOnCreditHold] [bit] NOT NULL,
	[PaymentDays] [int] NOT NULL,
	[PhoneNumber] [nvarchar](20) NOT NULL,
	[FaxNumber] [nvarchar](20) NOT NULL,
	[DeliveryRun] [nvarchar](5) NULL,
	[RunPosition] [nvarchar](5) NULL,
	[WebsiteURL] [nvarchar](256) NOT NULL,
	[DeliveryAddressLine1] [nvarchar](60) NOT NULL,
	[DeliveryAddressLine2] [nvarchar](60) NULL,
	[DeliveryPostalCode] [nvarchar](10) NOT NULL,
	[DeliveryLocation] [geography] NULL,
	[PostalAddressLine1] [nvarchar](60) NOT NULL,
	[PostalAddressLine2] [nvarchar](60) NULL,
	[PostalPostalCode] [nvarchar](10) NOT NULL,
	[LastEditedBy] [int] NOT NULL,
	[ValidFrom] [datetime2](7) GENERATED ALWAYS AS ROW START NOT NULL,
	[ValidTo] [datetime2](7) GENERATED ALWAYS AS ROW END NOT NULL,
 CONSTRAINT [PK_Sales_Customers_BulkDemo] PRIMARY KEY CLUSTERED 
(
	[CustomerID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [USERDATA],
 CONSTRAINT [UQ_Sales_Customers_CustomerName_BulkDemo] UNIQUE NONCLUSTERED 
(
	[CustomerName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [USERDATA],
	PERIOD FOR SYSTEM_TIME ([ValidFrom], [ValidTo])
) ON [USERDATA] TEXTIMAGE_ON [USERDATA]

GO

	BULK INSERT [WideWorldImporters].[Sales].[Customers_BulkDemo]
				   FROM "D:\1\Customers.txt"
				   WITH 
					 (
						BATCHSIZE = 1000, 
						DATAFILETYPE = 'widechar',
						FIELDTERMINATOR = '!!!',
						ROWTERMINATOR ='\n',
						KEEPNULLS,
						TABLOCK        
					  );


select Count(*) from [Sales].[Customers_BulkDemo];
select Count(*) from [Sales].[Customers];

TRUNCATE TABLE [Sales].[Customers_BulkDemo];
drop table if exists [Sales].[Customers_BulkDemo]