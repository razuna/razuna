<!---

	Syntax Highlighting class

	Adapted from the original version CFCDocs

	--->
<cfcomponent output="false">

<cffunction name="syntaxHighlight" access="public" output="false" returntype="String" hint="Does color coding of source">
	<cfargument name="data" required="true" type="String" hint="The source that needs color coding">

	<cfscript>
		/* Pointer to Attributes.Data */
		this = arguments.Data;

		/* Convert special characters so they do not get interpreted literally; italicize and boldface */
		this = REReplaceNoCase(this, "&([[:alpha:]]{2,});", "«b»«i»&amp;\1;«/i»«/b»", "ALL");

		/* Convert many standalone (not within quotes) numbers to blue, ie. myValue = 0 */
		this = REReplaceNoCase(this, "(gt|lt|eq|is|,|\(|\))([[:space:]]?[0-9]{1,})", "\1«span class=n»\2«/span»", "ALL");

		/* Convert normal tags */
		this = REReplaceNoCase(this, "<(/?)((!d|b|c(e|i|od|om)|d|e|f(r|o)|h|i|k|l|m|n|o|p|q|r|s|t(e|i|t)|u|v|w|x)[^>]*)>", "«span class=h»<\1\2>«/span»", "ALL");

		/* Convert all table-related tags */
		this = REReplaceNoCase(this, "<(/?)(t(a|r|d|b|f|h)([^>]*)|c(ap|ol)([^>]*))>", "«span class=t»<\1\2>«/span»", "ALL");

		/* Convert all form-related tags */
		this = REReplaceNoCase(this, "<(/?)((bu|f(i|or)|i(n|s)|l(a|e)|se|op|te)([^>]*))>", "«span class=f»<\1\2>«/span»", "ALL");

		/* Convert all tags starting with 'a' to green */
		this = REReplaceNoCase(this, "<(/?)(a[^>]*)>", "«span class=a»<\1\2>«/span»", "ALL");

		/* Convert all image */
		this = REReplaceNoCase(this, "<(/?)((im[^>]*)|(sty[^>]*))>", "«span class=i»<\1\2>«/span»", "ALL");

		/* Convert all ColdFusion, SCRIPT and WDDX tags to maroon */
		this = REReplaceNoCase(this, "<(/?)((cf[^>]*)|(sc[^>]*)|(wddx[^>]*))>", "«span class=cf»<\1\2>«/span»", "ALL");

		/* Convert all multi-line script comments */
		this = REReplaceNoCase(this, "(\/\*[^\*]*\*\/)", "«span class=c»«i»\1«/i»«/span»", "ALL");
		this = REReplaceNoCase(this, "(<!-"&"--?[^-]*-?-"&"->)", "«span class=c»«i»\1«/i»«/span»", "ALL");

		/* Convert all quoted values */
		this = REReplaceNoCase(this, """([^""]*)""", "«span class=q»""\1""«/span»", "ALL");

		/* Convert left containers to their ASCII equivalent */
		this = Replace(this, "<", "&lt;", "ALL");

		// Convert all the tabs to 2 spaces
		this = Replace(this, Chr(9), "  ", "ALL");

		/* Revert all pseudo-containers back to their real values to be interpreted literally (revised) */
		this = REReplaceNoCase(this, "«([^»]*)»", "<\1>", "ALL");

	</cfscript>
	<cfreturn this>
</cffunction>

</cfcomponent>