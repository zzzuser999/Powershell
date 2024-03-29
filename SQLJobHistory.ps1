#--Security creation script for user nagios_reader
#--Created At: 20140602142030
#--Created By: EUROPE\plprdus
#--Add User To Database
#CREATE LOGIN [nagios_reader] WITH PASSWORD=N'imn4tyoXB9mn1afiMWiM', DEFAULT_DATABASE=[msdb], DEFAULT_LANGUAGE=[us_english], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF

#USE [msdb]
#EXEC [sp_grantdbaccess]
#	@loginame = 'nagios_reader',
#	@name_in_db = 'nagios_reader'
#GO
#--Add User To Roles
#GO
#--Set Object Specific Permissions
#GRANT
#	SELECT
#	ON [dbo].[sysjobs]
#	TO nagios_reader
#GO
#GRANT
#	SELECT
#	ON [dbo].[sysjobschedules]
#	TO nagios_reader
#GO
#GRANT
#	SELECT
#	ON [dbo].[sysjobhistory]
#	TO nagios_reader
#GO




$Servers = get-content "d:\ABBSoftware\Scripts\sqlserverlist.txt"
#$Servers = $env:computername

$Report = @()

foreach ($Server in $Servers)
{
$Connection = new-object system.data.sqlclient.sqlconnection
$Connection.ConnectionString ="server=$Server;database=msdb;User ID=nagios_reader; Password=gokQvQS0k9aBGyMwIp4s" 

$SqlCmd = New-Object System.Data.SqlClient.SqlCommand #setting object to use sql commands

$SqlQuery = @"
SELECT 
   @@SERVERNAME as [InstanceName]
    , [sJOB].[name] AS [JobName]
	, [sJOB].[enabled] AS [Enabled]
    , CASE 
        WHEN [sJOBH].[run_date] IS NULL OR [sJOBH].[run_time] IS NULL THEN NULL
        ELSE CAST(
                CAST([sJOBH].[run_date] AS CHAR(8))
                + ' ' 
                + STUFF(
                    STUFF(RIGHT('000000' + CAST([sJOBH].[run_time] AS VARCHAR(6)),  6)
                        , 3, 0, ':')
                    , 6, 0, ':')
                AS DATETIME)
      END AS [LastRunDateTime]
    , CASE [sJOBH].[run_status]
        WHEN 0 THEN 'Failed'
        WHEN 1 THEN 'Succeeded'
        WHEN 2 THEN 'Retry'
        WHEN 3 THEN 'Canceled'
        WHEN 4 THEN 'Running' -- In Progress
      END AS [LastRunStatus]
    , STUFF(
            STUFF(RIGHT('000000' + CAST([sJOBH].[run_duration] AS VARCHAR(6)),  6)
                , 3, 0, ':')
            , 6, 0, ':') 
        AS [LastRunDuration]
    , [sJOBH].[message] AS [LastRunStatusMessage]
    , CASE [sJOBSCH].[NextRunDate]
        WHEN 0 THEN NULL
        ELSE CAST(
                CAST([sJOBSCH].[NextRunDate] AS CHAR(8))
                + ' ' 
                + STUFF(
                    STUFF(RIGHT('000000' + CAST([sJOBSCH].[NextRunTime] AS VARCHAR(6)),  6)
                        , 3, 0, ':')
                    , 6, 0, ':')
                AS DATETIME)
      END AS [NextRunDateTime]
FROM 
    [msdb].[dbo].[sysjobs] AS [sJOB]
    LEFT JOIN (
                SELECT
                    [job_id]
                    , MIN([next_run_date]) AS [NextRunDate]
                    , MIN([next_run_time]) AS [NextRunTime]
                FROM [msdb].[dbo].[sysjobschedules]
                GROUP BY [job_id]
            ) AS [sJOBSCH]
        ON [sJOB].[job_id] = [sJOBSCH].[job_id]
    LEFT JOIN (
                SELECT 
                    [job_id]
                    , [run_date]
                    , [run_time]
                    , [run_status]
                    , [run_duration]
                    , [message]
                    , ROW_NUMBER() OVER (
                                            PARTITION BY [job_id] 
                                            ORDER BY [run_date] DESC, [run_time] DESC
                      ) AS RowNumber
                FROM [msdb].[dbo].[sysjobhistory]
                WHERE [step_id] = 0
            ) AS [sJOBH]
        ON [sJOB].[job_id] = [sJOBH].[job_id]
        AND [sJOBH].[RowNumber] = 1
ORDER BY [JobName]

"@

$Connection.open()
$SqlCmd.CommandText = $SqlQuery
$SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter
$SqlAdapter.SelectCommand = $SqlCmd
$SqlCmd.Connection = $Connection
$dt = New-Object System.Data.DataTable
$SqlAdapter.Fill($dt)
foreach ($row in $dt.rows)

{
$repl=$row.LastRunStatusMessage
$repl=[string]$repl
$repl=$repl.Replace("'","")
$query = "
INSERT INTO EventLogsRepository.dbo.SQLJobsHistory
  (
    [InstanceName]
   ,[JobName]
   ,[Enabled]
   ,[LastRunDateTime]
   ,[LastRunStatus]
   ,[LastRunDuration]
   ,[LastRunStatusMessage]
   ,[NextRunDateTime]
  ) VALUES ('" + $row.InstanceName + "','" + $row.JobName + "','" + $row.Enabled + "','" + $row.LastRunDateTime + "','" + $row.LastRunStatus + "','" + $row.LastRunDuration + "','" + $repl + "','" + $row.NextRunDateTime + "')"
Write-Host $query
$Conn = new-object system.data.sqlclient.sqlconnection
$Conn.ConnectionString ="server=xe-s-HFMDB01P.xe.abb.com\HFMPROD01,1433;database=EventLogsRepository;User ID=EventLogsRepository_prod_writer;password=zH6jx2nOGWGAxzonDfyA" 
$conn.Open()
$RunUpdate = New-Object System.Data.SqlClient.SqlCommand($query,$Conn)
$RunUpdate.ExecuteNonQuery() | out-null
$conn.Close()
}
$Connection.Close()
}
