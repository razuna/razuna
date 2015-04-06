<p>
Using queries with a function is very easy, simply passing in the query to the QueryRun() function.
</p>

<pre class="cfml">
<cfset a = QueryRun("ds",
										"select X from tableA where T_ID = 1"
										)>
</pre>

<p>
If you need to pass in a dynamic variable, then this function has the same ability as CFQUERYPARAM has, by passing
in an array of structures with all the attributes that you would pass into CFQUERYPARAM.  You specify the position
of this using the ? inside the query block.
</p>

<pre class="cfml">
<cfset a = QueryRun("ds",
										"select X from tableA where T_ID in (?)", 
										[
											{
												value:"1,2,3,4", 
												list:true, 
												defaultlist:"0"
											}
										]
										)>
</pre>
