<cfset request.page.section = "adv">
<cfset request.page.title = "Integrating MongoDB with CFML">
<cfset request.page.desc	= "Integrating MongoDB with OpenBD is extremely easy and fast">

<div class="subnav">
	<div class="container">
		<ul class="breadcrumb">
			<li><a href="./?/advanced">Advanced</a></li>
			<li class="active"><a href="./?/database_mongodb"><cfoutput>#request.page.title#</cfoutput></a></li>
		</ul>
	</div>
</div>


<div class="content" id="content">
	<div class="container cf">

		<h1>MongoDB and CFML</h1>
		
		<cfinclude template="pages/sidebar_advanced.inc" />
		
		<div class="section">

			<p>From the <a href="http://www.mongodb.org/">MongoDB</a> website:</p>
			
			<blockquote>
			MongoDB (from "humongous") is a scalable, high-performance, open source, document-oriented database.
			MongoDB bridges the gap between key-value stores (which are fast and highly scalable) and traditional RDBMS systems (which provide rich queries and deep functionality).
			</blockquote>
			
			<p>
			MongoDB differs from traditional row-column based databases in that data is stored as documents with attributes.  A document can have as many attributes as required, with
			not every document requiring the same amount of attributes.  This makes it extremely efficient for applications that do not have a consistent data requirement.
			</p>
			
			<p>
			In MongoDB, a document is "like" a row of data, except that it doesn't have to contain a constant set of attributes (columns) across all documents.  A collection can be
			thought of like a database table, but unlike a traditional SQL server, you do not need to setup a collection up advance before using it.  A document has a unique index identifier,
			<code>_id</code>.  You do not need to worry about setting this (although you can if you wish).
			</p>
			
			<p>
			The OpenBD CFML application engine has full integration with MongoDB, allowing CFML developers to quickly and easily utilise this powerful database without any fuss or hassle.
			</p>
			
			
			
			<h2>Setting up the Connection</h2>
			
			<p>
			Working with a MongoDB is not unlike working with Amazon SimpleDB.  You register a MongoDB datasource with <a href="./?/function/mongoregister"><code>MongoRegister()</code></a> function
			which accepts a name for the datasource, the remote server IP and port, plus any username/password that has been enabled.
			</p>

<pre class="cfml">&lt;cfscript>
	MongoRegister( name="mongo", server="127.0.0.1", db="openbd" );
	var dbs = MongoDatabaseList( "mongo" );
	WriteDump( dbs );
&lt;/cfscript></pre>
			
			<p>You can later, if you wish, call <a href="./?/function/mongoregister"><code>MongoDeRegister()</code></a> function to remove the datasource from the server.</p>
			
			<p>MongoDB is special compared to the likes of MySQL/SQLServer in that you do not have to set anything up prior to using it.  So here, for example, we are referencing the database
			'openbd' and if that does not exist, MongoDB server will create it there and then.  This is true also of collections.</p>
			
			<p>
			There are a number of operations you can perform on the database, like listing all the databases, dropping databases and you can send commands straight to the server for
			execution.
			</p>
			
			<blockquote>
			<strong>User Configuration Note</strong><br />
			If you are running MongoDB as a remote server and experience problems connecting to databases with an admin user, you may have to create a standard user profile and
			assign relevant database privileges to that user. This is due to some restrictions MongoDB enforces when logging in admin users, where such a user can only initially
			be logged into the admin database before attempting a switch to other databases. MongoRegister does not currently support this switching between databases as it requires
			a static database with which to create the datasource. Therefore using a standard user profile, correctly configured with the relevant database privileges, is recommended.<br /><br />
			You can find out more about user configuration for MongoDB over at <a href="http://www.mongodb.org/display/DOCS/Security+and+Authentication" target="_blank">MongoDB Security and Authentication</a>.
			</blockquote>
			
			<h2>Inserting Documents</h2>

			<p>
			Putting data into the database collection is extremely easy.   Remember, MongoDB is a schema-less data storage.  This means you do not need to setup the structure ahead of your
			data like you do with RDMS SQL databases.   You store what you need, not what you hope to need.</p>
			
			<p>Inserting a set of 100 documents in a collection can be as easy as the example below:</p>
			
