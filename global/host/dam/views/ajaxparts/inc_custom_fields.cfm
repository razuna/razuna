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
	<!---RAZ-2834:: Assign the custom field customized --->
	<cfset custom_fields = "">
	<cfif !structKeyExists(variables,"cf_inline")><table border="0" cellpadding="0" cellspacing="0" width="450" class="grid"></cfif>
		<cfloop query="qry_cf">
			<cfif ! (qry_cf.cf_show EQ attributes.cf_show OR qry_cf.cf_show EQ 'all')>
				<cfcontinue>
			</cfif>
			<cfset custom_fields = listappend(custom_fields,"#cs.customfield_images_metadata#",',')>
			<cfset custom_fields = listappend(custom_fields,"#cs.customfield_audios_metadata#",',')>
			<cfset custom_fields = listappend(custom_fields,"#cs.customfield_videos_metadata#",',')>
			<cfset custom_fields = listappend(custom_fields,"#cs.customfield_files_metadata#",',')>
			<cfset custom_fields = listappend(custom_fields,"#cs.customfield_all_metadata#",',')>
			<tr>
				<cfif !structKeyExists(variables,"cf_inline")>
					<td width="130" nowrap="true"<cfif cf_type EQ "textarea"> valign="top"</cfif>><strong>#cf_text#</strong></td>
					<td width="320">
				<cfelse>
					<td>
				</cfif>
					<!--- For text --->
					<cfif cf_type EQ "text">
						<!--- Variable --->
						<cfset allowed = false>
						<!--- Check for Groups --->
						<cfloop list="#session.thegroupofuser#" index="i">
							<cfif listfind(cf_edit,i)>
								<cfset allowed = true>
								<cfbreak>
							</cfif>
						</cfloop>
						<!--- Check for users --->
						<cfloop list="#session.theuserid#" index="i">
							<cfif listfind(cf_edit,i)>
								<cfset allowed = true>
								<cfbreak>
							</cfif>
						</cfloop>
						<cfif !isnumeric(cf_edit) AND cf_edit EQ "true">
							<cfset allowed = true>
						</cfif>
						<input type="text" style="width:300px;" id="cf_text_#listlast(cf_id,'-')#" name="cf_#cf_id#" value="#cf_value#" <cfif listFindNoCase(custom_fields,'#qry_cf.cf_id#',',')>onchange="document.form#attributes.file_id#.cf_meta_text_#listlast(cf_id,'-')#.value = document.form#attributes.file_id#.cf_text_#listlast(cf_id,'-')#.value;" </cfif>  <cfif structKeyExists(variables,"cf_inline")> placeholder="#cf_text#"</cfif><cfif !allowed> disabled="disabled"</cfif>>
					<!--- Radio --->
					<cfelseif cf_type EQ "radio">
						<!--- Variable --->
						<cfset allowed = false>
						<!--- Check for Groups --->
						<cfloop list="#session.thegroupofuser#" index="i">
							<cfif listfind(cf_edit,i)>
								<cfset allowed = true>
								<cfbreak>
							</cfif>
						</cfloop>
						<!--- Check for users --->
						<cfloop list="#session.theuserid#" index="i">
							<cfif listfind(cf_edit,i)>
								<cfset allowed = true>
								<cfbreak>
							</cfif>
						</cfloop>
						<cfif !isnumeric(cf_edit) AND cf_edit EQ "true">
							<cfset allowed = true>
						</cfif>
						<input type="radio" name="cf_#cf_id#" id="cf_radio_yes#listlast(cf_id,'-')#" value="T" <cfif listFindNoCase(custom_fields,'#qry_cf.cf_id#',',')> onchange="document.form#attributes.file_id#.cf_meta_radio_yes#listlast(cf_id,'-')#.checked = document.form#attributes.file_id#.cf_radio_yes#listlast(cf_id,'-')#.checked;" </cfif> <cfif cf_value EQ "T"> checked="true"</cfif><cfif !allowed> disabled="disabled"</cfif>>#myFusebox.getApplicationData().defaults.trans("yes")# 
						<input type="radio" name="cf_#cf_id#" id="cf_radio_no#listlast(cf_id,'-')#" value="F" <cfif listFindNoCase(custom_fields,'#qry_cf.cf_id#',',')> onchange="document.form#attributes.file_id#.cf_meta_radio_no#listlast(cf_id,'-')#.checked = document.form#attributes.file_id#.cf_radio_no#listlast(cf_id,'-')#.checked;" </cfif> <cfif cf_value EQ "F" OR cf_value EQ ""> checked="true"</cfif><cfif !allowed> disabled="disabled"</cfif>>#myFusebox.getApplicationData().defaults.trans("no")#
					<!--- Textarea --->
					<cfelseif cf_type EQ "textarea">
						<!--- Variable --->
						<cfset allowed = false>
						<!--- Check for Groups --->
						<cfloop list="#session.thegroupofuser#" index="i">
							<cfif listfind(cf_edit,i)>
								<cfset allowed = true>
								<cfbreak>
							</cfif>
						</cfloop>
						<!--- Check for users --->
						<cfloop list="#session.theuserid#" index="i">
							<cfif listfind(cf_edit,i)>
								<cfset allowed = true>
								<cfbreak>
							</cfif>
						</cfloop>
						<cfif !isnumeric(cf_edit) AND cf_edit EQ "true">
							<cfset allowed = true>
						</cfif>
						<textarea name="cf_#cf_id#" id="cf_textarea_#listlast(cf_id,'-')#" <cfif listFindNoCase(custom_fields,'#qry_cf.cf_id#',',')> onchange="document.form#attributes.file_id#.cf_meta_textarea_#listlast(cf_id,'-')#.value = document.form#attributes.file_id#.cf_textarea_#listlast(cf_id,'-')#.value;" </cfif> style="width:310px;height:60px;"<cfif structKeyExists(variables,"cf_inline")> placeholder="#cf_text#"</cfif><cfif !allowed> disabled="disabled"</cfif>>#cf_value#</textarea>
					<!--- Select --->
					<cfelseif cf_type EQ "select">
						<!--- Variable --->
						<cfset allowed = false>
						<!--- Check for Groups --->
						<cfloop list="#session.thegroupofuser#" index="i">
							<cfif listfind(cf_edit,i)>
								<cfset allowed = true>
								<cfbreak>
							</cfif>
						</cfloop>
						<!--- Check for users --->
						<cfloop list="#session.theuserid#" index="i">
							<cfif listfind(cf_edit,i)>
								<cfset allowed = true>
								<cfbreak>
							</cfif>
						</cfloop>
						<cfif !isnumeric(cf_edit) AND cf_edit EQ "true">
							<cfset allowed = true>
						</cfif>
						<select name="cf_#cf_id#" id="cf_select_#listlast(cf_id,'-')#" <cfif listFindNoCase(custom_fields,'#qry_cf.cf_id#',',')> onchange="document.form#attributes.file_id#.cf_meta_select_#listlast(cf_id,'-')#.value = document.form#attributes.file_id#.cf_select_#listlast(cf_id,'-')#.value;" </cfif> style="width:300px;"<cfif !allowed> disabled="disabled"</cfif>>
							<option value=""></option>
							<cfloop list="#ltrim(ListSort(replace(cf_select_list,', ',',','ALL'), 'text', 'asc', ','))#" index="i">
								<option value="#i#"<cfif i EQ "#cf_value#"> selected="selected"</cfif>>#i#</option>
							</cfloop>
						</select>
					<!--- Select-search --->
					<cfelseif cf_type EQ "select-search">
						<!--- Variable --->
						<cfset allowed = false>
						<!--- Check for Groups --->
						<cfloop list="#session.thegroupofuser#" index="i">
							<cfif listfind(cf_edit,i)>
								<cfset allowed = true>
								<cfbreak>
							</cfif>
						</cfloop>
						<!--- Check for users --->
						<cfloop list="#session.theuserid#" index="i">
							<cfif listfind(cf_edit,i)>
								<cfset allowed = true>
								<cfbreak>
							</cfif>
						</cfloop>
						<cfif !isnumeric(cf_edit) AND cf_edit EQ "true">
							<cfset allowed = true>
						</cfif>
						<select name="cf_#cf_id#" id="cf_select_#listlast(cf_id,'-')#" style="width:300px;"<cfif !allowed> disabled="disabled"</cfif>>
							<option value=""></option>
							<cfloop list="#ltrim(ListSort(REReplace(cf_select_list, ",(?![^()]+\))\s?" ,';','ALL'), 'text', 'asc', ';'))#" index="i" delimiters=";">
								<option value="#i#"<cfif i EQ "#cf_value#"> selected="selected"</cfif>>#i#</option>
							</cfloop>
						</select>
						<cfoutput>
							<!--- JS --->
							<script language="JavaScript" type="text/javascript">
								
								$("td select[name='cf_"+"<cfoutput>#cf_id#</cfoutput>"+"']").ready(function(event){
									//J'écoute les changements
									(function(self){
										var prefix = "<cfoutput>#session.hostdbprefix#</cfoutput>";
										var select = $("td select[name='cf_"+"<cfoutput>#cf_id#</cfoutput>"+"']");
										select.chosen({add_contains: true});		

										var chosen = select.next(".chosen-container");
										//Sur entrŽe
										chosen.find("input").on("keyup", function(ev){	
											//J'ajoute ˆ la liste							
											if(ev.keyCode === 13 && chosen.find(".chosen-results .active-result").length === 0){
												//Je mets ˆ jour ma liste
												var currentValue = $(this).val();
												select.append('<option value="'+currentValue+'">'+currentValue+'</option>');								
												select.trigger("chosen:updated");
												//Je met ˆ jour le serveur
												var values = [];
												$.each(select.find("option"), function(index, item){
													if($(item).html().length > 0)
														values.push($(item).html())
												})
												$.get(
													"../../global/api2/J2S.cfc?method=updateCustomField&select_list=" + values.join(",") + "&cf_id=" + "#qry_cf.cf_id#" + "&prefix=" + prefix + "&user_id=#session.theuserid#", 
														// NITA Modif ajout du user id
													function(result){}
												);
												//Je trigger l'event ˆ nouveau
												$(this).val(currentValue).trigger("keyup");
												
											}
											else {
												chosen.find(".chosen-results .no-results").append(". Press enter to add");
											}
										})
									})(this);
								});
							</script>
						</cfoutput>	
					<!--- select-category --->
					<cfelseif cf_type EQ "select-category">
						<!--- Variable --->
						<cfset allowed = false>
						<!--- Check for Groups --->
						<cfloop list="#session.thegroupofuser#" index="i">
							<cfif listfind(cf_edit,i)>
								<cfset allowed = true>
								<cfbreak>
							</cfif>
						</cfloop>
						<!--- Check for users --->
						<cfloop list="#session.theuserid#" index="i">
							<cfif listfind(cf_edit,i)>
								<cfset allowed = true>
								<cfbreak>
							</cfif>
						</cfloop>
						<cfif !isnumeric(cf_edit) AND cf_edit EQ "true">
							<cfset allowed = true>
						</cfif>
						<select name="cf_#cf_id#" type="category" id="cf_select_category_#listlast(cf_id,'-')#" value="#cf_value#" style="width:300px;" <cfif !allowed> disabled="disabled"</cfif>>
							<cfset x = ["mars","earth", "venus", "jupiter"]>
							<option value=""></option>
							<cfloop list="#ltrim(replace(cf_select_list,', ',',','ALL'))#" index="i">
								<option value="#i#"<cfif i EQ "#cf_value#"> selected="selected"</cfif>>#i#</option>
							</cfloop>						
						</select>						
					<!--- select-category --->
					<cfelseif cf_type EQ "select-sub-category">
						<!--- Variable --->
						<cfset allowed = false>
						<!--- Check for Groups --->
						<cfloop list="#session.thegroupofuser#" index="i">
							<cfif listfind(cf_edit,i)>
								<cfset allowed = true>
								<cfbreak>
							</cfif>
						</cfloop>
						<!--- Check for users --->
						<cfloop list="#session.theuserid#" index="i">
							<cfif listfind(cf_edit,i)>
								<cfset allowed = true>
								<cfbreak>
							</cfif>
						</cfloop>
						<cfif !isnumeric(cf_edit) AND cf_edit EQ "true">
							<cfset allowed = true>
						</cfif>
						<select name="cf_#cf_id#" type="sub-category" id="cf_select_sub_category_#listlast(cf_id,'-')#" value="#cf_value#" style="width:300px;" <cfif !allowed> disabled="disabled"</cfif>>
							<cfset list = "#cf_select_list#"> 
							<cfset category = listToArray(list, ";", true)>							
							<cfloop array=#category# index="i" delimiters=";" item="name">								
								<cfset category[#i#] = "#ltrim(ListSort(REReplace(name, ",(?![^()]+\))\s?" ,';','ALL'), 'text', 'asc', ';'))#" />
							</cfloop>
							<option value=""></option>
							<cfif cf_value NEQ null>
								<cfloop array=#category# index="i" item="cat">
									<cfset categories=listToArray(#cat#, ";", true) >								
									<cfif ArrayContains(categories,cf_value)>
										<cfloop array=#categories# index="name">
											<option value="#name#" <cfif name EQ "#cf_value#"> selected="selected"</cfif>>#name#</option>
										</cfloop>
									</cfif>
								</cfloop>
							</cfif>
						</select>
						<cfoutput>
							<!--- JS --->
							<script language="JavaScript" type="text/javascript">
								var id = "<cfoutput>#cf_id#</cfoutput>";
								var category = $(document).find("select[type=category]");
								var subCategory = $("select[name='cf_"+id+"']");	

								//La catŽgorie parente change, je charge la sous-catŽgorie
								category.change(function(event){
									subCategory.val("");
									subCategory.empty();
									subCategory.append("<option value=''></option>");
									var #toScript(category, "values")#
									var list = event.srcElement.selectedIndex ? values[event.srcElement.selectedIndex-1] : values.join(";");
									if(list){
										for(var i = 0 ; i < list.split(";").length ; i++){
											subCategory.append("<option value="+list.split(";")[i]+">"+list.split(";")[i]+"</option>")
										}
									}
								});
							</script>
						</cfoutput>	
					</cfif>
				</td>
			</tr>
		</cfloop>
	<cfif !structKeyExists(variables,"cf_inline")></table></cfif>
</cfoutput>