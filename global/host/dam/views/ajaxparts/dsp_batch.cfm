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
	<!--- Turn date inputs into jQuery datepicker --->
	  <script>
		  $(function() {
		    $( "##expiry_date" ).datepicker();
		  });
	  </script>
	<form name="form0" id="form0" method="post" action="#self#">
	<input type="hidden" name="#theaction#" value="#xfa.batchdo#">
	<input type="hidden" name="langcount" value="#valuelist(qry_langs.lang_id)#">
	<input type="hidden" name="thepath" value="#thisPath#">
	<input type="hidden" name="what" value="#attributes.what#">
	<input type="hidden" name="file_id" value="#attributes.file_id#">
	<input type="hidden" name="file_ids" value="#session.thefileid#">
	<input type="hidden" name="folder_id" value="#attributes.folder_id#">
	<input type="hidden" name="customfields" value="#qry_cf.recordcount#">
		<div id="tabs_batch">
			<ul>
				<li tabindex="0"><a href="##batch_desc">#myFusebox.getApplicationData().defaults.trans("asset_desc")#</a></li>
				<cfif attributes.what EQ "img" OR session.thefileid CONTAINS "-img">
					<cfif cs.tab_xmp_description><li tabindex="1"><a href="##batch_xmp">XMP Description</a></li></cfif>
					<cfif cs.tab_iptc_contact><li tabindex="2"><a href="##iptc_contact">IPTC Contact</a></li></cfif>
					<cfif cs.tab_iptc_image><li tabindex="3"><a href="##iptc_image">IPTC Image</a></li></cfif>
					<cfif cs.tab_iptc_content><li tabindex="4"><a href="##iptc_content">IPTC Content</a></li></cfif>
					<cfif cs.tab_iptc_status><li tabindex="5"><a href="##iptc_status">IPTC Status</a></li></cfif>
					<cfif cs.tab_origin><li tabindex="6"><a href="##iptc_origin">Origin</a></li></cfif>
				</cfif>
				<cfif cs.tab_labels><li tabindex="7"><a href="##batch_labels" onclick="activatechosen();">#myFusebox.getApplicationData().defaults.trans("labels")#</a></li></cfif>
				<cfif cs.tab_custom_fields AND qry_cf.recordcount><li tabindex="8"><a href="##batch_custom">#myFusebox.getApplicationData().defaults.trans("custom_fields_header")#</a></li></cfif>
			</ul>
			<!--- Descriptions & Keywords --->
			<div id="batch_desc">
				<table border="0" cellpadding="0" cellspacing="0" width="100%" class="grid">
					<cfloop query="qry_langs">
						<tr>
							<td class="td2" valign="top" width="1%" nowrap="true"><strong>#lang_name#: #myFusebox.getApplicationData().defaults.trans("description")#</strong></td>
							<td class="td2" width="100%"><textarea name="<cfif what EQ "doc">file<cfelseif what EQ "vid">vid<cfelseif what EQ "img">img<cfelseif what EQ "aud">aud<cfelseif what EQ "all">all</cfif>_desc_#lang_id#" class="text" rows="2" cols="50"<cfif attributes.what EQ "img"> onchange="javascript:document.form#attributes.file_id#.iptc_content_description_#lang_id#.value = document.form#attributes.file_id#.img_desc_#lang_id#.value"</cfif>></textarea></td>
						</tr>
						<tr>
							<td class="td2" valign="top" width="1%" nowrap="true"><strong>#lang_name#: #myFusebox.getApplicationData().defaults.trans("keywords")#</strong></td>
							<td class="td2" width="100%"><textarea name="<cfif what EQ "doc">file<cfelseif what EQ "vid">vid<cfelseif what EQ "img">img<cfelseif what EQ "aud">aud<cfelseif what EQ "all">all</cfif>_keywords_#lang_id#" class="text" rows="2" cols="50"<cfif attributes.what EQ "img"> onchange="javascript:document.form#attributes.file_id#.iptc_content_keywords_#lang_id#.value = document.form#attributes.file_id#.img_keywords_#lang_id#.value"</cfif>></textarea></td>
						</tr>
					</cfloop>
				</table>
				<!--- Expiry date field --->
				<table border="0" cellpadding="0" cellspacing="0" width="100%" class="grid">
					<tr>
						<td width="1%" nowrap="true"><strong>#myFusebox.getApplicationData().defaults.trans("expiry_date")#</strong></td>
						<td width="100%"><input name="expiry_date" id="expiry_date"></td>
					</tr>
				</table>
			</div>
			<cfif attributes.what EQ "img" OR session.thefileid CONTAINS "-img">
				<!--- XMP Description --->
				<cfif cs.tab_xmp_description>
					<div id="batch_xmp">
						<cfinclude template="dsp_asset_images_xmp.cfm">
					</div>
				</cfif>
				<!--- IPTC Contact --->
				<cfif cs.tab_iptc_contact>
					<div id="iptc_contact">
						<cfinclude template="dsp_asset_images_iptc_contact.cfm">
					</div>
				</cfif>
				<!--- IPTC Image --->
				<cfif cs.tab_iptc_image>
					<div id="iptc_image">
						<cfinclude template="dsp_asset_images_iptc_image.cfm">
					</div>
				</cfif>
				<!--- IPTC Content --->
				<cfif cs.tab_iptc_content>
					<div id="iptc_content">
						<cfinclude template="dsp_asset_images_iptc_content.cfm">
					</div>
				</cfif>
				<!--- IPTC Status --->
				<cfif cs.tab_iptc_status>
					<div id="iptc_status">
						<cfinclude template="dsp_asset_images_iptc_status.cfm">
					</div>
				</cfif>
				<!--- Origin --->
				<cfif cs.tab_origin>
					<div id="iptc_origin">
						<cfinclude template="dsp_asset_images_origin.cfm">
					</div>
				</cfif>
			</cfif>
			<!--- Labels --->
			<cfif cs.tab_labels>
				<div id="batch_labels" style="min-height:200px;">
					<strong>Choose #myFusebox.getApplicationData().defaults.trans("labels")#</strong><br />
					<select data-placeholder="Choose a label" class="chzn-select" style="width:410px;" name="labels" id="tags_labels" multiple="multiple">
						<option value=""></option>
						<cfloop query="qry_labels">
							<cfset l = replace(label_path," "," AND ","all")>
							<cfset l = replace(l,"/"," AND ","all")>
							<option value="#label_id#">#label_path#</option>
						</cfloop>
					</select>
				</div>
			</cfif>
			<!--- Custom Fields --->
			<div id="batch_custom">
				<!--- Custom Fields --->
				<cfif qry_cf.recordcount NEQ 0 AND cs.tab_custom_fields>
					<div id="customfields" style="padding-top:10px;">
						<cfinclude template="inc_batch_custom_fields.cfm">
					</div>
					<div stlye="clear:both;"></div>
				</cfif>
			</div>
			
		</div>
		<!--- Submit Button --->
		<div style="float:right;padding:10px;">New values will <input type="radio" name="batch_replace" value="true" /> replace or <input type="radio" name="batch_replace" value="false" checked="checked" /> append to existing records. <input type="submit" name="submit" value="Batch records now" class="button"></div>
		<div id="updatebatch" style="float:left;padding:10px;color:green;font-weight:bold;display:none;"></div>
	</form>
	<!--- Activate the Tabs --->
	<script language="JavaScript" type="text/javascript">
		// Initialize Tabs
		jqtabs("tabs_batch");
		// Submit Form
		$("##form0").submit(function(e){
			// Show
			$("##updatebatch").css("display","");
			$("##updatebatch").html('<img src="#dynpath#/global/host/dam/images/loading.gif" border="0" style="padding:10px;" width="16" height="16">');
			// Get values
			var url = formaction("form0");
			var items = formserialize("form0");
			// Submit Form
			$.ajax({
				type: "POST",
				url: url,
			   	data: items,
			   	success: function(){
			   		$("##updatebatch").html('#JSStringFormat(myFusebox.getApplicationData().defaults.trans("batch_done"))#');
					$("##updatebatch").animate({opacity: 1.0}, 3000).fadeTo("slow", 0.33);
			   	}
			});
			return false;
		});
		// Activate Chosen
		function activatechosen(){
			setTimeout(function() {
		    	activatechosendelay();
			}, 10)
		};
		function activatechosendelay(){
			$(".chzn-select").chosen({search_contains: true});
		}
	</script>
</cfoutput>