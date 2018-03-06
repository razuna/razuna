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
	<table width="700" border="0" cellspacing="0" cellpadding="0" class="grid">
	<!--- URL of Website --->
	<tr>
	<th colspan="2" class="textbold">#myFusebox.getApplicationData().defaults.trans("url_website")#</th>
	</tr>
	<tr>
	<td nowrap>URL</td>
	<td><input type="text" name="url_website" size="60" value="#prefs.set2_url_website#"></td>
	</tr>
	<tr>
	<td></td>
	<td>#myFusebox.getApplicationData().defaults.trans("http_desc")#</td>
	</tr>
	<!--- WebSite Titels --->
	<tr>
	<th colspan="2" class="textbold">#myFusebox.getApplicationData().defaults.trans("header_title_web")#</th>
	</tr>
	<cfloop from="1" to="#myFusebox.getApplicationData().defaults.howmanylang("#application.razuna.datasource#")#" index="langindex">
	<tr>
	<td nowrap>#myFusebox.getApplicationData().defaults.trans("title_in")# #myFusebox.getApplicationData().defaults.thislang("SET_LANG_#langindex#")#</td>
	<td><input type="text" name="set_title_website_#langindex#" size="60" value="#myFusebox.getApplicationData().settings.thissetting("set_title_website_#langindex#", attributes)#"></td>
	</tr>
	</cfloop>
	<!--- Payment Options --->
	<tr>
	<th colspan="2">#myFusebox.getApplicationData().defaults.trans("payment_options")#</th>
	</tr>
	<tr>
	<td colspan="2">#myFusebox.getApplicationData().defaults.trans("payment_options_desc2")#</td>
	</tr>
	<tr>
	<td>#myFusebox.getApplicationData().defaults.trans("payment_cc")#</td>
	<td><input type="radio" name="set2_payment_cc" value="T"<cfif #prefs.set2_payment_cc# EQ "T"> checked</cfif> /> #myFusebox.getApplicationData().defaults.trans("yes")# <input type="radio" name="set2_payment_cc" value="F"<cfif #prefs.set2_payment_cc# EQ "F"> checked</cfif> /> #myFusebox.getApplicationData().defaults.trans("no")#</td>
	</tr>
	<tr>
	<td valign="top">#myFusebox.getApplicationData().defaults.trans("payment_cc_cards")#</td>
	<td><textarea name="set2_payment_cc_cards" rows="3" cols="80" class="text">#prefs.set2_payment_cc_cards#</textarea><br />#myFusebox.getApplicationData().defaults.trans("separate_values_desc")#</td>
	</tr>
	<tr>
	<td>#myFusebox.getApplicationData().defaults.trans("payment_bill")#</td>
	<td><input type="radio" name="set2_payment_bill" value="T"<cfif #prefs.set2_payment_bill# EQ "T"> checked</cfif> /> #myFusebox.getApplicationData().defaults.trans("yes")# <input type="radio" name="set2_payment_bill" value="F"<cfif #prefs.set2_payment_bill# EQ "F"> checked</cfif> /> #myFusebox.getApplicationData().defaults.trans("no")#</td>
	</tr>
	<tr>
	<td>#myFusebox.getApplicationData().defaults.trans("payment_pod")#</td>
	<td><input type="radio" name="set2_payment_pod" value="T"<cfif #prefs.set2_payment_pod# EQ "T"> checked</cfif> /> #myFusebox.getApplicationData().defaults.trans("yes")# <input type="radio" name="set2_payment_pod" value="F"<cfif #prefs.set2_payment_pod# EQ "F"> checked</cfif> /> #myFusebox.getApplicationData().defaults.trans("no")#</td>
	</tr>
	<tr>
	<td>#myFusebox.getApplicationData().defaults.trans("payment_pre")#</td>
	<td><input type="radio" name="set2_payment_pre" value="T"<cfif #prefs.set2_payment_pre# EQ "T"> checked</cfif> /> #myFusebox.getApplicationData().defaults.trans("yes")# <input type="radio" name="set2_payment_pre" value="F"<cfif #prefs.set2_payment_pre# EQ "F"> checked</cfif> /> #myFusebox.getApplicationData().defaults.trans("no")#</td>
	</tr>
	<tr>
	<td>PayPal</td>
	<td><input type="radio" name="set2_payment_paypal" value="T"<cfif #prefs.set2_payment_paypal# EQ "T"> checked</cfif> /> #myFusebox.getApplicationData().defaults.trans("yes")# <input type="radio" name="set2_payment_paypal" value="F"<cfif #prefs.set2_payment_paypal# EQ "F"> checked</cfif> /> #myFusebox.getApplicationData().defaults.trans("no")#</td>
	</tr>
	</table>
</cfoutput>