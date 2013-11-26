<cfoutput>
	<div style="float:left;width:100%;">
		<div style="float:left;text-align:left;width:100%;">
			<cfif qry_labels.recordcount>
				<!--- Looping the all labels in the query --->
				<cfloop query="qry_labels" >
					<label style="float:left;clear:both;">
					<input type="checkbox" data-label-text="<cfif qry_labels.label_id_r EQ '0'>#label_text#<cfelse>#qry_labels.label_path#</cfif>" 
							name="label_id" id="check_label_#label_id#" class="check" value="#label_id#"  <cfif listfindnocase(attributes.asset_labels_list,#label_id#,',')>checked="checked"</cfif> style="float:left;width:20px; "> 
					#label_text# <cfif qry_labels.label_id_r EQ '0'>(root level)<cfelse>(#qry_labels.label_path#)</cfif>
					</label></br>
				</cfloop> 
			<cfelse>
				<span style="font-weight:bold;"> No record found!</span>
			</cfif>
		</div>
	</div>
	<script type="text/javascript">
		$(document).ready(function() 
	    { 
			  $(".check").change(function(){
				if($(this).is(":checked")){
					$(":checkbox[value='"+$(this).val()+"']").attr("checked", true);
					newElement = "<div class='singleLabel' id="+$(this).val()+"><span>"+$(this).attr('data-label-text')+"</span><a class='labelRemove' onclick=removeLabel('#attributes.file_id#','#attributes.file_type#','"+$(this).val()+"',this) >X</a></div>";
					$('##select_lables_#attributes.file_id#').append(newElement);
					loadcontent('div_forall','index.cfm?fa=c.asset_label_add_remove&fileid=#attributes.file_id#&thetype=#attributes.file_type#&checked=true&labels=' + $(this).val());
				} else {
					$(":checkbox[value='"+$(this).val()+"']").attr("checked", false);
					$('##select_lables_#attributes.file_id# div##'+$(this).val()+'').remove();
					loadcontent('div_forall','index.cfm?fa=c.asset_label_add_remove&fileid=#attributes.file_id#&thetype=#attributes.file_type#&checked=false&labels=' + $(this).val());
				}
				$.sticky('<span style="color:green;font-Weight:bold;">Your change has been saved!</span>');
				return false;
			 });
		});
	</script>
</cfoutput>