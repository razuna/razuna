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
<form action="#self#" method="post" name="formwmtemp" id="formwmtemp">
<input type="hidden" name="#theaction#" value="c.admin_watermark_template_save">
<input type="hidden" name="wm_temp_id" value="#attributes.wm_temp_id#">
<input type="hidden" name="wm_image_path" id="wm_image_path" value="#qry_detail.wmval.wm_image_path#">
	<!--- Output --->
	<div id="thewmtemp">
		<input type="checkbox" name="wm_active" value="true"<cfif qry_detail.wm.wm_active> checked="checked"</cfif> /> #myFusebox.getApplicationData().defaults.trans("admin_watermark_templates_active")#
		<br />
		<div style="width:90px;float:left;line-height:2em;padding-left:24px;">#myFusebox.getApplicationData().defaults.trans("admin_watermark_template_name")#</div>
		<div style="float:left;"><input type="text" style="width:400px;" name="wm_name" id="wm_name" value="#qry_detail.wm.wm_name#" /></div>
		<div class="clear"></div>
		<br />
		<input type="checkbox" name="wm_use_image" value="true"<cfif qry_detail.wmval.wm_use_image> checked="checked"</cfif> /> <strong>#myFusebox.getApplicationData().defaults.trans("admin_watermark_use_image")#</strong>
		<br /><br />
		<div style="padding-left:25px;">
			<div style="width:90px;float:left;line-height:2em;">#myFusebox.getApplicationData().defaults.trans("admin_watermark_upload_image")#</div>
			<div style="float:left;">
				<iframe src="#myself#ajax.admin_watermark_upload&wm_temp_id=#attributes.wm_temp_id#" frameborder="false" scrolling="false" style="border:0px;width:250px;height:50px;"></iframe>
			</div>
			<div id="thewmimg" style="float:left;width:250px;"><cfif qry_detail.wmval.wm_image_path NEQ ""><img src="../../global/host/watermark/#session.hostid#/#qry_detail.wmval.wm_image_path#" width="200" border="0" /></cfif></div>
			<div class="clear"></div>
			<br />
			<div style="width:90px;float:left;line-height:2em;">#myFusebox.getApplicationData().defaults.trans("opacity")#</div>
			<div style="float:left;"><input type="text" style="width:30px;" name="wm_image_opacity" value="<cfif qry_detail.wmval.wm_image_opacity EQ "">50<cfelse>#qry_detail.wmval.wm_image_opacity#</cfif>" /> 0 - 100 %</div>
			<div class="clear"></div>
			<br />
			<div style="width:90px;float:left;">#myFusebox.getApplicationData().defaults.trans("admin_watermark_position_image")#</div>
			<div style="float:left;">
				<select name="wm_image_position">
					<option value="center"<cfif qry_detail.wmval.wm_image_position EQ "center"> selected="selected"</cfif>>#myFusebox.getApplicationData().defaults.trans("center")#</option>
					<option value="northeast"<cfif qry_detail.wmval.wm_image_position EQ "northeast"> selected="selected"</cfif>>#myFusebox.getApplicationData().defaults.trans("upper_right")#</option>
					<option value="northwest"<cfif qry_detail.wmval.wm_image_position EQ "northwest"> selected="selected"</cfif>>#myFusebox.getApplicationData().defaults.trans("upper_left")#</option>
					<option value="southeast"<cfif qry_detail.wmval.wm_image_position EQ "southeast"> selected="selected"</cfif>>#myFusebox.getApplicationData().defaults.trans("lower_right")#</option>
					<option value="southwest"<cfif qry_detail.wmval.wm_image_position EQ "southwest"> selected="selected"</cfif>>#myFusebox.getApplicationData().defaults.trans("lower_left")#</option>
				</select>
			</div>
		</div>
		<br /><br />
		<input type="checkbox" name="wm_use_text" value="true"<cfif qry_detail.wmval.wm_use_text> checked="checked"</cfif> /> <strong>#myFusebox.getApplicationData().defaults.trans("admin_watermark_use_text")#</strong>
		<br /><br />
		<div style="padding-left:25px;">
			<div style="width:90px;float:left;line-height:2em;">#myFusebox.getApplicationData().defaults.trans("admin_watermark_text_content")#</div>
			<div style="float:left;">
			<input type="text" style="width:400px;" name="wm_text_content" value="#qry_detail.wmval.wm_text_content#" />
			</div>
			<div class="clear"></div>
			<br />
			<div style="width:90px;float:left;">#myFusebox.getApplicationData().defaults.trans("admin_watermark_text_font")#</div>
			<div style="float:left;">
				<select name="wm_text_font">
					<cfloop list="#qry_detail.fontlist#" delimiters="," index="f">
						<cfset fullname = listFirst(f,":")>
						<cfset fontname = listLast(f,":")>
						<option value="#fontname#"<cfif qry_detail.wmval.wm_text_font EQ fontname> selected="selected"</cfif>>#fullname#</option>
					</cfloop>
				</select>
			</div>
			<div class="clear"></div>
			<br />
			<div style="width:90px;float:left;line-height:2em;">#myFusebox.getApplicationData().defaults.trans("admin_watermark_text_font_size")#</div>
			<div style="float:left;"><input type="text" style="width:20px;" name="wm_text_font_size" value="<cfif qry_detail.wmval.wm_text_font_size EQ "">36<cfelse>#qry_detail.wmval.wm_text_font_size#</cfif>" />pt</div>
			<div class="clear"></div>
			<br />
			<div style="width:90px;float:left;line-height:2em;">#myFusebox.getApplicationData().defaults.trans("opacity")#</div>
			<div style="float:left;">
			<input type="text" style="width:30px;" name="wm_text_opacity" value="<cfif qry_detail.wmval.wm_text_opacity EQ "">100<cfelse>#qry_detail.wmval.wm_text_opacity#</cfif>" /> (100% means no opacity)
			</div>
			<div class="clear"></div>
			<br />
			<div style="width:90px;float:left">#myFusebox.getApplicationData().defaults.trans("admin_watermark_position_text")#</div>
			<div style="float:left;">
			<select name="wm_text_position">
				<option value="center"<cfif qry_detail.wmval.wm_text_position EQ "center"> selected="selected"</cfif>>#myFusebox.getApplicationData().defaults.trans("center")#</option>
				<option value="northeast"<cfif qry_detail.wmval.wm_text_position EQ "northeast"> selected="selected"</cfif>>#myFusebox.getApplicationData().defaults.trans("upper_right")#</option>
				<option value="northwest"<cfif qry_detail.wmval.wm_text_position EQ "northwest"> selected="selected"</cfif>>#myFusebox.getApplicationData().defaults.trans("upper_left")#</option>
				<option value="southeast"<cfif qry_detail.wmval.wm_text_position EQ "southeast"> selected="selected"</cfif>>#myFusebox.getApplicationData().defaults.trans("lower_right")#</option>
				<option value="southwest"<cfif qry_detail.wmval.wm_text_position EQ "southwest"> selected="selected"</cfif>>#myFusebox.getApplicationData().defaults.trans("lower_left")#</option>
			</select>
		</div>
		</div>
	</div>
	<div class="clear"></div>
	<div id="submit" style="float:right;padding:10px;">
		<div id="wmtempfeedback" style="color:green;padding:10px;display:none;float:left;font-weight:bold;"></div>
		<input type="submit" name="SubmitUser" value="#myFusebox.getApplicationData().defaults.trans("button_save")#" class="button" style="float:right;">
	</div>

</form>

<!--- Activate the Tabs --->
<script language="JavaScript" type="text/javascript">
	// Fire the form submit for new or update
	$(document).ready(function(){
		$("##formwmtemp").validate({
			submitHandler: function(form) {
				jQuery(form).ajaxSubmit({
					success: formwmtempfeedback
				});
			},
			rules: {
				wm_name: "required"			   
			 }
		});
	});
	// Feedback when saving form
	function formwmtempfeedback() {
		$("##wmtempfeedback").css("display","");
		$("##wmtempfeedback").html("#JSStringFormat(myFusebox.getApplicationData().defaults.trans("success"))#");
		loadcontent('admin_watermark_templates', '#myself#c.admin_watermark_templates');
	}
	
</script>
</cfoutput>
