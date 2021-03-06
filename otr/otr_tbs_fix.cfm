<!---
    Copyright (C) 2010-2013 - Oracle Tablespace Report Project - http://www.network23.net
    
    Contributing Developers:
    Mats Str�mberg - ms@network23.net

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
	2012.05.16	mst	Fixed adding and Increasing Tablespaces stored on ASM 
	2013.04.17	mst	Added SYSTEM Username
--->
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"><cfprocessingdirective suppresswhitespace="Yes"><cfsetting enablecfoutputonly="true">
<cfsetting enablecfoutputonly="false">
<!--- Get the HashKey --->
<cfset sHashKey = Trim(Application.pw_hash.lookupKey()) />

<cfif IsDefined("URL.SID") AND Trim(URL.SID) GT ""><cfset oraSID = Trim(URL.SID) /><cfelse>No SID passed<cfabort></cfif>
<cfif IsDefined("URL.TBS") AND Trim(URL.TBS) GT ""><cfset oraTBS = Trim(URL.TBS) /><cfelse>No Tablespace passed<cfabort></cfif>

<!--- Get the System Password --->
<cfquery name="qInstances" datasource="#application.datasource#">
	select db_name, system_username, system_password, db_host, db_port, db_asm, db_rac, db_servicename, db_blackout
	from otr_db 
	where UPPER(db_name) = '#Trim(UCase(oraSID))#'
	order by db_name
</cfquery>

<!--- If no password set, Abort --->
<cfif Trim(qInstances.system_password) IS "">
	No System PASSWORD defined<cfabort>
<cfelse>
	<cfset sPassword = Application.pw_hash.decryptOraPW(Trim(qInstances.system_password), Trim(sHashKey)) />
</cfif>

<!--- Get Listener Port --->
<cfif Trim(qInstances.db_port) IS "">
	<cfquery name="qPort" datasource="OTR_SYSMAN">
		select distinct b.property_value
		  from mgmt_target_properties a, mgmt_target_properties b
		 where a.target_guid = b.target_guid
		   and UPPER(a.property_value) = '#Trim(UCase(oraSID))#'
		   and b.property_name = 'Port';
	</cfquery>
	<cfset iPort = qPort.property_value />
<cfelse>
	<cfset iPort = qInstances.db_port />
</cfif>

<!--- Get Host server from EM --->
<cfif Trim(qInstances.db_host) IS "" >
	<cfquery name="qHost" datasource="OTR_SYSMAN">
		select distinct b.property_value
		  from mgmt_target_properties a, mgmt_target_properties b
		 where a.target_guid = b.target_guid
		   and UPPER(a.property_value) = '#Trim(UCase(qInstances.db_name))#'
		   and b.property_name = 'MachineName'
	</cfquery>
	<cfset sHost = Trim(qHost.property_value) />
<cfelse>
	<cfset sHost = Trim(qInstances.db_host) />
</cfif>

<!--- Create Temporary Data Source --->
<cfset s = StructNew()>
<cfif qInstances.db_rac IS 1>
	<cfset s.hoststring   = "jdbc:oracle:thin:@#LCase(sHost)#:#iPort#/#UCase(qInstances.db_servicename)#" />
<cfelse>
	<cfset s.hoststring   = "jdbc:oracle:thin:@#LCase(sHost)#:#iPort#:#UCase(qInstances.db_name)#" />
</cfif>
<cfset s.drivername   = "oracle.jdbc.OracleDriver">
<cfset s.databasename = "#UCase(oraSID)#">
<cfset s.username     = "#UCase(qInstances.system_username)#">
<cfset s.password     = "#sPassword#">
<cfset s.port         = "#iPort#">

<cfif DataSourceIsValid("#UCase(oraSID)#temp")>
	<cfset DataSourceDelete( "#UCase(oraSID)#temp" )>
</cfif>
<cfif NOT DataSourceIsValid("#UCase(oraSID)#temp")>
	<cfset DataSourceCreate( "#UCase(oraSID)#temp", s )>
</cfif>

<!--- BIGFILE YES or NO? --->
<cfquery name="qTBSinfo" datasource="#UCase(oraSID)#temp">
	select * from dba_tablespaces
	where tablespace_name = '#oraTBS#'
	order by tablespace_name
</cfquery>

<cfquery name="qDBFinfo" datasource="#UCase(oraSID)#temp">
	select file_name, maxbytes/1024/1024 max_mb, user_bytes/1024/1024 used_mb 
	from dba_data_files
	where tablespace_name = '#oraTBS#'
	order by tablespace_name, relative_fno
