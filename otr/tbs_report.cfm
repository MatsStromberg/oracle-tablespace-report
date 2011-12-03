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
<cfif IsDefined("FORM.development")>
	<cfset qDev = 1>
<cfelse>
	<cfset qDev = 0>
</cfif>
<cfif IsDefined("FORM.internal")>
	<cfset qInt = 1>
<cfelse>
	<cfset qInt = 0>
</cfif>

<cfif IsDefined("FORM.rep_cust") AND Trim(FORM.rep_cust) GT "">
	<cfquery name="qRepClient" datasource="#application.datasource#">
		select cust_id, cust_name 
		from otr_cust 
		where cust_id = '#FORM.rep_cust#'
		order by cust_name
	</cfquery>
</cfif>

<cfquery name="qReport" datasource="#application.datasource#">
	select distinct a.db_name, b.cust_appl_id, b.cust_id, a.db_tbs_name, trunc(a.rep_date) as rep_date, a.db_tbs_used_mb, a.db_tbs_free_mb, 
    	   a.db_tbs_can_grow_mb, a.db_tbs_max_free_mb, a.db_tbs_prc_used, a.db_tbs_real_prc_used
	from otr_db_space_rep a, otr_cust_appl_db_tbs_v b
	where a.db_name = b.db_name
	and   a.db_tbs_name = b.db_tbs_name
	<cfif IsDefined("FORM.rep_cust") AND Trim(FORM.rep_cust) GT "">and   b.cust_id = '#Trim(FORM.rep_cust)#'</cfif>
	<cfif qDev IS 0>and   b.db_env <> 'DEV'</cfif>
	<cfif qInt IS 0>and   b.db_env <> 'INT'</cfif>
	and   trunc(a.rep_date) = trunc(to_date('#FORM.rep_date#','DD-MM-YYYY'))
	order by trunc(a.rep_date), a.db_name, a.db_tbs_name
</cfquery>

<cfquery name="qReportLinks" datasource="#application.datasource#">
    select distinct a.db_name, trunc(a.rep_date) as rep_date
	from otr_db_space_rep a, otr_cust_appl_db_tbs_v b
	where a.db_name = b.db_name
	and   a.db_tbs_name = b.db_tbs_name
	<cfif IsDefined("FORM.rep_cust") AND Trim(FORM.rep_cust) GT "">and   b.cust_id = '#Trim(FORM.rep_cust)#'</cfif>
	<cfif qDev IS 0>and   b.db_env <> 'DEV'</cfif>
	<cfif qInt IS 0>and   b.db_env <> 'INT'</cfif>
	and   trunc(a.rep_date) = trunc(to_date('#FORM.rep_date#','DD-MM-YYYY'))
	order by trunc(a.rep_date), a.db_name
</cfquery>

<cfset nSubSum = 0>
<cfset nTotSum = 0>
<cfsetting enablecfoutputonly="false">
<html>
<head>
	<title>Oracle Grid Control TABLESPACE Reports</title>
<link rel="stylesheet" href="ogc.css" type="text/css" />
<style type="text/css">
<!--
/* Import the fancy styles for IE only (NS4.x doesn't use the @import function) */
@import url("formIE.css");
-->
</style>
<script type="text/javascript">
function searchSel() {
  var input=document.getElementById('searchtxt').value.toUpperCase();
  var output=document.getElementById('instance').options;
  for(var i=0;i<output.length;i++) {
    if(output[i].value.indexOf(input)==0){
      output[i].selected=true;
      }
    if(document.forms[0].searchtxt.value==''){
      output[0].selected=true;
      }
  }
}

function submitForm() {
  location.href="#" + document.form.instance.options[document.form.instance.selectedIndex].value;
}

</script>
</head>
<body>
<cfinclude template="_top_menu.cfm">
<br />
<div align="center">
<h2>Oracle Grid Control TABLESPACE Report</h2>
<h3><cfoutput>#DateFormat(FORM.rep_date,"dd.mm.yyyy")#<cfif IsDefined("FORM.rep_cust") AND Trim(FORM.rep_cust) GT ""> - #qRepClient.cust_name#</cfif></cfoutput></h3>
<cfoutput query="qReportLinks"><a href="###qReportLinks.db_name#" onFocus="this.blur();">#qReportLinks.db_name#</a> </cfoutput>
<!--- <br />
<form name="Form" action="" onsubmit="submitForm(this.form)">
<cfoutput>
<cfif IsDefined("FORM.rep_cust") AND Trim(FORM.rep_cust) GT ""><input name="rep_cust" type="Hidden" value="#FORM.rep_cust#"></cfif>
<input name="rep_date" type="Hidden" value="#FORM.rep_date#">
</cfoutput>
Search: <input type="text" id="searchtxt" onkeyup="this.value=this.value.toUpperCase(); searchSel();">
<select name="instance" id="instance">
<option value="">Select...</option>
<cfoutput query="qReportLinks"><option value="#qReportLinks.db_name#">#qReportLinks.db_name#</option>
</cfoutput></select>
</form> --->
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
<!--- <div align="left" style="font-size: 13pt;font-weight: bold;">DB: #qReport.db_name#&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Client App(s): #qReport.cust_appl_id#</div> --->
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
	<td width="120" align="right">#qReport.db_tbs_can_grow_mb#</td>
	<td width="120" align="right">#LSNumberFormat(qReport.db_tbs_max_free_mb,"99999.99")#</td>
	<td width="120" align="right" title="#LsNumberFormat(qReport.db_tbs_prc_used,"999.09")# %" style="cursor:help;">#LsNumberFormat(round(qReport.db_tbs_prc_used),"999")# %</td>
	<td width="120" align="right" title="#LsNumberFormat(qReport.db_tbs_real_prc_used,"999.09")# %" style="cursor:help;">#LsNumberFormat(round(qReport.db_tbs_real_prc_used),"999")# %</td>
</tr></cfoutput>
<tr>
	<td width="200" align="right">Sub Total (MB):</td>
	<td width="120" align="right"><strong><u>#LSNumberFormat(nSubSum,"999,999")#</u></strong></td>
	<td colspan="4">&nbsp;</td>
	<td align="right"><a href="##top" style="font-size: 7pt; cursor:hand;" onFocus="this.blur();">Top</a></td>
</tr>
</table>
<cfset nTotSum = nTotSum + nSubSum>
<cfset nSubSum = 0>
<br />
</cfoutput>
<table border="0" cellpadding="2" cellspacing="1">
<tr>
	<td width="200" align="right">Total Space Used (MB):</td>
	<td width="120" align="right"><strong><cfoutput><u>#LSNumberFormat(nTotSum,"999,999")#</u></cfoutput></strong></td>
	<td colspan="5">&nbsp;</td>
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
