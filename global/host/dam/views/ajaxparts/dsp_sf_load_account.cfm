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
<!---  --->
<!--- This template works by default with Dropbox --->
<!---  --->
<cfoutput>
	<cfset pc = "">
	<input type="hidden" id="thepath" name="thepath" value="" />
	<!--- Breadcrumb --->
	<strong><a href="##" onclick="loadoverlay();$('##sf_account').load('#myself#c.sf_load_account', { sf_type: '#session.sf_account#' }, function(){ $('##bodyoverlay').remove(); });return false;">Home</a> / <cfloop list="#qry_sf_list.path#" index="p" delimiters="/">
			<cfif session.sf_account EQ "dropbox">
				<cfset pc = pc & "/" & p>
			<cfelse>
				<cfset pc = pc & p & "/">
			</cfif>
			<a rel="prefetch" href="##" onclick="loadoverlay();$('##sf_account').load('#myself#c.sf_load_account', { path: '<cfif session.sf_account EQ "dropbox">/</cfif>#pc#', sf_type: '#session.sf_account#'}, function(){$('##bodyoverlay').remove(); });return false;">#p#</a> / 
		</cfloop></strong>
	<p></p>
	<div id="sf_select_div">
		<div style="padding:10px;"><a href="##" onclick="downloadselected();">#myFusebox.getApplicationData().defaults.trans("sf_import_to_razuna_all")#</a></div>
	</div>
	<p></p>
	<div style="text-decoration:none;width:600px;"<cfif attributes.folderaccess NEQ "R"> id="selectme"</cfif>>
		<!--- Dropbox --->
		<cfif session.sf_account EQ "dropbox">
			<!--- Loop over array --->
			<cfloop array="#qry_sf_list.contents#" index="a">
				<cfinclude template="inc_sf_load_account.cfm">
			</cfloop>
		<!--- Amazon --->
		<cfelseif session.sf_account EQ "amazon">
			<cfloop query="qry_sf_list.contents">
				<!--- Set path --->
				<cfset a.path = key>
				<!--- Change query var to fit the dropbox ones --->
				<cfif size EQ 0>
					<cfset a.is_dir = true>
				<cfelse>
					<cfset a.is_dir = false>
				</cfif>
				<cfinclude template="inc_sf_load_account.cfm">
			</cfloop>
		</cfif>
	</div>
	<script type="text/javascript">
		$("img").trigger('scroll'); // this is needed for the first time to trigger 
		$("img").lazyload({
			event: "scrollstop"
		});
		$(window).bind("load", function() { 
		    var timeout = setTimeout(function() {
		    	$("img.lazy").trigger("scrollstop")
		    }, 5000);
		});
		$(window).resize();
		// Make files selectable
		$("##selectme").selectable({
			cancel: 'a,##folder',
			selecting: function( event, ui ) {
				$( "##folder", this ).each(function() {
					$(this).css('background','##FFFFFF');
				});
			},
			stop: function(event, ui) {
				var l = '';
				$( ".ui-selected", this ).each(function() {
					if (this.id != "" && this.id != "folder"){
						l += this.id + ',';
					}
				});
				// Store value in hidden field
				$('##thepath').val(l);
				// Call function to show/hide menu
				showhidemenu();
			}
		});
		// Show/hide dropdown
		function showhidemenu(){
			var n = $(".ui-selected").length;
		    // Open or close selection
		    if (n > 0) {
				$("##sf_select_div").slideDown('slow');
			}
			if (n == 0) {
				$("##sf_select_div").slideUp('slow');
			}
		}
		// Trigger downloadselected
		function downloadselected(){
			// Grab the selected values from the hidden field
			var thepath = $('##thepath').val();
			// Store value in session scope
			$('##div_forall').load('#myself#c.sf_load_download_folder_include', { path: thepath } );
			// Open window for use to select folder
			showwindow('#myself#c.sf_load_download_folder','#myFusebox.getApplicationData().defaults.trans("sf_choose_folder")#',600,1);
		}
	</script>
</cfoutput>
