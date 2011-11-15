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
  <cfparam name="cachingMessage" type="string" default="" />
  <cfparam name="contentCacheMessage" type="string" default="" />
  <cfparam name="queryCacheMessage" type="string" default="" />
  <cfparam name="numFilesInCache" type="numeric" default="-1" />
  <cfparam name="numQueriesInCache" type="numeric" default="-1" />
  
  <cfset fileCacheInfo = SystemFileCacheInfo() />
  
  <cftry>
    <cfset cachingSettings = Application.caching.getCachingSettings() />
    <cfcatch type="bluedragon.adminapi.caching">
      <cfset cachingMessage = CFCATCH.Message />
      <cfset cachingMessageType = "warning" />
    </cfcatch>
  </cftry>
  
  <cftry>
    <cfset numContentInCache = Application.caching.getNumContentInCache() />
    <cfset numContentCacheHits = Application.caching.getContentCacheHits() />
    <cfset numContentCacheMisses = Application.caching.getContentCacheMisses() />
    <cfcatch type="bluedragon.adminapi.caching">
      <cfset contentCacheMessage = CFCATCH.Message />
      <cfset contentCacheMessageType = "warning" />
    </cfcatch>
  </cftry>
  
  <cftry>
    <cfset numQueriesInCache = Application.caching.getNumQueriesInCache() />
    <cfset numQueryCacheHits = Application.caching.getQueryCacheHits() />
    <cfset numQueryCacheMisses = Application.caching.getQueryCacheMisses() />
    <cfcatch type="bluedragon.adminapi.caching">
      <cfset queryCacheMessage = CFCATCH.Message />
      <cfset queryCacheMessageType = "warning" />
    </cfcatch>
  </cftry>
  
  <cfif !StructKeyExists(cachingSettings, "cfcachecontent")>
    <cfset cachingSettings.cfcachecontent = {} />
  </cfif>
  
  <cfif !StructKeyExists(cachingSettings.cfcachecontent, "datasource")>
    <cfset cachingSettings.cfcachecontent.datasource = "" />
  </cfif>
  
  <cfif !StructKeyExists(cachingSettings.cfcachecontent, "total")>
    <cfset cachingSettings.cfcachecontent.total = 1000 />
  </cfif>

  <cftry>
    <cfset datasources = Application.datasource.getDatasources() />
    <cfcatch type="bluedragon.adminapi.datasource">
      <cfset datasources = [] />
    </cfcatch>
  </cftry>
