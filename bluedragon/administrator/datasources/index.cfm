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
  <cfparam name="dbDriverRetrievalMessage" type="string" default="" />
  <cfparam name="datasourceRetrievalMessage" type="string" default="" />
  <cfparam name="autoconfigodbc" type="boolean" default="false" />
  <cfparam name="autoConfigODBCRetrievalMessage" type="string" default="" />
  <cfparam name="isWindows" type="boolean" default="false" />
  
  <cfif CompareNoCase(left(Application.datasource.getJVMProperty("os.name"), 7), "windows") == 0>
    <cfset isWindows = true />
  </cfif>
  
  <cfset dbdrivers = [] />
  <cfset datasources = [] />

  <cftry>
    <cfset dbdrivers = Application.datasource.getRegisteredDrivers() />
    <cfcatch type="any">
      <cfset dbDriverRetrievalMessage = CFCATCH.Message />
      <cfset dbDriverRetrievalMessageType = "error" />
    </cfcatch>
  </cftry>
  
  <cfif isWindows>
    <cftry>
      <cfset autoconfigodbc = Application.datasource.getAutoConfigODBC() />
      <cfcatch type="any">
	<cfset autoConfigODBCRetrievalMessage = CFCATCH.Message />
	<cfset autoConfigODBCRetrievalMessageType = "error" />
      </cfcatch>
    </cftry>
  </cfif>
  
  <cftry>
    <cfset datasources = Application.datasource.getDatasources() />
    
    <!--- add the database driver description (if available) and some other placeholder info to the array of datasources --->
    <cfloop index="i" from="1" to="#ArrayLen(datasources)#">
      <cfif datasources[i].databasename == "">
	<cfset datasources[i].driverdescription = "Other" />
	<cfelse>
	  <cfif StructKeyExists(datasources[i], "drivername")>
	    <cftry>
	      <cfset datasources[i].driverdescription = 
		     Application.datasource.getDriverInfo(drivername = datasources[i].drivername).driverdescription />
	      <cfcatch type="any">
		<!--- assume there's a drivername in one of the datasource nodes that we can't pull data on --->
		<cfset datasources[i].driverdescription = "Other" />
	      </cfcatch>
	    </cftry>
	    <cfelse>
	      <cfset datasources[i].driverdescription = "" />
	  </cfif>
      </cfif>
    </cfloop>
    
    <!--- if session.datasourceStatus exists, either one or all datasources are being verified so add that info to the 
	  datasources --->
    <cfif StructKeyExists(session, "datasourceStatus")>
      <cfloop index="i" from="1" to="#ArrayLen(session.datasourceStatus)#">
	<cfloop index="j" from="1" to="#ArrayLen(datasources)#">
	  <cfif session.datasourceStatus[i].name is datasources[j].name>
	    <cfset datasources[j].verified = session.datasourceStatus[i].verified />
	    <cfset datasources[j].message = session.datasourceStatus[i].message />
	  </cfif>
	</cfloop>
      </cfloop>
    </cfif>
    
    <cfcatch type="any">
      <cfset datasourceRetrievalMessage = CFCATCH.Message />
      <cfset datasourceRetrievalMessageType = "error" />
    </cfcatch>
  </cftry>
