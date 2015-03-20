<cfsilent>
	<cfdump var="1">

	<cfparam name="url.id" default="0">

	<cfset request.nextId	= GetTickCount()>
	<cfset request.varsToDump = {
					query : [],
					object : {},
					strings: []
						}>

	<cfset request.stats = {
					"struct" : 0,
					"array"  : 0,
					"query" : 0,
					"object" : 0,
					"function" : 0,
					"binary" : 0,
					"simplevalue" : 0,
					"repeated references" : 0
						}>

	<cfset request.hs	= CreateObject("java","java.util.HashSet")>


<cffunction name="getDataType" returnType="string">
	<cfargument name="varname" />
	<cfset arguments.vardata 	= DebuggerInspect( url.id, arguments.varname )>
	<cfif isObject( arguments.vardata )>
		<cfreturn "object">
	<cfelseif isCustomFunction( arguments.vardata )>
		<cfreturn "function">
	<cfelseif isStruct( arguments.vardata )>
		<cfreturn "struct">
	<cfelseif isArray( arguments.vardata )>
		<cfreturn "array">
	<cfelseif isQuery( arguments.vardata )>
		<cfreturn "query">
	<cfelse>
		<cfreturn "simple">
	</cfif>
</cffunction>


<cffunction name="getFunctionDef" returntype="string">
	<cfargument name="func" />
	<cfsavecontent variable="arguments.bluffy"><cfdump var="#arguments.func#"></cfsavecontent>
	<cfreturn Replace( arguments.bluffy, "cfdump", "", "ALL" )>
</cffunction>


