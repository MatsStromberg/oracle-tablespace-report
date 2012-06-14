<!---
    Copyright (C) 2010-2012 - Oracle Tablespace Report Project - http://www.network23.net
    
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
	2012.05.20	mst	Application.tablespace.prc_used is not used anymore. 
					This value is picked up from the Targets Thresholds.
	2012.05.26	mst	Added setting for the Refresh Time on the Tablespace
					monitoring pane.
--->
<cfcomponent displayname="Application" output="false" hint="Application.cfc for OTR Tablespace Monitoring">

	<cfset this.name = "OTR_TABLESPACE_REPORT" />

	<cffunction name="onApplicationStart">
		<cfscript>
			Application.pw_hash = CreateObject("component", "otr.pw_hash");
		</cfscript>
		<!--- SQLNET.DEFAULT_DOMAIN for DB-Links --->
		<cfset Application.oracle.domain_name = "MYDOMAIN.CH" />
		<!--- Datasource Settings --->
		<cfset Application.datasource = "OTR_OTRREP" />
		<cfset Application.dbusername = "OTRREP" />
		<cfset Application.dbpassword = "otrrep4otr" />
		<!--- MailServer Settings --->
		<cfset Application.mailserver = "" />
		<cfset Application.mailport = "25" />
		<cfset Application.mailtimeout = "60" />
		<!--- Mail adress for DBA or DBA Group --->
		<cfset Application.dba_group_mail = "" />
		<!--- Company Settings --->
		<cfset Application.company = "My Company Inc." />
		<!--- Excel Document Info --->
		<!--- Forreign Characters for Excel
		      ß = chr(223)
			  å = chr(229)
			  ä = chr(228)
			  ö = chr(246)
			  Å = chr(197)
			  Ä = chr(196)
			  Ö = chr(214) --->
		<cfset Application.excel_doc_info_author = "Mats Str#chr(246)#mberg" />
		<cfset Application.excel_doc_info_subject = "Customer Tablspace Usage" />
		<cfset Application.excel_doc_info_title = Application.company & " - Tablespace Report" />
		<cfset Application.excel_doc_info_lastauthor = "mast" />
		<!--- Snapshot Day / Sunday = 1 --->
		<cfset Application.snapshot_day = 6 /><!--- 6 = Friday --->
		<!--- General Application Settings --->
		<cfset Application.obd_host = "http://minerva:8080/" />
		<cfset Application.obd_desktop_host = "http://localhost:8080/" />
		<cfset Application.logo_image = "OTR_logo.gif" />
		<cfset Application.ogc_logon_url = "https://minerva:7799/em/" />
		<cfset Application.ogc_external_table = "/orascripts/scripts/monitoring/xt/OTR" />
		<cfset Application.host_instance_pdf_dir = "/opt/OpenBD/tbsreports/" />
		<!--- Set Locale --->
		<cfset Application.locale_string = "German (Switzerland)" />
		<cfset dummy = SetLocale("#Application.locale_string#") />
		<!--- Password Hash Key --->
		<cfset Application.system_pw_hash = "otrrep$system$hash" />
		<!--- Tablespace Warning Levels --->
		<!--- <cfset Application.tablespace.prc_used = 98 /> --->
		<cfset Application.tablespace.mb_left = 1800 />
		<!--- Tablespace Monitoring Refresh, default 5 minute --->
		<cfset Application.monitoring_cycle = 5 />
	</cffunction>

</cfcomponent>