</cfsilent>
<cfsavecontent variable="request.content">
  <cfoutput>
    <script type="text/javascript">
      function validate(f) {
        var dsn = f.dsn.value;
        var dbType = f.dbType.value;
        // TODO: add a trim function here to check for dsns with only spaces
        if (f.dsn.value.length == 0) {
          alert("Please enter the datasource name");
          return false;
        } else if (f.dbType.value == "") {
          alert("Please select the database type");
          return false;
        } else {
          return true;
        }
      }
      
      function removeDatasource(dsn) {
        if(confirm("Are you sure you want to remove this datasource?")) {
          location.replace("_controller.cfm?action=removeDatasource&dsn=" + dsn);
        }
      }
      
      function resetDBDrivers() {
        if(confirm("Are you sure you want to reset the database driver list to the defaults?")) {
          location.replace("_controller.cfm?action=resetDatabaseDrivers");
        }
      }
      
      function verifyAllDatasources() {
        location.replace("_controller.cfm?action=verifyDatasource");
      }
      
      function refreshODBCDatasources() {
        location.replace("_controller.cfm?action=refreshODBCDatasources");
      }
    </script>
    
    <div class="row">
      <div class="pull-left">
	<h2>Manage Datasources</h2>
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

    <cfif dbDriverRetrievalMessage != "">
      <div class="alert-message #dbDriverRetrievalMessageType# fade in" data-alert="alert">
	<a class="close" href="##">x</a>
	<p>#dbDriverRetrievalMessage#</p>
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
    
    <form name="addDatasource" action="_controller.cfm?action=addDatasource" method="post" 
	  onsubmit="javascript:return validate(this);">
      <table>
	<tr bgcolor="##dedede">
	  <th colspan="2"><h5>Add a Datasource</h5></th>
	</tr>
	<tr>
	  <td bgcolor="##f0f0f0"><label for="dsn">Datasource Name</label></td>
	  <td><input type="text" name="dsn" id="dsn" class="span6" maxlength="50" tabindex="1" /></td>
	</tr>
	<tr>
	  <td bgcolor="##f0f0f0"><label for="datasourceconfigpage">Database Type</label></td>
	  <td>
	    <select name="datasourceconfigpage" id="datasourceconfigpage" class="span6" tabindex="2">
	      <option value="" selected="true">- select -</option>
	      <cfloop index="i" from="1" to="#ArrayLen(dbdrivers)#">
		<option value="#dbdrivers[i].datasourceconfigpage#">#dbdrivers[i].driverdescription#</option>
	      </cfloop>
	    </select>&nbsp;
	    <a href="javascript:void(0);" onclick="javascript:resetDBDrivers()" alt="Reset Database Drivers" title="Reset Database Drivers"><img src="../images/database_gear.png" border="0" width="16" height="16" /></a>
	  </td>
	</tr>
	<tr bgcolor="##dedede">
	  <td>&nbsp;</td>
	  <td><input class="btn primary" type="submit" name="submit" value="Add Datasource" tabindex="3" /></td>
	</tr>
      </table>
    </form>
    
    <hr noshade="true" />

    <h3>Datasources</h3>
    
    <cfif datasourceRetrievalMessage != "">
      <p class="#datasourceRetrievalMessageType#">#datasourceRetrievalMessage#</p>
    </cfif>
    
    <cfif ArrayLen(datasources) == 0>
      <p><strong><em>No datasources configured</em></strong></p>
      <cfelse>
	<table>
	  <tr bgcolor="##dedede">
	    <th style="width:100px;">Actions</th>
	    <th>Datasource Name</th>
	    <th>Description</th>
	    <th>Database Type</th>
	    <th style="width:200px;">Status</th>
	  </tr>
	  <cfloop index="i" from="1" to="#ArrayLen(datasources)#">
	    <tr<cfif !StructKeyExists(datasources[i], "verified")> bgcolor="##ffffff"<cfelseif datasources[i].verified> bgcolor="##ccffcc"<cfelseif !datasources[i].verified> bgcolor="##ffff99"</cfif>>
	      <td>
		<a href="_controller.cfm?action=editDatasource&dsn=#datasources[i].name#" alt="Edit Datasource" title="Edit Datasource"><img src="../images/pencil.png" border="0" width="16" height="16" /></a>
		<a href="_controller.cfm?action=verifyDatasource&dsn=#datasources[i].name#" alt="Verify Datasource" title="Verify Datasource"><img src="../images/accept.png" border="0" width="16" height="16" /></a>
		<a href="javascript:void(0);" onclick="javascript:removeDatasource('#datasources[i].name#');" alt="Remove Datasource" title="Remove Datasource"><img src="../images/cancel.png" border="0" width="16" height="16" /></a>
	      </td>
	      <td><cfif StructKeyExists(datasources[i], "displayname")>#datasources[i].displayname#<cfelse>#datasources[i].name#</cfif></td>
	      <td><cfif StructKeyExists(datasources[i], "description")>#datasources[i].description#<cfelse>&nbsp;</cfif></td>
	      <td>#datasources[i].driverdescription#</td>
	      <td width="200">
		<cfif StructKeyExists(datasources[i], "verified")>
		  <cfif datasources[i].verified>
		    <img src="../images/tick.png" width="16" height="16" alt="Datasource Verified" title="Datasource Verified" />
		    <cfelseif !datasources[i].verified>
		      <img src="../images/exclamation.png" width="16" height="16" alt="Datasource Verification Failed" title="Datasource Verification Failed" /><br />
		      #datasources[i].message#
		  </cfif>
		  <cfelse>
		    &nbsp;
		</cfif>
	      </td>
	    </tr>
	  </cfloop>
	  <tr bgcolor="##dedede">
	    <td colspan="5">
	      <input class="btn primary" type="button" name="verifyAll" value="Verify All Datasources" onclick="javascript:verifyAllDatasources()" 
		     tabindex="4" />
	    </td>
	  </tr>
	</table>
    </cfif>

    <hr noshade="true" />
    
    <cfif isWindows>
      <h3>
	ODBC Datasources&nbsp;
	<a href="javascript:void(0);" onclick="javascript:refreshODBCDatasources();" 
	   alt="Refresh ODBC Datasources" title="Refresh ODBC Datasources">
	  <img src="../images/arrow_refresh.png" width="16" height="16" border="0" />
	</a>
      </h3>
      
      <cfif autoConfigODBCRetrievalMessage != "">
	<p class="#autoConfigODBCRetrievalMessageType#">#autoConfigODBCRetrievalMessage#</p>
      </cfif>
      
      <form name="odbcDatasourcesForm" action="_controller.cfm?action=setAutoConfigODBCDatasources" method="post">
	<table border="0">
	  <tr>
	    <td><strong>Auto-Configure ODBC Datasources?</strong></td>
	    <td>
	      <div class="inline-inputs">
		<input type="radio" name="autoconfigodbc" id="autoconfigodbcTrue" value="true" 
		       <cfif autoConfigODBC>checked="true"</cfif> tabindex="5" />
		<span>Yes</span>
		<input type="radio" name="autoconfigodbc" id="autoconfigodbcFalse" value="false" 
		       <cfif not autoConfigODBC>checked="false"</cfif> tabindex="6" />
		<span>No</span>
	      </div>
	    </td>
	  </tr>
	  <tr>
	    <td>&nbsp;</td>
	    <td><input class="btn primary" type="submit" name="submit" value="Submit" tabindex="7" /></td>
	  </tr>
	</table>
      </form>
      
      <hr noshade="true" />
    </cfif>

    <div id="moreInfo" class="modal hide fade">
      <div class="modal-header">
	<a href="##" class="close">&times;</a>
	<h3>Information Concerning Datasources and Database Drivers</h3>
      </div>
      <div class="modal-body">
	<ul>
	  <li>Use the "Reset Database Drivers" link to reset the available database drivers to the default drivers that ship with OpenBD.</li>
	  <li>
	    If you do not see the database you wish to use listed, obtain JDBC drivers for the database, place the JDBC driver JAR file 
	    in OpenBD's /WEB-INF/lib directory (or the equivalent for your environment), and then use the "Other" database type to 
	    configure the datasource.
	  </li>
	  <li>
	    To connect to Microsoft SQL Server 2000, 2005, or 2008, you may create a datasource using either the 
	    open source <a href="http://jtds.sourceforge.net/" target="_blank">jTDS driver</a> or the Microsoft driver.
	  </li>
	  <li>
	    <a href="http://www.h2database.com" target="_blank">H2</a> is an open source, Java-based embedded database that allows for 
	    the easy creation of databases from within the OpenBD administrator. To create a new H2 database, simply create the datasource 
	    and if the H2 database doesn't exist, it will be created. You may also create datasources pointing to existing H2 embedded 
	    databases.
	  </li>
	  <li>Deleting an H2 Embedded datasource does <em>not</em> delete the database files. These files must be deleted manually.</li>
	  <cfif isWindows>
	    <li>
	      ODBC datasources will be read into OpenBD as datasources if "Auto-Configure ODBC Datasources" is set to "Yes." 
	      Note that the user name and password will <em>not</em> be read into the OpenBD datasource. This information 
	      must be added by editing the datasource.
	    </li>
	    <li>
	      ODBC datasources will be treated as a datasource type of "other."
	    </li>
	  </cfif>
	</ul>
      </div>
    </div>
  </cfoutput>
  <cfset structDelete(session, "dbDriverRetrievalMessage", false) />
  <cfset structDelete(session, "datasourceStatus", false) />
</cfsavecontent>
