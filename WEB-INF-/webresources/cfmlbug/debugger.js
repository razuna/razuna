SessionManager = {
		
	aS : {},
		
	setFile : function( sessionid, file, line ){
		if ( typeof(parent.fileframe) == "undefined" || typeof(parent.fileframe.BreakPointManager) == "undefined" || parent.fileframe.BreakPointManager.activeFile != file ){
			setTimeout( function(){
				parent.fileframe.location	= "cfmlbug.cfres?_f=debugger/loadFile.cfm&f=" + escape(file) + "&l=" + line + "&id=" + sessionid + "&_openbddebugger";	
				}, 1 );
		}else{
			parent.fileframe.BreakPointManager.highlightLine( sessionid, line );
		}
	},
	
	inspect : function( id, hash ){
		window.open( "cfmlbug.cfres?_f=debugger/inspect.cfm&id=" + id + "&_cfmlbug", "Session" + hash );
	},
	
	runToEnd : function( id ){
		$("#" + id + " .sessionaction button").attr("disabled","disabled");
		SessionManager.aS[id].wasload = false;
		parent.topframe.$D.runToEnd(id);
	},
	
	step : function( id ){
		$("#" + id + " .sessionaction button").attr("disabled","disabled");
		SessionManager.aS[id].wasload = false;
		parent.topframe.$D.step(id);
	},
	
	stepOver : function( id ){
		$("#" + id + " .sessionaction button").attr("disabled","disabled");
		SessionManager.aS[id].wasload = false;
		parent.topframe.$D.stepOver(id);
	},
	
	stepToBP : function( id ){
		$("#" + id + " .sessionaction button").attr("disabled","disabled");
		SessionManager.aS[id].wasload = false;
		parent.topframe.$D.stepToBP(id);
	},
	
	load : function( id ){
		parent.topframe.$D.loadFile( id, SessionManager.aS[id].f, SessionManager.aS[id].line ); 
	},
	
	refresh : function(){
		var params = {};
		params._cfmlbug = new Date().getTime();
		
		$.ajax({
		  url: "cfmlbug.cfres?_f=debugger/_activesessions.cfm",data:params,cache:false,
		  success: function(html){
				eval( "qry = " + html );
				
				x = qry.rowcount;
				while ( x-- ){
					var sessionId	= qry.data.id[x];
					
					// Store the active session
					if ( !SessionManager.aS.hasOwnProperty( sessionId ) ) {
						SessionManager.aS[ sessionId ] = {wasloaded:false};
					}

					SessionManager.aS[ sessionId ].line 				= qry.data.line[x];
					SessionManager.aS[ sessionId ].f 						= qry.data.f[x];
					SessionManager.aS[ sessionId ].pf 					= qry.data.pf[x];
					SessionManager.aS[ sessionId ].paused 			= qry.data.paused[x];
					SessionManager.aS[ sessionId ].onexception 	= qry.data.onexception[x];
					SessionManager.aS[ sessionId ].tag 					= qry.data.tag[x];
					
					
					var trRow	= $("#" + sessionId );
					
					// Create the Row if it doesn't already exist
					if ( trRow.length == 0 ){
						var trBody = "<tr id='" + sessionId + "' class='session'>";
						
						trBody += "<td nowrap width='1%' class='sessionid'>";
						trBody += sessionId;
						trBody += "</td>"
							
						trBody += "<td class='sessionuri'><a href='javascript:void(null);' onclick='SessionManager.load(";
						trBody += sessionId;
						trBody += ");'>";
						trBody += qry.data.pf[x];
						trBody += "</a></td>"

						trBody += "<td class='sessionstatus'></td>";
						trBody += "<td class='sessionline'></td>";

						trBody += "<td class='sessionaction'>";
						trBody += "<button type='button' class='inspect-show' title='inspect the session variables' onclick='SessionManager.inspect(" + sessionId + ",\"" + sessionId + "-" + qry.data.line[x] + "-" + qry.data.tag[x] + "\");'>inspect</button>";
						trBody += "<button type='button' class='breakpoint' title='run to next breakpoint' onclick='SessionManager.stepToBP(" + sessionId + ");'>breakpoint</button>";
						trBody += "<button type='button' class='step-over' title='run to the next tag/statement on same page' onclick='SessionManager.stepOver(" + sessionId + ");'>step over</button>";
						trBody += "<button type='button' class='step' title='run to the next tag/statement' onclick='SessionManager.step(" + sessionId + ");'>step</button>";
						trBody += "<button type='button' class='request-end' title='run to the request end' onclick='SessionManager.runToEnd(" + sessionId + ");'>request end</button>";
						trBody += "</td>";
							
						trBody += "</tr>";
												
						$('#sessionTable tr:last').after(trBody);
					}
					

					//Update the row
					trRow.find(".sessionline").html( qry.data.line[x] );
					trRow.find(".sessionuri a").html( qry.data.pf[x] );

					if ( qry.data.paused[x] ){
						trRow.find(".sessionstatus").html( "PAUSED" );
						trRow.find(".sessionline").html( qry.data.tag[x] + " @ Line " + qry.data.line[x] );
						trRow.find(".sessionaction button").removeAttr("disabled");
					}else if ( qry.data.onexception[x] ){
						trRow.find(".sessionstatus").html( "EXCEPTION" );
						trRow.find(".sessionline").html( qry.data.tag[x] + " @ Line " + qry.data.line[x] );
						trRow.find(".sessionaction button").removeAttr("disabled");
					}else{
						trRow.find(".sessionstatus").html("");
						trRow.find(".sessionline").html("");
						trRow.find(".sessionaction button").attr("disabled","disabled");
					}
				}

				
				// Remove any of the old ones
				$(".session").each(function(){
					var id = $(this).attr("id");
					
					x = qry.rowcount;
					while ( x-- ){
						if ( qry.data.id[x] == id )
							return;
					}

					delete SessionManager.aS[id];
					$(this).remove();
				});
				
				
				
				// Determine the active session
				if ( parent.topframe.$D.activeSession != 0 ){
					var id = parent.topframe.$D.activeSession;

					if ( !SessionManager.aS.hasOwnProperty( id ) ){
						parent.topframe.$D.clearSession();
					} else if ( !SessionManager.aS[id].wasload ) {
						parent.topframe.$D.loadFile( id, SessionManager.aS[id].f, SessionManager.aS[id].line );
						SessionManager.aS[id].wasload = true;
					}

				}else{
					//no session has been set yet; so let us load in this one
					for ( var x in SessionManager.aS ){
						if ( SessionManager.aS[x]["paused"] ){
							parent.topframe.$D.loadFile( x, SessionManager.aS[x].f, SessionManager.aS[x].line );
							break;
						}
					}
				}
				
				setTimeout( "SessionManager.refresh();", 1500 );
		  }
		});
	}
};