</cfquery>
<!---
<cfquery name="qDBCountFiles" datasource="#UCase(oraSID)#temp">
	select count(*) number_of_files
	from dba_data_files
	where tablespace_name = '#oraTBS#'
	order by tablespace_name, relative_fno
</cfquery>
--->

<html>
<head>
	<title><cfoutput>#Application.company#</cfoutput> - Tablespace Adjustments</title>
<link rel="stylesheet" href="JScripts/jQuery/jquery.tablesorter/themes/blue/style.css" type="text/css" id="" media="print, projection, screen" />
<cfinclude template="_otr_css.cfm">
<script type="text/javascript">
<!--
$(document).ready(function(){
	$("table").tablesorter({debug: false, widgets: ['zebra'],sortList: [[1,0]]});
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
</script><!---
<cfjavascript minimize="true" munge="true">
function confirmation(txt, url) {
  if (confirm(txt)) {
    document.location.href = url;
  } else {
    /* window.showHourglasses = false; */
  }
}
</cfjavascript> --->
<!--- <cfjavascript minimize="true" munge="true"> --->
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
<h2><cfoutput>#Application.company#</cfoutput> - Tablespace Adjustments</h2>
<div align="center">
<table border="0" cellpadding="5">
<tr>
	<td class="bodyline">
	<table border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td>
			<div align="center" style="text-align: center; font-weight: bold; font-size:14pt;"><cfoutput>(#oraSID#) #oraTBS#</cfoutput></div>
			<cfif qTBSinfo.bigfile IS "YES">
				<table border="0" cellpadding="2" cellspacing="5">
				<tr>
					<th>Datafile</th>
					<th style="text-align: right;">Can grow to</th>
					<th style="text-align: right;">Used</th>
					<th>Increase with</th>
				</tr>
				<cfoutput query="qDBFinfo"><tr>
					<td>#qDBFinfo.file_name#</td>
					<td align="right">#NumberFormat(qDBFinfo.max_mb)# MB</td>
					<td align="right">#NumberFormat(qDBFinfo.used_mb)# MB</td>
					<td align="center"><a href="otr_tbs_dofix.cfm?action=increase&SID=#oraSID#&TBS=#oraTBS#&DBF=#qDBFinfo.file_name#&BIGFILE=#qTBSinfo.bigfile#&CGT=1024" onFocus="this.blur();" class="otrtip" title="<div align='center'>Increase the *Can Grow To*<br />with 1GB more.</div>">1GB</a>&nbsp;&nbsp;&nbsp;<a href="otr_tbs_dofix.cfm?action=increase&SID=#oraSID#&TBS=#oraTBS#&DBF=#qDBFinfo.file_name#&BIGFILE=#qTBSinfo.bigfile#&CGT=2048" onFocus="this.blur();" class="otrtip" title="<div align='center'>Increase the *Can Grow To*<br />with 2GB more.</div>">2GB</a></td>
				</tr></cfoutput>
				</table>
			<cfelse>
				<table border="0" cellpadding="2" cellspacing="2">
				<tr>
					<th>Datafile</th>
					<th style="text-align: right;">Can grow to</th>
					<th style="text-align: right;">Used</th>
					<th>Increase with</th>
				</tr>
				<cfoutput query="qDBFinfo"><cfif qDBFinfo.max_mb NEQ 0><tr>
					<td>#qDBFinfo.file_name#<cfset sFileName = Trim(qDBFinfo.file_name) /></td>
					<td align="right">#NumberFormat(qDBFinfo.max_mb)# MB</td>
					<td align="right">#NumberFormat(qDBFinfo.used_mb)# MB</td>
					<td align="center"><a href="otr_tbs_dofix.cfm?action=increase&SID=#oraSID#&TBS=#oraTBS#&DBF=#qDBFinfo.file_name#&BIGFILE=#qTBSinfo.bigfile#&CGT=1024" onFocus="this.blur();" class="otrtip" title="<div align='center'>Increase the *Can Grow To*<br />with 1GB more.</div>">1GB</a>&nbsp;&nbsp;<a href="otr_tbs_dofix.cfm?action=increase&SID=#oraSID#&TBS=#oraTBS#&DBF=#qDBFinfo.file_name#&BIGFILE=#qTBSinfo.bigfile#&CGT=2048" onFocus="this.blur();" class="otrtip" title="<div align='center'>Increase the *Can Grow To*<br />with 2GB more.</div>">2GB</a></td>
				</tr></cfif></cfoutput><cfif qTBSinfo.bigfile IS "NO">
				<tr>
					<td colspan="4" style="color: #f00; font-weight: bold;">This is not a BIGFILE Tablespace so the file should not get bigger than 32GB!</td>
				</tr></cfif>
				<tr>
					<td colspan="4">&nbsp;</td>
				</tr>
				<tr>
					<td colspan="4">There are currently <cfoutput><strong>#qDBFinfo.RecordCount#</strong></cfoutput> file<cfif qDBFinfo.RecordCount GT 1>s</cfif> in this Tablespace. Most likely you should add a new file to it.</td>
				</tr>
				<cfif qInstances.db_asm IS 0>
					<cfset sFileName = ReplaceNoCase(sFileName, ".dbf", "") /><cfset sFileName2 = sFileName />
					<cfset iLen = Len(sFileName) />
					<cfloop from="#iLen#" to="#Int(iLen - 5)#" step="-1" index="a">
						<cfif ! IsNumeric(#Mid(sFileName,a,1)#)><cfset sFileName = Left(sFileName, a) & Int(qDBFinfo.RecordCount+1) & ".dbf" /><!--- <cfoutput>#sFileName#</cfoutput> ---><cfbreak></cfif>
					</cfloop>
					<cfset iCnt = 0 />
					<cfset iLoop = 1 />
					<cfloop condition="iLoop EQ 1">
						<!--- <cfoutput>#iCnt# #sFilename#</cfoutput><br /> --->
						<cfquery name="qCheck" datasource="#UCase(oraSID)#temp">
							select file_name 
							from dba_data_files
							where tablespace_name = '#oraTBS#'
							  and UPPER(file_name) = '#UCASE(sFileName)#'
							order by tablespace_name, relative_fno
						</cfquery>
						<!--- <cfoutput>RecordCount: #qCheck.RecordCount#</cfoutput> --->
						<cfif qCheck.RecordCount IS 0><cfset iLoop = 0 /></cfif>
						<!--- <cfdump><cfexit> --->
						<cfif qCheck.RecordCount NEQ 0>
							<cfset iCnt = iCnt + 1 />
							<!--- <cfoutput>#Int(qDBFinfo.RecordCount+iCnt)#</cfoutput> --->
							<cfset sFileName = sFileName2 />
							<cfloop from="#iLen#" to="#Int(iLen - 5)#" step="-1" index="a">
								<cfif ! IsNumeric(#Mid(sFileName,a,1)#)><cfset sFileName = Left(sFileName, a) & Int(qDBFinfo.RecordCount-1+iCnt) & ".dbf" /><cfbreak></cfif>
							</cfloop>
							<!--- <cfoutput>#sFileName#</cfoutput> --->
						</cfif>
						<!--- <cfexit> --->
					</cfloop>
				<cfelse>
					<cfset sFileName = Left(sFileName, Find(".",sFileName,1)-1)>
				</cfif>
				<tr><cfoutput>
					<td>#sFileName#<cfif qInstances.db_asm IS 1>.???.?????????</cfif></td>
					<td align="right">#NumberFormat(2048)# MB</td>
					<td align="right">#NumberFormat(128)# MB</td>
					<td align="center"><a href="otr_tbs_dofix.cfm?action=addfile&SID=#oraSID#&TBS=#oraTBS#&DBF=#sFileName#&BIGFILE=#qTBSinfo.bigfile#" onFocus="this.blur();" class="otrtip" title="<div align='center'>Add a new file to<br />this tablespace.</div>">ADD FILE</td>
				</cfoutput></tr>
				</table>
			</cfif>
			<cfoutput>
				<cfif qTBSinfo.bigfile IS "NO">
				<p>
					We have made our best effort to make sure this filename is not allready used.<br />
					At the moment we're only expanded the storage usage with 128MB but <strong>Please</strong><br />
					make sure there is enough space on the storage for this file to grow.
				</p>
				<cfelse>
				<p>
					At the moment we have not used any extra storage but <strong>Please</strong> make sure<br />
					that the storage have enough space available for this file to grow.
				</p>
				</cfif>
				<!---
				BIGFILE = #qTBSinfo.bigfile#<br />
				Number of files: #qDBFinfo.RecordCount#<br />
				--->
			</cfoutput>
		</td>
	</tr>
</table>
</div>

<!--- Delete Temporary Data Source --->
<cfif DataSourceIsValid("#UCase(oraSID)#temp")>
	<cfset DataSourceDelete( "#UCase(oraSID)#temp" )>
</cfif>
</body>
</html></cfprocessingdirective>
