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

<cfquery name="qHostInstances" datasource="#application.datasource#">
	select distinct a.hostname db_host, a.db_name, a.rep_date, c.db_port, c.system_password
	from otrrep.otr_nfs_space_rep a, otrrep.otr_space_rep_max_timestamp_v b, otrrep.otr_db c
	where TRUNC(a.rep_date) = b.rep_date 
	  and a.db_name = c.db_name
	order by rep_date desc, hostname, db_name
</cfquery>

<cfset dummy = SetLocale("German (Switzerland)") />
<cfsetting enablecfoutputonly="false">
<html>
<head>
	<title><cfoutput>#application.company#</cfoutput> - Oracle Hosts &amp; Instances</title>
<link rel="stylesheet" href="JScripts/jQuery/jquery.tablesorter/themes/blue/style.css" type="text/css" id="" media="print, projection, screen" />
<cfinclude template="_otr_css.cfm">
<!--- <script src="JScripts/jQuery/jquery-1.5.2.min.js" type="text/javascript"></script> --->
<script type="text/javascript">
<!--
$(document).ready(function(){
	$("table").tablesorter({debug: false, widgets: ['zebra'],sortList: [[0,0]]});
	$("table").bind("sortStart",function() {  
		$("#sort_overlay").show();  
 	}).bind("sortEnd",function() {  
		$("#sort_overlay").hide();  
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
<cfjavascript minimize="false" munge="true">
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
<h2><cfoutput>#application.company#</cfoutput> - Oracle Hosts &amp; Instances</h2>
<table border="0" cellpadding="5">
<tr>
	<td class="bodyline">
	<cfif qHostInstances.RecordCount IS NOT 0>
	<table border="0" cellpadding="0" cellspacing="0" class="tablesorter">
	<thead>
	<tr>
		<th width="200" style="font-size: 9pt;font-weight: bold;">Host</th>
		<th width="200" style="font-size: 9pt;font-weight: bold;">SID</th>
		<th width="200" style="font-size: 9pt;font-weight: bold;">Release</th>
	</tr>
	</thead>
	<tfoot>
	<tr>
		<th width="200" style="font-size: 9pt;font-weight: bold;">Host</th>
		<th width="200" style="font-size: 9pt;font-weight: bold;">SID</th>
		<th width="200" style="font-size: 9pt;font-weight: bold;">Release</th>
	</tr>
	</tfoot>
	<tbody>
	<cfloop query="qHostInstances">
		<!--- Decrypt the SYSTEM Password --->
		<cfset sPassword = Trim(Application.pw_hash.decryptOraPW(qHostInstances.system_password)) />
		<!--- Create Temporary Data Source --->
		<cfset s = StructNew() />
		<cfset s.hoststring   = "jdbc:oracle:thin:@#LCase(qHostInstances.db_host)#:#qHostInstances.db_port#:#UCase(qHostInstances.db_name)#" />
		<cfset s.drivername   = "oracle.jdbc.OracleDriver" />
		<cfset s.databasename = "#UCase(qHostInstances.db_name)#" />
		<cfset s.username     = "system" />
		<cfset s.password     = "#sPassword#" />
		<cfset s.port         = "#qHostInstances.db_port#" />

		<cfif DataSourceIsValid("#UCase(qHostInstances.db_name)#temp")>
			<cfset DataSourceDelete( "#UCase(qHostInstances.db_name)#temp" ) />
		</cfif>
		<cfif NOT DataSourceIsValid("#UCase(qHostInstances.db_name)#temp")>
			<cfset DataSourceCreate( "#UCase(qHostInstances.db_name)#temp", s ) />
		</cfif>
		<cfquery name="qDBversion" datasource="#UCase(qHostInstances.db_name)#temp">
		select SUBSTRB (SUBSTR (b.banner, INSTR (b.banner, 'Release') + 8, 10), 1, 10) VERSION
		  from SYS.v_$version b
		 WHERE INSTR (UPPER (b.banner), 'ORACLE') > 0
	       	   AND (   INSTR (UPPER (b.banner), 'ENTERPRISE') > 0
                    OR (   INSTR (UPPER (b.banner), 'ORACLE9I') > 0
                        OR (   INSTR (UPPER (b.banner), 'ORACLE8I') > 0
                            OR INSTR (UPPER (b.banner), 'DATABASE') > 0
                           )
                       )
                  )
		</cfquery>
	<tr<cfif qHostInstances.CurrentRow mod 2> class="alternate"</cfif>>
		<td><cfoutput>#qHostInstances.db_host#</cfoutput></td>
		<td><cfoutput>#qHostInstances.db_name#</cfoutput></td>
		<td><cfoutput>#qDBversion.version#</cfoutput></td>
	</tr>
		<cfif DataSourceIsValid("#UCase(qHostInstances.db_name)#temp")>
			<cfset DataSourceDelete( "#UCase(qHostInstances.db_name)#temp" ) />
		</cfif>
	<cfset dRepDate = LSDateFormat(qHostInstances.rep_date, 'medium') /></cfloop>
	</tbody>
	</table>
	<table border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td style="font-size: 8pt;font-weight: normal;font-style: oblique">Number of Instances: <cfoutput>#qHostInstances.RecordCount#, Stand of #dRepDate#</cfoutput></td>
	</tr>
	<tr>
		<td style="font-size: 8pt;font-weight: normal;">Weekly PDF's are stored under <cfoutput>#Application.host_instance_pdf_dir#</cfoutput></td>
	</tr>
	</table>
	<cfelse>
	No snapshots are available!!!
	</cfif>
	</td>
</tr>
<tr>
	<td align="center" style="font-size: 8pt; text-align: center;">
<cfinclude template="_footer.cfm" />
	</td>
</tr>
</table>
</div>
</body>
</html></cfprocessingdirective>