<cffunction name="dumpTree" returnType="string">
	<cfargument name="varname" />

	<cfset arguments.vardata 	= DebuggerInspect( url.id, arguments.varname )>

	<!--- Stop Repeated logs --->
	<cfset arguments.hc = GetHashCode( arguments.vardata )>
	<cfif !request.hs.contains( arguments.hc )>
		<cfset request.hs.add( arguments.hc )>
	<cfelseif getDataType(arguments.varname) neq "simple">
		<cfset request.stats["repeated references"]	= IncrementValue( request.stats["repeated references"] )>

		<cfif (getDataType(arguments.varname) eq "struct" && StructCount( arguments.vardata ) == 0)
					|| (getDataType(arguments.varname) eq "array" && ArrayLen( arguments.vardata ) == 0)>
			<cfreturn "<span class=""simple"">&nbsp;</span>">
		<cfelse>
			<cfreturn "<span class=""alreadydump""><em><a href=""##"" title=""click to expose the variable"" onclick=""varDisp(#arguments.hc#);"">already available</a></em></span>">
		</cfif>
	</cfif>

	<cfset arguments.bluffy 	= "">


	<!--- Now do the dump of the variables --->
	<cfif isObject( arguments.vardata )>
		<!--- ----------------------------------------------------------------------- --->
		<cfset request.stats["object"]	= IncrementValue( request.stats["object"] )>

		<cfset arguments.bluffy &= "<ul>">
		<cfloop collection="#arguments.vardata#" item="arguments.key">
			<cfset arguments.prefix	= arguments.varname & "." & arguments.key>
			<cfset arguments.bluffy &= "<li id=""#GetHashCode( DebuggerInspect( url.id, arguments.prefix ) )#"">">
			<cfset arguments.bluffy &= "<a href=""##"" class=""object""><ins class=""#getDataType(arguments.prefix)#"">&nbsp;</ins>">
			<cfset arguments.bluffy &= arguments.key>
			<cfset arguments.bluffy &= "</a>">
			<cfset arguments.bluffy &= dumpTree( arguments.prefix )>
			<cfset arguments.bluffy &= "</li>">
		</cfloop>
		<cfset arguments.bluffy &= "</ul>">

		<!--- ----------------------------------------------------------------------- --->
	<cfelseif isCustomFunction( arguments.vardata )>
		<!--- ----------------------------------------------------------------------- --->
		<cfset request.stats["function"]	= IncrementValue( request.stats["function"] )>

		<cfset arguments.functionDef 			= getFunctionDef(arguments.vardata)>
		<cfset arguments.functionDefHash	= Hash( arguments.functionDef )>
		<cfif !StructKeyExists( request.varsToDump.object, arguments.functionDefHash )>
			<cfset request.nextId	= request.nextId + 1>
			<cfset request.varsToDump.object[arguments.functionDefHash] = {
						path:arguments.varname,
						id:request.nextId,
						str:arguments.functionDef
				 }>
			<cfset arguments.nextid = request.nextId>
		<cfelse>
			<cfset arguments.nextid = request.varsToDump.object[arguments.functionDefHash].id>
		</cfif>

		<cfset arguments.bluffy &= "<span class=""function"" onclick=""display(#arguments.nextid#, '#JSStringFormat(arguments.varname)#');"">&laquo; view defintion &raquo;</span>">

		<!--- ----------------------------------------------------------------------- --->
	<cfelseif isStruct( arguments.vardata )>
		<!--- ----------------------------------------------------------------------- --->
		<cfset request.stats["struct"]	= IncrementValue( request.stats["struct"] )>

		<cfset arguments.bluffy &= "<ul>">
		<cfloop collection="#arguments.vardata#" item="arguments.key">
			<cfset arguments.prefix	= arguments.varname & "['" & arguments.key & "']">
			<cfset arguments.bluffy &= "<li id=""#GetHashCode( DebuggerInspect( url.id, arguments.prefix ) )#"">">
			<cfset arguments.bluffy &= "<a href=""##"" class=""keys""><ins class=""#getDataType(arguments.prefix)#"">&nbsp;</ins>">
			<cfset arguments.bluffy &= arguments.key>
			<cfset arguments.bluffy &= "</a>">
			<cfset arguments.bluffy &= dumpTree( arguments.prefix )>
			<cfset arguments.bluffy &= "</li>">
		</cfloop>
		<cfset arguments.bluffy &= "</ul>">

		<!--- ----------------------------------------------------------------------- --->
	<cfelseif isArray( arguments.vardata )>
		<!--- ----------------------------------------------------------------------- --->

		<cfset request.stats["array"]	= IncrementValue( request.stats["array"] )>

		<cfset arguments.bluffy &= "<ul>">
		<cfset argumetns.arrLen	= ArrayLen( arguments.vardata )>
		<cfloop index="arguments.x" from="1" to="#argumetns.arrLen#">
			<cfset arguments.prefix	= arguments.varname & "[" & arguments.x & "]">
			<cfset arguments.bluffy &= "<li id=""#GetHashCode( DebuggerInspect( url.id, arguments.prefix ) )#"">">
			<cfset arguments.bluffy &= "<a href=""##"" class=""array""><ins class=""#getDataType(arguments.prefix)#"">&nbsp;</ins>[">
			<cfset arguments.bluffy &= arguments.x>
			<cfset arguments.bluffy &= "]</a>">
			<cfset arguments.bluffy &= dumpTree( arguments.prefix )>
			<cfset arguments.bluffy &= "</li>">
		</cfloop>

		<cfset arguments.bluffy &= "</ul>">

		<!--- ----------------------------------------------------------------------- --->
	<cfelseif isQuery( arguments.vardata )>
		<!--- ----------------------------------------------------------------------- --->

		<cfset request.stats["query"]	= IncrementValue( request.stats["query"] )>

		<cfset request.nextId	= request.nextId + 1>
		<cfset ArrayAppend( request.varsToDump.query, {
						path:arguments.varname,
						id:request.nextId
				 } )>
		<cfset arguments.bluffy &= "<span class=""query"" onclick=""display('#request.nextId#', '#JSStringFormat(arguments.varname)#');"">&laquo; click to view query &raquo;</span>">

		<!--- ----------------------------------------------------------------------- --->
	<cfelseif isBinary( arguments.vardata )>
		<!--- ----------------------------------------------------------------------- --->

		<cfset request.stats["binary"]	= IncrementValue( request.stats["binary"] )>
		<cfset arguments.bluffy &= "<span class=""binary"">">
		<cfset arguments.bluffy &= Len( arguments.vardata )>
		<cfset arguments.bluffy &= " bytes</span>">

		<!--- ----------------------------------------------------------------------- --->
	<cfelseif isSimpleValue( arguments.vardata )>
		<!--- ----------------------------------------------------------------------- --->
		<cfset request.stats["simplevalue"]	= IncrementValue( request.stats["simplevalue"] )>

		<cfset arguments.str			= ToString(arguments.vardata)>
		<cfset arguments.bluffy &= "<span class=""simple"">">

		<cfif arguments.str != "">

			<cfif Len(arguments.str) GT 50>
				<cfset request.nextId	= request.nextId + 1>
				<cfset ArrayAppend( request.varsToDump.strings, {
							path:arguments.varname,
							id:request.nextId
					 } )>
				<cfset arguments.bluffy &= XmlFormat( Left(arguments.str,50) ) & " <a href=""##"" onclick=""display(#request.nextId#, '#JSStringFormat(arguments.varname)#');"">[All #Len(arguments.str)# chars]</a>">
			<cfelse>
				<cfset arguments.bluffy &= XmlFormat( arguments.str )>
			</cfif>

		<cfelse>
			<cfset arguments.bluffy &= "&nbsp;">
		</cfif>

		<cfset arguments.bluffy &= "</span>">
		<!--- ----------------------------------------------------------------------- --->
	</cfif>

	<cfreturn arguments.bluffy>
