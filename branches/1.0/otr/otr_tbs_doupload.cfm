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
<cfsetting enablecfoutputonly="true" />
<cfset sftpHost = "#application.sftpHost#" />
<cfset sftpUser = "#application.sftpUser#" />
<cfset sftpPass = "#application.sftpPass#" />
<cfset cDirSep = FileSeparator() />
<cfset bExcel = 0>
<cfif cDirSep IS "/">
	<cfset sPath = GetDirectoryfrompath(GetBasetemplatePath()) />
	<cfif Trim(FORM.file_type) IS "xls">
		<cfset sFile = '#application.ogc_external_table##cDirSep#OTR_CUST_APPL_TBS_XT.xls' />
		<cfset bExcel = 1>
	<cfelse>
		<cfset sFile = '#application.ogc_external_table##cDirSep#OTR_CUST_APPL_TBS_XT.tmp' /><br>
		<cfset bExcel = 0>
	</cfif>
	<cfset sFile2 = '#application.ogc_external_table##cDirSep#OTR_CUST_APPL_TBS_XT.DAT' />
<cfelse>
	<cfset sPath = GetDirectoryfrompath(GetBasetemplatePath()) />
	<cfif Trim(FORM.file_type) IS "xls">
		<cfset sFile = '#sPath##cDirSep#OTR_CUST_APPL_TBS_XT.xls' />
		<cfset bExcel = 1>
	<cfelse>
		<cfset sFile = '#sPath##cDirSep#OTR_CUST_APPL_TBS_XT.tmp' /><br>
		<cfset bExcel = 0>
	</cfif>
	<cfset sFile2 = '#application.ogc_external_table##cDirSep#OTR_CUST_APPL_TBS_XT.DAT' />
</cfif>
<cfsetting enablecfoutputonly="true" />
<!--- <cfoutput>#sPath#<br />#sFile#</cfoutput> --->

<cfset args = {
	destination : "#sFile#",
	filefield : "file_name",
	nameconflict : "overwrite"
	}>

<cfset x = StructNew()>
<cfset x = FileUpload(ArgumentCollection = args) />
<!--- If we're on UNIX/Linux set the access mode on the target file to 777 --->
<cfif cDirSep IS "/"><cfset x2 = FileSetAccessmode(#sFile#, 777) /></cfif>

<!--- Is this an Excel File? BEGIN --->
<cfif bExcel IS 1>
	<cfset iRow = 1 />
	<cfset iCol = 1 />
	<cfset bDone = 1 />
	<cfset qExcel = QueryNew("field1, field2, field3, field4")>
	<cftry>
		<cfset xlsObj = SpreadsheetRead('#sFile#',0) />
		<cfset bDummy = IsSpreadsheetobject(xlsObj) />
		<cfloop condition="bDone EQUAL 1">
			<cfset newRow = QueryAddRow(qExcel, 1)>
			<cfloop from="1" to="4" index="iCol">
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
		<!--- Change the file extention from .xls to .tmp and generate the CSV File --->
		<cfset oFile = FileOpen(ReplaceNoCase(sFile, ".xls", ".tmp", "ALL"),"write")>
		<cfoutput query="qExcel">
			<cfif Trim(qExcel.field1) IS NOT ""><cfset sDummy = FileWriteline(oFile, "#Trim(qExcel.field1)#;#Trim(qExcel.field2)#;#Trim(qExcel.field3)#;#Trim(qExcel.field4)#")></cfif>
		</cfoutput>
		<cfset bDummy = FileClose(oFile)>
		<!--- Delete the .xls File --->
		<cfset b = FileDelete('#sFile#') />
		<!--- Change file extention back to the .tmp --->
		<cfset sFile = ReplaceNoCase(sFile, ".xls", ".tmp", "ALL")>
		<cfcatch type="any">
			<cfdump var="#cfcatch#">
			<cfdump var="#xlsObj#">
		</cfcatch>
	</cftry>
</cfif>
<!--- Is this an Excel File ?? END --->

<!--- Make sure the file is in UNIX Format --->
<cfif cDirSep IS "/"><cfexecute name="#application.UXdos2unix#" arguments="#sFile#" timeout="10"></cfexecute></cfif>
<cfif cDirSep IS "\"><cfexecute name="#application.WINdos2unix#" arguments="#sFile#" timeout="10"></cfexecute></cfif>
<!--- <cfabort> --->
<!--- Use SFTP to transfer the, uploaded or generated from .xls, CSV File under user Oracle and with extention .DAT
      This is used as an External Table in Oracle. --->
<cfscript>
    fso = CreateObject("java", "org.apache.commons.vfs.FileSystemOptions").init(); 
    CreateObject("java", "org.apache.commons.vfs.provider.sftp.SftpFileSystemConfigBuilder").getInstance().setStrictHostKeyChecking(fso, "no"); 
	Selectors = CreateObject("java", "org.apache.commons.vfs.Selectors");

    fsManager = CreateObject("java", "org.apache.commons.vfs.VFS").getManager(); 

    uri = "sftp://#sftpUser#:#sftpPass#@#sftpHost##application.ogc_external_table#/OTR_CUST_APPL_TBS_XT.DAT"; 

    fo = fsManager.resolveFile(uri, fso); 
    lfo = fsManager.resolveFile("#sFile#"); 

	fo.copyFrom(lfo, Selectors.SELECT_SELF);
		
    lfo.close();
	fs = fo.getFileSystem();
	
    fsManager.closeFileSystem(fs); 
</cfscript> 

<!--- Delete the file with extention .tmp --->
<cfset b = FileDelete('#sFile#') />

<cflocation url="otr_tbs.cfm" addtoken="No">
