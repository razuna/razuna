<cfsilent>

	<cfset request.page.section = "tags">
	<cfset request.page.title 	= "All">
	
	<cfset tagArray = GetEngineTagCategories()>
</cfsilent>

	
<div class="subnav">
	<div class="container">
		<ul class="breadcrumb">
			<cfif ( arraylen(request.params) == 1 )>
				<li class="active"><a href="#">CFML Tags</a></li>
			<cfelse>
				<li><a href="./?/tag">CFML Tags</a></li>
				<li class="active"><cfoutput><a href="##" style="text-transform:capitalize">#request.params[3]# #request.params[2]#</a></cfoutput></li>
			</cfif>
		</ul>
	</div>
</div>


<div class="content" id="content">
	<div class="container cf">

		<h1>CFML Tags</h1>
		
		<div class="sidebar cf">
			<div id="side_menu" class="show_cats">Categories <span><b></b></span></div>
			<ul class="categories">
				<li<cfif ArrayLen(request.params) != 3> class="active"</cfif>><a href="./?/tag/">All</a></li>
				<cfoutput><cfloop array="#tagArray#" index="category">
				<li<cfif ArrayLen(request.params) == 3 && request.params[3] == category> class="active"</cfif>><a href="./?/tag/category/#category#" style="text-transform:capitalize">#category#</a></li>
				</cfloop></cfoutput>
			</ul>
		</div>
		
		
		<div class="section">

<cfif ArrayLen(request.params) == 3>

	<cfset request.page.title 	= "#request.params[3]# Tags">
	<cfset request.page.desc 		= "#request.params[3]# Tags">


	<cfoutput>
	<h2 style="text-transform:capitalize">#request.params[3]# Tags</h2>

	<cfset funcArray = GetSupportedTags( request.params[3] )>

	<table class="zebra-striped">
		<thead>
		<tr>
			<th>Tag Name</th>
			<th>Description</th>
		</tr>
		</thead>
		<tbody>
		<cfloop array="#funcArray#" index="func"><cfsilent>
			<cfset funcMeta = GetEngineTagInfo( func )>
		</cfsilent><tr>
			<td width="1%" nowrap align="right"><a href="./?/tag/#func#">#func#</a></td>
			<td>#XmlFormat(funcMeta.summary)#</td>
		</tr></cfloop>
		</tbody>
	</table>

	</cfoutput>

<cfelse>

	<h2 style="text-transform:capitalize">All Tags</h2>

	<cfset request.page.title 	= "All CFML Tags">
	<cfset request.page.desc 		= "All the OpenBD CFML tags">
	<cfset funcArray = GetSupportedTags( "" )>
	<cfset firstChar	= "">
	<cfset cols = 0>

	<cfoutput>
	<cfloop index="x" from="1" to="#ArrayLen(funcArray)#"><cfif Len(funcArray[x]) == 2><cfcontinue></cfif>
	<cfif funcArray[x].charAt(2) != firstChar>
		<cfset firstChar = funcArray[x].charAt(2)><cfset cols = 0>

	<cfif x GT 1></div></div></cfif>

	<div class="tag-row cf">
		<h4>#firstChar#</h4>
		<div class="full">
	</cfif>

		<div class="tag"><a href="./?/tag/#funcArray[ x ]#">#application.docs.getCamelCase( funcArray[ x ] )#</a></div>

	</cfloop>

		</div><!-- /full -->
	</div>
	</cfoutput>

</cfif>

		</div><!-- .section -->

	</div><!--- .container --->
</div><!--- .content --->