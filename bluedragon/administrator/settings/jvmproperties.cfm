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
  <cfparam name="jvmMessage" type="string" default="" />
  
  <cfset jvmProps = {} />
  
  <cftry>
    <cfset jvmProps = Application.serverSettings.getJVMProperties() />
    <cfcatch type="any">
      <cfset jvmMessage = CFCATCH.Message />
      <cfset jvmMessageType = "error" />
    </cfcatch>
  </cftry>
</cfsilent>
<cfsavecontent variable="request.content">
  <cfoutput>
    <div class="row">
      <h2>Java Virtual Machine (JVM) Properties</h2>
    </div>
    
    <cfif StructKeyExists(session, "message") && session.message.text != "">
      <div class="alert-message #session.message.type# fade in" data-alert="alert">
	<a class="close" href="##">x</a>
	<p>#session.message.text#</p>
      </div>
    </cfif>
    
    <cfif jvmMessage != "">
      <div class="alert-message #jvmMessageType# fade in" data-alert="alert">
	<a class="close" href="##">x</a>
	<p>#jvmMessage#</p>
      </div>
    </cfif>

    <table>
      <tr bgcolor="##f0f0f0">
	<th>Property Name</th>
	<th>Property Value</th>
      </tr>
      <cfloop collection="#jvmProps#" item="prop">
	<tr>
	  <td bgcolor="##f0f0f0">#prop#</td>
	  <td bgcolor="##ffffff">#jvmProps[prop]#</td>
	</tr>
      </cfloop>
    </table>
  </cfoutput>
</cfsavecontent>
