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
	2013.04.22	mst	Removed commented code not used anymore.
	2013.04.24	mst	changed from tablesoter.js to dataTables.js
--->
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"><cfprocessingdirective suppresswhitespace="Yes"><cfsetting enablecfoutputonly="true">
<cfset cDirSep = FileSeparator() />
<cfset sPath = ExpandPath('/') />
<cfset sTemplatePath = GetDirectoryfrompath(GetBasetemplatePath()) />

<!--- TODO: Fix a new way to load the OTR_CUST_APPL_TBS Table if it's empty! --->


<cfquery name="qParFile" datasource="#Application.datasource#">
	select * from otr_cust_appl_tbs
	order by db_name, db_tbs_name
</cfquery>

<!--- Generate a New Excel file --->
<cftry>
	<cfset xlsTBSobj = SpreadsheetNew(false) />
	<cfset bDummy = SpreadsheetSetcolumnwidth(xlsTBSobj,1,1700) />
	<cfset bDummy = SpreadsheetSetcolumnwidth(xlsTBSobj,2,8000) />
	<cfset bDummy = SpreadsheetSetcolumnwidth(xlsTBSobj,3,3500) />
	<cfset bDummy = SpreadsheetSetcolumnwidth(xlsTBSobj,4,8500) />
	<cfset bDummy = SpreadsheetSetcolumnwidth(xlsTBSobj,5,1500) />
	<cfset bDummy = SpreadsheetSetcolumnwidth(xlsTBSobj,6,1500) />
	<!---
	<cfset bDummy = SpreadsheetQuerywrite (xlsTBSobj, qParFile, 'Tablespaces') />
	--->
	<cfoutput query="qParFile">
	<cfset bDummy = SpreadsheetSetcellvalue (xlsTBSobj, '#qParFile.cust_id#', #qParFile.CurrentRow#, 1) />
	<cfset bDummy = SpreadsheetSetcellvalue (xlsTBSobj, '#qParFile.cust_appl_id#', #qParFile.CurrentRow#, 2) />
	<cfset bDummy = SpreadsheetSetcellvalue (xlsTBSobj, '#qParFile.db_name#', #qParFile.CurrentRow#, 3) />
	<cfset bDummy = SpreadsheetSetcellvalue (xlsTBSobj, '#qParFile.db_tbs_name#', #qParFile.CurrentRow#, 4) />
	<cfset bDummy = SpreadsheetSetcellvalue (xlsTBSobj, '#qParFile.threshold_warning#', #qParFile.CurrentRow#, 5) />
	<cfset bDummy = SpreadsheetSetcellvalue (xlsTBSobj, '#qParFile.threshold_critical#', #qParFile.CurrentRow#, 6) />
	</cfoutput>

	<!--- Meta Info --->
	<cfset stInfo = StructNew()>
	<cfset bDummy = StructInsert(stInfo, "author", "#Application.excel_doc_info_author#") />
	<cfset bDummy = StructInsert(stInfo, "category", "") />
	<cfset bDummy = StructInsert(stInfo, "subject", "#Application.excel_doc_info_subject#") />
	<cfset bDummy = StructInsert(stInfo, "title", "#Application.excel_doc_info_title#") />
	<cfset bDummy = StructInsert(stInfo, "revision", "") />
	<cfset bDummy = StructInsert(stInfo, "description", "") />
	<cfset bDummy = StructInsert(stInfo, "manager", "") />
	<cfset bDummy = StructInsert(stInfo, "company", "#Application.company#") />
	<cfset bDummy = StructInsert(stInfo, "comments", "") />
	<cfset bDummy = StructInsert(stInfo, "lastauthor", "#Application.excel_doc_info_lastauthor#") />

	<cfset bDummy = SpreadsheetAddinfo(xlsTBSobj, stInfo) />
	<!---
	p2   structure - items include (author, category, subject, title, revision, description, manager, company, comments, lastauthor) 
	--->
	<!--- Save the Excel File --->
	<cfset bDummy = SpreadsheetWrite (xlsTBSobj, '#sTemplatePath##cDirSep#excel#cDirSep#otr_cust_tbs.xls', true) />
	<cfcatch type="any">
		<cfdump var="#cfcatch#">
		<cfdump var="#xlsTBSobj#">
	</cfcatch>
</cftry>
<cfsetting enablecfoutputonly="false">
<html>
<head>
	<title><cfoutput>#Application.company#</cfoutput> - Oracle Customer/App/Tablespace</title>
<cfinclude template="_otr_css.cfm">
<script type="text/javascript">
<!--
$(document).ready(function(){
        $('#tablespace').dataTable( {
          "sDom": '<"top"flp<"clear">>rt<"bottom"ifp<"clear">>'
        });
});

function makeDisableSubmit(){
    /*var x=document.getElementById("qSubmit");
    x.disabled=true;*/
}
function makeEnableSubmit(){
    var x=document.getElementById("qSubmit");
    x.disabled=false;
}
function hideDiv() { 
	if (document.getElementById) { // DOM3 = IE5, NS6 
		document.getElementById("loaderDiv").style.visibility = 'hidden'; 
		document.getElementById("loaderDiv").style.display = 'none'; 
	} 
	else { 
		if (document.layers) { // Netscape 4 
			document.loaderDiv.visibility = 'hidden'; 
		} 
		else { // IE 4 
			document.all.loaderDiv.style.visibility = 'hidden'; 
		} 
	} 
} 

function showDiv() { 
	if (document.getElementById) { // DOM3 = IE5, NS6 
		document.getElementById("loaderDiv").style.visibility = 'visible'; 
		document.getElementById("loaderDiv").style.display = 'block'; 
		document.getElementById("snapshot").src = 'otr_tbs_newsnapshot.cfm?MENU=YES';
	} 
	else { 
		if (document.layers) { // Netscape 4 
			document.loaderDiv.visibility = 'visible'; 
		} 
		else { // IE 4 
			document.all.loaderDiv.style.visibility = 'visible'; 
		} 
	} 
} 
// -->
</script>
<cfjavascript minimize="true" munge="true">
function confirmation(txt, url) {
  if (confirm(txt)) {
    document.location.href = url;
  } else {
    /* window.showHourglasses = false; */
  }
}
</cfjavascript>
</head>
<body>
<cfinclude template="_top_menu.cfm">
<div align="center">
	<div id="sort_overlay">
		Please wait...
	</div>
<!--- <cfoutput>#sTemplatePath#</cfoutput><br /> --->
<h2><cfoutput>#Application.company#</cfoutput> - Oracle Customer/App/Tablespace</h2>
<div align="center">
<a href="otr_tbs_csv.cfm" class="otrtip" title="<div align='center'>Save info as a CSV File.</div>" target="csv"><img src="images/xls.png" alt="" width="16" height="16" border="0">&nbsp;Export Result as CSV</a> - <a href="excel/otr_cust_tbs.xls" class="otrtip" title="<div align='center'>Save info as an Excel File.</div>" target="_new"><img src="images/xls.png" alt="" width="16" height="16" border="0">&nbsp;Export Result to Excel</a> - <a href="otr_tbs_upload.cfm" class="otrtip" title="<div align='center'>Upload Tablespace Info from<br />an Excel or a CSV File.</div>"><img src="images/file.gif" alt="" width="18" height="18" border="0">&nbsp;Upload a new CSV or XLS(X)</a><br>
<table border="0" cellpadding="5">
<tr>
	<td class="bodyline">
	<table border=0 class="tablesorter" id="tablespace">
	<thead>
	<tr>
		<th align="right" width="30" style="font-size: 9pt;font-weight: bold;">#&nbsp;</th>
		<th width="100" style="font-size: 9pt;font-weight: bold;">Customer</th>
		<th width="220" style="font-size: 9pt;font-weight: bold;">Application</th>
		<th width="100" style="font-size: 9pt;font-weight: bold;">SID</th>
		<th width="200" style="font-size: 9pt;font-weight: bold;">Tablespace</th>
		<th width="90" style="font-size: 9pt;font-weight: bold;">Warning</th>
		<th width="90" style="font-size: 9pt;font-weight: bold;">Critical</th>
	</tr>
	</thead>
	<tbody>
	<cfoutput query="qParFile"><tr<cfif qParFile.CurrentRow mod 2> class="alternate"</cfif>>
		<td align="right"><cfif qParFile.currentRow LT 10000>&nbsp;</cfif><cfif qParFile.currentRow LT 1000>&nbsp;</cfif><cfif qParFile.currentRow LT 100>&nbsp;</cfif><cfif qParFile.currentRow LT 10>&nbsp;</cfif>#qParFile.currentRow#&nbsp;</td>
		<td>#qParFile.cust_id#</td>
		<td>#qParFile.cust_appl_id#</td>
		<td>#qParFile.db_name#</td>
		<td>#qParFile.db_tbs_name#</td>
		<td align="center">#qParFile.threshold_warning#</td>
		<td align="center">#qParFile.threshold_critical#</td>
	</tr></cfoutput>
	</tbody>
	</table>
	</td>
</tr>
<tr>
	<td align="center" style="font-size: 8pt; text-align: center;">
<cfinclude template="_footer.cfm" />
	</td>
</tr>
</table>
<iframe id="csv" height="1" width="1" name="csv" style="visibility:hidden;"></iframe>
</div>
</body>
</html></cfprocessingdirective>