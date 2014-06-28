<cfif isQuery(result.cfc.pl.loadform.qry_files)>
	<cfset forjs = "">
	<cfoutput>
		<!--- If we don't have any files we redirect to the folder --->
		<cfif result.cfc.pl.loadform.qry_files.recordcount EQ 0>
			<h1>Upload error</h1>
			<h2>There was an error in your upload or the file already exists in the system. Click on the left to navigate back to the folder.</h2>
		<cfelse>
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
						<input type="hidden" name="filewithtype" value="#id#_#type#">
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
												<cfif listGetAt(mf_value,3,";") EQ "mf_meta_field_req_#thenr#:true">
													<cfset thereq = true>
												<cfelse>
													<cfset thereq = false>
												</cfif>
												#ucase(thefield)#<cfif thereq> *</cfif><br />
												<textarea class="text" name="#id#_#thefield#" id="#id#_#thefield#" style="width:400px;height:40px;"></textarea>
												<a href ="javascript:void(0)" onclick="copytextfield('#thefield#',$('###id#_#thefield#').val())">Copy to all</a>
												<cfif thereq>
													<cfset forjs = forjs & ",#id#_#thefield#:text">
												</cfif>
											<!--- Custom fields --->
											<cfelseif mf_cf NEQ "">
												<cfif result.cfc.pl.loadform.qry_fields.cf_show EQ "all" OR (result.cfc.pl.loadform.qry_fields.cf_show EQ result.cfc.pl.loadform.qry_files.type)>
													<cfif listGetAt(mf_value,3,";") EQ "mf_meta_field_req_#thenr#:true">
														<cfset thereq = true>
													<cfelse>
														<cfset thereq = false>
													</cfif>
													#ucase(cf_text)#<cfif thereq> *</cfif><br />
													<!--- For text --->
													<cfif cf_type EQ "text">
														<input type="text" style="width:400px;" id="#id#_cf_#cf_id#" name="#id#_cf_#cf_id#" />
														<a href ="javascript:void(0)" onclick="copytextfield('cf_#cf_id#',$('###id#_cf_#cf_id#').val())">Copy to all</a>
														<cfif thereq>
															<cfset forjs = forjs & ",#id#_cf_#cf_id#:text">
														</cfif>
													<!--- Radio --->
													<cfelseif cf_type EQ "radio">
														<input type="radio" name="#id#_cf_#cf_id#" id="#id#_cf_#cf_id#" value="T">yes <input type="radio" name="#id#_cf_#cf_id#" id="#id#_cf_#cf_id#" value="F" checked="true">no
														&nbsp;&nbsp;<a href ="javascript:void(0)" onclick="copyradiofield('cf_#cf_id#',$('input:radio[name=#id#_cf_#cf_id#]:checked').val())">Copy to all</a>
														<cfif thereq>
															<cfset forjs = forjs & ",#id#_cf_#cf_id#:radio">
														</cfif>
													<!--- Textarea --->
													<cfelseif cf_type EQ "textarea">
														<textarea name="#id#_cf_#cf_id#" id="#id#_cf_#cf_id#" style="width:400px;height:60px;"></textarea>
														<a href ="javascript:void(0)" onclick="copytextfield('cf_#cf_id#',$('###id#_cf_#cf_id#').val())">Copy to all</a>
														<cfif thereq>
															<cfset forjs = forjs & ",#id#_cf_#cf_id#:text">
														</cfif>
													<!--- Select --->
													<cfelseif cf_type EQ "select">
														<select name="#id#_cf_#cf_id#" id="#id#_cf_#cf_id#" style="width:410px;">
															<option value=""></option>
															<cfloop list="#ListSort(cf_select_list, 'text', 'asc', ',')#" index="i">
																<option value="#i#">#i#</option>
															</cfloop>
														</select>
														<a href ="javascript:void(0)" onclick="copytextfield('cf_#cf_id#',$('###id#_cf_#cf_id#').val())">Copy to all</a>
														<cfif thereq>
															<cfset forjs = forjs & ",#id#_cf_#cf_id#:select">
														</cfif>
													</cfif>
												</cfif>
											<cfelseif thefield EQ "labels">
												<cfif listGetAt(mf_value,3,";") EQ "mf_meta_field_req_#thenr#:true">
													<cfset thereq = true>
												<cfelse>
													<cfset thereq = false>
												</cfif>
												#ucase(thefield)#<cfif thereq> *</cfif><br />
												<select data-placeholder="Choose a label" class="chzn-select" style="width:410px;" name="#id#_#thefield#" id="#id#_#thefield#"multiple="multiple">
													<option value=""></option>
													<cfloop query="result.cfc.pl.loadform.qry_labels">
														<option value="#label_id#">#label_path#</option>
													</cfloop>
												</select>
												<a href ="javascript:void(0)" onclick="copylabelfield('_labels',$('###id#_#thefield#').val())">Copy to all</a>
												<cfif thereq>
													<cfset forjs = forjs & ",#id#_#thefield#:chosen">
												</cfif>
											<!--- Input fields --->
											<cfelse>
												<cfif listGetAt(mf_value,3,";") EQ "mf_meta_field_req_#thenr#:true">
													<cfset thereq = true>
												<cfelse>
													<cfset thereq = false>
												</cfif>
												#ucase(thefield)#<cfif thereq> *</cfif><br />
												<input type="text" name="#id#_#thefield#" id="#id#_#thefield#" style="width:400px;" />
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
				function copytextfield(field, value)
				{
					$("[id*="+field+"]").each(function() {
					        $(this).val(value);
					    });
				}
				function copyradiofield(field, value)
				{
					$("[id*="+field+"]").each(function() {
					        var radioName = $(this).prop("name");
					        $("input:radio[name="+radioName+"][value ="+ value + "]").prop('checked', true);
					    });
					
				}
				function copylabelfield(field, value)
				{
					$("[id*="+field).each(function() {
					        $(this).val(value);
					        $(this).trigger("chosen:updated");
					    });
				}
				// Activate Chosen
				$(".chzn-select").chosen({search_contains: true});
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
							if ( $('###tf#').val() == '' ){
								alert('Please enter all required values!');
								return false;
							}
						<cfelseif tt EQ "select">
							if ( $('###tf# option:selected').val() == "" ){
								alert('Please enter all required values!');
								return false;
							}
						<cfelseif tt EQ "chosen">
							if ( !$('###tf# option:selected').length){
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
		</cfif>
	</cfoutput>
</cfif>