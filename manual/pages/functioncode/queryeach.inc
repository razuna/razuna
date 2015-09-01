<p>
You can easily iterate over the rows of the query by using the QueryEach() function or the .each() feature.
</p>

<pre class="cfml">
<cfscript>
// Create a sample query; but this could be from a database
qry = QueryNew( 'name' );
QueryAddrow( qry, 1 );
QuerySetCell( qry, 'name', 'Andy' );
QueryAddRow( qry, 1 );
QuerySetCell( qry, 'name', 'Alan' );


// Callback function declared that accepts a row 
function queryLoop(row){
  WriteDump( row );
}


// Loop around each row
QueryEach( qry, queryLoop );


// Alternatively you can loop using the .each()
qry.each( queryLoop );
</cfscript>
</pre>

<p>
For each row in the query, the function 'queryLoop' is executed, passing in the current row.  The row structure has the 'currentrow' and 'recordcount'
variables set so you know how far along you are in the query.   The callback function sits within the variable scope of the calling function, so it
can interact with variables outside of itself.
</p>