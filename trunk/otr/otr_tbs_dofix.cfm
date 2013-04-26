<!---
    Copyright (C) 2010-2013 - Oracle Tablespace Report Project - http://www.network23.net
    
    Contributing Developers:
    Mats Strömberg - ms@network23.net

    This file is part of the Oracle Tablespace Report.

    The Oracle Tablespace Report is free software: you can redistribute 
    it and/or modify it under the terms of the GNU General Public License 
    as published by the Free Software Foundation, either version 3 of the 
    License, or (at your option) any later version.

    The Oracle Tablespace Report is distributed in the hope that it will 
    be useful, but WITHOUT ANY WARRANTY; without even the implied warranty 
    of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU 
    General Public License for more details.
	
	The Oracle Tablespace Report do need an Oracle Enterprise
	Manager 10g or later Repository (Copyright Oracle Inc.)
	since it will get some of it's data from the EM Repository.
    
    You should have received a copy of the GNU General Public License 
    along with the Oracle Tablespace Report.  If not, see 
    <http://www.gnu.org/licenses/>.
--->
<!---
	Long over due Change Log
	2012.05.16	mst	Fixed adding and Increasing Tablespaces stored on ASM 
	2013.04.17	mst	Added SYSTEM Username
--->
<!--- Get the HashKey --->
<cfset sHashKey = Trim(Application.pw_hash.lookupKey()) />

<cfif IsDefined("URL.action")>
	<cfswitch expression="#URL.action#">
		<cfcase value="increase">
			<cfset dAddfile = 0 />
			<cfset dIncrease = 1 />
		</cfcase>
		<cfcase value="addfile">
			<cfset dAddfile = 1 />
			<cfset dIncrease = 0 />
		</cfcase>
		<cfdefaultcase>
			<cfset dAddfile = 0 />
			<cfset dIncrease = 0 />
		</cfdefaultcase>
	</cfswitch>
</cfif>
<cfif IsDefined("URL.SID") AND Trim(URL.SID) GT ""><cfset oraSID = Trim(URL.SID) /><cfelse>No SID passed<cfabort></cfif>
<cfif IsDefined("URL.TBS") AND Trim(URL.TBS) GT ""><cfset oraTBS = Trim(URL.TBS) /><cfelse>No Tablespace passed<cfabort></cfif>
<cfif IsDefined("URL.DBF") AND Trim(URL.DBF) GT ""><cfset oraDBF = Trim(URL.DBF) /><cfelse>No Filename passed<cfabort></cfif>
<cfif #URL.action# IS "increase">
	<cfif IsDefined("URL.CGT") AND Trim(URL.CGT) GT ""><cfset oraCGT = Trim(URL.CGT) /><cfelse>No Increase To passed<cfabort></cfif>
</cfif>
<cfif IsDefined("URL.BIGFILE") AND Trim(URL.BIGFILE) GT ""><cfset oraBIGFILE = Trim(URL.BIGFILE) /><cfelse>No info about BIGFILE passed<cfabort></cfif>

<!--- Get the System Password --->
<cfquery name="qInstances" datasource="#Application.datasource#">
	select db_name, system_username, system_password, db_host, db_port, db_asm, db_rac, db_servicename, db_blackout
	from otr_db 
	where UPPER(db_name) = '#Trim(UCase(oraSID))#'
	order by db_name
</cfquery>

<!--- If no password set, Abort --->
<cfif Trim(qInstances.system_password) IS "">
	No System PASSWORD defined<cfabort>
<cfelse>
	<cfset sPassword = Application.pw_hash.decryptOraPW(qInstances.system_password), Trim(sHashKey)) />
</cfif>

<!--- Get Listener Port --->
<cfif Trim(qInstances.db_port) IS "">
	<cfquery name="qPort" datasource="OTR_SYSMAN">
		select distinct b.property_value
		  from mgmt_target_properties a, mgmt_target_properties b
		 where a.target_guid = b.target_guid
		   and UPPER(a.property_value) = '#Trim(UCase(oraSID))#'
		   and b.property_name = 'Port';
	</cfquery>
	<cfset iPort = qPort.property_value />
<cfelse>
	<cfset iPort = qInstances.db_port />
</cfif>

<!--- Get Host server --->
<cfif Trim(qInstances.db_host) IS "" >
	<cfquery name="qHost" datasource="OTR_SYSMAN">
		select distinct b.property_value
		  from mgmt_target_properties a, mgmt_target_properties b
		 where a.target_guid = b.target_guid
		   and UPPER(a.property_value) = '#Trim(UCase(qInstances.db_name))#'
		   and b.property_name = 'MachineName'
	</cfquery>
	<cfset sHost = Trim(qHost.property_value) />
<cfelse>
	<cfset sHost = Trim(qInstances.db_host) />
</cfif>

<!--- Create Temporary Data Source --->
<cfset s = StructNew()>
<cfif qInstances.db_rac IS 1>
	<cfset s.hoststring   = "jdbc:oracle:thin:@#LCase(sHost)#:#iPort#/#UCase(qInstances.db_servicename)#" />
<cfelse>
	<cfset s.hoststring   = "jdbc:oracle:thin:@#LCase(sHost)#:#iPort#:#UCase(qInstances.db_name)#" />
