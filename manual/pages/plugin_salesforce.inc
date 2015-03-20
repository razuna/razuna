<cfset request.page.section = "plugins">
<cfset request.page.title = "Salesforce Plugin">
<cfset request.page.desc	= "Salesforce plugin makes it really easy and quick interacting with Salesforce without the overhead">

<div class="subnav">
  <div class="container">
    <ul class="breadcrumb">
      <li><a href="./?/plugin">Plugins</a></li>
      <li class="active"><a href="./?/plugin_salesforce"><cfoutput>#request.page.title#</cfoutput></a></li>
    </ul>
  </div>
</div>


<div class="content" id="content">
	<div class="container cf">

		<h1>Salesforce Plugin</h1>
		
		<cfinclude template="pages/sidebar_plugin.inc" />
		
		<div class="section">
		
<p>The openBD Salesforce plugin lets you quickly and easily send queries to the <a href="https://www.salesforce.com/" title="www.salesforce.com/">Salesforce</a> platform. You can also create, update, get descriptions of and delete objects, including custom ones through this API.</p>

<p>The following information and code snippets are derived from the updating of a custom web application to use this plugin over another Salesforce driver. In fact it was <em>this</em> application which spawned the development of the OpenBD Salesforce Plugin in the first place. </p>

<h2>Overview of functions</h2>

<table class="zebra-striped">
<thead>
	<tr>
		<th>Function Name</th>
		<th>Description</th>
	</tr>
</thead>
<tbody>
	<tr>
		<td width="1%" nowrap align="right"><a href="./?/function/salesforcecreate">SalesforceCreate</a></td>
		<td>Inserts a new Object into Salesforce, returning the new ID that was created</td>

	</tr><tr>
		<td width="1%" nowrap align="right"><a href="./?/function/salesforcedelete">SalesforceDelete</a></td>
		<td>Deletes the object within Salesforce at the given Id</td>
	</tr><tr>
		<td width="1%" nowrap align="right"><a href="./?/function/salesforcedescribe">SalesforceDescribe</a></td>
		<td>Retrieves the information about the object</td>
	</tr><tr>

		<td width="1%" nowrap align="right"><a href="./?/function/salesforcequery">SalesforceQuery</a></td>
		<td>Executes a query against Salesforce, caching the result if necessary</td>
	</tr><tr>
		<td width="1%" nowrap align="right"><a href="./?/function/salesforceupdate">SalesforceUpdate</a></td>
		<td>Updates the Object type with the given Id to the values in the fields.  If the fields already exist they are overwritten</td>
	</tr>
</tbody>
</table>

<p>To use any of the Salesforce plugin functions, you'll need the account Username, Password, and Salesforce Security Token.  A handy tip would be to set these as variables in the application scope, as the security token expires after 90 days.</p>

<p><span class="label notice">Please note:</span> all the following CFML snippets will assumed to be used inside CFSCRIPT unless otherwise stated.</p>

<h2>SalesforceCreate</h2>
<p><code>SalesforceCreate( username, password, type, fields );</code></p>

<p>Creating records is really straightforward, just specify the Object (<code>type</code>) you wish to insert into, and the Fields you wish to populate in the form of a structure. It's worth re-iterating that case matters, so if the Object name is Account, write it as such, don't convert case or your insert might not work.</p>

<p>Here's some sample code for creating a record in the Salesforce 'Task' object, making the assumption you'll be passing variables into the field structure.</p>

<pre>
username = "yourSFusername";
password = "yourSFpasswordAndSFSecurityTokenCombined";
type = "Task";
fields = {
  RecordTypeId : RecordTypeIdValue,
  Subject : SubjectValue,
  Description : DescriptionValue,
  ActivityDate : ActivityDateValue,
  Status : StatusValue,
  Priority : PriorityValue,
  OwnerId : OwnerIdValue,
  Type : TypeValue,	
  WhatId : WhatIdValue,
  WhoId : WhoIdValue
 };
