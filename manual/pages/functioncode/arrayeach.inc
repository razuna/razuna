<p>
You can easily iterate over the elements of an array by using the ArrayEach() function or the .each() feature.
</p>

<pre class="cfml">
<cfscript>
// Create a sample array
arr = ["alan", "ceri", "andy", "jamie" ];


// Callback function declared that accepts the element
function arrayLoop(el){
  WriteDump( el );
}


// Loop around each element
ArrayEach( arr, arrayLoop );


// Alternatively you can loop using the .each()
arr.each( arrayLoop );
</cfscript>
</pre>

<p>
For each element in the array, the function 'arrayLoop' is called, passing in the current element.  
The callback function sits within the variable scope of the calling function, so it can interact with variables outside of itself.
</p>