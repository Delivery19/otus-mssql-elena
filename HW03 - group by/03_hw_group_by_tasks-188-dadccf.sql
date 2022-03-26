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
1. Посчитать среднюю цену товара, общую сумму продажи по месяцам
Вывести:
* Год продажи (например, 2015)
* Месяц продажи (например, 4)
* Средняя цена за месяц по всем товарам
* Общая сумма продаж за месяц

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

SELECT
	year(a.InvoiceDate) AS InvoiceDate_YY,
	month(a.InvoiceDate) AS InvoiceDate_MM,
	AVG(b.UnitPrice) AS UnitPrice_AVG,
	SUM(b.UnitPrice) AS UnitPrice_SUM
FROM Sales.Invoices a
JOIN Sales.InvoiceLines b ON a.InvoiceID = b.InvoiceID
GROUP BY year(a.InvoiceDate), month(a.InvoiceDate)
ORDER BY InvoiceDate_YY, InvoiceDate_MM


/*
2. Отобразить все месяцы, где общая сумма продаж превысила 10 000

Вывести:
* Год продажи (например, 2015)
* Месяц продажи (например, 4)
* Общая сумма продаж

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

SELECT
	year(a.InvoiceDate) AS InvoiceDate_YY,
	month(a.InvoiceDate) AS InvoiceDate_MM,
	SUM(b.UnitPrice) AS UnitPrice_SUM
FROM Sales.Invoices a
JOIN Sales.InvoiceLines b ON a.InvoiceID = b.InvoiceID
GROUP BY year(a.InvoiceDate), month(a.InvoiceDate)
HAVING SUM(b.UnitPrice) > 10000
ORDER BY InvoiceDate_YY, InvoiceDate_MM

/*
3. Вывести сумму продаж, дату первой продажи
и количество проданного по месяцам, по товарам,
продажи которых менее 50 ед в месяц.
Группировка должна быть по году,  месяцу, товару.

Вывести:
* Год продажи
* Месяц продажи
* Наименование товара
* Сумма продаж
* Дата первой продажи
* Количество проданного

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

SELECT
	year(a.InvoiceDate) AS InvoiceDate_YY,
	month(a.InvoiceDate) AS InvoiceDate_MM,
	b.Description,
	SUM(b.UnitPrice) AS UnitPrice_SUM,
	--a.InvoiceDate,
	SUM(b.Quantity) AS Quantity
FROM Sales.Invoices a
JOIN Sales.InvoiceLines b ON a.InvoiceID = b.InvoiceID
WHERE b.Quantity < 50
GROUP BY year(a.InvoiceDate), month(a.InvoiceDate), b.Description
ORDER BY InvoiceDate_YY, InvoiceDate_MM

-- ---------------------------------------------------------------------------
-- Опционально
-- ---------------------------------------------------------------------------
/*
Написать запросы 2-3 так, чтобы если в каком-то месяце не было продаж,
то этот месяц также отображался бы в результатах, но там были нули.
*/