BreakPointManager = {
	activeFile : "",
	activeSession : "",
	
	highlightLine : function( _activeSession, line ){
		var sessJ	= $("#sessionid");
		if ( _activeSession != 0 )
			sessJ.html("(Session " + _activeSession + ")");
		else
			sessJ.html("");

		$(".fileList tr").removeClass("lineHi");
		if ( line != 0 ){
			var lineJ = $("#line" + line);
			lineJ.addClass("lineHi");
			if ( line > 10 )
				$(window).scrollTo( $("#line" + (line-5)) );
		}else{
			if ( line > 10 )
				$(window).scrollTo( sessJ );
		}
	},
	
	clearSession : function(){
		BreakPointManager.activeSession = 0;
		$("#sessionid").html("");
		$(".fileList tr").removeClass("lineHi");
	},
	
	init : function( currentFile, _activeSession ){
		this.activeFile	= currentFile;
		this.activeSession	= _activeSession;
		
		$(".fileList tr").click(function(){
			var	bpPosition	= $(this).attr("lineno");
			var imgTagJQ 		= $(this).find("img");

			if ( imgTagJQ.attr("src") == "cfmlbug-static.cfres?f=img/bp.png" ){
				imgTagJQ.attr("src","cfmlbug-static.cfres?f=img/1x1t.gif");
				BreakPointManager.clearBreakPoint( BreakPointManager.activeFile, bpPosition );
			}else{
				var tagCode = $(this).find(".code pre").html();
				if ( tagCode != "" ){
					imgTagJQ.attr("src","cfmlbug-static.cfres?f=img/bp.png");
					BreakPointManager.setBreakPoint( BreakPointManager.activeFile, bpPosition );
				}
			}
		});
	
	},
	
	clearBreakPoint : function( file, line ){
		var params = {};
		params.cfc 			= "rpcdebugger.cfc";
		params.method 	= "clearBreakPoint";
		params.file			= file;
		params.lineno		= line;
		params._cfmlbug = new Date().getTime();
		
		$.ajax({url: "cfmlbug.cfres?_f=proxy.cfm",data: params,cache: false,
			success: function(html){
				parent.breakpointframe.location	= "cfmlbug.cfres?_f=debugger/breakpoints.cfm&_d=" + new Date().getTime() + "&_cfmlbug";
		  }
		});
		
	},
	
	setBreakPoint : function( file, line ){
		var params 			= {};
		params.cfc 			= "rpcdebugger.cfc";
		params.method 	= "setBreakPoint";
		params.file			= file;
		params.lineno		= line;
		params._cfmlbug = new Date().getTime();
		
		$.ajax({url: "cfmlbug.cfres?_f=proxy.cfm",data: params,cache: false,
		  success: function(html){
				parent.breakpointframe.location	= "cfmlbug.cfres?_f=debugger/breakpoints.cfm&_d=" + new Date().getTime() + "&_cfmlbug";
		  }
		});
		
	},
	
	clearAll : function(){
		if ( !confirm("Are you sure you wish to clear _all_ the breakpoints?") )return;

		var params = {};
		params.method 	= "clearAllBreakPoint";
		params.cfc 			= "rpcdebugger.cfc";
		params._cfmlbug = new Date().getTime();
		
		$.ajax({url: "cfmlbug.cfres?_f=proxy.cfm",data: params,cache: false,
			success: function(html){
				parent.breakpointframe.location	= "cfmlbug.cfres?_f=debugger/breakpoints.cfm&_d=" + new Date().getTime() + "&_cfmlbug";
		  }
		});
	}
};


