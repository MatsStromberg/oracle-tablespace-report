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
	2012.05.18	mst	Updating Target DB's with Warning and Critical Thresholds
					set by the CSV or the Excel sheet.
					Deleteing all Thresholds on the Target that has the same 
					value as the Instance Default values.
	2013.04.17	mst	Added SYSTEM Username
--->
<cfsetting enablecfoutputonly="true" />
<!--- Get the HashKey --->
<cfset sHashKey = Trim(Application.pw_hash.lookupKey()) />

<cfset cDirSep = FileSeparator() />
<cfset bExcel = 0>
<cfset sPath = GetDirectoryfrompath(GetBasetemplatePath()) />
<!--- <cfif cDirSep IS "/"> --->
	<cfif Trim(FORM.file_type) IS "xls">
		<cfset sFile = '#sPath##cDirSep#OTR_CUST_APPL_TBS.xls' />
		<cfset bExcel = 1>
	<cfelseif Trim(FORM.file_type) IS "xlsx">
		<cfset sFile = '#sPath##cDirSep#OTR_CUST_APPL_TBS.xlsx' />
		<cfset bExcel = 1>
	<cfelse>
		<cfset sFile = '#sPath##cDirSep#OTR_CUST_APPL_TBS.csv' />
		<cfset bExcel = 0>
	</cfif>
<!--- <cfelse>
	<cfif Trim(FORM.file_type) IS "xls">
		<cfset sFile = '#sPath##cDirSep#OTR_CUST_APPL_TBS.xls' />
		<cfset bExcel = 1>
	<cfelseif Trim(FORM.file_type) IS "xlsx">
		<cfset sFile = '#sPath##cDirSep#OTR_CUST_APPL_TBS.xlsx' />
		<cfset bExcel = 1>
	<cfelse>
		<cfset sFile = '#sPath##cDirSep#OTR_CUST_APPL_TBS.csv' />
		<cfset bExcel = 0>
	</cfif>
</cfif> --->
<cfsetting enablecfoutputonly="true" />
<!--- 
<cfoutput>
#sPath#<br />#sFile#<br />#bExcel#
</cfoutput>
 --->

<cfset args = {
	destination : "#sFile#",
	filefield : "file_name",
	nameconflict : "overwrite"
	} />

