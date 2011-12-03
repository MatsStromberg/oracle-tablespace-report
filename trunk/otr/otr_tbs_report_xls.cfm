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
<cfif IsDefined("URL.development")>
	<cfset qDev = 1>
<cfelse>
	<cfset qDev = 0>
</cfif>
<cfif IsDefined("URL.internal")>
	<cfset qInt = 1>
<cfelse>
	<cfset qInt = 0>
</cfif>
<cfif NOT IsDefined("URL.rep_date")><cflocation url="index.cfm" addtoken="No"></cfif>
<cfif IsDefined("URL.rep_cust") AND Trim(URL.rep_cust) GT "">
	<cfquery name="qRepClient" datasource="#application.datasource#">
		select cust_id, cust_name 
		from otr_cust 
		where cust_id = '#URL.rep_cust#'
		order by cust_name
	</cfquery>
</cfif>

<cfquery name="qReport" datasource="#application.datasource#">
	select distinct a.db_name, b.cust_appl_id, b.cust_id, a.db_tbs_name, trunc(a.rep_date) as rep_date, a.db_tbs_used_mb, a.db_tbs_free_mb, 
    	   a.db_tbs_can_grow_mb, a.db_tbs_max_free_mb, a.db_tbs_prc_used, a.db_tbs_real_prc_used
	from otr_db_space_rep a, otr_cust_appl_db_tbs_v b
	where a.db_name = b.db_name
	and   a.db_tbs_name = b.db_tbs_name
	<cfif IsDefined("URL.rep_cust") AND Trim(URL.rep_cust) GT "">and   b.cust_id = '#Trim(URL.rep_cust)#'</cfif>
	<cfif qDev IS 0>and   b.db_env <> 'DEV'</cfif>
	<cfif qInt IS 0>and   b.db_env <> 'INT'</cfif>
	and   trunc(a.rep_date) = trunc(to_date('#URL.rep_date#','DD-MM-YYYY'))
	order by trunc(a.rep_date), a.db_name, a.db_tbs_name
</cfquery>

<cfquery name="qReportLinks" datasource="#application.datasource#">
    select distinct a.db_name, trunc(a.rep_date) as rep_date
	from otr_db_space_rep a, otr_cust_appl_db_tbs_v b
	where a.db_name = b.db_name
	and   a.db_tbs_name = b.db_tbs_name
	<cfif IsDefined("URL.rep_cust") AND Trim(URL.rep_cust) GT "">and   b.cust_id = '#Trim(URL.rep_cust)#'</cfif>
	<cfif qDev IS 0>and   b.db_env <> 'DEV'</cfif>
	<cfif qInt IS 0>and   b.db_env <> 'INT'</cfif>
	and   trunc(a.rep_date) = trunc(to_date('#URL.rep_date#','DD-MM-YYYY'))
	order by trunc(a.rep_date), a.db_name
</cfquery>

<!---
http://www.tek-tips.com/faqs.cfm?fid=6715

http://help.adobe.com/en_US/ColdFusion/9.0/CFMLRef/WSc3ff6d0ea77859461172e0811cbec22c24-6747.html

"underline", True
--->
<cfscript>
	stNormal10 = structNew();
	StructInsert(stNormal10, "fontsize", 10);

	stNormalRight10 = structNew();
	StructInsert(stNormalRight10, "alignment", "right");
	StructInsert(stNormalRight10, "fontsize", 10);

	stNormalProc10 = structNew();
	StructInsert(stNormalProc10, "fontsize", 10);
	StructInsert(stNormalProc10, "dataformat", "0.00%");

	stNormalRightProc10 = structNew();
	StructInsert(stNormalRightProc10, "alignment", "right");
	StructInsert(stNormalRightProc10, "fontsize", 10);
	StructInsert(stNormalRightProc10, "dataformat", "0%");

	stBold10 = structNew();
	StructInsert(stBold10, "bold", True);
	StructInsert(stBold10, "fontsize", 10);

	stBoldRight10 = structNew();
	StructInsert(stBoldRight10, "alignment", "right");
	StructInsert(stBoldRight10, "bold", True);
	StructInsert(stBoldRight10, "fontsize", 10);

	stBoldRight10 = structNew();
	StructInsert(stBoldRight10, "bold", True);
	StructInsert(stBoldRight10, "alignment", "right");
	StructInsert(stBoldRight10, "fontsize", 10);

	stBold12 = structNew();
	StructInsert(stBold12, "bold", True);
	StructInsert(stBold12, "fontsize", 12);

	stBoldRight12 = structNew();
	StructInsert(stBoldRight12, "bold", True);
	StructInsert(stBoldRight12, "alignment", "right");
	StructInsert(stBoldRight12, "fontsize", 12);

	stBold14 = structNew();
	StructInsert(stBold14, "bold", True);
	StructInsert(stBold14, "fontsize", 14);

	stBoldRight = structNew();
	StructInsert(stBoldRight, "bold", True);
	StructInsert(stBoldRight, "alignment", "right");

	stHeaderCenter = structNew();
	StructInsert(stHeaderCenter, "bold", True);
	StructInsert(stHeaderCenter, "alignment", "center");
	StructInsert(stHeaderCenter, "fontsize", 18);

	stHeaderCenter2 = structNew();
	StructInsert(stHeaderCenter2, "bold", True);
	StructInsert(stHeaderCenter2, "alignment", "center");
	StructInsert(stHeaderCenter2, "fontsize", 14);
