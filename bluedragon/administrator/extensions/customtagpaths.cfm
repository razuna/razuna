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
  <cfparam name="customTagMessage" type="string" default="" />
  <cfparam name="customTagPaths" type="array" default="#arrayNew(1)#" />
  <cfparam name="customTagPath" type="string" default="" />
  <cfparam name="customTagPathAction" type="string" default="create" />
  
  <cftry>
    <cfset customTagPaths = Application.extensions.getCustomTagPaths() />
    <cfcatch type="bluedragon.adminapi.extensions">
      <cfset customTagPaths = arrayNew(1) />
      <cfset customTagMessage = CFCATCH.Message />
      <cfset customTagMessageType = "error" />
    </cfcatch>
  </cftry>
</cfsilent>
<cfsavecontent variable="request.content">
  <cfoutput>
    <script type="text/javascript">
      function editCustomTagPath(path) {
        var f = document.forms.customTagPathForm;
      
        document.getElementById('actionHeader').innerHTML = 'Edit';
        f.directory.value = path;
        f.customTagPathAction = "update";
        f.existingCustomTagPath = path;
      }
      
      function resetCustomTagPathForm() {
        var f = document.forms.customTagPathForm;
      
        document.getElementById('actionHeader').innerHTML = 'Add a';
        f.directory.value = "";
        f.customTagPathAction = "create";
        f.existingCustomTagPath = "";
      }
      
      function deleteCustomTagPath(path) {
        if(confirm("Are you sure you want to delete this custom tag path?")) {
          location.replace("_controller.cfm?action=deleteCustomTagPath&directory=" + path);
        }
      }
      
      function validate(f) {
        if (f.directory.value.length == 0) {
          alert("Please enter a valid directory path");
          return false;
        } else {
          return true;
        }
      }
    </script>
    
    <div class="row">
      <div class="pull-left">
	<h2>Custom Tag Paths</h2>
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

    <cfif customTagMessage != "">
      <div class="alert-message #customTagMessageType# fade in" data-alert="alert">
	<a class="close" href="##">x</a>
	<p>#customTagMessage#</p>
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
    
    <cfif ArrayLen(customTagPaths) gt 0>
      <table>
	<tr bgcolor="##f0f0f0">
	  <th style="width:100px;">Actions</th>
	  <th>Custom Tag Path</th>
	</tr>
	<cfloop index="i" from="1" to="#ArrayLen(customTagPaths)#">
	  <tr>
	    <td>
	      <a href="javascript:void(0);" 
		 onclick="javascript:editCustomTagPath('#Replace(customTagPaths[i], '\', '\\', 'all')#');" 
		 alt="Edit Custom Tag Path" title="Edit Custom Tag Path">
		<img src="../images/pencil.png" border="0" width="16" height="16" />
	      </a>
	      <a href="_controller.cfm?action=verifyCustomTagPath&directory=#customTagPaths[i]#" alt="Verify Custom Tag Path" 
		 title="Verify Custom Tag Path">
		<img src="../images/accept.png" border="0" width="16" height="16" />
	      </a>
	      <a href="javascript:void(0);" 
		 onclick="javascript:deleteCustomTagPath('#Replace(customTagPaths[i], '\', '\\', 'all')#');" 
		 alt="Delete Custom Tag Path" title="Delete Custom Tag Path">
		<img src="../images/cancel.png" border="0" width="16" height="16" />
	      </a>
	    </td>
	    <td>#customTagPaths[i]#</td>
	  </tr>
	</cfloop>
      </table>
    </cfif>
    
    <br />
    
    <form name="customTagPathForm" action="_controller.cfm?action=processCustomTagPathForm" method="post" 
	  onsubmit="javascript:return validate(this);">
      <table>
	<tr>
	  <th colspan="2" bgcolor="##dedede"><span id="actionHeader">Add a</span> Custom Tag Path</strong></th>
	</tr>
	<tr>
	  <td bgcolor="##f0f0f0">Custom Tag Path</td>
	  <td>
	    <input type="text" name="directory" id="directory" class="span6" value="#customTagPath#" tabindex="1" />
	  </td>
	</tr>
	<tr bgcolor="##dedede">
	  <td>&nbsp;</td>
	  <td>
	    <input type="button" name="reset" class="btn default" value="Reset" onclick="javascript:resetCustomTagPathForm();" tabindex="2" />
	    <input type="submit" name="submit" class="btn primary" value="Submit" tabindex="3" />
	  </td>
	</tr>
      </table>
      <input type="hidden" name="customTagPathAction" value="#customTagPathAction#" />
      <input type="hidden" name="existingCustomTagPath" value="#customTagPath#">
    </form>

    <div id="moreInfo" class="modal hide fade">
      <div class="modal-header">
	<a href="##" class="close">&times;</a>
	<h3>Important Information Concerning Custom Tag Paths</h3>
      </div>
      <div class="modal-body">
	<ul>
	  <li>
	    When specifying a full physical path on UNIX-based systems (including GNU/Linux and Mac OS X), you must place 
	    a "$" at the beginning of the path. For example:<br />
	    $/usr/local/myPath
	  </li>
	  <li>
	    A path beginning with "/" is interpreted as a relative path from the web application root directory, which 
	    may be a subdirectory of the WEB-INF directory.
	  </li>
	</ul>
      </div>
    </div>
  </cfoutput>
  <cfset StructDelete(session, "mapping", false) />
</cfsavecontent>
