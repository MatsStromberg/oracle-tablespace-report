<cfdocument format="pdf" pagetype="A4"> <!-- filename="/tmp/pdftest.pdf" overwrite="true"> -->
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
	<cfquery name="qRepClient" datasource="#Application.datasource#">
		select cust_id, cust_name 
		from otr_cust 
		where UPPER(cust_id) = '#UCase(URL.rep_cust)#'
		order by cust_name
	</cfquery>
</cfif>

<cfquery name="qReport" datasource="#Application.datasource#">
	select distinct a.db_name, b.cust_appl_id, b.cust_id, a.db_tbs_name, trunc(a.rep_date) as rep_date, a.db_tbs_used_mb, a.db_tbs_free_mb, 
    	   a.db_tbs_can_grow_mb, a.db_tbs_max_free_mb, a.db_tbs_prc_used, a.db_tbs_real_prc_used
	from otr_db_space_rep a, otr_cust_appl_db_tbs_v b
	where UPPER(a.db_name) = UPPER(b.db_name)
	and   a.db_tbs_name = b.db_tbs_name
	<cfif IsDefined("URL.rep_cust") AND Trim(URL.rep_cust) GT "">and   b.cust_id = '#Trim(URL.rep_cust)#'</cfif>
	<cfif qDev IS 0>and   b.db_env <> 'DEV'</cfif>
	<cfif qInt IS 0>and   b.db_env <> 'INT'</cfif>
	and   trunc(a.rep_date) = trunc(to_date('#URL.rep_date#','DD-MM-YYYY'))
	order by trunc(a.rep_date), a.db_name, a.db_tbs_name
</cfquery>

<cfquery name="qReportLinks" datasource="#Application.datasource#">
    select distinct a.db_name, trunc(a.rep_date) as rep_date
	from otr_db_space_rep a, otr_cust_appl_db_tbs_v b
	where UPPER(a.db_name) = UPPER(b.db_name)
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
<!--- ASM Sum --->
<cfset asmSubUsedSum = 0 />
<cfset asmTotUsedSum = 0 />
<cfset asmSubFreeSum = 0 />
<cfset asmTotFreeSum = 0 />
<cfset asmSubTotalSum = 0 />
<cfset asmTotTotalSum = 0 />
<cfset showASMsum = 0 />

<!--- Set the Date Format to Localized Format --->
<cfset dummy = SetLocale("#Application.locale_string#") />
<cfsetting enablecfoutputonly="false">
<html>
<head>
	<title><cfoutput>#Application.company#</cfoutput> - Oracle Tablespace Reports</title>
