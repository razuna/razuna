<cfoutput>
	<table border="0" cellpadding="0" cellspacing="0">
		<cfif qry_results.recordcount AND qry_results.id NEQ ''>
			<cfloop query="qry_results">
				<cfif id NEQ attributes.fid>
					<tr>
						<td>
							<input type="checkbox" name="idList" class="idList" value="#id#"> #filename#
						</td>
					</tr>
				</cfif>
			</cfloop>
		<cfelse>
			<tr>
				<td>
					<p style="color:red; font-weight:bolder;">#myFusebox.getApplicationData().defaults.trans("no_related_record")#</p>
				</td>
			</tr>
		</cfif>
	</table>
</cfoutput><hr>
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
</script>