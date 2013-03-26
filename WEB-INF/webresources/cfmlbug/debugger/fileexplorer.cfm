<cfinclude template="../inc/header.inc">

<script src="<cfoutput>#request.staticroot#</cfoutput>jquery.tree.js"></script>

<table width="100%" class="fileList" cellpadding="0" cellspacing="0">
<tr>
	<th colspan="3"><div id="varname" class="filename">Web Root</div></th>
</tr>
</table>

<div id="fileexplorer"></div>

<script type="text/javascript">
DebuggerFileExplorer = {

	init : function(){
		$("#fileexplorer").tree({
			data : {
				type : "json",async : true,opts : {async : true,method : "GET",url : requestRoot + "proxy.cfm&cfc=file.cfc&method=get&_cfmlbug"}
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
				onselect:function(NODE, TREE_OBJ) {
					DebuggerFileExplorer.selectFile( NODE );
				}
			}
		});
	},

	selectFile : function( node ){
		var f = $( node ).attr("f");
		if ( f != "" )
			parent.topframe.$D.loadFile( null, f, 0 );
	}
};

$(function() {
	DebuggerFileExplorer.init();
});
</script>
<cfinclude template="../inc/footer.inc">