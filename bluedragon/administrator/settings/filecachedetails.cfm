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
  <cfset fileCacheList = SystemFileCacheList() />
</cfsilent>
<cfsavecontent variable="request.content">
  <cfoutput>
    <div class="row">
      <h2>File Cache Details</h2>
    </div>
    <cfif ArrayLen(fileCacheList) gt 0>
      <table>
	<tr bgcolor="##dedede">
	  <td colspan="5"><h5>Files in Cache (#ArrayLen(fileCacheList)#)</h5></td>
	</tr>
	<tr bgcolor="##f0f0f0">
	  <th>URI</th>
	  <th>Real Path</th>
	  <th>Hits</th>
	  <th>Last Used</th>
	</tr>
	<cfloop array="#fileCacheList#" index="info">
	  <tr>
	    <td bgcolor="##ffffff">#info.uri#</td>
	    <td bgcolor="##ffffff">#info.realpath#</td>
	    <td bgcolor="##ffffff">#info.hits#</td>
	    <td bgcolor="##ffffff">
	      #DateFormat(info.lastused, 'mm-dd-yyyy')# 
	      #TimeFormat(info.lastused, 'HH:mm:ss')#
	    </td>
	  </tr>
	</cfloop>
      </table>
      <cfelse>
	<em>- no files in cache -</em>
    </cfif>
  </cfoutput>
</cfsavecontent>
