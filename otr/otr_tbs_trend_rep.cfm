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
	2013.04.19	mst	Cleaned up some commented code
--->
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"><cfprocessingdirective suppresswhitespace="Yes"><cfsetting enablecfoutputonly="true">
<cfif NOT IsDefined("FORM.db_name")><cflocation url="otr_tbs_trend.cfm" addtoken="No"></cfif>
<cfif IsDefined("FORM.monthly")>
	<cfquery name="qTrend" datasource="#application.datasource#">
		select a.db_name, a.rep_date_max as rep_date, b.db_tbs_name, b.db_tbs_real_used_mb, b.db_tbs_can_grow_mb, b.db_tbs_real_prc_used
		  from otr_space_rep_v b, 
			(select db_name, max(rep_date) rep_date_max  
			   from otr_db_space_rep
			  where UPPER(db_name) = '#UCase(FORM.db_name)#'
			    and extract(YEAR from rep_date) = #FORM.year#
		   group by db_name, to_char(rep_date, 'YYYY_MM')) a
		 where UPPER(a.db_name) = UPPER(b.db_name)
		   and a.rep_date_max = b.rep_date
		   and extract(YEAR from b.rep_date) = #FORM.year#
		order by db_name, db_tbs_name, rep_date
	</cfquery>
<cfelse>
	<cfquery name="qTrend" datasource="#application.datasource#">
		select db_name, db_tbs_name, rep_date, db_tbs_real_used_mb, db_tbs_can_grow_mb, db_tbs_real_prc_used
		 from otr_space_rep_v
		where UPPER(db_name) = '#UCase(FORM.db_name)#'
		  -- and   db_tbs_name not IN ('SYSTEM','SYSAUX','TEMP','UNDO','UNDOTBS1')
		  and   trunc(rep_date) between trunc(to_date('#form.from_date#','DD-MM-YYYY')) and trunc(to_date('#FORM.to_date#','DD-MM-YYYY'))
		group by db_name, db_tbs_name, rep_date, db_tbs_real_used_mb, db_tbs_can_grow_mb, db_tbs_real_prc_used
		order by db_name, db_tbs_name, rep_date
	</cfquery>
</cfif>
<!---
<cfquery name="qTrend" datasource="#application.datasource#">
	select db_name, db_tbs_name, rep_date, db_tbs_real_used_mb, db_tbs_can_grow_mb, db_tbs_real_prc_used
	from otr_space_rep_v
	where db_name = '#form.db_name#'
	and   db_tbs_name not IN ('SYSTEM','SYSAUX','TEMP','UNDO','UNDOTBS1')
	<cfif IsDefined("FORM.monthly")>
	and   trunc(rep_date) in ((select distinct trunc(c.rep_date) from otr_db_space_rep c where to_char(c.rep_date,'dd') >= 25))
	<cfelse>
	and   trunc(rep_date) between trunc(to_date('#form.from_date#','DD-MM-YYYY')) and trunc(to_date('#form.to_date#','DD-MM-YYYY'))
	</cfif>
	group by db_name, db_tbs_name, rep_date, db_tbs_real_used_mb, db_tbs_can_grow_mb, db_tbs_real_prc_used
	order by db_name, db_tbs_name, rep_date
</cfquery>
--->
<cfsetting enablecfoutputonly="false">
<html>
<head>
	<title><cfoutput>#application.company#</cfoutput> - <cfoutput>#UCase(FORM.DB_NAME)#</cfoutput> Tablespace Trend</title>
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
			document.snapshot.location = 'otr_tbs_newsnapshot.cfm';
		} 
		else { // IE 4 
			document.all.loaderDiv.style.visibility = 'visible'; 
			document.all.snapshot.location = 'otr_tbs_newsnapshot.cfm';
		} 
	} 
}
function getHash() {
  var hash = window.location.hash;
  return hash.substring(1); // remove #
}
 
