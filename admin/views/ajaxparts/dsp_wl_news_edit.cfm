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
	<form name="form_wl_news" id="form_wl_news" method="post" action="#self#">
	<input type="hidden" name="#theaction#" value="c.wl_news_save">
	<input type="hidden" name="news_id" value="#attributes.news_id#">
		<strong>Title</strong><br />
		<p><input type="text" style="width:600px;" name="news_title" id="news_title" value="#qry_news_edit.news_title#" /></p>
		<strong>Message</strong><br />
		<p><textarea name="news_text" id="news_text" style="width:600px;height:200px;">#qry_news_edit.news_text#</textarea></p>
		<strong>Date (US format)</strong><br />
		<p><input type="text" style="width:600px;" name="news_date" id="news_date" value="<cfif attributes.add>#dateformat(now(), "mm-dd-yyyy")# #timeformat(now(), "hh:mm tt")#<cfelse>#qry_news_edit.news_date#</cfif>" /></p>
		<strong>Show entry</strong>
		<p><input type="radio" name="news_active" value="true"<cfif qry_news_edit.news_active> checked="checked"</cfif>> Yes <input type="radio" name="news_active" value="false"<cfif !qry_news_edit.news_active> checked="checked"</cfif>> No</p>
		<input type="submit" name="submitbuttonnews" value="#myFusebox.getApplicationData().defaults.trans("save")#">
		<br /><br />
		<div id="wlfeedbacknews" style="display:none;font-weight:bold;color:green;padding-bottom:15px;"></div>
 	</form>
 	<script type="text/javascript">
 		$('##news_text').markItUp(mySettings);
 		// Save this form
		$("##form_wl_news").submit(function(e){
			// Get values
			var url = formaction("form_wl_news");
			var items = formserialize("form_wl_news");
			// Submit Form
			$.ajax({
				type: "POST",
				url: url,
			   	data: items
			});
			// Display saved message
			$("##wlfeedbacknews").css("display","");
			$("##wlfeedbacknews").html('#defaultsObj.trans("saved_changes")#');
			// Refresh list
			loadcontent('wl_news','#myself#c.wl_news');
			return false;
		});
 	</script>
</cfoutput>