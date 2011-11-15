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
  <cfset serverSettings = Application.serverSettings.getServerSettings() />
  
  <cfif !StructKeyExists(serverSettings, "legacyformvalidation")>
    <cfset serverSettings.legacyformvalidation = true />
  </cfif>

  <cfif !StructKeyExists(serverSettings, "formurlcombined")>
    <cfset serverSettings.formurlcombined = false />
  </cfif>
  
  <cfif !StructKeyExists(serverSettings, "strictarraypassbyreference")>
    <cfset serverSettings.strictarraypassbyreference = false />
  </cfif>

  <cfif !StructKeyExists(serverSettings, "functionscopedvariables")>
    <cfset serverSettings.functionscopedvariables = false />
  </cfif>
 
  <cfset charsets = Application.serverSettings.getAvailableCharsets() />
</cfsilent>
<cfsavecontent variable="request.content">
  <cfoutput>
    <script type="text/javascript">
      function updateBufferSettings() {
        var f = document.forms.serverSettings;
      
        if (f.bufferentirepage.checked) {
          f.buffersize.readOnly = true;
          f.buffersize.value = "0";
        } else {
          f.buffersize.readOnly = false;
          f.buffersize.value = "4";
        }
      }
      
      function validate(f) {
        if (f.buffersize.value != parseInt(f.buffersize.value)) {
          alert("Buffer size must be numeric");
          return false;
        } else {
          var cfcfile = '#replace(serverSettings["component-cfc"], "\", "\\", "all")#';
          if (f.componentcfc.value != cfcfile) {
            if(confirm("Are you SURE you want to change the value of Base ColdFusion Component (CFC)?")) {
              return true;
            } else {
              return false;
            }
          }
        }
      }
      
      function confirmRevert() {
        if (confirm("Are you sure you want to revert to the previous version of the server settings?")) {
          location.replace("_controller.cfm?action=revertToPreviousSettings");
        }
      }
      
      function confirmReload() {
        if(confirm("Are you sure you want to reload the configuration settings?")) {
          location.replace("_controller.cfm?action=reloadSettings");
        }
      }
    </script>
    
    <div class="row">
      <div class="pull-left">
	<h2>Server Settings</h2>
      </div>

      <div class="pull-right">
	<button data-controls-modal="moreInfo" data-backdrop="true" data-keyboard="true" class="btn primary">More Info</button>
      </div>
    </div>

    <h4>Settings last updated #serverSettings.lastupdated#</h4>

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
    
    <form name="serverSettings" action="_controller.cfm?action=processServerSettingsForm" method="post" 
	  onsubmit="javascript:return validate(this);">
      <table>
	<tr bgcolor="##dedede">
	  <td colspan="2">
	    <h5>
	      Update Server Settings
	      <a href="javascript:void(0);" onclick="javascript:confirmRevert();" alt="Revert to Previous Settings" 
	       title="Revert to Previous Settings">
		<img src="../images/arrow_undo.png" height="16" width="16" border="0" />
	      </a>&nbsp;
	      <a href="javascript:void(0);" onclick="javascript:confirmReload();" alt="Reload Current Settings" 
		 title="Reload Current Settings">
		<img src="../images/arrow_refresh.png" height="16" width="16" border="0" />
	      </a>
	    </h5> 
	  </td>
	</tr>
	<tr>
	  <td bgcolor="##f0f0f0" style="width:300px;">Response Buffer Size</td>
	  <td>
	    <div class="inline-inputs">
	      <input class="span2" type="text" name="buffersize" id="buffersize" value="#serverSettings.buffersize#"<cfif serverSettings.buffersize == 0> readOnly="true"</cfif> tabindex="1" /><span>KB</span>
	      <input type="checkbox" name="bufferentirepage" id="bufferentirepage" value="1" 
		     onclick="javascript:updateBufferSettings();"<cfif serverSettings.buffersize == 0> checked="true"</cfif> 
		     tabindex="2" /><span>Buffer Entire Page</span>
	    </div>
	  </td>
	</tr>
	<tr>
	  <td bgcolor="##f0f0f0">Whitespace Compression</td>
	  <td>
	    <div class="inline-inputs">
	      <input type="radio" name="whitespacecomp" id="whitespacecompTrue" value="true"<cfif serverSettings.whitespacecomp> checked="true"</cfif> tabindex="3" />
	      <span>Yes</span>
	      <input type="radio" name="whitespacecomp" id="whitespacecompFalse" value="false"<cfif !serverSettings.whitespacecomp> checked="true"</cfif> tabindex="4" />
	      <span>No</span>
	    </div>
	  </td>
	</tr>
	<tr>
	  <td bgcolor="##f0f0f0">Default Error Handler</td>
	  <td>
	    <input type="text" name="errorhandler" id="errorhandler" class="span6" value="#serverSettings.errorhandler#" 
		   tabindex="5" />
	  </td>
	</tr>
	<tr>
	  <td bgcolor="##f0f0f0">Missing Template Handler</td>
	  <td>
	    <input type="text" name="missingtemplatehandler" id="missingtemplatehandler" class="span6" 
		   value="#serverSettings.missingtemplatehandler#" tabindex="6" />
	  </td>
	</tr>
	<tr>
	  <td bgcolor="##f0f0f0">Default Character Set</td>
	  <td>
	    <select name="defaultcharset" id="defaultcharset" tabindex="6">
	      <cfloop collection="#charsets#" item="charset">
		<option value="#charset#"<cfif serverSettings.defaultcharset == charset> selected="true"</cfif>>#charset#</option>
	      </cfloop>
	    </select>
	  </td>
	</tr>
	<tr>
	  <td bgcolor="##f0f0f0">Global Script Protection</td>
	  <td>
	    <div class="inline-inputs">
	      <input type="radio" name="scriptprotect" id="scriptprotectTrue" value="true"<cfif serverSettings.scriptprotect> checked="true"</cfif> tabindex="7" />
	      <span>Yes</span>
	      <input type="radio" name="scriptprotect" id="scriptprotectFalse" value="false"<cfif !serverSettings.scriptprotect> checked="true"</cfif> tabindex="8" />
	      <span>No</span>
	      <img src="../images/arrow_refresh_small.png" height="16" width="16" alt="Requires Server Restart" title="Requires Server Restart" />
	    </div>
	  </td>
	</tr>
	<tr>
	  <td bgcolor="##f0f0f0">Always Pass Arrays By Reference</td>
	  <td>
	    <div class="inline-inputs">
	      <input type="radio" name="strictarraypassbyreference" id="strictarraypassbyreferenceTrue" value="true"
		     <cfif serverSettings.strictarraypassbyreference> checked="true"</cfif> tabindex="9" />
	      <span>Yes</span>
	      <input type="radio" name="strictarraypassbyreference" id="strictarraypassbyreferenceFalse" value="false"
		     <cfif !serverSettings.strictarraypassbyreference> checked="true"</cfif> tabindex="10" />
	      <span>No</span>
	    </div>
	  </td>
	</tr>
	<tr>
	  <td bgcolor="##f0f0f0">Auto-VAR Scope Variables in Functions</td>
	  <td>
	    <div class="inline-inputs">
	      <input type="radio" name="functionscopedvariables" id="functionscopedvariablesTrue" value="true"
		     <cfif serverSettings.functionscopedvariables> checked="true"</cfif> tabindex="11" />
	      <span>Yes</span>
	      <input type="radio" name="functionscopedvariables" id="functionscopedvariablesFalse" value="false"
		     <cfif !serverSettings.functionscopedvariables> checked="true"</cfif> tabindex="12" />
	      <span>No</span>
	    </div>
	  </td>
	</tr>
	<tr>
	  <td bgcolor="##f0f0f0">Combine Form and URL Scopes</td>
	  <td>
	    <div class="inline-inputs">
	      <input type="radio" name="formurlcombined" id="formurlcombinedTrue" value="true"<cfif serverSettings.formurlcombined> checked="true"</cfif> tabindex="13" />
	      <span>Yes</span>
	      <input type="radio" name="formurlcombined" id="formurlcombinedFalse" value="false"<cfif !serverSettings.formurlcombined> checked="true"</cfif> tabindex="14" />
	      <span>No</span>
	    </div>
	  </td>
	</tr>
	<tr>
	  <td bgcolor="##f0f0f0">Support Legacy Form Validation</td>
	  <td>
	    <div class="inline-inputs">
	      <input type="radio" name="legacyformvalidation" id="legacyformvalidationTrue" 
		     value="true"<cfif serverSettings.legacyformvalidation> checked="true"</cfif> 
		     tabindex="15" />&nbsp;
	      <span>Yes</span>
	      <input type="radio" name="legacyformvalidation" id="legacyformvalidationFalse" 
		     value="false"<cfif !serverSettings.legacyformvalidation> checked="true"</cfif> 
		     tabindex="16" />
	      <span>No</span>
	    </div>
	  </td>
	</tr>
	<tr>
	  <td bgcolor="##f0f0f0">Default CFFORM Script Source Location</td>
	  <td>
	    <input type="text" name="scriptsrc" id="scriptsrc" class="span6" 
		   value="#serverSettings.scriptsrc#" tabindex="17" />
	  </td>
	</tr>
	<tr>
	  <td bgcolor="##f0f0f0">Temp Directory Location</td>
	  <td>
	    <input type="text" name="tempdirectory" id="tempdirectory" class="span6" value="#serverSettings.tempdirectory#" 
		   tabindex="18" />
	  </td>
	</tr>
	<tr>
	  <td bgcolor="##f0f0f0">Base ColdFusion Component (CFC)</td>
	  <td>
	    <input type="text" name="componentcfc" id="componentcfc" class="span6" value="#serverSettings['component-cfc']#" 
		   tabindex="19" />
	  </td>
	</tr>
	<tr>
	  <td bgcolor="##f0f0f0">Server CFC</td>
	  <td>
	    <input type="text" name="servercfc" id="servercfc" class="span6" value="#serverSettings.servercfc#" 
		   tabindex="20" />
	  </td>
	</tr>
	<tr>
	  <td bgcolor="##f0f0f0">Verify Path Settings?</td>
	  <td>
	    <div class="inline-inputs">
	      <input type="radio" name="verifypathsettings" id="verifypathsettingsTrue" value="true" checked="true" tabindex="21" />
	      <span>Yes</span>
	      <input type="radio" name="verifypathsettings" id="verifypathsettingsFalse" value="false" tabindex="22" />
	      <span>No</span>
	    </div>
	  </td>
	</tr>
	<tr bgcolor="##dedede">
	  <td>&nbsp;</td>
	  <td>
	    <input class="btn primary" type="submit" name="submit" value="Submit" tabindex="23" />
	  </td>
	</tr>
      </table>
    </form>

    <div id="moreInfo" class="modal hide fade" style="width:940px;position:absolute;">
      <div class="modal-header">
	<a href="##" class="close">&times;</a>
	<h3>Additional Server Settings Information</h3>
      </div>
      <div class="modal-body">
	<h4>Important Information Concerning Physical Paths</h4>
	<ul>
	  <li>
	    When specifying a full physical path on UNIX-based systems (including GNU/Linux and Mac OS X), you must place 
	    a "$" at the beginning of the path. For example:<br />
	    $/usr/local/myPath/myErrorHandler.cfm
	  </li>
	  <li>
	    A path beginning with "/" is interpreted as a relative path from the web application root directory, which 
	    may be a subdirectory of the WEB-INF directory.
	  </li>
	  <li>
	    A path beginning with "$../" is interpreted as relative to the servlet container's home JVM property. 
	    For example, on Tomcat this would be relative to catalina.home, and on Jetty this would be relative to 
	    jetty.home.
	  </li>
	  <li>
	    If "Verify Path Settings" in the form above is set to "Yes," an attempt will be made to perform a read operation on 
	    the directories (or in the case of the Base CFC, the file) provided when the form is submitted. If the read operation 
	    is not successful, the settings will not be saved. If you are running OpenBD in an unusual environment for which read 
	    operations on the directories provided are not successful, but you wish to save the settings regardless, you must set 
	    "Verify Path Settings" to "No" in order for the settings to be saved.
	  </li>
	</ul>

	<h4>Important Information Concerning Configuration Settings</h4>
	<ul>
	  <li>
	    Clicking "Revert to Previous Settings" will reload all OpenBD configuration settings using the XML 
	    configuration file that is one revision older than the current file.
	  </li>
	  <li>
	    Clicking "Reload Current Settings" will force a reload of all OpenBD configuration settings from 
	    the current bluedragon.xml configuration file. One use for this function is if the bluedragon.xml 
	    file is manually replaced with a different bluedragon.xml file, OpenBD will need to be forced 
	    to reload the configuration settings. Using this function avoids having to restart OpenBD, other than 
	    if a specific configuration setting requires a server restart.
	  </li>
	  <li>
	    If the configuration settings are changed using either the "Revert to Previous" or "Reload Current" functions, 
	    and one of the settings within the updated configuration file requires a server restart to take effect 
	    (e.g. "Global Script Protection" and "ColdFusion 5-compatible client data" on the variables settings page), 
	    using these functions will not eliminate the need for a server restart.
	  </li>
	</ul>
	
	<h4>Important Information Concerning the Base ColdFusion Component (CFC)</h4>
	<ul>
	  <li>
	    If you change this value, PLEASE use caution and ensure that the CFC file being used is error free,
	    and that the path to the CFC file is valid. Upon submitting the form the application will attempt to 
	    read the physical CFC file (provided you have "Verify Path Settings" set to "Yes"), but this does not 
	    ensure that an error in the CFC itself will not cause global problems on this instance of OpenBD. 
	    If problems do occur, the value must be changed in the bluedragon.xml configuration file and the 
	    OpenBD instance must be restarted.
	  </li>
	</ul>
      </div>
    </div>
  </cfoutput>
</cfsavecontent>
