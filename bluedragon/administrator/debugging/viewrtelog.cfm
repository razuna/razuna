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
  <cfparam name="url.rteLog" type="string" default="" />
  <cfparam name="logContents" type="string" default="" />
  
  <cfset rteLogPath = Application.debugging.getRunTimeErrorLogPath() & Application.debugging.getFileSeparator() />
  
  <cfif url.rteLog != "">
    <cfif FileExists("#rteLogPath##url.rteLog#")>
      <cffile action="read" file="#rteLogPath##url.rteLog#" variable="logContents" />
    </cfif>
  </cfif>
</cfsilent>
<cfsavecontent variable="request.content">
  <cfoutput>
    <cfif logContents != "">
      <div class="row">
	<div class="pull-left"><h3>Viewing Contents of #url.rteLog#</h3></div>
	<div class="pull-right"><h6><a href="runtimeerrors.cfm">&laquo; Back to Runtime Error Logs</a></h6></div>
      </div>
      <div class="container" style="width:100%;">
	#logContents#
      </div>
      <cfelse>
	<p><strong>No file contents to display</strong></p>
    </cfif>
  </cfoutput>
</cfsavecontent>
