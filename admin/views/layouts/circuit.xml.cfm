<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE circuit>

<circuit access="internal">
	
	<!--
		Apply a standard layout to the result of all display fuseactions.
		This is fine for simple applications that have just one layout but
		for more complicated situations you will either need to move to
		multiple view circuits or a view circuit and a layout circuit and
		may have to explicitly call a layout fuseaction from your other
		display fuseactions.
	
	<postfuseaction>
		<include template="lay_template" />
	</postfuseaction>
	-->
	
	<!--
	This is the layout for the login screen. We load the index page and within that we load the login layout
	-->
	<fuseaction name="lay_loginpage">
  	<include template="lay_login" contentvariable="thecontent" />
  	<include template="lay_index" />
	</fuseaction>
	
	<!--
	This is the layout for the application itself
	-->
	<fuseaction name="lay_mainpage">
		<xfa name="switchlang" value="c.switchlang" />
		<include template="lay_header" contentvariable="headercontent" />
		<include template="lay_left" contentvariable="leftcontent" />
		<include template="lay_right" contentvariable="maincontent" />
		<include template="lay_showcontent" contentvariable="showcontent" />
		<include template="lay_footer" contentvariable="footercontent" />
  	<include template="lay_main" />
	</fuseaction>
	
	<!--
	This is the layout for the DAM-file-selector
	-->
	<fuseaction name="dam_main">
		<include template="lay_dam_main" />
	</fuseaction>
	
	<!--
	Serve Assets
	-->
	<fuseaction name="lay_assets">
  		<include template="lay_showcontent" contentvariable="showcontent" />
  		<include template="lay_assets" />
	</fuseaction>
	
</circuit>