createRecord = SalesforceCreate(username, password, type, fields);
return createRecord;  // the function returns a string containing the id of the new record
</pre>

<h2>SalesforceDelete</h2>
<p><code>SalesforceDelete( username, password, id );</code></p>

<p>Quite self explanatory this one, all you need is the id of the record you wish to delete. Use with caution, once it's gone it's gone!</p>

<pre>
username = "yourSFusername";
password = "yourSFpasswordAndSFSecurityTokenCombined";
id = "objectIdValue";
deleteObject = SalesforceDelete(username, password, id);
</pre>


<h2>SalesforceDescribe</h2>
<p><code>SalesforceDescribe( username, password, type );</code></p>

<p>Finding out details about a particular object can be useful, particularly when it comes to creating and updating records. <code>SalesforceDescribe()</code> will get you the information on all the columns in the object quickly and easily, just pass in the Object name (<code>type</code>) and you're there. </p>

<pre>
username = "yourSFusername";
password = "yourSFpasswordAndSFSecurityTokenCombined";
type = "Task";
describeObject = SalesforceDescribe(username, password, type);

writeDump(describeObject); 
</pre>

<h2>SalesforceQuery</h2>
<p><code>SalesforceQuery( username, password, soql, cache );</code></p>

<p>Querying Salesforce is easy, especially if you use <a href="http://wiki.developerforce.com/index.php/ForceExplorer" title="wiki.developerforce.com/index.php/ForceExplorer">force.com explorer</a> to build the queries first. This is a good thing to do if you're not too familiar with the column names you're dealing with.</p>

<p>Salesforce uses <a href="http://www.salesforce.com/us/developer/docs/api/index_Left.htm#CSHID=sforce_api_calls_soql.htm|StartTopic=Content%2Fsforce_api_calls_soql.htm|SkinName=webhelp" title="Salesforce Object Query Language(SOQL)">SOQL</a>, Salesforce Object Query Language, which is similar to but perhaps not quite as comprehensive as SQL.</p>

<blockquote><p>SOQL does not support all advanced features of the SQL SELECT command. For example, you cannot use SOQL to perform arbitrary join operations, use wildcards in field lists, or use calculation expressions.</p><small>Salesforce.com</small></blockquote>

<p>It's worth noting the way queries are returned by the plugin differs from <code>cfquery</code> in that what is returned depends on the content in the object.</p>

<p>For example, if a particular column in your query contains no data, the column itself won't be returned, so any checking you do at the presentation end has to be modified accordingly to account for this, i.e. use <code>StructKeyExists(qry, "data")</code> to check the data is there rather than <code>len(qry.data) != 0</code> to avoid errors.</p>

<p>Query cache is set by adding the time you want the cache to last in seconds, the default is 0. As with the username and password, you may want to define a standard cache value in the application scope.</p>

<p>The SalesforceQuery() function does not support the use of <code>cfqueryparam</code>.</p>

<p>Here's an example of a simple Salesforce query of the 'Contact' object.</p>

<pre>
username = "yourSFusername";
password = "yourSFpasswordAndSFSecurityTokenCombined";
cache = "3600";

soql = "SELECT AccountId, Company_Name__c, Id, Email, FirstName, Formal_Title__c, Full_Name__c, Group_Primary__c, LastName, City__c, RecordTypeId FROM Contact";

query = SalesforceQuery( username, password, soql, cache );

// in a cfc or function context 
return query; 

// or if you just want to see it
writeDump(query); 
</pre>

<p>This next example shows a SOQL query of the 'Account' object with a simple join to the 'Contact' object.  This will most likely return duplicate records, and is merely here to illustrate the syntax.  Queries like this are referred to as <a href="http://www.salesforce.com/us/developer/docs/api/index_Left.htm#CSHID=sforce_api_calls_soql_relationships.htm|StartTopic=Content%2Fsforce_api_calls_soql_relationships.htm|SkinName=webhelp" title="SOQL Relationship Queries">Relationship Queries</a>.</p>

