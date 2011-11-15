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
<cfif qry_allhosts.recordcount GT 1>
	<cfoutput>
	<div id="host_chooser">
		<table width="100%" border="0" cellpadding="0" cellspacing="0" class="tablepanel">
			<tr>
				<th colspan="2">Choose your host</th>
			</tr>
			<tr>
				<td>Choose your host for getting the specific data for it</td>
				<td>
					<select name="host_chooser" id="host_chooser" onChange="switchtohost();">
						<cfloop query="qry_allhosts">
							<option value="#myself#c.sethost&host_id=#host_id#&cache=#createuuid()#&rto=#xfa.rto#"<cfif session.hostid EQ host_id> selected="true"</cfif>>#ucase(host_name)#</option>
						</cfloop>
					</select>
				</td>
			</tr>
		</table>
		<br />
		<script language="JavaScript" type="text/javascript">
			function switchtohost(){
				// get value
				var thevalue = $('##host_chooser :selected').val();
				// Load
				loadcontent('rightside', thevalue);
			}
		</script>
	</div>
	</cfoutput>
</cfif>