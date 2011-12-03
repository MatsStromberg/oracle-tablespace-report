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
<!--- Is It a Snapshot Day and was it started Manually? --->
<cfif IsDefined("URL.MENU") AND DayOfWeek(Now()) IS application.snapshot_day>
<cfoutput>
<script language="JavaScript">
top.location.replace("#caller_url#");
</script>
</cfoutput>
</cfif>
<!--- <cfoutput>#URL.MENU# - #DayOfWeek(Now())# - #application.snapshot_day# - #CGI.caller_url#</cfoutput><cfabort> --->

<!--- <cfif DayOfWeek(Now()) IS application.snapshot_day><cflocation url="http://minerva/ogc/index.cfm" addtoken="No"></cfif> --->
<cfset caller_url = Trim(CGI.HTTP_REFERER)>
<!--- Delete any snapshot done TODAY --->
<cfset dToday = DateFormat(Now(),'dd.mm.yyyy')>
<cfoutput>#dToday#<br />#CGI.HTTP_REFERER#</cfoutput>
<cfquery name="qDelete" datasource="#application.datasource#">
	delete from otr_db_space_rep a
	where   trunc(a.rep_date) = trunc(to_date('#dToday#','DD-MM-YYYY'))
</cfquery>
<cfquery name="qDelete2" datasource="#application.datasource#">
	delete from otr_nfs_space_rep a
	where   trunc(a.rep_date) = trunc(to_date('#dToday#','DD-MM-YYYY'))
</cfquery>

<!--- Generate a TBS Snapshot using the Stored Procedure OTR_ReportingProc --->
<CFSTOREDPROC PROCEDURE="OTRREP.OTR_ReportingProc" DATASOURCE="OGC_SYSMAN">
</CFSTOREDPROC>

<cfsetting enablecfoutputonly="false">
<html>
<head>
	<title><cfoutput>#application.company#</cfoutput>Creating Tablespace Snapshot</title>
<cfinclude template="_otr_css.cfm">
</head>
<body>
<cfinclude template="_top_menu.cfm">
<br />
<div align="center">
<h2>PLEASE WAIT...</h2>
</div>

<!--- <cflocation url="index.cfm" addtoken="No"> --->
<cfoutput>
<script language="JavaScript">
top.location.replace("#caller_url#");
</script>
</cfoutput>
</body>
</html></cfprocessingdirective>
