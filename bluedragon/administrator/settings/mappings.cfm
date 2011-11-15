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
  <cfparam name="mappingMessage" type="string" default="" />
  <cfparam name="mappings" type="array" default="#arrayNew(1)#" />
  <cfparam name="mappingAction" type="string" default="create" />
  
  <cfif StructKeyExists(session, "mapping")>
    <cfset mapping = session.mapping[1] />
    <cfset mappingAction = "update" />
    <cfelse>
      <cfset mapping = {name:'', displayname:'', directory:'', mappingAction:'create'} />
  </cfif>
  
  <cftry>
    <cfset mappings = Application.mapping.getMappings() />
    <cfcatch type="bluedragon.adminapi.mapping">
      <cfset mappingMessage = CFCATCH.Message />
      <cfset mappingMessageType = "error" />
    </cfcatch>
  </cftry>
</cfsilent>
<cfsavecontent variable="request.content">
  <cfoutput>
    <script type="text/javascript">
      function validate(f) {
        if (f.name.value.length == 0) {
          alert("Please enter the logical path");
          return false;
        } else if (f.directory.value.length == 0) {
          alert("Please enter the directory path");
          return false;
        } else {
          return true;
        }
      }
      
      function deleteMapping(mappingName) {
        if (confirm("Are you sure you want to delete this mapping?")) {
          location.replace("_controller.cfm?action=deleteMapping&name=" + mappingName);
        }
      }
    </script>
    
    <div class="row">
      <div class="pull-left">
	<h2>Directory Mappings</h2>
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

    <cfif mappingMessage != "">
      <div class="alert-message #mappingMessageType# fade in" data-alert="alert">
	<a class="close" href="##">x</a>
	<p>#mappingMessage#</p>
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

    <cfif ArrayLen(mappings) gt 0>
      <table>
	<tr bgcolor="##f0f0f0">
	  <th>Actions</th>
	  <th>Logical Path</th>
	  <th>Directory Path</th>
	</tr>
	<cfloop index="i" from="1" to="#ArrayLen(mappings)#">
	  <tr bgcolor="##ffffff">
	    <td style="width:100px;">
	      <a href="_controller.cfm?action=editMapping&name=#mappings[i].name#" alt="Edit Mapping" title="Edit Mapping">
		<img src="../images/pencil.png" border="0" width="16" height="16" />
	      </a>
	      <a href="_controller.cfm?action=verifyMapping&name=#mappings[i].name#" alt="Verify Mapping" title="Verify Mapping">
		<img src="../images/accept.png" border="0" width="16" height="16" />
	      </a>
	      <a href="javascript:void(0);" onclick="javascript:deleteMapping('#mappings[i].name#');" alt="Delete Mapping" title="Delete Mapping">
		<img src="../images/cancel.png" border="0" width="16" height="16" />
	      </a>
	    </td>
	    <td><cfif structKeyExists(mappings[i], "displayname")>#mappings[i].displayname#<cfelse>#mappings[i].name#</cfif></td>
	    <td>#mappings[i].directory#</td>
	  </tr>
	</cfloop>
      </table>
    </cfif>
    
    <br />
    
    <form name="mappingForm" action="_controller.cfm?action=processMappingForm" method="post" 
	  onsubmit="javascript:return validate(this);">
      <table>
	<tr bgcolor="##dedede">
	  <td colspan="2"><strong><cfif mappingAction == "create">Add a<cfelse>Edit</cfif> Mapping</strong></td>
	</tr>
	<tr>
	  <td bgcolor="##f0f0f0">Logical Path</td>
	  <td bgcolor="##ffffff">
	    <input type="text" name="name" id="name" class="span8" 
		   value="<cfif structKeyExists(mapping, 'displayname')>#mapping.displayname#<cfelse>#mapping.name#</cfif>" 
		   tabindex="1" />
	  </td>
	</tr>
	<tr>
	  <td bgcolor="##f0f0f0">Directory Path</td>
	  <td bgcolor="##ffffff">
	      <input type="text" name="directory" id="directory" class="span8" value="#mapping.directory#" tabindex="2" />
	  </td>
	</tr>
	<tr bgcolor="##dedede">
	  <td>&nbsp;</td>
	  <td>
	    <input class="btn primary" type="submit" name="submit" value="Submit" tabindex="3" />
	  </td>
	</tr>
      </table>
      <input type="hidden" name="mappingAction" value="#mappingAction#" />
      <input type="hidden" name="existingMappingName" value="#mapping.name#">
    </form>

    <div id="moreInfo" class="modal hide fade">
      <div class="modal-header">
	<a href="##" class="close">&times;</a>
	<h3>Important Information Concerning Mappings</h3>
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
