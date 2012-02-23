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
<cfquery name="qHostInstances" datasource="#Application.datasource#">
	select distinct a.hostname db_host, a.db_name, a.rep_date, c.db_port, c.system_password
	from otrrep.otr_nfs_space_rep a, otrrep.otr_space_rep_max_timestamp_v b, otrrep.otr_db c
	where TRUNC(a.rep_date) = b.rep_date 
	  and a.db_name = c.db_name
	order by rep_date desc, hostname, db_name
</cfquery>

<cfquery name="getDate" datasource="#Application.datasource#">
	select rep_date from otrrep.otr_space_rep_max_timestamp_v
</cfquery>

<cfset pdf_date = DateFormat(getDate.rep_date, 'yyyymmdd') />
<!--- Define Date Format --->
<cfset dummy = SetLocale("#Application.locale_string#") />
<cfdocument format="pdf" filename="#application.host_instance_pdf_dir#dbhosts_instances_#pdf_date#.pdf" overwrite="yes" pagetype="A4">
<style>
  table {
    -fs-table-paginate: paginate;
  }
</style>
<cfdocumentitem type="header">
	<table width="100%" border="1" cellpadding="0" cellspacing="0">
	<tr>
		<td align="left">DB-HOSTS - ORACLE INSTANCES - <cfoutput>#LSDateFormat(getDate.rep_date, 'medium')#</cfoutput></td>
	</tr>
	</table>
</cfdocumentitem>
<cfdocumentitem type="footer">
	<table width="100%" border="1" cellpadding="0" cellspacing="0">
	<tr>
		<td align="right"><cfoutput>#application.company# - Page #cfdocument.currentsectionpagenumber# of
            #cfdocument.totalsectionpagecount#</cfoutput></td>
	</tr>
	</table>
</cfdocumentitem>
<cfdocumentsection>
	<table border="0" cellpadding="0" cellspacing="0">
	<thead>
	<tr>
		<th width="200" style="font-size: 9pt;font-weight: bold;">Host</th>
		<th width="200" style="font-size: 9pt;font-weight: bold;">SID</th>
		<th width="200" style="font-size: 9pt;font-weight: bold;">Release</th>
	</tr>
	</thead>
	<tbody>
	<cfloop query="qHostInstances">
		<!--- Decrypt the SYSTEM Password --->
		<cfset sPassword = Trim(Application.pw_hash.decryptOraPW(qHostInstances.system_password)) />
		<!--- Create Temporary Data Source --->
		<cfset s = StructNew() />
		<cfset s.hoststring   = "jdbc:oracle:thin:@#LCase(qHostInstances.db_host)#:#qHostInstances.db_port#:#UCase(qHostInstances.db_name)#" />
		<cfset s.drivername   = "oracle.jdbc.OracleDriver" />
		<cfset s.databasename = "#UCase(qHostInstances.db_name)#" />
		<cfset s.username     = "system" />
		<cfset s.password     = "#sPassword#" />
		<cfset s.port         = "#qHostInstances.db_port#" />

		<cftry>
			<cfif DataSourceIsValid("#UCase(qHostInstances.db_name)#temp")>
				<cfset DataSourceDelete( "#UCase(qHostInstances.db_name)#temp" ) />
			</cfif>
			<cfif NOT DataSourceIsValid("#UCase(qHostInstances.db_name)#temp")>
				<cfset DataSourceCreate( "#UCase(qHostInstances.db_name)#temp", s ) />
			</cfif>
			<cfquery name="qDBversion" datasource="#UCase(qHostInstances.db_name)#temp">
				select SUBSTRB(SUBSTR(b.banner, INSTR (b.banner, 'Release') + 8, 10), 1, 10) VERSION
				  from SYS.v_$version b
				 where INSTR(UPPER(b.banner), 'ORACLE') > 0
		       	   and (INSTR(UPPER(b.banner), 'ENTERPRISE') > 0
    	                or (INSTR(UPPER(b.banner), 'ORACLE9I') > 0
	                        or (INSTR(UPPER (b.banner), 'ORACLE8I') > 0
	                            or INSTR(UPPER (b.banner), 'DATABASE') > 0
	                           )
    	                   )
	                  )
			</cfquery>
			<cfset sVersion = qDBversion.version />
			<cfif DataSourceIsValid("#UCase(qHostInstances.db_name)#temp")>
				<cfset DataSourceDelete( "#UCase(qHostInstances.db_name)#temp" ) />
			</cfif>
			<cfcatch type="database">
				<cfset sVersion = "" />
				<cfif DataSourceIsValid("#UCase(qHostInstances.db_name)#temp")>
					<cfset DataSourceDelete( "#UCase(qHostInstances.db_name)#temp" ) />
				</cfif>
			</cfcatch>
		</cftry>
	<tr<cfif qHostInstances.CurrentRow mod 2> class="alternate"</cfif>>
		<td><cfoutput>#qHostInstances.db_host#</cfoutput></td>
		<td><cfoutput>#qHostInstances.db_name#</cfoutput></td>
		<td><cfoutput>#sVersion#</cfoutput></td>
	</tr>
	<cfset dRepDate = LSDateFormat(qHostInstances.rep_date, 'medium') /></cfloop>
	</tbody>
	<tr>
		<td colspan="2" style="font-size: 8pt;font-weight: normal;font-style: oblique">Number of Instances: <cfoutput>#qHostInstances.RecordCount#, Stand: #dRepDate#</cfoutput></td>
	</tr>
	</table>
</cfdocumentsection>
</cfdocument>
<!--- <cfexecute name="/bin/chown" arguments="pccr:dba /opt/pro/dir/ccr/oracle/dbhosts_instances_#pdf_date#.pdf" /> --->
