<p>
Creates an array of the indices where the callback function returned true.  The callback function must return either true/false.
</p>

<pre class="cfml">
<cfscript>
// Create a sample array
arr = ["alan", "ceri", "andy", "jamie" ];


// Callback function declared that accepts the element
function arrayLoopCallback(el){
  if ( el.startsWith("a") )
    return true;
  else
    return false;
}


// Create a new array from the old one
newArr = ArrayFindAll( arr, arrayLoopCallback );

// newArr will be [1,2]
</cfscript>
</pre>