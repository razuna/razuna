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
  <cfparam name="cfxTagMessage" type="string" default="" />
  <cfparam name="cfxTagMessageType" type="string" default="" />
  <cfparam name="cfxTag" type="struct" default="#StructNew()#" />
  <cfparam name="cfxTagAction" type="string" default="create" />
  
  <cfif StructKeyExists(session, "cfxTag")>
    <cfset cfxTag = session.cfxTag />
    <cfset cfxTagAction = "update" />
    <cfset submitButtonAction = "Update" />
    <cfelse>
      <cfset cfxTag = {name:'', displayname:'cfx_', description:'', 
	               module:'', function:'', keeploaded:true} />
      <cfset cfxTagAction = "create" />
      <cfset submitButtonAction = "Register" />
  </cfif>
</cfsilent>
<cfsavecontent variable="request.content">
  <cfoutput>
    <script type="text/javascript">
      function validate(f) {
        var tagNameTest = /^([a-zA-Z0-9_-]+)$/;
      
        if (f.name.value.length == 0) {
          alert("Please enter the tag name");
          return false;
        } else if (f.name.value.substring(0,4).toLowerCase() != 'cfx_') {
          alert("Custom tag names must start with cfx_");
          return false;
        } else if (!tagNameTest.test(f.name.value)) {
          alert("Custom tag names may only include alphanumeric characters, hypens, and underscores");
          return false;
        } else if (f.module.value.length == 0) {
          alert("Please enter the class name");
          return false;
        } else if (f.function.value.length == 0) {
          alert("Please enter the function name");
          return false;
        } else {
          return true;
        }
      }
    </script>
    
    <div class="row">
      <div class="pull-left">
	<h2>C++ CFX Tag</h2>
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

    <cfif cfxTagMessage != "">
      <div class="alert-message #cfxTagMessageType# fade in" data-alert="alert">
	<a class="close" href="##">x</a>
	<p>#cfxTagMessage#</p>
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
    
    <form action="_controller.cfm?action=processCPPCFXForm" method="post" onsubmit="javascript:return validate(this);">
      <table>
	<tr>
	  <td bgcolor="##f0f0f0">Tag Name</td>
	  <td>
	    <input type="text" name="name" id="name" class="span6" value="#cfxTag.displayname#" tabindex="1" />
	  </td>
	</tr>
	<tr>
	  <td bgcolor="##f0f0f0">Module Name</td>
	  <td>
	    <input type="text" name="module" id="module" class="span6" value="#cfxTag.module#" tabindex="2" />
	  </td>
	</tr>
	<tr>
	  <td bgcolor="##f0f0f0">Function Name</td>
	  <td>
	    <input type="text" name="function" id="function" class="span6" value="#cfxTag.function#" tabindex="3" />
	  </td>
	</tr>
	<tr>
	  <td bgcolor="##f0f0f0">Keep Loaded</td>
	  <td>
	    <div class="inline-inputs">
	      <input type="radio" name="keeploaded" id="keeploadedTrue" value="true"
		     <cfif cfxTag.keeploaded> checked="true"</cfif> tabindex="4" />
	      <span>Yes</span>
	      <input type="radio" name="keeploaded" id="keeploadedFalse" value="false"
		     <cfif not cfxTag.keeploaded> checked="true"</cfif> tabindex="5" />
	      <span>No</span>
	    </div>
	  </td>
	</tr>
	<tr>
	  <td valign="top" bgcolor="##f0f0f0">Description</td>
	  <td valign="top">
	    <textarea name="description" id="description" class="span6" rows="6" tabindex="6">#cfxTag.description#</textarea>
	  </td>
	</tr>
	<tr bgcolor="##dedede">
	  <td>&nbsp;</td>
	  <td>
	    <input type="button" class="btn default" name="cancel" id="cancel" value="Cancel" 
		   onclick="javascript:location.replace('cfxtags.cfm');" tabindex="7" />
	    <input type="submit" class="btn primary" name="submit" id="submit" value="#submitButtonAction# C++ CFX Tag" tabindex="8" />
	  </td>
	</tr>
      </table>
      <input type="hidden" name="existingCFXName" value="#cfxTag.name#" />
      <input type="hidden" name="cfxAction" value="#cfxTagAction#" />
    </form>

    <div id="moreInfo" class="modal hide fade">
      <div class="modal-header">
	<a href="##" class="close">&times;</a>
	<h3>Important Information Concerning C++ Custom Tags</h3>
      </div>
      <div class="modal-body">
	<ul>
	  <li>The path to the C++ module may be specified as a full path or a relative path.</li>

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
</cfsavecontent>
