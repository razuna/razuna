<p>
You can easily iterate over the elements of a structure by using the StructEach() function or the .each() feature.
</p>

<pre class="cfml">
<cfscript>
str = {
	name : "alan",
	age : 21,
	dob : now()
};


// Callback function declared that accepts the element
function mapCallback(k,v){
	Console( k & "=" & v );
}


// Loop around each element
StructEach( str, mapCallback );


// Alternatively you can loop using the .each()
str.each( mapCallback );
</cfscript>
</pre>

<p>
For each element in the array, the function 'mapCallback' is called, passing in the current element and the key.  
The callback function sits within the variable scope of the calling function, so it can interact with variables outside of itself.
</p>