<cfset x = StructNew()>
<cfset x = FileUpload(ArgumentCollection = args) />
<!--- If we're on UNIX/Linux set the access mode on the target file to 777 --->
<!--- <cfif cDirSep IS "/"><cfset x2 = FileSetAccessmode(#sFile#, 777) /></cfif> --->

<!--- Is this an Excel or a CSV File? BEGIN --->
<cfif bExcel IS 1>
	<!--- It's an Excel File --->
	<cfset iRow = 1 />
	<cfset iCol = 1 />
	<cfset bDone = 1 />
	<cfset qExcel = QueryNew("field1, field2, field3, field4, field5, field6")>
	<cftry>
		<!--- Create en Excel Object and read the Excel doscument into a Query Object --->
		<cfset xlsObj = SpreadsheetRead('#sFile#',0) />
		<cfset bDummy = IsSpreadsheetobject(xlsObj) />
		<cfloop condition="bDone EQUAL 1">
			<cfset newRow = QueryAddRow(qExcel, 1)>
			<cfloop from="1" to="6" index="iCol">
				<cfset sVal = SpreadsheetGetcellvalue(xlsObj, iRow, iCol) />
				<cfif Trim(sVal) IS NOT "" or sVal IS NOT NULL>
					<cfif Trim(sVal) IS ""><cfbreak></cfif>
					<cfset dummy = QuerySetCell(qExcel, "field#iCol#", "#sVal#", iRow) />
				</cfif>
			</cfloop>
			<cfif Trim(sVal) IS ""><cfset bDone = 0 /></cfif>
			<!--- <cfif Trim(sVal) IS NOT "" OR bDone IS 1><cfset newRow = QueryAddRow(qExcel, 1)></cfif>--->
			<cfif bDone IS 0><cfbreak><cfelse><cfset iRow = iRow + 1 /></cfif>
		</cfloop>

		<!--- Delete Content in the OTR_CUST_APPL_TBS table --->
		<cfquery name="qDeleteTBS" datasource="#Application.datasource#">
			delete from OTR_CUST_APPL_TBS
		</cfquery>
		<!--- Load the OTR_CUST_APPL_TBS Table from Excel --->
		<cfloop query="qExcel">
			<cfif Trim(qExcel.field1) IS NOT "">
				<cfquery name="qTBSload" datasource="#Application.datasource#">
					insert into OTR_CUST_APPL_TBS
						(CUST_ID, CUST_APPL_ID, DB_NAME, DB_TBS_NAME, THRESHOLD_WARNING, THRESHOLD_CRITICAL)
					values ('#Trim(qExcel.field1)#','#Trim(qExcel.field2)#','#Trim(qExcel.field3)#','#Trim(qExcel.field4)#',#Int(qExcel.field5)#,#Int(qExcel.field6)#)
				</cfquery>
			</cfif>
		</cfloop>
		<!--- Delete the .xls File --->
		<cfset b = FileDelete('#sFile#') />

		<cfcatch type="any">
			<cfdump var="#cfcatch#">
			<cfdump var="#xlsObj#">
		</cfcatch>
	</cftry>
<cfelse>
	<!--- It's a CSV File --->
	<cftry>
		<cfset sCSVfile = FileRead(#sFile#) />
		<cfset args = {
			string	: "#sCSVfile#",
			headerline : false,
			delimiter : ";"
		} />
		<cfset qCSV = csvread(ArgumentCollection = args) />

		<!--- Delete Content in the OTR_CUST_APPL_TBS table --->
		<cfquery name="qDeleteTBS" datasource="#Application.datasource#">
			delete from OTR_CUST_APPL_TBS
		</cfquery>
		<!--- Load the OTR_CUST_APPL_TBS Table from Excel --->
		<cfloop query="qCSV">
			<cfif Trim(qCSV.Column1) IS NOT "">
				<cfquery name="qTBSload" datasource="#Application.datasource#">
					insert into OTR_CUST_APPL_TBS
						(CUST_ID, CUST_APPL_ID, DB_NAME, DB_TBS_NAME, THRESHOLD_WARNING, THRESHOLD_CRITICAL)
					values ('#Trim(qCSV.Column1)#','#Trim(qCSV.Column2)#','#Trim(qCSV.Column3)#','#Trim(qCSV.Column4)#',#Int(qCSV.Column5)#,#Int(qCSV.Column6)#)
				</cfquery>
			</cfif>
		</cfloop>
		<!--- Delete the .csv File --->
		<cfset b = FileDelete('#sFile#') />

		<cfcatch type="any">
			<cfdump var="#cfcatch#">
			<!--- <cfdump var="#xlsObj#"> --->
		</cfcatch>
	</cftry>
</cfif>
<!--- Is this an Excel or a CSV File ?? END --->

<!--- Update Target Thresholds with the current values from OTR_CUST_APPL_TBS --->
<!--- 
For Decode Purpose....
-- operator types
OPERATOR_GT           CONSTANT BINARY_INTEGER := 0;
OPERATOR_EQ           CONSTANT BINARY_INTEGER := 1;
OPERATOR_LT           CONSTANT BINARY_INTEGER := 2;
OPERATOR_LE           CONSTANT BINARY_INTEGER := 3;
OPERATOR_GE           CONSTANT BINARY_INTEGER := 4;
OPERATOR_CONTAINS     CONSTANT BINARY_INTEGER := 5;
OPERATOR_NE           CONSTANT BINARY_INTEGER := 6;
OPERATOR_DO_NOT_CHECK CONSTANT BINARY_INTEGER := 7;

-- object types
OBJECT_TYPE_SYSTEM       CONSTANT BINARY_INTEGER := 1;
OBJECT_TYPE_FILE         CONSTANT BINARY_INTEGER := 2;
OBJECT_TYPE_SERVICE      CONSTANT BINARY_INTEGER := 3;
OBJECT_TYPE_EVENT_CLASS  CONSTANT BINARY_INTEGER := 4;
OBJECT_TYPE_TABLESPACE   CONSTANT BINARY_INTEGER := 5;
OBJECT_TYPE_SESSION      CONSTANT BINARY_INTEGER := 9;
OBJECT_TYPE_WRCLIENT     CONSTANT BINARY_INTEGER := 16;

-- message levels
SUBTYPE SEVERITY_LEVEL_T IS PLS_INTEGER;
LEVEL_CRITICAL      CONSTANT PLS_INTEGER := 1;
LEVEL_WARNING       CONSTANT PLS_INTEGER := 5;
LEVEL_CLEAR         CONSTANT PLS_INTEGER := 32;

-- metrics names
...
TABLESPACE_PCT_FULL      CONSTANT BINARY_INTEGER := 9000;
TABLESPACE_BYT_FREE      CONSTANT BINARY_INTEGER := 9001;
...

BEGIN
DBMS_SERVER_ALERT.SET_THRESHOLD(
   metrics_id              => DBMS_SERVER_ALERT.TABLESPACE_BYT_FREE,
   warning_operator        => DBMS_SERVER_ALERT.OPERATOR_LE,
   warning_value           => '10240',
   critical_operator       => DBMS_SERVER_ALERT.OPERATOR_LE,
   critical_value          => '2048',
   observation_period      => 1,
   consecutive_occurrences => 1,
   instance_name           => NULL,
   object_type             => DBMS_SERVER_ALERT.OBJECT_TYPE_TABLESPACE,
   object_name             => 'USERS');

DBMS_SERVER_ALERT.SET_THRESHOLD(
   metrics_id              => DBMS_SERVER_ALERT.TABLESPACE_PCT_FULL,
   warning_operator        => DBMS_SERVER_ALERT.OPERATOR_GT,
   warning_value           => '0',
   critical_operator       => DBMS_SERVER_ALERT.OPERATOR_GT,
   critical_value          => '0',
   observation_period      => 1,
   consecutive_occurrences => 1,
   instance_name           => NULL,
   object_type             => DBMS_SERVER_ALERT.OBJECT_TYPE_TABLESPACE,
   object_name             => 'USERS');
END;
/

Set Threshold
BEGIN DBMS_SERVER_ALERT.SET_THRESHOLD(9000,4,'85',4,'97',1,1,NULL,5,'OTR_REP_DATA'); END;
/

Delete Threshold
BEGIN DBMS_SERVER_ALERT.SET_THRESHOLD(9000,NULL,NULL,NULL,NULL,1,1,NULL,5,'OTR_REP_DATA'); END;
/

--->
<cfquery name="qInstances" datasource="#Application.datasource#">
	select db_name, system_username, system_password, db_host, db_port, db_rac, db_servicename
	  from otr_db
	 where db_blackout = 0
	 order by db_name
</cfquery>

<cfoutput query="qInstances">
	<cftry>
		<cfif Trim(qInstances.db_port) IS "">
			<!--- Get Listener Port from EM --->
			<cfquery name="qPort" datasource="OTR_SYSMAN">
				select distinct b.property_value
				from mgmt_target_properties a, mgmt_target_properties b
				where a.target_guid = b.target_guid
				and   UPPER(a.property_value) = '#Trim(UCase(qInstances.db_name))#'
				and   b.property_name = 'Port'
			</cfquery>
			<cfset iPort = qPort.property_value />
		<cfelse>
			<cfset iPort = qInstances.db_port />
		</cfif>

		<cfif Trim(qInstances.db_host) IS "" >
			<!--- Get Host server from EM --->
			<cfquery name="qHost" datasource="OTR_SYSMAN">
				select distinct b.property_value
				from mgmt_target_properties a, mgmt_target_properties b
				where a.target_guid = b.target_guid
				and   UPPER(a.property_value) = '#Trim(UCase(qInstances.db_name))#'
				and   b.property_name = 'MachineName'
			</cfquery>
			<cfset sHost = Trim(qHost.property_value) />
		<cfelse>
			<cfset sHost = Trim(qInstances.db_host) />
		</cfif>

		<!--- Decrypt the SYSTEM Password --->
		<cfset sPassword = Application.pw_hash.decryptOraPW(Trim(qInstances.system_password), Trim(sHashKey)) />
		<!--- Create Temporary Data Source --->
		<cfset s = StructNew() />
		<cfif qInstances.db_rac IS 1>
			<cfset s.hoststring   = "jdbc:oracle:thin:@#LCase(sHost)#:#iPort#/#UCase(qInstances.db_servicename)#" />
		<cfelse>
			<cfset s.hoststring   = "jdbc:oracle:thin:@#LCase(sHost)#:#iPort#:#UCase(qInstances.db_name)#" />
		</cfif>
		<cfset s.drivername   = "oracle.jdbc.OracleDriver" />
		<cfset s.databasename = "#UCase(qInstances.db_name)#" />
		<cfset s.username     = "#UCase(qInstances.system_username)#" />
		<cfset s.password     = "#sPassword#" />
		<cfset s.port         = "#iPort#" />

		<cfif DataSourceIsValid("#UCase(qInstances.db_name)#temp")>
			<cfset DataSourceDelete("#UCase(qInstances.db_name)#temp") />
		</cfif>
		<cfif NOT DataSourceIsValid("#UCase(qInstances.db_name)#temp")>
			<cfset DataSourceCreate("#UCase(qInstances.db_name)#temp", s) />
		</cfif>

		<cfquery name="qTBSthreshold" datasource="#Application.datasource#">
			select db_name, db_tbs_name, threshold_warning, threshold_critical
			  from OTR_CUST_APPL_TBS
			 where db_name = '#UCase(qInstances.db_name)#'
			 order by db_name, db_tbs_name
		</cfquery>
		<!---
		DBMS_SERVER_ALERT.SET_THRESHOLD(arguments...)
		Param 1:	9000 = 	DBMS_SERVER_ALERT.TABLESPACE_PCT_FULL
		Param 2:	4 =		DBMS_SERVER_ALERT.OPERATOR_GE
		Param 3:	=		Warning Threshhold
		Param 4:	4 =		DBMS_SERVER_ALERT.OPERATOR_GE
		Param 5:	=		Critical Threshold
		Param 6:	1 = 	obervation_period
		Param 7:	1 =		consecutive_occurrences
		Param 8:	NULL	Instance Name
		Param 9:	5 = 	DBMS_SERVER_ALERT.OBJECT_TYPE_TABLESPACE
		Param 10:	=		TABLSPACE_NAME
		--->
		<cfloop query="qTBSthreshold">
			<cfquery name="qUpdateThresholds" datasource="#UCase(qInstances.db_name)#temp">
				BEGIN DBMS_SERVER_ALERT.SET_THRESHOLD(<cfoutput>9000,4,'#qTBSthreshold.threshold_warning#',4,'#qTBSthreshold.threshold_critical#',1,1,NULL,5,'#qTBSthreshold.db_tbs_name#'</cfoutput>); END;
			</cfquery>
		</cfloop>
		<!--- Lookup Default Threshold --->
		<cfquery name="qTHdefault" datasource="#UCase(qInstances.db_name)#temp">
			select warning_value, critical_value
			 from sys.dba_thresholds
			where metrics_name = 'Tablespace Space Usage'
			  and nvl(object_name,'-OTR-TBS-') = '-OTR-TBS-'
		</cfquery>
		<!--- Lookup all none-default Thresholds --->	
		<cfquery name="qTHnonedefault" datasource="#UCase(qInstances.db_name)#temp">
			select warning_value, critical_value, object_name
			 from sys.dba_thresholds
			where metrics_name like '%Tablespace Space Usage'
			  and nvl(object_name,'-OTR-TBS-') <> '-OTR-TBS-'
		</cfquery>
		<!--- Delete Thresholds for tablespaces that have the default values --->
		<cfloop query="qTHnonedefault">
			<cfif qTHnonedefault.warning_value IS qTHdefault.warning_value AND qTHnonedefault.critical_value IS qTHdefault.critical_value>
				<cfquery name="qDeleteThresholds" datasource="#UCase(qInstances.db_name)#temp">
					BEGIN DBMS_SERVER_ALERT.SET_THRESHOLD(9000,NULL,NULL,NULL,NULL,1,1,NULL,5,'<cfoutput>#qTHnonedefault.object_name#</cfoutput>'); END;
				</cfquery>
			</cfif>
		</cfloop>

		<cfcatch type="Database">
			<cfif DataSourceIsValid("#UCase(qInstances.db_name)#temp")>
				<cfset DataSourceDelete("#UCase(qInstances.db_name)#temp") />
			</cfif>
		</cfcatch>
	</cftry>
	<cfif DataSourceIsValid("#UCase(qInstances.db_name)#temp")>
		<cfset DataSourceDelete("#UCase(qInstances.db_name)#temp") />
	</cfif>
</cfoutput>
<cflocation url="otr_tbs.cfm" addtoken="No">
