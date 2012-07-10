<!---
*
* Copyright (C) 2005-2008 Razuna
*
* This file is part of Razuna - Enterprise Digital Asset Management.
*
* Razuna is free software: you can redistribute it and/or modify
* it under the terms of the GNU Affero Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* Razuna is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU Affero Public License for more details.
*
* You should have received a copy of the GNU Affero Public License
* along with Razuna. If not, see <http://www.gnu.org/licenses/>.
*
* You may restribute this Program with a special exception to the terms
* and conditions of version 3.0 of the AGPL as described in Razuna's
* FLOSS exception. You should have received a copy of the FLOSS exception
* along with Razuna. If not, see <http://www.razuna.com/licenses/>.
*
--->
<cfoutput>
	<script type="text/javascript" charset="utf-8"> 
		$(document).ready(function() {
		
		var oCache = {
			iCacheLower: -1
		};
	
		function fnSetKey( aoData, sKey, mValue )
		{
			for ( var i=0, iLen=aoData.length ; i<iLen ; i++ )
			{
				if ( aoData[i].name == sKey )
				{
					aoData[i].value = mValue;
				}
			}
		}
		
		function fnGetKey( aoData, sKey )
		{
			for ( var i=0, iLen=aoData.length ; i<iLen ; i++ )
			{
				if ( aoData[i].name == sKey )
				{
					return aoData[i].value;
				}
			}
			return null;
		}
	
		function fnDataTablesPipeline ( sSource, aoData, fnCallback ) {
			/* --- Start: Pipeline --- */
			var iPipe = 5; /* Ajust the pipe size */
			var bNeedServer = false;
			var sEcho = fnGetKey(aoData, "sEcho");
			var iRequestStart = fnGetKey(aoData, "iDisplayStart");
			var iRequestLength = fnGetKey(aoData, "iDisplayLength");
			var iRequestEnd = iRequestStart + iRequestLength;
			oCache.iDisplayStart = iRequestStart;
			/* outside pipeline? */
			if ( oCache.iCacheLower < 0 || iRequestStart < oCache.iCacheLower || iRequestEnd > oCache.iCacheUpper )
			{
				bNeedServer = true;
			}
			/* sorting etc changed? */
			if ( oCache.lastRequest && !bNeedServer )
			{
				for( var i=0, iLen=aoData.length ; i<iLen ; i++ )
				{
					if ( aoData[i].name != "iDisplayStart" && aoData[i].name != "iDisplayLength" && aoData[i].name != "sEcho" )
					{
						if ( aoData[i].value != oCache.lastRequest[i].value )
						{
							bNeedServer = true;
							break;
						}
					}
				}
			}
			/* Store the request for checking next time around */
			oCache.lastRequest = aoData.slice();
			if ( bNeedServer )
			{
				if ( iRequestStart < oCache.iCacheLower )
				{
					iRequestStart = iRequestStart - (iRequestLength*(iPipe-1));
					if ( iRequestStart < 0 )
					{
						iRequestStart = 0;
					}
				}
				oCache.iCacheLower = iRequestStart;
				oCache.iCacheUpper = iRequestStart + (iRequestLength * iPipe);
				oCache.iDisplayLength = fnGetKey( aoData, "iDisplayLength" );
				fnSetKey( aoData, "iDisplayStart", iRequestStart );
				fnSetKey( aoData, "iDisplayLength", iRequestLength*iPipe );
				$.getJSON( sSource, aoData, function (json) { 
					/* Callback processing */
					oCache.lastJson = jQuery.extend(true, {}, json);
					if ( oCache.iCacheLower != oCache.iDisplayStart )
					{
						json.aaData.splice( 0, oCache.iDisplayStart-oCache.iCacheLower );
					}
					json.aaData.splice( oCache.iDisplayLength, json.aaData.length );
					fnCallback(json)
				} );
			}
			else
				{
					json = jQuery.extend(true, {}, oCache.lastJson);
					json.sEcho = sEcho; /* Update the echo for each response */
					json.aaData.splice( 0, iRequestStart-oCache.iCacheLower );
					json.aaData.splice( iRequestLength, json.aaData.length );
					fnCallback(json);
					return;
				}
			};
				
			/* --- Start: Init table --- */
			var oTable = $('##displayData').dataTable( {
				"bJQueryUI": true,
				"bProcessing": true,
				"bStateSave": false,
				"bServerSide": true,
				"sAjaxSource": "#myself#c.folder_content_list&folder_id=#attributes.folder_id#",
				"aoColumns": [
					{ "sClass": "center", "bSortable": false },
					{ "sName": "id", "bVisible": false },
					{ "sName": "filename" },
					{ "sName": "kind" }
				],
				"sPaginationType": "full_numbers",
				"aaSorting": [[2,'asc']],
				"fnServerData": fnDataTablesPipeline
			} );
			
			$('##displayData tbody tr').live('click', function () {
				var aData = oTable.fnGetData( this );
				var iId = aData[1];
				alert(iId);
				
			} );
			
		} );
	</script> 

	<table cellpadding="0" cellspacing="0" border="0" class="display" id="displayData"> 
		<thead> 
			<tr>
				<th></th>
				<th></th>
				<th align="left">#myFusebox.getApplicationData().defaults.trans("file_name")#</th> 
				<th align="left">#myFusebox.getApplicationData().defaults.trans("assets_type")#</th>
			</tr> 
		</thead> 
		<tbody> 
			<tr> 
				<td colspan="5" class="dataTables_empty">Loading data from server</td> 
			</tr> 
		</tbody> 
	</table> 








</cfoutput>