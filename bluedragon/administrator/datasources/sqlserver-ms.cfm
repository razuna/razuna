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
  <cfparam name="url.dsn" type="string" default="" />
  <cfparam name="url.action" type="string" default="create" />
  
  <cfif !StructKeyExists(session, "datasource")>
    <cfset session.message.text = "An error occurred while processing the datasource action." />
    <cfset session.message.type = "error" />
    <cflocation url="index.cfm" addtoken="false" />
  </cfif>
  
  <cfset dsinfo = session.datasource[1] />
  
  <!--- added connectstring so need to set to a default in case it doesn't exist in the xml --->
  <cfif !StructKeyExists(dsinfo, "connectstring")>
    <cfset dsinfo.connectstring = "" />
  </cfif>
</cfsilent>
<cfsavecontent variable="request.content">
  <cfoutput>
    <script type="text/javascript">
      function showHideAdvSettings() {
        var advSettings = document.getElementById('advancedSettings');
        var advSettingsButton = document.getElementById('advSettingsButton');
      
        if (advSettings.style.visibility == 'visible') {
          advSettingsButton.value = 'Show Advanced Settings';
          advSettings.style.display= 'none';
          advSettings.style.visibility = 'hidden';
        } else {
          advSettingsButton.value = 'Hide Advanced Settings';
          advSettings.style.display = 'inline';
          advSettings.style.visibility = 'visible';
        }
      }
      
      function validate(f) {
        var ok = true;
      
        if (f.name.value.length == 0) {
          alert("Please enter the datasource name");
          ok = false;
        } else if (f.databasename.value.length == 0) {
          alert("Please enter the database name");
          ok = false;
        } else if (f.server.value.length == 0) {
          alert("Please enter the database server");
          ok = false;
        } else if (f.port.value.length == 0) {
          alert("Please enter the database server port");
          ok = false;
        }
      
        return ok;
      }
    </script>
    <h3>Configure Datasource - SQL Server (Microsoft)</h3>

    <cfif StructKeyExists(session, "message") && session.message.text != "">
      <div class="alert-message #session.message.type# fade in" data-alert="alert">
	<a class="close" href="##">x</a>
	<p>#session.message.text#</p>
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
    
    <!--- TODO: need explanatory tooltips/mouseovers on all these settings, esp. 'per request connections' which 
	from my understanding is the opposite of Adobe CF's description 'maintain connections across client requests'--->
    <form name="datasourceForm" action="_controller.cfm?action=processDatasourceForm" method="post" 
	  onsubmit="return validate(this);">
      <table>
	<tr bgcolor="##dedede">
	  <th colspan="2"><h5>Datasource Details</h5></th>
	</tr>
	<tr>
	  <td bgcolor="##f0f0f0">OpenBD Datasource Name</td>
	  <td>
	    <input name="name" id="name" type="text" class="span6" maxlength="50" value="#dsinfo.name#" tabindex="1" />
	  </td>
	</tr>
	<tr>
	  <td bgcolor="##f0f0f0">Database Name</td>
	  <td>
	    <input name="databasename" id="databasename" type="text" class="span6" maxlength="250" 
		   value="#dsinfo.databasename#" tabindex="2" />
	  </td>
	</tr>
	<tr>
	  <td bgcolor="##f0f0f0">Database Server</td>
	  <td>
	    <input name="server" id="server" type="text" class="span6" maxlength="250" value="#dsinfo.server#" tabindex="3" />
	  </td>
	</tr>
	<tr>
	  <td bgcolor="##f0f0f0">Server Port</td>
	  <td>
	    <input name="port" id="port" type="text" class="span2" maxlength="5" value="#dsinfo.port#" tabindex="4" />
	  </td>
	</tr>
	<tr>
	  <td bgcolor="##f0f0f0">User Name</td>
	  <td>
	    <input name="username" id="username" type="text" class="span6" maxlength="50" value="#dsinfo.username#" tabindex="5" />
	  </td>
	</tr>
	<tr>
	  <td bgcolor="##f0f0f0">Password</td>
	  <td>
	    <input name="password" id="password" type="password" class="span6" maxlength="128" value="#dsinfo.password#" tabindex="6" />
	  </td>
	</tr>
	<tr>
	  <td valign="top" bgcolor="##f0f0f0">Description</td>
	  <td valign="top">
	    <textarea name="description" id="description" rows="4" class="span6" tabindex="7"><cfif StructKeyExists(dsinfo, "description")>#dsinfo.description#</cfif></textarea>
	  </td>
	</tr>
	<tr bgcolor="##dedede">
	  <td>
	    <input type="button" class="btn default" id="advSettingsButton" name="showAdvSettings" value="Show Advanced Settings" 
		   onclick="javascript:showHideAdvSettings();" tabindex="8" />
	  </td>
	  <td align="right">
	    <input type="submit" class="btn primary" name="submit" value="Submit" tabindex="9" />
	    <input type="button" class="btn default" name="cancel" value="Cancel" 
		   onclick="javascript:location.replace('index.cfm');" tabindex="10" />
	  </td>
	</tr>
      </table>
      <div id="advancedSettings" style="display:none;visibility:hidden;">
	<br />
	<table>
	  <tr bgcolor="##dedede">
	    <th colspan="2">Advanced Settings</th>
	  </tr>
	  <tr>
	    <td valign="top" bgcolor="##f0f0f0">Connection String</td>
	    <td valign="top">
	      <textarea name="connectstring" id="connectstring" rows="4" class="span6" tabindex="11">#dsinfo.connectstring#</textarea>
	    </td>
	  </tr>
	  <tr>
	    <td valign="top" bgcolor="##f0f0f0">Initialization String</td>
	    <td valign="top">
	      <textarea name="initstring" id="initstring" rows="4" class="span6" tabindex="12">#dsinfo.initstring#</textarea>
	    </td>
	  </tr>
	  <tr>
	    <td valign="top" bgcolor="##f0f0f0">SQL Operations</td>
	    <td valign="top">
	      <div class="inline-inputs">
		<input type="checkbox" name="sqlselect" id="sqlselect" value="true"<cfif dsinfo.sqlselect> checked="true"</cfif> tabindex="13" />
		<span>SELECT</span>
		<input type="checkbox" name="sqlinsert" id="sqlinsert" value="true"<cfif dsinfo.sqlinsert> checked="true"</cfif> tabindex="14" />
		<span>INSERT</span>
		<input type="checkbox" name="sqlupdate" id="sqlupdate" value="true"<cfif dsinfo.sqlupdate> checked="true"</cfif> tabindex="15" />
		<span>UPDATE</span>
		<input type="checkbox" name="sqldelete" id="sqldelete" value="true"<cfif dsinfo.sqldelete> checked="true"</cfif> tabindex="16" />
		<span>DELETE</span>
		<input type="checkbox" name="sqlstoredprocedures" id="sqlstoredprocedures" value="true"<cfif dsinfo.sqlstoredprocedures> checked="true"</cfif> tabindex="17" />
		<span>Stored Procedures</span>
	      </div>
	    </td>
	  </tr>
	  <tr>
	    <td bgcolor="##f0f0f0">Per-Request Connections</td>
	    <td>
	      <input type="checkbox" name="perrequestconnections" id="perrequestconnections" value="true"
		     <cfif dsinfo.perrequestconnections> checked="true"</cfif> tabindex="18" />
	    </td>
	  </tr>
	  <tr>
	    <td bgcolor="##f0f0f0">Maximum Connections</td>
	    <td>
	      <input type="text" name="maxconnections" id="maxconnections" class="span2" maxlength="4" 
		     value="#dsinfo.maxconnections#" tabindex="19" />
	    </td>
	  </tr>
	  <tr>
	    <td bgcolor="##f0f0f0">Connection Timeout</td>
	    <td>
	      <input type="text" name="connectiontimeout" id="connectiontimeout" class="span2" maxlength="10" 
		     value="#dsinfo.connectiontimeout#" tabindex="20" />
	    </td>
	  </tr>
	  <tr>
	    <td bgcolor="##f0f0f0">Login Timeout</td>
	    <td>
	      <input type="text" name="logintimeout" id="logintimeout" class="span2" maxlength="4" 
		     value="#dsinfo.logintimeout#" tabindex="21" />
	    </td>
	  </tr>
	  <tr>
	    <td bgcolor="##f0f0f0">Connection Retries</td>
	    <td>
	      <input type="text" name="connectionretries" id="connectionretries" class="span2" maxlength="4" 
		     value="#dsinfo.connectionretries#" tabindex="22" />
	    </td>
	  </tr>
	</table>
      </div>
      <input type="hidden" name="drivername" value="#dsinfo.drivername#" />
      <input type="hidden" name="datasourceAction" value="#url.action#" />
      <input type="hidden" name="existingDatasourceName" value="#dsinfo.name#" />
    </form>
  </cfoutput>
  <cfset StructDelete(session, "datasource", false) />
</cfsavecontent>
