<!---
    Oracle Tablespace Report Project - http://www.network23.net
    
    Contributing Developers:
    Ben Nadel - 
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
	
	Special Note:
	This Function is a work of Ben Nadel... All qudos to him!!
	http://www.bennadel.com/blog/149-Ask-Ben-Converting-A-Query-To-A-Struct.htm
--->
<cfcomponent displayname="query2struct"
		output="false" 
		hint="Convert a query to a Structure">

	<!--- 
		QueryToStruct
	--->
	<cffunction name="QueryToStruct"
				access="public"
				output="false"
				returntype="any"
				hint="Converts an entire query or the given record to a struct. This might return a structure (single record) or an array of structures.">

		<cfargument name="Query" 
					type="query" 
					required="true"
					hint="This is the query object to be converted" />
		<cfargument name="Row" 
					type="numeric" 
					required="false" 
					default="0"
					hint="Optional row number in the query to be converted." />
<cfscript>
// Define the local scope.
var local = StructNew();

// Determine the indexes that we will need to loop over.
// To do so, check to see if we are working with a given row,
// or the whole record set.
if (arguments.Row){
	// We are only looping over one row.
	local.FromIndex = arguments.Row;
	local.ToIndex = arguments.Row;
} else {
	// We are looping over the entire query.
	local.FromIndex = 1;
	local.ToIndex = arguments.Query.RecordCount;
}

// Get the list of columns as an array and the column count.
local.Columns = ListToArray(arguments.Query.ColumnList);
local.ColumnCount = ArrayLen(local.Columns);

// Create an array to keep all the objects.
local.DataArray = ArrayNew(1);

// Loop over the rows to create a structure for each row.
for (local.RowIndex = local.FromIndex; local.RowIndex LTE local.ToIndex; local.RowIndex = (local.RowIndex + 1)){
	// Create a new structure for this row.
	ArrayAppend( local.DataArray, StructNew() );

	// Get the index of the current data array object.
	local.DataArrayIndex = ArrayLen(local.DataArray);

	// Loop over the columns to set the structure values.
	for (local.ColumnIndex = 1; local.ColumnIndex LTE local.ColumnCount; local.ColumnIndex = (local.ColumnIndex + 1)){
		// Get the column value.
		local.ColumnName = local.Columns[local.ColumnIndex];

		// Set column value into the structure.
		local.DataArray[local.DataArrayIndex][local.ColumnName] = arguments.Query[local.ColumnName][local.RowIndex];
	}
}

// At this point, we have an array of structure objects that
// represent the rows in the query over the indexes that we
// wanted to convert. If we did not want to convert a specific
// record, return the array. If we wanted to convert a single
// row, then return the just that STRUCTURE, not the array.
if (arguments.Row){
	// Return the first array item.
	return(local.DataArray[1]);
} else {
	// Return the entire array.
	return(local.DataArray);
}
</cfscript>
	</cffunction>
</cfcomponent>
