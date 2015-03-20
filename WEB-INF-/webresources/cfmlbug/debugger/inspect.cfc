<cfcomponent output="false">


<cffunction name="get" returntype="any" access="remote" returnformat="json">
	<cfargument name="sid">
	<cfargument name="id">

	<cfif arguments.id == 0>
		<cfreturn getTopLevelScopes( arguments.sid )>
	<cfelseif arguments.id == "locals">
		<cfreturn getLocalLevelScopes( arguments.sid )>
	<cfelse>
		<cfset arguments.id  = decode( arguments.id )>
		<cfreturn getVar( arguments.sid, arguments.id )>
	</cfif>
</cffunction>


<cffunction name="encode" returntype="string">
	<cfargument name="v">

	<cfscript>
	arguments.v = Replace( arguments.v, "['", "__SL__","ALL");
	arguments.v = Replace( arguments.v, "']", "__SR__", "ALL");

	arguments.v = Replace( arguments.v, "[", "__AL__","ALL");
	arguments.v = Replace( arguments.v, "]", "__AR__", "ALL");

	arguments.v = Replace( arguments.v, "'", "&apos;", "ALL");
	return arguments.v;
	</cfscript>
</cffunction>


<cffunction name="decode" returntype="string">
	<cfargument name="v">

	<cfscript>
	arguments.v = Replace( arguments.v, "__SL__", "['","ALL");
	arguments.v = Replace( arguments.v, "__SR__", "']", "ALL");

	arguments.v = Replace( arguments.v, "__AL__", "[","ALL");
	arguments.v = Replace( arguments.v, "__AR__", "]", "ALL");

	arguments.v = Replace( arguments.v, "__AP__", "'", "ALL");
	return arguments.v;
	</cfscript>
</cffunction>


<cffunction name="getVar" returntype="array">
	<cfargument name="sid" />
	<cfargument name="varname" />

	<cfset arguments.vardata 	= DebuggerInspect( arguments.sid, arguments.varname )>
	<cfset var results = []>
	<cfset var prefix = true>
	<cfset var li = true>
	<cfset var tickCount	= GetTickCount()>

	<!--- Now do the dump of the variables --->
	<cfif isObject( arguments.vardata )>
		<!--- ----------------------------------------------------------------------- --->

		<cfset keys = StructKeyArray(arguments.vardata)>
		<cfset ArraySort( keys, "text", "asc" )>

		<cfloop array="#keys#" index="arguments.key">
			<cfscript>
				tickCount++;
				prefix = arguments.varname & "." & arguments.key;
				title = arguments.key;
				id = encode( prefix );

				clss = getDataType(arguments.sid, prefix);

				li = {
					data : {
						title : title
					},
					attributes : {
						id : id,
						class : clss,
						type  : "Dir",
						icon : clss
					}
				};

				if (clss == "function"){
					li.data.extra = "<span class=""simple""><a href=""javascript:void(0);"" class=""inspectfunction"" var=""#id#"" onclick=""inspectVar(this);"">[inspect function]</a></span>";
				}else if (clss == "binary"){
					li.data.extra = "<span class=""binary"">#Len( arguments.vardata )# bytes [Binary Object]</span>";
				}else if ( clss != "simple" ){
					li.state = "closed";
				}else{
					str = ToString( DebuggerInspect(arguments.sid,prefix) );
					if ( str.length() > 50 ){
						li.data.extra = "<span class=""simple"">" & encode( Left(str, 50) ) & " <a href=""javascript:void(0);"" var=""#id#"" onclick=""inspectVar(this);"">[inspect]</a></span>";
					}else{
						li.data.extra = "<span class=""simple"">" & encode(str) & " &nbsp;</span>";
					}
				}

				ArrayAppend( results, li );
			</cfscript>
		</cfloop>

		<!--- ----------------------------------------------------------------------- --->
	<cfelseif isStruct( arguments.vardata )>
		<!--- ----------------------------------------------------------------------- --->

		<cfset keys = StructKeyArray(arguments.vardata)>
		<cfset ArraySort( keys, "text", "asc" )>

		<cfloop array="#keys#" index="arguments.key">
			<cfscript>
				tickCount++;
				prefix = arguments.varname & "['" & arguments.key & "']";
				title = arguments.key;
				id = encode( prefix );

				clss = getDataType(arguments.sid, prefix);

				li = {
					data : {
						title : title
					},
					attributes : {
						id : id,
						class : clss,
						type  : "Dir",
						icon : clss
					}
				};

				if (clss == "function"){
					li.data.extra = "<span class=""simple""><a href=""javascript:void(0);"" class=""inspectfunction"" var=""#id#"" onclick=""inspectVar(this);"">[inspect function]</a></span>";
				}else if (clss == "binary"){
					li.data.extra = "<span class=""binary"">#Len( arguments.vardata )# bytes [Binary Object]</span>";
				}else if ( clss != "simple" ){
					li.state = "closed";
				}else{
					str = ToString( DebuggerInspect(arguments.sid,prefix) );
					if ( str.length() > 50 ){
						li.data.extra = "<span class=""simple"">" & encode( Left(str, 50) ) & " <a href=""javascript:void(0);"" var=""#id#"" onclick=""inspectVar(this);"">[inspect]</a></span>";
					}else{
						li.data.extra = "<span class=""simple"">" & encode(str) & " &nbsp;</span>";
					}
				}

				ArrayAppend( results, li );
			</cfscript>
		</cfloop>


		<!--- ----------------------------------------------------------------------- --->
	<cfelseif isArray( arguments.vardata )>
		<!--- ----------------------------------------------------------------------- --->

		<cfloop index="x" from="1" to="#ArrayLen(arguments.vardata)#">
			<cfscript>
				tickCount++;
				prefix	= arguments.varname & "[" & x & "]";
				title 	= "[" & x & "]";
				id 			= encode( prefix );
				clss 		= getDataType(arguments.sid, prefix);

				li = {
					data : {
						title : title
					},
					attributes : {
						id : id,
						class : clss,
						type  : "Dir"
					},
					class : "alan"
				};

				if (clss == "function"){
					li.data.extra = "<span class=""simple""><a href=""javascript:void(0);"" class=""inspectfunction"" var=""#id#"" onclick=""inspectVar(this);"">[inspect function]</a></span>";
				}else if (clss == "binary"){
					li.data.extra = "<span class=""binary"">#Len( arguments.vardata )# bytes [Binary Object]</span>";
				}else if ( clss != "simple" ){
					li.state = "closed";
				}else{
					str = ToString( DebuggerInspect(arguments.sid,prefix) );
					if ( str.length() > 50 ){
						li.data.extra = "<span class=""simple"">" & encode( Left(str, 50) ) & " <a href=""javascript:void(0);"" var=""#id#"" onclick=""inspectVar(this);"">[inspect]</a></span>";
					}else{
						li.data.extra = "<span class=""simple"">" & encode(str) & " &nbsp;</span>";
					}
				}

				ArrayAppend( results, li );
			</cfscript>
		</cfloop>

		<!--- ----------------------------------------------------------------------- --->
	<cfelseif isQuery( arguments.vardata )>
		<!--- ----------------------------------------------------------------------- --->

		<cfscript>
		li = {
			data : {
				title : "recordcount",
				extra : "<span class=""simple"">" & arguments.vardata.recordcount & "</span>"
			},
			attributes : {
				id : "",
				class : "simple",
				type  : "Dir",
				icon : "simple"
			}
		};
		ArrayAppend( results, li );

		li = {
			data : {
				title : "currentrow",
				extra : "<span class=""simple"">" & arguments.vardata.currentrow & "</span>"
			},
			attributes : {
				id : "",
				class : "simple",
				type  : "Dir",
				icon : "simple"
			}
		};
		ArrayAppend( results, li );

		li = {
			data : {
				title : "columnlist",
				extra : "<span class=""simple"">" & arguments.vardata.columnlist & "</span>"
			},
			attributes : {
				id : "",
				class : "simple",
				type  : "Dir",
				icon : "simple"
			}
		};
		ArrayAppend( results, li );

		li = {
			data : {
				title : "rows",
				extra : "<span class=""simple""><a href=""javascript:void(0);"" var=""#encode(arguments.varname)#"" onclick=""inspectVar(this);"">[inspect]</a></span>"
			},
			attributes : {
				id : encode(arguments.varname),
				class : "simple",
				type  : "Dir",
				icon : "simple"
			}
		};
		ArrayAppend( results, li );
		</cfscript>


		<!--- ----------------------------------------------------------------------- --->
	<cfelseif isBinary( arguments.vardata )>
		<!--- ----------------------------------------------------------------------- --->

		<!--- ----------------------------------------------------------------------- --->
	</cfif>

	<cfreturn results>
