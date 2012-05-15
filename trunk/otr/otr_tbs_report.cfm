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
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"><cfprocessingdirective suppresswhitespace="Yes"><cfsetting enablecfoutputonly="true">
<cftry>
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
<cfif NOT IsDefined("FORM.rep_date")><cflocation url="index.cfm" addtoken="No"></cfif>
<cfif IsDefined("FORM.rep_cust") AND Trim(FORM.rep_cust) GT "">
	<cfquery name="qRepClient" datasource="#Application.datasource#">
		select cust_id, cust_name 
		  from otr_cust 
		 where UPPER(cust_id) = '#UCase(FORM.rep_cust)#'
		order by cust_name
	</cfquery>
</cfif>

<cfquery name="qReport" datasource="#Application.datasource#">
	select distinct a.db_name, b.cust_appl_id, b.cust_id, a.db_tbs_name, trunc(a.rep_date) as rep_date, a.db_tbs_used_mb, a.db_tbs_free_mb, 
    	   a.db_tbs_can_grow_mb, a.db_tbs_max_free_mb, a.db_tbs_prc_used, a.db_tbs_real_prc_used
	  from otr_db_space_rep a, otr_cust_appl_db_tbs_v b
	 where UPPER(a.db_name) = UPPER(b.db_name)
	   and   a.db_tbs_name = b.db_tbs_name
	<cfif IsDefined("FORM.rep_cust") AND Trim(FORM.rep_cust) GT "">and   UPPER(b.cust_id) = '#Trim(UCase(FORM.rep_cust))#'</cfif>
	<cfif qDev IS 0>and   b.db_env <> 'DEV'</cfif>
	<cfif qInt IS 0>and   b.db_env <> 'INT'</cfif>
	   and   trunc(a.rep_date) = trunc(to_date('#FORM.rep_date#','DD-MM-YYYY'))
	order by trunc(a.rep_date), a.db_name, a.db_tbs_name
</cfquery>

<cfquery name="qReportLinks" datasource="#Application.datasource#">
    select distinct a.db_name, trunc(a.rep_date) as rep_date
	  from otr_db_space_rep a, otr_cust_appl_db_tbs_v b
	 where UPPER(a.db_name) = UPPER(b.db_name)
	   and   a.db_tbs_name = b.db_tbs_name
	<cfif IsDefined("FORM.rep_cust") AND Trim(FORM.rep_cust) GT "">and   UPPER(b.cust_id) = '#TrimUCase((FORM.rep_cust))#'</cfif>
	<cfif qDev IS 0>and   b.db_env <> 'DEV'</cfif>
	<cfif qInt IS 0>and   b.db_env <> 'INT'</cfif>
	   and   trunc(a.rep_date) = trunc(to_date('#FORM.rep_date#','DD-MM-YYYY'))
	order by trunc(a.rep_date), a.db_name
</cfquery>
<!--- Generate Excel File --->
<cfset cDirSep = FileSeparator() />
<cfset sPath = ExpandPath('/') />
<cfset sTemplatePath = GetDirectoryfrompath(GetBasetemplatePath()) />

<cfscript>
	stBold = structNew();
	StructInsert(stBold, "bold", True);

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
	
	stTest = structNew();
	structInsert(stTest, "bold", True);
	structInsert(stTest, "alignment", "right");
	structInsert(stTest, "dataformat", "0.000%");

	stTestCol = structNew();
	structInsert(stTestCol, "alignment", "right");
	
</cfscript>
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

<cfset iRow = 0 />
	<cfcatch type="Any">
		<cfdump var="#cfcatch#">
	</cfcatch>
</cftry>

