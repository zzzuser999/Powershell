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
    ,srm.permission_name as "Granted Permission"
    ,srm.class_desc as "Securable Type"
    ,Case
		when srm.class = 101 Then SUSER_NAME(srm.major_id)
	END as "Securable"
    ,srm.state_desc as "State"
FROM master.sys.server_permissions as srm, master.sys.server_principals as sp
	LEFT JOIN master.sys.syslogins as sl
		on (sp.sid = sl.sid)
WHERE
	(sp.[principal_id] = srm.grantee_principal_id);
