<p>
The following shows an example of creating a datasource using CFML.
</p>

<pre class="cfml">
<cfscript>
if ( !DataSourceIsValid("myds") ){
	var ds = {
		username : "user1",
		password : "password1",
		databasename : "MyDatabase",
		drivername : "org.gjt.mm.mysql.Driver",
		hoststring : "jdbc:mysql://8.8.8.8/MyDatabase?useUnicode=true&amp;characterEncoding=UTF-8"
	};

	DataSourceCreate( "myds", ds );
}
</cfscript>
</pre>