---------------------------------------------------------
--Запрос: составить список Клиентов, договоры с которыми заключил заданный сотрудник
---------------------------------------------------------

--Составной индекс
CREATE INDEX IX_Operator_Client
ON [dbo].[Contract] (OperatorID, ClientID)
GO


SELECT DISTINCT Cl.name
FROM Contract con
JOIN Client Cl ON con.ClientID = Cl.ClientID
WHERE con.OperatorID = 3


---------------------------------------------------------
--Запрос: Определить номера договоров и вид страхового продукта, заключенных заданным работником
---------------------------------------------------------
--CREATE INDEX IX_Operator_typeID
--ON [dbo].[Contract] (OperatorID, typeID)
--GO


SELECT con.number, ct.name
FROM Contract con
JOIN ContractType ct ON con.typeID = ct.typeID
WHERE con.OperatorID = 3


---------------------------------------------------------
--Запрос: Список Клиентов, у которых срок действия договора истекает в указанную дату
---------------------------------------------------------
CREATE INDEX IX_name
ON [dbo].[Client] (name)
GO

CREATE INDEX IX_enddate_Client
ON [dbo].[Contract] (enddate, ClientID)
GO

SELECT Cl.name
FROM Client Cl
JOIN  Contract con ON con.ClientID = Cl.ClientID
WHERE con.enddate = '20220715'


---------------------------------------------------------
--Запрос: Список Клиентов, сумма страхования у которых меньше указанной величины
---------------------------------------------------------

SELECT distinct Cl.name
FROM Contract con
JOIN Client Cl ON con.ClientID = Cl.ClientID
WHERE con.summa < 12000