function getLinkTarget(link) {
  return link.href.substring(link.href.indexOf('#')+1);
}
// -->
</script>
</head>
<!--- BAR Colors
aliceblue, antiquewhite, aqua, aquamarine, azure, beige, bisque, black, blanchedalmond, blue, blueviolet, 
brown, burlywood, cadetblue, chartreuse, chocolate, coral, cornflowerblue, cornsilk, crimson, cyan, darkblue, 
darkcyan, darkgoldenrod, darkgray, darkgreen, darkgrey, darkkhaki, darkmagenta, darkolivegreen, darkorange, 
darkorchid, darkred, darksalmon, darkslateblue, darkslategray, darkslategrey, darkturquoise, darkviolet, 
deeppink, deepskyblue, dimgray, dimgrey, dodgerblue, firebrick, floralwhite, forestgreen, fuchsia, gainsboro, 
ghostwhite, gold, goldenrod, gray, green, greenyellow, grey, honeydew, hotpink, indianred, indigo, ivory, khaki, 
lavender, lavenderblush, lawngreen, lemonchiffon, lightblue, lightcoral, lightcyan, lightgoldenrodyellow, lightgray, 
lightgreen, lightgrey, lightpink, lightsalmon, lightseagreen, lightskyblue, lightslategray, lightslategrey, 
lightsteelblue, lightyellow, lime, limegreen, linen, magenta, maroon, mediumaquamarine, mediumblue, mediumorchid, 
mediumpurple, mediumseagreen, mediumslateblue, mediumspringgreen, mediumturquoise, mediumvioletred, midnightblue, 
mintcream, mistyrose, moccasin, navajowhite, navy, oldlace, olive, olivedrab, orange, orangered, orchid, palegoldenrod, 
palegreen, paleturquoise, palevioletred, papayawhip, peachpuff, peru, pink, plum, powderblue, purple, red, rosybrown, 
royalblue, saddlebrown, salmon, sandybrown, seagreen, seashell, sienna, silver, skyblue, slateblue, slategray, slategrey, 
snow, springgreen, steelblue, tan, teal, thistle, tomato, turquoise, violet, violetred, wheat, white, whitesmoke, yellow, yellowgreen
--->
<body>
<cfinclude template="_top_menu.cfm">
<div align="center">
<h2><cfoutput>#application.company#</cfoutput> - <cfoutput>#UCase(FORM.DB_NAME)#</cfoutput> Tablespace Trend</h2>
<table border="0" cellpadding="5">
<tr>
	<td class="bodyline">
	<div align="center"><a href="otr_tbs_trend.cfm" onfocus="this.blur();">Back</a><br /><br /></div>
<cfoutput query="qTrend" group="db_tbs_name">
	<div align="center" style="font-size: 14pt; font-weight: bold;">#qTrend.db_tbs_name#</div>
	<cfchart
		FORMAT="png"
		FONTSIZE="9"
		CHARTHEIGHT="400"
		CHARTWIDTH="1000"
		show3D="Yes"
		DATABACKGROUNDCOLOR="antiquewhite">
	<cfchartseries
		type="horizontalbar"
		serieslabel="#qTrend.db_tbs_name#"
		seriescolor="lavender">
	<cfoutput>
		<cfchartdata item="#DateFormat(qTrend.rep_date, 'dd.mm.yyyy')#" value="#qTrend.db_tbs_real_used_mb#">
	</cfoutput>
	</cfchartseries>
	<cfchartseries
		type="horizontalbar"
		serieslabel="#qTrend.db_tbs_name#-Can-Grow-To"
		seriescolor="lightblue">
	<cfoutput>
		<cfchartdata item="#DateFormat(qTrend.rep_date, 'dd.mm.yyyy')#" value="#qTrend.db_tbs_can_grow_mb#">
	</cfoutput>
	</cfchartseries>
	</cfchart><br /><br />
</cfoutput>
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