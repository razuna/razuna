<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE circuit>

<circuit access="public">

	<!-- Load page fragements for index page -->
	<fuseaction name="mainblog">
  		<include template="dsp_main_blog" />
	</fuseaction>
	<fuseaction name="mainsupport">
  		<include template="dsp_main_support" />
	</fuseaction>
	<fuseaction name="mainsysteminfo">
  		<include template="dsp_main_systeminfo" />
	</fuseaction>
	
	<!-- LOGIN: Login Errors -->
	<fuseaction name="loginerrors">
  		<include template="dsp_loginerrors" />
	</fuseaction>
	<!-- LOGIN: Forgotpass -->
	<fuseaction name="forgotpass">
  		<include template="dsp_forgotpass" />
	</fuseaction>
	<!-- LOGIN: Forgotpass Feedback -->
	<fuseaction name="forgotpassfeedback">
  		<include template="dsp_forgotpassfeedback" />
	</fuseaction>
	
	<!-- LOGIN: Request Access -->
	<fuseaction name="req_access">
  		<include template="dsp_request_access" />
	</fuseaction>
	<!-- LOGIN: Request Access Feedback -->
	<fuseaction name="req_access_feedback">
  		<include template="dsp_request_access_feedback" />
	</fuseaction>
	
	<!-- WINDOW: Remove Record -->
	<fuseaction name="remove_record">
  		<include template="win_remove_record" />
	</fuseaction>
	<!-- WINDOW: Remove eMail -->
	<fuseaction name="remove_email">
  		<include template="win_remove_email" />
	</fuseaction>
	<!-- WINDOW: Trash Record -->
	<fuseaction name="trash_record">
  		<include template="win_trash_record" />
	</fuseaction>
	<!-- WINDOW: Restore Record -->
	<fuseaction name="restore_record">
  		<include template="win_restore_record" />
	</fuseaction>
	
	<!-- Dummy empty page -->
	<fuseaction name="dummy">
  		<include template="dsp_dummy" />
	</fuseaction>
	
	<!-- Menu: Explorer -->
	<fuseaction name="explorer">
  		<include template="dsp_explorer" />
	</fuseaction>
	<!-- Menu: Explorer Collection -->
	<fuseaction name="explorer_col">
  		<include template="dsp_explorer_col" />
	</fuseaction>
	<!-- Menu: Favorites -->
	<fuseaction name="favorites">
  		<include template="dsp_favorites" />
	</fuseaction>
	<!-- Menu: Basket -->
	<fuseaction name="basket">
  		<include template="dsp_basket" />
	</fuseaction>
	<!-- Basket Full -->
	<fuseaction name="basket_full">
  		<include template="dsp_basket_full" />
	</fuseaction>
	<!-- Basket Remove -->
	<fuseaction name="remove_basket">
  		<include template="win_remove_basket" />
	</fuseaction>
	<!-- Basket Save -->
	<fuseaction name="basket_save">
  		<include template="win_basket_save" />
	</fuseaction>
	
	<!-- Save as ZIP -->
	<fuseaction name="saveaszip_form">
  		<include template="win_saveaszip_form" />
	</fuseaction>
	<!-- Save as COLLECTION -->
	<fuseaction name="saveascollection_form">
  		<include template="win_saveascollection_form" />
	</fuseaction>
	<!-- Save as COLLECTION -->
	<fuseaction name="collection_detail">
  		<include template="win_collection_detail" />
	</fuseaction>
	
	<!-- Folder: Main -->
	<fuseaction name="folder">
  		<include template="dsp_folder" />
	</fuseaction>
	<!-- Folder: New -->
	<fuseaction name="folder_new">
  		<include template="dsp_folder_new" />
	</fuseaction>
	<!-- Folder: Sharing -->
	<fuseaction name="folder_sharing">
  		<include template="dsp_folder_sharing" />
	</fuseaction>
	<!-- Folder: Remove Folder -->
	<fuseaction name="remove_folder">
  		<include template="win_remove_folder" />
	</fuseaction>
	<!-- Folder: Trash Folder -->
	<fuseaction name="trash_folder">
  		<include template="win_trash_folder" />
	</fuseaction>
	<!-- Folder: Confirm removal of folder -->
	<fuseaction name="remove_folder_confirm">
  		<include template="dsp_folder_remove_confirm" />
	</fuseaction>
	<!-- Folder: Confirm removal of folder -->
	<fuseaction name="remove_collection_confirm">
  		<include template="dsp_folder_remove_confirm" />
	</fuseaction>
	<!-- Folder: Confirm trash of folder -->
	<fuseaction name="trash_folder_confirm">
  		<include template="dsp_folder_trash_confirm" />
	</fuseaction>
	<!-- Folder: Content -->
	<fuseaction name="folder_content">
  		<include template="dsp_folder_content" />
	</fuseaction>
	<!-- Copy Metadata -->
	<fuseaction name="copy_metadata">
  		<include template="dsp_copy_metadata" />
	</fuseaction>
	<!-- Copy Metadata Do -->
	<fuseaction name="copy_metadata_do">
  		<include template="dsp_copy_metadata_do" />
	</fuseaction>
	<!-- Folder: Content LIST -->
	<fuseaction name="folder_content_list">
  		<include template="dsp_folder_content_list" />
	</fuseaction>
	<!-- Folder: Content for search -->
	<fuseaction name="folder_content_results">
  		<include template="dsp_folder_content_results" />
	</fuseaction>
	<!-- Folder: Files -->
	<fuseaction name="folder_files">
  		<include template="dsp_folder_files" />
	</fuseaction>
	<!-- Folder: Images -->
	<fuseaction name="folder_images">
  		<include template="dsp_folder_images" />
	</fuseaction>
	<!-- Folder: Videos -->
	<fuseaction name="folder_videos">
  		<include template="dsp_folder_videos" />
	</fuseaction>
	<!-- Trash: Records -->
	<fuseaction name="trash_assets">
  		<include template="dsp_trash_assets" />
	</fuseaction>
	<!-- Folder: Load Video -->
	<fuseaction name="folder_videos_show">
  		<include template="dsp_folder_videos_show" />
	</fuseaction>
	<!-- Folder: Audios -->
	<fuseaction name="folder_audios">
  		<include template="dsp_folder_audios" />
	</fuseaction>
	<!-- Folder LINK: Check -->
	<fuseaction name="folder_check">
  		<include template="dsp_folder_check" />
	</fuseaction>
	<!-- Folder: Settings -->
	<fuseaction name="folder_settings">
  		<include template="dsp_folder_settings" />
	</fuseaction>
	<!-- Assets: trash -->
    <fuseaction name="folder_trash">
		<include template="dsp_folder_trash" />
    </fuseaction>
	<!-- Folder: trash -->
    <fuseaction name="trash_folder_all">
		<include template="dsp_trash_folder_all" />
    </fuseaction>
	<!-- Folder: samefoldernamecheck -->
	<fuseaction name="folder_namecheck">
  		<include template="dsp_folder_namecheck" />
	</fuseaction>
	<!-- Folder: samecollectionnamecheck -->
	<fuseaction name="collection_namecheck">
  		<include template="dsp_collection_namecheck" />
	</fuseaction>
	<!-- Collections: List -->
	<fuseaction name="collections_list">
  		<include template="dsp_collections_list" />
	</fuseaction>
	<!-- Collections: List -->
	<fuseaction name="collections_del_item">
  		<include template="win_remove_col_item" />
	</fuseaction>
	<!-- Collections: Chooser -->
	<fuseaction name="collection_chooser">
  		<include template="dsp_collection_chooser" />
	</fuseaction>
	<!-- collection: trash -->
    <fuseaction name="collection_trash">
		<include template="dsp_collection_trash" />
    </fuseaction>
	<!-- WINDOW: Restore Collection -->
	<fuseaction name="restore_collection">
  		<include template="win_restore_collection" />
	</fuseaction>
	<!-- Collections: List -->
	<fuseaction name="collections_trash_item">
  		<include template="win_trash_col_item" />
	</fuseaction>
	<!-- collection: collections in trash -->
    <fuseaction name="collection_item_trash">
		<include template="dsp_trash_col" />
    </fuseaction>
	<!-- collection: folders in trash -->
    <fuseaction name="col_folder_trash">
		<include template="dsp_col_folder_trash" />
    </fuseaction>
	<!-- collection: files in trash -->
    <fuseaction name="col_file_trash">
		<include template="dsp_col_file_trash" />
    </fuseaction>
	<!-- Assets: Add -->
	<fuseaction name="asset_add">
  		<include template="dsp_asset_add" />
	</fuseaction>
	<!-- Assets: Add Single -->
	<fuseaction name="asset_add_single">
  		<include template="dsp_asset_add_single" />
	</fuseaction>
	<!-- Assets: Add Upload form -->
	<fuseaction name="asset_add_upload">
  		<include template="dsp_asset_add_upload" />
	</fuseaction>
	<!-- Assets: Add Server -->
	<fuseaction name="asset_add_server">
  		<include template="dsp_asset_add_server" />
	</fuseaction>
	<!-- Assets: Add Server Folders -->
	<fuseaction name="asset_add_server_folders">
  		<include template="dsp_asset_add_server_folders" />
	</fuseaction>
	<!-- Assets: Add Server Content -->
	<fuseaction name="asset_add_server_content">
  		<include template="dsp_asset_add_server_content" />
	</fuseaction>
	<!-- Assets: Add eMail Form -->
	<fuseaction name="asset_add_email">
  		<include template="dsp_asset_add_email" />
	</fuseaction>
	<!-- Assets: Add eMail Show Messages -->
	<fuseaction name="asset_add_email_show">
  		<include template="dsp_asset_add_email_show" />
	</fuseaction>
	<!-- Assets: Add eMail Show Messages Detail -->
	<fuseaction name="asset_add_email_show_mail">
  		<include template="dsp_asset_add_email_show_mail" />
	</fuseaction>
	<!-- Assets: Add FTP Form -->
	<fuseaction name="asset_add_ftp">
  		<include template="dsp_asset_add_ftp" />
	</fuseaction>
	<!-- Assets: Add FTP Show Server -->
	<fuseaction name="asset_add_ftp_show">
  		<include template="dsp_asset_add_ftp_show" />
	</fuseaction>
	<!-- Assets: Add LINK -->
	<fuseaction name="asset_add_link">
  		<include template="dsp_asset_add_link" />
	</fuseaction>
	<!-- Assets: Show history -->
	<fuseaction name="log_history">
  		<include template="dsp_asset_log" />
	</fuseaction>
	<!-- Assets: Show alias usage -->
	<fuseaction name="usage_alias">
  		<include template="dsp_usage_alias" />
	</fuseaction>
	
	
	<!-- Files: Detail -->
	<fuseaction name="files_detail">
  		<include template="dsp_asset_files_detail" />
	</fuseaction>
	<!-- Files: Serve PDF JPGS -->
	<fuseaction name="serve_pdfjpgs">
  		<include template="dsp_asset_files_pdfjpgs" />
	</fuseaction>
	<!-- Videos: Detail -->
	<fuseaction name="videos_detail">
  		<include template="dsp_asset_videos_detail" />
	</fuseaction>
	<!-- Videos: Detail Flash -->
	<fuseaction name="videos_detail_flash">
  		<include template="dsp_asset_videos_flash" />
	</fuseaction>
	<!-- Videos: Related -->
	<fuseaction name="videos_detail_related">
  		<include template="dsp_asset_videos_related" />
	</fuseaction>
	<!-- Videos: Renditions -->
	<fuseaction name="exist_rendition_videos">
  		<include template="dsp_exist_rendition_videos" />
	</fuseaction>	
	<!-- Images: Detail -->
	<fuseaction name="images_detail">
  		<include template="dsp_asset_images_detail" />
	</fuseaction>
	<!-- Images: Related -->
	<fuseaction name="images_detail_related">
  		<include template="dsp_asset_images_related" />
	</fuseaction>
	<!-- Images: Renditions -->
	<fuseaction name="exist_rendition_images">
  		<include template="dsp_exist_rendition_images" />
	</fuseaction>
	<!-- Images: Serve -->
	<fuseaction name="serve_image">
  		<include template="dsp_asset_images_show" />
	</fuseaction>
	<!-- Audios: Detail -->
	<fuseaction name="audios_detail">
  		<include template="dsp_asset_audios_detail" />
	</fuseaction>
	<!-- Audios: Detail Flash -->
	<fuseaction name="audios_detail_flash">
  		<include template="dsp_asset_audios_flash" />
	</fuseaction>
	<!-- Audios: Related -->
	<fuseaction name="audios_detail_related">
  		<include template="dsp_asset_audios_related" />
	</fuseaction>
	<!-- Audios: Renditions -->
	<fuseaction name="exist_rendition_audios">
  		<include template="dsp_exist_rendition_audios" />
	</fuseaction>
	<!-- eMail: eMail Send -->
	<fuseaction name="email_send">
  		<include template="dsp_email_send" />
	</fuseaction>
	
	<!-- FTP: FTP Send -->
	<fuseaction name="ftp_send">
  		<include template="dsp_ftp_send" />
	</fuseaction>
	<!-- FTP: FTP Put -->
	<fuseaction name="ftp_put">
  		<include template="dsp_ftp_put" />
	</fuseaction>
	
	
	<!-- SEARCH: Show results -->
	<fuseaction name="search">
  		<include template="dsp_search" />
	</fuseaction>
	<!-- SEARCH: Window for advanced search -->
	<fuseaction name="search_advanced">
  		<include template="win_search_advanced" />
	</fuseaction>
	
	
	<!-- CHOOSE: Choose Folder Window -->
	<fuseaction name="choose_folder">
  		<include template="win_choose_folder" />
	</fuseaction>
	
	<!-- BATCH: Show Window -->
	<fuseaction name="batch_form">
  		<include template="dsp_batch" />
	</fuseaction>
	
	<!-- ADMIN: Show Window -->
	<fuseaction name="admin">
  		<include template="dsp_admin" />
	</fuseaction>
	<!-- ADMIN: Users -->
	<fuseaction name="admin_users">
  		<include template="dsp_admin_users" />
	</fuseaction>
	<!-- ADMIN: AD Services -->
	<fuseaction name="admin_ad_services">
  		<include template="dsp_admin_ad_services" />
	</fuseaction>
	<!-- ADMIN: AD Server import Users list -->
	<fuseaction name="ad_server_users_list">
  		<include template="dsp_admin_ad_userlist" />
	</fuseaction>
	<fuseaction name="ad_server_users_list_do">
  		<include template="dsp_admin_ad_userlist_do" />
	</fuseaction>		
	<!-- ADMIN: Users Search -->
	<fuseaction name="users_search">
  		<include template="dsp_admin_users_results" />
	</fuseaction>
	<!-- ADMIN: Users Details -->
	<fuseaction name="users_detail">
  		<include template="dsp_admin_users_details" />
	</fuseaction>
	<!-- ADMIN: Users Check -->
	<fuseaction name="users_check">
  		<include template="dsp_users_check" />
	</fuseaction>
	<!-- ADMIN: User API -->
	<fuseaction name="admin_user_api">
  		<include template="dsp_admin_users_api" />
	</fuseaction>
	<!-- ADMIN: Groups List -->
	<fuseaction name="groups_list">
  		<include template="dsp_admin_groups_list" />
	</fuseaction>
	<!-- ADMIN: Groups Details -->
	<fuseaction name="groups_detail">
  		<include template="dsp_admin_groups_detail" />
	</fuseaction>
	<!-- ADMIN: Scheduler List -->
	<fuseaction name="scheduler_list">
  		<include template="dsp_admin_sched_list" />
	</fuseaction>
	<!-- ADMIN: Scheduler Detail -->
	<fuseaction name="scheduler_detail">
  		<include template="dsp_admin_sched_detail" />
	</fuseaction>
	<!-- ADMIN: Scheduler Status -->
	<fuseaction name="scheduler_status">
  		<include template="dsp_admin_sched_status" />
	</fuseaction>
	<!-- ADMIN: Scheduler Log -->
	<fuseaction name="scheduler_log">
  		<include template="dsp_admin_sched_log" />
	</fuseaction>
	<!-- ADMIN: Log Users -->
	<fuseaction name="log_users">
  		<include template="dsp_admin_log_users" />
	</fuseaction>
	<!-- ADMIN: Log Assets -->
	<fuseaction name="log_assets">
  		<include template="dsp_admin_log_assets" />
	</fuseaction>
	
	<!-- ADMIN: Log Folder Summary -->
	<fuseaction name="log_folder_summary">
  		<include template="dsp_admin_log_folder_summary" />
	</fuseaction>

	<!-- ADMIN: Log Folder Summary Report -->
	<fuseaction name="log_folder_summary_report">
  		<include template="dsp_admin_log_folder_summary_report" />
	</fuseaction>

	<!-- ADMIN: Log Folders -->
	<fuseaction name="log_folders">
  		<include template="dsp_admin_log_folders" />
	</fuseaction>
	<!-- ADMIN: Log Searches -->
	<fuseaction name="log_searches">
  		<include template="dsp_admin_log_searches" />
	</fuseaction>
	<!-- ADMIN: Log Errors -->
	<fuseaction name="log_errors">
  		<include template="dsp_admin_log_errors" />
	</fuseaction>
	<!-- ADMIN: Log Errors Detail -->
	<fuseaction name="log_errors_detail">
  		<include template="dsp_admin_log_errors_detail" />
	</fuseaction>
	<!-- ADMIN: Log Errors Detail -->
	<fuseaction name="log_errors_win">
  		<include template="dsp_admin_log_errors_win" />
	</fuseaction>
	<!-- ADMIN: Log Searches Summarizes -->
	<fuseaction name="log_searches_sum">
  		<include template="dsp_admin_log_searches_sum" />
	</fuseaction>
	<!-- ADMIN: Log Search -->
	<fuseaction name="log_search">
  		<include template="dsp_admin_log_search" />
	</fuseaction>
	<!-- ADMIN: Custom Fields -->
	<fuseaction name="custom_fields">
  		<include template="dsp_admin_custom_fields" />
	</fuseaction>
	<!-- ADMIN: Custom Fields Existing -->
	<fuseaction name="custom_fields_existing">
  		<include template="dsp_admin_custom_fields_existing" />
	</fuseaction>
	<!-- ADMIN: Custom Fields Detail -->
	<fuseaction name="custom_fields_detail">
  		<include template="dsp_admin_custom_fields_detail" />
	</fuseaction>
	<!-- ADMIN: Settings -->
	<fuseaction name="isp_settings">
  		<include template="dsp_admin_settings" />
	</fuseaction>
	<!-- ADMIN: Settings Upload -->
	<fuseaction name="isp_settings_upload">
  		<include template="dsp_admin_settings_upload" />
	</fuseaction>
	<!-- ADMIN: Load Logo -->
	<fuseaction name="prefs_loadlogo">
  		<include template="dsp_admin_settings_loadlogo" />
	</fuseaction>
	<!-- ADMIN: Load Login Image -->
	<fuseaction name="prefs_loadloginimg">
  		<include template="dsp_admin_settings_loadloginimg" />
	</fuseaction>
	<!-- ADMIN: Load Favicon Image -->
	<fuseaction name="prefs_loadfavicon">
  		<include template="dsp_admin_settings_loadfavicon" />
	</fuseaction>
	<!-- Users Randompass -->
	<fuseaction name="randompass">
  		<include template="dsp_randompass" />
	</fuseaction>
	<!-- ADMIN: Integration -->
	<fuseaction name="admin_integration">
  		<include template="dsp_admin_integration" />
	</fuseaction>
	<!-- ADMIN: Integration -->
	<fuseaction name="admin_integration_s3">
  		<include template="dsp_admin_integration_s3" />
	</fuseaction>
	<!-- ADMIN: Customization -->
	<fuseaction name="admin_customization">
  		<include template="dsp_admin_customization" />
	</fuseaction>
	<!-- ADMIN: Notification -->
	<fuseaction name="admin_notification">
  		<include template="dsp_admin_notification" />
	</fuseaction>
	<!-- ADMIN: Maintenance -->
	<fuseaction name="admin_maintenance">
  		<include template="dsp_admin_maintenance" />
	</fuseaction>
	<!-- ADMIN: Maintenance Cloud -->
	<fuseaction name="admin_maintenance_cloud">
  		<include template="dsp_admin_maintenance_cloud" />
	</fuseaction>
	<!-- ADMIN: Maintenance Upload -->
	<fuseaction name="admin_maintenance_upload">
  		<include template="dsp_admin_maintenance_upload" />
	</fuseaction>
	<!-- ADMIN: Maintenance -->
	<fuseaction name="admin_maintenance_cleaner">
  		<include template="dsp_admin_maintenance_cleaner" />
	</fuseaction>
	<!-- ADMIN: System Information -->
	<fuseaction name="admin_system">
  		<include template="dsp_admin_system" />
	</fuseaction>
	<!-- ADMIN: Upload Templates -->
	<fuseaction name="upl_templates">
  		<include template="dsp_admin_upl_templates" />
	</fuseaction>
	<!-- ADMIN: Upload Templates Details -->
	<fuseaction name="upl_template_detail">
  		<include template="dsp_admin_upl_template_detail" />
	</fuseaction>
	<!-- ADMIN: Labels -->
	<fuseaction name="admin_labels">
  		<include template="dsp_admin_labels" />
	</fuseaction>
	<!-- ADMIN: Labels all -->
	<fuseaction name="admin_labels_add">
  		<include template="win_label_add" />
	</fuseaction>
	<!-- Labels -->
	<fuseaction name="labels">
  		<include template="dsp_labels" />
	</fuseaction>
	<!-- Labels Main -->
	<fuseaction name="labels_main">
  		<include template="dsp_labels_main" />
	</fuseaction>
	<!-- Labels Main Assets -->
	<fuseaction name="labels_main_assets">
  		<include template="dsp_labels_main_assets" />
	</fuseaction>
	<!-- Labels Main Folders -->
	<fuseaction name="labels_main_folders">
  		<include template="dsp_labels_main_folders" />
	</fuseaction>
	<!-- Labels Main Collections -->
	<fuseaction name="labels_main_collections">
  		<include template="dsp_labels_main_collections" />
	</fuseaction>
	<!-- Labels Main Comments -->
	<fuseaction name="labels_main_properties">
  		<include template="dsp_labels_main_properties" />
	</fuseaction>
	<!-- ADMIN: Import Templates -->
	<fuseaction name="imp_templates">
  		<include template="dsp_admin_imp_templates" />
	</fuseaction>
	<!-- ADMIN: Import Templates Details -->
	<fuseaction name="imp_template_detail">
  		<include template="dsp_admin_imp_template_detail" />
	</fuseaction>
	<!-- ADMIN: Watermark Templates -->
	<fuseaction name="admin_watermark_templates">
  		<include template="dsp_admin_watermark_templates" />
	</fuseaction>
	<!-- ADMIN: Watermark Templates Details -->
	<fuseaction name="admin_watermark_template_detail">
  		<include template="dsp_admin_watermark_template_detail" />
	</fuseaction>
	<!-- ADMIN: Watermark Upload -->
	<fuseaction name="admin_watermark_upload">
  		<include template="dsp_watermark_upload" />
	</fuseaction>
	<!-- ADMIN: Show user of groups -->
	<fuseaction name="groups_list_users">
  		<include template="dsp_groups_list_users" />
	</fuseaction>
	<!-- ADMIN: Plugin -->
	<fuseaction name="plugin_info">
  		<include template="win_plugin_info" />
	</fuseaction>

	<!-- Plugin: settings loader -->
	<fuseaction name="plugin_settings_loader">
  		<include template="dsp_plugin_settings_loader" />
	</fuseaction>
	<!-- Plugin: loader -->
	<fuseaction name="plugin_loader">
  		<include template="dsp_plugin_loader" />
	</fuseaction>
	
	<!-- Gears -->
	<fuseaction name="gears">
  		<include template="win_gears" />
	</fuseaction>
	
	<!-- Help -->
	<fuseaction name="help">
  		<include template="win_help" />
	</fuseaction>
	
	<!-- Account -->
	<fuseaction name="account">
  		<include template="win_account" />
	</fuseaction>
	
	<!-- PDF -->
	<fuseaction name="topdf_window">
  		<include template="dsp_topdf_window" />
	</fuseaction>
	<fuseaction name="topdf">
  		<include template="dsp_topdf" />
	</fuseaction>
	
	<!-- API Feedback -->
	<fuseaction name="api_feedback">
  		<include template="dsp_api_feedback" />
	</fuseaction>
	
	<!-- Process -->
	<fuseaction name="process">
  		<include template="dsp_process" />
	</fuseaction>
	
	<!-- Comments -->
	<fuseaction name="comments">
  		<include template="dsp_comments" />
	</fuseaction>
	<!-- Comments: List -->
	<fuseaction name="comments_list">
  		<include template="dsp_comments_list" />
	</fuseaction>
	<!-- Comments: Edit -->
	<fuseaction name="comments_edit">
  		<include template="win_comments_edit" />
	</fuseaction>
	<!-- Comments Share: List -->
	<fuseaction name="share_comments_list">
  		<include template="dsp_share_comments_list" />
	</fuseaction>
	<!-- Comments Share: Latest comment -->
	<fuseaction name="share_comments_latest">
  		<include template="dsp_share_comments_latest" />
	</fuseaction>
	
	<!-- Share: Content -->
	<fuseaction name="share_content">
  		<include template="dsp_share_content" />
	</fuseaction>
	<!-- Share: Remove record -->
	<fuseaction name="share_remove_record">
  		<include template="win_share_remove_record" />
	</fuseaction>
	<!-- Share: Order Basket -->
	<fuseaction name="share_order">
  		<include template="dsp_share_order" />
	</fuseaction>
	
	<!-- Versions -->
	<fuseaction name="versions">
  		<include template="dsp_versions" />
	</fuseaction>
	<!-- Versions: List -->
	<fuseaction name="versions_list">
  		<include template="dsp_versions_list" />
	</fuseaction>
	<!-- Versions: Upload -->
	<fuseaction name="versions_upload">
  		<include template="dsp_versions_upload" />
	</fuseaction>
	
	<!-- FB reload -->
	<fuseaction name="fbparsecmd">
  		<include template="cmd_fbparsecmd" />
	</fuseaction>
	
	<!-- Share Options -->
	<fuseaction name="share_options">
  		<include template="dsp_share_options" />
	</fuseaction>
	
	<!-- Orders -->
	<fuseaction name="orders">
  		<include template="dsp_orders" />
	</fuseaction>
	
	<!-- Datatables -->
	<fuseaction name="datatables_json">
  		<include template="dsp_datatables_json" />
	</fuseaction>
	
	<!-- Views -->
	<fuseaction name="views">
  		<include template="dsp_views" />
	</fuseaction>
	
	<!-- Preview Image -->
	<fuseaction name="previewimage">
  		<include template="dsp_previewimage" />
	</fuseaction>
	<!-- Preview Image Preview -->
	<fuseaction name="previewimage_prev">
  		<include template="dsp_previewimage_prev" />
	</fuseaction>
	<!-- Recreate Image Preview -->
	<fuseaction name="recreate_previews">
  		<include template="win_preview_images" />
	</fuseaction>
	
	<!-- Widgets -->
	<fuseaction name="widgets">
  		<include template="dsp_widgets" />
	</fuseaction>
	<!-- Widgets: Detail -->
	<fuseaction name="widget_detail">
  		<include template="win_widget_detail" />
	</fuseaction>
	<!-- Widgets: External Call -->
	<fuseaction name="widget_iframe">
  		<include template="dsp_widget_iframe" />
	</fuseaction>
	<!-- Widgets: Download Window -->
	<fuseaction name="widget_download">
  		<include template="win_widget_download" />
	</fuseaction>
	
	<!-- Folder Thumbnail -->
	<fuseaction name="folder_thumbnail">
  		<include template="dsp_folder_thumbnail" />
	</fuseaction>
	
	<fuseaction name="folder_thumbnail_save">
  		<include template="inc_folder_thumbnail_save" />
	</fuseaction>
	
	
	<!-- Additional versions -->
	<fuseaction name="adi_versions">
  		<include template="dsp_additional_versions" />
	</fuseaction>
	<!-- Show for detail pages Additional versions -->
	<fuseaction name="av_load">
  		<include template="dsp_additional_versions_all" />
	</fuseaction>
	<!-- Edit Additional versions -->
	<fuseaction name="av_edit">
  		<include template="win_additional_versions_edit" />
	</fuseaction>
	
	<!-- Meta: Export -->
	<fuseaction name="meta_export">
  		<include template="dsp_meta_export" />
	</fuseaction>

	<!-- Meta: Import -->
	<fuseaction name="meta_imp">
  		<include template="dsp_meta_import" />
	</fuseaction>
	<!-- Meta: Import Upload window -->
	<fuseaction name="meta_imp_upload">
  		<include template="dsp_meta_import_upload" />
	</fuseaction>
	
	<!-- Download Folder -->
	<fuseaction name="download_folder">
  		<include template="dsp_download_folder" />
	</fuseaction>
	
	<!-- User: Export -->
	<fuseaction name="users_export">
  		<include template="dsp_admin_users_export" />
	</fuseaction>
	<!-- User: Import -->
	<fuseaction name="users_import">
  		<include template="dsp_admin_users_import" />
	</fuseaction>
	<!-- User: Import -->
	<fuseaction name="users_import_upload">
  		<include template="dsp_admin_users_import_upload" />
	</fuseaction>

	<!-- Mini: Slider -->
	<fuseaction name="mini_browser_files">
  		<include template="dsp_mini_browser_files" />
	</fuseaction>
	<!-- Mini: Search Results -->
	<fuseaction name="mini_search">
  		<include template="dsp_mini_search" />
	</fuseaction>

	<!-- File: Download -->
	<fuseaction name="file_download">
  		<include template="dsp_file_download" />
	</fuseaction>

	<!-- Rendition: Metadata -->
	<fuseaction name="rend_meta">
  		<include template="win_rend_meta" />
	</fuseaction>

	<!-- Collection: Release -->
	<fuseaction name="col_release">
  		<include template="win_collection_release" />
	</fuseaction>
	<!-- Collection: Copy -->
	<fuseaction name="col_copy">
  		<include template="win_collection_copy" />
	</fuseaction>

	<!-- Smart Folders: List -->
	<fuseaction name="smart_folders">
  		<include template="dsp_smart_folders" />
	</fuseaction>
	<!-- Smart Folders: Settings -->
	<fuseaction name="smart_folders_settings">
  		<include template="dsp_smart_folders_settings" />
	</fuseaction>
	<!-- Smart Folders: Content -->
	<fuseaction name="smart_folders_content">
  		<include template="dsp_smart_folders_content" />
	</fuseaction>
	<!-- Smart Folders: Account Content -->
	<fuseaction name="sf_load_account">
  		<include template="dsp_sf_load_account" />
	</fuseaction>
	<!--  Select label popup Window -->
	<fuseaction name="select_label_popup">
  		<include template="win_choose_labels" />
	</fuseaction>
	<!-- Search label for the asset -->
	<fuseaction name="search_label_for_asset">
  		<include template="dsp_search_label_for_asset" />
	</fuseaction>
	<!-- Folder subscribe -->
	<fuseaction name="folder_subscribe">
		<include template="dsp_folder_subscribe" />
	</fuseaction>
	<!-- Metadata export template -->
	<fuseaction name="admin_export_template">
		<include template="dsp_admin_export_template" />
	</fuseaction>

	<!-- Updater -->
	<fuseaction name="updater_tool">
		<include template="dsp_updater_tool" />
	</fuseaction>

	<!-- Alias -->
	<fuseaction name="trash_alias">
		<include template="win_trash_alias" />
	</fuseaction>
	
	<!-- Admin Access -->
	<fuseaction name="admin_access">
		<include template="dsp_admin_access" />
	</fuseaction>

	<!-- Upload basket to local storage -->
	<fuseaction name="basket_upload2local">
		<include template="dsp_basket_upload2local" />
	</fuseaction>
	
	<!-- WL section -->
	<fuseaction name="wl_host">
		<include template="dsp_wl_host" />
	</fuseaction>
	<fuseaction name="wl_news">
		<include template="dsp_wl_news" />
	</fuseaction>
	<fuseaction name="wl_news_edit">
		<include template="dsp_wl_news_edit" />
	</fuseaction>

</circuit>
