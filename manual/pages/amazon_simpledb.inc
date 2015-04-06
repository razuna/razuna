<cfsilent>
	<cfset request.page.title = "Amazon SimpleDB with OpenBD">
	<cfset request.page.section = "adv">
	<cfset request.page.desc	= "Accessing and integrating Amazon SimpleDB service into OpenBD is very easy">
</cfsilent>

<div class="subnav">
	<div class="container">
		<ul class="breadcrumb">
			<li><a href="./?/advanced">Advanced</a></li>
			<li class="active"><a href="./?/amazon_simpledb"><cfoutput>#request.page.title#</cfoutput></a></li>
		</ul>
	</div>
</div>


<div class="content" id="content">
	<div class="container cf">

		<h1>Amazon SimpleDB Integration</h1>
		
		<cfinclude template="pages/sidebar_advanced.inc" />
		
		<div class="section">

<p><a href="http://aws.amazon.com/simpledb/"><img class="right" src="http://g-ecx.images-amazon.com/images/G/01/00/10/00/14/19/27/100014192753._V46777512_.gif"></a>
As you may already be aware, Amazon do a little more than just sell books.  They have quietly and slowly changing
the way we think of web services and cloud computing.  With their ondemands servers (EC2), unlimited file storage (S3),
 messaging (SQS), databases (SimpleDB) they are truely making us all rethink how we architect tomorrows systems.</p>

<p>
Amazon's SimpleDB service, is a system for storing and querying data without any consideration for scaling and storage.
You just use it.  Priced like all their other systems, the more you use the more you pay.
</p>

<p>
Like all of Amazon's web services this is another powerful tool to add to their arsenal, and now you as a CFML
developer can easily get at this service through OpenBD's CFQUERY extension.
</p>

<h2>Amazon Simple DB Basics</h2>

<p>
Amazon SimpleDB is not a true relational database.  Instead you can think of it as a series of Hashtables, stored in
a single domain.   A <strong>domain</strong> in the Amazon-speak is not dissimilar to a table in SQL, where their
<strong>Item</strong> is close in thinking to a row.  In a traditional database, you have a fixed number of columns per
table, but in Amazon thats not the case, you can have up to 255 <strong>attributes</strong> (or columns) in a row and
do not all have to be defined.
</p>

<p>
There is also no concept of a table/domain definition.  You just add/delete data, with the assumption that you provide
a unique identifier for each row or Item.   Another small gotcha is that all your data is stored as literal strings.
So 10 would be stored as "10".  The only time you need to worry about that is when doing less-than greater-than queries,
as they would be performed at a lexical level.
</p>

<ul>
<li>Amazon stores data in Domains then Items, with each item having any number of attributes
</li><li>Maximum of 100 domains per user account
</li><li>Maximum of 10GB per domain
</li><li>All data is stored as strings; got to be careful when doing ItemA &gt; ItemB as its lexical comparisons not numeric (ie pad out numbers)
</li><li>No individual item can be over 1k in size
</li><li>Maximum attributes per row/item is 255
</li><li>Each row has a unique ID (ItemName)
</li></ul>

<p>
Pricing for Amazon SimpleDB can be <a href="http://aws.amazon.com/simpledb/">found here</a>,
but they charge per-GB on data going in and out, and the amount of CPU time your query takes.
</p>

<h2>CFML Integration</h2>

<p>
Getting access to this functionality is very easy with OpenBD.  We've added Simple DB functionality to our official
engine that is available for use.  When looking at providing access to this service, we debated whether it should be a set of
functions, new set of tags or something else.  The answer was staring us all in the face; <a href="./?/tag/CFQUERY">CFQUERY</a>.
</p>

<p>
CFQUERY is of course the CFML window into data storage, and the original creators of this tag already had built in
future extensibility by the utilising the <b>dbtype=""</b> attribute.  Historically only really used to differientiate
between a SQL Query and a Query-of-Queries query.  So we added a new dbtype; <b>amazon</b>.
</p>

<p>This lets you build INSERT / DELETE / SELECT statements for accessing data sitting inside of Amazon SimpleDB.</p>

<p>
If that wasn't cool and easy enough, the real side effect of using CFQUERY for your Amazon SimpleDB API
is that it literally saves you money.  For each request you make of Amazon SimpleDB, it costs money.  But by
utilising the inbuilt query caching of CFQUERY (including the OpenBD caching enhancements) you
don't need to query Amazon half as much as you would normally would.
</p>

