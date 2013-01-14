<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE circuit>

<circuit access="public">
	<!--
	This is the default action showing the login screen
	-->
	<fuseaction name="login">
		<include template="dsp_login" contentvariable="body" />
		<do action="l.lay_loginpage" />
	</fuseaction>
	<!--
	Show firstime
	-->
	<fuseaction name="firsttime">
		<include template="dsp_firsttime" contentvariable="body" />
		<do action="l.lay_loginpage" />
	</fuseaction>
	<!--
	The main page 
	-->
	<fuseaction name="main">
		<include template="dsp_menu_left" contentvariable="menuleft" />
		<include template="dsp_main" contentvariable="rightcontent" />
		<!-- <include template="dsp_showcontent" contentvariable="showcontent" /> -->
		<do action="l.lay_mainpage" />
	</fuseaction>
	<!--
	Serve Asset 
	-->
	<fuseaction name="serve_asset">
		<include template="dsp_serve_asset" contentvariable="showcontent" />
		<do action="l.lay_assets" />
	</fuseaction>
	<!--
	Gears 
	-->
	<fuseaction name="gears">
		<include template="gears_manifest" />
	</fuseaction>
	<!--
	Share: Folder Page
	-->
	<fuseaction name="share">
		<include template="dsp_share_left" contentvariable="menuleft" />
		<include template="dsp_share" contentvariable="rightcontent" />
		<do action="l.lay_share" />
	</fuseaction>
	<!--
	Share: Login
	-->
	<fuseaction name="share_login">
		<include template="dsp_share_login" contentvariable="body" />
		<do action="l.lay_loginpage" />
	</fuseaction>
	<!--
	MINI: Login
	-->
	<fuseaction name="login_mini">
		<include template="dsp_login_mini" contentvariable="body" />
		<do action="l.lay_loginpage_mini" />
	</fuseaction>
	<!--
	MINI: Browser
	-->
	<fuseaction name="mini_browser">
		<include template="dsp_browser_mini" contentvariable="body" />
		<do action="l.lay_browser_mini" />
	</fuseaction>
	<!--
	VIEW: Custom
	-->
	<fuseaction name="view_custom">
		<include template="dsp_view_custom" contentvariable="maincontent" />
		<do action="l.lay_view_custom" />
	</fuseaction>
</circuit>
