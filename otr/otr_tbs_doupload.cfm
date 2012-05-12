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
	
	The Oracle Tablespace Report do need an Oracle Grid Control 10g Repository
	(Copyright Oracle Inc.) since it will get some of it's data from the Grid 
	Repository.
    
    You should have received a copy of the GNU General Public License 
    along with the Oracle Tablespace Report.  If not, see 
    <http://www.gnu.org/licenses/>.
--->
<cfsetting enablecfoutputonly="true" />
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
<cflocation url="otr_tbs.cfm" addtoken="No">