<cftry>
	<!--- Open a Preformated empty Excel Template --->
	<cfset xlsObj = SpreadsheetRead('#sTemplatePath##cDirSep#excel#cDirSep#customer_template.xls',0) />
	<cfset iRow = iRow + 1 />
	<!--- Output Header on the first line --->
	<cfset bDummy = SpreadsheetSetcellvalue(xlsObj, '#Application.company# - Oracle Tablespace Report', #iRow#, 1) />
	<cfset iRow = iRow + 1 />
	<cfset iRow = iRow + 1 />
	<cfset sHeadDate = "" & DateFormat(FORM.rep_date,"dd.mm.yyyy") />
	<cfif IsDefined("FORM.rep_cust") AND Trim(FORM.rep_cust) GT "">
		<cfset sHeadDate = sHeadDate & "- " & qRepClient.cust_name />
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
			<cfset bDummy = SpreadsheetSetcellvalue(xlsObj, #qReport.db_tbs_used_mb#, #iRow#, 2) />
			<cfset bDummy = SpreadsheetSetcellvalue(xlsObj, #qReport.db_tbs_free_mb#, #iRow#, 3) />
			<cfset bDummy = SpreadsheetSetcellvalue(xlsObj, #qReport.db_tbs_can_grow_mb#, #iRow#, 4) />
			<cfset bDummy = SpreadsheetSetcellvalue(xlsObj, #qReport.db_tbs_max_free_mb#, #iRow#, 5) />
			<cfset bDummy = SpreadsheetSetcellvalue(xlsObj, #(qReport.db_tbs_prc_used/100)#, #iRow#, 6) />
			<cfset bDummy = SpreadsheetSetcellvalue(xlsObj, #(qReport.db_tbs_real_prc_used/100)#, #iRow#, 7) />
			<!--- Calculate the Sub Total --->
			<cfset nSubSum = nSubSum + qReport.db_tbs_used_mb>
			<cfset nSubCanGrowToSum = nSubCanGrowToSum + qReport.db_tbs_can_grow_mb>
		</cfoutput>
		<cfset iRow = iRow + 1 />
		<!--- Output Sub Total --->
		<cfset bDummy = SpreadsheetSetcellvalue(xlsObj, 'Sub Total (MB):', #iRow#, 1) />
		<cfset bDummy = SpreadsheetSetcellvalue(xlsObj, #nSubSum#, #iRow#, 2) />
		<cfset bDummy = SpreadsheetSetcellvalue(xlsObj, #Round(nSubCanGrowToSum)#, #iRow#, 4) />
		<!--- Make this row Bold and Right Adjusted --->
		<cfset bDummy = SpreadsheetFormatRow(xlsObj, #stBoldRight10#, #iRow#) />

		<cfquery name="qNFSrep" datasource="#Application.datasource#">
			select * 
			from otr_nfs_space_rep
			where UPPER(db_name) = '#UCase(qReport.db_name)#'
			and   trunc(rep_date) = trunc(to_date('#FORM.rep_date#','DD-MM-YYYY'))
			order by trunc(rep_date), db_name, mountpoint
		</cfquery>
		<cfif qNFSrep.RecordCount IS NOT 0><cfset iRow = iRow + 2 /></cfif>

		<!--- Output NFS Space Usage --->
		<cfoutput query="qNFSrep">
			<cfset bDummy = SpreadsheetSetcellvalue(xlsObj, 'NFS Server: #qNFSrep.nfs_server#', #iRow#, 1) />
			<cfset bDummy = SpreadsheetSetcellvalue(xlsObj, 'Mount: #qNFSrep.mountpoint#', #iRow#, 2) />
			<cfset bDummy = SpreadsheetSetcellvalue(xlsObj, '#Round(qNFSrep.nfs_mb_total)#', #iRow#, 4) />
			<cfset bDummy = SpreadsheetSetcellvalue(xlsObj, '#Round(qNFSrep.nfs_mb_free)#', #iRow#, 5) />
			<cfset bDummy = SpreadsheetSetcellvalue(xlsObj, '#(qNFSrep.nfs_prc_used/100)#', #iRow#, 6) />
			<!--- Make Column 2 Right Adjusted --->
			<cfset bDummy = SpreadsheetFormatCell(xlsObj, #stNormal10#, #iRow#, 2) />
			<!--- Calcuate NFS Sub and Grand Total --->
			<cfset nfsSubSum = nfsSubSum + qNFSrep.nfs_mb_total />
			<cfset nfsSubFreeSum = nfsSubFreeSum + qNFSrep.nfs_mb_free />
			<cfset iRow = iRow + 1 />
			<cfset showNFSsum = 1 />
		</cfoutput>
		<cfset nfsTotSum = nfsTotSum + nfsSubSum />
		<cfset nfsTotFreeSum = nfsTotFreeSum + nfsSubFreeSum />
		<!--- Output NFS Sub Total --->
		<cfif showNFSsum>
			<cfset bDummy = SpreadsheetSetcellvalue(xlsObj, '#Round(nfsSubSum)#', #iRow#, 4) />
			<cfset bDummy = SpreadsheetSetcellvalue(xlsObj, '#Round(nfsSubFreeSum)#', #iRow#, 5) />
			<!--- Make this row Bold and Right Adjusted --->
			<cfset bDummy = SpreadsheetFormatRow(xlsObj, #stBoldRight10#, #iRow#) />
			<cfset iRow = iRow + 1 />
			<cfset showNFSsum = 0 />
		</cfif>

		<cfquery name="qASMrep" datasource="#Application.datasource#">
			select * 
			from otr_asm_space_rep
			where UPPER(db_name) = '#UCase(qReport.db_name)#'
			and   trunc(rep_date) = trunc(to_date('#FORM.rep_date#','DD-MM-YYYY'))
			order by trunc(rep_date), db_name, dg_name
		</cfquery>
		<cfif qASMrep.RecordCount IS NOT 0><cfset iRow = iRow + 2 /></cfif>

		<cfset bDummy = SpreadsheetSetCellValue(xlsObj, 'Disk Group', #iRow#, 1) />
		<cfset bDummy = SpreadsheetSetCellValue(xlsObj, 'Used (MB)', #iRow#, 2) />
		<cfset bDummy = SpreadsheetSetCellValue(xlsObj, 'Free (MB)', #iRow#, 3) />
		<cfset bDummy = SpreadsheetSetCellValue(xlsObj, 'Total (MB)', #iRow#, 4) />
		<cfset bDummy = SpreadsheetSetCellValue(xlsObj, '% Used', #iRow#, 6) />
		<!--- Make this row Bold and Right adjusted --->
		<cfset bDummy = SpreadsheetFormatRow(xlsObj, #stBoldRight10#, #iRow#) />
		<!--- Make the first Cell in this row Bold and Left adjusted --->
		<cfset bDummy = SpreadsheetFormatCell(xlsObj, #stBold10#, #iRow#, 1) />
		<cfset iRow = iRow + 1 />

		<!--- Output ASM Space Usage --->
		<cfoutput query="qASMrep">
			<cfset bDummy = SpreadsheetSetcellvalue(xlsObj, 'Disk Group: #qASMrep.dg_name#', #iRow#, 1) />
			<cfset bDummy = SpreadsheetSetcellvalue(xlsObj, '#Round(qASMrep.asm_mb_used)#', #iRow#, 2) />
			<cfset bDummy = SpreadsheetSetcellvalue(xlsObj, '#Round(qASMrep.asm_mb_free)#', #iRow#, 3) />
			<cfset bDummy = SpreadsheetSetcellvalue(xlsObj, '#qASMrep.asm_mb_total#', #iRow#, 4) />
			<cfset bDummy = SpreadsheetSetcellvalue(xlsObj, '#(qASMrep.asm_prc_used/100)#', #iRow#, 6) />
			<!--- Make Column 2 Right Adjusted --->
			<cfset bDummy = SpreadsheetFormatCell(xlsObj, #stNormal10#, #iRow#, 2) />
			<!--- Calcuate NFS Sub and Grand Total --->
			<cfset asmSubUsedSum = asmSubUsedSum + qASMrep.asm_mb_used />
			<cfset asmSubFreeSum = asmSubFreeSum + qASMrep.asm_mb_free />
			<cfset asmSubTotalSum = asmSubTotalSum + qASMrep.asm_mb_total />
			<cfset iRow = iRow + 1 />
			<cfset showASMsum = 1 />
		</cfoutput>
		<cfset asmTotUsedSum = asmTotUsedSum + asmSubUsedSum />
		<cfset asmTotFreeSum = asmTotFreeSum + asmSubFreeSum />
		<cfset asmTotTotalSum = asmTotTotalSum + asmSubTotalSum />
		<!--- Output ASM Sub Total --->
		<cfif showASMsum>
			<cfset bDummy = SpreadsheetSetcellvalue(xlsObj, '#Round(asmSubUsedSum)#', #iRow#, 2) />
			<cfset bDummy = SpreadsheetSetcellvalue(xlsObj, '#Round(asmSubFreeSum)#', #iRow#, 3) />
			<cfset bDummy = SpreadsheetSetcellvalue(xlsObj, '#Round(asmSubTotalSum)#', #iRow#, 4) />
			<!--- Make this row Bold and Right Adjusted --->
			<cfset bDummy = SpreadsheetFormatRow(xlsObj, #stBoldRight10#, #iRow#) />
			<cfset iRow = iRow + 1 />
			<cfset showNFSsum = 0 />
		</cfif>

		<!--- Calculate the Total Sum --->
		<cfset nfsSubSum = 0 />
		<cfset nfsSubFreeSum = 0 />
		<cfset asmSubUsedSum = 0 />
		<cfset asmSubFreeSum = 0 />
		<cfset asmSubTotalSum = 0 />
		<cfset nTotSum = nTotSum + nSubSum />
		<cfset nSubSum = 0 />
		<cfset nTotCanGrowToSum = nTotCanGrowToSum + nSubCanGrowToSum />
		<cfset nSubCanGrowToSum = 0 />
		<cfset iRow = iRow + 1 />
	</cfoutput>
	<cfset iRow = iRow + 1 />
	<!--- Output the Grand Total for DB Space Usage --->
	<cfset bDummy = SpreadsheetSetcellvalue(xlsObj, 'Total DB Space Used (MB):', #iRow#, 1) />
	<cfset bDummy = SpreadsheetSetcellvalue(xlsObj, #Round(nTotSum)#, #iRow#, 2) />
	<cfset bDummy = SpreadsheetSetcellvalue(xlsObj, #Round(nTotCanGrowToSum)#, #iRow#, 4) />
	<!--- Make this row Bold and Right Adjusted --->
	<cfset bDummy = SpreadsheetFormatRow(xlsObj, #stBoldRight10#, #iRow#) />

	<cfif qNFSrep.RecordCount GT 0>
		<cfset iRow = iRow + 2 />
		<!--- Output the Grand Total for NFS Space Usage --->
		<cfset bDummy = SpreadsheetSetcellvalue(xlsObj, 'Total NFS Space Used (MB):', #iRow#, 1) />
		<cfset bDummy = SpreadsheetSetcellvalue(xlsObj, '#Round(nfsTotSum)#', #iRow#, 4) />
		<cfset bDummy = SpreadsheetSetcellvalue(xlsObj, '#Round(nfsTotFreeSum)#', #iRow#, 5) />
		<!--- Make this row Bold and Right Adjusted --->
		<cfset bDummy = SpreadsheetFormatRow(xlsObj, #stBoldRight10#, #iRow#) />
	</cfif>

	<cfif qASMrep.RecordCount GT 0>
		<cfset iRow = iRow + 2 />
		<!--- Output the Grand Total for ASM Space Usage --->
		<cfset bDummy = SpreadsheetSetcellvalue(xlsObj, 'Total ASM Space Used (MB):', #iRow#, 1) />
		<cfset bDummy = SpreadsheetSetcellvalue(xlsObj, '#Round(asmTotUsedSum)#', #iRow#, 2) />
		<cfset bDummy = SpreadsheetSetcellvalue(xlsObj, '#Round(asmTotFreeSum)#', #iRow#, 3) />
		<cfset bDummy = SpreadsheetSetcellvalue(xlsObj, '#Round(asmTotTotalSum)#', #iRow#, 4) />
		<!--- Make this row Bold and Right Adjusted --->
		<cfset bDummy = SpreadsheetFormatRow(xlsObj, #stBoldRight10#, #iRow#) />
	</cfif>
	<!--- Save the Excel File under the name of customer_report.xls (For Excel 97 - 2003) --->
	<cfset bDummy = SpreadsheetWrite (xlsObj, '#sTemplatePath##cDirSep#excel#cDirSep#customer_report.xls', true) />
	<cfcatch type="any">
		<cfdump var="#cfcatch#">
		<cfdump var="#xlsObj#">
	</cfcatch>
</cftry>
<!---- Excel File ganarated --->

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

<cfsetting enablecfoutputonly="false">
<html>
<head>
	<title><cfoutput>#Application.company#</cfoutput> - Oracle Tablespace Report</title>
<cfinclude template="_otr_css.cfm">
<script type="text/javascript">
<!--
function makeDisableSubmit(){
    /*var x=document.getElementById("qSubmit");
    x.disabled=true;*/
}
function makeEnableSubmit(){
    var x=document.getElementById("qSubmit");
    x.disabled=false;
}
function makeDisable(){
    var x=document.getElementById("from_date");
    x.disabled=true;
    var y=document.getElementById("to_date");
    y.disabled=true;
}
function makeEnable(){
    var x=document.getElementById("from_date");
    x.disabled=false;
    var y=document.getElementById("to_date");
    y.disabled=false;
}
function toggle_select(){
	if (document.getElementById("monthly").checked) {
		makeDisable();
	} else {
		makeEnable();
	}
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
			document.snapshot.location = 'otr_tbs_newsnapshot.cfm';
		} 
		else { // IE 4 
			document.all.loaderDiv.style.visibility = 'visible'; 
			document.all.snapshot.location = 'otr_tbs_newsnapshot.cfm';
		} 
	} 
} 
// -->
</script>
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
<h2><cfoutput>#Application.company#</cfoutput> - Oracle Tablespace Report</h2>
<h3><cfoutput>#LSDateFormat(DateFormat(FORM.rep_date,"dd.mm.yyyy"), 'short')#<cfif IsDefined("FORM.rep_cust") AND Trim(FORM.rep_cust) GT ""> - #qRepClient.cust_name#</cfif></cfoutput></h3>
<cfoutput query="qReportLinks"><a href="###qReportLinks.db_name#" onFocus="this.blur();">#qReportLinks.db_name#</a> </cfoutput>
</div>
<div align="center">
<a href="excel/customer_report.xls" target="_blank" class="otrtip" title="<div align='center'>Save output as an<br />Excel Document</div>">customer_report.xls&nbsp;<img src="images/xls.png" alt="" width="16" height="16" border="0"></a>
<cfoutput><a href="otr_tbs_report_pdf.cfm?rep_date=#FORM.rep_date#<cfif IsDefined("FORM.development")>&development=#FORM.development#</cfif><cfif IsDefined("FORM.internal")>&internal=#FORM.internal#</cfif><cfif IsDefined("FORM.rep_cust") AND Trim(FORM.rep_cust) GT "">&rep_cust=#FORM.rep_cust#</cfif>" target="_blank" class="otrtip" title="<div align='center'>Save output as a<br />PDF Document</div>">as PDF&nbsp;<img src="images/pdficon_small.gif" alt="" width="17" height="17" border="0"></a></cfoutput>
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
	<td width="200">#qReport.db_tbs_name#</td>
	<td width="120" style="text-align: right;">#LSNumberFormat(qReport.db_tbs_used_mb,"999,999")#<cfset nSubSum = nSubSum + qReport.db_tbs_used_mb /></td>
	<td width="120" style="text-align: right;">#LSNumberFormat(qReport.db_tbs_free_mb,"999,999.99")#</td>
	<td width="120" style="text-align: right;">#LSNumberFormat(qReport.db_tbs_can_grow_mb,"999,999")#<cfset nSubCanGrowToSum = nSubCanGrowToSum + qReport.db_tbs_can_grow_mb /></td>
	<td width="120" style="text-align: right;">#LSNumberFormat(qReport.db_tbs_max_free_mb,"999,999.99")#</td>
	<td width="120" style="cursor:help; text-align: right;" class="otrtip" title="#LsNumberFormat(qReport.db_tbs_prc_used,"999.09")# %">#LsNumberFormat(round(qReport.db_tbs_prc_used),"999")# %</td>
	<td width="120" style="cursor:help; text-align: right;" class="otrtip" title="#LsNumberFormat(qReport.db_tbs_real_prc_used,"999.09")# %">#LsNumberFormat(round(qReport.db_tbs_real_prc_used),"999")# %</td>
</tr></cfoutput>
<tr>
	<td align="right">Sub Total (MB):</td>
	<td align="right"><strong><u>#LSNumberFormat(nSubSum,"999,999")#</u></strong></td>
	<td>&nbsp;</td>
	<td align="right"><strong><u>#LSNumberFormat(nSubCanGrowToSum,"999,999")#</u></strong></td>
	<td colspan="2">&nbsp;</td>
	<td align="right"><a href="##top" style="font-size: 7pt; cursor:hand;" onFocus="this.blur();">Top</a></td>
</tr>
<cfquery name="qNFSreport" datasource="#Application.datasource#">
	select * 
	from otr_nfs_space_rep
	where UPPER(db_name) = '#UCase(qReport.db_name)#'
	and   trunc(rep_date) = trunc(to_date('#FORM.rep_date#','DD-MM-YYYY'))
	order by trunc(rep_date), db_name, mountpoint
</cfquery>
<cfif qNFSreport.RecordCount GT 0><tr>
	<td colspan="7">&nbsp;</td>
</tr></cfif>
<cfoutput query="qNFSreport"><tr<cfif qNFSreport.CurrentRow mod 2> class="alternate"</cfif>>
	<td style="text-align: left;">NFS Server: <strong>#qNFSreport.nfs_server#</strong></td>
	<td align="left" colspan="2"<cfif qNFSReport.filesystem CONTAINS 'SnapManager'> class="otrtip" title="#qNFSreport.filesystem#" style="cursor:help; color: rgb(124,43,66);"<cfset bSMO = 1 /></cfif>>Mount: #qNFSreport.mountpoint#</td>
	<td style="text-align: right;">#LSNumberFormat(qNFSreport.nfs_mb_total,"999,999")#<cfset nfsSubSum = nfsSubSum + qNFSreport.nfs_mb_total /></td>
	<td style="text-align: right;">#LSNumberFormat(qNFSreport.nfs_mb_free,"999,999")#<cfset nfsSubFreeSum = nfsSubFreeSum + qNFSreport.nfs_mb_free /></td>
	<td style="text-align: right;">#LsNumberFormat(round(qNFSreport.nfs_prc_used),"999")# %</td>
</tr><cfset showNFSsum = 1 /></cfoutput>
<cfif showNFSsum IS 1><tr>
	<td colspan="3">&nbsp;</td>
	<td style="text-align: right; font-weight: bold; text-decoration:underline;">#LSNumberFormat(nfsSubSum,"999,999")#</td>
	<td style="text-align: right; font-weight: bold; text-decoration:underline;<cfif nSubCanGrowToSum GT nfsSubFreeSum> color: red;</cfif>"<cfif nSubCanGrowToSum GT nfsSubFreeSum> class="otrtip" title="<div align='center'>Storage space is<br /><strong>smaller</strong> than possible<br />Database space!!!</div>"</cfif>>#LSNumberFormat(nfsSubFreeSum,"999,999")#</td>
	<td colspan="2">&nbsp;</td>
</tr><cfset nfsTotSum = nfsTotSum + nfsSubSum /><cfset nfsTotFreeSum = nfsTotFreeSum + nfsSubFreeSum /></cfif>
<cfquery name="qASMreport" datasource="#Application.datasource#">
	select * 
	from otr_asm_space_rep
	where UPPER(db_name) = '#UCase(qReport.db_name)#'
	and   trunc(rep_date) = trunc(to_date('#FORM.rep_date#','DD-MM-YYYY'))
	order by trunc(rep_date), db_name, dg_name
</cfquery>
<tr>
	<td colspan="7">&nbsp;</td>
</tr>
<cfif qASMreport.RecordCount GT 0><tr>
	<td style="text-align: left; font-weight: bold;">Disk Group</td>
	<td style="text-align: right; font-weight: bold;">Used (MB)</td>
	<td style="text-align: right; font-weight: bold;">Free (MB)</td>
	<td style="text-align: right; font-weight: bold;">Total (MB)</td>
	<td>&nbsp;</td>
	<td style="text-align: right; font-weight: bold;">% Used</td>
	<td>&nbsp;</td>
</tr></cfif>
<cfoutput query="qASMreport"><tr<cfif qASMreport.CurrentRow mod 2> class="alternate"</cfif>>
	<td align="left">#qASMreport.dg_name#</td>
	<td style="text-align: right;">#LSNumberFormat(qASMreport.asm_mb_used, "999,999")#<cfset asmSubUsedSum = asmSubUsedSum + qASMreport.asm_mb_used /></td>
	<td style="text-align: right;">#LSNumberFormat(qASMreport.asm_mb_free, "999,999")#<cfset asmSubFreeSum = asmSubFreeSum + qASMreport.asm_mb_free /></td>
	<td style="text-align: right;">#LSNumberFormat(qASMreport.asm_mb_total, "999,999")#<cfset asmSubTotalSum = asmSubTotalSum + qASMreport.asm_mb_Total /></td>
	<td>&nbsp;</td>
	<td class="otrtip" title="#LsNumberFormat(qASMreport.asm_prc_used,"999.09")# %" style="cursor:help; text-align: right;">#LsNumberFormat(round(qASMreport.asm_prc_used),"999")# %</td>
	<td>&nbsp;</td>
</tr><cfset showASMsum = 1 /></cfoutput>
<cfif showASMsum IS 1><tr>
	<td style="text-align: right;">Sub Total (MB):</td>
	<td style="text-align: right; font-weight: bold; text-decoration:underline;">#LSNumberFormat(asmSubUsedSum,"999,999")#</td>
	<td style="text-align: right; font-weight: bold; text-decoration:underline;">#LSNumberFormat(asmSubFreeSum,"999,999")#</td>
	<td style="text-align: right; font-weight: bold; text-decoration:underline;<cfif nSubCanGrowToSum GT asmSubTotalSum> color: red; cursor: help;</cfif>"<cfif nSubCanGrowToSum GT asmSubTotalSum> class="otrtip" title="<div align='center'>Storage space is<br /><strong>smaller</strong> than possible<br />Database space!!!</div>"</cfif>>#LSNumberFormat(asmSubTotalSum,"999,999")#</td>
	<td colspan="3">&nbsp;</td>
</tr><cfset asmTotUsedSum = (asmTotUsedSum + asmSubUsedSum) /><cfset asmTotFreeSum = asmTotFreeSum + asmSubFreeSum /><cfset asmTotTotalSum = asmTotTotalSum + asmSubTotalSum /></cfif>
</table>
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
<br />
</cfoutput>
<table border="0" cellpadding="2" cellspacing="1">
<tr>
	<td width="200" style="text-align: right;">Total DB Space Used (MB):</td>
	<td width="120" style="text-align: right; font-weight: bold; text-decoration:underline;"><cfoutput>#LSNumberFormat(nTotSum,"999,999")#</cfoutput></td>
	<td width="120">&nbsp;</td>
	<td width="120" style="text-align: right; font-weight: bold; text-decoration:underline;"><cfoutput>#LSNumberFormat(nTotCanGrowToSum,"999,999")#</cfoutput></td>
	<td colspan="3">&nbsp;</td>
</tr><cfif qNFSrep.RecordCount GT 0>
<tr>
	<td colspan="7">&nbsp;</td>
</tr>
<tr>
	<td width="200" style="text-align: right;">Total NFS Space Used (MB):</td>
	<td width="120" style="text-align: right; font-weight: bold; text-decoration:underline;"><!--- <cfoutput>#LSNumberFormat(nTotSum,"999,999")#</cfoutput>---></td>
	<td width="120">&nbsp;</td>
	<td width="120" style="text-align: right; font-weight: bold; text-decoration:underline;"><cfoutput>#LSNumberFormat(nfsTotSum,"999,999")#</cfoutput></td>
	<td width="120" style="text-align: right; font-weight: bold; text-decoration:underline;"><cfoutput>#LSNumberFormat(nfsTotFreeSum,"999,999")#</cfoutput></td>
	<td colspan="2">&nbsp;</td>
</tr></cfif><cfif qASMreport.RecordCount GT 0>
<tr>
	<td width="200" style="text-align: right;">Total ASM Space Used (MB):</td>
	<td width="120" style="text-align: right; font-weight: bold; text-decoration:underline;"><cfoutput>#LSNumberFormat(asmTotUsedSum,"999,999")#</cfoutput></td>
	<td width="120" style="text-align: right; font-weight: bold; text-decoration:underline;"><cfoutput>#LSNumberFormat(asmTotFreeSum,"999,999")#</cfoutput></td>
	<td width="120" style="text-align: right; font-weight: bold; text-decoration:underline;"><cfoutput>#LSNumberFormat(asmTotTotalSum,"999,999")#</cfoutput></td>
	<td colspan="2">&nbsp;</td>
</tr></cfif>
</table>
	<table border="0" width="100%">
	<tr>
		<td align="right" style="color: red;">
		<strong>% Used</strong> and <strong>% Real Used</strong> are rounded up. Just "Mouse Over" these 2 columns to see the real value with 2 decimal digits<cfif qNFSrep.RecordCount GT 0><br />
		<strong>NOTE:</strong> NFS Space Usage is without snapshot space calculated!!!<cfif bSMO IS 1>&nbsp;<span style="color: rgb(124,43,66);">Mount: /u01/oradata</span> = SnapManager Clone.</cfif></cfif>
		</td>
	</tr>
	</table>
	</td>
</tr>
<tr>
	<td align="center" colspan="2" style="font-size: 8pt; text-align: center;">
<cfinclude template="_footer.cfm" />
	</td>
</tr>
</table>
</div>
<a href="index.cfm" onfocus="this.blur();">Back to Main</a>
</body>
</html></cfprocessingdirective>
