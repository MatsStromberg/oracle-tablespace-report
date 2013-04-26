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
	2013.04.25	mst	Updated Copyright note
--->
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"><cfprocessingdirective suppresswhitespace="Yes"><cfsetting enablecfoutputonly="true">
<cfsetting enablecfoutputonly="false">
<html>
<head>
	<title><cfoutput>#application.company#</cfoutput> - Oracle Tablespace Report</title>
<cfinclude template="_otr_css.cfm">

</head>

<body>
<cfinclude template="_otr_menu_setup.cfm">
<br />
<div align="center">
<h2><cfoutput>#application.company#</cfoutput> - Oracle Tablespace Report - Setup</h2>
<table border="0" width="980" cellpadding="10">
<tr>
	<td class="bodyline" align="center" valign="top">
	<form action="otr_setup_cust_save.cfm" method="post">
	<table border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td width="300" align="right" style="font-size: 11pt;font-weight: bold; text-align: right">Company ID:&nbsp;</td>
		<td width="150"><input type="text" name="cust_id" id="cust_id" value="" size="3" onChange="javascript:this.value=this.value.toUpperCase();"></td>
	</tr>
	<tr>
		<td width="300" align="right" style="font-size: 11pt;font-weight: bold;">Name of Company:&nbsp;</td>
		<td width="300"><input type="text" name="cust_name" id="cust_name" value="" size="30"></td>
	</tr>
	<tr>
		<td colspan="2">&nbsp;</td>
	</tr>
	<tr>
		<td align="center" colspan="2"><input value="Save" id="qSubmit" type="submit">&nbsp;&nbsp;&nbsp;<input type="reset" id="qReset"></td>
	</tr>
	</table>
	</form>
	</td>
</tr>
<tr>
	<td align="center" colspan="2" style="font-size: 8pt; text-align: center;">
<cfinclude template="_footer.cfm" />
	</td>
</tr>
</table>
</div>
</body>
</html></cfprocessingdirective>