<p>
Lets look at some sample code, and how else OpenBD helps you interact with Amazon SimpleDB.
</p>

<h2>Sample Code</h2>

<p>First of all, we didn't get away with not implementing some functions.  These were purely to assist in the creation of
the Amazon datasource and the high level management of domains.</p>

<pre class="cfml">&lt;cfset amazonDS = AmazonRegisterDataSource( "MyIdentifier", awsAccessId, awsSecretKey )&gt;

&lt;cfset AmazonSimpleDbCreateDomain( amazonDS, "mydomain" )&gt;
&lt;cfset AmazonSimpleDbDeleteDomain( amazonDS, "mydomain" )&gt;
&lt;cfset qry = AmazonSimpleDbListDomains( amazonDS )&gt;
</pre>

<p>The first function <a href="./?/function/amazonregisterdatasource">AmazonRegisterDataSource()</a> sets up the Amazon datasource, and once done you won't
need to do it again.  You don't even need to keep a reference to it, because all that is returned is a String object that will be your reference to it.  This call takes in your two Amazon AWS access codes which opens up the world of Amazon to you.</p>

<p>To create a new domain you simple call <a href="./?/function/AmazonSimpleDbCreateDomain">AmazonSimpleDbCreateDomain()</a> passing in
the Amazon datasource and the name you want your domain to be.  Similiarly deleting the domain is performed
using the <a href="./?/function/AmazonSimpleDbDeleteDomain">AmazonSimpleDbDeleteDomain()</a> function.  You can get a CFML query back of all your current domains by
calling <a href="./?/function/AmazonSimpleDbListDomains">AmazonSimpleDbListDomains()</a>.</p>

<h2>Inserting data</h2>

<p>
Let us start by inserting data into our domain.  We are all familiar with the INSERT syntax for SQL, so you'll
be able to dump data straight into your Amazon SimpleDB very quickly.
</p>

<pre class="cfml">&lt;cfquery dbtype="amazon" datasource="#amazonDS#"&gt;
  insert into mydomainname (ItemName, "name", "age") values (
  'MyUniqueName',
  &lt;cfqueryparam value="#session.name#"&gt;,
  &lt;cfqueryparam value="#session.age#"&gt;)
&lt;/cfquery&gt;
</pre>

<p>
As you can see, it is a standard INSERT statement, complete with <a href="./?/tag/CFQUERYPARAM">CFQUERYPARAM</a> tags to help you format your data.
Please note though, when inserting you will need to provide in the column list, <b>ItemName</b>.  This is the unique
identifier, or index, for you row.  If the row already exists, then the attritbute columns are overwritten.
</p>

<h2>Deleting data</h2>

<p>
Deleting data is equally as painless, except there are two types of deletes.  You can delete an attribute from a
given row, or you can delete the complete row.  Remember, Amazon charges you for the data, whether you use it or not,
so the ability to delete a given column in a given row is very powerful (and cost effective!).
</p>

<pre class="cfml">&lt;cfquery dbtype="amazon" datasource="#amazonDS#"&gt;
  delete from mydomainname
  where ItemName='myrowid'
  [AND ItemAttribute='myattribute']
&lt;/cfquery&gt;
</pre>

<p>
So here you can see you either delete the whole row by specifying the unique id to the <b>ItemName</b> column,
or you delete a specific attribute using the <b>ItemAttribute</b> keyword.
</p>

<p>
Note, Amazon does warn that due to the way their system operates and synchronizes, if you do an add or delete of
data, then it may not be immediately available if you query for it straight after.   In practice though,
we haven't noticed this.
</p>

<h2>Selecting data</h2>

<p>
So now that you have data sitting within Amazon SimpleDB, you will no doubt want to pull it back out.  This is done
with the SELECT statement, within a <a href="./?/tag/CFQUERY">CFQUERY</a> tag.  Remember, you can utilise the caching techniques of CFQUERY
to increase performance.
</p>

<pre class="cfml">&lt;cfquery dbtype="amazon" datasource="#amazonDS#" name="qry"&gt;
  select * from ItemAttribute
  where domain='mydomain' and ItemName='myrowid'
&lt;/cfquery&gt;
</pre>

<p>
Here we are pulling back all the attributes for a given item or row.  This will be a single row query.
This may seem a little strange, but this maps onto how Amazon manage their data.
</p>

