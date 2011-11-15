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
  <cfparam name="variableMessage" type="string" default="" />
  
  <cftry>
    <cfset variableSettings = Application.variableSettings.getVariableSettings() />
    
    <cftry>
      <cfset datasources = Application.datasource.getDatasources() />
      <cfcatch type="bluedragon.adminapi.datasource">
	<cfset datasources = [] />
      </cfcatch>
    </cftry>
    
    <cfset chartSettings = Application.chart.getChartSettings() />
    
    <!--- need to extract application and session timeout values from the createTimeSpan value in the config settings --->
    <cfset startPos = Find("(", variableSettings.applicationtimeout) + 1 />
    <cfset endPos = Find(")", variableSettings.applicationtimeout) />
    <cfset applicationTimeout = Mid(variableSettings.applicationtimeout, startPos, endPos - startPos) />
    
    <cfset startPos = Find("(", variableSettings.sessiontimeout) + 1 />
    <cfset endPos = Find(")", variableSettings.sessiontimeout) />
    <cfset sessionTimeout = Mid(variableSettings.sessiontimeout, startPos, endPos - startPos) />
    
    <cfcatch type="bluedragon.adminapi.variableSettings">
      <cfset variableMessage = CFCATCH.Message />
      <cfset variableMessageType = "error" />
    </cfcatch>
  </cftry>
