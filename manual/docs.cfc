<cfcomponent output="false">

<cffunction name="init" returntype="any">
	<cfreturn this>
</cffunction>



<cffunction name="renderBody" returntype="string">
	<cfargument name="b" required="true">

	<cfset arguments.b	= XmlFormat( arguments.b )>

	<cfset arguments.b	= Replace( arguments.b, "{{{", "<pre>", "ALL")>
	<cfset arguments.b	= Replace( arguments.b, "}}}", "</pre>", "ALL")>

	<cfset this.urlRE = "((http|https)\://[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(:[a-zA-Z0-9]*)?/?([a-zA-Z0-9\-\._\?\,/\\\+&%\$##\=~])*)">
	<cfset arguments.b	= rereplacenocase( arguments.b, this.urlRE, "<a href='\1' target='_blank'>\1</a>", "ALL")>

	<cfreturn ParagraphFormat( arguments.b )>
</cffunction>



<cfset this.prefix = "spreadsheet,get,array,struct,socket,system,nx,bit,binary,cache,collection,create,date,file,find,html,ip,image,is,list,ls,query,set,jmx,java,to,mapping,xml,replace,span,sqs,thread,url,write,yes,amazon,directory,delete,salesforce,mongo">

<cffunction name="getCamelCase" returntype="string">
	<cfargument name="funcname">

	<cfset var st = "">
	<cfloop list="#this.prefix#" index="st" delimiters=",">
		<cfif ( arguments.funcname.startsWith( st ) && Len(arguments.funcname) > Len(st) )>
			<cfset var b = arguments.funcname.substring(0,1).toUpperCase()>
			<cfset b = b & st.substring( 1 )>
			<cfset b = b & arguments.funcname.substring( st.length(), st.length()+1 ).toUpperCase()>
			<cfset b = b & arguments.funcname.substring( st.length()+1 )>
			<cfreturn b>
		</cfif>
	</cfloop>

	<cfreturn arguments.funcname.substring(0,1).toUpperCase() & arguments.funcname.substring(1)>
</cffunction>


</cfcomponent>