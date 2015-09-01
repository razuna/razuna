<p>
	This function makes it easy to read the session data into a table.  For large journal files, it is more efficient to read
	the data into a database to work with.  If you do not have a database handy, you can easily use the embedded database that
	ships with OpenBD, H2 (<a href="http://h2database.com/">http://h2database.com/</a>).
</p>

<p>
	This function will create the underlying table if it does not already exist.  There is a primary key placed on the JOURNAL_ID and ID columns.
</p>

<pre class="cfml">
<cfscript>
if ( !DataSourceIsValid("tmpJournal") ){
  ds = {
    databasename : "Session1",
    drivername : "org.h2.Driver",
    hoststring : "jdbc:h2:file:c:/data/tmpjournal;MODE=MYSQL"
  };

  DataSourceCreate( "tmpJournal", ds );
}

JournalReadToDataSource( datasource="tmpJournal", file="c:/tmp/2015-02-07_11.51.07-34.txt" );
</cfscript>
</pre>
