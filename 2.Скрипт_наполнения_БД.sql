USE [lial_dbistt_3213E83F5A5938281]
GO

INSERT INTO [dbo].[AccPoint] ([code], [name]) VALUES 
  ('��-1', '��-1'),
  ('��-2', '��-2'),
  ('��-3', '��-3'),
  ('��-4', '��-4'),
  ('��-5', '��-5'),
  ('��-6', '��-6'),
  ('��-7', '��-7'),
  ('��-8', '��-8'),
  ('��-9', '��-9')
       
GO

INSERT INTO [dbo].[NetElem] ([code], [name]) VALUES 
  ('��-1', '��-1'),
  ('��-2', '��-2'),
  ('��-3', '��-3'),
  ('��-4', '��-4'),
  ('��-5', '��-5'),
  ('��-6', '��-6'),
  ('��-7', '��-7'),
  ('��-8', '��-8'),
  ('��-9', '��-9')
       
GO

INSERT INTO [dbo].[AccPoint2NetElementLink] ([accpoint_id], [netelem_id]) VALUES
  (1, 1),
  (2, 2),
  (3, 3),
  (4, 4),
  (5, 5),
  (6, 6),
  (7, 7),
  (8, 8),
  (9, 9)

GO


-- ���������������� ��������� ���������� ��� ������ ��1/��1.
INSERT INTO [dbo].[AccPointStatus] ([accpoint_id], [date], [status]) VALUES
  (1, '2017-02-01', 0),
  (1, '2017-02-10', 1),
  (1, '2017-02-20', 0)
GO

INSERT INTO [dbo].[NetElemStatus] ([netelem_id], [date], [status]) VALUES
  (1, '2017-02-01', 0),
  (1, '2017-03-01', 1),
  (1, '2017-04-01', 0)
GO

-- �������������� ��������� ���������� ��� ������ ��2/��2.
INSERT INTO [dbo].[AccPointStatus] ([accpoint_id], [date], [status]) VALUES
  (2, '2018-02-01', 0),
  (2, '2018-02-10', 1),
  (2, '2018-02-20', 0)
GO

INSERT INTO [dbo].[NetElemStatus] ([netelem_id], [date], [status]) VALUES
  (2, '2018-01-01', 0),
  (2, '2018-02-01', 1),
  (2, '2018-04-01', 0)
GO

-- �������������� ��������� ���������� ��� ������ ��3/��3 (������� - �������).
INSERT INTO [dbo].[AccPointStatus] ([accpoint_id], [date], [status]) VALUES
  (3, '2018-01-01', 0),
  (3, '2018-02-01', 1),
  (3, '2018-04-01', 0)
GO

INSERT INTO [dbo].[NetElemStatus] ([netelem_id], [date], [status]) VALUES
  (3, '2018-02-01', 0),
  (3, '2018-02-10', 1),
  (3, '2018-02-20', 0)
GO

-- �������������� ��������� ���������� ��� ������ ��4/��4 (������).
INSERT INTO [dbo].[AccPointStatus] ([accpoint_id], [date], [status]) VALUES
  (4, '2018-02-01', 0),
  (4, '2018-02-10', 1),
  (4, '2018-02-20', 0)
GO

INSERT INTO [dbo].[NetElemStatus] ([netelem_id], [date], [status]) VALUES
  (4, '2018-02-01', 0),
  (4, '2018-02-10', 1),
  (4, '2018-02-20', 0)
GO

-- �������� ���������� ������������ ������� ��� ��� ������ ��5/��5.
INSERT INTO [dbo].[AccPointStatus] ([accpoint_id], [date], [status]) VALUES
  (5, '2017-01-01', 0),
  (5, '2017-02-01', 1),
  (5, '2018-04-01', 0)
GO

INSERT INTO [dbo].[NetElemStatus] ([netelem_id], [date], [status]) VALUES
  (5, '2017-02-01', 0),
  (5, '2017-02-10', 1),
  (5, '2018-02-20', 0)
GO

-- �������� ���������� ������������ ������� ���� ��� ��� ������ ��6/��6.
INSERT INTO [dbo].[AccPointStatus] ([accpoint_id], [date], [status]) VALUES
  (6, '2017-01-01', 0),
  (6, '2017-02-01', 1),
  (6, '2019-04-01', 0)
GO

INSERT INTO [dbo].[NetElemStatus] ([netelem_id], [date], [status]) VALUES
  (6, '2017-02-01', 0),
  (6, '2017-02-10', 1),
  (6, '2019-02-20', 0)
GO

-- �������� ���������� ������������ ������� ���� ��� ��� ������ ��7/��7.
INSERT INTO [dbo].[AccPointStatus] ([accpoint_id], [date], [status]) VALUES
  (7, '2017-01-01', 0),
  (7, '2017-02-01', 1),
  (7, '2020-04-01', 0)
GO

INSERT INTO [dbo].[NetElemStatus] ([netelem_id], [date], [status]) VALUES
  (7, '2017-02-01', 0),
  (7, '2017-02-10', 1),
  (7, '2020-02-20', 0)
GO
