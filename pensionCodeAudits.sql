--Audit file

--This will extract a file that will show employees whose comps are;

--have a pension code is Blank 
--have a pension code is not equal to 99
--the comp is a payout

select 
	distinct
	pye.LastName + ', ' + pye.FirstName + ' ' + (case when isnull(pye.MiddleName, '') = '' then '' else pye.MiddleName + '. ' end) 
	+ ' | PensionCode: ' + pyc.PensionCode
	+ ' | Position: ' + pyp.[Description]
	+ ' | Comp Type: ' + pyct.[Description]
	+ ' | Amount: ' + cast(pyc.Amount as varchar) as 'Description',
	pye.Id as 'Id'
from PyEmployee pye
inner join
	PyCompensation pyc
	on pye.Id = pyc.PyEmployeeId
	and pye.PayrollRunId = (select Id from PayrollRun where [Description] = 'DEC 2018' )
	and (pyc.PensionCode = isnull(pyc.PensionCode, '') or pyc.PensionCode != '99')
inner join
	DS_Global..PyCompensationType pyct
	on pyc.PyCompensationTypeId = pyct.Id
	and pyct.Id in (350, 351)
inner join
	PyPosition pyp
	on pyc.PyPositionId = pyp.Id
order by 	
	pye.LastName + ', ' + pye.FirstName + ' ' + (case when isnull(pye.MiddleName, '') = '' then '' else pye.MiddleName + '. ' end) 
	+ ' | PensionCode: ' + pyc.PensionCode
	+ ' | Position: ' + pyp.[Description]
	+ ' | Comp Type: ' + pyct.[Description]
	+ ' | Amount: ' + cast(pyc.Amount as varchar) asc


-- insert the audit
DECLARE @id int --Max ID + 1
DECLARE @Grouping varchar(50)--Audit Grouping (ex. PayrollNet, PayrollGross,PERS,GL)
DECLARE @Description varchar(50)--Audit Description
DECLARE @SQL varchar(5000)--Set SQL Statement here
DECLARE @Severity int --1 is High, 2 is Medium , 3 is Low
SET @id = (Select max(id) + 1  from ds_global..Audit)
SET @Grouping = 'PayrollNet'
SET @Description = 'Payout Transaction Reportable to Retirement with Pension Code not blank or equal to 99'
SET @SQL = 'select 
		pye.LastName + '', '' + pye.FirstName + '' '' + (case when isnull(pye.MiddleName, '''') = '''' then '''' else pye.MiddleName + ''. '' end) 
		+ '' | PensionCode: '' + pyc.PensionCode
		+ '' | Position: '' + pyp.[Description]
		+ '' | Comp Type: '' + pyct.[Description]
		+ '' | Amount: '' + cast(pyc.Amount as varchar) as ''Description'',
		pye.Id as ''Id''
	from PyEmployee pye
	inner join
		PyCompensation pyc
		on pye.Id = pyc.PyEmployeeId
		and pye.PayrollRunId = @0
		and (pyc.PensionCode = isnull(pyc.PensionCode, '''') or pyc.PensionCode != ''99'')
	inner join
		DS_Global..PyCompensationType pyct
		on pyc.PyCompensationTypeId = pyct.Id
		and pyct.Id in (350, 351)
	inner join
		PyPosition pyp
		on pyc.PyPositionId = pyp.Id
	order by 	
		pye.LastName + '', '' + pye.FirstName + '' '' + (case when isnull(pye.MiddleName, '''') = '''' then '''' else pye.MiddleName + ''. '' end) 
		+ '' | PensionCode: '' + pyc.PensionCode
		+ '' | Position: '' + pyp.[Description]
		+ '' | Comp Type: '' + pyct.[Description]
		+ '' | Amount: '' + cast(pyc.Amount as varchar) asc'
SET @Severity = 2
INSERT INTO ds_global..Audit(id,grouping,description,sql,Severity,isForClient)
SELECT @id,@grouping,@description,@sql,@severity,1

select top 1 *
from DS_Global..[Audit]
order by id desc