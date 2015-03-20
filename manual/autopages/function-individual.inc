<cfsilent>

	<cfset url.function = request.params[2]>

	<cftry>
		<cfset func = GetEngineFunctionInfo( url.function )>
	<cfcatch>
		<cfif cfcatch.message contains "No such function exists">
			<cflocation url="/manual/?/function/">
		<cfelse>
			<cfrethrow>
		</cfif>
	</cfcatch>
	</cftry>

	<cfset request.page.title 	= "#application.docs.getCamelCase( url.function )#()">
	<cfset request.page.section = "functions">
	<cfset request.page.category = func.category>

	<cfset desc = Left( func.summary, 200 )>
	<cfset desc = Replace( desc, Chr(13), "", "ALL" )>
	<cfset request.page.desc = "#application.docs.getCamelCase( url.function )#() :: #XmlFormat(desc)#">

</cfsilent>
<cfoutput>

<div class="subnav">
	<div class="container">
		<ul class="breadcrumb">
			<li><a href="./?/function/">CFML Functions</a></li>
			<li><a href="./?/function/category/#func.category#" style="text-transform:capitalize">#func.category# Category</a></li>
			<li class="active"><a href="##">#application.docs.getCamelCase( url.function )#()</a></li>
		</ul>
	</div>
</div>


<div class="content" id="content">
	<div class="container cf">

		<h1>#application.docs.getCamelCase( url.function )#()</h1>
		
		<cfset categoryArray = GetEngineFunctionCategories()>
		
		<div class="sidebar cf">
			<div id="side_menu" class="show_cats">Categories <span><b></b></span></div>
			<ul class="categories">
				<li><a href="./?/function/">All</a></li>
				<cfoutput><cfloop array="#categoryArray#" index="category"><cfif category == "unknown"><cfcontinue></cfif>
				<li <cfif ( request.page.category == category )>class="active"</cfif>><a href="./?/function/category/#category#" style="text-transform:capitalize">#category#</a></li></cfloop></cfoutput>
			</ul>
		</div>


		<div class="section">
		
			<div class="row">
				<p>#XmlFormat(func.summary)#</p>
			</div>
			
			
			<div class="row">
			
				<h3>Usage</h3>
			
				<div class="usage">
				<code><span class="return">#func.return#</span> = #application.docs.getCamelCase( url.function )#(
				<cfloop index="p" from="1" to="#func.max#">
					<cfif !func.namedparamsupport><cfset paramName = "p" & p><cfelse><cfset paramName = func.namedparams[p]></cfif>
					<cfif (p <= func.min)>
						<span class="inparam">#paramName#<cfif (p < func.max)>, </cfif></span>
					<cfelseif (p > func.min)>
						<span class="inparam optional">#paramName#<cfif (p < func.max)>, </cfif></span>
					</cfif>
				</cfloop>
				)</span></code>
			
				<cfif (func.max > 0)>
					<table style="margin-top: 20px;">
						<tr>
							<th>Argument</th>
							<th>Summary</th>
						</tr>
					<cfloop index="p" from="1" to="#func.max#">
						<cfif !func.namedparamsupport><cfset paramName = "p" & p><cfelse><cfset paramName = func.namedparams[p]></cfif>
					<tr>
						<td valign="top"><strong>#paramName#</strong></td>
						<td valign="top">#func.params[p]# <cfif (p > func.min)>[optional]</cfif></td>
					</tr>
					</cfloop>
					</table>
				</cfif>
			
			</div>


<cfif func.namedparamsupport>
<div class="row">

	<h3>Calling</h3>


	<div class="supports">
	<p>Supports <a href="./?/language_tagsfunctions##namedparams">named-parameter calling</a> allowing you to use the function like:</p>

	<pre class="arguments" >#application.docs.getCamelCase( url.function )#(
<cfloop index="p" from="1" to="#func.max#">   #func.namedparams[p]#=?<cfif (p < func.max)>, </cfif>
</cfloop>);</pre>
	</div>

	<div class="supports args">
		<p>Supports passing parameters as a structure using <strong>ArgumentCollection</strong>:</p>
		<pre class="arguments">#application.docs.getCamelCase( url.function )#( ArgumentCollection={
<cfloop index="p" from="1" to="#func.max#">   #func.namedparams[p]# : ?<cfif (p < func.max)>, </cfif>
</cfloop>} );</pre>
	</div>

</div>
</cfif>

<cfset codeSnippet = ExpandPath( "./pages/functioncode/#LCase(url.function)#.inc" )>
<cfif FileExists(codeSnippet)>
<div class="row">

	<h3>Extra</h3>

	<cfset contents = FileRead( codeSnippet )>
	<cfset contents = Replace(contents,"<cf", "&lt;cf", "all")>
	<cfset contents = Replace(contents,"</cf", "&lt;/cf", "all")>
	<cfset contents = Replace(contents,"<!---", "&lt;!---", "all")>
	<cfset contents = Replace(contents, Chr(9), "  ", "all")>
	#contents#


</div>
</cfif>

<cfif url.function.startsWith("mongo")>
<div class="row">

	<h3>Extra</h3>

	<cfset contents = FileRead( ExpandPath("./pages/functioncode/mongo.inc") )>
	<cfset contents = Replace(contents,"<cf", "&lt;cf", "all")>
	<cfset contents = Replace(contents,"</cf", "&lt;/cf", "all")>
	<cfset contents = Replace(contents,"<!---", "&lt;!---", "all")>
	<cfset contents = Replace(contents, Chr(9), "  ", "all")>
	#contents#

</div>
</cfif>




<cfif func.category != "unknown">
<div class="row">


	<h3>See Also</h3>

		<div class="usage">
			<cfset funcArray = GetSupportedFunctions( func.category )>
			<cfloop array="#funcArray#" index="func">
			<a href="./?/function/#func#">#application.docs.getCamelCase(func)#</a> &nbsp; </cfloop>
		</div>

</div>

</cfif>

</div>

</cfoutput>

		</div><!-- .section -->

	</div><!--- .container --->
</div><!--- .content --->