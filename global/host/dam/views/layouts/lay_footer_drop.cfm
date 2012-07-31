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
<div id="tabs_footer">
	<ul>
		<li><a href="##thedropbasket" id="div_link_basket" onclick="tooglefooter('0');loadcontent('thedropbasket','#myself#c.basket');">Show #myFusebox.getApplicationData().defaults.trans("header_basket")#</a></li>
		<li><a href="##thedropfav" id="div_link_fav" onclick="tooglefooter('1');loadcontent('thedropfav','#myself#c.favorites');">Show #myFusebox.getApplicationData().defaults.trans("header_favorites")#</a></li>
		<cfif qry_orders.recordcount NEQ 0>
			<li><a href="##thedroporders" id="div_link_orders" onclick="tooglefooter('2');loadcontent('thedroporders','#myself#c.orders');">Show Orders</a></li>
		</cfif>
		<li style="float:right;"><a href="##raztab" onclick="tooglefooter('<cfif qry_orders.recordcount EQ 0>2<cfelse>3</cfif>');">About Razuna</a></li>
	</ul>
	<div id="thedropbasket" style="float:left;width:100%;padding:0px 10px 0px 10px;"></div>
	<div id="thedropfav" style="float:left;width:100%;padding:0px 10px 0px 10px;"></div>
	<cfif qry_orders.recordcount NEQ 0>
		<div id="thedroporders" style="float:left;width:100%;padding:0px 10px 0px 10px;"></div>
	</cfif>
	<div id="raztab" style="float:right;padding:10px 10px 0px 10px;font-weight:normal;width:100%;">
		<div id="div_feedback" style="float:left;padding-left:20px;">
			<a href="http://twitter.com/razunahq" class="twitter-follow-button">Follow @razunahq</a><br /><br />
			<iframe src="//www.facebook.com/plugins/like.php?app_id=207944582601260&amp;href=http%3A%2F%2Fwww.facebook.com%2Frazunahq&amp;send=false&amp;layout=standard&amp;width=450&amp;show_faces=false&amp;action=like&amp;colorscheme=light&amp;height=35" scrolling="no" frameborder="0" style="border:none; overflow:hidden; width:300px; height:55px;" allowTransparency="true"></iframe>
		</div>
		<!--- <div id="div_feedback" style="float:left;padding-left:20px;">
		<strong>Have any feedback? Make sure to let us know!</strong><br>
		<form action="#self#" method="post" name="form_feedback" id="form_feedback" onsubmit="send_feedback();return false;">
		<input type="hidden" name="fa" value="c.send_feedback">
			<div id="info">
			    <label for="author">Name</label> 
				<input type="text" name="author" id="author" value="" size="22" tabindex="1" class="rounded" /> 
				<label for="email">Email</label> 
				<input type="text" name="email" id="email" value="" size="22" tabindex="2" class="rounded" /> 
				<label for="url">Razuna URL</label> 
				<input type="text" name="url" id="url" value="" size="22" tabindex="3" class="rounded" /> 
			</div>
			<div id="feedbsubmit">
				<div style="float:left;">
				<input name="submit" type="submit" id="submit" class="rounded" tabindex="5" value="Submit" />
				</div>
				<div id="send_feedback_status" style="clear:both;padding:0;margin:0;color:green;width:200px;"></div>
			</div>
			<div id="message">
				<label for="comment">Feedback</label>
				<textarea name="comment" id="comment" cols="2" rows="2" tabindex="4" class="rounded"></textarea> 
			</div>
		</form>
		</div> --->
		<div style="float:right;text-align:right;">
			<a href="http://www.razuna.com" target="_blank"><img src="#dynpath#/global/host/dam/images/razuna_logo-200.png" width="200" height="29" border="0" style="padding:3px 0px 0px 5px;"></a>
			<br>
			<cfif NOT application.razuna.isp>
				<a href="http://www.razuna.com" target="_blank">Razuna</a> #version#<br>
				Licensed under <a href="http://www.razuna.org/whatisrazuna/licensing" target="_blank">AGPL</a><br>
			</cfif>
			<a href="http://razuna.com" target="_blank">Razuna Hosted Platform</a> and <a href="http://razuna.org" target="_blank">Razuna Open Source</a><br>
			<a href="http://blog.razuna.com" target="_blank">Visit the Razuna Blog for latest news.</a>
		</div>
	</div>
</div>

<script type="text/javascript">
jqtabs("tabs_footer");
function tooglefooter(what){
	// which div to resize
	var thefooterslider = $('##footer_drop');
	// get selected tab
	var selected = $('##tabs_footer').tabs( "option", "selected" );
	if (what == 3){
		var selected = 3;
	}
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
			var thistype = $(ui.draggable).attr("type");
			thisid = thisid.replace('draggable','');
			thisid = thisid.replace('draggable-s','');
			loadcontent('thedropbasket','#myself#c.basket_put&file_id=' + thistype + '&thetype=' + thistype);
			loadcontent('thedropbasket','#myself#c.basket');
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
			thisid = thisid.replace('draggable','');
			thisid = thisid.replace('draggable-s','');
			loadcontent('thedropfav','#myself#c.favorites_put&favtype=file&favid=' + thisid);
			loadcontent('thedropfav','#myself#c.favorites');
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
</cfoutput>
