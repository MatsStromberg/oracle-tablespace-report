<cfdocument format="pdf" pagetype="A4"> <!-- filename="/tmp/pdftest.pdf" overwrite="true"> -->
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
<!---<cfprocessingdirective suppresswhitespace="Yes">---><cfsetting enablecfoutputonly="true">
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

<!--- SnapManager --->
<cfset bSMO = 0 />
<!--- DB Sum --->
<cfset nSubSum = 0 />
<cfset nTotSum = 0 />
<cfset nSubCanGrowToSum = 0 />
<cfset nTotCanGrowToSum = 0 />
<!--- NFS Sum --->
<cfset nfsSubSum = 0 />
<cfset nfsTotSum = 0 />
<cfset nfsSubFreeSum = 0 />
<cfset nfsTotFreeSum = 0 />
<cfset showNFSsum = 0 />

<cfsetting enablecfoutputonly="false">
<html>
<head>
	<title><cfoutput>#application.company#</cfoutput> - Oracle Tablespace Reports</title>
<cfinclude template="_otr_css.cfm">
</head>
<body>
<!---<cfinclude template="_top_menu.cfm">--->
<br />
<div align="center">
<h2><cfoutput>#application.company#</cfoutput> - Oracle Tablespace Reports</h2>
<h3><cfoutput>#DateFormat(URL.rep_date,"dd.mm.yyyy")#<cfif IsDefined("URL.rep_cust") AND Trim(URL.rep_cust) GT ""> - #qRepClient.cust_name#</cfif></cfoutput></h3>
<!---<cfoutput query="qReportLinks"><a href="###qReportLinks.db_name#" onFocus="this.blur();">#qReportLinks.db_name#</a> </cfoutput>--->
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
	<th style="text-align: right;"><nobr>Can Grow To (MB)</nobr></th>
	<th style="text-align: right;">Max Free (MB)</th>
	<th style="text-align: right;">% Used</th>
	<th style="text-align: right;">% Real Used</th>
</tr>
<cfoutput><tr<cfif qReport.CurrentRow mod 2> class="alternate"</cfif>>
	<td width="200" align="left">#qReport.db_tbs_name#</td>
	<td width="120" align="right">#LSNumberFormat(qReport.db_tbs_used_mb,"999,999")#<cfset nSubSum = nSubSum + qReport.db_tbs_used_mb /></td>
	<td width="120" align="right">#LSNumberFormat(qReport.db_tbs_free_mb,"999,999.99")#</td>
	<td width="120" align="right">#LSNumberFormat(qReport.db_tbs_can_grow_mb,"999,999")#<cfset nSubCanGrowToSum = nSubCanGrowToSum + qReport.db_tbs_can_grow_mb /></td>
	<td width="120" align="right">#LSNumberFormat(qReport.db_tbs_max_free_mb,"999,999.99")#</td>
	<td width="120" align="right" class="otrtip" title="#LsNumberFormat(qReport.db_tbs_prc_used,"999.09")# %" style="cursor:help;">#LsNumberFormat(round(qReport.db_tbs_prc_used),"999")# %</td>
	<td width="120" align="right" class="otrtip" title="#LsNumberFormat(qReport.db_tbs_real_prc_used,"999.09")# %" style="cursor:help;">#LsNumberFormat(round(qReport.db_tbs_real_prc_used),"999")# %</td>
</tr></cfoutput>
<tr>
	<td align="right">Sub Total (MB):</td>
	<td align="right"><strong><u>#LSNumberFormat(nSubSum,"999,999")#</u></strong></td>
	<td>&nbsp;</td>
	<td align="right"><strong><u>#LSNumberFormat(nSubCanGrowToSum,"999,999")#</u></strong></td>
	<td colspan="2">&nbsp;</td>
	<td align="right"><a href="##top" style="font-size: 7pt; cursor:hand;" onFocus="this.blur();">Top</a></td>
</tr>
<cfquery name="qNFSreport" datasource="#application.datasource#">
	select * 
	from otr_nfs_space_rep
	where db_name = '#qReport.db_name#'
	and   trunc(rep_date) = trunc(to_date('#URL.rep_date#','DD-MM-YYYY'))
	order by trunc(rep_date), db_name, mountpoint
