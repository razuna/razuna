<p>
Creates a new structure using only the elements from the first structure, by using the callback function. 
</p>

<pre class="cfml">
<cfscript>
str = {
	name : "alan",
	age : 21,
	dob : now()
};


// Callback function declared that accepts the element
function mapCallbackFilter(k,v){
	return isNumeric(k);
}


// Loop around each element
newstr = StructFilter( str, mapCallbackFilter );
</cfscript>
</pre>

<p>
For each element in the array, the function 'mapCallbackFilter' is called, passing in the current element and the key.  
The callback function sits within the variable scope of the calling function, so it can interact with variables outside of itself.
</p>