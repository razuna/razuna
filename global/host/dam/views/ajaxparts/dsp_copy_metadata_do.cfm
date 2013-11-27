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
	<a href="##" onclick="selectuserscm();return false;" id="selectallcm">#myFusebox.getApplicationData().defaults.trans("select_all")#</a>
	<br /><br />
	<cfif qry_results.recordcount AND qry_results.id NEQ ''>
		<cfloop query="qry_results">
			<cfif id NEQ attributes.fid>
				<input type="checkbox" name="idList" class="idList" value="#id#"> #filename#
				<br />
			</cfif>
		</cfloop>
	<cfelse>
		<p style="color:red; font-weight:bolder;">#myFusebox.getApplicationData().defaults.trans("no_related_record")#</p>
	</cfif>
</cfoutput>
<hr>
<p align="right"><input type="radio" checked="checked" name="insert_type" value="replace"> replace or <input type="radio" name="insert_type" value="append"> append to existing records.&nbsp;   
<input type="submit" name="submit" disabled="true" id="apply" value="Apply" onclick="completed();"></p>
<script type="text/javascript">
	$(document).ready(function(){
		$('.idList').click(function(){
			if($("input[class=idList]:checked").length>0){
				$('#apply').removeAttr('disabled');
			}
			else{
				$('#apply').attr('disabled', 'true');
			}
		});
	});
	// Select all
	function selectuserscm(){
		$('.idList').each( function(){ 
			if (this.checked){
				// select none
				$(this).prop('checked',false);
				// Apply Disable
				$('#apply').attr('disabled', 'true');
				// Change link
				$('#selectallcm').text('Select all');
			}
			else {
				// select all
				$(this).prop('checked','checked');
				//Apply Enable
				$('#apply').removeAttr('disabled');
				// Change link
				$('#selectallcm').text('Select none');
			}		
		})
	};
</script>