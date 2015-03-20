<cfsilent>
	<cfparam name="url.id" default="0">

<cfset activeSessions	= DebuggerGetSessions()>
<cfquery name="thisSession" dbtype="query">select * from activeSessions where id=<cfqueryparam value="#url.id#"></cfquery>

</cfsilent><cfinclude template="../inc/header.inc">



<table width="100%" class="fileList" cellpadding="0" cellspacing="0">
<tr>
	<th colspan="3"><div id="varname" class="filename"><cfoutput query="thisSession"><cfif onexception>Exception &mdash; </cfif>&lt;#tag#&gt; &mdash; #pf# &mdash; @ Line #line#</cfoutput>
	<span style="float:right"><a class="reload" title="reload" href="cfmlbug.cfres?_f=debugger/inspect_middle.cfm&id=<cfoutput>#url.id#</cfoutput>"></a></span></div></th>
</tr>
</table>

<div id="preTree">
	<p align="center" style="margin-top:40px"><em>Please wait while the variable tree is built</em></p>
</div>

<!---
<div class="searchBar">
	<strong>Search Variable Tree</strong><br/><input type="text" id="searchStr" size="14" /> <input type="button" value="&raquo;" onclick="varSearch( $('#searchStr').val() );" />
	<div id="searchHistory"></div>
</div>
--->



<div id="varTree" style="display:none"></div>

<script src="<cfoutput>#request.staticroot#</cfoutput>jquery.tree.js"></script>
<script type="text/javascript">
$(function() {
	$("#varTree").tree({
		data : {
			type : "json",async : true,opts : 
			{async:true,method:"GET",
			url : requestRoot + "proxy.cfm&cfc=inspect.cfc&method=get&_cfmlbug&sid=<cfoutput>#url.id#</cfoutput>"}
		},
		selected : "/",
		ui:{
			theme_name: false
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
		},
		callback:{
			onselect:function(node, treeObj) {
				//var path = $( node ).attr("path");
				//alert(path);
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

inspectVar = function(obj){
	var varname = $(obj).attr("var");
	parent.valueframe.document.location = "cfmlbug.cfres?_f=debugger/inspect_bottom.cfm&v=" + varname + "&sid=<cfoutput>#url.id#</cfoutput>";
};

display = function( v, m ){
	parent.valueframe.document.getElementById("varname").innerHTML = m;
	parent.valueframe.document.getElementById("vardump").innerHTML = document.getElementById(v).innerHTML;
};

varDisp = function( hc ){
	$.tree.focused().close_all();
	$.tree.focused().open_branch( "#" + hc );
};
</script>

<cfinclude template="../inc/footer.inc">