<cfsilent>
	<cfset request.page.title = "Embedded H2 Database OpenBD">
	<cfset request.page.section = "adv">
	<cfset request.page.desc	= "Using the embedded H2 Relational database that is shipped with OpenBD">
</cfsilent>

<div class="subnav">
	<div class="container">
		<ul class="breadcrumb">
			<li><a href="./?/advanced">Advanced</a></li>
			<li class="active"><a href="./?/embedded_database"><cfoutput>#request.page.title#</cfoutput></a></li>
		</ul>
	</div>
</div>


<div class="content" id="content">
	<div class="container cf">

		<h1>Embedded H2 Database</h1>
		<cfinclude template="pages/sidebar_advanced.inc" />

		<div class="section">

<p>
	If you do not have a database handy, you can easily use the embedded database that
	ships with OpenBD, H2 (<a href="http://h2database.com/">http://h2database.com/</a>).   H2 supports more advanced queries than the likes of the
	QueryOfQueries can offer.
</p>

<p>
	H2 is a fully fledged Java database that can be used either completely in memory, or from disk if you are either memory constraint, or wish
	the database to persist between restarts.   H2 communicates through SQL statements, that you can easily send do using the CFQUERY tag or the QueryRun() function.
</p>

<p>
	You need to first create a datasource that will point to the new database.   H2 uses the 'hoststring' to control the features of the database.
	The details of this can be <a href="http://h2database.com/html/features.html#database_url">found here</a>.   If the database already exists, then
	it will be opened.  If nothing is there, a new database will be created.
</p>

<pre class="cfml">&lt;cfscript&gt;
if ( !DataSourceIsValid("tmpdb") ){
  ds = {
    databasename : "TempDatabase",
    drivername : "org.h2.Driver",
    hoststring : "jdbc:h2:file:c:/data/tmpjournal;MODE=MYSQL"
  };

  DataSourceCreate( "tmpdb", ds );
}

QueryRun( "tmpdb", "CREATE TABLE IF EXISTS table1 (ID INT PRIMARY KEY, NAME VARCHAR(32))" );
QueryRun( "tmpdb", "INSERT INTO table1 (id, name) VALUES (1,'alan')" );
QueryRun( "tmpdb", "INSERT INTO table1 (id, name) VALUES (2,'andy')" );


WriteDump( QueryRun( "tmpdb", "SELECT * FROM table1") );

&lt;/cfscript&gt;

</pre>


<p>
	If you are using a file based database, then files are created in the directory you specified in the hoststring.  Details of what these files are <a href="http://h2database.com/html/features.html#database_file_layout">can be read here</a>
</p>

		</div><!--- .section --->

	</div><!--- .container --->
</div><!--- .content --->