<p>
So the question becomes, what <b>ItemName</b>'s do I need to pull back based on a given criteria or query.  You
can easily determine using the following SELECT statement.
</p>

<pre class="cfml">&lt;cfquery dbtype="amazon" datasource="#amazonDS#" name="qry"&gt;
  select ItemName,NextToken from mydomain
  where [Amazon Query]
  limit [nexttoken,],5
&lt;/cfquery&gt;
</pre>

<p>
This one may require a little explanation as its more of an Amazon issue.  Amazon has no real notion of paging
results.  You can get a maximum of 250 items back in one go, and to get the next set you must pass back a
special token that will allow Amazon to get you the next set.  This token is taken from the previous query resultset.
</p>

<p>
Querying the data, you use Amazon's <a href="http://docs.amazonwebservices.com/AmazonSimpleDB/2007-11-07/DeveloperGuide/SDB_API_Query.html">special query language</a>,
which isn't dissimilar to how some SQL databases format their commands.</p>

<p>
For example, in our example, to query for all people that are in their 20's we would write the following.
</p>

<pre class="cfml">&lt;cfquery dbtype="amazon" datasource="#amazonDS#" name="qry"&gt;
  select ItemName,NextToken from mydomain
  where ['age'&gt;'19' AND 'age'&lt;'30']
  limit 100
&lt;/cfquery&gt;
</pre>

<p>
Recall we said that all data is stored as pure string's.  This means your queries may look a little strange at
first.  But you soon get use to it.
</p>

<p>
However, you may be wondering how you can manage numbers of unequal length.  We've added a new attribute to
<a href="./?/tag/CFQUERYPARAM">CFQUERYPARAM</a>, called PADDING="" that lets you specify the number of leading zero's to a number if the value passed in is a number.
</p>

<p>
If you use the <a href="./?/tag/CFQUERYPARAM">CFQUERYPARAM</a> for inserting your data, OpenBD will figure out the best way to represent your data
within Amazon SimpleDB so querying for it doesn't cause any bizarre side effects.  For example, date objects
can cause problems if not careful.  Best to stick to using <a href="./?/tag/CFQUERYPARAM">CFQUERYPARAM</a>.
</p>

<h2>Other Functions for Simple DB</h2>

<p>
There are functions that let you operate with all of the services provided by SimpleDB.
</p>

<table align="center" cellpadding="5" cellspacing="0" width="90%">
<thead>
	<tr>
		<th>Function Name</th>
		<th>Description</th>
	</tr>
</thead>
<tbody>
	<tr>
		<td align="right" nowrap="nowrap" width="1%"><a href="./?/function/amazonsimpledbcreatedomain">AmazonSimpledbCreateDomain</a></td>
		<td>Creates a new SimpleDB domain for storing data</td>
	</tr><tr>
		<td align="right" nowrap="nowrap" width="1%"><a href="./?/function/amazonsimpledbdeleteattribute">AmazonSimpledbDeleteAttribute</a></td>
		<td>Deletes the attribute (and optional value) from the ItemName inside the domain</td>
	</tr><tr>
		<td align="right" nowrap="nowrap" width="1%"><a href="./?/function/amazonsimpledbdeletedomain">AmazonSimpledbDeleteDomain</a></td>
		<td>Deletes a SimpleDB domain, removing all data immediately</td>
	</tr><tr>
		<td align="right" nowrap="nowrap" width="1%"><a href="./?/function/amazonsimpledbgetattributes">AmazonSimpledbGetAttributes</a></td>
		<td>Gets all the attributes for the given domain and ItemName.  Supports the consistentread flag of SimpleDB.</td>
	</tr><tr>
		<td align="right" nowrap="nowrap" width="1%"><a href="./?/function/amazonsimpledblistdomains">AmazonSimpledbListDomains</a></td>
		<td>Lists all the domains within this datasource</td>
	</tr><tr>
		<td align="right" nowrap="nowrap" width="1%"><a href="./?/function/amazonsimpledbsetattribute">AmazonSimpledbSetAttribute</a></td>
		<td>Sets the attribute (and optional value) to the ItemName inside the domain</td>
	</tr><tr>
		<td align="right" nowrap="nowrap" width="1%"><a href="./?/function/amazonsimpledbsetstruct">AmazonSimpledbSetStruct</a></td>
		<td>Sets all the attributes in data to the ItemName in domain</td>
	</tr>
</tbody>
</table>

		</div><!--- .section --->

	</div><!--- .container --->
</div><!--- .content --->