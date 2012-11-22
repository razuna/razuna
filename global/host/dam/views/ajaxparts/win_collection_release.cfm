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
<!--- Define variables --->
<cfoutput>
	<form name="formrelease#attributes.col_id#" id="formrelease#attributes.col_id#" method="post" action="#self#">
	<input type="hidden" name="#theaction#" value="c.col_release">
	<input type="hidden" name="col_id" value="#attributes.col_id#">
	<input type="hidden" name="folder_id" value="#attributes.folder_id#">
	<input type="hidden" name="release" value="#attributes.release#">
		<h2>Release this collection</h2>
		Releasing a collection will freeze the collection for further changes. It can be used in order to "lock" the collection. Only an Administrator can Un-Release a collection and make changes to it.
		<br /><br />
		<strong>Change Collection Name to</strong>
		<input type="text" style="width:400px;" name="col_name">
		<!--- Save --->
		<div style="float:right;padding:20px 0px 20px 0px;"><input type="submit" name="submit" value="Release Collection" class="button"></div>
	</form>
	<!--- JS --->
	<script type="text/javascript">
		// Submit Form
		$("##formrelease#attributes.col_id#").submit(function(e){
			// Get data
			var url = formaction("formrelease#attributes.col_id#");
			var items = formserialize("formrelease#attributes.col_id#");
			// Submit Form
	       	$.ajax({
				type: "POST",
				url: url,
			   	data: items,
			   	success: function(){
					loadcontent('rightside','#myself#c.collection_detail&col_id=#attributes.col_id#&folder_id=#attributes.folder_id#');
					destroywindow('1');
			   	}
			})
	        return false;
	    });
	</script>
</cfoutput>