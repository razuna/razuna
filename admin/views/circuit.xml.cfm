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
	Show update
	-->
	<fuseaction name="update">
		<include template="dsp_update" contentvariable="body" />
		<do action="l.lay_loginpage" />
	</fuseaction>
	<!--
	The main page 
	-->
	<fuseaction name="main">
		<include template="dsp_menu_left" contentvariable="menuleft" />
		<include template="dsp_main" contentvariable="rightcontent" />
		<include template="dsp_showcontent" contentvariable="showcontent" />
		<do action="l.lay_mainpage" />
	</fuseaction>
	<!--
	Serve Asset 
	-->
	<fuseaction name="serve_asset">
		<include template="dsp_serve_asset" contentvariable="showcontent" />
		<do action="l.lay_assets" />
	</fuseaction>
	
	<!-- Show debug info  -->
	<fuseaction name="debug">
			<include template="dsp_debug"/>
	</fuseaction>
</circuit>
