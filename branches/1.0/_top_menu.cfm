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
<cfsetting enablecfoutputonly="true" /><cfquery name="qRepDateMax" datasource="#application.datasource#">
	select rep_date 
	from otr_space_rep_max_timestamp_v 
	order by rep_date desc
</cfquery>
<cfset dummy = SetLocale("English (United States)")>
<cfsetting enablecfoutputonly="false" /><a name="top"></a><table border="0" width="100%">
<table border="0" width="100%">
<tr>
	<cfif CGI.SCRIPT_NAME IS "/index.cfm" OR CGI.SCRIPT_NAME IS "/otr/index.cfm"><td valign="top" width="100"><!--- <a href="../index.cfm" class="otrtip" title="<div align='center'>Back to the<br />Services<br />main menu</div>" onfocus="this.blur();">Back to Main</a> ---></td><cfelse><td align="center" valign="top" width="100"><a href="index.cfm" class="otrtip" title="<div align='center'>Back to the<br />main menu</div>" onfocus="this.blur();">Back to Main</a></td></cfif>
	<td align="center" valign="top" width="100"><a href="otr_cust.cfm" class="otrtip" title="<div align='center'>Customers with<br>Mandator Info</div>" onfocus="this.blur();">Customers</a></td>
	<td align="center" valign="top" width="100"><a href="otr_db.cfm" class="otrtip" title="<div align='center'>DB Instances and<br />the Type there of...<br />SEE = Shared Enterprise Edition,<br />DEE = Dedicated Enterprise Edition,<br />DEV = Development Servers or<br />INT = Internally Used</div>" onfocus="this.blur();">DB Instances</a></td>
	<td align="center" valign="top" width="100"><a href="otr_db_host.cfm" class="otrtip" title="<div align='center'>DB Instances and<br />the physical location...<br />The report lists the location<br />as of last <cfoutput>#LCase(Dayofweekasstring(Application.snapshot_day))#</cfoutput></div>" onfocus="this.blur();">DB Hosts</a></td>
	<td align="center" valign="top" width="100"><a href="otr_tbs.cfm" class="otrtip" title="<div align='center'>Here you define the releationships<br />between Customers, Instances and<br />one or more Tablespace(s)</div>" onfocus="this.blur();">Tablespaces</a></td>
	<td align="center" valign="top" width="100"><a href="otr_tbs_trend.cfm" class="otrtip" title="<div align='center'>Here you can see the Trend in<br />growth of the tablespace usage<br />as a Bar chart.<br /><img src=images/chart.png width=128 height=96 border=0 /></div>" onfocus="this.blur();">TBS Trend</a></td>
	<cfif DayOfWeek(Now()) IS Application.snapshot_day><td align="center" valign="top" width="100"><a href="#" onclick="showHalgeDiv();" class="otrtip" title="<div align='center'>No manually generated<br />snapshots on a<br /><cfoutput>#Dayofweekasstring(Application.snapshot_day)#</cfoutput>!</div>" onfocus="this.blur();">New Snapshot</a></td><cfelse><td align="center" valign="top" width="100"><a href="#" onclick="showDiv(); makeDisableSubmit()" class="otrtip" title="<div align='center'>This will generate<br />a new snapshot with<br />todays date, containing<br />Tablespace and NFS<br />Storage usage.</div>" onfocus="this.blur();">New Snapshot</a></td></cfif>
	<td align="center" valign="top" width="100"><a href="otr_tbs_deletesnapshot.cfm" class="otrtip" title="<div align='center'>Delete a specific snapshot.<br />You can not delete <cfoutput>#Dayofweekasstring(Application.snapshot_day)#</cfoutput> snapshots</div>" onfocus="this.blur();">Del Snapshot</a></td>
	<td align="center" valign="top" width="100"><a href="<cfoutput>#application.ogc_logon_url#</cfoutput>" target="_blank" class="otrtip" title="<div align='center'>This is a direct<br />Link to the Oracle<br />Enterprise Manager</div>" onfocus="this.blur();">Enterprise Manager</a></td>
	<!---<td align="center" valign="top" width="200">Last Snapshot: <cfoutput>#DateFormat(qRepDateMax.rep_date, "dd.mm.yyyy")#</cfoutput></td>--->
	<td align="right" style="font-size: 8pt; font-weight: bold; color: rgb(124,43,66);"><cfset dummy = SetLocale("#Application.locale_string#") /><img src="images/<cfoutput>#application.logo_image#</cfoutput>" alt="" width="186" height="45" border="0"><br />Last Snapshot: <cfoutput>#LSDateFormat(qRepDateMax.rep_date, 'medium')#</cfoutput></td>
</tr>
</table>
<div id="loaderDiv" class="hideMe">&nbsp;</div>
<div id="halgeDiv" class="hideMe">&nbsp;<div align="center" class="halgeHeading">No manually generated Snapshots on <cfoutput>#Dayofweekasstring(Application.snapshot_day)#</cfoutput>! <div id="countDown"></div></div></div>
<iframe frameborder="0" name="snapshot" id="snapshot" src="" width="0" height="0" scrolling="NO"></iframe>
<br />
