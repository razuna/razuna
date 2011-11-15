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
  <cfparam name="debuggingMessage" type="string" default="" />
  <cftry>
    <cfset debugSettings = Application.debugging.getDebugSettings() />
    <cfcatch type="bluedragon.adminapi.debugging">
      <cfset debuggingMessage = CFCATCH.Message />
      <cfset debuggingMessageType = "error" />
    </cfcatch>
  </cftry>
</cfsilent>
<cfsavecontent variable="request.content">
  <cfoutput>
    <script type="text/javascript">
      function validateDebugOutputForm(f) {
        if (f.highlight.value != parseInt(f.highlight.value)) {
          alert("The value of Highlight Execution Times is not numeric");
          return false;
        } else {
          return true;
        }
      }
    </script>
    
    <h2>Debug Settings</h2>

    <cfif StructKeyExists(session, "message") && session.message.text != "">
      <div class="alert-message #session.message.type# fade in" data-alert="alert">
	<a class="close" href="##">x</a>
	<p>#session.message.text#</p>
      </div>
    </cfif>

    <cfif debuggingMessage != "">
      <div class="alert-message #debuggingMessageType# fade in" data-alert="alert">
	<a class="close" href="##">x</a>
	<p>#debuggingMessage#</p>
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
    
    <form name="debugSettingsForm" action="_controller.cfm?action=processDebugSettingsForm" method="post">
      <table>
	<tr bgcolor="##dedede">
	  <th colspan="2"><h5>Debug &amp; Error Settings</h5></th>
	</tr>
	<tr>
	  <td bgcolor="##f0f0f0" style="width:200px;">Extended Error Reporting</td>
	  <td>
	    <input type="checkbox" name="debug" id="debug" value="true"
		   <cfif debugSettings.system.debug> checked="true"</cfif> tabindex="1" />
	  </td>
	</tr>
	<tr>
	  <td bgcolor="##f0f0f0">Runtime Error Logging</td>
	  <td>
	    <div class="inline-inputs">
	      <input type="checkbox" name="runtimelogging" id="runtimelogging" value="true"
		     <cfif debugSettings.system.runtimelogging> checked="true"</cfif> tabindex="2" />&nbsp;
	      <span>Store a maximum of</span>
	      <input type="text" name="runtimeloggingmax" id="runtimeloggingmax" class="span2" maxlength="5" 
		     value="#debugSettings.system.runtimeloggingmax#" tabindex="3" />
	      <span>RTE logs</span>
	    </div>
	  </td>
	</tr>
	<tr>
	  <td bgcolor="##f0f0f0" align="right">Enable Debug Output</td>
	  <td>
	    <input type="checkbox" name="enabled" id="enabled" value="true"
		   <cfif debugSettings.debugoutput.enabled> checked="true"</cfif> tabindex="4" />
	  </td>
	</tr>
	<tr>
	  <td bgcolor="##f0f0f0">Assertions</td>
	  <td>
	    <input type="checkbox" name="assert" id="assert" value="true"
		   <cfif debugSettings.system.assert> checked="true"</cfif> tabindex="5" />
	  </td>
	</tr>
	<tr>
	  <td bgcolor="##f0f0f0">Slow Query Log</td>
	  <td bgcolor="##ffffff">
	    <div class="inline-inputs">
	      <input type="checkbox" name="enableslowquerylog" id="enableslowquerylog" value="true" 
		     <cfif debugSettings.slowquerytime != -1> checked="true"</cfif> tabindex="6" />&nbsp;&nbsp;
	      <span>Log queries running more than</span>&nbsp;
	      <input type="text" name="slowquerytime" id="slowquerytime" class="span2" maxlength="4" 
		     value="<cfif debugSettings.slowquerytime != -1>#debugSettings.slowquerytime#</cfif>" tabindex="7" />&nbsp;seconds&nbsp;
	      <img src="../images/arrow_refresh_small.png" height="16" width="16" 
		   alt="Requires Server Restart" title="Requires Server Restart" />
	    </div>
	  </td>
	</tr>
	<tr bgcolor="##dedede">
	  <td>&nbsp;</td>
	  <td><input type="submit" class="btn primary" name="submit" value="Submit" tabindex="8" /></td>
	</tr>
      </table>
    </form>
    
    <br />

    <form name="debugOutputForm" action="_controller.cfm?action=processDebugOutputForm" method="post" 
	  onsubmit="javascript:return validateDebugOutputForm(this);">
      <table>
	<tr bgcolor="##dedede">
	  <th colspan="2"><h5>Debug Output</h5></th>
	</tr>
	<tr>
	  <td bgcolor="##f0f0f0" style="width:200px;">Page Execution Times</td>
	  <td>
	    <div class="inline-inputs">
	      <input type="checkbox" name="executiontimes" id="executiontimes" value="true"
		     <cfif debugSettings.debugoutput.executiontimes.show> checked="true"</cfif> tabindex="8" />&nbsp;&nbsp;
	      <span>Highlight times greater than</span>&nbsp;
	      <input type="text" name="highlight" id="highlight" class="span2" maxlength="4" 
		     value="#debugSettings.debugoutput.executiontimes.highlight#" tabindex="9" />&nbsp;ms
	    </div>
	  </td>
	</tr>
	<tr>
	  <td bgcolor="##f0f0f0">Database Activity</td>
	  <td>
	    <input type="checkbox" name="database" id="database" value="true"
		   <cfif debugSettings.debugoutput.database.show> checked="true"</cfif> tabindex="10" />
	  </td>
	</tr>
	<tr>
	  <td bgcolor="##f0f0f0">Exceptions</td>
	  <td>
	    <input type="checkbox" name="exceptions" id="exceptions" value="true"
		   <cfif debugSettings.debugoutput.exceptions.show> checked="true"</cfif> tabindex="11" />
	  </td>
	</tr>
	<tr>
	  <td bgcolor="##f0f0f0">Trace Points</td>
	  <td>
	    <input type="checkbox" name="tracepoints" id="tracepoints" value="true"
		   <cfif debugSettings.debugoutput.tracepoints.show> checked="true"</cfif> tabindex="12" />
	  </td>
	</tr>
	<tr>
	  <td bgcolor="##f0f0f0">Timer Information</td>
	  <td>
	    <input type="checkbox" name="timer" id="timer" value="true"
		   <cfif debugSettings.debugoutput.timer.show> checked="true"</cfif> tabindex="13" />
	  </td>
	</tr>
	<tr>
	  <td bgcolor="##f0f0f0">Variables</td>
	  <td>
	    <input type="checkbox" name="variables" id="variables" value="true"
		   <cfif debugSettings.debugoutput.variables.show> checked="true"</cfif> tabindex="14" />
	  </td>
	</tr>
	<tr bgcolor="##dedede">
	  <td>&nbsp;</td>
	  <td><input type="submit" class="btn primary" name="submit" value="Submit" tabindex="15" /></td>
	</tr>
      </table>
    </form>
    
    <br />
    
    <form name="debugVariablesForm" action="_controller.cfm?action=processDebugVariablesForm" method="post">
      <table>
	<tr bgcolor="##dedede">
	  <th colspan="2"><h5>Debug and Error Variables</h5></th>
	</tr>
	<tr>
	  <td bgcolor="##f0f0f0" valign="top">Variable Scopes</td>
	  <td bgcolor="##ffffff">
	    <div class="row">
	      <div class="inline-inputs">
		<div class="span3">
		  <input type="checkbox" name="local" id="local" value="true"
			 <cfif debugSettings.debugoutput.variables.local> checked="true"</cfif> tabindex="16" />
		  <span>Local</span>
		</div>
		<div class="span3">
		  <input type="checkbox" name="url" id="url" value="true"
			 <cfif debugSettings.debugoutput.variables.url> checked="true"</cfif> tabindex="17" />
		  <span>URL</span>
		</div>
		<div class="span3">
		  <input type="checkbox" name="session" id="session" value="true"
			 <cfif debugSettings.debugoutput.variables.session> checked="true"</cfif> tabindex="18" />
		  <span>Session</span>
		</div>	      
	      </div>
	    </div>
	    <div class="row">
	      <div class="inline-inputs">
		<div class="span3">
		  <input type="checkbox" name="variables" id="variablesScope" value="true"
			 <cfif debugSettings.debugoutput.variables.variables> checked="true"</cfif> tabindex="19" />
		  <span>Variables</span>
		</div>
		<div class="span3">
		  <input type="checkbox" name="form" id="form" value="true"
			 <cfif debugSettings.debugoutput.variables.form> checked="true"</cfif> tabindex="20" />
		  <span>Form</span>
		</div>
		<div class="span3">
		  <input type="checkbox" name="client" id="client" value="true"
			 <cfif debugSettings.debugoutput.variables.client> checked="true"</cfif> tabindex="21" />
		  <span>Client</span>
		</div>
	      </div>
	    </div>
	    <div class="row">
	      <div class="inline-inputs">
		<div class="span3">
		  <input type="checkbox" name="request" id="request" value="true"
			 <cfif debugSettings.debugoutput.variables.request> checked="true"</cfif> tabindex="22" />
		  <span>Request</span>
		</div>
		<div class="span3">
		  <input type="checkbox" name="cookie" id="cookie" value="true"
			 <cfif debugSettings.debugoutput.variables.cookie> checked="true"</cfif> tabindex="23" />
		  <span>Cookie</span>
		</div>
		<div class="span3">
		  <input type="checkbox" name="application" id="application" value="true"
			 <cfif debugSettings.debugoutput.variables.application> checked="true"</cfif> tabindex="24" />
		  <span>Application</span>
		</div>
	      </div>
	    </div>
	    <div class="row">
	      <div class="inline-inputs">
		<div class="span3">
		  <input type="checkbox" name="cgi" id="cgi" value="true"
			 <cfif debugSettings.debugoutput.variables.cgi> checked="true"</cfif> tabindex="25" />
		  <span>CGI</span>
		</div>
		<div class="span3">
		  <input type="checkbox" name="cffile" id="cffile" value="true"
			 <cfif debugSettings.debugoutput.variables.cffile> checked="true"</cfif> tabindex="26" />
		  <span>CFFILE</span>
		</div>
		<div class="span3">
		  <input type="checkbox" name="server" id="server" value="true"
			 <cfif debugSettings.debugoutput.variables.server> checked="true"</cfif> tabindex="27" />
		  <span>Server</span>
		</div>
	      </div>
	    </div>
	  </td>
	</tr>
	<tr bgcolor="##dedede">
	  <td>&nbsp;</td>
	  <td><input class="btn primary" type="submit" name="submit" value="Submit" tabindex="28" /></td>
	</tr>
      </table>
    </form>
  </cfoutput>
</cfsavecontent>
