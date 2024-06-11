USE master
SELECT
	sp.name as Grantee
	,sp.[principal_id] as "Grantee Principal ID"
	,CONVERT(NVARCHAR(max), sp.[sid], 1) as "Grantee SID"
    ,sp.[type_desc] as "Grantee Type"
    ,sp.[is_disabled] as "Grantee Disabled"
    ,sl.denylogin as "Grantee Deny Login"
    ,sl.hasaccess as "Has Access"
    ,sp.[create_date] as "Grantee Create Date"
    ,sp.[modify_date] as "Account Modify Date"
    ,LOGINPROPERTY(sp.name,'PasswordLastSetTime') as "Account Last Password Change Date"
    ,sp.[default_database_name] as "Grantee Default Database"
    ,sp2.name as "Granted Role"
	,sp2.[principal_id] as "Role Principal ID"
    ,CONVERT(NVARCHAR(max), sp2.[sid], 1) as "Role SID"
    ,sp2.[create_date] as "Role Create Date"
    ,sp2.[modify_date] as "Role Modify Date"
FROM master.sys.server_role_members as srm, master.sys.server_principals as sp2, master.sys.server_principals as sp
	LEFT JOIN master.sys.syslogins as sl
       on (sp.sid = sl.sid)
WHERE 
	((sp.[principal_id] = srm.member_principal_id)
	AND (sp2.principal_id = srm.role_principal_id));
