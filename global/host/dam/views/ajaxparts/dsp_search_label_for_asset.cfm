<cfoutput>
	<div style="float:left;width:100%;">
		<div style="float:left;text-align:left;width:100%;">
			<cfif qry_labels.recordcount>
				<!--- Last 20 labels added --->
				<cfif structKeyExists(attributes,'show') AND attributes.show EQ 'default'>
					<span style="float:left;clear:both;"><h3>Last 20 Labels Added</h3></span><br/>
				</cfif>
				<!--- Looping the all labels in the query --->
				<cfloop query="qry_labels" >
					<label style="float:left;clear:both;">
					<input type="checkbox" data-label-text="<cfif qry_labels.label_id_r EQ '0'>#label_text#<cfelse>#qry_labels.label_path#</cfif>" 
							name="label_id" id="check_label_#label_id#" class="check" value="#label_id#"  <cfif listfindnocase(attributes.asset_labels_list,#label_id#,',') OR ( attributes.file_id EQ 0 AND listfindnocase(evaluate('session.search_advanced.labels_#attributes.file_type#'),#label_id#,','))>checked="checked"</cfif> style="float:left;width:20px; "> 
					#label_text# <cfif qry_labels.label_id_r EQ '0'>(root level)<cfelse>(#qry_labels.label_path#)</cfif>
					</label></br>
				</cfloop> 
			<cfelse>
				<span style="font-weight:bold;"> No record found!</span>
			</cfif>
		</div>
	</div>
	<script type="text/javascript">
		// Append to the list values
		jQuery.fn.extend({
			addToArray: function(value) {
				return this.filter(":input").val(function(i, v) {
					var arr = v.split(',');
					arr.push(value);
					return arr.join(',');
				}).end();
			},
			removeFromArray: function(value) {
				return this.filter(":input").val(function(i, v) {
					return $.grep(v.split(','), function(val) {  
						return val != value;
					}).join(',');
				}).end();
			}
		});
		$(document).ready(function() 
		{ 
			$(".check").change(function(){
				if($(this).is(":checked")){
					$(":checkbox[value='"+$(this).val()+"']").attr("checked", true);
					newElement = "<div class='singleLabel' id="+$(this).val()+"><span>"+$(this).attr('data-label-text')+"</span><a class='labelRemove' onclick=removeLabel('#attributes.file_id#','#attributes.file_type#','"+$(this).val()+"',this) >X</a></div>";
					<cfif attributes.file_id NEQ '0'>
						$('##select_lables_#attributes.file_id#').append(newElement);
					<cfelse>
						$('##lables_#attributes.file_type#').append(newElement);
						$("##search_labels_#attributes.file_type#").addToArray($(this).attr('data-label-text'));
					</cfif>
					loadcontent('div_forall','index.cfm?fa=c.asset_label_add_remove&fileid=#attributes.file_id#&thetype=#attributes.file_type#&checked=true&labels=' + $(this).val());
				} else {
					$(":checkbox[value='"+$(this).val()+"']").attr("checked", false);
					<cfif attributes.file_id NEQ '0'>
						$('##select_lables_#attributes.file_id# div##'+$(this).val()+'').remove();
					<cfelse>
						$('##lables_#attributes.file_type# div##'+$(this).val()+'').remove();
						$("##search_labels_#attributes.file_type#").removeFromArray($(this).attr('data-label-text'));
					</cfif>
					loadcontent('div_forall','index.cfm?fa=c.asset_label_add_remove&fileid=#attributes.file_id#&thetype=#attributes.file_type#&checked=false&labels=' + $(this).val());
				}
				<cfif attributes.file_id NEQ '0'> 
				$.sticky('<span style="color:green;font-Weight:bold;">Your change has been saved!</span>');
				</cfif>
				return false;
			 });
		});
	</script>
</cfoutput>