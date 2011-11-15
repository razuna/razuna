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
  <cfparam name="cppTagsMessage" type="string" default="" />
  <cfparam name="javaTagsMessage" type="string" default="" />
  <cfparam name="cppTags" type="array" default="#arrayNew(1)#" />
  <cfparam name="javaTags" type="array" default="#arrayNew(1)#" />
  
  <cftry>
    <cfset cppTags = Application.extensions.getCPPCFX() />
    <cfcatch type="bluedragon.adminapi.extensions">
      <cfset cppTagsMessage = CFCATCH.Message />
      <cfset cppTagsMessageType = "error" />
    </cfcatch>
  </cftry>
  
  <cftry>
    <cfset javaTags = Application.extensions.getJavaCFX() />
    <cfcatch type="bluedragon.adminapi.extensions">
      <cfset javaTagsMessage = CFCATCH.Message />
      <cfset javaTagsMessageType = "error" />
    </cfcatch>
  </cftry>
</cfsilent>
<cfsavecontent variable="request.content">
  <cfoutput>
    <script type="text/javascript">
      function deleteCFXTag(tag, type) {
        if(confirm("Are you sure you want to delete this CFX tag?")) {
          if (type == 'java') {
            location.replace("_controller.cfm?action=deleteJavaCFXTag&name=" + tag);
          } else if (type == 'cpp') {
            location.replace("_controller.cfm?action=deleteCPPCFXTag&name=" + tag);
          }
        }
      }
    </script>
    
    <h2>CFX Tags</h2>

    <cfif StructKeyExists(session, "message") && session.message.text != "">
      <div class="alert-message #session.message.type# fade in" data-alert="alert">
	<a class="close" href="##">x</a>
	<p>#session.message.text#</p>
      </div>
    </cfif>

    <cfif cppTagsMessage != "">
      <div class="alert-message #cppTagsMessageType# fade in" data-alert="alert">
	<a class="close" href="##">x</a>
	<p>#cppTagsMessage#</p>
      </div>
    </cfif>

    <cfif javaTagsMessage != "">
      <div class="alert-message #javaTagsMessageType# fade in" data-alert="alert">
	<a class="close" href="##">x</a>
	<p>#javaTagsMessage#</p>
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
    
    <cfif ArrayLen(cppTags) gt 0 || ArrayLen(javaTags) gt 0>
      <table>
	<tr bgcolor="##f0f0f0">
	  <th style="width:100px;">Actions</th>
	  <th>Tag Name</th>
	  <th>Type</th>
	  <th>Module/Class</th>
	  <th>Description</th>
	</tr>
	<cfif arrayLen(cppTags) gt 0>
	  <cfloop index="i" from="1" to="#ArrayLen(cppTags)#">
	    <tr>
	      <td>
		<a href="_controller.cfm?action=editCPPCFXTag&cfxTag=#cppTags[i].name#" alt="Edit CFX Tag" title="Edit CFX Tag"><img src="../images/pencil.png" border="0" width="16" height="16" /></a>
		<a href="_controller.cfm?action=verifyCFXTag&name=#cppTags[i].name#&type=cpp" alt="Verify CFX Tag" title="Verify CFX Tag"><img src="../images/accept.png" border="0" width="16" height="16" /></a>
		<a href="javascript:void(0);" onclick="javascript:deleteCFXTag('#cppTags[i].name#','cpp');" alt="Delete CFX Tag" title="Delete CFX Tag"><img src="../images/cancel.png" border="0" width="16" height="16" /></a>
	      </td>
	      <td>#cppTags[i].displayname#</td>
	      <td>C++</td>
	      <td>#cppTags[i].module#</td>
	      <td>#cppTags[i].description#</td>
	    </tr>
	  </cfloop>
	</cfif>
	<cfif ArrayLen(javaTags) gt 0>
	  <cfloop index="i" from="1" to="#arrayLen(javaTags)#">
	    <tr>
	      <td>
		<a href="_controller.cfm?action=editJavaCFXTag&cfxTag=#javaTags[i].name#" alt="Edit CFX Tag" title="Edit CFX Tag"><img src="../images/pencil.png" border="0" width="16" height="16" /></a>
		<a href="_controller.cfm?action=verifyCFXTag&name=#javaTags[i].name#&type=java" alt="Verify CFX Tag" title="Verify CFX Tag"><img src="../images/accept.png" border="0" width="16" height="16" /></a>
		<a href="javascript:void(0);" onclick="javascript:deleteCFXTag('#javaTags[i].name#','java');" alt="Delete CFX Tag" title="Delete CFX Tag"><img src="../images/cancel.png" border="0" width="16" height="16" /></a>
	      </td>
	      <td>#javaTags[i].displayname#</td>
	      <td>Java</td>
	      <td>#javaTags[i].class#</td>
	      <td>#javaTags[i].description#</td>
	    </tr>
	  </cfloop>
	</cfif>
      </table>
    </cfif>
    <ul>
      <li><a href="javacfx.cfm">Register Java CFX Tag</a></li>
      <li><a href="cppcfx.cfm">Register C++ CFX Tag</a></li>
    </ul>
  </cfoutput>
  <cfset StructDelete(session, "cfxTag", false) />
</cfsavecontent>
