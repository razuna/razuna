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
  <cfparam name="logFileMessage" type="string" default="" />
  <cfparam name="url.logFile" type="string" default="" />
  <cfparam name="url.numLinesToShow" type="numeric" default="25" />
  <cfparam name="url.startLine" type="numeric" default="1" />
  
  <cfset logFileData = {} />
  <cfset logFileData.totalLineCount = 0 />
  <cfset logFileData.logFileLines = [] />
  
  <cftry>
    <cfset logFileData = Application.debugging.getLogFileLines(url.logFile, url.startLine, url.numLinesToShow) />
    
    <cfif url.startLine + url.numLinesToShow - 1 gte logFileData.totalLineCount>
      <cfset endLine = logFileData.totalLineCount />
      <cfset showNext = false />
      <cfset showFinal = false />
      <cfelse>
	<cfset nextStart = url.startLine + url.numLinesToShow />
	
	<cfif logFileData.totalLineCount Mod url.numLinesToShow == 0>
	  <cfset finalStart = ((logFileData.totalLineCount / url.numLinesToShow) - 1) * url.numLinesToShow + 1 />
	  <cfelse>
	    <cfset numOnLastPage = logFileData.totalLineCount mod url.numLinesToShow />
	    <cfset finalStart = logFileData.totalLineCount - numOnLastPage + 1 />
	</cfif>
	
	<cfif finalStart gte logFileData.totalLineCount>
	  <cfset showFinal = false />
	  <cfelse>
	    <cfset showFinal = true />
	</cfif>
	
	<cfset endLine = url.startLine + url.numLinesToShow - 1 />
	<cfset showNext = true />
    </cfif>
    
    <cfif url.startLine != 1>
      <cfset prevStart = url.startLine - url.numLinesToShow />
      <cfset showPrev = true />
      <cfelse>
	<cfset showPrev = false />
    </cfif>
    
    <cfcatch type="bluedragon.adminapi.debugging">
      <cfset logFileMessage = CFCATCH.Message />
      <cfset logFileMessageType = "error" />
    </cfcatch>
  </cftry>
</cfsilent>
<cfsavecontent variable="request.content">
  <cfoutput>
    <div class="row">
      <div class="pull-left"><h3>View Log File - #url.logFile#</h3></div>
      <div class="pull-right"><h6><a href="logs.cfm">&laquo; Back to Logs</a></h6></div>
    </div>

    <cfif StructKeyExists(session, "message") && session.message.text != "">
      <div class="alert-message #session.message.type# fade in" data-alert="alert">
	<a class="close" href="##">x</a>
	<p>#session.message.text#</p>
      </div>
    </cfif>

    <cfif logFileMessage != "">
      <div class="alert-message #logFileMessageType# fade in" data-alert="alert">
	<a class="close" href="##">x</a>
	<p>#logFileMessage#</p>
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
    
    <cfif ArrayLen(logFileData.logFileLines) == 0>
      <p><strong><em>Log file not available or contains no entries</em></strong></p>
      <cfelse>
	<div class="pull-left"><h5>Entries #url.startLine# - #endLine# of #logFileData.totalLineCount#</h5></div>
	<div class="pull-right">
	  <cfif showPrev>
	    <a href="viewlogfile.cfm?logFile=#url.logFile#&startLine=1&numLinesToShow=#url.numLinesToShow#"><img src="../images/resultset_first.png" border="0" width="16" height="16" alt="Go To Beginning" title="Go To Beginning" /></a>
	  </cfif>
	  <cfif showPrev>
	    <a href="viewlogfile.cfm?logFile=#url.logFile#&startLine=#prevStart#&numLinesToShow=#url.numLinesToShow#"><img src="../images/resultset_previous.png" border="0" width="16" height="16" alt="Previous #url.numLinesToShow#" title="Previous #url.numLinesToShow#" /></a>
	  </cfif>
	  <cfif showNext>
	    <a href="viewlogfile.cfm?logFile=#url.logFile#&startLine=#nextStart#&numLinesToShow=#url.numLinesToShow#"><img src="../images/resultset_next.png" border="0" width="16" height="16" alt="Next #url.numLinesToShow#" title="Next #url.numLinesToShow#" /></a>
	  </cfif>
	  <cfif showFinal>
	    <a href="viewlogfile.cfm?logFile=#url.logFile#&startLine=#finalStart#&numLinesToShow=#url.numLinesToShow#"><img src="../images/resultset_last.png" border="0" width="16" height="16" alt="Go To End" title="Go To End" /></a>
	  </cfif>
	</div>
	<table>
	  <cfloop index="i" from="1" to="#arrayLen(logFileData.logFileLines)#">
	    <cfset rowBG = IIf(i Mod 2 == 0, DE("f0f0f0"), DE("ffffff")) />
	    <tr bgcolor="###rowBG#">
	      <td>
		<cfif logFileData.logFileLines[i] != "">
		  #logFileData.logFileLines[i]#
		  <cfelse>
		    &nbsp;
		</cfif>
	      </td>
	    </tr>
	  </cfloop>
	</table>
    </cfif>
  </cfoutput>
</cfsavecontent>
