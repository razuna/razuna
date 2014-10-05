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
<cfif cs.show_basket_part OR cs.show_favorites_part OR qry_orders.recordcount NEQ 0>	
	<cfif !cs.show_basket_part>
		<cfset basket_css  = "display:none;">
	<cfelse>
		<cfset basket_css  = "">
	</cfif>
	
	<cfif !cs.show_favorites_part>
		<cfset favorites_css  = "display:none;">
	<cfelse>
		<cfset favorites_css  = "">
	</cfif>

	<cfif qry_orders.recordcount EQ 0>
		<cfset orders_css  = "display:none;">
	<cfelse>
		<cfset orders_css  = "">
	</cfif>

	<div id="tabs_footer">
		<ul>
			<li style="#basket_css#" ><a href="##thedropbasket" id="div_link_basket" onclick="tooglefooter('0');loadcontent('thedropbasket','#myself#c.basket');">#myFusebox.getApplicationData().defaults.trans("show_basket")#</a></li>
			<li style="#favorites_css#"><a href="##thedropfav" id="div_link_fav"onclick="tooglefooter('1');loadcontent('thedropfav','#myself#c.favorites');">Show #myFusebox.getApplicationData().defaults.trans("header_favorites")#</a></li>
			<li style="#orders_css#"><a href="##thedroporders" id="div_link_orders" onclick="tooglefooter('2');loadcontent('thedroporders','#myself#c.orders');">Show Orders</a></li>
			<cfif !application.razuna.whitelabel>
				<li style="float:right;"><a href="##raztab" onclick="tooglefooter('3');">About Razuna</a></li>
			<cfelseif application.razuna.whitelabel AND wl_text NEQ "">
				<li style="float:right;"><a href="##raztab" onclick="tooglefooter('3');">#wl_text#</a></li>
			</cfif>
		</ul>
		<div id="thedropbasket" style="float:left;width:100%;padding:0px 10px 0px 10px;"></div>
		<div id="thedropfav" style="float:left;width:100%;padding:0px 10px 0px 10px;"></div>
		<cfif qry_orders.recordcount NEQ 0>
			<div id="thedroporders" style="float:left;width:100%;padding:0px 10px 0px 10px;"></div>
		</cfif>
		<div id="raztab" style="float:right;padding:10px 10px 0px 10px;font-weight:normal;width:100%;">
			<div style="float:right;text-align:right;">
				<cfif application.razuna.whitelabel>
					#wl_content#
				<cfelse>
					<a href="http://www.razuna.com" target="_blank"><img src="../../global/host/dam/images/razuna_logo-200.png" width="220" height="34" border="0" style="padding:3px 0px 0px 5px;"></a>
					<br>
					<cfif !application.razuna.isp>
						<a href="http://www.razuna.com" target="_blank">Razuna</a> #version#<br>
						Licensed under <a href="http://www.razuna.org/whatisrazuna/licensing" target="_blank">AGPL</a><br>
					</cfif>
					<a href="http://razuna.com" target="_blank">Razuna Hosted Platform</a> and <a href="http://razuna.org" target="_blank">Razuna Open Source</a><br>
					<a href="http://blog.razuna.com" target="_blank">Visit the Razuna Blog for latest news.</a>
				</cfif>
			</div>
		</div>
	</div>

	<script type="text/javascript">
	jqtabs("tabs_footer");
	function tooglefooter(what){
		// which div to resize
		var thefooterslider = $('##footer_drop');
		// get selected tab
		var selected = $('##tabs_footer').tabs( "option", "active" );
		// Resize
		if (thefooterslider.height() == '30'){
			// Resize and show
			thefooterslider.css('height','160px');
			if(what == 0){
				$('##div_link_basket').html('Hide #myFusebox.getApplicationData().defaults.trans("header_basket")#');
				//loadcontent('thedropbasket','#myself#c.basket');
			}
			else if (what == 1){
				$('##div_link_fav').html('Hide #myFusebox.getApplicationData().defaults.trans("header_favorites")#');
				//loadcontent('thedropfav','#myself#c.favorites');
			}
			else if (what == 2){
				$('##div_link_orders').html('Hide Orders');
				//loadcontent('thedroporders','#myself#c.orders');
			}
		}
		else {
			// Resize and Hide
			if(selected == what){
				$('##div_link_basket').html('Show #myFusebox.getApplicationData().defaults.trans("header_basket")#');
				$('##div_link_fav').html('Show #myFusebox.getApplicationData().defaults.trans("header_favorites")#');
				$('##div_link_orders').html('Show Orders');
				thefooterslider.css('height','30px');
			}
		}	
	}
	$(function() {
		$("##thedropbasket").droppable({
			tolerance: 'touch',
			//activeClass: 'assetbaskethover',
			drop: function(event, ui) {
				var thisid = $(ui.draggable).attr("id");
				if(thisid==undefined)
					var thisid = $(ui.draggable).attr("role");
				var thistype = $(ui.draggable).attr("type");
				var thisid = thisid.replace('draggable','');
				var thisid = thisid.replace('draggable-s','');
				$('##div_forall').load('#myself#c.basket_put&file_id=' + thistype + '&thetype=' + thistype, function(){
					$('##thedropbasket').load('#myself#c.basket');
				});
			}
		});
	});
	$(function() {
		$("##thedropfav").droppable({
			tolerance: 'touch',
			//activeClass: 'assetbaskethover',
			drop: function(event, ui) {
				var thisid = $(ui.draggable).attr("id");
				var thistype = $(ui.draggable).attr("type");
				if(thistype.indexOf("-all") != -1){
					var thisid = thisid;
				}
				else{
					var thisid = thistype;
				}
				var thisid = thisid.replace('draggable','');
				var thisid = thisid.replace('draggable-s','');
				$('##div_forall').load('#myself#c.favorites_put&favtype=file&favid=' + thisid, function(){
					$('##thedropfav').load('#myself#c.favorites');
				});
				
			}
		});
	});
	function send_feedback(){
		// Get values
		var url = formaction("form_feedback");
		var items = formserialize("form_feedback");
		// Submit Form
		$.ajax({
			type: "POST",
			url: url,
		   	data: items,
		   	success: function(){
		   		$('##send_feedback_status').html('We have sent your feedback and will contact you if needed. Thank you.');
		   	}
		});
		return false;
	}
	</script>
</cfif>
</cfoutput>
