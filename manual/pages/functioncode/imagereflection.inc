<pre class="cfml"><nocfml><cfset im	= ImageRead( "http://www.openbluedragon.org/images/logo.gif" )>

<cfset ImageReflection( image=im )>
<cfset b = ImageWriteBase64( image=im, format="jpg", inhtmlformat=true )>

&lt;img src="<cfoutput>#b#</cfoutput>" />
</nocfml></pre>