</cfscript>
<cfset nSubSum = 0>
<cfset nTotSum = 0>
<cfset nSubCanGrowToSum = 0>
<cfset nTotCanGrowToSum = 0>
<cfset iRow = 0>

<cftry>
	<!--- Open a Preformated empty Excel Template --->
	<cfset xlsObj = SpreadsheetRead('#sTemplatePath#excel#cDirSep#customer_template.xls',0) />
	<cfset iRow = iRow + 1 />
	<!--- Output Header on the first line --->
	<cfset bDummy = SpreadsheetSetcellvalue(xlsObj, '#application.company# - Oracle Tablespace Reports', #iRow#, 1) />
	<cfset iRow = iRow + 1 />
	<cfset iRow = iRow + 1 />
	<cfset sHeadDate = "" & DateFormat(URL.rep_date,"dd.mm.yyyy") />
	<cfif IsDefined("URL.rep_cust") AND Trim(URL.rep_cust) GT "">
		<cfset sHeadDate & "- " & qRepClient.cust_name />
	</cfif>
	<!--- Output Reporting Date and if selected the Customer Name --->
	<cfset bDummy = SpreadsheetSetcellvalue(xlsObj, '#sHeadDate#', #iRow#, 1) />
	<cfset iRow = iRow + 1 />
	
	<cfoutput query="qReport" group="db_name">
		<cfset iRow = iRow + 1 />
		<!--- Output which DB and for what Application it's used --->
		<cfset bDummy = SpreadsheetSetcellvalue(xlsObj, 'DB: #qReport.db_name#', #iRow#, 1) />
		<cfset bDummy = SpreadsheetSetcellvalue(xlsObj, 'Client App(s): #qReport.cust_appl_id#', #iRow#, 3) />
		<!--- Merge some cells for a better look --->
		<cfset bDummy = SpreadsheetMergecells(xlsObj, #iRow#, #iRow#,1,2) />
		<cfset bDummy = SpreadsheetMergecells(xlsObj, #iRow#, #iRow#,3,7) />
		<!--- Merge some cells for a better look --->
		<cfset bDummy = SpreadsheetFormatRow(xlsObj, #stBold14#, #iRow#) />
		<cfset iRow = iRow + 1 />
		<cfset iRow = iRow + 1 />
		<!--- Output Header Info for the data columns --->
		<cfset bDummy = SpreadsheetSetcellvalue(xlsObj, 'TABLESPACE', #iRow#, 1) />
		<cfset bDummy = SpreadsheetSetcellvalue(xlsObj, 'Used (MB)', #iRow#, 2) />
		<cfset bDummy = SpreadsheetSetcellvalue(xlsObj, 'Free (MB)', #iRow#, 3) />
		<cfset bDummy = SpreadsheetSetcellvalue(xlsObj, 'Can Grow To (MB)', #iRow#, 4) />
		<cfset bDummy = SpreadsheetSetcellvalue(xlsObj, 'Max Free (MB)', #iRow#, 5) />
		<cfset bDummy = SpreadsheetSetcellvalue(xlsObj, '% Used', #iRow#, 6) />
		<cfset bDummy = SpreadsheetSetcellvalue(xlsObj, '% Real Used', #iRow#, 7) />
		<!--- Make this row Bold and Right adjusted --->
		<cfset bDummy = SpreadsheetFormatRow(xlsObj, #stBoldRight10#, #iRow#) />
		<!--- Make the first Cell in this row Bold and Left adjusted --->
		<cfset bDummy = SpreadsheetFormatCell(xlsObj, #stBold10#, #iRow#, 1) />
		<!--- Output TABLESPACE Space Usage Data --->
		<cfoutput>
			<cfset iRow = iRow + 1 />
			<cfset bDummy = SpreadsheetSetcellvalue(xlsObj, '#qReport.db_tbs_name#', #iRow#, 1) />
			<cfset bDummy = SpreadsheetFormatCell(xlsObj, #stNormal10#, #iRow#, 1) />
			<cfset bDummy = SpreadsheetSetcellvalue(xlsObj, '#LSNumberFormat(qReport.db_tbs_used_mb,"999,999")#', #iRow#, 2) />
			<cfset bDummy = SpreadsheetFormatCell(xlsObj, #stNormalRight10#, #iRow#, 2) />
			<cfset bDummy = SpreadsheetSetcellvalue(xlsObj, '#LSNumberFormat(qReport.db_tbs_free_mb,"99999.99")#', #iRow#, 3) />
			<cfset bDummy = SpreadsheetFormatCell(xlsObj, #stNormalRight10#, #iRow#, 3) />
			<cfset bDummy = SpreadsheetSetcellvalue(xlsObj, '#qReport.db_tbs_can_grow_mb#', #iRow#, 4) />
			<cfset bDummy = SpreadsheetFormatCell(xlsObj, #stNormalRight10#, #iRow#, 4) />
			<cfset bDummy = SpreadsheetSetcellvalue(xlsObj, '#LSNumberFormat(qReport.db_tbs_max_free_mb,"99999.99")#', #iRow#, 5) />
			<cfset bDummy = SpreadsheetFormatCell(xlsObj, #stNormalRight10#, #iRow#, 5) />
			<cfset bDummy = SpreadsheetSetcellvalue(xlsObj, '#LsNumberFormat(round(qReport.db_tbs_prc_used),"999")# %', #iRow#, 6) />
			<cfset bDummy = SpreadsheetFormatCell(xlsObj, #stNormalRight10#, #iRow#, 6) />
			<cfset bDummy = SpreadsheetSetcellvalue(xlsObj, '#LsNumberFormat(round(qReport.db_tbs_real_prc_used),"999")# %', #iRow#, 7) />
			<cfset bDummy = SpreadsheetFormatCell(xlsObj, #stNormalRight10#, #iRow#, 7) />
			<!--- Calculate the Sub Total --->
			<cfset nSubSum = nSubSum + qReport.db_tbs_used_mb>
			<cfset nSubCanGrowToSum = nSubCanGrowToSum + qReport.db_tbs_can_grow_mb>
		</cfoutput>
		<cfset iRow = iRow + 1 />
		<!--- Output Sub Total --->
		<cfset bDummy = SpreadsheetSetcellvalue(xlsObj, 'Sub Total (MB):', #iRow#, 1) />
		<cfset bDummy = SpreadsheetSetcellvalue(xlsObj, '#LSNumberFormat(nSubSum,"999,999")#', #iRow#, 2) />
		<cfset bDummy = SpreadsheetSetcellvalue(xlsObj, '#LSNumberFormat(nSubCanGrowToSum,"999,999")#', #iRow#, 4) />
		<!--- Make this row Bold and Right Adjusted --->
		<cfset bDummy = SpreadsheetFormatRow(xlsObj, #stBoldRight10#, #iRow#) />

		<!--- Calculate the Total Sum --->
		<cfset nTotSum = nTotSum + nSubSum>
		<cfset nSubSum = 0>
		<cfset nTotCanGrowToSum = nTotCanGrowToSum + nSubCanGrowToSum>
		<cfset nSubCanGrowToSum = 0>
		<cfset iRow = iRow + 1 />
	</cfoutput>
	<cfset iRow = iRow + 1 />
	<!--- Output the Grand Total --->
	<cfset bDummy = SpreadsheetSetcellvalue(xlsObj, 'Total Space Used (MB):', #iRow#, 1) />
	<cfset bDummy = SpreadsheetSetcellvalue(xlsObj, '#LSNumberFormat(nTotSum,"999,999")#', #iRow#, 2) />
	<cfset bDummy = SpreadsheetSetcellvalue(xlsObj, '#LSNumberFormat(nTotCanGrowToSum,"999,999")#', #iRow#, 4) />
	<!--- Make this row Bold and Right Adjusted --->
	<cfset bDummy = SpreadsheetFormatRow(xlsObj, #stBoldRight10#, #iRow#) />

	<!--- Save the Excel File under the name of customer_report.xls (For Excel 97 - 2003) --->
	<cfset bDummy = SpreadsheetWrite (xlsObj, '#sTemplatePath#excel#cDirSep#customer_report.xls', true) />
	<cfcatch type="any">
		<cfdump var="#cfcatch#">
		<cfdump var="#xlsObj#">
	</cfcatch>
</cftry>

<cfsetting enablecfoutputonly="false">
<cfabort>
<html>
<head>
	<title><cfoutput>#application.company#</cfoutput> - Oracle Tablespace Reports</title>
<cfinclude template="_otr_css.cfm">
</head>
<body>
<cfinclude template="_top_menu.cfm">
<br />
<div align="center">
<h2><cfoutput>#application.company#</cfoutput> - Oracle Tablespace Reports</h2>
<h3><cfoutput>#DateFormat(URL.rep_date,"dd.mm.yyyy")#<cfif IsDefined("URL.rep_cust") AND Trim(URL.rep_cust) GT ""> - #qRepClient.cust_name#</cfif></cfoutput></h3>
<cfoutput query="qReportLinks"><a href="###qReportLinks.db_name#" onFocus="this.blur();">#qReportLinks.db_name#</a> </cfoutput>
</div>
<div align="center">
<table border="0" cellpadding="5">
<tr>
	<td class="bodyline">
<cfoutput query="qReport" group="db_name">
<table border="0" cellpadding="0" cellspacing="0">
<tr>
	<td width="200" style="font-size: 13pt;font-weight: bold;"><a name="#qReport.db_name#"></a>DB: #qReport.db_name#</td>
	<td style="font-size: 13pt;font-weight: bold;">Client App(s): #qReport.cust_appl_id#</td>
</tr>
</table>
<br />
<table border="0" cellpadding="2" cellspacing="1">
<tr>
	<th>TABLESPACE</th>
	<th style="text-align: right;">Used (MB)</th>
	<th style="text-align: right;">Free (MB)</th>
	<th style="text-align: right;">Can Grow To (MB)</th>
	<th style="text-align: right;">Max Free (MB)</th>
	<th style="text-align: right;">% Used</th>
	<th style="text-align: right;">% Real Used</th>
</tr>
<cfoutput><tr<cfif qReport.CurrentRow mod 2> class="alternate"</cfif>>
	<td width="200">#qReport.db_tbs_name#</td>
	<td width="120" align="right">#LSNumberFormat(qReport.db_tbs_used_mb,"999,999")#<cfset nSubSum = nSubSum + qReport.db_tbs_used_mb></td>
	<td width="120" align="right">#LSNumberFormat(qReport.db_tbs_free_mb,"99999.99")#</td>
	<td width="120" align="right">#qReport.db_tbs_can_grow_mb#<cfset nSubCanGrowToSum = nSubCanGrowToSum + qReport.db_tbs_can_grow_mb></td>
	<td width="120" align="right">#LSNumberFormat(qReport.db_tbs_max_free_mb,"99999.99")#</td>
	<td width="120" align="right" title="#LsNumberFormat(qReport.db_tbs_prc_used,"999.09")# %" style="cursor:help;">#LsNumberFormat(round(qReport.db_tbs_prc_used),"999")# %</td>
	<td width="120" align="right" title="#LsNumberFormat(qReport.db_tbs_real_prc_used,"999.09")# %" style="cursor:help;">#LsNumberFormat(round(qReport.db_tbs_real_prc_used),"999")# %</td>
</tr></cfoutput>
<tr>
	<td align="right">Sub Total (MB):</td>
	<td align="right"><strong><u>#LSNumberFormat(nSubSum,"999,999")#</u></strong></td>
	<td>&nbsp;</td>
	<td align="right"><strong><u>#LSNumberFormat(nSubCanGrowToSum,"999,999")#</u></strong></td>
	<td colspan="2">&nbsp;</td>
	<td align="right"><a href="##top" style="font-size: 7pt; cursor:hand;" onFocus="this.blur();">Top</a></td>
</tr>
</table>
<cfset nTotSum = nTotSum + nSubSum>
<cfset nSubSum = 0>
<cfset nTotCanGrowToSum = nTotCanGrowToSum + nSubCanGrowToSum>
<cfset nSubCanGrowToSum = 0>
<br />
</cfoutput>
<table border="0" cellpadding="2" cellspacing="1">
<tr>
	<td width="200" align="right">Total Space Used (MB):</td>
	<td width="120" align="right"><strong><u><cfoutput>#LSNumberFormat(nTotSum,"999,999")#</cfoutput></u></strong></td>
	<td width="120">&nbsp;</td>
	<td width="120" align="right"><strong><u><cfoutput>#LSNumberFormat(nTotCanGrowToSum,"999,999")#</cfoutput></u></strong></td>
	<td colspan="3">&nbsp;</td>
</tr>
</table>
	<table border="0" width="100%">
	<tr>
		<td align="right" style="color: red;">
		<strong>% Used</strong> and <strong>% Real Used</strong> are rounded up. Just "Mouse Over" these 2 columns to see the real value with 2 decimal digits
		</td>
	</tr>
	</table>
	</td>
</tr>
</table>
</div>
<a href="index.cfm" onfocus="this.blur();">Back to Main</a>
</body>
</html></cfprocessingdirective>
