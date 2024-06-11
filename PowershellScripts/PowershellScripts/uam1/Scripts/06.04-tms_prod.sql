USE tms_prod
SELECT  
	sp3.name as "Grantee Login"
	,sp.name as Grantee
	,sp.[principal_id] as "Grantee Principal ID"
    ,CONVERT(NVARCHAR(max), sp.[sid], 1) as "Grantee SID"
    ,sp.[type_desc] as "Grantee Type"
    ,sp3.[is_disabled] as "Grantee Disabled"
    ,sl.denylogin as "Grantee Deny Login"
    ,sl.hasaccess as "Has Access"
    ,sp.[create_date] as "Grantee Create Date"
    ,sp.[modify_date] as "Account Modify Date"
    , LOGINPROPERTY(sp3.name,'PasswordLastSetTime') as "Account Last Password Change Date"
    ,CASE
		WHEN su.islogin = 0 THEN 'N\A - Role'
		WHEN su.[hasdbaccess] = 0 THEN 'No'
		WHEN su.[hasdbaccess] = 1 THEN 'Yes' END as "Has Database Access"
    ,database_permissions.permission_name as "Permission"
    ,database_permissions.state_desc as "Permission State"
    ,CASE
		WHEN class = 0 THEN DB_NAME() WHEN class = 1 
	then 
		case
			when minor_id = 0 then object_name(major_id) else (SELECT  object_name(object_id) + '.'+ name FROM sys.columns where object_id = database_permissions.major_id and column_id = database_permissions.minor_id) 
		end
		WHEN class = 3 THEN SCHEMA_NAME(major_id)
		WHEN class = 4 THEN USER_NAME(major_id) END [Securable]
     ,CASE
		When ((database_permissions.class= 1) AND (database_permissions.minor_id <> 0)) then 'Column'
		WHEN ((database_permissions.class= 1) AND (database_permissions.minor_id = 0)) then 'Object'
      else database_permissions.class_desc END "Securable Description"
FROM sys.database_permissions database_permissions, sys.sysusers as su, sys.database_principals as sp
	LEFT JOIN master.sys.syslogins as sl
		on (sp.sid = sl.sid)
    LEFT JOIN master.sys.server_principals as sp3
		on (sp.sid = sp3.sid)
WHERE 
	((sp.[principal_id] = database_permissions.grantee_principal_id)
	AND (sp.principal_id = su.uid));