/**
 * jQuery.ScrollTo - Easy element scrolling using jQuery.
 * Copyright (c) 2007-2009 Ariel Flesler - aflesler(at)gmail(dot)com | http://flesler.blogspot.com
 * Dual licensed under MIT and GPL.
 * Date: 5/25/2009
 * @author Ariel Flesler
 * @version 1.4.2
 *
 * http://flesler.blogspot.com/2007/10/jqueryscrollto.html
 */
;(function(d){var k=d.scrollTo=function(a,i,e){d(window).scrollTo(a,i,e)};k.defaults={axis:'xy',duration:parseFloat(d.fn.jquery)>=1.3?0:1};k.window=function(a){return d(window)._scrollable()};d.fn._scrollable=function(){return this.map(function(){var a=this,i=!a.nodeName||d.inArray(a.nodeName.toLowerCase(),['iframe','#document','html','body'])!=-1;if(!i)return a;var e=(a.contentWindow||a).document||a.ownerDocument||a;return d.browser.safari||e.compatMode=='BackCompat'?e.body:e.documentElement})};d.fn.scrollTo=function(n,j,b){if(typeof j=='object'){b=j;j=0}if(typeof b=='function')b={onAfter:b};if(n=='max')n=9e9;b=d.extend({},k.defaults,b);j=j||b.speed||b.duration;b.queue=b.queue&&b.axis.length>1;if(b.queue)j/=2;b.offset=p(b.offset);b.over=p(b.over);return this._scrollable().each(function(){var q=this,r=d(q),f=n,s,g={},u=r.is('html,body');switch(typeof f){case'number':case'string':if(/^([+-]=)?\d+(\.\d+)?(px|%)?$/.test(f)){f=p(f);break}f=d(f,this);case'object':if(f.is||f.style)s=(f=d(f)).offset()}d.each(b.axis.split(''),function(a,i){var e=i=='x'?'Left':'Top',h=e.toLowerCase(),c='scroll'+e,l=q[c],m=k.max(q,i);if(s){g[c]=s[h]+(u?0:l-r.offset()[h]);if(b.margin){g[c]-=parseInt(f.css('margin'+e))||0;g[c]-=parseInt(f.css('border'+e+'Width'))||0}g[c]+=b.offset[h]||0;if(b.over[h])g[c]+=f[i=='x'?'width':'height']()*b.over[h]}else{var o=f[h];g[c]=o.slice&&o.slice(-1)=='%'?parseFloat(o)/100*m:o}if(/^\d+$/.test(g[c]))g[c]=g[c]<=0?0:Math.min(g[c],m);if(!a&&b.queue){if(l!=g[c])t(b.onAfterFirst);delete g[c]}});t(b.onAfter);function t(a){r.animate(g,j,b.easing,a&&function(){a.call(this,n,b)})}}).end()};k.max=function(a,i){var e=i=='x'?'Width':'Height',h='scroll'+e;if(!d(a).is('html,body'))return a[h]-d(a)[e.toLowerCase()]();var c='client'+e,l=a.ownerDocument.documentElement,m=a.ownerDocument.body;return Math.max(l[h],m[h])-Math.min(l[c],m[c])};function p(a){return typeof a=='object'?a:{top:a,left:a}}})(jQuery);

