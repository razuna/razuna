<cfsetting showdebugoutput="false" />

<cfsilent>

	<cfset database	= ArrayNew(1)>

	<cfset funcArray = GetSupportedFunctions("")>
	<cfloop array="#funcArray#" index="f">
		<cfset s = StructNew()>
		<cfset s.t	= "f">
		<cfset s.n	= f>
		<cfset ArrayAppend( database, s )>
	</cfloop>

	<cfset tagArray = GetSupportedTags("")>
	<cfloop array="#tagArray#" index="f">
		<cfset s = StructNew()>
		<cfset s.t	= "t">
		<cfset s.n	= f>
		<cfset ArrayAppend( database, s )>
	</cfloop>

	<cfcontent type="text/javascript">

</cfsilent>

var database = <cfoutput>#SerializeJSON( database, true, true )#</cfoutput>;

$(function () {

	$("#searchbox").autocomplete(
		database,
		{matchContains:1,max:15,scroll:false,formatItem:function(item){return item.n;}}
		).result(
			function(event, item) {
				if ( item.t == 'f' ){
					document.location = "./?/function/" + item.n;
				}else{
					document.location = "./?/tag/" + item.n;
				}
			}
	);

});