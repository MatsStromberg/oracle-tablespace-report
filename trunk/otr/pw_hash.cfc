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
    along with the Ooracle Tablespace Report.  If not, see 
    <http://www.gnu.org/licenses/>.
--->
<!---
	Long over due Change Log
	2013.04.23	mst	Changed Encryption/Decryption to use a stronger method.
	2013.04.23	mst	Hashkey stored in table OTR_VER
	2013.04.23	mst	Added new function  to lookup the hash key
--->
<cfcomponent displayname="pw_hash"
		output="false" 
		hint="Encrypting/Decrypting Oracle Passswords">

	<!---
		Lookup Key
	--->
	<cffunction name="lookupKey"
				access="public"
				output="false"
				returntype="string"
				hint="Returns the current Hash key">
		<cfquery name="qLookupHashKey" datasource="#Application.datasource#">
			select otr_key
			  from otr_ver
			 where otr_ver = '2.1'
		</cfquery>
		<cfreturn qLookupHashKey.otr_key>
	</cffunction>

	<!--- 
		decryptOraPW
	--->
	<cffunction name="decryptOraPW"
				access="public"
				output="false"
				returntype="string"
				hint="Returns an string contining an an decrypted Oracle Password">

		<cfargument name="password"
					type="string"
					required="true"
					hint="A string that contains an encrypted Oracle Password" />

		<cfargument name="hashKey"
					type="string"
					required="true"
					hint="A string that contains an Hash Key" />

			<cfset locals.decryptedString = decrypt(Trim(password), Trim(hashKey), "AES/CBC/PKCS5Padding", "HEX") />
			<!--- Return the decrypted string --->
			<cfreturn locals.decryptedString />
	</cffunction>

	<!--- 
		encryptOraPW
	--->
	<cffunction name="encryptOraPW"
				access="public"
				output="false"
				returntype="string"
				hint="Returns an string contining an an encrypted Oracle Password">

		<cfargument name="password"
					type="string"
					required="true"
					hint="A string that contains an decrypted Oracle Password">

		<cfargument name="HashKey"
					type="string"
					required="true"
					hint="A string that contains an Hash Key">

			<cfset locals.encryptedString = encrypt(password,HashKey, "AES/CBC/PKCS5Padding", "HEX")>
			<!--- Return the decrypted string --->
			<cfreturn locals.encryptedString>
	</cffunction>
</cfcomponent>
