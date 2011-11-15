<!---
    Copyright (C) 2008 - Open BlueDragon Project - http://www.openbluedragon.org
    
    Contributing Developers:
    Matt Woodward - matt@mattwoodward.com

    This file is part of the Open BlueDragon Administrator.

    The Open BlueDragon Administrator is free software: you can redistribute 
    it and/or modify it under the terms of the GNU General Public License 
    as published by the Free Software Foundation, either version 3 of the 
    License, or (at your option) any later version.

    The Open BlueDragon Administrator is distributed in the hope that it will 
    be useful, but WITHOUT ANY WARRANTY; without even the implied warranty 
    of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU 
    General Public License for more details.
    
    You should have received a copy of the GNU General Public License 
    along with the Open BlueDragon Administrator.  If not, see 
    <http://www.gnu.org/licenses/>.
--->
<cfsilent>
  <cfparam name="ipAddressMessage" type="string" default="" />
  
  <cftry>
    <cfset ipAddresses = Application.debugging.getDebugIPAddresses() />
    <cfcatch type="bluedragon.adminapi.debugging">
      <cfset debuggingMessage = CFCATCH.Message />
      <cfset debuggingMessageType = "error" />
    </cfcatch>
  </cftry>
</cfsilent>
<cfsavecontent variable="request.content">
  <cfoutput>
    <script type="text/javascript">
      function validateAddIPAddressForm(f) {
        var ipCheck = /^((25[0-5]|2[0-4][0-9]|1[0-9]{2}|[0-9]{1,2})\.){3}(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[0-9]{1,2})$/;
        if (!ipCheck.test(f.ipaddress.value)) {
          alert("Please enter a valid IP address.");
          return false;
        } else {
          return true;
        }
      }
      
      function validateEditIPAddressForm(f) {
        if (f.ipaddresses.value.length == 0) {
          alert("Please select IP addresses to remove.");
          return false;
        } else {
          return true;
        }
      }
    </script>
    
    <h2>Debug IP Addresses</h2>

    <cfif StructKeyExists(session, "message") && session.message.text != "">
      <div class="alert-message #session.message.type# fade in" data-alert="alert">
	<a class="close" href="##">x</a>
	<p>#session.message.text#</p>
      </div>
    </cfif>

    <cfif ipAddressMessage != "">
      <div class="alert-message #ipAddressMessageType# fade in" data-alert="alert">
	<a class="close" href="##">x</a>
	<p>#ipAddressMessage#</p>
      </div>
    </cfif>

    <cfif StructKeyExists(session, "errorFields") && IsArray(session.errorFields) && ArrayLen(session.errorFields) gt 0>
      <div class="alert-message block-message error fade in" data-alert="alert">
	<a class="close" href="##">x</a>
	<h5>The following errors occurred:</h5>
	<ul>
	  <cfloop index="i" from="1" to="#ArrayLen(session.errorFields)#">
	    <li>#session.errorFields[i][2]#</li>
	  </cfloop>
	</ul>
      </div>
    </cfif>
    
    <form name="addIPAddressForm" action="_controller.cfm?action=addIPAddress" method="post" 
	  onsubmit="javascript:return validateAddIPAddressForm(this);">
      <table>
	<tr bgcolor="##dedede">
	  <th colspan="2"><h5>Add IP Address</h5></td>
	</tr>
	<tr>
	  <td bgcolor="##f0f0f0" style="width:200px;">New IP Address</td>
	  <td>
	    <input type="text" name="ipaddress" id="ipaddress" class="span6" maxlength="15" tabindex="1" />
	  </td>
	</tr>
	<tr bgcolor="##dedede">
	  <td>&nbsp;</td>
	  <td>
	    <input type="button" class="btn default" name="addLocalIP" value="Add Local" tabindex="2" 
		   onclick="javascript:location.replace('_controller.cfm?action=addLocalIP');" />
	    <input type="submit" class="btn primary" name="submit" value="Submit" tabindex="3" />
	  </td>
	</tr>
      </table>
    </form>
    
    <br />

    <form name="editIPAddressForm" action="_controller.cfm?action=removeIPAddresses" method="post" 
	  onsubmit="javascript:return validateEditIPAddressForm(this);">
      <table>
	<tr bgcolor="##dedede">
	  <th colspan="2"><h5>Edit IP Addresses</h5></th>
	</tr>
	<tr>
	  <td bgcolor="##f0f0f0" align="right" valign="top" style="width:200px;">Configured IP Addresses</td>
	  <td>
	    <select name="ipaddresses" id="ipaddresses" size="5" multiple="true" class="span6" tabindex="4">
	      <cfif ArrayLen(ipAddresses) gt 0>
		<cfloop index="i" from="1" to="#ArrayLen(ipAddresses)#">
		  <option value="#ipAddresses[i]#">#ipAddresses[i]#</option>
		</cfloop>
	      </cfif>
	    </select>
	  </td>
	</tr>
	<tr bgcolor="##dedede">
	  <td>&nbsp;</td>
	  <td><input type="submit" class="btn primary" name="submit" value="Remove Selected IPs" tabindex="5" /></td>
	</tr>
      </table>
    </form>
  </cfoutput>
</cfsavecontent>
