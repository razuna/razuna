<pre class="cfml"><nocfml><cfset im	= ImageRead( "http://www.openbluedragon.org/images/logo.gif" )>

<cfset ImageContractBrightness( image=im, brightness=3 )>
<cfset b = ImageWriteBase64( image=im, format="jpg", inhtmlformat=true )>

&lt;img src="<cfoutput>#b#</cfoutput>" />
</nocfml></pre>