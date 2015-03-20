<cfsilent>

	<cfset request.simple = true>
	<cfset request.page.title = "CFMLBug: Debugger">
	<cfset request.page.heading = "CFMLBug: Debugger">

</cfsilent><cfinclude template="../inc/header.inc">
<cfinclude template="../inc/nav.inc">

<script>
$D = {

	activeFile : null,
	activeSession	: 0,
	activeLine : 0,

	loadFile: function ( sessionid, page, line ){
		if ( $D.activeFile != page ){
			$D.activeFile	= page;

			if ( sessionid == null )
				sessionid = 0;

			parent.fileframe.location	= requestRoot + "debugger/loadFile.cfm&f=" + escape(page) + "&line=" + line + "&id=" + sessionid + "&_cfmlbug";
		}else if ( sessionid != null && $D.activeFile == page && $D.activeLine != line ){
			$D.activeSession 	= sessionid;
			$D.activeLine			= line;
			parent.fileframe.BreakPointManager.highlightLine( sessionid, line );
		}
	},

	clearSession : function(){
		$D.activeSession = 0;
		if ( typeof(parent.fileframe.BreakPointManager) != "undefined" ){
			parent.fileframe.BreakPointManager.clearSession();
		}
	},

	step : function( sessionid, page ){
		$D.activeSession = sessionid;
		var params = {};
		params.cfc 				= "rpcdebugger.cfc";
		params.method 		= "step";
		params.sessionid 	= sessionid;
		params._cfmlbug 	=	new Date().getTime();
		$.ajax({url:"cfmlbug.cfres?_f=proxy.cfm",data:params,cache: false});
	},

	stepOver : function( sessionid, page ){
		$D.activeSession = sessionid;
		var params = {};
		params.cfc 				= "rpcdebugger.cfc";
		params.method 		= "stepOver";
		params.sessionid 	= sessionid;
		params._cfmlbug 	=	new Date().getTime();
		$.ajax({url:"cfmlbug.cfres?_f=proxy.cfm",data:params,cache: false});
	},

	stepToBP : function( sessionid ){
		$D.activeSession = sessionid;
		var params = {};
		params.cfc 				= "rpcdebugger.cfc";
		params.method 		= "stepToBreakPoint";
		params.sessionid	= sessionid;
		params._cfmlbug 	=	new Date().getTime();
		$.ajax({url:"cfmlbug.cfres?_f=proxy.cfm",data:params,cache: false});
	},

	runToEnd : function( sessionid ){
		$D.activeSession = sessionid;
		var params = {};
		params.cfc 				= "rpcdebugger.cfc";
		params.method 		= "stepToEnd";
		params.sessionid	= sessionid;
		params._cfmlbug 	=	new Date().getTime();
		$.ajax({url:"cfmlbug.cfres?_f=proxy.cfm",data:params,cache: false});
	}

};
</script>

<cfinclude template="../inc/footer.inc">