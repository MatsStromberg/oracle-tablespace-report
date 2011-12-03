<!---
    Copyright (C) 2011 - Oracle Tablespace Report Project - http://www.network23.net
    
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
	
	The Oracle Tablespace Report do need an Oracle Grid Control 10g Repository
	(Copyright Oracle Inc.) since it will get some of it's data from the Grid 
	Repository.
    
    You should have received a copy of the GNU General Public License 
    along with the Oracle Tablespace Report.  If not, see 
    <http://www.gnu.org/licenses/>.
--->
<cfcomponent displayname="Application" output="false" hint="Application.cfc for OTR Tablespace Monitoring">

	<cfset this.name = "OTR_TABLESPACE_REPORT" />

	<cffunction name="onApplicationStart">
		<cfscript>
			Application.pw_hash = CreateObject("component", "otr.pw_hash");
		</cfscript>
		<!--- SQLNET.DEFAULT_DOMAIN for DB-Links --->
		<cfset Application.oracle.domain_name = "MBCZH.CH" />
		<!--- Datasource Settings --->
		<cfset Application.datasource = "OTR_OTRREP" />
		<cfset Application.dbusername = "OTRREP" />
		<cfset Application.dbpassword = "otrrep4otr" />
		<!--- MailServer Settings (Not used at the moment) --->
		<cfset Application.mailserver = "" />
		<cfset Application.mailport = "" />
		<cfset Application.mailtimout = "" />
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
		<cfset Application.excel_doc_info_title = "My Company Inc. - Tablespace Report" />
		<cfset Application.excel_doc_info_lastauthor = "ustr" />
		<!--- Snapshot Day / Sunday = 1 --->
		<cfset Application.snapshot_day = 6 /><!--- 6 = Friday --->
		<!--- General Application Settings --->
		<cfset Application.obd_host = "http://minerva/" />
		<cfset Application.obd_desktop_host = "http://localhost/" />
		<cfset Application.logo_image = "OTR_logo.gif" />
		<cfset Application.ogc_logon_url = "http://minerva:4889/em/console/logon/logon" />
		<cfset Application.ogc_external_table = "/orascripts/scripts/monitoring/xt/OGC2ICB" />
		<cfset Application.host_instance_pdf_dir = "/opt/pro/dir/ccr/oracle/" />
		<!--- SFTP Settings for the host of the GridControl Repository --->
		<cfset Application.sftpHost = "minerva.mbczh.ch">
		<cfset Application.sftpUser = "oracle">
		<cfset Application.sftpPass = "orambc">
		<!--- DOS2UNIX Executable for Windows and UNIX/Linux --->
		<cfset Application.UXdos2unix = "/usr/bin/dos2unix" />
		<cfset Application.WINdos2unix = "S:\wa\tools\sp\DOS2UNIX.EXE" />
		<!--- Some Windows versions of dos2unix can be found in the list below.
		      http://sourceforge.net/projects/dos2unix/
		      http://www.bastet.com/
		      http://waterlan.home.xs4all.nl/dos2unix.html
		--->
		<!--- Set Locale --->
		<cfset Application.locale_string = "German (Switzerland)" />
		<cfset dummy = SetLocale("#application.locale_string#") />
		<!--- Password Hash Key --->
		<cfset Application.system_pw_hash = "otrrep$system$hash" />
	</cffunction>

</cfcomponent>