<pre class="cfml">&lt;cfloop index="x" from="1" to="100">

  &lt;cfset MongoCollectionInsert( "mongo", "mycoll", {
     name:"Document" & x,
     age:x,
     children : {
       child1 : "name1",
       child2 : "name2",
       child3 : "name3"
     }
   })>

&lt;/cfloop></pre>
			
			<p>As you can see, the natural syntax of CFML JSON makes formatting documents extremely easy. When a document is inserted, the MongoDB assigns it a unique <code>_id</code>
			identifier. This is an alphanumeric key that is assured to be unique and constant for that given document.</p>
			
			<p>
			You can assign any type of attribute to a Document, including inner structures and arrays.  The only limitation is that from MongoDB 1.9, a single document can not be greater
			than 16MB.
			</p>
			
			<h2>Updating Documents</h2>
			
			<p>
			There are a number of ways you can update a document in Mongo.  If you are already working with a previously retrieved object, then you can save it using
			<a href="./?/function/MongoCollectionSave"><code>MongoCollectionSave()</code></a>.
			</p>
			
<pre class="cfml">&lt;cfset MongoCollectionSave("mongo", "mycoll", mydoc, "NORMAL" )></pre>
			
			<p>
			Alternatively you can update only subparts of the document using <a href="./?/function/MongoCollectionUpdate"><code>MongoCollectionUpdate()</code></a>.
			</p>

			<p>
			The different with the <code>upsert</code> method is that if the record does not exist it will be created, otherwise the one that matches will be updated.  Particularly
			handy for handling count situations.
			</p>
			
			
			<h2>Querying Documents</h2>
			
			<p>
			MongoDB comes with its own query language, which is very JSON like in how you describe how you wish to query the data.  Full details can be found on the MongoDB website.
			</p>
			
			<p>
			The example here, pulls back 10 results, starting at 0, whose <code>age</code> attribute is greater or equal to 40.   Any documents that do not have the <code>age</code>
			attribute will not be returned.
			</p>
			
			<pre class="cfml">&lt;cfset results = MongoCollectionFind("mongo", "mycoll", {age: {"$gte":40} }, {}, 0, 10) ></pre>
			
			<p>
			The <code>results</code> object is an array of structures.  In this case the full document is returned, but the second (and currently blank) structure argument can be used to
			define a subset of keys/fields to be returned, rather than the entire document. You can determine how many documents will match your query by first
			calling the <a href="./?/function/MongoCollectionCount"><code>MongoCollectionCount()</code></a> method.
			</p>
			
			
			<h2>Mongo CFML Functions</h2>
			
			<p>
			You can see all the available <a href="./?/function/category/mongo">functions here</a>.
			</p>
			
			<h2>Further Reading</h2>
			
			<p>
			MongoDB is a very powerful server and while it takes a mental shift away from traditional SQL based servers, you will soon discover the power having a MongoDB server
			within your enterprise network will yield.
			</p>
			
			<ul>
				<li><a href="http://www.mongodb.org/">MongoDB Web Site</a></li>
				<li><a href="http://www.mongodb.org/display/DOCS/Home">MongoDB Documentation</a></li>
				<li><a href="http://www.mongodb.org/display/DOCS/Inserting">MongoDB Inserting</a></li>
				<li><a href="http://www.mongodb.org/display/DOCS/Updating">MongoDB Updating</a></li>
				<li><a href="http://www.mongodb.org/display/DOCS/Querying">MongoDB Querying</a></li>
				<li><a href="http://www.mongodb.org/display/DOCS/Indexes">MongoDB Indexes</a></li>
				<li><a href="http://wiki.mongodb.org/display/DOCS/MapReduce">MongoDB Map Reduce</li>
				<li><a href="http://www.mongodb.org/display/DOCS/Aggregation">MongoDB Aggregation</li>
			</ul>

		</div><!--- .section --->

	</div><!--- .container --->
</div><!--- .content --->
