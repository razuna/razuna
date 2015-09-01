<h3>Example</h3>
<br />
<p>
MongoDB's query syntax is quite different then the SQL you might got used too. A good overview how to find (select) records with MongoDB can be found at <a href="http://www.mongodb.org/display/DOCS/SQL+to+Mongo+Mapping+Chart" target="_blank">SQL to Mongo Mapping Chart</a>. In short, the MongoDB find() syntax is close to the "chained" commands you might know from the likes of JQuery. Important to remember is that 99% of the time everything you pass to MongoDB is a JSON structure and has a JSON like syntax.</p>
<p>
Since OpenBD is using the Java Driver and we apply a CFML tag for it, the query syntax differs slightly from the one you would enter in a mongo shell. Please find below some examples.</p>
</p>
<h4>Find all records</h4>
<pre class="cfml">
<cfset myarray = MongoCollectionfind(
   datasource="mongosource", 
   collection="users", 
   query={}
)>
</pre>
<p>The above MongoCollectionfind() will return an Array with all records of the Collection and all fields.</p>
<h4>Return only certain fields</h4>
<p>It's a common practice not to return all fields as in a "SELECT column1, column2 FROM…". With MongoCollectionfind() you would do something like:</p>
<pre class="cfml">
<cfset myarray = MongoCollectionfind(
   datasource="mongosource", 
   collection="users", 
   query={},
   fields={email:true,firstname:true}
)>
</pre>
<p>Again the MongoCollectionfind() would return an Array with all records, but this time only with the columns "email" and "firstname". Note: The unique value of "_id" is always returned!</p>
<h4>Find a specific user</h4>
<p>Of course, returning all records is 99% of the time not wanted. MongoDB has a very sophisticated approach to finding records. As you can see from the SQL to MongoDB map. Ok, now let's find user by his eMail address</p>
<pre class="cfml">
<cfset myarray = MongoCollectionfind(
   datasource="mongosource", 
   collection="users", 
   query=({email:"nitai@openbd.com"}),
   fields={email:true,firstname:true}
)>
</pre>
<p>To find the user with his eMail address AND his first name you would do:</p>
<pre class="cfml">
<cfset myarray = MongoCollectionfind(
   datasource="mongosource", 
   collection="users", 
   query=({email:"nitai@openbd.com",firstname:"nitai"}),
   fields={email:true,firstname:true}
)>
</pre>
<p>The same find() as above but this time with OR would be:</p>
<pre class="cfml">
<cfset myarray = MongoCollectionfind(
   datasource="mongosource", 
   collection="users", 
   query=( { $or : [ { email : "nitai@openbd.com" } , { first_name : "nitai" } ] } ),
   fields={email:true,firstname:true}
)>
</pre>
