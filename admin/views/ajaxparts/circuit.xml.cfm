<!DOCTYPE circuit>

<circuit access="public">
	
	<!-- Login Choose Host -->
	<fuseaction name="choosehost">
  		<include template="dsp_login_choosehost" />
	</fuseaction>
	
	<!-- LOAD JS EXT STUFF -->
	<fuseaction name="jstabs">
  		<include template="js_tabs" />
	</fuseaction>
	<fuseaction name="jssettings">
  		<include template="js_settings" />
	</fuseaction>

	<!-- WINDOW: REMOVE RECORD -->
	<fuseaction name="remove_record">
  		<include template="win_remove_record" />
	</fuseaction>

	<!-- Load page fragements for index page -->
	<fuseaction name="mainchecklist">
  		<include template="dsp_main_checkinstall" />
	</fuseaction>
	<fuseaction name="mainsysteminfo">
  		<include template="dsp_main_systeminfo" />
	</fuseaction>
	<fuseaction name="mainblog">
  		<include template="dsp_main_blog" />
	</fuseaction>
	<fuseaction name="mainsupport">
  		<include template="dsp_main_support" />
	</fuseaction>
	<fuseaction name="maintwitter">
  		<include template="dsp_main_twitter" />
	</fuseaction>
	
	<!-- LOGIN: Forgotpass -->
	<fuseaction name="forgotpass">
  		<include template="dsp_forgotpass" />
	</fuseaction>
	<!-- LOGIN: Forgotpass Feedback -->
	<fuseaction name="forgotpassfeedback">
  		<include template="dsp_forgotpassfeedback" />
	</fuseaction>
	<!-- LOGIN: Show hosts -->
	<fuseaction name="showhosts">
  		<include template="dsp_showhosts" />
	</fuseaction>
	<!-- LOGIN: Show Errors -->
	<fuseaction name="loginerrors">
  		<include template="dsp_loginerrors" />
	</fuseaction>
	
	<!-- Dummy empty page -->
	<fuseaction name="dummy">
  		<include template="dsp_dummy" />
	</fuseaction>

	<!-- Output value, variable named "value"-->
	<fuseaction name="outputValue">
  		<include template="outputValue" />
	</fuseaction>
	
	<!-- First time: Paths -->
	<fuseaction name="first_time_paths">
  		<include template="dsp_firsttime_paths" />
	</fuseaction>
	<!-- First time: Account -->
	<fuseaction name="first_time_account">
  		<include template="dsp_firsttime_account" />
	</fuseaction>
	<!-- First time: Database -->
	<fuseaction name="first_time_database">
  		<include template="dsp_firsttime_database" />
	</fuseaction>
	<!-- First time: Database Config -->
	<fuseaction name="first_time_database_config">
  		<include template="dsp_firsttime_database_config" />
	</fuseaction>
	<!-- First time: Database Check -->
	<fuseaction name="first_time_database_check">
  		<include template="dsp_firsttime_database_check" />
	</fuseaction>
	<!-- First time: Database Check -->
	<fuseaction name="first_time_database_setup">
  		<include template="dsp_firsttime_database_setup" />
	</fuseaction>
	<!-- First time: Database Restore -->
	<fuseaction name="first_time_database_restore">
  		<include template="dsp_firsttime_database_restore" />
	</fuseaction>
	
	
	<!-- Done the firsttime setup -->
	<fuseaction name="first_time_done">
  		<include template="dsp_firsttime_done" />
	</fuseaction>

	<!-- Menu: DAM -->
	<fuseaction name="menu_dam">
  	<include template="dsp_menu_dam" />
	</fuseaction>
	<!-- Menu: Settings -->
	<fuseaction name="menu_settings">
  	<include template="dsp_menu_settings" />
	</fuseaction>

	<!-- Preferences -->
	<fuseaction name="prefs">
  		<include template="dsp_pref_main" />
	</fuseaction>
	<!-- Gobal -->
	<fuseaction name="prefs_global">
  		<include template="dsp_pref_global" />
	</fuseaction>
	<!-- Meta -->
	<fuseaction name="prefs_meta">
  		<include template="dsp_pref_meta" />
	</fuseaction>
	<!-- DAM -->
	<fuseaction name="prefs_dam">
  		<include template="dsp_pref_dam" />
	</fuseaction>
	<!-- Website -->
	<fuseaction name="prefs_web">
  		<include template="dsp_pref_web" />
	</fuseaction>
	<!-- Image -->
	<fuseaction name="prefs_image">
  		<include template="dsp_pref_image" />
	</fuseaction>
	<!-- Video -->
	<fuseaction name="prefs_video">
  		<include template="dsp_pref_video" />
	</fuseaction>
	<!-- Oracle -->
	<fuseaction name="prefs_oracle">
  		<include template="dsp_pref_oracle" />
	</fuseaction>
	<!-- Storage -->
	<fuseaction name="prefs_storage">
  		<include template="dsp_pref_storage" />
	</fuseaction>
	<!-- Upload -->
	<fuseaction name="prefs_imgupload">
  		<include template="dsp_pref_image_upload" />
	</fuseaction>
	<!-- Load Logo -->
	<fuseaction name="prefs_loadlogo">
  		<include template="dsp_pref_loadlogo" />
	</fuseaction>
	
	<!-- GLOBAL: Preferences -->
	<fuseaction name="prefs_global_main">
  		<include template="dsp_pref_global_main" />
	</fuseaction>
	<!-- GLOBAL: File Types -->
	<fuseaction name="prefs_types">
  		<include template="dsp_pref_global_types" />
	</fuseaction>
	<!-- GLOBAL: Storage -->
	<fuseaction name="prefs_global_storage">
  		<include template="dsp_pref_global_storage" />
	</fuseaction>
	<!-- GLOBAL: DB -->
	<fuseaction name="prefs_global_db">
  		<include template="dsp_pref_global_db" />
	</fuseaction>
	<!-- GLOBAL: Backup -->
	<fuseaction name="prefs_backup_restore">
  		<include template="dsp_pref_global_backup" />
	</fuseaction>
	<!-- GLOBAL: Backup Upload -->
	<fuseaction name="prefs_backup_restore_upload">
  		<include template="dsp_pref_global_backup_upload" />
	</fuseaction>
	<!-- GLOBAL: Storage -->
	<fuseaction name="prefs_global_tools">
  		<include template="dsp_pref_global_tools" />
	</fuseaction>
	<!-- GLOBAL: White Labeling -->
	<fuseaction name="pref_global_wl">
  		<include template="dsp_pref_global_wl" />
	</fuseaction>

	<!-- Translations -->
	<fuseaction name="translations">
  		<include template="dsp_translations_main" />
	</fuseaction>
	<!-- Translations Results -->
	<fuseaction name="translations_results">
  		<include template="dsp_translations_results" />
	</fuseaction>
	<!-- Translations Details -->
	<fuseaction name="translations_detail">
  		<include template="dsp_translations_detail" />
	</fuseaction>
	<!-- Translations New -->
	<fuseaction name="translations_add">
  		<include template="dsp_translations_new" />
	</fuseaction>

	<!-- Users -->
	<fuseaction name="users">
  		<include template="dsp_users_main" />
	</fuseaction>
	<!-- Users Search -->
	<fuseaction name="users_search">
  		<include template="dsp_users_results" />
	</fuseaction>
	<!-- Users Details -->
	<fuseaction name="users_detail">
  		<include template="dsp_users_details" />
	</fuseaction>
	<!-- Users Check -->
	<fuseaction name="users_check">
  		<include template="dsp_users_check" />
	</fuseaction>
	<!-- Users Randompass -->
	<fuseaction name="randompass">
  		<include template="dsp_randompass" />
	</fuseaction>
	<!-- Users API -->
	<fuseaction name="users_api">
  		<include template="dsp_users_api" />
	</fuseaction>

	<!-- Groups -->
	<fuseaction name="groups">
  		<include template="dsp_groups_main" />
	</fuseaction>
	<!-- Groups List -->
	<fuseaction name="groups_list">
  		<include template="dsp_groups_list" />
	</fuseaction>
	<!-- Groups List -->
	<fuseaction name="groups_detail">
  		<include template="dsp_groups_detail" />
	</fuseaction>

	<!-- Hosts -->
	<fuseaction name="hosts">
  		<include template="dsp_hosts_main" />
	</fuseaction>
	<!-- Hosts List -->
	<fuseaction name="hosts_list">
  		<include template="dsp_hosts_list" />
	</fuseaction>
	<!-- Hosts Languages -->
	<fuseaction name="hosts_languages">
  		<include template="dsp_hosts_languages" />
	</fuseaction>
	<!-- Hosts Details -->
	<fuseaction name="hosts_detail">
  		<include template="dsp_hosts_detail" />
	</fuseaction>
	<!-- Hosts Recreate -->
	<fuseaction name="hosts_recreate">
  		<include template="dsp_hosts_recreate" />
	</fuseaction>
	<!-- Hosts Check -->
	<fuseaction name="hosts_checkhostname">
  		<include template="dsp_hosts_check" />
	</fuseaction>
	
	<!-- Images: Serve -->
	<fuseaction name="serve_image">
  		<include template="dsp_asset_images_show" />
	</fuseaction>
	<!-- Folder: Load Video -->
	<fuseaction name="folder_videos_show">
  		<include template="dsp_folder_videos_show" />
	</fuseaction>
	
	<!-- Help -->
	<fuseaction name="help">
  		<include template="win_help" />
	</fuseaction>
	
	<!-- Redirector -->
	<fuseaction name="redirector">
  		<include template="redirector" />
	</fuseaction>
	
	<!-- Prefs: Rendering Farm -->
	<fuseaction name="prefs_rendf">
  		<include template="dsp_pref_global_rendfarm" />
	</fuseaction>
	<!-- Prefs: Rendering Farm Add -->
	<fuseaction name="prefs_rendf_add">
  		<include template="dsp_pref_global_rendfarm_add" />
	</fuseaction>
	<!-- Prefs: Rendering Farm Validate Server -->
	<fuseaction name="prefs_rendf_valserver">
  		<include template="dsp_pref_global_rendfarm_valserver" />
	</fuseaction>
	<!-- Prefs: Rendering Farm Validate FTP -->
	<fuseaction name="prefs_rendf_valftp">
  		<include template="dsp_pref_global_rendfarm_valftp" />
	</fuseaction>

	<!-- Plugins -->
	<fuseaction name="plugins">
  		<include template="dsp_plugins" />
	</fuseaction>
	<!-- Plugins Hosts -->
	<fuseaction name="plugins_hosts">
  		<include template="dsp_plugins_hosts" />
	</fuseaction>
	<!-- Plugins Upload -->
	<fuseaction name="plugins_upload">
  		<include template="dsp_plugins_upload" />
	</fuseaction>

	<!-- WL News -->
	<fuseaction name="wl_news">
  		<include template="dsp_wl_news" />
	</fuseaction>
	<!-- WL News Edit -->
	<fuseaction name="wl_news_edit">
  		<include template="dsp_wl_news_edit" />
	</fuseaction>
	
</circuit>