</cffunction>


<cfset activeSessions	= DebuggerGetSessions()>
<cfquery name="thisSession" dbtype="query">select * from activeSessions where id=<cfqueryparam value="#url.id#"></cfquery>

</cfsilent><cfinclude template="header.inc">

<style>
.tree li span.simple {color: blue;}
.tree li span.binary {color: #ff8040;}
.tree li span.alreadydump {color: red;}

.tree li span.query {color: maroon;cursor: pointer;}
.tree li span.function {color: blue;cursor: pointer;}
.tree li a.array {color: green;min-width: 50px;}
a.keys, a.object {min-width: 200px;}

ins.query, a ins.query { background:url("query.png") no-repeat; }
ins.struct, a ins.struct { background:url("struct.png") no-repeat; }
ins.array, a ins.array { background:url("array.png") no-repeat; }
ins.function, a ins.function { background:url("function.png") no-repeat; }
ins.object, a ins.object { background:url("object.png") no-repeat; }
ins.simple, a ins.simple { background:url("simple.png") no-repeat; }

#varTree {margin-left: 20px;margin-top: 10px; float: left; }

.searchBar {padding: 10px;margin: 20px;float: right;border: 1px solid #dfdfdf;}
.searchBar input {color: blue;}
.searchBar ul {
	margin-left: 5px;
	padding-left: 20px;
}

.searchBar ul li {
	padding: 1px;
	color: navy;
}
</style>

<table width="100%" class="fileList" cellpadding="0" cellspacing="0">
<tr>
	<td colspan="3"><div id="varname" class="filename"><cfoutput query="thisSession"><cfif onexception>Exception &mdash; </cfif>&lt;#tag#&gt; &mdash; #pf# &mdash; @ Line #line#</cfoutput></div></td>
</tr>
</table>

<div id="preTree">
	<p align="center" style="margin-top:40px"><em>Please wait while the variable tree is built</em></p>
</div>

<div class="searchBar">
	<strong>Search Variable Tree</strong><br/><input type="text" id="searchStr" size="14" /> <input type="button" value="&raquo;" onclick="varSearch( $('#searchStr').val() );" />
	<div id="searchHistory"></div>
</div>


<div id="varTree" style="display:none"><ul>
<cfloop array="#DebuggerInspectTopScopes( url.id )#" index="top">
	<cfset data	= DebuggerInspect( url.id, top )>
	<cfoutput><li id="top-#top#"><a href="##"><ins class="struct">&nbsp;</ins>#top#</a>#dumpTree( top )#</cfoutput></li>
</cfloop>


<cftry>

	<cfset data = debuggerinspectlocalscope( url.id )>
	<li id="top-local" rel="node-type">
		<a href="#"><ins class="struct">&nbsp;</ins><cfoutput>locals</cfoutput></a>
		<ul>
		<cfloop collection="#data#" item="key">
			<li id="top-local-#key#" rel="node-type">
				<a href="#" class="keys"><ins class="<cfoutput>#getDataType(key)#">&nbsp;</ins>#key#</a>#dumpTree( key )#</cfoutput>
			</li>
		</cfloop>
		</ul>
	</li>

<cfcatch></cfcatch>
</cftry>

</ul></div>

<div style="display:none;"><cfoutput>
<cfloop array="#request.varsToDump.query#" index="q"><div id="#q.id#">#getFunctionDef(DebuggerInspect( url.id, q.path ))#</div>
</cfloop><cfloop collection="#request.varsToDump.object#" item="key"><div id="#request.varsToDump.object[key].id#">#request.varsToDump.object[key].str#</div>
</cfloop><cfloop array="#request.varsToDump.strings#" index="q"><div id="#q.id#"><pre>#XmlFormat( DebuggerInspect( url.id, q.path ) )#</pre></div>
</cfloop></cfoutput>

<cfset stats	= DebuggerGetStats( url.id )>
<div id="statsTable">
<table width="100%" class="fileList" cellpadding="0" cellspacing="0">
<cfoutput query="stats">
<tr>
	<td width="1%"><pre>#name#</pre></td>
	<td align="right">#NumberFormat( total )#&nbsp;</td>
</tr>
</cfoutput>
<cfoutput><cfloop collection="#request.stats#" item="k">
<tr>
	<td width="1%"><pre>#k#</pre></td>
	<td align="right">#NumberFormat( request.stats[k] )#&nbsp;</td>
</tr>
</cfloop></cfoutput>
</table>
</div>

</div>

<script type="text/javascript">
$(function() {
	$("#varTree").tree({
		selected : "/",
		ui:{
			theme_name: "classic"
		},
		types : {
			"default" : {
					clickable	: true,
					renameable: false,
					deletable	: false,
					creatable	: false,
					draggable	: false,
					max_children	: -1,
					max_depth	: -1,
					valid_children	: "all"
				}
		}
	});

	$("#preTree").hide();
	$("#varTree").show();

	$("#searchStr").keypress(function (e) {
		if ((e.which && e.which == 13) || (e.keyCode && e.keyCode == 13)) {
			varSearch( $('#searchStr').val() );
			return false;
		} else {
			return true;
		}
  });

	displayHistory();

	parent.statsframe.document.getElementById("vardump").innerHTML = document.getElementById("statsTable").innerHTML;
});

display = function( v, m ){
	parent.valueframe.document.getElementById("varname").innerHTML = m;
	parent.valueframe.document.getElementById("vardump").innerHTML = document.getElementById(v).innerHTML;
};

varDisp = function( hc ){
	$.tree.focused().close_all();
	$.tree.focused().open_branch( "#" + hc );
};

varSearch = function( str ){
	if ( str != "" ){
		$("#searchStr").val( str );
		$.tree.focused().close_all();
		$.tree.focused().search( str );

		var sHist	= $.cookie("sh");
		if ( sHist == null || sHist == "" ){
			sHist	= str;
		}else{
			if ( sHist.indexOf(str) == -1 )
				sHist = str + "," + sHist;
		}

		// Keep the last 10
		var aa = sHist.split(",");
		if ( aa.length > 10 ){
			var bb = [];
			for ( var x=0; x < 10; x++ )
				bb[x] = aa[x];

			sHist	= bb.join(",");
		}

		$.cookie("sh", sHist);

		displayHistory();
	}
};

displayHistory = function(){
	//Update the history
	var sHist	= $.cookie("sh");
	var aa = sHist.split(",");
	var out = "<ul>";
	for ( var x=0; x < aa.length; x++ ){
		out = out + "<li><a href='#' title='search again using this string' onclick='varSearch(\"" + aa[x] + "\")'>" + aa[x] + "</a></li>";
	}
	out = out + "</ul>";

	$("#searchHistory").html( out );
};
</script>

<cfinclude template="footer.inc">