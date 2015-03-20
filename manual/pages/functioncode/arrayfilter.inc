<p>
Creates a brand new array using the elements from the previous one, by using a callback function to determine whether or not the
element should be included.  The callback function must return either true/false.
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
newArr = ArrayFilter( arr, arrayLoopCallback );
</cfscript>
</pre>