</cfif>
<cfset s.drivername   = "oracle.jdbc.OracleDriver">
<cfset s.databasename = "#UCase(oraSID)#">
<cfset s.username     = "#UCase(Trim(qInstances.system_username))#">
<cfset s.password     = "#sPassword#">
<cfset s.port         = "#iPort#">

<cfif DataSourceIsValid("#UCase(oraSID)#temp")>
	<cfset DataSourceDelete( "#UCase(oraSID)#temp" )>
</cfif>
<cfif NOT DataSourceIsValid("#UCase(oraSID)#temp")>
	<cfset DataSourceCreate( "#UCase(oraSID)#temp", s )>
</cfif>

<cfif oraBIGFILE IS "YES">
	<cfif dAddFile IS 1>
		This is a BIGFILE Tablespace... You should only increase the "CAN GROW TO"
		<cfabort>
	</cfif>
	<cfquery name="qDBFinfo" datasource="#UCase(oraSID)#temp">
		select file_name, maxbytes/1024/1024 max_mb, user_bytes/1024/1024 used_mb 
		from dba_data_files
		where tablespace_name = '#oraTBS#'
		order by tablespace_name, relative_fno
	</cfquery>
	<cfset nNewSize = NumberFormat(qDBFinfo.max_mb + #oraCGT#, '999999999') />
	<cfif dIncrease IS 1>
		<cfquery name="qIncrease" datasource="#UCase(oraSID)#temp">
			ALTER TABLESPACE #oraTBS# AUTOEXTEND ON MAXSIZE #nNewSize#M
		</cfquery>
		<!--- <cfoutput>ALTER TABLESPACE #oraTBS# AUTOEXTEND ON MAXSIZE #nNewSize#M;</cfoutput> --->
	</cfif>
<cfelse>
	<cfif dIncrease IS 1>
		<cfquery name="qDBFinfo" datasource="#UCase(oraSID)#temp">
			select file_name, maxbytes/1024/1024 max_mb, user_bytes/1024/1024 used_mb 
			from dba_data_files
			where tablespace_name = '#oraTBS#'
			  and file_name = '<cfif qInstances.db_asm IS 1>+</cfif>#Trim(oraDBF)#'
			order by tablespace_name, relative_fno
		</cfquery>
		<cfset nNewSize = NumberFormat(qDBFinfo.max_mb + #oraCGT#,'9999999') />
		<cfif qInstances.db_asm IS 1>
			<cfquery name="qIncrease" datasource="#UCase(oraSID)#temp">
				ALTER DATABASE DATAFILE '+#Trim(oraDBF)#' AUTOEXTEND ON MAXSIZE #Int(nNewSize)#M
			</cfquery>
		<cfelse>
			<cfquery name="qIncrease" datasource="#UCase(oraSID)#temp">
				ALTER DATABASE DATAFILE '#oraDBF#' AUTOEXTEND ON MAXSIZE #Int(nNewSize)#M
			</cfquery>
		</cfif>
		<!--- <cfoutput>ALTER DATABASE DATAFILE '#oraDBF#' AUTOEXTEND ON MAXSIZE #nNewSize#M;</cfoutput> --->
	</cfif>
	<cfif dAddFile IS 1>
		<cfif qInstances.db_asm IS 1>
			<cfquery name="qAddFile" datasource="#UCase(oraSID)#temp">
				ALTER TABLESPACE "#oraTBS#" ADD DATAFILE '+#Trim(Left(oraDBF,Find("/",oraDBF,1)-1))#' SIZE 128M AUTOEXTEND ON NEXT 128M MAXSIZE 2048M
			</cfquery>
		<cfelse>
			<cfquery name="qAddFile" datasource="#UCase(oraSID)#temp">
				ALTER TABLESPACE "#oraTBS#" ADD DATAFILE '#oraDBF#' SIZE 128M AUTOEXTEND ON NEXT 128M MAXSIZE 2048M
			</cfquery>
		</cfif>
		<!--- <cfoutput>ALTER TABLESPACE "#oraTBS#" ADD DATAFILE '#oraDBF#' SIZE 100M AUTOEXTEND ON NEXT 128M MAXSIZE 2000M;</cfoutput> --->
	</cfif>
</cfif>

<cfif DataSourceIsValid("#UCase(oraSID)#temp")>
	<cfset DataSourceDelete( "#UCase(oraSID)#temp" )>
</cfif>
<!--- Send E-Mail to the DBA Group --->
<cfif Application.mailserver IS NOT "">
	<cfmail from="#Application.dba_group_mail#" 
			to="#Application.dba_group_mail#" 
			subject="Tablespace #oraTBS# on #UCase(oraSID)# just got another #oraCGT# MB!" 
			server="#Application.mailserver#" 
			port="#Application.mailport#" 
			timeout="#Application.mailtimeout#" 
			type="html">
				<html>
				<head><title>TABLESPACE ADJUSTED</title></head>
				<body>
					Tablespace <strong>#oraTBS#<cfif oraBIGFILE IS "MO"> File: <cfif qInstances.db_asm IS 1>+</cfif>#Trim(oraDBF)#</cfif></strong> on Instance <strong>#UCase(oraSID)#</strong> was
					just extended with #oraCGT# MB more.<br />
					<strong>#UCase(oraSID)#</strong> is located on host <strong>#LCase(sHost)#</strong><br />
					Please make sure there is enough storage space available for this
					tablespace to grow.
				</body>
				</html>
	</cfmail>
</cfif>
<cflocation url="/otr/index.cfm" addtoken="No" />