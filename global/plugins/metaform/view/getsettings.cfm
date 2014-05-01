<cfoutput>
	<style>
		.actionbox {
			border: 1px solid ##D3D3D3;
			padding: 10px;
			margin: 10px;
			background: ##E6E6E6;
			border-radius: 10px;
			-webkit-border-radius: 10px;
		    -moz-border-radius: 10px;
		    cursor: move;
		}
		.myplace { 
			height: 50px; 
			line-height:50px; 
			border: 3px dotted grey;
			padding: 10px;
			margin: 10px;
			border-radius: 10px;
			-webkit-border-radius: 10px;
		    -moz-border-radius: 10px;
		}
	</style>
	<!--- Create the div with the tabs --->
	<!--- Set optional width with: style="width:720px;" --->
	<div id="tab_metaform" style="width:720px;">
		<!--- Tabs --->
		<ul>
			<li><a href="##tab1">Define metadata form</a></li>
			<!--- <li><a href="##tab2">Logs</a></li> --->
		</ul>
		<!--- Divs --->
		<div id="tab1">
			<form id="form_metaform" method="post" action="index.cfm?fa=c.plugin_direct">
				<input type="hidden" name="comp" value="metaform.cfc.settings">
				<input type="hidden" name="func" value="setSettings">
				<input type="hidden" name="mf_order" id="mf_order" value="#result.cfc.pl.getSettings.qry_mf_order.mf_value#" />
				If activated, the metadata form will show after a user has uploaded all his files. Define below what metadata fields you want to have your user to fill in.
				<br /><br />
				<strong>Activate form after upload</strong><br />
				<input type="radio" name="mf_active" value="true"<cfif result.cfc.pl.getSettings.qry_mf_active.mf_value> checked="checked"</cfif>> Form is active<br />
				<input type="radio" name="mf_active" value="false"<cfif !result.cfc.pl.getSettings.qry_mf_active.mf_value> checked="checked"</cfif>> Form is inactive
				<br /><br />
				<hr />
				<input type="button" value="Add field" onclick="appendAction();" class="button" />
				<br /><br />
				<div id="thefields">
					<cfloop query="result.cfc.pl.getSettings.qry">
						<cfif mf_type CONTAINS "mf_meta_field_">
							<!--- Get number --->
							<cfset n = listlast(mf_type,"_")>
							<!--- Get values --->
							<cfif mf_type EQ "mf_meta_field_#n#">
								<cfloop list="#mf_value#" index="i" delimiters=";">
									<cfif listfirst(i,":") EQ "mf_meta_field_#n#">
										<cfset thefield = listlast(i,":")>
									</cfif>
									<cfif listfirst(i,":") EQ "mf_meta_field_req_#n#">
										<cfset thereq = listlast(i,":")>
									</cfif>
								</cfloop>
							</cfif>
							<!--- The div --->
							<div id="div_metafield_#n#" class="clonefield actionbox">
								<div>
									<div style="float:left;padding-right:10px;">
										<img src="../../global/plugins/metaform/images/arrow-out.png" border="0" width="16" height="16" />
									</div>
									<div>
										<strong>Metadata field</strong> | <a href="##" onclick="$('##div_metafield_#n#').detach();return false;" class="clonefield_del">Remove action</a>
									</div>
								</div>
								<br />
								<!--- Metadata fields --->
								<select name="mf_meta_field_#n#" style="width:200px;">
									<option>Choose Field</option>
									<option></option>
						        	<option>--- Default ---</option>
						        	<cfloop list="#result.cfc.pl.getSettings.meta_default#" index="i" delimiters=","><option value="#i#"<cfif thefield EQ i> selected="selected"</cfif>>#i#</option></cfloop>
						        	<option></option>
						        	<!--- <option>--- For Images only ---</option>
						        	<cfloop list="#result.cfc.pl.getSettings.meta_img#" index="i" delimiters=","><option value="#i#"<cfif thefield EQ i> selected="selected"</cfif>>#i#</option></cfloop>
						        	<option></option>
						        	<option>--- For Documents (PDF) only ---</option>
						        	<cfloop list="#result.cfc.pl.getSettings.meta_doc#" index="i" delimiters=","><option value="#i#"<cfif thefield EQ i> selected="selected"</cfif>>#i#</option></cfloop>
						        	<option></option> --->
						        	<option>--- Custom Fields ---</option>
						        	<cfloop query="result.cfc.pl.getSettings.qry_cf">
						        		<option value="#cf_id#"<cfif thefield EQ cf_id> selected="selected"</cfif>>#cf_text# (#cf_type#)</option>
						        	</cfloop>
								</select>
								Required: <input type="radio" name="mf_meta_field_req_#n#" value="true"<cfif thereq> checked="checked"</cfif> /> Yes <input type="radio" name="mf_meta_field_req_#n#" value="false"<cfif !thereq> checked="checked"</cfif> /> No
								<br /><br />
								<div style="clear:both;"></div>
							</div>
						</cfif>
					</cfloop>
				</div>
				<br /><br />
				<!--- Save --->
				<div style="float:left;"><input type="submit" name"mybutton" value="Save Settings" style="vertical-align:top;" class="button" /></div>
				<div style="float:right;"><em>(Tip: Drag &amp; drop fields to re-order them)</em></div>
				<div style="clear:both;"></div>
				<div id="mf_save_status"></div>
				<div style="clear:both;"></div>
			</form>

			<!--- This is hidden div and being called with JS to insert into the above "theactions" div --->
			<div style="display:none">
				<div id="div_metafield_0" class="clonefield actionbox">
					<div>
						<div style="float:left;padding-right:10px;">
							<img src="../../global/plugins/metaform/images/arrow-out.png" border="0" width="16" height="16" />
						</div>
						<div>
							<strong>Metadata field</strong> | <a href="##" onclick="$('##div_metafield_0').detach();return false;" class="clonefield_del">Remove action</a>
						</div>
					</div>
					<br />
					<!--- Metadata fields --->
					<select name="mf_meta_field_0" style="width:200px;">
						<option>Choose Field</option>
						<option></option>
			        	<option>--- Default ---</option>
			        	<cfloop list="#result.cfc.pl.getSettings.meta_default#" index="i" delimiters=","><option value="#i#">#i#</option></cfloop>
			        	<option></option>
			        	<!--- <option>--- For Images only ---</option>
			        	<cfloop list="#result.cfc.pl.getSettings.meta_img#" index="i" delimiters=","><option value="#i#">#i#</option></cfloop>
			        	<option></option>
			        	<option>--- For Documents (PDF) only ---</option>
			        	<cfloop list="#result.cfc.pl.getSettings.meta_doc#" index="i" delimiters=","><option value="#i#">#i#</option></cfloop>
						<option></option> --->
			        	<option>--- Custom Fields ---</option>
			        	<cfloop query="result.cfc.pl.getSettings.qry_cf">
			        		<option value="#cf_id#">#cf_text# (#cf_type#)</option>
			        	</cfloop>
					</select>
					Required <input type="radio" name="mf_meta_field_req_0" value="true" checked="checked" /> Yes <input type="radio" name="mf_meta_field_req_0" value="false" /> No
					<br /><br />
					<div style="clear:both;"></div>
				</div>
			</div>
		</div>
	</div>
	<!--- Activate the Tabs --->
	<script language="JavaScript" type="text/javascript">
		// Create Tabs
		jqtabs("tab_metaform");
		// Make theactions sortable
		$('##thefields').sortable({
			placeholder: "myplace",
			distance: 15,
			opacity: 0.6,
			scroll: true
		});
		// Append
		function appendAction(){
			// How many clones do we have
			var num = $('##thefields .clonefield').length;
			// Add one
			var newNum = new Number(num + 1);
			var isexists = true;
			// If field already exists then choose another number. Can happen when fields are removed
			 while (isexists)
			 {
			 	if ($( '##div_metafield_' + newNum).length)
			 		newNum = newNum + 1;
			 	else
			 		isexists = false;
			 }
			// create the new element via clone(), and manipulate it's ID using newNum value
	        var newElem = $('##div_metafield_0').clone().attr('id', 'div_metafield_' + newNum);
	         // Append the element
	        $(newElem).appendTo('##thefields');
	        // Loop over the new object and replace _number with the new one
	        $('##div_metafield_' + newNum + ' :input').each(
	        	function(){
	        		// Get name of input
	        		var tn = $(this).attr('name');
	        		// Remove the last two characters
	        		var tn = tn.slice(0,-2);
	        		// Add the newNum
					$(this).attr('name', tn + '_' + newNum);
					$(this).attr('id', tn + '_' + newNum);
	        	}
	        );
	        // Find the detach reference and change it as well
	        var theclick = '$(' + '\'' + '##div_metafield_' + newNum + '\'' + ').detach();return false;';
	        $('##div_metafield_' + newNum + ' ' + '.clonefield_del').attr("onclick",theclick);
		};
		// Submit form
		<!--- Load Progress --->
		$("##form_metaform").submit(function(e){
			// Set the order
			var s = $("##thefields").sortable('toArray');
			$('##mf_order').val(s);
			// Get values
			var url = formaction("form_metaform");
			var items = formserialize("form_metaform");
			// Submit Form
			$.ajax({
				type: "POST",
				url: url,
			   	data: items
			});
			// Feedback
			$('##mf_save_status').fadeTo("fast", 100);
			$('##mf_save_status').html('<span style="font-weight:bold;color:green;">We saved the changes successfully!</span>');
			$('##mf_save_status').fadeTo(5000, 0);
			return false;
		});
	</script>
</cfoutput>