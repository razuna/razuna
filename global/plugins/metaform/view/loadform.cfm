<cfif isQuery(result.cfc.pl.loadform.qry_files)>
	<cfset forjs = "">
	<cfoutput>
		<form id="saveform_metaform" method="post" action="index.cfm?fa=c.plugin_direct">
		<input type="hidden" name="comp" value="metaform.cfc.settings">
		<input type="hidden" name="func" value="saveForm">
			<table border="0" cellpadding="0" cellspacing="0" width="100%" class="grid">
				<tr>
					<td colspan="2">
						<h1>Apply metadata</h1>
					</td>
				</tr>
				<tr>
					<td colspan="2">Please enter the metadata fields for each file below.</td>
				</tr>
				<!--- <tr>
					<th>Filename</th>
					<th>Fields</th>
				</tr> --->
				<!--- Loop over files --->
				<cfloop query="result.cfc.pl.loadform.qry_files">
					<cfset id = id>
					<tr<cfif result.cfc.pl.loadform.qry_files.recordcount NEQ 1> class="list"</cfif>>
						<!--- Filename on the left --->
						<td valign="top" style="font-weight:bold;">#filename#</td>
						<!--- Fields on the right --->
						<td>
							<cfloop query="result.cfc.pl.loadform.qry_fields">
								<cfset thenr = listLast(mf_type,"_")>
								<cfloop list="#mf_value#" delimiters=";" index="i">
									<cfif listfirst(i,":") EQ "mf_meta_field_#thenr#">
										<cfset thefield = listlast(i,":")>
									<cfelse>
										<cfset thefield = "">
									</cfif>
									<!--- Make sure we only show fields when it is not empty --->
									<cfif thefield NEQ "">
										<!--- desc and keys are textareas --->
										<cfif thefield EQ "keywords" OR thefield EQ "description">
											#ucase(thefield)#<br />
											<textarea class="text" name="#id#_#thefield#" id="#id#_#thefield#" style="width:400px;height:40px;"></textarea>
											<cfif listGetAt(mf_value,3,";") EQ "mf_meta_field_req_#thenr#:true">
												<cfset thereq = true>
											<cfelse>
												<cfset thereq = false>
											</cfif>
											<cfif thereq>
												<cfset forjs = forjs & ",#id#_#thefield#:text">
											</cfif>
										<!--- Custom fields --->
										<cfelseif mf_cf NEQ "">
											#ucase(cf_text)#<br />
											<!--- For text --->
											<cfif cf_type EQ "text">
												<input type="text" style="width:400px;" id="#id#_cf_#cf_id#" name="cf_#cf_id#" />
												<cfif listGetAt(mf_value,3,";") EQ "mf_meta_field_req_#thenr#:true">
													<cfset thereq = true>
												<cfelse>
													<cfset thereq = false>
												</cfif>
												<cfif thereq>
													<cfset forjs = forjs & ",#id#_#thefield#:text">
												</cfif>
											<!--- Radio --->
											<cfelseif cf_type EQ "radio">
												<input type="radio" name="#id#_cf_#cf_id#" id="#id#_cf_#cf_id#" value="T" checked="true">#myFusebox.getApplicationData().defaults.trans("yes")# <input type="radio" name="#id#_cf_#cf_id#" id="#id#_cf_#cf_id#" value="F">#myFusebox.getApplicationData().defaults.trans("no")#
												<cfif listGetAt(mf_value,3,";") EQ "mf_meta_field_req_#thenr#:true">
													<cfset thereq = true>
												<cfelse>
													<cfset thereq = false>
												</cfif>
												<cfif thereq>
													<cfset forjs = forjs & ",#id#_#thefield#:radio">
												</cfif>
											<!--- Textarea --->
											<cfelseif cf_type EQ "textarea">
												<textarea name="#id#_cf_#cf_id#" id="#id#_cf_#cf_id#" style="width:400px;height:60px;"></textarea>
												<cfif listGetAt(mf_value,3,";") EQ "mf_meta_field_req_#thenr#:true">
													<cfset thereq = true>
												<cfelse>
													<cfset thereq = false>
												</cfif>
												<cfif thereq>
													<cfset forjs = forjs & ",#id#_#thefield#:text">
												</cfif>
											<!--- Select --->
											<cfelseif cf_type EQ "select">
												<select name="#id#_cf_#cf_id#" id="#id#_cf_#cf_id#" style="width:410px;">
													<option value=""></option>
													<cfloop list="#cf_select_list#" index="i">
														<option value="#i#">#i#</option>
													</cfloop>
												</select>
												<cfif listGetAt(mf_value,3,";") EQ "mf_meta_field_req_#thenr#:true">
													<cfset thereq = true>
												<cfelse>
													<cfset thereq = false>
												</cfif>
												<cfif thereq>
													<cfset forjs = forjs & ",#id#_#thefield#:select">
												</cfif>
											</cfif>
										<cfelseif thefield EQ "labels">
											#ucase(thefield)#<br />
											<select data-placeholder="Choose a label" class="chzn-select" style="width:410px;" name="#id#_#thefield#" id="#id#_#thefield#"multiple="multiple">
												<option value=""></option>
												<cfloop query="result.cfc.pl.loadform.qry_labels">
													<option value="#label_id#">#label_path#</option>
												</cfloop>
											</select>
											<cfif listGetAt(mf_value,3,";") EQ "mf_meta_field_req_#thenr#:true">
												<cfset thereq = true>
											<cfelse>
												<cfset thereq = false>
											</cfif>
											<cfif thereq>
												<cfset forjs = forjs & ",#id#_#thefield#:select">
											</cfif>
										<!--- Input fields --->
										<cfelse>
											#ucase(thefield)#<br />
											<input type="text" name="#id#_#thefield#" id="#id#_#thefield#" style="width:400px;" />
											<cfif listGetAt(mf_value,3,";") EQ "mf_meta_field_req_#thenr#:true">
												<cfset thereq = true>
											<cfelse>
												<cfset thereq = false>
											</cfif>
											<cfif thereq>
												<cfset forjs = forjs & ",#id#_#thefield#:text">
											</cfif>
										</cfif>
									</cfif>
								</cfloop>
								<br />
							</cfloop>
						</td>
					</tr>
				</cfloop>
				<tr>
					<td colspan="2" align="right" style="padding-top:20px;">
						<input type="submit" name="submitfields" value="Update Files" class="button" />
					</td>
				</tr>
			</table>
		</form>
		<!--- JS --->
		<script type="text/javascript">
			// Activate Chosen
			$(".chzn-select").chosen();
			// Submit
			$("##saveform_metaform").submit(function(e){
				// Check for required fields
				<cfloop list="#forjs#" delimiters="," index="i">
					<!--- The field --->
					<cfset tf = listfirst(i,":")>
					<!--- The type --->
					<cfset tt = listlast(i,":")>
					<!--- JS --->
					<cfif tt EQ "text">
						if ($('###tf#').val() == ''){
							alert('Please enter all required values!');
							return false;
						}
					<cfelseif tt EQ "select">
						if (!$('###tf# option:selected').length){
							alert('Please enter all required values!');
							return false;
						}
					</cfif>
				</cfloop>
				// Get values
				var url = formaction("saveform_metaform");
				var items = formserialize("saveform_metaform");
				// Submit Form
				$.ajax({
					type: "POST",
					url: url,
				   	data: items,
				   	success: function(){
				   		$('##rightside').load('index.cfm?fa=c.folder&col=F&folder_id=#result.cfc.pl.loadform.qry_files.folder_id#');
				   	}
				});
				return false;
			});
		</script>
	</cfoutput>
</cfif>