<pre>
soql = "SELECT Id, Name, Industry, (SELECT AccountId, Id, Bio__c, Email, Formal_Title__c, Full_Name__c FROM Contact__r WHERE AccountId = Account.Id) FROM Account";
</pre>

<p>Alternatively you can make use of more sophisticated SQL syntax by joining your SalesforceQuery results using Query of Queries, this is useful to cut down the number of calls to Salesforce, and if the data you're querying is appropriate for cacheing.</p>

<pre>
newQuery = queryOfQueryRun( sql="SELECT * FROM query, anotherQuery WHERE query.AccountId = anotherQuery.Id" );
</pre>

<p>Find more information on SOQL in the <a href="http://www.salesforce.com/us/developer/docs/api/index_Left.htm#CSHID=sforce_api_calls_soql.htm|StartTopic=Content%2Fsforce_api_calls_soql.htm|SkinName=webhelp" title="Salesforce Object Query Language(SOQL)">Salesforce developer manual</a></p>

<h2>SalesforceUpdate</h2>
<p><code>SalesforceUpdate( username, password, type, id, fields );</code></p>

<p>Updating records is easy, too.  All you need in addition to the Object name (type) and the struct of Fields is the ID of the object you wish to update.</p>

<p>Some fields are updatable, some are not.  If your update fails, it's worth checking this using <code>SalesforceDescribe()</code>. You can also check the properties of an object and its fields easily in <a href="http://wiki.developerforce.com/index.php/ForceExplorer" title="wiki.developerforce.com/index.php/ForceExplorer">force.com explorer</a>.</p>

<p><span class="label new">Tip:</span> if you need to overwrite data with a blank (null) value, pass in a space i.e. <code>fieldVal : " ";</code> because <code>fieldVal : "";</code> won't overwrite what's already in the cell.</p>

<pre>
username = "yourSFusername";
password = "yourSFpasswordAndSFSecurityTokenCombined";
type = "Task";
id = objectIdValue;
fields = {
  RecordTypeId : RecordTypeIdValue,
  Subject : SubjectValue,
  Description : DescriptionValue,
  ActivityDate : ActivityDateValue,
  Status : StatusValue,
  Priority : PriorityValue,
  OwnerId : OwnerIdValue,
  Type : TypeValue,	
  WhatId : WhatIdValue,
  WhoId : WhoIdValue
 };
updateRecord = SalesforceCreate(username, password, type, id, fields);
</pre>

<h2>Resources</h2>
<p>An invaluable tool to get to grips with SOQL and the data you are dealing with is <a href="http://wiki.developerforce.com/index.php/ForceExplorer" title="wiki.developerforce.com/index.php/ForceExplorer">force.com explorer</a>.</p>
<blockquote><p>"This handy tool lets you browse your database schema, custom objects and fields, and build and test SOQL queries.</p><small>developerforce.com</small></blockquote>

<p>There is a <a href="http://www.salesforce.com/us/developer/docs/api/index_Left.htm#StartTopic=Content/sforce_api_quickstart_steps.htm" title="Salesforce Developer Manual">full developer manual</a> for all things Salesforce.</p>

<p>We also have detailed information on <a href="./?/webservices_salesforce" title="web services using SalesForce">Web Services using Salesforce with OpenBD</a> in the Advanced section of the manual.</p>

<p>As with all OpenBD plugins, download the <a href="http://openbd.org/download/nightly/openbdplugin-salesforce.jar" title="download the openBD Salesforce Plugin">openbdplugin-salesforce.jar</a> and drop it into your applications' /WEB-INF/lib folder and you're good to go.</p>

<p>All comments and suggestions for improvement of this page are warmly invited and can be posted in our <a href="http://groups.google.com/group/openbd" title="OpenBD Google Discussion Group">OpenBD Google Discussion Group</a></p>

		</div><!--- .section --->

	</div><!--- .container --->
</div><!--- .content --->