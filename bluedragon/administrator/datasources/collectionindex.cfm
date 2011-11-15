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
  <cfparam name="searchCollectionsMessage" type="string" default="" />
  
  <cfif !StructKeyExists(session, "searchCollection")>
    <cflocation url="collections.cfm" addtoken="false" />
  </cfif>
  
  <cfset fileExtensions = [] />
  
  <cftry>
    <cfset fileExtensions = ArrayToList(Application.searchCollections.getIndexableFileExtensions()) />
    <cfcatch type="any">
      <cfset searchCollectionsMessage = CFCATCH.Message />
      <cfset searchCollectionsMessageType = "error" />
    </cfcatch>
  </cftry>
</cfsilent>
<cfsavecontent variable="request.content">
  <cfoutput>
    <script type="text/javascript">
      function validateDirectoryIndexForm(f) {
        if (f.key.value.length == 0) {
          alert("Please enter the directory path");
          return false;
        } else {
          return true;
        }
      }
    </script>

    <div class="row">
      <div class="pull-left">
	<h2>Create/Update Index for Search Collection "#session.searchCollection.name#"</h2>
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

    <cfif searchCollectionsMessage != "">
      <div class="alert-message #searchCollectionsMessageType# fade in" data-alert="alert">
	<a class="close" href="##">x</a>
	<p>#searchCollectionsMessage#</p>
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
    
    <form name="directoryIndexForm" action="_controller.cfm?action=indexSearchCollection" method="post" 
	  onSubmit="return validateDirectoryIndexForm(this);">
      <table>
	<tr bgcolor="##dedede">
	  <th colspan="2"><h5>Directory Index</h5></th>
	</tr>
	<tr>
	  <td bgcolor="##f0f0f0">Directory Path</td>
	  <td><input type="text" name="key" id="key" class="span12" tabindex="1" /></td>
	</tr>
	<tr>
	  <td bgcolor="##f0f0f0">Extensions</td>
	  <td>
	    <input type="text" name="extensions" id="extensions" class="span12" value="#fileExtensions#" 
		   tabindex="2" />
	  </td>
	</tr>
	<tr>
	  <td bgcolor="##f0f0f0">Recurse Subdirectories</td>
	  <td>
	    <div class="inline-inputs">
	      <input type="radio" name="recurse" id="recurseTrue" value="true" checked="true" tabindex="3" />
	      <span>Yes</span>
	      <input type="radio" name="recurse" id="recurseFalse" value="false" tabindex="4" />
	      <span>No</span>
	    </div>
	  </td>
	</tr>
	<tr>
	  <td bgcolor="##f0f0f0">URL Path</td>
	  <td><input type="text" name="urlpath" id="urlpath" class="span12" tabindex="5" /></td>
	</tr>
	<tr>
	  <td bgcolor="##f0f0f0" align="right">Language</td>
	  <td>#session.searchCollection.language#</td>
	</tr>
	<tr bgcolor="##dedede">
	  <td>&nbsp;</td>
	  <td><input type="submit" class="btn primary" name="submit" value="Create/Update Index" tabindex="6" /></td>
	</tr>
      </table>
      <input type="hidden" name="collection" value="#session.searchCollection.name#" />
      <input type="hidden" name="type" value="path" />
      <input type="hidden" name="language" value="#session.searchCollection.language#" />
      <input type="hidden" name="collectionAction" value="refresh" />
    </form>
    
    <br />
    
    <form name="webSiteIndexForm" action="_controller.cfm?action=indexSearchCollection" method="post" 
	  onsubmit="javascript:return validateWebSiteIndexForm(this);">
      <table>
	<tr bgcolor="##dedede">
	  <th colspan="2"><h5>Web Site Index</h5></th>
	</tr>
	<tr>
	  <td bgcolor="##f0f0f0">Starting URL</td>
	  <td><input type="text" name="key" id="urlKey" class="span12" tabindex="7" /></td>
	</tr>
	<tr bgcolor="##dedede">
	  <td>&nbsp;</td>
	  <td><input type="submit" class="btn primary" name="submit" value="Create/Update Index" tabindex="8" /></td>
	</tr>
      </table>
      <input type="hidden" name="collection" value="#session.searchCollection.name#" />
      <input type="hidden" name="type" value="website" />
      <input type="hidden" name="language" value="#session.searchCollection.language#" />
      <input type="hidden" name="collectionAction" value="refresh" />
    </form>
  </cfoutput>

  <div id="moreInfo" class="modal hide fade">
    <div class="modal-header">
      <a href="##" class="close">&times;</a>
      <h3>Information Concerning Indexing Search Collections</h3>
    </div>
    <div class="modal-body">
      <ul>
	<li>Search collections may be populated from either a directory path or a full URL.</li>
	<li>
	  Use the Directory Index form to populate the collection using a directory path. Use the 
	  Web Site Index form to populate the collection from a starting URL.
	</li>
	<li>
	  A full physical path starting with "/" (on Unix-based systems) or a full drive path including drive letter 
	  (on Windows systems) may be specified for the directory path in the top form.
	</li>
      </ul>
    </div>
  </div>
  
  <cfset StructDelete(session, "searchCollectionMessage", false) />
  <cfset StructDelete(session, "searchCollection", false) />
</cfsavecontent>
