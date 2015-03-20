<pre class="cfml">
<cfscript>
  myArray    = ArrayNew();
  myArray[1] = "item1";
</cfscript>

<cfset myOtherArray = ArrayNew(2)>
<cfset myOtherArray[1][1] = "item2">

<cfoutput>#ArrayToList( myArray )#</cfoutput>

<cfdump var="#myOtherArray#">
</pre>