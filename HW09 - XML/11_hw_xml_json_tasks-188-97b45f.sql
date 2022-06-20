
/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "08 - Выборки из XML и JSON полей".

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
Примечания к заданиям 1, 2:
* Если с выгрузкой в файл будут проблемы, то можно сделать просто SELECT c результатом в виде XML. 
* Если у вас в проекте предусмотрен экспорт/импорт в XML, то можете взять свой XML и свои таблицы.
* Если с этим XML вам будет скучно, то можете взять любые открытые данные и импортировать их в таблицы (например, с https://data.gov.ru).
* Пример экспорта/импорта в файл https://docs.microsoft.com/en-us/sql/relational-databases/import-export/examples-of-bulk-import-and-export-of-xml-documents-sql-server
*/


/*
1. В личном кабинете есть файл StockItems.xml.
Это данные из таблицы Warehouse.StockItems.
Преобразовать эти данные в плоскую таблицу с полями, аналогичными Warehouse.StockItems.
Поля: StockItemName, SupplierID, UnitPackageID, OuterPackageID, QuantityPerOuter, TypicalWeightPerUnit, LeadTimeDays, IsChillerStock, TaxRate, 
UnitPrice 

Загрузить эти данные в таблицу Warehouse.StockItems: 
существующие записи в таблице обновить, отсутствующие добавить (сопоставлять записи по полю StockItemName). 

Сделать два варианта: с помощью OPENXML и через XQuery.
*/


--С помощью OPENXML


DECLARE @xmlDocument  xml

-- Считываем XML-файл в переменную
-- !!! измените путь к XML-файлу
SELECT @xmlDocument = BulkColumn
FROM OPENROWSET
(BULK 'D:\otus\11_StockItems-188-1fb5df.xml', SINGLE_CLOB) as data 

-- Проверяем, что в @xmlDocument
--SELECT @xmlDocument as [@xmlDocument]

DECLARE @docHandle int
EXEC sp_xml_preparedocument @docHandle OUTPUT, @xmlDocument

---- можно вставить результат в таблицу
DROP TABLE IF EXISTS #StockItem

CREATE TABLE #StockItem(
	[StockItemName]        nvarchar(100)  ,
	[SupplierID]           int            ,
	[UnitPackageID]        int            ,
	[OuterPackageID]       int            ,
	[QuantityPerOuter]     int            ,
	[TypicalWeightPerUnit] decimal(18,3)  ,
	[LeadTimeDays]         int            ,
	[IsChillerStock]       bit            ,
	[TaxRate]              decimal(18,3)  ,
	[UnitPrice]            decimal(18,2) 
)

INSERT INTO #StockItem
SELECT *
FROM OPENXML(@docHandle, N'/StockItems/Item')
WITH ( 
	[StockItemName]        nvarchar(100)  '@Name',
	[SupplierID]           int            'SupplierID',
	[UnitPackageID]        int            'Package/UnitPackageID',
	[OuterPackageID]       int            'Package/OuterPackageID',
	[QuantityPerOuter]     int            'Package/QuantityPerOuter',
	[TypicalWeightPerUnit] decimal(18,3)  'Package/TypicalWeightPerUnit',
	[LeadTimeDays]         int            'LeadTimeDays',
	[IsChillerStock]       bit            'IsChillerStock',
	[TaxRate]              decimal(18,3)  'TaxRate',
	[UnitPrice]            decimal(18,2)  'UnitPrice')

-- Надо удалить handle
EXEC sp_xml_removedocument @docHandle
SELECT * FROM #StockItem

--SELECT wS.* FROM Warehouse.StockItems wS
--LEFT JOIN #StockItem SI ON wS.StockItemName COLLATE Latin1_General_CI_AS = SI.StockItemName

MERGE Warehouse.StockItems AS target 
USING (SELECT *  FROM #StockItem 
		) 
		AS source  
		ON
	 (target.StockItemName = source.StockItemName COLLATE Latin1_General_100_CI_AS) 
	WHEN MATCHED 
		THEN UPDATE SET target.SupplierID = source.SupplierID,
						target.UnitPackageID = source.UnitPackageID,
						target.OuterPackageID = source.OuterPackageID,
						target.QuantityPerOuter = source.QuantityPerOuter,
						target.TypicalWeightPerUnit = source.TypicalWeightPerUnit,
						target.LeadTimeDays = source.LeadTimeDays,
						target.IsChillerStock = source.IsChillerStock,
						target.TaxRate = source.TaxRate,
						target.UnitPrice = source.UnitPrice
	WHEN NOT MATCHED 
		THEN INSERT (StockItemName, SupplierID, UnitPackageID, OuterPackageID, QuantityPerOuter, TypicalWeightPerUnit, LeadTimeDays, IsChillerStock, TaxRate, UnitPrice, [LastEditedBy]) 
		VALUES (source.StockItemName, source.SupplierID, source.UnitPackageID, source.OuterPackageID, source.QuantityPerOuter, source.TypicalWeightPerUnit, source.LeadTimeDays, source.IsChillerStock, source.TaxRate, source.UnitPrice, 1) 
	OUTPUT deleted.*, $action, inserted.*;


DROP TABLE IF EXISTS #StockItem


--через XQuery


DECLARE @x XML
SET @x = ( 
  SELECT * FROM OPENROWSET
  (BULK 'D:\otus\11_StockItems-188-1fb5df.xml',
   SINGLE_CLOB) as d)

-- можно вставить результат в таблицу
DROP TABLE IF EXISTS #StockItem

