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
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"><cfprocessingdirective suppresswhitespace="Yes"><cfsetting enablecfoutputonly="true">
<cfset cDirSep = FileSeparator() />
<cfset sPath = ExpandPath('/') />
<cfset sTemplatePath = GetDirectoryfrompath(GetBasetemplatePath()) />
<!--- Does the file exist ? If not it's a new Setup --->
<cfif cDirSep IS "/">
	<cfset sFileCheck = #Application.ogc_external_table# & #cDirSep# & "OTR_CUST_APPL_TBS_XT.DAT" />
<cfelse>
	<cfset sFileCheck = #sTemplatePath# & #cDirSep# & "OTR_CUST_APPL_TBS_XT.DAT" />
</cfif>
<!--- Create a new OTR_CUST_APPL_TBS_XT.DAT if it doesn't exists --->
<cfif NOT FileExists(sFileCheck)>
	<cfquery name="qAllDBs" datasource="#Application.datasource#">
		select * from otr_db
		 order by db_name
	</cfquery>
	<cfquery name="qGetCustomer" datasource="#Application.datasource#">
		select cust_id from otr_cust
		 order by cust_id
	</cfquery>
	<!--- Change the file extention from .xls to .tmp and generate the CSV File --->
	<cfset oFile = FileOpen(ReplaceNoCase(sFileCheck, ".DAT", ".tmp", "ALL"),"write")>
	<cfoutput query="qAllDBs">
		<cfif Trim(qAllDBs.db_name) IS NOT ""><cfset sDummy = FileWriteline(oFile, "#Trim(qGetCustomer.cust_id)#;#Trim(qAllDBs.db_desc)#;#Trim(qAllDBs.db_name)#;NOT DEFINED")></cfif>
	</cfoutput>
	<cfset bDummy = FileClose(oFile)>
	<!--- Make sure the file is in UNIX Format --->
	<cfif cDirSep IS "/"><cfexecute name="#Application.UXdos2unix#" arguments="#ReplaceNoCase(sFileCheck, ".DAT", ".tmp", "ALL")#" timeout="10"></cfexecute></cfif>
	<cfif cDirSep IS "\"><cfexecute name="#Application.WINdos2unix#" arguments="#ReplaceNoCase(sFileCheck, ".DAT", ".tmp", "ALL")#" timeout="10"></cfexecute></cfif>
	<!--- Use SFTP to transfer the, uploaded or generated from .xls, CSV File under user Oracle and with extention .DAT
	      This is used as an External Table in Oracle. --->
	<cfscript>
	    fso = CreateObject("java", "org.apache.commons.vfs.FileSystemOptions").init(); 
	    CreateObject("java", "org.apache.commons.vfs.provider.sftp.SftpFileSystemConfigBuilder").getInstance().setStrictHostKeyChecking(fso, "no"); 
		Selectors = CreateObject("java", "org.apache.commons.vfs.Selectors");

	    fsManager = CreateObject("java", "org.apache.commons.vfs.VFS").getManager(); 

	    uri = "sftp://#Application.sftpUser#:#Application.sftpPass#@#Application.sftpHost##Application.ogc_external_table#/OTR_CUST_APPL_TBS_XT.DAT"; 

	    fo = fsManager.resolveFile(uri, fso); 
	    lfo = fsManager.resolveFile("#ReplaceNoCase(sFileCheck, ".DAT", ".tmp", "ALL")#"); 

		fo.copyFrom(lfo, Selectors.SELECT_SELF);
		
	    lfo.close();
		fs = fo.getFileSystem();
	
	    fsManager.closeFileSystem(fs); 
	</cfscript> 

	<!--- Delete the file with extention .tmp --->
	<cfset b = FileDelete('#ReplaceNoCase(sFileCheck, ".DAT", ".tmp", "ALL")#') />
	
</cfif>
<cflocation url="/otr/otr_setup.cfm" addtoken="no" />
