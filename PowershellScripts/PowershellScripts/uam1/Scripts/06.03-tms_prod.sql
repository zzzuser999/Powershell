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
		WHEN su.[hasdbaccess] = 1 THEN 'Yes'
	END as "Has Database Access"
    ,sp2.name as "Granted Role"
	,sp2.[principal_id] as "Role Principal ID"
    ,CONVERT(NVARCHAR(max), sp2.[sid], 1) as "Role SID"
    ,sp2.[create_date] as "Role Create Date"
    ,sp2.[modify_date] as "Role Modify Date"
FROM sys.database_role_members as srm, sys.database_principals as sp2, sys.sysusers as su, sys.database_principals as sp
	LEFT JOIN master.sys.syslogins as sl
		on (sp.sid = sl.sid)
    LEFT JOIN master.sys.server_principals as sp3
		on (sp.sid = sp3.sid)
WHERE 
	((sp.[principal_id] = srm.member_principal_id)
	AND (sp2.principal_id = srm.role_principal_id)
	AND (sp.principal_id = su.uid));
