---1 �������� ���� ������ �� ���������
/* ����� ��������� �� ���� �������*/
CREATE DATABASE Diploma;
GO

USE [Diploma]
GO

--������� �����������
CREATE TABLE [dbo].[Operator](
	[OperatorID] [decimal](18, 0) NOT NULL,
	[FIO] [nvarchar](50) NOT NULL,
	[Login] [nvarchar](50) NOT NULL,
	[position] [nvarchar](100) NULL,
	[department] [nvarchar](50) NULL,
 CONSTRAINT [PK_Operator] PRIMARY KEY CLUSTERED 
(
	[OperatorID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

--������� ��������
CREATE TABLE [dbo].[Client](
	[ClientID] [decimal](18, 0) NOT NULL,
	[name] [nvarchar](900) NOT NULL,
	[birthdate] [date] NOT NULL,
	[gender] [bit] NOT NULL,
	[email] [nvarchar](50) NULL,
	[INN] [nchar](15) NULL,
	[SNILS] [nchar](14) NULL,
 CONSTRAINT [PK_Clients] PRIMARY KEY CLUSTERED 
(
	[ClientID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

--������� ���������
CREATE TABLE [dbo].[PaspInfo](
	[number] [nchar](32) NULL,
	[OutDate] [date] NULL,
	[Code] [nchar](7) NULL,
	[Unavailable] [bit] NOT NULL,
	[Distrib] [nvarchar](220) NULL,
	[PaspInfoID] [decimal](18, 0) NOT NULL,
 CONSTRAINT [PK_PaspInfo] PRIMARY KEY CLUSTERED 
(
	[PaspInfoID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[PaspInfo]  WITH CHECK ADD  CONSTRAINT [FK_PaspInfo_PaspInfoID_Clients] FOREIGN KEY([PaspInfoID])
REFERENCES [dbo].[Client] ([ClientID])
GO

ALTER TABLE [dbo].[PaspInfo] CHECK CONSTRAINT [FK_PaspInfo_PaspInfoID_Clients]
GO

--============================
--Unavailable �� ��������� 0. �.�. �� ��������� ������� �����������
ALTER TABLE [dbo].[PaspInfo]
	ADD CONSTRAINT [DF_PaspInfo_Unavailable] DEFAULT((0)) FOR [Unavailable]
GO

--============================
--������� ����� ���������
CREATE TABLE [dbo].[ContractType](
	[typeID] [decimal](18, 0) NOT NULL,
	[name] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_ContractType] PRIMARY KEY CLUSTERED 
(
	[typeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

--������� ���������
CREATE TABLE [dbo].[Contract](
	[ContractID] [decimal](18, 0) NOT NULL,
	[opendate] [date] NOT NULL,
	[enddate] [date] NOT NULL,
	[closedate] [date] NULL,
	[typeID] [decimal](18, 0) NOT NULL,
	[ClientID] [decimal](18, 0) NOT NULL,
	[summa] [decimal](18, 2) NOT NULL,
	[OperatorID] [decimal](18, 0) NOT NULL,
	[number] [nchar](20) NULL,
 CONSTRAINT [PK_Contract] PRIMARY KEY CLUSTERED 
(
	[ContractID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Contract]  WITH CHECK ADD  CONSTRAINT [FK_Contract_ClientID_Clients] FOREIGN KEY([ClientID])
REFERENCES [dbo].[Client] ([ClientID])
GO

ALTER TABLE [dbo].[Contract] CHECK CONSTRAINT [FK_Contract_ClientID_Clients]
GO

ALTER TABLE [dbo].[Contract]  WITH CHECK ADD  CONSTRAINT [FK_Contract_OperatorID_Operator] FOREIGN KEY([OperatorID])
REFERENCES [dbo].[Operator] ([OperatorID])
GO

ALTER TABLE [dbo].[Contract] CHECK CONSTRAINT [FK_Contract_OperatorID_Operator]
GO

ALTER TABLE [dbo].[Contract]  WITH CHECK ADD  CONSTRAINT [FK_Contract_typeID_ContractType] FOREIGN KEY([typeID])
REFERENCES [dbo].[ContractType] ([typeID])
GO

ALTER TABLE [dbo].[Contract] CHECK CONSTRAINT [FK_Contract_typeID_ContractType]
GO

--���� � ������
--ALTER TABLE [dbo].[PaspInfo]  WITH CHECK ADD  CONSTRAINT [FK_PaspInfo_PaspInfoID_Clients] FOREIGN KEY([PaspInfoID])
--REFERENCES [dbo].[Client] ([ClientID])

--������������������ ��� ��������������
CREATE SEQUENCE ContractType_TypeID
  AS int
  START WITH 1
  INCREMENT BY 1
  MINVALUE 1
  MAXVALUE 2147483647
  CYCLE;
GO

SELECT NEXT VALUE FOR ContractType_TypeID;


--Declare 
--	@TypeId INT

--SET @TypeId = NEXT VALUE FOR ContractType_TypeID;

--INSERT INTO ContractType
--	(typeID, [name])
--VALUES
--	(@TypeId, '�����'),
--	(@TypeId, '�����'),
--	(@TypeId, '������������'),
--	(@TypeId, '��������'),
--	(@TypeId, '�������������');
--GO

INSERT INTO ContractType
	(typeID,[name])
VALUES
	(NEXT VALUE FOR ContractType_TypeID, '�����'),
	(NEXT VALUE FOR ContractType_TypeID, '�����'),
	(NEXT VALUE FOR ContractType_TypeID, '������������'),
	(NEXT VALUE FOR ContractType_TypeID, '��������'),
	(NEXT VALUE FOR ContractType_TypeID, '�������������');

SELECT * FROM ContractType

--==============================================
--������������������ ��� �����������
CREATE SEQUENCE Operator_OperatorID
  AS decimal(18,0)
  START WITH 1
  INCREMENT BY 1
  MINVALUE 1
  MAXVALUE 2147483647;
GO

--����������� �� ������������������ ��� ������� Operator
ALTER TABLE Operator
	ADD CONSTRAINT Cons_OperatorID DEFAULT (NEXT VALUE FOR Operator_OperatorID) FOR [OperatorID]
GO

insert into Operator
			(FIO
			,Login
			,position
			,department) 
values 
			('������� ����� ���������','semen','��������','����� ������'),
			('������ ���� ������','ivan','��������','���������'),
			('������ ���� ��������','petya','��������','����� ������'),
			('��������� ��������� ����������','valya','������� ��������','����� ������'),
			('����������� ����� ������������','olesya','����� ��������','����� ������'),
			('���������� �������� ������������','sveta','������������ ������ ������','����� ������');
GO

SELECT * FROM Operator

--==============================================
--������������������ ��� ��������
CREATE SEQUENCE Client_ClientID
  AS decimal(18,0)
  START WITH 1
  INCREMENT BY 1
  MINVALUE 1
  MAXVALUE 2147483647;
GO

--����������� �� ������������������ ��� ������� Operator
ALTER TABLE Client
	ADD CONSTRAINT Cons_ClientID DEFAULT (NEXT VALUE FOR Client_ClientID)  FOR [ClientID]
GO

--����������� �� ���
ALTER TABLE Client 
	ADD CONSTRAINT Cons_inn 
		CHECK (len(INN)<=15);


--�������� �������
insert into Client
			(name
			,birthdate
			,gender
			,email
			,INN
			,SNILS) 
values 
			('�������� ����� ����������','19970806','0','babochka@gmail.ru','16185295026',null),
			('�������� ���� �������','19780803','0','nick@yandex.ru','16598404391','845-385-946-04'),
			('�������� �������� ���������','19800303','1','rich@yandex.ru','16898404391','875-467-387 09'),
			('׸���� ��������� ����������','19991108','0','black@google.com','16599504391','940-275-073-87'),
			('�������� ����� ��������','19880621','1','mir@yandex.ru','165398404391','984-485-083 87'),
			('������ ����� ��������','19980403','1','white@gmail.com',null,null),
			('��������� �������� ����������','19880803','0','valya@yandex.ru','1698455591',null);
GO

SELECT * FROM Client

--==============================================
--������������������ ��� ���������
CREATE SEQUENCE Contract_ContractID
  AS decimal(18,0)
  START WITH 1
  INCREMENT BY 1
  MINVALUE 1
  MAXVALUE 2147483647;
GO

--����������� �� ������������������ ��� ������� Contract
ALTER TABLE Contract
	ADD CONSTRAINT Cons_ContractID DEFAULT (NEXT VALUE FOR Contract_ContractID) FOR [ContractID]
GO

--����������� ��� ������� Contract �� ���� ���������� �������� (������� �� ����� ����)
ALTER TABLE Contract
	ADD CONSTRAINT Cons_enddate CHECK ((enddate > opendate) AND datediff(dd, opendate, enddate)<366);
GO

--������ �� �������� � ������� ���������
create index idx_Client on Contract (ClientID);


--�������� ������� ���������
insert into Contract
			(opendate
			,enddate
			,closedate
			,typeID
			,ClientID
			,summa
			,OperatorID
			,number) 
values 
			('20200710','20210710','20210115',1,3,'12000',5,'Q123/2020'),
			('20220310','20220715',null,3,7,'12000.99',2,'T324/2022'),
			('20220410','20220715',null,4,6,'999.99',4,'kjw/2022'),
			('20220510','20220715',null,3,5,'70000',4,'987d3/2022'),
			('20220610','20220715',null,2,4,'122000',3,'4��983/2022'),
			('20210510','20220315',null,1,2,'43000',5,'4��983/2022'),
			('20210410','20220215',null,1,5,'2000',6,'4��983/2022'),
			('20210410','20220315','20220315',1,3,'4500',3,'4��983/2022'),
			('20210710','20220710',null,4,4,'23000',3,'4��9583/2022'),
			('20220810','20221215',null,1,2,'98000',3,'4��983/2022'),
			('20220210','20220715',null,5,7,'9000.45',3,'4��5983/2022'),
			('20220410','20220715',null,2,7,'12000.11',4,'4��9483/2020'),
			('20200210','20200615',null,1,6,'2000.50',4,'4��983/2020'),
			('20200310','20210215',null,4,2,'700',3,'4��983/2020'),
			('20200510','20210415',null,4,1,'16005.76',3,'4�e�983/2020'),
			('20200510','20200715',null,5,5,'15800.05',6,'4��983/2020');
GO

SELECT * FROM Operator
SELECT * FROM ContractType
SELECT * FROM Client
SELECT * FROM Contract