CREATE TABLE #StockItem(
	[StockItemName]        nvarchar(100)  ,
	[SupplierID]           int            ,
	[UnitPackageID]        int            ,
	[OuterPackageID]       int            ,
	[QuantityPerOuter]     int            ,
	[TypicalWeightPerUnit] decimal(18,3)  ,
	[LeadTimeDays]         int            ,
	[IsChillerStock]       bit            ,
	[TaxRate]              decimal(18,3)  ,
	[UnitPrice]            decimal(18,2) 
)

INSERT INTO #StockItem
SELECT 
   @x.value('(/StockItems/Item/@Name)[1]', 'nvarchar(100)') as [StockItemName],
   @x.value('(/StockItems/Item/SupplierID)[1]', 'int') as [SupplierID],
   @x.value('(/StockItems/Item/Package/UnitPackageID)[1]', 'int') as [UnitPackageID],
   @x.value('(/StockItems/Item/Package/OuterPackageID)[1]', 'int') as [OuterPackageID],
   @x.value('(/StockItems/Item/Package/QuantityPerOuter)[1]', 'int') as [QuantityPerOuter],
   @x.value('(/StockItems/Item/Package/TypicalWeightPerUnit)[1]', 'decimal(18,3)') as [TypicalWeightPerUnit],
   @x.value('(/StockItems/Item/LeadTimeDays)[1]', 'int') as [LeadTimeDays],
   @x.value('(/StockItems/Item/IsChillerStock)[1]', 'bit') as [IsChillerStock],
   @x.value('(/StockItems/Item/TaxRate)[1]', 'decimal(18,3)') as [TaxRate],
   @x.value('(/StockItems/Item/UnitPrice)[1]', 'decimal(18,2)') as [UnitPrice]

 
MERGE Warehouse.StockItems AS target 
USING (SELECT *  FROM #StockItem 
		) 
		AS source  
		ON
	 (target.StockItemName = source.StockItemName COLLATE Latin1_General_100_CI_AS) 
	WHEN MATCHED 
		THEN UPDATE SET target.SupplierID = source.SupplierID,
						target.UnitPackageID = source.UnitPackageID,
						target.OuterPackageID = source.OuterPackageID,
						target.QuantityPerOuter = source.QuantityPerOuter,
						target.TypicalWeightPerUnit = source.TypicalWeightPerUnit,
						target.LeadTimeDays = source.LeadTimeDays,
						target.IsChillerStock = source.IsChillerStock,
						target.TaxRate = source.TaxRate,
						target.UnitPrice = source.UnitPrice
	WHEN NOT MATCHED 
		THEN INSERT (StockItemName, SupplierID, UnitPackageID, OuterPackageID, QuantityPerOuter, TypicalWeightPerUnit, LeadTimeDays, IsChillerStock, TaxRate, UnitPrice, [LastEditedBy]) 
		VALUES (source.StockItemName, source.SupplierID, source.UnitPackageID, source.OuterPackageID, source.QuantityPerOuter, source.TypicalWeightPerUnit, source.LeadTimeDays, source.IsChillerStock, source.TaxRate, source.UnitPrice, 1) 
	OUTPUT deleted.*, $action, inserted.*;


DROP TABLE IF EXISTS #StockItem


/*
2. Выгрузить данные из таблицы StockItems в такой же xml-файл, как StockItems.xml
*/

SELECT
    StockItemName AS [@Name],
    SupplierID AS [SupplierID],
    UnitPackageID AS [Package/UnitPackageID],
    OuterPackageID AS [Package/OuterPackageID],
    QuantityPerOuter AS [Package/QuantityPerOuter],
    TypicalWeightPerUnit AS [Package/TypicalWeightPerUnit],
    LeadTimeDays [LeadTimeDays],
    IsChillerStock AS [IsChillerStock],
	TaxRate AS [TaxRate],
	UnitPrice AS [UnitPrice]
FROM Warehouse.StockItems
WHERE Warehouse.StockItems.TaxRate = 20
FOR XML PATH('Item'), ROOT('StockItems')
GO


/*
3. В таблице Warehouse.StockItems в колонке CustomFields есть данные в JSON.
Написать SELECT для вывода:
- StockItemID
- StockItemName
- CountryOfManufacture (из CustomFields)
- FirstTag (из поля CustomFields, первое значение из массива Tags)
*/

SELECT StockItemID, StockItemName,
	JSON_VALUE(CustomFields, '$.CountryOfManufacture') as CountryOfManufacture,
	JSON_VALUE(CustomFields, '$.Tags[0]') as FirstTag
FROM Warehouse.StockItems

/*
4. Найти в StockItems строки, где есть тэг "Vintage".
Вывести: 
- StockItemID
- StockItemName
- (опционально) все теги (из CustomFields) через запятую в одном поле

Тэги искать в поле CustomFields, а не в Tags.
Запрос написать через функции работы с JSON.
Для поиска использовать равенство, использовать LIKE запрещено.

Должно быть в таком виде:
... where ... = 'Vintage'

Так принято не будет:
... where ... Tags like '%Vintage%'
... where ... CustomFields like '%Vintage%' 
*/


SELECT StockItemID, StockItemName--,
--CustomFields,
--JSON_VALUE(CustomFields, '$.CountryOfManufacture') as CountryOfManufacture,
--JSON_QUERY(CustomFields, '$.Tags') as Tag
FROM Warehouse.StockItems
CROSS APPLY OPENJSON(CustomFields, '$.Tags') tag
WHERE tag.value = 'Vintage'
