<cfsilent>

	<cfset request.page.section = "tags">

	<cfset url.tag	= request.params[2]>

	<cftry>
		<cfset tagInfo = GetEngineTagInfo( url.tag )>
	<cfcatch>
		<cfif cfcatch.message contains "No such tag exists">
			<cflocation url="/manual/?/tag/">
		<cfelse>
			<cfrethrow>
		</cfif>
	</cfcatch>
	</cftry>
	
	<cfset request.page.title = "#UCase(url.tag)#">
	<cfset request.page.section = "tags">
	<cfset request.page.category = tagInfo.category>

	<cfset desc = Left( tagInfo.summary, 200 )>
	<cfset desc = Replace( desc, Chr(13), "", "ALL" )>
	<cfset request.page.desc = "#UCase(url.tag)# :: #XmlFormat(desc)#">

</cfsilent>


<cfoutput>

<div class="subnav">
	<div class="container">
		<ul class="breadcrumb">
			<li><a href="./?/tag/">CFML Tags</a></li>
			<li><a href="./?/tag/category/#tagInfo.category#" style="text-transform:capitalize">#tagInfo.category# Category</a></li>
			<li class="active"><a href="##">&lt;#UCase(url.tag)#&gt;</a></li>
		</ul>
	</div>
</div>


<div class="content" id="content">
	<div class="container cf">

		<h1>#UCase(url.tag)#</h1>
		
		<cfset tagArray = GetEngineTagCategories()>
		
		<div class="sidebar cf">
			<div id="side_menu" class="show_cats">Categories <span><b></b></span></div>
			<ul class="categories">
				<li><a href="./?/tag/">All</a></li>
				<cfoutput><cfloop array="#tagArray#" index="category">
				<li<cfif request.page.category == category> class="active"</cfif>><a href="./?/tag/category/#category#" style="text-transform:capitalize">#category#</a></li></cfloop></cfoutput>
			</ul>
		</div>
		
		
		<div class="section">

			<div class="row">
				<p>#XmlFormat(tagInfo.summary)#</p>	
			</div>
	
			<div class="row">
				<h3>Usage</h3>	
				<code>&lt;#url.tag#&gt; <cfif tagInfo.endtag>... &lt;/#url.tag#&gt;</cfif></code>	
			</div>
	
	
			<cfif ArrayLen(tagInfo.attributes) != 0>
			
				<div class="row">
					<h3>Attributes</h3>
					
					<table>
							<thead>
							<tr>
								<th>Attribute</th>
								<th>default</th>
								<th>required</th>
								<th>summary</th>
							</tr>
							</thead>
							</tbody>
							<cfloop index="p" array="#tagInfo.attributes#">
							<tr>
								<td valign="top"><strong>#p.name#</strong></td>
								<td valign="top" align="center">#p.default#</td>
								<td valign="top" align="center"><cfif #p.required# == true><img src="required.png" title="Required" /><cfelse> </cfif></td>
								<td valign="top">#p.summary#</td>
							</tr>
							</cfloop>
							</tbody>
					</table>
				</div>
			
			</cfif>


<cfset codeSnippet = ExpandPath( "./pages/tagcode/#LCase(url.tag)#.inc" )>
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



<cfif tagInfo.category neq "unknown">
<div class="row">
	<h3>See Also</h3>

	<cfset funcArray = GetSupportedTags( tagInfo.category )>
	<div class="usage">
		<p>
			<cfloop array="#funcArray#" index="func"><a href="./?/tag/#func#">#func#</a> </cfloop>
		</p>
	</div>
</div>

</cfif>

</cfoutput>

		</div><!-- .section -->

	</div><!--- .container --->
</div><!--- .content --->