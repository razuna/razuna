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
		<!-- CFC: Get config -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="getconfig('version')" returnvariable="version" />
		<!-- CFC: Get wl -->
		<if condition="application.razuna.whitelabel">
			<true>
				<invoke object="myFusebox.getApplicationData().settings" methodcall="get_options_one_host('wl_login_links_#session.hostid#')" returnvariable="wl" />
				<invoke object="myFusebox.getApplicationData().settings" methodcall="get_options_one_host('wl_html_title_#session.hostid#')" returnvariable="wl_html_title" />
				<invoke object="myFusebox.getApplicationData().settings" methodcall="get_options_one_host('wl_thecss_#session.hostid#')" returnvariable="wl_thecss" />
  			</true>
  		</if>
  		<include template="lay_login" contentvariable="thecontent" />
		<!-- <include template="lay_footer" contentvariable="footercontent" /> -->
  		<include template="lay_index" />
	</fuseaction>
	
	<!--
	This is the layout for the application itself
	-->
	<fuseaction name="lay_mainpage">
		<xfa name="switchlang" value="c.switchlang" />
		<do action="c.languages" />
		<!-- CFC: Set the user id -->
		<set name="attributes.user_id" value="#session.theuserid#" overwrite="false" />
		<!-- CFC: Get the user -->
		<invoke object="myFusebox.getApplicationData().users" methodcall="details(attributes)" returnvariable="qry_detail" />
		<!-- CFC: Get config -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="getconfig('version')" returnvariable="version" />
		<!-- CFC: Get customization -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="get_customization()" returnvariable="cs" />
		<!-- CFC: Get wl -->
		<if condition="application.razuna.whitelabel">
			<true>
				<invoke object="myFusebox.getApplicationData().settings" methodcall="get_options_one_host('wl_razuna_tab_text_#session.hostid#')" returnvariable="wl_text" />
				<invoke object="myFusebox.getApplicationData().settings" methodcall="get_options_one_host('wl_razuna_tab_content_#session.hostid#')" returnvariable="wl_content" />
				<invoke object="myFusebox.getApplicationData().settings" methodcall="get_options_one_host('wl_html_title_#session.hostid#')" returnvariable="wl_html_title" />
				<invoke object="myFusebox.getApplicationData().settings" methodcall="get_options_one_host('wl_feedback_#session.hostid#')" returnvariable="wl_feedback" />
				<invoke object="myFusebox.getApplicationData().settings" methodcall="get_options_one_host('wl_link_search_#session.hostid#')" returnvariable="wl_link_search" />
				<invoke object="myFusebox.getApplicationData().settings" methodcall="get_options_one_host('wl_link_support_#session.hostid#')" returnvariable="wl_link_support" />
				<invoke object="myFusebox.getApplicationData().settings" methodcall="get_options_one_host('wl_link_doc_#session.hostid#')" returnvariable="wl_link_doc" />
				<invoke object="myFusebox.getApplicationData().settings" methodcall="get_options_one_host('wl_thecss_#session.hostid#')" returnvariable="wl_thecss" />
  			</true>
  		</if>
  		<if condition="cs.search_selection">
  			<true>
  				<invoke object="myFusebox.getApplicationData().folders" methodcall="getInSearchSelection()" returnvariable="qry_searchselection" />
  			</true>
  		</if>
		<include template="lay_header" contentvariable="headercontent" />
  		<!-- <include template="lay_menu_top" contentvariable="menucontent" /> -->
		<include template="lay_left" contentvariable="leftcontent" />
		<include template="lay_right" contentvariable="maincontent" />
		<!-- <include template="lay_showcontent" contentvariable="showcontent" /> -->
		<include template="lay_footer" contentvariable="footercontent" />
		<include template="lay_footer_drop" contentvariable="footerdrop" />
  		<include template="lay_main" />
	</fuseaction>
	
	<!--
	Serve Assets
	-->
	<fuseaction name="lay_assets">
  		<include template="lay_showcontent" contentvariable="showcontent" />
  		<include template="lay_assets" />
	</fuseaction>
	
	<!--
	Share: Folder / Collection
	-->
	<fuseaction name="lay_share">
		<xfa name="switchlang" value="c.switchlang" />
		<do action="c.languages" />
		<invoke object="myFusebox.getApplicationData().settings" methodcall="getconfig('version')" returnvariable="version" />
		<include template="lay_header_share" contentvariable="headercontent" />
		<include template="lay_left" contentvariable="leftcontent" />
		<include template="lay_right" contentvariable="maincontent" />
		<include template="lay_footer" contentvariable="footercontent" />
  		<include template="lay_share" />
	</fuseaction>
	
	<!--
	Mini: Login Page
	-->
	<fuseaction name="lay_loginpage_mini">
		<!-- CFC: Get config -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="getconfig('version')" returnvariable="version" />
  		<include template="lay_login_mini" contentvariable="thecontent" />
  		<include template="lay_index_mini" />
	</fuseaction>
	
	<!--
	Mini: Browser
	-->
	<fuseaction name="lay_browser_mini">
  		<include template="lay_browser_mini" contentvariable="thecontent" />
  		<include template="lay_main_mini" />
	</fuseaction>

	<!--
	View: Custom
	-->
	<fuseaction name="lay_view_custom">
  		<!-- <include template="lay_view_custom" contentvariable="maincontent" /> -->
  		<include template="lay_custom" />
	</fuseaction>

	
</circuit>