</cfquery>
<tr>
	<td colspan="7">&nbsp;</td>
</tr>
<cfoutput query="qNFSreport"><tr>
	<td align="left">NFS Server: <strong>#qNFSreport.nfs_server#</strong></td>
	<td align="left" colspan="2"<cfif qNFSReport.filesystem CONTAINS 'SnapManager'> class="otrtip" title="#qNFSreport.filesystem#" style="cursor:help; color: rgb(124,43,66);"<cfset bSMO = 1 /></cfif>>Mount: #qNFSreport.mountpoint#</td>
	<td align="right">#LSNumberFormat(qNFSreport.nfs_mb_total,"999,999")#<cfset nfsSubSum = nfsSubSum + qNFSreport.nfs_mb_total /></td>
	<td align="right">#LSNumberFormat(qNFSreport.nfs_mb_free,"999,999")#<cfset nfsSubFreeSum = nfsSubFreeSum + qNFSreport.nfs_mb_free /></td>
	<td align="right">#LsNumberFormat(round(qNFSreport.nfs_prc_used),"999")# %</td>
</tr><cfset nfsTotSum = nfsTotSum + nfsSubSum /><cfset nfsTotFreeSum = nfsTotFreeSum + nfsSubFreeSum /><cfset showNFSsum = 1 /></cfoutput>
<cfif showNFSsum IS 1><tr>
	<td colspan="3">&nbsp;</td>
	<td align="right"><strong><u>#LSNumberFormat(nfsSubSum,"999,999")#</u></strong></td>
	<td align="right"><strong><u>#LSNumberFormat(nfsSubFreeSum,"999,999")#</u></strong></td>
	<td colspan="2">&nbsp;</td>
</tr></cfif>
</table>
<cfset showNFSsum = 0 />
<cfset nfsSubSum = 0 />
<cfset nfsSubFreeSum = 0 />
<cfset nTotSum = nTotSum + nSubSum />
<cfset nSubSum = 0 />
<cfset nTotCanGrowToSum = nTotCanGrowToSum + nSubCanGrowToSum />
<cfset nSubCanGrowToSum = 0 />
<br />
</cfoutput>
<table border="0" cellpadding="2" cellspacing="1">
<tr>
	<td width="200" align="right">Total DB Space Used (MB):</td>
	<td width="120" align="right"><strong><u><cfoutput>#LSNumberFormat(nTotSum,"999,999")#</cfoutput></u></strong></td>
	<td width="120">&nbsp;</td>
	<td width="120" align="right"><strong><u><cfoutput>#LSNumberFormat(nTotCanGrowToSum,"999,999")#</cfoutput></u></strong></td>
	<td colspan="3">&nbsp;</td>
</tr>
<tr>
	<td colspan="7">&nbsp;</td>
</tr>
<tr>
	<td width="200" align="right">Total NFS Space Used (MB):</td>
	<td width="120" align="right"><strong><u><!--- <cfoutput>#LSNumberFormat(nTotSum,"999,999")#</cfoutput>---></u></strong></td>
	<td width="120">&nbsp;</td>
	<td width="120" align="right"><strong><u><cfoutput>#LSNumberFormat(nfsTotSum,"999,999")#</cfoutput></u></strong></td>
	<td width="120" align="right"><strong><u><cfoutput>#LSNumberFormat(nfsTotFreeSum,"999,999")#</cfoutput></u></strong></td>
	<td colspan="2">&nbsp;</td>
</tr>
</table>
	<table border="0" width="100%">
	<tr>
		<td align="right" style="color: red;">
		<strong>% Used</strong> and <strong>% Real Used</strong> are rounded up. Just "Mouse Over" these 2 columns to see the real value with 2 decimal digits<br />
		<strong>NOTE:</strong> NFS Space Usage is without snapshot space calculated!!!<cfif bSMO IS 1>&nbsp;<span style="color: rgb(124,43,66);">Mount: /u01/oradata</span> = SnapManager Clone.</cfif>
		</td>
	</tr>
	</table>
	</td>
</tr>
</table>
</div>
</body>
</html></cfdocument><!---</cfprocessingdirective>--->
