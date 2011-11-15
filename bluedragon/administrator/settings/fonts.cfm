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
  <cfparam name="fontsMessage" type="string" default="" />
  <cfparam name="fontDirs" type="array" default="#arrayNew(1)#" />
  <cfparam name="fontDirAction" type="string" default="create" />
  
  <cftry>
    <cfset fontDirs = Application.fonts.getFontDirectories() />
    <cfcatch type="bluedragon.adminapi.fonts">
      <cfset fontsMessage = CFCATCH.Message />
      <cfset fontsMessageType = "error" />
    </cfcatch>
  </cftry>
</cfsilent>
<cfsavecontent variable="request.content">
  <cfoutput>
    <script type="text/javascript">
      function validate(f) {
        if (f.fontDir.value.length == 0) {
          alert("Please enter the font directory");
          return false;
        } else {
          return true;
        }
      }
      
      function editFontDir(fontDir) {
        var f = document.forms.fontDirForm;
      
        f.fontDir.value = fontDir;
        f.existingFontDir.value = fontDir;
        f.fontDirAction.value = "update";
      }
      
      function removeFontDir(fontDir) {
        if (confirm("Are you sure you want to remove this font directory?")) {
          location.replace("_controller.cfm?action=removeFontDirectory&fontDir=" + fontDir);
        }
      }
    </script>
    
    <div class="row">
      <div class="pull-left">
	<h2>Font Directories</h2>
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
    
    <cfif fontsMessage != "">
      <div class="alert-message #fontsMessageType# fade in" data-alert="alert">
	<a class="close" href="##">x</a>
	<p>#fontsMessage#</p>
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

    <cfif ArrayLen(fontDirs) gt 0>
      <table>
	<tr bgcolor="##f0f0f0">
	  <th>Actions</th>
	  <th>Font Directory</th>
	</tr>
	<cfloop index="i" from="1" to="#arrayLen(fontDirs)#">
	  <tr bgcolor="##ffffff">
	    <td width="100">
	      <a href="javascript:void(0);" 
		 onclick="javascript:editFontDir('#replace(fontDirs[i], '\', '\\', 'all')#');" 
		 alt="Edit Font Directory" title="Edit Font Directory">
		<img src="../images/pencil.png" border="0" width="16" height="16" />
	      </a>
	      <a href="_controller.cfm?action=verifyFontDirectory&fontDir=#fontDirs[i]#" alt="Verify Font Directory" 
		 title="Verify Font Directory">
		<img src="../images/accept.png" border="0" width="16" height="16" />
	      </a>
	      <a href="javascript:void(0);" 
		 onclick="javascript:removeFontDir('#replace(fontDirs[i], '\', '\\', 'all')#');" 
		 alt="Remove Font Directory" title="Remove Font Directory">
		<img src="../images/cancel.png" border="0" width="16" height="16" />
	      </a>
	    </td>
	    <td>#fontDirs[i]#</td>
	  </tr>
	</cfloop>
      </table>
    </cfif>
    
    <br />
    
    <form name="fontDirForm" action="_controller.cfm?action=processFontDirForm" method="post" 
	  onsubmit="javascript:return validate(this);">
      <table>
	<tr bgcolor="##dedede">
	  <th colspan="2"><h5><cfif fontDirAction == "create">Add a<cfelse>Edit</cfif> Font Directory</h5></th>
	</tr>
	<tr>
	  <td bgcolor="##f0f0f0"><label for="fontDir">Font Directory</label></td>
	  <td bgcolor="##ffffff">
	    <input class="span6" type="text" name="fontDir" id="fontDir" value="" tabindex="1" />
	  </td>
	</tr>
	<tr bgcolor="##dedede">
	  <td>&nbsp;</td>
	  <td>
	    <input class="btn primary" id="submit" type="submit" name="submit" value="Submit" tabindex="2" />
	  </td>
	</tr>
      </table>
      <input type="hidden" name="fontDirAction" value="#fontDirAction#" />
      <input type="hidden" name="existingFontDir" value="">
    </form>

    <div id="moreInfo" class="modal hide fade">
      <div class="modal-header">
	<a href="##" class="close">&times;</a>
	<h3>Important Information Concerning Font Paths</h3>
      </div>
      <div class="modal-body">
	<ul>
	  <li>
	    A full physical path starting with "/" (on Unix-based systems) or a full drive path including drive letter 
	    (on Windows systems) may be specified.
	  </li>
	  <li>
	    On Unix-based systems the common font folders include:
	    <ul>
	      <li>/usr/X/lib/X11/fonts/TrueType</li>
	      <li>/usr/openwin/lib/X11/fonts/TrueType</li>
	      <li>/usr/share/fonts/default/TrueType</li>
	      <li>/usr/X11R6/lib/X11/fonts/ttf</li>
	      <li>/usr/X11R6/lib/X11/fonts/truetype</li>
	      <li>/usr/X11R6/lib/X11/fonts/TTF</li>
	    </ul>
	  </li>
	</ul>
      </div>
    </div>
  </cfoutput>
  <cfset structDelete(session, "fontDir", false) />
</cfsavecontent>
