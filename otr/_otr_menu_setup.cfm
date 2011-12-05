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
<cfsetting enablecfoutputonly="true" />
<cfquery name="qRepDateMax" datasource="#application.datasource#">
	select rep_date 
	from otr_space_rep_max_timestamp_v 
	order by rep_date desc
</cfquery>
<cfsetting enablecfoutputonly="false" /><a name="top"></a><table border="0" width="100%">
<table border="0" width="100%">
<tr>
	<td align="center" valign="top" width="100">&nbsp;</td>
	<td align="center" valign="top" width="100">&nbsp;</td>
	<td align="center" valign="top" width="100">&nbsp;</td>
	<td align="center" valign="top" width="100">&nbsp;</td>
	<td align="center" valign="top" width="100">&nbsp;</td>
	<td align="center" valign="top" width="100">&nbsp;</td>
	<td align="center" valign="top" width="100">&nbsp;</td>
	<td align="center" valign="top" width="100">&nbsp;</td>
	<td align="center" valign="top" width="100"><a href="<cfoutput>#application.ogc_logon_url#</cfoutput>" target="_blank" class="otrtip" title="<div align='center'>This is a direct<br />Link to the<br />Oracle GridControl</div>" onfocus="this.blur();">GridControl</a></td>
	<td align="right" style="font-size: 8pt; font-weight: bold; color: rgb(124,43,66);"><img src="images/<cfoutput>#application.logo_image#</cfoutput>" alt="" width="186" height="45" border="0"></td>
</tr>
</table>
<div id="loaderDiv" class="hideMe">&nbsp;</div>
<div id="halgeDiv" class="hideMe">&nbsp;<div align="center" class="halgeHeading">No manually generated Snapshots on <cfoutput>#Dayofweekasstring(Application.snapshot_day)#</cfoutput>! <div id="countDown"></div></div></div>
<iframe frameborder="0" name="snapshot" id="snapshot" src="" width="0" height="0" scrolling="NO"></iframe>
<br />