<cfinclude template="_otr_css.cfm">
<style type="text/css">
	body { background-color:#FFFFFF; }
</style>
</head>
<body>
<!---<cfinclude template="_top_menu.cfm">--->
<br />
<div align="center">
<h2><cfoutput>#Application.company#</cfoutput> - Oracle Tablespace Reports</h2>
<h3><cfoutput>#LSDateFormat(DateFormat(URL.rep_date,"dd.mm.yyyy"), 'medium')#<cfif IsDefined("URL.rep_cust") AND Trim(URL.rep_cust) GT ""> - #qRepClient.cust_name#</cfif></cfoutput></h3>
<!---<cfoutput query="qReportLinks"><a href="###qReportLinks.db_name#" onFocus="this.blur();">#qReportLinks.db_name#</a> </cfoutput>--->
</div>
<div align="center">
<table border="0" cellpadding="5">
<tr>
	<td class="bodyline">
<cfoutput query="qReport" group="db_name">
<!---
<table border="0" cellpadding="0" cellspacing="0">
<tr>
	<td width="220" style="font-size: 12pt;font-weight: bold;">DB: #qReport.db_name#</td>
	<td style="font-size: 12pt;font-weight: bold;">Client App(s): #qReport.cust_appl_id#</td>
</tr>
</table>
<br />
--->
<table border="0" cellpadding="2" cellspacing="1">
<tr>
	<td colspan="2" style="font-size: 12pt;font-weight: bold;">DB: #qReport.db_name#</td>
	<td colspan="5" style="font-size: 12pt;font-weight: bold;">Client App(s): #qReport.cust_appl_id#</td>
</tr>
<tr>
	<td width="220" style="font-size: 7pt; text-align: left; font-weight: bold;">TABLESPACE</td>
	<td width="120" style="font-size: 7pt; text-align: right; font-weight: bold;">Used (MB)</td>
	<td width="120" style="font-size: 7pt; text-align: right; font-weight: bold;">Free (MB)</td>
	<td width="120" style="font-size: 7pt; text-align: right; font-weight: bold;"><nobr>Can Grow To (MB)</nobr></td>
	<td width="120" style="font-size: 7pt; text-align: right; font-weight: bold;">Max Free (MB)</td>
	<td width="120" style="font-size: 7pt; text-align: right; font-weight: bold;">% Used</td>
	<td width="120" style="font-size: 7pt; text-align: right; font-weight: bold;">% Real Used</td>
</tr>
<cfoutput><tr<cfif qReport.CurrentRow mod 2> class="alternate"</cfif>>
	<td width="220" style="font-size: 8pt; text-align: left;">#qReport.db_tbs_name#</td>
	<td width="120" style="font-size: 8pt; text-align: right;">#LSNumberFormat(qReport.db_tbs_used_mb,"999,999")#<cfset nSubSum = nSubSum + qReport.db_tbs_used_mb /></td>
	<td width="120" style="font-size: 8pt; text-align: right;">#LSNumberFormat(qReport.db_tbs_free_mb,"999,999.99")#</td>
	<td width="120" style="font-size: 8pt; text-align: right;">#LSNumberFormat(qReport.db_tbs_can_grow_mb,"999,999")#<cfset nSubCanGrowToSum = nSubCanGrowToSum + qReport.db_tbs_can_grow_mb /></td>
	<td width="120" style="font-size: 8pt; text-align: right;">#LSNumberFormat(qReport.db_tbs_max_free_mb,"999,999.99")#</td>
	<td width="120" style="font-size: 8pt; text-align: right;">#LsNumberFormat(round(qReport.db_tbs_prc_used),"999")# %</td>
	<td width="120" style="font-size: 8pt; text-align: right;">#LsNumberFormat(round(qReport.db_tbs_real_prc_used),"999")# %</td>
</tr></cfoutput>
<tr>
	<td width="220" style="font-size: 8pt; text-align: right;">Sub Total (MB):</td>
	<td style="font-size: 8pt; text-align: right; font-weight: bold; text-decoration:underline;">#LSNumberFormat(nSubSum,"999,999")#</td>
	<td>&nbsp;</td>
	<td style="font-size: 8pt; text-align: right; font-weight: bold; text-decoration:underline;">#LSNumberFormat(nSubCanGrowToSum,"999,999")#</td>
	<td colspan="3">&nbsp;</td>
</tr>
<cfquery name="qNFSreport" datasource="#Application.datasource#">
	select * 
	from otr_nfs_space_rep
	where UPPER(db_name) = '#UCase(qReport.db_name)#'
	and   trunc(rep_date) = trunc(to_date('#URL.rep_date#','DD-MM-YYYY'))
	order by trunc(rep_date), db_name, mountpoint
</cfquery>
<cfif qNFSreport.RecordCount GT 0><tr>
	<td colspan="7">&nbsp;</td>
</tr>
</cfif>
<cfoutput query="qNFSreport"><tr<cfif qNFSreport.CurrentRow mod 2> class="alternate"</cfif>>
	<td width="220" style="font-size: 8pt; text-align: left;">NFS Server: <strong>#qNFSreport.nfs_server#</strong></td>
	<td colspan="2" style="font-size: 8pt; text-align: left;<cfif qNFSReport.filesystem CONTAINS 'SnapManager'> color: rgb(124,43,66);</cfif>"<cfif qNFSReport.filesystem CONTAINS 'SnapManager'><cfset bSMO = 1 /></cfif>>Mount: #qNFSreport.mountpoint#</td>
	<td style="font-size: 8pt; text-align: right;">#LSNumberFormat(qNFSreport.nfs_mb_total,"999,999")#<cfset nfsSubSum = nfsSubSum + qNFSreport.nfs_mb_total /></td>
	<td style="font-size: 8pt; text-align: right;">#LSNumberFormat(qNFSreport.nfs_mb_free,"999,999")#<cfset nfsSubFreeSum = nfsSubFreeSum + qNFSreport.nfs_mb_free /></td>
	<td style="font-size: 8pt; text-align: right;">#LsNumberFormat(round(qNFSreport.nfs_prc_used),"999")# %</td>
</tr><cfset showNFSsum = 1 /></cfoutput>
<cfif showNFSsum IS 1><tr>
	<td colspan="3">&nbsp;</td>
	<td style="font-size: 8pt; text-align: right; font-weight: bold; text-decoration:underline;">#LSNumberFormat(nfsSubSum,"999,999")#</td>
	<td style="font-size: 8pt; text-align: right; font-weight: bold; text-decoration:underline;">#LSNumberFormat(nfsSubFreeSum,"999,999")#</td>
	<td colspan="2">&nbsp;</td>
</tr><cfset nfsTotSum = nfsTotSum + nfsSubSum /><cfset nfsTotFreeSum = nfsTotFreeSum + nfsSubFreeSum /></cfif>
<cfquery name="qASMreport" datasource="#Application.datasource#">
	select * 
	from otr_asm_space_rep
	where UPPER(db_name) = '#UCase(qReport.db_name)#'
	and   trunc(rep_date) = trunc(to_date('#URL.rep_date#','DD-MM-YYYY'))
	order by trunc(rep_date), db_name, dg_name
</cfquery>
<cfif qASMreport.RecordCount GT 0><tr>
	<td colspan="7">&nbsp;</td>
</tr>
<tr>
	<td width="220" style="font-size: 7pt; text-align: left; font-weight: bold;">Disk Group</td>
	<td style="font-size: 7pt; text-align: right; font-weight: bold;">Used (MB)</td>
	<td style="font-size: 7pt; text-align: right; font-weight: bold;">Free (MB)</td>
	<td style="font-size: 7pt; text-align: right; font-weight: bold;">Total (MB)</td>
	<td>&nbsp;</td>
	<td style="font-size: 7pt; text-align: right; font-weight: bold;">% Used</td>
	<td>&nbsp;</td>
</tr></cfif>
<cfoutput query="qASMreport"><tr<cfif qASMreport.CurrentRow mod 2> class="alternate"</cfif>>
	<td width="220" align="left">#qASMreport.dg_name#</td>
	<td style="font-size: 8pt; text-align: right;">#LSNumberFormat(qASMreport.asm_mb_used, "999,999")#<cfset asmSubUsedSum = asmSubUsedSum + qASMreport.asm_mb_used /></td>
	<td style="font-size: 8pt; text-align: right;">#LSNumberFormat(qASMreport.asm_mb_free, "999,999")#<cfset asmSubFreeSum = asmSubFreeSum + qASMreport.asm_mb_free /></td>
	<td style="font-size: 8pt; text-align: right;">#LSNumberFormat(qASMreport.asm_mb_total, "999,999")#<cfset asmSubTotalSum = asmSubTotalSum + qASMreport.asm_mb_Total /></td>
	<td>&nbsp;</td>
	<td align="right">#LsNumberFormat(round(qASMreport.asm_prc_used),"999")# %</td>
	<td>&nbsp;</td>
</tr><cfset showASMsum = 1 /></cfoutput>
<cfif showASMsum IS 1><tr>
	<td width="220">&nbsp;</td>
	<td style="font-size: 8pt; text-align: right; font-weight: bold; text-decoration:underline;">#LSNumberFormat(asmSubUsedSum,"999,999")#</td>
	<td style="font-size: 8pt; text-align: right; font-weight: bold; text-decoration:underline;">#LSNumberFormat(asmSubFreeSum,"999,999")#</td>
	<td style="font-size: 8pt; text-align: right; font-weight: bold; text-decoration:underline;">#LSNumberFormat(asmSubTotalSum,"999,999")#</td>
	<td colspan="3">&nbsp;</td>
</tr><cfset asmTotUsedSum = (asmTotUsedSum + asmSubUsedSum) /><cfset asmTotFreeSum = asmTotFreeSum + asmSubFreeSum /><cfset asmTotTotalSum = asmTotTotalSum + asmSubTotalSum /></cfif>
<!--- </table> --->
<cfset showNFSsum = 0 />
<cfset nfsSubSum = 0 />
<cfset nfsSubFreeSum = 0 />
<cfset showASMsum = 0 />
<cfset asmSubUsedSum = 0 />
<cfset asmSubFreeSum = 0 />
<cfset asmSubTotalSum = 0 />
<cfset nTotSum = nTotSum + nSubSum />
<cfset nSubSum = 0 />
<cfset nTotCanGrowToSum = nTotCanGrowToSum + nSubCanGrowToSum />
<cfset nSubCanGrowToSum = 0 />
<!--- <br /> --->
</cfoutput>
<!--- <table border="0" cellpadding="2" cellspacing="1"> --->
<tr>
	<td width="220" align="right">Total DB Space Used (MB):</td>
	<td width="120" align="right"><strong><u><cfoutput>#LSNumberFormat(nTotSum,"999,999")#</cfoutput></u></strong></td>
	<td width="120">&nbsp;</td>
	<td width="120" align="right"><strong><u><cfoutput>#LSNumberFormat(nTotCanGrowToSum,"999,999")#</cfoutput></u></strong></td>
	<td width="120">&nbsp;</td>
	<td width="120">&nbsp;</td>
	<td width="120">&nbsp;</td>
</tr><cfif qNFSreport.RecordCount GT 0>
<!--- <tr>
	<td colspan="7">&nbsp;</td>
</tr> --->
<tr>
	<td width="220" align="right">Total NFS Space Used (MB):</td>
	<td width="120" align="right"><strong><u><!--- <cfoutput>#LSNumberFormat(nTotSum,"999,999")#</cfoutput>---></u></strong></td>
	<td width="120">&nbsp;</td>
	<td width="120" align="right"><strong><u><cfoutput>#LSNumberFormat(nfsTotSum,"999,999")#</cfoutput></u></strong></td>
	<td width="120" align="right"><strong><u><cfoutput>#LSNumberFormat(nfsTotFreeSum,"999,999")#</cfoutput></u></strong></td>
	<td colspan="2">&nbsp;</td>
</tr></cfif><cfif qASMreport.RecordCount GT 0>
<tr>
	<td width="220" align="right">Total ASM Space Used (MB):</td>
	<td width="120" align="right"><strong><u><cfoutput>#LSNumberFormat(asmTotUsedSum,"999,999")#</cfoutput></u></strong></td>
	<td width="120" align="right"><strong><u><cfoutput>#LSNumberFormat(asmTotFreeSum,"999,999")#</cfoutput></u></strong></td>
	<td width="120" align="right"><strong><u><cfoutput>#LSNumberFormat(asmTotTotalSum,"999,999")#</cfoutput></u></strong></td>
	<td colspan="3">&nbsp;</td>
</tr></cfif>
</table>
	<table border="0" width="100%">
	<tr>
		<td align="right" style="color: red; font-size: 6pt;">
		<strong>% Used</strong> and <strong>% Real Used</strong> are rounded up.<cfif qNFSreport.RecordCount GT 0><br />
		<strong>NOTE:</strong> NFS Space Usage is without snapshot space calculated!!!<cfif bSMO IS 1>&nbsp;<span style="color: rgb(124,43,66);">Mount: /u01/oradata</span> = SnapManager Clone.</cfif></cfif>
		</td>
	</tr>
	</table>
	</td>
</tr>
</table>
</div>
</body>
</html></cfdocument><!---</cfprocessingdirective>--->
