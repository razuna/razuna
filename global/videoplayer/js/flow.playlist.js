
/**
 * flow.playlist 0.10. Flowplayer playlist script
 * 
 * http://flowplayer.org/tools/flow-playlist.html
 *
 * Copyright (c) 2008 Tero Piirainen (tero@flowplayer.org)
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 * 
 * >> Basically you can do anything you want but leave this header as is <<
 *
 * Version: 0.10 - 05/19/2008
 */ 
(function($) {		
	
	// plugin initialization
	$.fn.extend({
		playlist: function(params, config, opts) { 			
			return this.each(function() {
				new playlist($(this), params, config, opts);
			});
		}		
	});
					
			
	function playlist(root, params, config, playlistOpts) {

		var player = null;

		var opts = {
			playingClass: 'playing',
			pausedClass: 'paused',
			player: '#player',
			loop:false
		}
		
		opts = $.extend(opts, playlistOpts); 		
		
		config = config || {};
		if (typeof params == 'string') params = {src:params};
		 
		if (!$(opts.player).length) {
			alert("flow.playlist not configured properly\nnonexisting element " + opts.player);
			return;
		}
		
		var items = root.children();
		if (items.is(".__scrollable")) items = root.children().children();
		
		items.click(function(event) {	
			
			var el = $(this);
			
			// toggle play pause action
			if (player && el.hasClass(opts.playingClass)) {
				if (player.getIsPaused()) player.DoPlay();
				else player.Pause();
				return false;
			}			
			
			// toggle playing state
			el.parent().find("." + opts.playingClass)
				.removeClass(opts.playingClass)
				.removeClass(opts.pausedClass)
			;
				
			el.addClass(opts.playingClass);
			
			config.videoFile = el.attr("href");
			
			if (player == null) {
				player = flashembed($(opts.player)[0], params, {config:config}); 
				
			} else {
				player.setConfig(config);
			} 
	
			// setup callback methods
			window.onClipDone = function() {
				el.removeClass(opts.playingClass).removeClass(opts.pausedClass);
				
				// move to next entry if it exists
				if (el.next().length) el.next().click();
				
				// else reset player				
				else {
					if (opts.loop) {
						items.eq(0).click();
						
					} else {
						player.DoStop();
						player.Seek(0);
					}
				}
					
				
				// omit player's default behaviour (since version 2.2)
				return false;
			}	  			
	
			window.onPause = function() {
				if (el.hasClass(opts.playingClass)) el.addClass(opts.pausedClass);	
			}
	
			window.onResume = function() {
				el.removeClass(opts.pausedClass);	
			}	
			
			// disable default behaviour
			return false;			
			
		});	
		
		// clicking on the player clicks on the first playlist entry
		$(opts.player).click(function(event) {
			event.preventDefault();
			items.eq(0).click();		
		});			
			
	}
	

})(jQuery);

