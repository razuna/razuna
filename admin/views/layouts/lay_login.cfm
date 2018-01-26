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
	<!--- <div id="apDiv1"><span class="loginheader"><img src="images/logo.png" width="170" height="22" border="0" style="padding:7px 0px 0px 5px;"></span></div> --->
	<cfif application.razuna.firsttime>
		<div id="outerfirsttime">
			<div id="firsttime">
	<cfelse>
		<div id="outer">
			<div id="loginform">
	</cfif>
		<!--- News --->
		<cfif ! application.razuna.firsttime AND structKeyExists(attributes, "qry_news") AND attributes.qry_news.recordcount>
			<div style="text-align:center" class="news_frontpage">
				<h2>#attributes.qry_news.news_title#</h2>
				<p>#attributes.qry_news.news_excerpt#
				<cfif attributes.qry_news.news_text NEQ "">
					<p><a href="##news-frontpage-popup" class="open-news-popup">Read more...</a></p>
				</cfif>
				</p>
			</div>
			<div id="news-frontpage-popup" class="white-popup mfp-hide">
				#attributes.qry_news.news_text#
			</div>
		</cfif>
	    #body#
	  	</div>
	<cfif NOT application.razuna.firsttime>
	  	<div id="loginformfooter">
		<a href="http://www.razuna.com" target="_blank">Razuna</a> #settingsObj.getconfig("version")#
		<br>Licenced under <a href="http://www.razuna.org/whatisrazuna/licensing" target="_blank">AGPL</a>
		<br><a href="http://razuna.com" target="_blank">Razuna Website</a>
		<br><a href="http://blog.razuna.com" target="_blank">Razuna Blog</a>
		</div>
	</cfif>
	</div>
</cfoutput>
<script>
	$(function() {
		$('.open-news-popup').magnificPopup({
			type: 'inline',
			preloader: false,
			alignTop: true,
			midClick: true // Allow opening popup on middle mouse click. Always set it to true if you don't provide alternative source in href.
		});
	})
</script>