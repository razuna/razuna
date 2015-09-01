<p>
A linked structure works in the exact same way as a normal CFML structure, except it holds a maximum number of items, as well maintaining
the order of insertion order of the key.  When a new item that is greater than the maximum size, the oldest accessed value is removed
from the structure.
</p>

<p>
This is particularly useful if you are building a front-line cache for your application and you wish to limit the amount of memory.
</p>

<p>
The following example illustrates how the linked structure operates.  You can use all the <a href="./?/function/category/structure">structure</a> methods with this special type.
As soon the 'f' key is inserted, the oldest one is rotated out, which in this case is 'a'.  The structure will never grow beyond the maximum number of items.
</p>

<pre class="cfml">
<cfscript>
s = StructListNew( 5 );

 // Insert 6 items
s["a"] = 1;
s["b"] = 1;
s["c"] = 1;
s["d"] = 1;
s["e"] = 1;
s["f"] = 1;

length	= len(s);  // this will be 5 items
keylist	= StructKeyList(s); // "b,c,d,e,f"
</cfscript>
</pre>