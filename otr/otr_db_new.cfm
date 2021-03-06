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
	2013.04.17	mst	Added SYSTEM Username
--->
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"><cfprocessingdirective suppresswhitespace="Yes"><cfsetting enablecfoutputonly="true">

<cfsetting enablecfoutputonly="false">
<html>
<head>
	<title><cfoutput>#application.company#</cfoutput> - New Oracle Instance</title>
<cfinclude template="_otr_css.cfm">
<script type="text/javascript">
<!--
function makeDisableSubmit(){
    var x=document.getElementById("qSubmit");
    x.disabled=true;
    var y=document.getElementById("qReset");
    y.disabled=true;
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
		document.getElementById("snapshot").src = 'otr_tbs_newsnapshot.cfm';
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
<style type="text/css">
    .auto-hint { color: silver; }
</style>
<script type="text/javascript">
    $(document).ready(function(){
        //  Focus auto-focus fields
        $('.auto-focus:first').focus();

        //  Initialize auto-hint fields
        $('INPUT.auto-hint, TEXTAREA.auto-hint').focus(function(){
            if($(this).val() == $(this).attr('title')){
                $(this).val('');
                $(this).removeClass('auto-hint');
            }
        });

        $('INPUT.auto-hint, TEXTAREA.auto-hint').blur(function(){
            if($(this).val() == '' && $(this).attr('title') != ''){
                $(this).val($(this).attr('title'));
                $(this).addClass('auto-hint');
            }
        });

        $('INPUT.auto-hint, TEXTAREA.auto-hint').each(function(){
            if($(this).attr('title') == ''){ return; }
            if($(this).val() == ''){ $(this).val($(this).attr('title')); }
            else { $(this).removeClass('auto-hint'); }
        });
    });
</script>
</head>
<body>
<cfinclude template="_top_menu.cfm">
<div align="center">
<h2><cfoutput>#application.company#</cfoutput> - New Oracle Instance</h2>
<div align="center">
<table border="0" cellpadding="5">
<tr>
	<td class="bodyline">
	<form action="otr_db_save.cfm" method="post">
	<table border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td width="300" align="right" style="font-size: 9pt;font-weight: bold; text-align: right">Oracle SID:&nbsp;</td>
		<td width="150"><input type="text" name="db_name" id="db_name" value="" size="10"></td>
	</tr>
	<tr>
		<td width="300" align="right" style="font-size: 9pt;font-weight: bold; text-align: right">Environment:&nbsp;</td>
		<td width="150">
			<select name="db_env">
				<option value="DEE">(DEE) Dedicated Enterprise Edition</option>
				<option value="DSE">(DSE) Dedicated Standard Edition</option>
				<option value="SEE" selected>(SEE) Shared Enterprise Edition</option>
				<option value="SSE">(SSE) Shared Standard Edition</option>
				<option value="DEV">(DEV) Development Enterprise Edition</option>
				<option value="INT">(INT) Internal Enterprise Edition</option>
			</select>
		</td>
	</tr>
	<tr>
		<td width="300" align="right" style="font-size: 9pt;font-weight: bold;">Description:&nbsp;</td>
		<td width="300"><input type="text" name="db_desc" id="db_desc" value="" size="35"></td>
	</tr>
	<tr>
		<td width="300" align="right" style="font-size: 9pt;font-weight: bold;">SYSTEM Username:&nbsp;</td>
		<td width="300"><input type="text" name="system_username" id="system_username" value="" title="#UCase(Application.default_system_username)# is used as default" size="35" class="auto-hint"></td>
	</tr>
	<tr>
		<td width="300" align="right" style="font-size: 9pt;font-weight: bold;">SYSTEM Password:&nbsp;</td>
		<td width="300"><input type="password" name="system_password" id="system_password" value="" size="35"></td>
	</tr>
	<tr>
		<td width="300" align="right" style="font-size: 9pt;font-weight: bold;">Hostname:&nbsp;</td>
		<td width="300"><input type="text" name="db_host" id="db_host" value="" size="33"></td>
	</tr>
	<tr>
		<td width="300" align="right" style="font-size: 9pt;font-weight: bold;">Listener Port:&nbsp;</td>
		<td width="300"><input type="text" name="db_port" id="db_port" value="" size="6"></td>
	</tr>
	<tr>
		<td width="300" align="right" style="font-size: 9pt;font-weight: bold;">ASM Storage:&nbsp;</td>
		<td width="300"><input type="checkbox" name="db_asm" id="db_asm" value="1"></td>
	</tr>
	<tr>
		<td width="300" align="right" style="font-size: 9pt;font-weight: bold;">RAC Instance:&nbsp;</td>
		<td width="300"><input type="checkbox" name="db_rac" id="db_rac" value="1"></td>
	</tr>
	<tr>
		<td width="300" align="right" style="font-size: 9pt;font-weight: bold;">Service Name:&nbsp;</td>
		<td width="300"><input type="text" name="db_servicename" id="db_servicename" value="" size="33"></td>
	</tr>
	<tr>
		<td width="300" align="right" style="font-size: 9pt;font-weight: bold;">Blackout:&nbsp;</td>
		<td width="300"><input type="checkbox" name="db_blackout" id="db_blackout" value="1"></td>
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
</table>
</div>
</body>
</html></cfprocessingdirective>