</cfsilent>
<cfsavecontent variable="request.content">
  <cfoutput>
    <script type="text/javascript">
      function validate(f) {
        if (f.appTimeoutDays.value != parseInt(f.appTimeoutDays.value)) {
          alert("The value for application timeout days is not numeric.");
          return false;
        } else if (f.appTimeoutHours.value != parseInt(f.appTimeoutHours.value)) {
          alert("The value for application timeout hours is not numeric.");
          return false;
        } else if (f.appTimeoutMinutes.value != parseInt(f.appTimeoutMinutes.value)) {
          alert("The value for application timeout minutes is not numeric.");
          return false;
        } else if (f.appTimeoutSeconds.value != parseInt(f.appTimeoutSeconds.value)) {
          alert("The value for application timeout seconds is not numeric.");
          return false;
        } else if (f.sessionTimeoutDays.value != parseInt(f.sessionTimeoutDays.value)) {
          alert("The value for session timeout days is not numeric.");
          return false;
        } else if (f.sessionTimeoutHours.value != parseInt(f.sessionTimeoutHours.value)) {
          alert("The value for session timeout hours is not numeric.");
          return false;
        } else if (f.sessionTimeoutMinutes.value != parseInt(f.sessionTimeoutMinutes.value)) {
          alert("The value for session timeout minutes is not numeric.");
          return false;
        } else if (f.sessionTimeoutSeconds.value != parseInt(f.sessionTimeoutSeconds.value)) {
          alert("The value for session timeout seconds is not numeric.");
          return false;
        } else if (f.clientexpiry.value != parseInt(f.clientexpiry.value)) {
          alert("The value for client variable expiration days is not numeric.");
          return false;
        } else if (f.cfchartcachesize.value != parseInt(f.cfchartcachesize.value)) {
          alert("The value for CFCHART cache size is not numeric.");
          return false;
        } else {
          return true;
        }
      }
    </script>
    
    <div class="row">
      <div class="pull-left">
	<h2>Variable Settings</h2>
      </div>
      <div class="pull-right">
	<button data-controls-modal="moreInfo" data-backdrop="true" data-keyboard="true" class="btn primary">More Info</button>
      </div>
    </div>

    <cfif StructKeyExists(session, "message") && session.message.text != "">
      <div class="alert-message #session.message.type# fade in" data-alert="alert">
	<a class="close" href="##">x</a>
	<p>#session.message.text#</p>
      </div>
    </cfif>
    
    <cfif variableMessage !="">
      <div class="alert-message #variableMessageType# fade in" data-alert="alert">
	<a class="close" href="##">x</a>
	<p>#variableMessage#</p>
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
    
    <form name="variableForm" action="_controller.cfm?action=processVariableForm" method="post" 
	  onsubmit="javascript:return validate(this);">
      <table>
	<tr bgcolor="##dedede">
	  <td colspan="2"><h5>Update Variable Settings</h5></td>
	</tr>
	<tr>
	  <td bgcolor="##f0f0f0">Use J2EE Sessions</td>
	  <td bgcolor="##ffffff">
	    <div class="inline-inputs">
	      <input type="radio" name="j2eesession" id="j2eesessionTrue" value="true"<cfif variableSettings.j2eesession> checked="true"</cfif> tabindex="1" />
	      <span>Yes</span>
	      <input type="radio" name="j2eesession" id="j2eesessionFalse" value="false"<cfif !variableSettings.j2eesession> checked="true"</cfif> tabindex="2" />
	      <span>No</span>
	    </div>
	  </td>
	</tr>
	<tr>
	  <td bgcolor="##f0f0f0">Default Application Timeout</td>
	  <td bgcolor="##ffffff">
	    <div class="inline-inputs">
	      <input type="text" name="appTimeoutDays" id="appTimeoutDays" class="span2" maxlength="2" 
		     value="#ListFirst(applicationTimeout)#" tabindex="3" />
	      <span>days</span>
	      <input type="text" name="appTimeoutHours" id="appTimeoutHours" class="span2" maxlength="2" 
		     value="#ListGetAt(applicationTimeout, 2)#" tabindex="4" />
	      <span>hours</span>
	      <input type="text" name="appTimeoutMinutes" id="appTimeoutMinutes" class="span2" maxlength="2" 
		     value="#ListGetAt(applicationTimeout, 3)#" tabindex="5" />
	      <span>mins</span>
	      <input type="text" name="appTimeoutSeconds" id="appTimeoutSeconds" class="span2" maxlength="2" 
		     value="#ListLast(applicationTimeout)#" tabindex="6" />
	      <span>secs</span>
	    </div>
	  </td>
	</tr>
	<tr>
	  <td bgcolor="##f0f0f0">Default Session Timeout</td>
	  <td bgcolor="##ffffff">
	    <div class="inline-inputs">
	      <input type="text" name="sessionTimeoutDays" id="sessionTimeoutDays" class="span2" maxlength="2" 
		     value="#listFirst(sessionTimeout)#" tabindex="7" />
	      <span>days</span>
	      <input type="text" name="sessionTimeoutHours" id="sessionTimeoutHours" class="span2" maxlength="2" 
		     value="#listGetAt(sessionTimeout, 2)#" tabindex="8" />
	      <span>hours</span>
	      <input type="text" name="sessionTimeoutMinutes" id="sessionTimeoutMinutes" class="span2" maxlength="2" 
		     value="#listGetAt(sessionTimeout, 3)#" tabindex="9" />
	      <span>mins</span>
	      <input type="text" name="sessionTimeoutSeconds" id="sessionTimeoutSeconds" class="span2" maxlength="2" 
		     value="#listLast(sessionTimeout)#" tabindex="10" />
	      <span>secs</span>
	    </div>
	  </td>
	</tr>
	<tr>
	  <td bgcolor="##f0f0f0">Client Variable Storage</td>
	  <td bgcolor="##ffffff">
	    <div class="inline-inputs">
	      <select name="clientstorage" id="clientstorage" tabindex="11">
		<option value="cookie"<cfif variableSettings.clientstorage is "cookie"> selected="true"</cfif>>Cookies</option>
		<cfif ArrayLen(datasources) gt 0>
		  <cfloop index="i" from="1" to="#ArrayLen(datasources)#">
		    <option value="#datasources[i].name#"<cfif variableSettings.clientstorage == datasources[i].name> selected="true"</cfif>>#datasources[i].name#</option>
		  </cfloop>
		</cfif>
	      </select><br />
	      <input type="checkbox" name="clientpurgeenabled" id="clientpurgeenabled" value="true"
		     <cfif variableSettings.clientpurgeenabled> checked="true"</cfif> tabindex="12" />
	      <span>Enable purging of data that is</span>
	      <input type="text" name="clientexpiry" id="clientexpiry" class="span2" maxlength="3" 
		     value="#variableSettings.clientexpiry#" tabindex="13" />
	      <span>days old</span><br />
	      <input type="checkbox" name="clientGlobalUpdatesDisabled" id="clientGlobalUpdatesDisabled" value="true" <cfif StructKeyExists(variableSettings, "clientGlobalUpdatesDisabled") && variableSettings.clientGlobalUpdatesDisabled> checked="true"</cfif> tabindex="14" />
	      <span>Disable Global Client Variable Updates</span><br />
	      <input type="checkbox" name="cf5clientdata" id="cf5clientdata" value="true"<cfif variableSettings.cf5clientdata> checked="true"</cfif> tabindex="15" />
	      <span>ColdFusion 5-compatible client data <img src="../images/arrow_refresh_small.png" width="16" height="16" alt="Requires Server Restart" title="Requires Server Restart" /></span>
	    </div>
	  </td>
	</tr>
	<tr>
	  <td bgcolor="##f0f0f0">CFCHART Storage</td>
	  <td bgcolor="##ffffff">
	    <select name="cfchartstorage" id="cfchartstorage" tabindex="16">
	      <option value="file"<cfif chartSettings.storage == "file"> selected="true"</cfif>>File</option>
	      <option value="session"<cfif chartSettings.storage == "session"> selected="true"</cfif>>Session</option>
	      <cfif ArrayLen(datasources) gt 0>
		<cfloop index="i" from="1" to="#arrayLen(datasources)#">
		  <option value="#datasources[i].name#"<cfif chartSettings.storage is datasources[i].name> selected="true"</cfif>>
		    <cfif StructKeyExists(datasources[i], "displayname")>#datasources[i].displayname#<cfelse>#datasources[i].name#</cfif>
		  </option>
		</cfloop>
	      </cfif>
	    </select>
	  </td>
	</tr>
	<tr>
	  <td bgcolor="##f0f0f0">CFCHART Cache Size</td>
	  <td bgcolor="##ffffff">
	    <div class="inline-inputs">
	      <input type="text" name="cfchartcachesize" id="cfchartcachesize" class="span2" maxlength="4" 
		     value="#chartSettings.cachesize#" tabindex="17" /> charts
	    </div>
	  </td>
	</tr>
	<tr bgcolor="##dedede">
	  <td>&nbsp;</td>
	  <td><input class="btn primary" type="submit" name="submit" value="Submit" tabindex="18" /></td>
	</tr>
      </table>
    </form>

    <div id="moreInfo" class="modal hide fade">
      <div class="modal-header">
	<a href="##" class="close">&times;</a>
	<h3>Information Concerning Variable Settings</h3>
      </div>
      <div class="modal-body">
	<ul>
	  <li>Changing the "ColdFusion 5-compatible client data" setting requires Open BlueDragon to be restarted.</li>
	</ul>
      </div>
    </div>
  </cfoutput>
</cfsavecontent>
