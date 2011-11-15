/*
 * FlowPlayer external configuration file.
 *
 * NOTE! This file is only needed if you don't want to include all configuration
 * in the embedding HTML file. Please see the installation instructions at
 * http://flowpalyer.org
 *
 * Copyright 2005-2008 Anssi Piirainen
 *
 * All settings defined in this file can be alternatively defined in the 
 * embedding HTML object tag (as flashvars variables). Values defined in the
 * object tag override values defined in this file. You could use this 
 * config file to provide defaults for multiple player instances that 
 * are used in a Web site. Individual instances can be then customized 
 * with their embedding HTML.
 *
 * Note that you should probably remove all the comments from this file
 * before using it. That way the file will be smaller and will load faster.
 */
{
	/*
	 * Instructs the player to load the configuration from an external config file.
	 * This can be a abosulte URL or a relative url (relative to the HTML page
	 * where the player is embedded).
	 */
//	configFileName: 'flowPlayer.js',

	/*
	 * Instructs the player to load the configuration from a RTMP server.
	 * The player connects to the server listening in the address specified
	 * by this URL and calls a method 'getStreamPlayerConfig' that should return a
	 * valid FP configuration object.
	 */
//	rtmpConfigUrl: 'rtmp://localhost/myapp',

	/*
	 * A param value to be passed to getStreamPlayerConfig(). A value 'foobar'
	 * will make the player to call getStreamPlayerConfig('foobsr')
	 */
//	rtmpConfigParam: 'anssi',
	
	/*
	 * Name of the video file. Used if only one video is shown.
	 *
	 * Note for testing locally: Specify an empty baseURL '', if you want to load
	 * the video from your local disk from the directory that contains
	 * FlowPlayer.swf. In this case the videoFile parameter value should start
	 * with a slash, for example '/video.flv'.
	 *
	 * See also: 'baseURL' that affects this variable
	 */
//	 videoFile: 'honda_accord.flv',

	/*
	 * Clip to be used if the file specified with 'videoFile' or any of the clips in the playlist
	 * was not found.  The missing video clips are replaced by this clip. This can be
	 * an image or a FLV clip. Typically this will contain an image/video saying
	 * "the video you requested cannot be found.....".
	 *
	 * The syntax for the value is the same is with the clips in a playlist
	 * including the possibility to have start/end and duration properties.
	 *
	 * See also: 'baseURL' that affects this variable
	 */
	 noVideoClip: { url: 'main_clickToPlay.jpg', duration: 10 },
	 //noVideoClip: { url: 'MiltonFriedmanonLimi.flv' },

	/*
	 * Playlist is used to publish several videos using one player instance.
	 * You can also have images in the playlist. The playback pauses in the
	 * image unless a 'duration' property is given for the image:

 * 	 * The clips in the playlist may have following properties:
	 *
	 * name: Name for the clip to be shown in the playlist view. If this is
	 *       not given, the clip will be hidden from the view.
	 *
	 * url: The URL used to load the clip.
	 * 
	 * type: One of 'video', 'flv', 'swf', 'jpg'. Optional, determined from the URL's filename extension
	 *       if that is present. 'video' means a video file in any format supported by Flash.
	 *       'flv' is present here for backward compatibility, use 'video' in new FlowPlayer installations
	 *       now. Defaults to 'video' if the extension is not present in the URL.
	 *
	 * start: The start time (seconds) from where to start the playback. A nonzero
	 *        value can only be used when using a streaming server!!
	 * end: The end time (seconds) where to stop the playback.
	 *
	 * duration: The duration the image is to be shown. If not given the playback
	 *           pauses when the image is reached in the list.
	 * 
	 * protected: (true/false) Apply inlinine linking protection for this clip?
	 *            Optional, defaults to false.
	 * 
	 * linkUrl: Associates a hyperlink pointing to the specified URL. The linked
	 *          document will be opened to the browser when the clip area is clicked.
	 * 			Specifying this parameter will replace the normal pause/resume behavior
	 * 			that is associated to clicking the display area. If you specify an empty
	 * 			linkUrl '' the pause/resume behavior is disabled but no hyperlink
	 * 			is created.
	 * linkWindow: Specifies the name of the browser window or frame into which to load
	 *   the linked document. Can be a custom name or one of presets: '_blank', 
	 *   '_parent', '_self', '_top'. (optional, defaults to '_blank')
	 * 
	 * controlEnabled: (true/false) Enable transport control buttons for this clip?
	 *                 Optional, defaults to true.
	 *
	 * allowResize: (true/false) Allow resizing this clip according to the menu selection.
	 *              Optional, defaults to true.
	 *              
	 * overlay: A filename pointing to an image that will be placed on top of this image clip. This
	 *          is only applicable to image clips (jpg or png files). Essentially this layers two images
	 *          on top of each other. Typically the image on top is a big play button that is used on
	 *          top of an image taken from the main movie.
	 * 
	 * overlayId: ID that specifies a built-in overlay to be used. Currently the player supports
	 * 			  one built-in overlay with ID 'play'. It renders a large play button with mouse hover color change.
	 * 			  You can use this on top of image clips (one clip with both the 'url' property and
	 * 			  'overlayId' property). 
	 * 			  You can also specify a clip that only has this ID. In that
	 * 			  case you should place it immediately before or after a FLV clip. This overlay-only
	 * 			  clip is then rendered on top of the first or the last frame of the FLV video.
	 * 
	 * live: (true/false) Is this a live stream (played from a media server)?
	 * 
	 * showOnLoadBegin: (true/false) If true, make this clip visible when the fist bits have been loaded.
	 * If false, do not show this clip (show the background instead) before the buffer is filled
	 * and the playback starts. Optional, defaults to true.
	 * 
	 * maxPlayCount: The maximum play count for this clip. The clip is removed from the playlist when
	 * the playcount reaches this amount.
	 * 
	 * suggestedClipsInfoUrl:  URL used to fetch suggestions (related videos) information from the server
	 * 
	 * See also: 'baseURL' is prefixed with each URL
	 */
	playList: [
	{ url: 'main_clickToPlay.jpg' },
	{ name: 'Honda Accord', url: '!honda_accord.flv' },
	{ name: 'River', url: 'river.flv' },
	{ name: 'Ounasvaara', url: 'ounasvaara.flv' }
	],
	
	/*
	 * Specifies wether the playlist control buttons should be shown in the player SWF component or not.
	 * Optional, defaults to the value of showPlayList. 
	 */
	showPlayListButtons: true,

	/*
	 * Streaming server connection URL. 
	 * You don't need this with lighttpd, just use the streamingServer setting (see below) with it.
	 */
//	 streamingServerURL: 'rtmp://localahost:oflaDemo',
	
	/* 
	 * baseURL specifies the URL that is appended in front of different file names
	 * given in this file.
	 * 
	 * You don't need to specify this at all if you place the video next to
	 * the player SWF file on the Web server (to be available under the same URL path).
	 */
//	 baseURL: 'http://flowplayer.sourceforge.net/video',
	
	
	/*
	 * What kind of streaming server? Available options: 'fms', 'red5', 'lighttpd'
	 */
//	streamingServer: 'fms',
	
	/*
	 * Specifies whether thumbnail information is contained in the FLV's cue point 
	 * metadata. Cue points can be injected into the FLV file using 
	 * for example Flvtool2. See the FlowPlayer web site for more info.
	 * (optional, defaults to false)
	 * 
	 * See also: cuePoints below for an alternative way of specifying thumb metadata
	 */
//	thumbsOnFLV: true,
	
	/*
	 * Thumbnails specific to cue points. Use this if you don't want to
	 * embed thumbnail metadata into the FLV's cue points. 
	 * If you have thumbNails defined here you should have thumbsOnFLV: false !
	 * thumb times are given in seconds
	 */
// 	thumbs: [
// 	{ thumbNail:  'Thumb1.jpg', time: 10 },
// 	{ thumbNail:  'Thumb2.jpg', time: 24 },
// 	{ thumbNail:  'Thumb3.jpg', time: 54 },
// 	{ thumbNail:  'Thumb4.jpg', time: 74 },
// 	{ thumbNail:  'Thumb5.jpg', time: 94 },
// 	{ thumbNail:  'Thumb6.jpg', time: 110 }
// 	],
	// Location of the thumbnail files
// 	thumbLocation: 'http://www.kolumbus.fi/apiirain/video',
	
	/* 
	 * 'autoPlay' variable defines whether playback begins immediately or not.
	 * 
	 * Note that currently with red5 you should not have false in autoPlay 
	 * when you specify a nonzero starting position for the video clip. This is because red5
	 * does not send FLV metadata when the playback starts from a nonzero value.
	 * 
	 * (optional, defaults to true)
	 */
	autoPlay: true,

	/*
	 * 'autoBuffering' specifies wheter to start loading the video stream into
	 *  buffer memory  immediately. Only meaningful if 'autoPlay' is set to
	 * false. (optional, defaults to true)
	 */
	autoBuffering: true,

	/*
	 * 'startingBufferLength' specifies the video buffer length to be used to kick
	 * off the playback. This is used in the beginning of the playback and every time
	 * after the player has ran out of buffer memory. 
	 * More info at: http://www.progettosinergia.com/flashvideo/flashvideoblog.htm#031205
	 * (optional, defaults to the value of 'bufferLength' setting)
	 * 
	 * see also: bufferLength
	 */
//	startingBufferLength: 5,

	/*
	 * 'bufferLength' specifies the video buffer length in seconds. This is used
	 * after the playback has started with the initial buffer length. You should
	 * use an arbitrary large value here to ensure stable playback.
	 * (optional, defaults to 10 seconds)
	 * 
	 * see also: startingBufferLength
	 */
	bufferLength: 20,

	/*
	 * 'loop' defines whether the playback should loop to the first clip after
	 * all clips in the playlist have been shown. It is used as the
	 * default state of the toggle button that controls looping. (optional,
	 * defaults to true)
	 */
	loop: true,

	/*
	 * Rewind back to the fist clip in the playlist when end of the list has been reached?
	 * This option only has effect if loop is false (please see loop variable above).
	 * (optional, defaults to false)
	 */
	autoRewind: true,
	
	/*
	 * Specifies wether the loop toggle button should be shown in the player SWF component or not.
	 * Optional, defaults to false. 
	 */
//	showLoopButton: true,
	
	/*
	 * Specifies the height to be allocated for the video display. This is the
	 * maximum height available for the different resizing options.
	 */
	videoHeight: 320,
	
	/*
	 * Specifies the width for the control buttons area. Optiona, defaults to the
	 * width setting used in the embedding code. 
	 */
//	controlsWidth: 480,
	
	/*
	 * Specifies how the video is scaled initially. This can be then changed by
	 * the user through the menu. (optional, defaults to 'fit')
	 * Possible values:
	 * 'fit'   Fit to window by preserving the aspect ratios encoded in the FLV metadata.
	 *         This is the default behavior.
	 * 'half'  Half size (preserves aspect ratios)
	 * 'orig'  Use the dimensions encoded in FLV. If the video is too big for the 
	 *         available space the video is scaled as if using the 'fit' option.
	 * 'scale' Scale the video to fill all available space for the video. Ignores
	 *         the dimensions in metadata.
	 * 
	 */
	initialScale: 'fit',
	
	/*
	 * Specifies if the menu containing the size options should be shown or not.
	 * (optional, defaults to true)
//	showMenu: false,
	
	/*
	 * 'hideControls' if set to true, hides all buttons and the progress bar
	 * leaving only the video showing (optional, defaults to false)
	 */
	hideControls: false,

	/*
	 * URL that specifies a base URL that points to a folder containing
	 * images used to skin the player. You must specify this if you intend
	 * to load external button images (see 'loadButtonImages' below).
	 */
	skinImagesBaseURL: 'http://flowplayer.sourceforge.net/resources'

	/*
	 * Will button images be loaded from external files, or will images embedded
	 * in the player SWF component be used? Set this to false if you want to "skin"
	 * the buttons. Optional, defaults to true.
	 * 
	 * NOTE: If you set this to false, you need to have the skin images available
	 * on the server! Otherwise the player will not show up at all or will show
	 * up corrupted.
	 *
	 * See also: 'skinImagesBaseURL' that affects this variable
	 */
//	useEmbeddedButtonImages: false,
	
	/*
	 * 'splashImageFile' specifies an image file to be used as a splash image.
	 * This is useful if 'autoPlay' is set to false and you want to show a
	 * welcome image before the video is played. Should be in JPG format. The
	 * value of 'baseURL' is used similarily as with the video file name and
	 * therefore the video and the image files should be placed in the Web
	 * server next to each other.
	 * 
	 * NOTE: If you set a value for this, you need to have the splash image available
	 * on the server! Otherwise the player will not show up at all or will show
	 * up corrupted.
	 *
	 * NOTE2: You can also specify the splash in a playlist. This is just
	 * an alternative way of doing it. It was preserved for backward compatibility.
	 *
	 * See also: 'baseURL' that affects this variable
	 */
//	splashImageFile: 'main_clickToPlay.jpg',
	
	/*
	 * Should the splash image be scaled to fit the entire video area? If false,
	 * the image will be centered. Optional, defaults to false.
	 */
//	scaleSplash: false,

	/*
	 * 'progressBarColor1' defines the color of the progress bar at the bottom
	 * and top edges. Specified in hexadecimal triplet form indicating the RGB
	 * color component values. (optional)
	 */
//	progressBarColor1: 0xFFFFFF,


	/*
	 * 'progressBarColor2' defines the color in the middle of the progress bar.
	 * The value of this and 'progressBarColor1' variables define the gradient
	 * color fill of the progress bar. (optional)
	 */
//	progressBarColor2: 0xDDFFDD,

	/*
	 * 'bufferBarColor1' defines the color of the buffer size indicator bar at the bottom
	 * and top edges. (optional)
	 */
//	bufferBarColor1: 0xFFFFFF,


	/*
	 * 'bufferBarColor2' defines the color of the buffer size indicator bar in the middle
	 * of the bar. (optional)
	 */
//	bufferBarColor2: 0xDDFFDD,

	/*
	 * 'progressBarBorderColor1' defines the color of the progress bar's border at the bottom
	 * and top edges. (optional)
	 */
//	progressBarBorderColor1: 0xDDDDDD,


	/*
	 * 'progressBarBorderColor2' defines the color of the progress bar's border in the middle
	 * of the bar. (optional)
	 */
//	progressBarBorderColor2: 0xEEEEEE,

	/*
	 * 'bufferingAnimationColor' defines the color of the moving bars used in the buffering 
	 * animation. (optional)
	 */
//	bufferingAnimationColor: 0x0000FF,

	/*
	 * 'controlsAreaBorderColor' defines the color of the border behind buttons and progress bar 
	 * (optional)
	 */
//	controlsAreaBorderColor: 0x1234,

	/*
	 * 'timeDisplayFontColor' defines the color of the progress/duration time display 
	 * (optional)
	 */
//	timeDisplayFontColor: 0xAABBCC,

	/*
	 * Height of the progress bar. (optional)
	 */
//	progressBarHeight: 10,

	/*
	 * Height of the progress bar area. (optional)
	 */
//	progressBarAreaHeight: 10,

	/*
	 * Name of the authentication code file name that is used to prevent inline linking
	 * of video and image files. This can be a complete URL or just a file name relative
	 * to the location from where the player is loaded. (optional, defaults to flowplayer_auth.txt)
	 */
//	authFileName: 'http://www.mytube.org/authCode.txt',

	/*
	 * The URL pointing to a sctipt that opens the player full screen. 
	 * If this is not configured explicitly, the default script, 
	 * http://flowplayer.sourceforge.net/fullscreen.js, is used.
	 */
//	fullScreenScriptURL: 'http://mysite.org/fullscreen.js'

	/**
	 * Specifies which menu items will be show. This is an array that contains a boolean
	 * value for each of the items. By default shows them all except "full screen".
	 */
//	menuItems[
//		true, // show 'Fit to window'
//		true, // show 'Half size'
//		true, // show 'Original size'
//		true, // show 'Fill window'
//		true, // show 'Full screen'
//		false // hide 'Embed...'
//	],


	/*
	 * Specifies wether the full screen button should be shown in the player SWF component or not.
	 * Optional, defaults to true. 
	 */
//	showFullScreenButton: false,

	/*
	 * Use the Flash 9 native full screen mode.
	 */
//	useNativeFullScreen: true,
}

