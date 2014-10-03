<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE circuit>

<circuit access="public" xmlns:cf="cf/">

	<!--
		Default fuseaction for application, uses model and view circuits
		to do all of its work:
	-->
	<fuseaction name="login">
		<!-- XFA -->
		<xfa name="submitform" value="c.dologin" />
		<xfa name="forgotpass" value="c.forgotpass" />
		<xfa name="switchlang" value="c.switchlang" />
		<!-- Params -->
		<set name="attributes.firsttime" value="F" overwrite="false" />
		<set name="attributes.loginerror" value="F" overwrite="false" />
		<set name="attributes.nohost" value="F" overwrite="false" />
		<set name="attributes.choosehost" value="F" overwrite="false" />
		<set name="attributes.pathoneup" value="#pathoneup#" />
	 	<set name="attributes.pathhere" value="#thispath#" />
		<!-- CFC: Check db connection and setup the db for first time
		<invoke object="myFusebox.getApplicationData().hosts" methodcall="checkdb(attributes)" returnvariable="status" /> -->
		<if condition="application.razuna.firsttime">
			<true>
				<set name="attributes.firsttime" value="T" />
				<set name="attributes.host_lang" value="1" />
				<set name="session.hostid" value="1" />
				<xfa name="submitform" value="c.firsttimerun" />
				<set name="attributes.thepath" value="#thispath#" />
				
				<!-- CFC: Check -->
				<invoke object="myFusebox.getApplicationData().defaults" methodcall="getlangsadmin(attributes.thepath)" returnvariable="xml_langs" />
				<do action="v.firsttime" />
			</true>
			<false>
				<!-- CFC: check if db update is there -->
				<do action="update" />
				<!-- Show login page -->
				<do action="v.login" />
			</false>
		</if>
	</fuseaction>
	<!-- 
	GLOBAL Fuseaction for storage
	 -->
	 <fuseaction name="storage">
	 	<if condition="application.razuna.storage EQ 'nirvanix'">
			<true>
				<!-- Get username and password from nirvanix settings -->
				<invoke object="myFusebox.getApplicationData().settings" methodcall="prefs_storage()" returnvariable="attributes.qry_settings_nirvanix" />
				<!-- Get session token -->
				<invoke object="myFusebox.getApplicationData().Nirvanix" methodcall="login(attributes)" returnvariable="attributes.nvxsession" />
				<!-- Set child name -->
				<set name="attributes.nvxname" value="#attributes.qry_settings_nirvanix.set2_nirvanix_name#" />
			</true>
		</if>
	</fuseaction>
	<!--
		Check the login, write a log entry and let the user in or not
	-->
	<fuseaction name="dologin">
		<!-- Params -->
		<set name="attributes.passsend" value="F" overwrite="false" />
		<set name="attributes.rem_login" value="F" overwrite="false" />
		<set name="attributes.loginto" value="admin" overwrite="false" />
		<!-- Check the user and let him in ot nor -->
		<invoke object="myFusebox.getApplicationData().Login" methodcall="login(attributes)" returnvariable="logindone" />
		<!-- Log this action -->
		<if condition="logindone.notfound EQ 'F'">
    		<true>
				<!-- check groups -->
				<invoke object="myFusebox.getApplicationData().groups" methodcall="getdetail('SystemAdmin')" returnvariable="qry_sysadmingrp" />
				<invoke object="myFusebox.getApplicationData().groups" methodcall="getdetail('Administrator')" returnvariable="qry_admingrp" />
				<invoke object="myFusebox.getApplicationData().groups_users" methodcall="getGroupsOfUser(logindone.qryuser.user_id)" returnvariable="qry_groups_user" />
				<!-- init with dummy host 0 -->
				<invoke object="myFusebox.getApplicationData().security" methodcall="initUser(0,logindone.qryuser.user_id,'adm')" returnvariable="Request.securityobj" />
				<!-- <relocate url="#myself#c.choosehost" /> -->
				<do action="choosehost" />
			</true>
			<false>
		   		<!-- <set name="attributes.loginerror" value="T" /> -->
		   		<relocate url="#myself#c.logoff&amp;loginerror=T" />
		   	</false>
		</if>
	</fuseaction>
	<!-- Choose the Host -->
	<fuseaction name="choosehost">
		<!-- Check in how many hosts this user is in -->
		<set name="attributes.user_id" value="#session.theuserid#" />
		<invoke object="myFusebox.getApplicationData().users" methodcall="userhosts(attributes)" returnvariable="userhosts" />
		<!-- Params -->
		<set name="session.hostdbprefix" value="#userhosts.host_shard_group#" />
		<set name="session.hostid" value="#userhosts.host_id#" />
		<set name="session.host_count" value="1" />
		<!-- Relocate -->
		<relocate url="#myself#c.main&amp;_v=#createuuid('')#" />
		<!-- Show -->
		<!-- <do action="ajax.choosehost" /> -->
	</fuseaction>
	<!--
		If host is chosen
	-->
	<fuseaction name="sethost">
		<!-- Get the host settings -->
		<invoke object="myFusebox.getApplicationData().Hosts" methodcall="getdetail(attributes)" returnvariable="qry_host" />
		<!-- Set Sessions -->
		<set name="session.hostdbprefix" value="#qry_host.host_shard_group#" />
		<set name="session.hostid" value="#qry_host.host_id#" />
		<set name="session.host_count" value="0" />
		<!-- Go Main
		<relocate url="index.cfm?fa=c.main&amp;c=#createuuid()#" /> -->
		<!-- Go to action according to variable -->
		<if condition="#rto# EQ 'c.users'">
			<true>
				<do action="users" />
			</true>
		</if>
		<if condition="#rto# EQ 'c.groups'">
			<true>
				<do action="groups" />
			</true>
		</if>
		<if condition="#rto# EQ 'c.prefs'">
			<true>
				<do action="prefs" />
			</true>
		</if>
		<!-- <do action="main" /> -->
	</fuseaction>
	<!--
		For the main layout queries and settings
	 -->
	 <fuseaction name="main">
	 	<!-- Get the host settings
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="allsettings_2()" returnvariable="thisurl" /> -->
		<!-- Get Wisdom phrases -->
		<invoke object="myFusebox.getApplicationData().global" methodcall="wisdom()" returnvariable="wisdom" />
		<!-- Get all hosts -->
		<invoke object="myFusebox.getApplicationData().global" methodcall="allhosts()" returnvariable="qry_allhosts" />
		<!-- CFC: Check for application setup -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="applicationcheck()" returnvariable="appcheck" />
		<!-- CFC: Check if a new version is available -->
		<invoke object="myFusebox.getApplicationData().update" methodcall="check_update()" returnvariable="newversion" />
		<!-- Show main page -->
	 	<do action="v.main" />
	 </fuseaction>
	 <!--
		INDEXPAGE: System Checklist
	 -->
	 <fuseaction name="mainchecklist">
		<!-- Check for installation reuqirements -->
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="allsettings_2()" returnvariable="chklist_settings" />
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="get_tools()" returnvariable="tools" />
		<!-- Show main page -->
	 	<do action="ajax.mainchecklist" />
	 </fuseaction>
	 <!--
		INDEXPAGE: Blog
	 -->
	 <fuseaction name="mainblog">
		<!-- CFC: Parse RSS Feed -->
		<invoke object="myFusebox.getApplicationData().rssparser" methodcall="rssparse('http://blog.razuna.com/feed',10)" returnvariable="blogss" />
		<!-- Show main page -->
	 	<do action="ajax.mainblog" />
	 </fuseaction>

	<!--
		User forgot his password (which happens quite often)
	 -->
	<fuseaction name="forgotpass">
		<xfa name="submitform" value="c.forgotpasssend" />
		<xfa name="linkback" value="c.login" />
		<set name="attributes.emailnotfound" value="F" overwrite="false" />
		<set name="attributes.passsend" value="F" overwrite="false" />
		<do action="ajax.forgotpass" />
	</fuseaction>
	<!--
		User forgot his password so we send the password now
	 -->
	<fuseaction name="forgotpasssend">
		<!-- Param -->
		<set name="attributes.emailnotfound" value="F" overwrite="false" />
		<set name="attributes.passsend" value="F" overwrite="false" />
		<!-- Check the email address of the user -->
		<invoke object="myFusebox.getApplicationData().Login" methodcall="sendpassword(attributes.email)" returnvariable="status" />
		<!-- If the user is found an email has been sent thus return to the main layout with a message -->
		<if condition="status.notfound EQ 'F'">
    		<true>
				<set name="attributes.passsend" value="T" />
			</true>
			<false>
				<set name="attributes.emailnotfound" value="T" />
			</false>
		</if>
		<!-- Show -->
		<do action="ajax.forgotpassfeedback" />
	</fuseaction>
	<!--
		User switches language
	 -->
	<fuseaction name="switchlang">
		<invoke object="myFusebox.getApplicationData().global" methodcall="switchlang(attributes.thelang)" />
		<!-- <set name="attributes.to" value="" /> -->
		<if condition="attributes.to EQ 'index'">
    		<true>
				<do action="login" />
			</true>
			<false>
				<do action="main" />
			</false>
		</if>
	</fuseaction>
	<!--
		Logoff
	 -->
	<fuseaction name="logoff">
		<set name="session.login" value="F" />
		<set name="session.weblogin" value="F" />
		<set name="session.thegroupofuser" value="" />
		<set name="session.theuserid" value="" />
		<set name="session.thedomainid" value="" />
		<do action="login" />
	</fuseaction>
	
	<!-- 
	GLOBAL Fuseaction for Languages
	 -->
	 <fuseaction name="languages">
		<!-- Get languages -->
		<invoke object="myFusebox.getApplicationData().defaults" methodcall="getlangs()" returnvariable="qry_langs" />
	</fuseaction>
	
	<!-- Get Path to Assets -->
	<fuseaction name="assetpath">
		<invoke object="myFusebox.getApplicationData().settings" method="assetpath" returnvariable="attributes.assetpath" />
	</fuseaction>
	
	<!--  -->
	<!-- START: FIRSTTIME -->
	<!--  -->
	
	<!-- database -->
	<fuseaction name="first_time_database">
		<!-- Set sessions -->
		<set name="session.firsttime.type" value="custom" />
		<!-- Show -->
		<do action="ajax.first_time_database" />
	</fuseaction>
	<!-- paths -->
	<fuseaction name="first_time_paths">
		<!-- Set sessions -->
		<set name="session.firsttime.database" value="#attributes.db#" overwrite="false" />
		<set name="session.firsttime.database_type" value="#attributes.db#" overwrite="false" />
		<set name="session.firsttime.type" value="#attributes.type#" overwrite="false" />
		<set name="session.firsttime.path_assets" value="#pathoneup#assets" />
		<set name="session.firsttime.ecp_path" value="#pathoneup#" />
		<!-- If we are a standard installation with H2 -->
		<if condition="#attributes.type# EQ 'standard'">
			<true>
				<set name="session.firsttime.db_action" value="create" />
				<set name="session.firsttime.db_name" value="razuna" />
				<set name="session.firsttime.db_server" value="" />
				<set name="session.firsttime.db_port" value="0" />
				<set name="session.firsttime.db_schema" value="razuna" />
				<set name="session.firsttime.db_user" value="razuna" />
				<set name="session.firsttime.db_pass" value="razunabd" />
				<set name="session.firsttime.database_type" value="h2" />
				<!-- CFC: Check if there is a DB Connection -->
				<invoke object="myFusebox.getApplicationData().global" methodcall="checkdatasource()" returnvariable="thedsnarray" />
				<!-- If there is no H2 datasource then create it -->
				<if condition="#arrayisempty(thedsnarray)#">
					<true>
						<!-- CFC: Add the datasource -->
						<invoke object="myFusebox.getApplicationData().global" methodcall="setdatasource()" />
					</true>
				</if>
			</true>
		</if>
		<!-- Show -->
		<do action="ajax.first_time_paths" />
	</fuseaction>
	<!-- paths app check -->
	<fuseaction name="check_paths">
		<!-- CFC: Check paths -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="checkapp(attributes)" />
	</fuseaction>
	<!-- user account -->
	<fuseaction name="first_time_account">
		<!-- Set sessions -->
		<set name="session.firsttime.path_im" value="#attributes.path_imagemagick#" />
		<set name="session.firsttime.path_ffmpeg" value="#attributes.path_ffmpeg#" />
		<set name="session.firsttime.path_exiftool" value="#attributes.path_exiftool#" />
		<set name="session.firsttime.path_dcraw" value="#attributes.path_dcraw#" />
		<set name="session.firsttime.path_mp4box" value="#attributes.path_mp4box#" />
		<!-- Show -->
		<do action="ajax.first_time_account" />
	</fuseaction>
	<!-- db setup -->
	<fuseaction name="first_time_database_config">
		<!-- Set sessions -->
		<set name="session.firsttime.database" value="#attributes.db#" />
		<set name="session.firsttime.database_type" value="#attributes.db#" />
		<!-- If this is for H2 -->
		<if condition="attributes.db EQ 'H2'">
			<true>
				<!-- Set attributes -->
				<set name="attributes.db_name" value="razuna" />
				<set name="attributes.db_server" value="" />
				<set name="attributes.db_port" value="0" />
				<set name="attributes.db_schema" value="razuna" />
				<set name="attributes.db_user" value="razuna" />
				<set name="attributes.db_pass" value="razunabd" />
				<!-- CFC: Check if there is a DB Connection -->
				<invoke object="myFusebox.getApplicationData().global" methodcall="checkdatasource()" returnvariable="thedsnarray" />
				<!-- If there is no H2 datasource then create it -->
				<if condition="arrayisempty(thedsnarray)">
					<true>
						<set name="session.firsttime.db_action" value="create" />
						<set name="session.firsttime.db_name" value="razuna" />
						<set name="session.firsttime.db_server" value="" />
						<set name="session.firsttime.db_port" value="0" />
						<set name="session.firsttime.db_schema" value="razuna" />
						<set name="session.firsttime.db_user" value="razuna" />
						<set name="session.firsttime.db_pass" value="razunabd" />
						<set name="session.firsttime.database_type" value="h2" />
						<!-- CFC: Add the datasource -->
						<invoke object="myFusebox.getApplicationData().global" methodcall="setdatasource()" />
					</true>
				</if>
				<!-- Show -->
				<do action="first_time_database_done" />
			</true>
			<false>
				<!-- Set sessions -->
				<set name="session.firsttime.db_action" value="create" />
				<set name="session.firsttime.db_name" value="" />
				<set name="session.firsttime.db_server" value="" />
				<set name="session.firsttime.db_port" value="" />
				<set name="session.firsttime.db_schema" value="" />
				<set name="session.firsttime.db_user" value="" />
				<set name="session.firsttime.db_pass" value="" />
				<!-- CFC: Check if there is a DB Connection -->
				<invoke object="myFusebox.getApplicationData().global" methodcall="checkdatasource()" returnvariable="thedsnarray" />
				<!-- Show -->
				<do action="ajax.first_time_database_config" />
			</false>
		</if>
	</fuseaction>
	<!-- db setup check -->
	<fuseaction name="first_time_database_check">
		<!-- Set values from form into the sessions -->
		<set name="session.firsttime.db_name" value="#attributes.db_name#" />
		<set name="session.firsttime.db_server" value="#attributes.db_server#" />
		<set name="session.firsttime.db_port" value="#attributes.db_port#" />
		<set name="session.firsttime.db_schema" value="#attributes.db_schema#" />
		<set name="session.firsttime.db_user" value="#attributes.db_user#" />
		<set name="session.firsttime.db_pass" value="#attributes.db_pass#" />
		<!-- CFC: Add the datasource -->
		<invoke object="myFusebox.getApplicationData().global" methodcall="setdatasource()" />
		<!-- CFC: Check if there is a DB Connection -->
		<invoke object="myFusebox.getApplicationData().global" methodcall="verifydatasource()" returnvariable="theconnection" />
		<!-- Show -->
		<do action="ajax.first_time_database_check" />
	</fuseaction>
	<!-- db setup restore -->
	<fuseaction name="first_time_database_restore">
		<!-- Params -->
		<set name="attributes.hostid" value="0" />
		<!-- CFC -->
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="get_backup(attributes.hostid)" returnvariable="qry_backup" />
		<!-- Show -->
		<do action="ajax.first_time_database_restore" />
	</fuseaction>
	<!-- db setup restore upload div -->
	<fuseaction name="first_time_database_restore_div">
		<!-- XFA -->
		<xfa name="uploadto" value="c.first_time_database_restore_upload" />
		<!-- Show -->
		<do action="ajax.prefs_backup_restore_upload" />
	</fuseaction>
	<!-- db setup restore upload -->
	<fuseaction name="first_time_database_restore_upload">
		<!-- Params for backup -->
		<set name="application.razuna.thedatabase" value="#session.firsttime.database#" />
		<set name="application.razuna.theschema" value="#session.firsttime.db_schema#" />
		<!-- Params for creating DB -->
		<set name="session.firsttime.path_assets" value="" />
		<set name="session.firsttime.path_im" value="" />
		<set name="session.firsttime.path_ffmpeg" value="" />
		<set name="session.firsttime.path_exiftool" value="" />
		<set name="session.firsttime.path_dcraw" value="" />
		<set name="session.firsttime.path_mp4box" value="" />
		<set name="attributes.user_email" value="" />
		<set name="attributes.user_pass" value="" />
		<set name="attributes.user_login_name" value="" />
		<set name="attributes.user_first_name" value="" />
		<set name="attributes.user_last_name" value="" />
		<set name="attributes.restore" value="t" />
		<!-- Setup the DB -->
		<do action="first_time_final_include" />
		<!-- Restore Upload -->
		<do action="prefs_restore_upload" />
	</fuseaction>
	<!-- db setup restore from system -->
	<fuseaction name="first_time_database_restore_system">
		<!-- Params for backup -->
		<set name="application.razuna.thedatabase" value="#session.firsttime.database#" />
		<set name="application.razuna.datasource" value="#session.firsttime.database#" />
		<set name="application.razuna.theschema" value="#session.firsttime.db_schema#" />
		<!-- Params for creating DB -->
		<set name="session.firsttime.path_assets" value="" />
		<set name="session.firsttime.path_im" value="" />
		<set name="session.firsttime.path_ffmpeg" value="" />
		<set name="session.firsttime.path_exiftool" value="" />
		<set name="session.firsttime.path_dcraw" value="" />
		<set name="session.firsttime.path_mp4box" value="" />
		<set name="attributes.user_email" value="" />
		<set name="attributes.user_pass" value="" />
		<set name="attributes.user_login_name" value="" />
		<set name="attributes.user_first_name" value="" />
		<set name="attributes.user_last_name" value="" />
		<set name="attributes.restore" value="t" />
		<!-- Setup the DB -->
		<do action="first_time_final_include" />
		<!-- Restore -->
		<do action="prefs_restore_do" />
	</fuseaction>
	<!-- db setup done -->
	<fuseaction name="first_time_database_done">
		<!-- Set sessions -->
		<set name="session.firsttime.db_name" value="#attributes.db_name#" />
		<set name="session.firsttime.db_server" value="#attributes.db_server#" />
		<set name="session.firsttime.db_port" value="#attributes.db_port#" />
		<set name="session.firsttime.db_schema" value="#attributes.db_schema#" />
		<set name="session.firsttime.db_user" value="#attributes.db_user#" />
		<set name="session.firsttime.db_pass" value="#attributes.db_pass#" />
		<!-- Show -->
		<do action="ajax.first_time_database_setup" />
	</fuseaction>
	<!-- final -->
	<fuseaction name="first_time_final">
		<!-- Include DB setup -->
		<do action="first_time_final_include" />
		<!-- Show -->
		<do action="ajax.first_time_done" />
	</fuseaction>
	<!-- final include -->
	<fuseaction name="first_time_final_include">
		<!-- Params -->
		<set name="application.razuna.theschema" value="#session.firsttime.db_schema#" />
		<set name="application.razuna.thedatabase" value="#session.firsttime.database#" />
		<set name="application.razuna.datasource" value="#session.firsttime.database#" />
		<set name="attributes.dsn" value="#session.firsttime.database#" />
		<set name="attributes.theschema" value="#session.firsttime.db_schema#" />
		<set name="attributes.host_db_prefix" value="raz1_" />
		<set name="attributes.database" value="#session.firsttime.database#" />
		<set name="attributes.host_lang" value="1" />
		<set name="attributes.langs_selected" value="1_English" />
		<set name="attributes.pathhere" value="#thispath#" />
		<set name="attributes.pathoneup" value="#pathoneup#" />
		<set name="attributes.path_assets" value="#session.firsttime.path_assets#" />
		<set name="attributes.email_from" value="#attributes.user_email#" />
		<set name="attributes.host_path" value="raz1" />
		<set name="attributes.from_first_time" value="true" />
		<set name="attributes.host_name" value="Demo" />
		<set name="attributes.imagemagick" value="#session.firsttime.path_im#" />
		<set name="attributes.ffmpeg" value="#session.firsttime.path_ffmpeg#" />
		<set name="attributes.exiftool" value="#session.firsttime.path_exiftool#" />
		<set name="attributes.dcraw" value="#session.firsttime.path_dcraw#" />
		<set name="attributes.mp4box" value="#session.firsttime.path_mp4box#" />
		<!-- Update the global config file with the new datasource -->
		<set name="attributes.conf_database" value="#session.firsttime.database#" />
		<set name="attributes.conf_schema" value="#session.firsttime.db_schema#" />
		<set name="attributes.conf_datasource" value="#session.firsttime.database#" />
		<!-- Save general settings -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="update_global(attributes)" />
		<!-- Remove all data in the db, in case it is here -->
		<invoke object="myFusebox.getApplicationData().hosts" methodcall="cleardb()" />
		<!-- Setup & create host & add host -->
		<invoke object="myFusebox.getApplicationData().hosts" methodcall="setupdb(attributes)" />
		<!-- Save tools settings -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="update_tools(attributes)" />
		<!-- CFC: Set internal firsttime value to false -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="firsttime_false('false')" />
		<!-- CFC: Set update db -->
		<invoke object="myFusebox.getApplicationData().update" methodcall="setoptionupdate()" />
		<!-- Add Razuna Client db connection -->
		<set name="session.firsttime.database" value="razuna_client" />
		<set name="session.firsttime.database_type" value="mysql" />
		<set name="session.firsttime.db_name" value="razuna_clients" />
		<set name="session.firsttime.db_server" value="db.razuna.com" />
		<set name="session.firsttime.db_port" value="3306" />
		<set name="session.firsttime.db_user" value="razuna_client" />
		<set name="session.firsttime.db_pass" value="D63E61251" />
		<set name="session.firsttime.db_action" value="create" />
		<!-- CFC: Add the datasource -->
		<invoke object="myFusebox.getApplicationData().global" methodcall="setdatasource()" />
	</fuseaction>
	
	<!-- Call firsttime run -->
	<fuseaction name="firsttimerun">
		<!-- Add default values for the demo host -->
		<set name="attributes.firsttime" value="T" />
		<set name="attributes.folder_in" value="#attributes.theurl##dynpath#/raz1/dam/incoming" />
		<set name="attributes.folder_in_batch" value="#attributes.theurl##dynpath#/raz1/dam/incoming_batch" />
		<set name="attributes.folder_out" value="#attributes.theurl##dynpath#/raz1/dam/outgoing" />
		<set name="attributes.host_name" value="Demo" />
		<set name="attributes.host_path" value="raz1" />
		<set name="attributes.host_db_prefix" value="raz1" />
		<set name="attributes.host_lang" value="1" />
		<set name="attributes.set_lang_1" value="Language" />
		<set name="attributes.name" value="#attributes.user_login_name#" />
		<set name="attributes.pass" value="#attributes.user_pass#" />
		<!-- CFC: Add Host -->
		<invoke object="myFusebox.getApplicationData().hosts" methodcall="add(attributes)" />
		<!-- Show confirmation -->
		<do action="ajax.first_time_done" />
		<!-- <set name="attributes.firsttime" value="F" />
		<do action="dologin" /> -->
	</fuseaction>


	<!--  -->
	<!-- END: FIRSTTIME -->
	<!--  -->

	<!--  -->
	<!-- START: PLUGINS -->
	<!--  -->

	<!-- Load -->
	<fuseaction name="plugins">
		<!-- Assetpath -->
		<set name="attributes.pathoneup" value="#pathoneup#" />
		<!-- CFC: Get all plugins -->
		<invoke object="myFusebox.getApplicationData().plugins" methodcall="getall(attributes.pathoneup)" returnvariable="qry_plugins" />
		<!-- Show -->
		<do action="ajax.plugins" />
	</fuseaction>
	<!-- Activate/Deactivate -->
	<fuseaction name="plugins_onoff">
		<!-- CFC: Activate or not -->
		<invoke object="myFusebox.getApplicationData().plugins" methodcall="setactive(attributes.pid,attributes.active,'#pathoneup#')" />
		<!-- Reload the page -->
		<do action="plugins" />
	</fuseaction>
	<!-- remove -->
	<fuseaction name="plugins_remove">
		<!-- CFC: Activate or not -->
		<invoke object="myFusebox.getApplicationData().plugins" methodcall="remove(attributes.id)" />
		<!-- Reload the page -->
		<do action="plugins" />
	</fuseaction>
	<!-- Get Plugins Host -->
	<fuseaction name="plugins_hosts">
		<!-- Get all hosts -->
		<invoke object="myFusebox.getApplicationData().global" methodcall="allhosts()" returnvariable="qry_allhosts" />
		<!-- CFC: Get all plugins from DB only -->
		<invoke object="myFusebox.getApplicationData().plugins" methodcall="getalldb(active='true')" returnvariable="qry_plugins" />
		<!-- CFC: Get all plugins who are selected for the hosts -->
		<invoke object="myFusebox.getApplicationData().plugins" methodcall="getpluginshosts()" returnvariable="qry_plugins_hosts" />
		<!-- Show -->
		<do action="ajax.plugins_hosts" />
	</fuseaction>
	<!-- Get Plugins Host -->
	<fuseaction name="plugins_hosts_saves">
		<!-- CFC: Save host plugins -->
		<invoke object="myFusebox.getApplicationData().plugins" methodcall="setpluginshosts(attributes)" />
	</fuseaction>
	<!-- Get Plugins Host -->
	<fuseaction name="plugins_upload">
		<!-- CFC: Save host plugins -->
		<invoke object="myFusebox.getApplicationData().plugins" methodcall="upload(attributes)" />
		<do action="ajax.plugins_upload" />
	</fuseaction>

	<!--  -->
	<!-- END: PLUGINS -->
	<!--  -->

	<!--  -->
	<!-- START: PREFERENCES -->
	<!--  -->

	<!-- Load preferences -->
	<fuseaction name="prefs">
		<!-- XFA -->
		<xfa name="rto" value="c.prefs" />
		<!-- Get all hosts -->
		<invoke object="myFusebox.getApplicationData().global" methodcall="allhosts()" returnvariable="qry_allhosts" />
		<!-- Show -->
		<do action="ajax.prefs" />
	</fuseaction>
	<!-- Pref Global -->
	<fuseaction name="prefs_global">
		<!-- CFC: Load all the preferences -->
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="allsettings()" returnvariable="qry_allsettings" />
		<!-- CFC -->
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="prefs_global()" returnvariable="prefs" />
		<!-- CFC: Get Languages -->
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="lang_get()" returnvariable="qry_langs" />
		<!-- Show -->
		<do action="ajax.prefs_global" />
	</fuseaction>
	<!-- Pref Meta -->
	<fuseaction name="prefs_meta">
		<!-- Languages -->
		<do action="languages" />
		<!-- CFC -->
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="prefs_meta()" returnvariable="prefs" />
		<!-- Show -->
		<do action="ajax.prefs_meta" />
	</fuseaction>
	<!-- Pref DAM -->
	<fuseaction name="prefs_dam">
		<!-- Languages -->
		<do action="languages" />
		<!-- CFC -->
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="prefs_dam()" returnvariable="prefs" />
		<!-- Show -->
		<do action="ajax.prefs_dam" />
	</fuseaction>
	<!-- Pref Website -->
	<fuseaction name="prefs_web">
		<!-- CFC -->
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="prefs_web()" returnvariable="prefs" />
		<!-- Show -->
		<do action="ajax.prefs_web" />
	</fuseaction>
	<!-- Pref Image -->
	<fuseaction name="prefs_image">
		<!-- Variables -->
		<set name="set2_create_imgfolders_where" value="0" overwrite="false" />
		<!-- CFC -->
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="prefs_image()" returnvariable="prefs" />
		<!-- Show -->
		<do action="ajax.prefs_image" />
	</fuseaction>
	<!-- Pref Video -->
	<fuseaction name="prefs_video">
		<!-- Variables -->
		<set name="set2_create_vidfolders_where" value="0" overwrite="false" />
		<!-- CFC -->
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="prefs_video()" returnvariable="prefs" />
		<!-- Show -->
		<do action="ajax.prefs_video" />
	</fuseaction>
	<!-- Pref Oracle -->
	<fuseaction name="prefs_oracle">
		<!-- CFC -->
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="prefs_oracle()" returnvariable="prefs" />
		<!-- Show -->
		<do action="ajax.prefs_oracle" />
	</fuseaction>
	<!-- Save preferences -->
	<fuseaction name="prefs_save">
		<!-- CFC: Save Langs -->
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="lang_save(attributes)" />
		<!-- CFC: Save preferences -->
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="update(attributes)" />
		<!-- <do action="prefs" /> -->
	</fuseaction>
	<!-- Image Upload -->
	<fuseaction name="prefs_imgupload">
		<set name="attributes.uploadnow" value="F" overwrite="false" />
		<!-- CFC: Upload file -->
		<if condition="#attributes.uploadnow# EQ 'T'">
			<true>
				<!-- CFC: If we want to upload the watermark file take another method -->
				<if condition="#attributes.thefield# EQ 'set2_watermark'">
					<true>
						<invoke object="myFusebox.getApplicationData().settings" methodcall="upload_watermark(attributes)" returnvariable="result" />
					</true>
					<false>
						<invoke object="myFusebox.getApplicationData().settings" methodcall="upload(attributes)" returnvariable="result" />
					</false>
				</if>
			</true>
		</if>
		<!-- Show  -->
		<do action="ajax.prefs_imgupload" />
	</fuseaction>
	<!-- Pref Storage -->
	<fuseaction name="prefs_storage">
		<!-- CFC -->
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="prefs_storage()" returnvariable="prefs" />
		<!-- Show -->
		<do action="ajax.prefs_storage" />
	</fuseaction>
	<!-- Validate: Nirvanix -->
	<fuseaction name="prefs_nvx_validate">
		<!-- Param -->
		<set name="attributes.qry_settings_nirvanix.set2_nirvanix_name" value="#attributes.nvxname#" />
		<set name="attributes.qry_settings_nirvanix.set2_nirvanix_pass" value="#attributes.nvxpass#" />
		<set name="attributes.nvxappkey" value="#application.razuna.nvxappkey#" />
		<!-- CFC -->
		<invoke object="myFusebox.getApplicationData().Nirvanix" methodcall="validate(attributes)" />
	</fuseaction>
	<!-- Update Languages from XML -->
	<fuseaction name="prefs_update_langs">
		<!-- CFC: Get path of this host -->
		<invoke object="myFusebox.getApplicationData().defaults" methodcall="hostpath()" returnvariable="hostpath" />
		<!-- Create path -->
		<set name="attributes.thepath" value="#pathoneup##hostpath#/dam" />
		<set name="attributes.fromadmin" value="T" />
		<!-- CFC -->
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="lang_get_langs(attributes)" />
		<!-- Show -->
		<do action="prefs_global" />
	</fuseaction>
	<!-- User changes database (reset to firsttime) -->
	<fuseaction name="prefs_change_db">
		<!-- CFC -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="firsttime_false('true')" />
		<!-- Relocate to index page -->
		<do action="ajax.redirector" />
	</fuseaction>
	
	

	<!--  -->
	<!-- END: PREFERENCES -->
	<!--  -->

	<!--  -->
	<!-- START: GLOBAL PREFERENCES -->
	<!--  -->

	<!-- Load preferences -->
	<fuseaction name="prefs_global_main">
		<!-- Show -->
		<do action="ajax.prefs_global_main" />
	</fuseaction>
	<!-- Pref Types -->
	<fuseaction name="prefs_types">
		<!-- CFC -->
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="prefs_types()" returnvariable="prefs" />
		<!-- Show -->
		<do action="ajax.prefs_types" />
	</fuseaction>
	<!-- Add Pref Types -->
	<fuseaction name="prefs_types_add">
		<!-- CFC: Add type -->
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="prefs_types_add(attributes)" />
		<!-- Show -->
		<do action="prefs_types" />
	</fuseaction>
	<!-- Remove Pref Types -->
	<fuseaction name="prefs_types_del">
		<!-- CFC: Add type -->
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="prefs_types_del(attributes)" />
		<!-- Show -->
		<do action="prefs_types" />
	</fuseaction>
	<!-- Update Pref Types -->
	<fuseaction name="prefs_types_up">
		<!-- CFC: Add type -->
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="prefs_types_update(attributes)" />
		<!-- Show -->
		<do action="prefs_types" />
	</fuseaction>
	<!-- Pref Storage -->
	<fuseaction name="prefs_global_storage">
		<!-- CFC -->
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="get_global()" returnvariable="gprefs" />
		<!-- Show -->
		<do action="ajax.prefs_global_storage" />
	</fuseaction>
	<!-- Validate: Nirvanix -->
	<fuseaction name="prefs_nvx_validate_master">
		<!-- Param -->
		<set name="attributes.qry_settings_nirvanix.set2_nirvanix_name" value="#attributes.nvxname#" />
		<set name="attributes.qry_settings_nirvanix.set2_nirvanix_pass" value="#attributes.nvxpass#" />
		<set name="attributes.nvxappkey" value="#attributes.nvxkey#" />
		<!-- CFC -->
		<invoke object="myFusebox.getApplicationData().Nirvanix" methodcall="validate(attributes)" />
	</fuseaction>
	<!-- Validate: Amazon -->
	<fuseaction name="prefs_aws_validate">
		<!-- Params -->
		<set name="application.razuna.awskeysecret" value="#attributes.awskeysecret#" />
		<!-- CFC -->
		<invoke object="myFusebox.getApplicationData().amazon" methodcall="validate(attributes)" />
	</fuseaction>
	<!-- Validate: Amazon Bucket -->
	<fuseaction name="prefs_aws_bucket_validate">
		<!-- CFC -->
		<invoke object="myFusebox.getApplicationData().amazon" methodcall="validatebucket(attributes.awsbucket)" />
	</fuseaction>
	<!-- Save preferences -->
	<fuseaction name="prefs_global_save">
		<!-- CFC: Save preferences -->
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="update_global(attributes)" />
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="update_tools(attributes)" />
		<!-- <do action="prefs" /> -->
	</fuseaction>
	<!-- Pref DB -->
	<fuseaction name="prefs_global_db">
		<!-- CFC -->
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="get_global()" returnvariable="gprefs" />
		<!-- Show -->
		<do action="ajax.prefs_global_db" />
	</fuseaction>
	<!-- Pref Backup -->
	<fuseaction name="prefs_backup_restore_upload">
		<!-- XFA -->
		<xfa name="uploadto" value="c.prefs_restore_upload" />
		<!-- Show -->
		<do action="ajax.prefs_backup_restore_upload" />
	</fuseaction>
	<!-- Pref Backup -->
	<fuseaction name="prefs_backup_restore">
		<!-- Params -->
		<set name="attributes.hostid" value="0" />
		<!-- Assetpath -->
		<do action="assetpath" />
		<!-- CFC -->
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="thissetting('sched_backup')" returnvariable="qry_setinterval" />
		<!-- CFC -->
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="get_backup(attributes.hostid)" returnvariable="qry_backup" />
		<!-- Show -->
		<do action="ajax.prefs_backup_restore" />
	</fuseaction>
	<!-- Pref Backup -->
	<fuseaction name="prefs_backup_do">
		<!-- Param -->
		<set name="attributes.admin" value="T" />
		<set name="attributes.hostid" value="0" />
		<!-- Assetpath -->
		<set name="attributes.assetpath" value="#thispath#" />
		<!-- Backup tables and data to razuna_backup H2 database -->
		<invoke object="myFusebox.getApplicationData().backuprestore" methodcall="backuptodb(attributes)" />
	</fuseaction>
	<!-- Run backup from scheduled task -->
	<fuseaction name="runschedbackup">
		<!-- Param -->
		<set name="attributes.admin" value="T" />
		<set name="attributes.hostid" value="0" />
		<!-- CFC: Backup -->
		<invoke object="myFusebox.getApplicationData().backuprestore" methodcall="backuptodbthread(attributes)" />
	</fuseaction>
	<!-- Restore from filesystem -->
	<fuseaction name="prefs_restore_do">
		<!-- Param -->
		<set name="attributes.admin" value="T" />
		<set name="attributes.hostid" value="0" />
		<!-- Assetpath -->
		<set name="attributes.assetpath" value="#thispath#" />
		<!-- CFC: Restore -->
		<invoke object="myFusebox.getApplicationData().backuprestore" methodcall="restorexml(attributes)" />
	</fuseaction>
	<!-- Restore from upload -->
	<fuseaction name="prefs_restore_upload">
		<!-- Param -->
		<set name="attributes.admin" value="T" />
		<set name="attributes.thepath" value="#thispath#" />
		<set name="attributes.uploadxml" value="T" />
		<!-- Action: Get asset path -->
		<set name="attributes.assetpath" value="#thispath#" />
		<!-- Action: Storage -->
		<do action="storage" />
		<!-- CFC: Do the upload -->
		<invoke object="myFusebox.getApplicationData().backuprestore" methodcall="uploadxml(attributes)" returnvariable="upxml" />
		<!-- Set Params correctly -->
		<set name="attributes.uploadpath" value="#upxml.uploadpath#" />
		<set name="attributes.thebackupfile" value="#upxml.thebackupfile#" />
		<set name="attributes.theuploadxml" value="#upxml.theuploadxml#" />
		<!-- CFC: Do the restore -->
		<invoke object="myFusebox.getApplicationData().backuprestore" methodcall="restorexml(attributes)" />
	</fuseaction>
	<!-- Pref Tools -->
	<fuseaction name="prefs_global_tools">
		<!-- CFC -->
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="get_tools()" returnvariable="thetools" />
		<!-- Show -->
		<do action="ajax.prefs_global_tools" />
	</fuseaction>
	<!-- Remove Backup DB -->
	<fuseaction name="prefs_backup_remove">
		<!-- CFC: Restore -->
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="drop_backup(attributes)" />
		<!-- Show -->
		<do action="prefs_backup_restore" />
	</fuseaction>
	<!-- Pref Backup -->
	<fuseaction name="prefs_sched_backup">
		<!-- Set schedule -->
		<invoke object="myFusebox.getApplicationData().backuprestore" methodcall="setschedbackup(attributes.sched)" />
	</fuseaction>
	<!--  -->
	<!-- END: GLOBAL PREFERENCES -->
	<!--  -->

	<!--  -->
	<!-- START: TRANSLATIONS -->
	<!--  -->

	<!-- Load translations -->
	<fuseaction name="translations">
		<!-- Show -->
		<do action="ajax.translations" />
	</fuseaction>
	<!-- Search translations -->
	<fuseaction name="translation_search">
		<set name="session.trans_id" value="#attributes.trans_id#" />
		<set name="session.trans_text" value="#attributes.trans_text#" />
		<!-- CFC -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="translationsearch(attributes)" returnvariable="searchresults" />
		<!-- Show -->
		<do action="ajax.translations_results" />
	</fuseaction>
	<!-- Load detail translations -->
	<fuseaction name="translation_detail">
		<!-- CFC -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="translationdetail(attributes)" returnvariable="result" />
		<!-- Show -->
		<do action="ajax.translations_detail" />
	</fuseaction>
	<!-- Update translations -->
	<fuseaction name="translation_update">
		<!-- CFC -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="translationupdate(attributes)" />
	</fuseaction>
	<!-- Remove translations -->
	<fuseaction name="translation_remove">
		<!-- CFC -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="translationremove(attributes)" />
		<!-- Set the session into attributes -->
		<set name="attributes.trans_id" value="#session.trans_id#" />
		<set name="attributes.trans_text" value="#session.trans_text#" />
		<!-- Show the search -->
		<do action="translation_search" />
	</fuseaction>
	<!-- Add translations -->
	<fuseaction name="translation_add">
		<!-- CFC -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="translationadd(attributes)" />
	</fuseaction>

	<!--  -->
	<!-- END: TRANSLATIONS -->
	<!--  -->

	<!--  -->
	<!-- START: USERS -->
	<!--  -->

	<!-- Users List -->
	<fuseaction name="users">
		<!-- XFA -->
		<xfa name="rto" value="c.users" />
		<!-- Set rowmax and rowmin -->
		<set name="attributes.rowmax" value="30" />
		<set name="attributes.rowmin" value="0" />
		<!-- Get all hosts -->
		<invoke object="myFusebox.getApplicationData().global" methodcall="allhosts()" returnvariable="qry_allhosts" />
		<!-- CFC: Get all users -->
		<invoke object="myFusebox.getApplicationData().users" methodcall="getall(attributes)" returnvariable="qry_users" />
		<!-- Show  -->
		<do action="ajax.users" />
	</fuseaction>
	<!-- Users Search -->
	<fuseaction name="users_search">
		<!-- CFC: Search users -->
		<invoke object="myFusebox.getApplicationData().users" methodcall="quicksearch(attributes)" returnvariable="qry_users" />
		<!-- Show  -->
		<do action="ajax.users_search" />
	</fuseaction>
	<!-- Get Details -->
	<fuseaction name="users_detail">
		<set name="attributes.add" value="F" overwrite="false" />
		<!-- CFC: Get the user -->
		<invoke object="myFusebox.getApplicationData().users" methodcall="details(attributes)" returnvariable="qry_detail" />
		<!-- Get all hosts -->
		<invoke object="myFusebox.getApplicationData().global" methodcall="allhosts()" returnvariable="qry_allhosts" />
		<!-- Get Admin groups of this user and put into list -->
		<invoke object="myFusebox.getApplicationData().groups_users" method="getGroupsOfUser" returnvariable="qry_usergroup">
			<argument name="user_id" value="#attributes.user_id#" />
			<argument name="mod_short" value="adm" />
			<argument name="host_id" value="#session.hostid#" />
		</invoke>
		<set name="grpnrlist" value="#valuelist(qry_usergroup.grp_id)#" />
		<!-- Get DAM groups of this user and put into list -->
		<invoke object="myFusebox.getApplicationData().groups_users" method="getGroupsOfUser" returnvariable="qry_usergroupdam">
			<argument name="user_id" value="#attributes.user_id#" />
			<argument name="mod_short" value="ecp" />
			<argument name="host_id" value="#session.hostid#" />
		</invoke>
		<set name="webgrpnrlist" value="#valuelist(qry_usergroupdam.grp_id)#" />
		<!-- Get hosts of this user and put into list -->
		<invoke object="myFusebox.getApplicationData().users" methodcall="userhosts(attributes)" returnvariable="qry_userhosts" />
		<set name="hostlist" value="#valuelist(qry_userhosts.host_id)#" />
		<!-- CFC: Get DAM groups -->
		<invoke object="myFusebox.getApplicationData().groups" method="getall" returnvariable="qry_groups">
			<argument name="thestruct" value="#attributes#" />
			<argument name="mod_short" value="ecp" />
			<argument name="host_id" value="#session.hostid#" />
		</invoke>
		<!-- CFC: Get Admin groups -->
		<invoke object="myFusebox.getApplicationData().groups" method="getall" returnvariable="qry_groups_admin">
			<argument name="thestruct" value="#attributes#" />
			<argument name="mod_short" value="adm" />
			<argument name="host_id" value="#session.hostid#" />
		</invoke>
		<!-- Show -->
		<do action="ajax.users_detail" />
	</fuseaction>
	<!-- Save new or existing user -->
	<fuseaction name="users_save">
		<!-- CFC: If it is a new user then add, else update -->
		<if condition="#attributes.user_id# EQ 0">
			<true>
				<!-- CFC: Add user to db -->
				<invoke object="myFusebox.getApplicationData().users" methodcall="add(attributes)" returnvariable="attributes.newid" />
				<!-- CFC: Insert user to groups -->
				<invoke object="myFusebox.getApplicationData().groups_users" methodcall="addtogroups(attributes)" />
				<!-- CFC: Get all modules -->
				<invoke object="myFusebox.getApplicationData().modules" methodcall="getIdStruct()" returnvariable="attributes.module_id_struct" />
			</true>
			<false>
				<set name="attributes.newid" value="#attributes.user_id#" />
				<!-- CFC: Get all modules -->
				<invoke object="myFusebox.getApplicationData().modules" methodcall="getIdStruct()" returnvariable="attributes.module_id_struct" />
				<!-- CFC: Insert user to groups -->
				<invoke object="myFusebox.getApplicationData().groups_users" methodcall="addtogroups(attributes)" />
				<!-- CFC: Update the user -->
				<invoke object="myFusebox.getApplicationData().users" methodcall="update(attributes)" />
			</false>
		</if>
	</fuseaction>
	<!-- Delete -->
	<fuseaction name="users_remove">
		<!-- CFC: Delete user -->
		<invoke object="myFusebox.getApplicationData().users" methodcall="delete(attributes)" />
		<!-- CFC: Delete user groups -->
		<set name="attributes.newid" value="#attributes.id#" />
		<invoke object="myFusebox.getApplicationData().groups_users" methodcall="deleteUser(attributes)" />
		<!-- Show  -->
		<do action="users" />
	</fuseaction>

	<!-- Remove users coming from the select -->
	<fuseaction name="users_remove_select">
		<invoke object="myFusebox.getApplicationData().users" methodcall="delete_selects(attributes)" />
	</fuseaction>

	<!-- Send email to selected users -->
	<fuseaction name="send_useremails">
		<invoke object="myFusebox.getApplicationData().users" methodcall="send_emails(attributes)" />
	</fuseaction>	

	<!-- Check for the email -->
	<fuseaction name="checkemail">
		<!-- CFC: Check -->
		<invoke object="myFusebox.getApplicationData().users" methodcall="check(attributes)" returnvariable="qry_check" />
		<!-- Show -->
		<!-- <do action="ajax.users_check" /> -->
	</fuseaction>
	<!-- Check for the user name -->
	<fuseaction name="checkusername">
		<!-- CFC: Check -->
		<invoke object="myFusebox.getApplicationData().users" methodcall="check(attributes)" returnvariable="qry_check" />
		<!-- Show -->
		<!-- <do action="ajax.users_check" /> -->
	</fuseaction>
	<!-- Loading API page -->
	<fuseaction name="users_api">
		<!-- Param -->
		<set name="attributes.reset" value="false" overwrite="false" />
		<!-- CFC: Check API key -->
		<invoke object="myFusebox.getApplicationData().users" methodcall="getapikey(attributes.user_id,attributes.reset)" returnvariable="qry_api_key" />
		<!-- Show -->
		<do action="ajax.users_api" />
	</fuseaction>

	<!--  -->
	<!-- END: USERS -->
	<!--  -->

	<!--  -->
	<!-- START: GROUPS -->
	<!--  -->

	<!-- Show Main -->
	<fuseaction name="groups">
		<!-- XFA -->
		<xfa name="rto" value="c.groups" />
		<!-- Get all hosts -->
		<invoke object="myFusebox.getApplicationData().global" methodcall="allhosts()" returnvariable="qry_allhosts" />
		<!-- Show -->
		<do action="ajax.groups" />
	</fuseaction>
	<!-- Groups List -->
	<fuseaction name="groups_list">
		<!-- CFC: Get all groups -->
		<invoke object="myFusebox.getApplicationData().groups" method="getall" returnvariable="qry_groups">
			<argument name="thestruct" value="#attributes#" />
			<argument name="mod_short" value="#attributes.kind#" />
			<argument name="host_id" value="#session.hostid#" />
		</invoke>
		<!-- Show -->
		<do action="ajax.groups_list" />
	</fuseaction>
	<!-- Groups Add -->
	<fuseaction name="groups_add">
		<!-- CFC: Get mod id from modules -->
		<invoke object="myFusebox.getApplicationData().modules" methodcall="getid('#attributes.kind#')" returnvariable="attributes.modules_dam_id" />
		<!-- CFC: Add the new group -->
		<invoke object="myFusebox.getApplicationData().groups" methodcall="insertRecord(attributes)" />
		<!-- Show -->
		<do action="groups_list" />
	</fuseaction>
	<!-- Groups Detail -->
	<fuseaction name="groups_detail">
		<!-- CFC: Get details -->
		<invoke object="myFusebox.getApplicationData().groups" methodcall="getdetailedit(attributes)" returnvariable="qry_detail" />
		<!-- Show -->
		<do action="ajax.groups_detail" />
	</fuseaction>
	<!-- Groups Update -->
	<fuseaction name="groups_update">
		<!-- CFC: Update -->
		<invoke object="myFusebox.getApplicationData().groups" methodcall="update(attributes)" />
		<!-- Show -->
		<do action="groups_list" />
	</fuseaction>
	<!-- Groups Remove -->
	<fuseaction name="groups_remove">
		<!-- CFC: Update -->
		<invoke object="myFusebox.getApplicationData().groups" methodcall="remove(attributes)" />
		<!-- Show -->
		<do action="groups_list" />
	</fuseaction>

	<!--  -->
	<!-- END: GROUPS -->
	<!--  -->

	<!--  -->
	<!-- START: HOSTS -->
	<!--  -->

	<!-- Show Main -->
	<fuseaction name="hosts">
		<!-- Show -->
		<do action="ajax.hosts" />
	</fuseaction>
	<!-- List -->
	<fuseaction name="hosts_list">
		<set name="attributes.offset" value="0" overwrite="false" />
		<set name="session.offset" value="#attributes.offset#" />
		<!-- CFC: Get all hosts -->
		<invoke object="myFusebox.getApplicationData().hosts" methodcall="getall()" returnvariable="qry_hostslist" />
		<!-- Show -->
		<do action="ajax.hosts_list" />
	</fuseaction>
	<!-- Add -->
	<fuseaction name="hosts_add">
		<set name="attributes.firsttime" value="F" />
		<!-- CFC: Add Host -->
		<invoke object="myFusebox.getApplicationData().hosts" methodcall="add(attributes)" />
	</fuseaction>
	<!-- Detail -->
	<fuseaction name="hosts_detail">
		<!-- CFC: Get host -->
		<invoke object="myFusebox.getApplicationData().hosts" methodcall="getdetail(attributes)" returnvariable="qry_hostsdetail" />
		<invoke object="myFusebox.getApplicationData().hosts" methodcall="gethostsize(qry_hostsdetail.host_id)" returnvariable="hostsize" />
		<!-- Show -->
		<do action="ajax.hosts_detail" />
	</fuseaction>
	<!-- Detail -->
	<fuseaction name="hosts_update">
		<!-- CFC: Update host -->
		<invoke object="myFusebox.getApplicationData().hosts" methodcall="update(attributes)" />
	</fuseaction>
	<!-- Remove -->
	<fuseaction name="hosts_remove">
		<set name="attributes.theschema" value="#application.razuna.theschema#" />
		<set name="attributes.dsn" value="#application.razuna.datasource#" />
		<set name="attributes.database" value="#application.razuna.thedatabase#" />
		<set name="attributes.storage" value="#application.razuna.storage#" />
		<!-- CFC: Remove host -->
		<invoke object="myFusebox.getApplicationData().hosts" methodcall="remove(attributes)" />
		<!-- Show -->
		<do action="hosts_list" />
	</fuseaction>
	<!-- Recreate -->
	<fuseaction name="hosts_recreate">
		<!-- CFC: Recreate host -->
		<invoke object="myFusebox.getApplicationData().hosts" methodcall="hostupdate(attributes)" />
		<!-- Show -->
		<do action="hosts_list" />
	</fuseaction>
	<!-- Check for the hostname -->
	<fuseaction name="hosts_checkhostname">
		<!-- CFC: Check -->
		<invoke object="myFusebox.getApplicationData().hosts" methodcall="checkname(attributes)" returnvariable="qry_check" />
		<!-- Show -->
		<do action="ajax.hosts_checkhostname" />
	</fuseaction>
	<!-- Get Languages for new Host -->
	<fuseaction name="hosts_languages">
		<set name="attributes.thepath" value="#pathoneup#/global/" />
		<!-- CFC: Check -->
		<invoke object="myFusebox.getApplicationData().defaults" methodcall="getlangsadmin(attributes.thepath)" returnvariable="xml_langs" />
		<!-- Show -->
		<do action="ajax.hosts_languages" />
	</fuseaction>
	

	<!--  -->
	<!-- END: HOSTS -->
	<!--  -->


	<!-- EVERYTHING BELOW THIS LINE IS NOT USED -->



	<!--  -->
	<!-- ADMIN: HOST -->
	<!--  -->

	<!-- Load list of hosts -->
	<fuseaction name="hostlist">
		<!-- CFC: Get List of Hosts -->
		<invoke object="myFusebox.getApplicationData().admin" methodcall="hostlist()" returnvariable="hostlist" />
		<!-- Show list of hosts -->
		<do action="ajax.hosts_list" />
	</fuseaction>
	<!-- Add a new host -->
	<fuseaction name="newhost">
		<!-- CFC: Get List of Hosts -->
		<invoke object="myFusebox.getApplicationData().hosts" methodcall="add(attributes)" />
		<!-- Show list of hosts -->
		<do action="hostlist" />
	</fuseaction>
	<!-- Delete host -->
	<fuseaction name="delhost">
		<!-- CFC: Delete host -->
		<invoke object="myFusebox.getApplicationData().admin" methodcall="delete(attributes)" />
		<!-- Show list of hosts -->
		<do action="hostlist" />
	</fuseaction>

	<!--  -->
	<!-- START: Junction for deciding where to go after we delete an item -->

	<!--  -->
	<!-- END: Junction for deciding where to go after we delete an item -->
	<!--  -->

	<!--  -->
	<!-- START: Update function -->
	<!--  -->
	
	<!-- Check for update -->
	<fuseaction name="update">
		<!-- Param -->
		<set name="attributes.firsttime" value="T" overwrite="false" />
		<!-- CFC: Check if there is an update for this DB -->
		<invoke object="myFusebox.getApplicationData().update" methodcall="update_for()" returnvariable="session.updatedb" />
		<!-- Show -->
		<if condition="session.updatedb">
			<true>
				<!-- <do action="v.update" /> -->
				<relocate url="#myself#v.update&amp;_v=#createuuid('')#" />
			</true>
		</if>
	</fuseaction>
	<!-- Do the update -->
	<fuseaction name="update_do">
		<!-- Param -->
		<set name="attributes.firsttime" value="T" overwrite="false" />
		<set name="session.updatedb" value="false" />
		<!-- Add Razuna Client db connection -->
		<set name="session.firsttime.database" value="razuna_client" />
		<set name="session.firsttime.database_type" value="mysql" />
		<set name="session.firsttime.db_name" value="razuna_clients" />
		<set name="session.firsttime.db_server" value="db.razuna.com" />
		<set name="session.firsttime.db_port" value="3306" />
		<set name="session.firsttime.db_user" value="razuna_client" />
		<set name="session.firsttime.db_pass" value="D63E61251" />
		<set name="session.firsttime.db_action" value="create" />
		<!-- CFC: Add the datasource -->
		<invoke object="myFusebox.getApplicationData().global" methodcall="setdatasource()" />
		<!-- CFC: Get all Hosts -->
		<invoke object="myFusebox.getApplicationData().global" methodcall="allhosts()" returnvariable="attributes.qryhosts" />
		<!-- CFC: Do the DB update -->
		<invoke object="myFusebox.getApplicationData().update" methodcall="update_do(attributes)" />
		<!-- Show -->
		<do action="v.update" />
	</fuseaction>
	
	<!--  -->
	<!-- END: Update function -->
	<!--  -->
	
	<!--
		END: SERVE TO BROWSER (CALLS FROM EXTERNAL URL)
	-->
	
	<!-- Random Password -->
	<fuseaction name="randompass">
		<!-- CFC: Random Password -->
		<invoke object="myFusebox.getApplicationData().Login" methodcall="randompass()" returnvariable="attributes.thepass" />
		<!-- Show -->
		<do action="ajax.randompass" />
	</fuseaction>
	
	<!--  -->
	<!-- START: Rendering Farm -->
	<!--  -->
	
	<!-- Load -->
	<fuseaction name="prefs_renf">
		<!-- Global -->
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="get_global()" returnvariable="gprefs" />
		<!-- CFC: Check if there is an update for this DB -->
		<invoke object="myFusebox.getApplicationData().rfs" methodcall="rfs_get_all()" returnvariable="qry_rfs" />
		<!-- Show -->
		<do action="ajax.prefs_rendf" />
	</fuseaction>
	<!-- Server Edit -->
	<fuseaction name="prefs_renf_detail">
		<!-- If new then create id -->
		<if condition="attributes.rfs_id EQ 0">
			<true>
				<set name="attributes.rfs_id" value="#createuuid('')#" />
			</true>
		</if>
		<!-- CFC: Check if there is an update for this DB -->
		<invoke object="myFusebox.getApplicationData().rfs" methodcall="rfs_get_detail(attributes.rfs_id)" returnvariable="qry_rfs" />
		<!-- Show -->
		<do action="ajax.prefs_rendf_add" />
	</fuseaction>
	<!-- Server Save -->
	<fuseaction name="prefs_renf_add">
		<!-- Save -->
		<invoke object="myFusebox.getApplicationData().rfs" methodcall="rfs_update(attributes)" />
	</fuseaction>
	<!-- Server Remove -->
	<fuseaction name="rfs_remove">
		<!-- Save -->
		<invoke object="myFusebox.getApplicationData().rfs" methodcall="rfs_remove(attributes)" />
		<!-- Show -->
		<do action="prefs_renf" />
	</fuseaction>

	<!--  -->
	<!-- START: White Label -->
	<!--  -->
	
	<!-- Load -->
	<fuseaction name="pref_global_wl">
		<!-- Params -->
		<set name="application.razuna.show_recent_updates" value="false" overwrite="false" />
		<set name="attributes.pathoneup" value="#pathoneup#" />
		<!-- Get options -->
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="get_options()" returnvariable="qry_options" />
		<!-- Check if CSS directory exists -->
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="get_css(attributes.pathoneup)" />
		<!-- Show -->
		<do action="ajax.pref_global_wl" />
	</fuseaction>
	<!-- Save -->
	<fuseaction name="pref_global_wl_save">
		<!-- Save WL -->
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="set_options(attributes)" />
		<!-- Save CSS -->
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="set_css(attributes.wl_thecss,pathoneup)" />
	</fuseaction>
	<!-- News -->
	<fuseaction name="wl_news">
		<!-- Get options for rss -->
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="get_options_one('wl_news_rss')" returnvariable="attributes.rss" />
		<!-- Get news -->
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="get_news()" returnvariable="qry_news" />
		<!-- Show -->
		<do action="ajax.wl_news" />
	</fuseaction>
	<!-- News add/edit -->
	<fuseaction name="wl_news_edit">
		<!-- Param -->
		<set name="attributes.add" value="false" overwrite="false" />
		<!-- If add is true we create a news_id -->
		<if condition="attributes.add">
			<true>
				<set name="attributes.news_id" value="#createuuid()#" />
			</true>
		</if>
		<!-- Get record -->
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="get_news_edit(attributes)" returnvariable="qry_news_edit" />
		<!-- Show -->
		<do action="ajax.wl_news_edit" />
	</fuseaction>
	<!-- Save news -->
	<fuseaction name="wl_news_save">
		<!-- save record -->
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="set_news_edit(attributes)" />
	</fuseaction>
	<!-- Remove news -->
	<fuseaction name="wl_news_remove">
		<!-- save record -->
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="del_news(attributes.news_id)" />
	</fuseaction>

	<fuseaction name="debug">
		<do action="v.debug" />	
	</fuseaction>

	<!-- Run Folder subscribe schedule tasks -->
	<fuseaction name="folder_subscribe_task">
		<!-- CFC: Get the Schedule -->
		<invoke object="myFusebox.getApplicationData().scheduler" methodcall="folder_subscribe_task()" returnvariable="thetask" />
	</fuseaction>

	<!-- Schedule asset expiry task -->
	<fuseaction name="w_asset_expiry_task">
		<!-- CFC: Run task -->
		<invoke object="myFusebox.getApplicationData().scheduler" methodcall="asset_expiry_task()"/>
	</fuseaction>

	<!-- Run Lucene rebuild index task -->
	<fuseaction name="w_lucene_update_index">
		<set name="attributes.host_id" value="#url.host_id#" />
		<!-- CFC: Get the Schedule -->
		<invoke object="myFusebox.getApplicationData().lucene" methodcall="index_update_firsttime(attributes.host_id)"/>
	</fuseaction>

	<!-- Schedule FTP task -->
	<fuseaction name="w_ftp_notifications_task">
		<!-- CFC: Run task -->
		<invoke object="myFusebox.getApplicationData().scheduler" methodcall="ftp_notifications_task()"/>
	</fuseaction>

</circuit>