/**
 * Get the value of a cookie with the given name.
 *
 * @example $.cookie('the_cookie');
 * @desc Get the value of a cookie.
 *
 * @param String name The name of the cookie.
 * @return The value of the cookie.
 * @type String
 *
 * @name $.cookie
 * @cat Plugins/Cookie
 * @author Klaus Hartl/klaus.hartl@stilbuero.de
 */
jQuery.cookie = function(name, value, options) {
    if (typeof value != 'undefined') { // name and value given, set cookie
        options = options || {};
        if (value === null) {
            value = '';
            options.expires = -1;
        }
        var expires = '';
        if (options.expires && (typeof options.expires == 'number' || options.expires.toUTCString)) {
            var date;
            if (typeof options.expires == 'number') {
                date = new Date();
                date.setTime(date.getTime() + (options.expires * 24 * 60 * 60 * 1000));
            } else {
                date = options.expires;
            }
            expires = '; expires=' + date.toUTCString(); // use expires attribute, max-age is not supported by IE
        }
        // CAUTION: Needed to parenthesize options.path and options.domain
        // in the following expressions, otherwise they evaluate to undefined
        // in the packed version for some reason...
        var path = options.path ? '; path=' + (options.path) : '';
        var domain = options.domain ? '; domain=' + (options.domain) : '';
        var secure = options.secure ? '; secure' : '';
        document.cookie = [name, '=', encodeURIComponent(value), expires, path, domain, secure].join('');
    } else { // only name given, get cookie
        var cookieValue = null;
        if (document.cookie && document.cookie != '') {
            var cookies = document.cookie.split(';');
            for (var i = 0; i < cookies.length; i++) {
                var cookie = jQuery.trim(cookies[i]);
                // Does this cookie string begin with the name we want?
                if (cookie.substring(0, name.length + 1) == (name + '=')) {
                    cookieValue = decodeURIComponent(cookie.substring(name.length + 1));
                    break;
                }
            }
        }
        return cookieValue;
    }
};