</cffunction>



<cffunction name="getTopLevelScopes" returntype="array">
	<cfargument name="sessionid">

	<cfscript>
	var results = [];
	var x = 0;
	var li;
	var arry = DebuggerInspectTopScopes(arguments.sessionid);

	for ( x=1; x <= ArrayLen(arry); x++ ){
		li = {
			data : {
				title : arry[x]
			},
			attributes : {
				path : arry[x],
				id : arry[x],
				class : "struct",
				tyle  : "Dir"
			},
			state : "closed"
		};

		ArrayAppend( results, li );
	}


	// Put in the locals
	li = {
		data : {
			title : "locals"
		},
		attributes : {
			path : "locals",
			id : "locals",
			class : "struct",
			tyle  : "Dir"
		},
		state : "closed"
	};
	ArrayAppend( results, li );

	return results;
	</cfscript>

</cffunction>


<cffunction name="getLocalLevelScopes" returntype="array">
	<cfargument name="sessionid">

	<cfscript>
	try{

		var results = [];
		var x = 0;
		var li;
		var data = debuggerinspectlocalscope( arguments.sessionid );
		var arry = StructKeyArray(data);
		ArraySort( arry, "text", "asc" );

		for ( x=1; x <= ArrayLen(arry); x++ ){
			li = {
				data : {
					title : arry[x]
				},
				attributes : {
					path : arry[x],
					id : arry[x],
					class : "struct",
					tyle  : "Dir"
				},
				state : "closed"
			};

			ArrayAppend( results, li );
		}

		return results;

	}catch(Any e){
		return [];
	}
	</cfscript>
</cffunction>




<cffunction name="getDataType" returnType="string">
	<cfargument name="sessionid" />
	<cfargument name="varname" />

	<cfset arguments.vardata 	= DebuggerInspect( arguments.sessionid, arguments.varname )>
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

</cfcomponent>