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
	
	The Oracle Tablespace Report do need an Oracle Enterprise
	Manager 10g or later Repository (Copyright Oracle Inc.)
	since it will get some of it's data from the EM Repository.
    
    You should have received a copy of the GNU General Public License 
    along with the Oracle Tablespace Report.  If not, see 
    <http://www.gnu.org/licenses/>.
--->
<cfprocessingdirective suppresswhitespace="Yes"><cfsetting enablecfoutputonly="true">
<cfquery name="qDelete" datasource="#application.datasource#">
	delete from otr_db_space_rep a
	where trunc(a.rep_date) = trunc(to_date('#FORM.rep_date#','DD-MM-YYYY'))
</cfquery>
<cfquery name="qDelete2" datasource="#application.datasource#">
	delete from otr_nfs_space_rep a
	where trunc(a.rep_date) = trunc(to_date('#FORM.rep_date#','DD-MM-YYYY'))
</cfquery>
<cfsetting enablecfoutputonly="false">

<cflocation url="index.cfm" addtoken="No">
</cfprocessingdirective>