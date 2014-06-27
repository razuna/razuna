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
	<form name="formcopy#attributes.col_id#" id="formcopy#attributes.col_id#" method="post" action="#self#">
	<input type="hidden" name="#theaction#" value="c.col_copy_do">
	<input type="hidden" name="col_id" value="#attributes.col_id#">
	<input type="hidden" name="folder_id" value="#attributes.folder_id#">
	<input type="hidden" name="langcount" value="#valuelist(qry_langs.lang_id)#">
	<input type="hidden" name="release" value="true">
		<h2>Release this collection</h2>
		Releasing a collection will freeze the collection for further changes. It can be used in order to "lock" the collection. Only an Administrator can Un-Release a collection and make changes to it.
		<br /><br />
		<strong>Change Collection Name to</strong>
		<input type="text" style="width:400px;" name="col_name" value="#qry_detail.col_name# copy">
		<br /><br />
		<cfloop query="qry_langs">
			<cfset thisid = lang_id>
			<strong>#lang_name#: #myFusebox.getApplicationData().defaults.trans("description")#</strong>
			<br />
			<textarea name="col_desc_#thisid#" class="text" style="width:400px;height:50px;"><cfloop query="qry_detail"><cfif lang_id_r EQ thisid>#col_desc#</cfif></cfloop></textarea>
			<br />
			<strong>#lang_name#: #myFusebox.getApplicationData().defaults.trans("keywords")#</strong>
			<br />
			<textarea name="col_keywords_#thisid#" class="text" style="width:400px;height:50px;"><cfloop query="qry_detail"><cfif lang_id_r EQ thisid>#col_keywords#</cfif></cfloop></textarea>
			<br />
		</cfloop>
		<br />
		<!--- Labels --->
		<!--- <strong>#myFusebox.getApplicationData().defaults.trans("labels")#</strong>
		<br />
		<select data-placeholder="Choose a label" class="chzn-select" style="width:400px;" id="tags_col_copy" onchange="razaddlabels('tags_col_copy','#attributes.col_id#','collection');" multiple="multiple">
			<option value=""></option>
			<cfloop query="attributes.thelabelsqry">
				<option value="#label_id#"<cfif ListFind(qry_labels,'#label_id#') NEQ 0> selected="selected"</cfif>>#label_path#</option>
			</cfloop>
		</select>
		<br /> --->
		<!--- Save --->
		<div style="float:left;padding:20px 0px 20px 0px;"><input type="checkbox" name="copycol" id="copycol" value="true" checked="checked"> Copy the collection at the same time</div>
		<div style="float:right;padding:20px 0px 20px 0px;"><input type="submit" name="submit" value="Release Collection" class="button"></div>
	</form>
	<!--- JS --->
	<script type="text/javascript">
		// Activate Chosen
		// $(".chzn-select").chosen({search_contains: true});
		// Submit Form
		$("##formcopy#attributes.col_id#").submit(function(e){
			// Get data
			var url = formaction("formcopy#attributes.col_id#");
			var items = formserialize("formcopy#attributes.col_id#");
			var copycol = $('##copycol').is(':checked');
			// Submit Form
	       	$.ajax({
				type: "POST",
				url: url,
			   	data: items,
			   	success: function(){
					loadcontent('rightside','#myself#c.collections&col=F&folder_id=col-#attributes.folder_id#&released=true');
					destroywindow('1');
			   	}
			})
	        return false;
	    });
	</script>
</cfoutput>