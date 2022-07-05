---------------------------------------------------------
--������: ��������� ������ ��������, �������� � �������� �������� �������� ���������
---------------------------------------------------------

--��������� ������
CREATE INDEX IX_Operator_Client
ON [dbo].[Contract] (OperatorID, ClientID)
GO


SELECT DISTINCT Cl.name
FROM Contract con
JOIN Client Cl ON con.ClientID = Cl.ClientID
WHERE con.OperatorID = 3


---------------------------------------------------------
--������: ���������� ������ ��������� � ��� ���������� ��������, ����������� �������� ����������
---------------------------------------------------------
--CREATE INDEX IX_Operator_typeID
--ON [dbo].[Contract] (OperatorID, typeID)
--GO


SELECT con.number, ct.name
FROM Contract con
JOIN ContractType ct ON con.typeID = ct.typeID
WHERE con.OperatorID = 3


---------------------------------------------------------
--������: ������ ��������, � ������� ���� �������� �������� �������� � ��������� ����
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
--������: ������ ��������, ����� ����������� � ������� ������ ��������� ��������
---------------------------------------------------------

SELECT distinct Cl.name
FROM Contract con
JOIN Client Cl ON con.ClientID = Cl.ClientID
WHERE con.summa < 12000