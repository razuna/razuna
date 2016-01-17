<cfsilent>
	<cfset request.page.section = "functions">
	<cfset request.page.title 	= "All">

	<cfset categoryArray = GetEngineFunctionCategories()>
</cfsilent>


<div class="subnav">
	<div class="container">
		<ul class="breadcrumb">
		<cfif ( arraylen(request.params) == 1 )>
			<li class="active"><a href="#">CFML Functions</a></li>
		<cfelse>
			<li><a href="./?/function">CFML Functions</a></li>
			<li class="active"><cfoutput><a href="##" style="text-transform:capitalize">#request.params[3]# #request.params[2]#</a></cfoutput></li>
		</cfif>
		</ul>
	</div>
</div>

<div class="content" id="content">
	<div class="container cf">

		<h1>CFML Functions</h1>
			
		<div class="sidebar cf">
			<div id="side_menu" class="show_cats">Categories <span><b></b></span></div>
			<ul class="categories">
				<li<cfif ArrayLen(request.params) != 3> class="active"</cfif>><a href="./?/function/">All</a></li>
				<cfoutput><cfloop array="#categoryArray#" index="category"><cfif category == "unknown"><cfcontinue></cfif>
				<li<cfif ArrayLen(request.params) == 3 && request.params[3] == category> class="active"</cfif>><a href="./?/function/category/#category#" style="text-transform:capitalize">#category#</a></li>
				</cfloop></cfoutput>
			</ul>
		</div>

		<div class="section">

<cfif ArrayLen(request.params) == 3>

	<cfset request.page.title 	= "#request.params[3]# Functions">
	<cfset request.page.desc 		= "All the OpenBD CFML functions for the #request.params[3]# category">

	<cfset funcArray = GetSupportedFunctions( request.params[3] )>

	<h2 style="text-transform:capitalize"><cfoutput>#request.params[3]#</cfoutput> Category functions</h2>


	<table class="zebra-striped">
	<thead>
		<tr>
			<th>Function Name</th>
			<th>Description</th>
		</tr>
	</thead>
	<tbody>
		<cfoutput><cfloop array="#funcArray#" index="func"><cfsilent>
			<cfset funcMeta = GetEngineFunctionInfo( func )>
		</cfsilent><tr>
			<td width="1%" nowrap align="right"><a href="./?/function/#func#">#application.docs.getCamelCase( func )#</a></td>
			<td>#XmlFormat(funcMeta.summary)#</td>
		</tr></cfloop>
		</cfoutput>
	</tbody>
	</table>

<cfelse>

	<h2 style="text-transform:capitalize">All Functions</h2>

	<cfset request.page.title 	= "All CFML Functions">
	<cfset request.page.desc 		= "All the OpenBD CFML functions">
	<cfset funcArray = GetSupportedFunctions( "" )>
	<cfset firstChar	= "">
	<cfset cols = 0>
	<cfset leftCols = 0>

	<cfoutput>
	<cfloop index="x" from="1" to="#ArrayLen(funcArray)#">
	<cfif funcArray[x].charAt(0) != firstChar>
		<cfset firstChar = funcArray[x].charAt(0)><cfset cols = 0>

		<cfif x != 1></div></div></cfif>

		<div class="tag-row cf">
			<h4>#firstChar#</h4>
			<div class="full">
		</cfif>
			<div class="tag"><a href="./?/function/#funcArray[ x ]#">#application.docs.getCamelCase( funcArray[ x ] )#</a></div>

	</cfloop>
	</div>

	</cfoutput>

			</div><!-- /full -->
		</div>

</cfif>

		</div><!-- .section -->

	</div><!--- .container --->
</div><!--- .content --->