</cfsilent>
<cfsavecontent variable="request.content">
  <cfoutput>
    <script type="text/javascript">
      function validateCacheStatusForm(f) {
        var cbxCount = 0;
      
        for (var i = 0; i < f.cacheToFlush.length; i++) {
          if (f.cacheToFlush[i].checked) {
            cbxCount++;
          }
        }
			  
        if (cbxCount == 0) {
          alert("Please select at least one cache to flush");
          return false;
        } else {
          if(confirm("Are you sure you want to flush the selected caches?")) {
            return true;
          } else {
            return false;
          }
        }
      }
			  
      function validateFileCacheForm(f) {
        if (f.maxfiles.value != parseInt(f.maxfiles.value)) {
          alert("Please enter a numeric value for file cache size. If no caching is desired, please enter 0.");
          return false;
        } else {
          return true;
        }
      }
			  
      function validateQueryCacheForm(f) {
        if (f.cachecount.value != parseInt(f.cachecount.value)) {
          alert("Please enter a numeric value for query cache size. If no caching is desired, please enter 0.");
          return false;
        } else {
          return true;
        }
      }
			  
      function validateCFCacheContentForm(f) {
        if (f.total.value.length == 0 || 
          f.total.value != parseInt(f.total.value) || 
          f.total.value <= 0) {
            alert("Item Cache Size must be a numeric value greater than 0.");
            return false;
        } else {
          return true;
        }
      }
    </script>
    
    <div class="row">
      <div class="pull-left">
	<h2>Caching</h2>
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

    <cfif cachingMessage != "">
      <div class="alert-message #cachingMessageType# fade in" data-alert="alert">
	<a class="close" href="##">x</a>
	<p>#cachingMessage#</p>
      </div>
    </cfif>

    <cfif contentCacheMessage != "">
      <div class="alert-message #contentCacheMessageType# fade in" data-alert="alert">
	<a class="close" href="##">x</a>
	<p>#contentCacheMessage#</p>
      </div>
    </cfif>

    <cfif queryCacheMessage != "">
      <div class="alert-message #queryCacheMessageType# fade in" data-alert="alert">
	<a class="close" href="##">x</a>
	<p>#queryCacheMessage#</p>
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

    <form name="cacheStatusForm" action="_controller.cfm?action=processFlushCacheForm" method="post" 
	  onsubmit="javascript:return validateCacheStatusForm(this);">
      <table>
	<tr bgcolor="##dedede">
	  <td colspan="5"><h5>Cache Status</h5></td>
	</tr>
	<tr bgcolor="##f0f0f0">
	  <th style="width:200px;">Cache</th>
	  <th style="width:180px;">Size</th>
	  <th>Hits</th>
	  <th>Misses</th>
	  <th style="width:60px;">Flush</th>
	</tr>
	<tr>
	  <td bgcolor="##f0f0f0"><label for="cacheToFlushFile">File (<a href="filecachedetails.cfm">details</a>)</label></td>
	  <td bgcolor="##ffffff">#fileCacheInfo.size#</td>
	  <td bgcolor="##ffffff">#fileCacheInfo.hits#</td>
	  <td bgcolor="##ffffff">#fileCacheInfo.misses#</td>
	  <td bgcolor="##f0f0f0" style="width:80px;text-align:center;">
	    <input type="checkbox" name="cacheToFlush" id="cacheToFlushFile" value="file" tabindex="1" />
	  </td>
	</tr>
	<tr>
	  <td bgcolor="##f0f0f0"><label for="cacheToFlushQuery">Query</label></td>
	  <td bgcolor="##ffffff">#numQueriesInCache#</td>
	  <td bgcolor="##ffffff">#numQueryCacheHits#</td>
	  <td bgcolor="##ffffff">#numQueryCacheMisses#</td>
	  <td bgcolor="##f0f0f0" style="text-align:center;">
	    <input type="checkbox" name="cacheToFlush" id="cacheToFlushQuery" value="query" tabindex="2" />
	  </td>
	</tr>
	<tr>
	  <td bgcolor="##f0f0f0"><label for="cacheToFlushContent">Content</label></td>
	  <td bgcolor="##ffffff">#numContentInCache#</td>
	  <td bgcolor="##ffffff">#numContentCacheHits#</td>
	  <td bgcolor="##ffffff">#numContentCacheMisses#</td>
	  <td bgcolor="##f0f0f0" style="text-align:center;">
	    <input type="checkbox" name="cacheToFlush" id="cacheToFlushContent" value="content" tabindex="3" />
	  </td>
	</tr>
	<tr>
	</tr>
	<tr bgcolor="##dedede">
	  <td colspan="5">
	    <div class="pull-right">
	      <input class="btn primary" type="submit" name="submit" value="Flush Checked Caches" tabindex="4" />
	    </div>
	  </td>
	</tr>
      </table>
    </form>
    
    <br />
    
    <form name="fileCacheForm" action="_controller.cfm?action=processFileCacheForm" method="post" 
	  onsubmit="javascript:return validateFileCacheForm(this);">
      <table>
	<tr bgcolor="##dedede">
	  <td colspan="2"><h5>File Cache Settings</h5></td>
	</tr>
	<tr>
	  <td bgcolor="##f0f0f0" style="width:240px;"><label for="maxfiles">File Cache Size</label></td>
	  <td bgcolor="##ffffff">
	    <input class="span2" type="text" name="maxfiles" id="maxfiles" maxlength="4" 
		   value="#cachingSettings.file.maxfiles#" tabindex="5" /> files
	  </td>
	</tr>
	<tr>
	  <td bgcolor="##f0f0f0"><label>Trust Cache</label></td>
	  <td bgcolor="##ffffff">
	      <div class="inline-inputs">
		<input type="radio" name="trustcache" id="trustcacheTrue" value="true"<cfif cachingSettings.file.trustcache> checked="true"</cfif> tabindex="6" />
		<span>Yes</span>
		<input type="radio" name="trustcache" id="trustcacheFalse" value="false"<cfif !cachingSettings.file.trustcache> checked="true"</cfif> tabindex="7" />
		<span>No</span>
	      </div>
	  </td>
	</tr>
	<tr bgcolor="##dedede">
	  <td>&nbsp;</td>
	  <td><input class="btn primary" type="submit" name="submit" value="Submit" tabindex="8" /></td>
	</tr>
      </table>
    </form>
    
    <br />
    
    <form name="queryCacheForm" action="_controller.cfm?action=processQueryCacheForm" method="post" 
	  onsubmit="javascript:return validateQueryCacheForm(this);">
      <table>
	<tr bgcolor="##dedede">
	  <td colspan="2"><h5>Query Cache Settings</h5></td>
	</tr>
	<tr>
	  <td bgcolor="##f0f0f0" style="width:240px;"><label for="cachecount">Query Cache Size</label></td>
	  <td bgcolor="##ffffff">
	    <input class="span2" type="text" name="cachecount" id="cachecount" maxlength="4" 
		   value="#cachingSettings.cfquery.cachecount#" tabindex="9" /> queries
	  </td>
	</tr>
	<tr bgcolor="##dedede">
	  <td>&nbsp;</td>
	  <td><input class="btn primary" type="submit" name="submit" value="Submit" tabindex="10" /></td>
	</tr>
      </table>
    </form>
    
    <br />
    
    <form name="cfcachecontentForm" action="_controller.cfm?action=processCFCacheContentForm" method="post" 
	  onsubmit="javascript:return validateCFCacheContentForm(this);">
      <table>
	<tr bgcolor="##dedede">
	  <td colspan="2"><h5>CFCACHECONTENT Settings</h5></td>
	</tr>
	<tr>
	  <td bgcolor="##f0f0f0" style="width:240px;">
	    <label for="total">Item Cache Size</label>
	  </td>
	  <td bgcolor="##ffffff">
	    <input class="span2" type="text" name="total" id="total" maxlength="5" 
		   value="#cachingSettings.cfcachecontent.total#" tabindex="11" />
	  </td>
	</tr>
	<tr>
	  <td bgcolor="##f0f0f0" align="right">
	    <label for="datasource">Datasource</label>
	  </td>
	  <td bgcolor="##ffffff">
	    <select name="datasource" id="datasource" tabindex="12">
	      <option value=""<cfif cachingSettings.cfcachecontent.datasource == ""> selected="true"</cfif>>- select -</option>
	      <cfif ArrayLen(datasources) gt 0>
		<cfloop index="i" from="1" to="#ArrayLen(datasources)#">
		  <option value="#datasources[i].name#"<cfif cachingSettings.cfcachecontent.datasource == datasources[i].name> selected="true"</cfif>>#datasources[i].name#</option>
		</cfloop>
	      </cfif>
	    </select>
	  </td>
	</tr>
	<tr bgcolor="##dedede">
	  <td>&nbsp;</td>
	  <td><input class="btn primary" type="submit" name="submit" value="Submit" tabindex="13" /></td>
	</tr>
      </table>
    </form>

    <div id="moreInfo" class="modal hide fade">
      <div class="modal-header">
	<a href="##" class="close">&times;</a>
	<h3>Information Concerning Caching</h3>
      </div>
      <div class="modal-body">
	<ul>
	  <li>
	    The datasource setting for CFCACHECONTENT indicates the datasource in which items will be stored 
	    after the value of Item Cache Size is exceeded. The value of Item Cache Size must be a 
	    numeric value greater than 0.
	  </li>
	</ul>
      </div>
    </div>
  </cfoutput>
</cfsavecontent>
