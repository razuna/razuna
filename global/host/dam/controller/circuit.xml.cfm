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
		<xfa name="req_access" value="c.req_access" />
		<!-- Params -->
		<set name="attributes.loginerror" value="F" overwrite="false" />
		<set name="attributes.passsend" value="F" overwrite="false" />
		<set name="attributes.sameuser" value="F" overwrite="false" />
		<if condition="#session.hostid# NEQ ''">
			<true>
				<!-- CFC: Get languages -->
				<do action="languages" />
			</true>
		</if>
		<!-- If ISP (for now) -->
		<if condition="#application.razuna.isp#">
			<true>
				<set name="attributes.frontpage" value="true" />
				<invoke object="myFusebox.getApplicationData().settings" methodcall="news_get(attributes)" returnvariable="attributes.qry_news" />
			</true>
		</if>
		<!-- Show -->
		<do action="v.login" />
	</fuseaction>
	<!--
		Check the login, write a log entry and let the user in or not
	-->
	<fuseaction name="dologin">
		<!-- Params -->
		<set name="attributes.rem_login" value="F" overwrite="false" />
		<set name="session.indebt" value="false" />
		<!-- Check the user and let him in ot nor -->
		<invoke object="myFusebox.getApplicationData().Login" methodcall="login(attributes.name,attributes.pass,'dam',attributes.rem_login)" returnvariable="logindone" />
		<!-- Log this action -->
		<if condition="logindone.notfound EQ 'F'">
    		<true>
				<!-- Log -->
				<invoke object="myFusebox.getApplicationData().log" method="log_users">
					<argument name="theuserid" value="#logindone.qryuser.user_id#" />
					<argument name="logaction" value="Login" />
					<argument name="logsection" value="DAM" />
    				<argument name="logdesc" value="Login: User-ID: #logindone.qryuser.user_id# eMail: #logindone.qryuser.user_email# First Name: #logindone.qryuser.user_first_name#  Last Name: #logindone.qryuser.user_last_name#" />
				</invoke>
				<!-- check groups -->
				<invoke object="myFusebox.getApplicationData().groups" methodcall="getdetail('SystemAdmin')" returnvariable="qry_sysadmingrp" />
				<invoke object="myFusebox.getApplicationData().groups" methodcall="getdetail('Administrator')" returnvariable="qry_admingrp" />
				<invoke object="myFusebox.getApplicationData().groups_users" methodcall="getGroupsOfUser(logindone.qryuser.user_id)" returnvariable="qry_groups_user" />
				<!-- CFC: Check for collection -->
				<invoke object="myFusebox.getApplicationData().lucene" methodcall="exists()" />
				<!-- set host again with real value -->
				<invoke object="myFusebox.getApplicationData().security" methodcall="initUser(Session.hostid,logindone.qryuser.user_id,'adm')" returnvariable="Request.securityobj" />
				<!-- TL = Transparent login. In other words this action is called directly -->
				<if condition="structkeyexists(attributes,'tl')">
					<true>
						<relocate url="#variables.thehttp##cgi.http_host##myself#c.main" />
					</true>
				</if>
			</true>
			<false>
				<!-- Log -->
				<invoke object="myFusebox.getApplicationData().log" method="log_users">
					<argument name="theuserid" value="0" />
					<argument name="logaction" value="Error" />
					<argument name="logsection" value="DAM" />
    				<argument name="logdesc" value="Login Error for Name: #attributes.name#" />
				</invoke>
		   		<set name="attributes.loginerror" value="T" />
		   		<if condition="structkeyexists(attributes,'tl')">
					<true>
						<relocate url="#variables.thehttp##cgi.http_host##myself#c.logout&amp;loginerror=T" />
					</true>
				</if>
		   		<!-- <do action="login" /> -->
		   	</false>
		</if>
	</fuseaction>
	
	<!-- 
	NIRVANIX
	-->

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
		<if condition="application.razuna.storage EQ 'amazon'">
			<true>
				<!-- Get AWS Bucket -->
				<invoke object="myFusebox.getApplicationData().settings" methodcall="prefs_storage()" returnvariable="qry_storage" />
				<!-- Set bucket -->
				<set name="attributes.awsbucket" value="#qry_storage.set2_aws_bucket#" />
			</true>
		</if>
	</fuseaction>
	
	<!-- 
	GLOBAL Fuseaction for Languages
	 -->
	 <fuseaction name="languages">
		<!-- Get languages -->
		<invoke object="myFusebox.getApplicationData().defaults" methodcall="getlangs()" returnvariable="qry_langs" />
		<!-- Set as attributes also -->
		<set name="attributes.thelangs" value="#qry_langs#" />
	</fuseaction>
	<!-- 
	GLOBAL Fuseaction for Labels
	 -->
	 <fuseaction name="labels">
		<!-- Get languages -->
		<invoke object="myFusebox.getApplicationData().labels" methodcall="getalllabels()" returnvariable="qry_labels" />
		<!-- Set as attributes also -->
		<set name="attributes.thelabels" value="#qry_labels.l#" />
		<set name="attributes.thelabelsqry" value="#qry_labels.qryl#" />
	</fuseaction>
	
	<!--
		For the main layout queries and settings
	 -->
	 <fuseaction name="main">
	 	<if condition="#session.login# EQ 'T'">
	 		<true>
	 			<set name="session.hosttype" value="" overwrite="false" />
	 			<!-- If ISP (for now) -->
				<if condition="#application.razuna.isp#">
					<true>
						<!-- Get News -->
						<invoke object="myFusebox.getApplicationData().settings" methodcall="news_get(attributes)" returnvariable="attributes.qry_news" />
						<!-- Get Invoices -->
						<invoke object="myFusebox.getApplicationData().global" methodcall="getaccount(cgi.HTTP_X_FORWARDED_SERVER,session.hostid)" returnvariable="res_account" />
					</true>
				</if>
				<!-- For Nirvanix get usage count -->
				<if condition="application.razuna.storage EQ 'nirvanix' OR session.hosttype EQ 'f'">
					<true>
						<!-- Action: Check storage -->
						<do action="storage" />
						<invoke object="myFusebox.getApplicationData().Nirvanix" methodcall="GetAccountUsage(session.hostid,attributes.nvxsession)" returnvariable="attributes.nvxusage" />
					</true>
				</if>
				<!-- CFC: Custom fields -->
				<invoke object="myFusebox.getApplicationData().custom_fields" methodcall="getfieldssearch(attributes)" returnvariable="qry_cf_fields" />
				<!-- CFC: Get Wisdom phrases -->
				<invoke object="myFusebox.getApplicationData().Global" methodcall="wisdom()" returnvariable="wisdom" />
				<!-- CFC: Get Orders of this user -->
				<invoke object="myFusebox.getApplicationData().basket" methodcall="get_orders()" returnvariable="qry_orders" />
				<!-- Show main page -->
			 	<do action="v.main" />
			</true>
			<false>
				 <do action="login" />
			</false>
		</if>
	 </fuseaction>
	<!--
		Main System Info
	 -->
	 <fuseaction name="mainsysteminfo">
		<!-- CFC: Count all files -->
		<invoke object="myFusebox.getApplicationData().Folders" methodcall="filetotalcount(0,'T')" returnvariable="totalcount" />
		<!-- Show main page -->
	 	<do action="ajax.mainsysteminfo" />
	 </fuseaction>
	 <!--
		Main Blog
	 -->
	 <fuseaction name="mainblog">
		<!-- CFC: Parse RSS Feed -->
		<invoke object="myFusebox.getApplicationData().rssparser" methodcall="rssparse('http://blog.razuna.com/feed/rss',10)" returnvariable="blogss" />
		<!-- Show main page -->
	 	<do action="ajax.mainblog" />
	 </fuseaction>

	<!--
		User forgot his password (which happens quite often)
	 -->
	<fuseaction name="forgotpass">
		<xfa name="submitform" value="c.forgotpasssend" />
		<xfa name="linkback" value="c.login" />
		<do action="ajax.forgotpass" />
	</fuseaction>
	<!--
		User forgot his password so we send the password now
	 -->
	<fuseaction name="forgotpasssend">
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
		User requests access
	 -->
	<fuseaction name="req_access">
		<xfa name="submitform" value="c.req_access_send" />
		<xfa name="linkback" value="c.login" />
		<do action="ajax.req_access" />
	</fuseaction>
	<!--
		Send Request
	 -->
	<fuseaction name="req_access_send">
		<!-- Params -->
		<set name="attributes.user_login_name" value="#attributes.user_email#" />
		<set name="attributes.user_company" value="" />
		<set name="attributes.user_phone" value="" />
		<set name="attributes.user_mobile" value="" />
		<set name="attributes.user_fax" value="" />
		<set name="attributes.user_salutation" value="" />
		<set name="attributes.hostid" value="#session.hostid#" />
		<set name="session.theuserid" value="0" />
		<!-- Check the email address of the user -->
		<invoke object="myFusebox.getApplicationData().users" methodcall="add(attributes)" returnvariable="status" />
		<!-- Inform admins of this user request by eMails -->
		<if condition="#status# NEQ 0">
			<true>
				<invoke object="myFusebox.getApplicationData().Login" methodcall="reqaccessemail(attributes)" />
			</true>
		</if>
		<!-- Show -->
		<do action="ajax.req_access_feedback" />
	</fuseaction>
	
	<!--
		User switches language
	 -->
	<fuseaction name="switchlang">
		<!-- CFC -->
		<invoke object="myFusebox.getApplicationData().global" methodcall="switchlang(attributes.thelang)" />
		<!-- Where to go -->
		<if condition="attributes.to EQ 'index'">
    		<true>
				<do action="login" />
			</true>
			<false>
				<!-- If this is coming from a share -->
				<if condition="attributes.to CONTAINS 'share'">
    				<true>
						<set name="attributes.fid" value="#session.fid#" />
						<if condition="attributes.to EQ 'share'">
							<true>
								<do action="share" />
							</true>
							<false>
								<do action="sharep" />
							</false>
						</if>
					</true>
					<false>
						<do action="main" />
					</false>
				</if>
			</false>
		</if>
	</fuseaction>
	<!--
		Logoff
	 -->
	<fuseaction name="logout">
		<if condition="structkeyexists(session,'theuserid') AND session.theuserid NEQ ''">
			<true>
				<!-- CFC: User info for log -->
				<set name="attributes.user_id" value="#session.theuserid#" />
				<invoke object="myFusebox.getApplicationData().users" methodcall="details(attributes)" returnvariable="theuser" />
				<!-- Log -->
				<invoke object="myFusebox.getApplicationData().log" method="log_users">
					<argument name="theuserid" value="#session.theuserid#" />
					<argument name="logaction" value="Logout" />
					<argument name="logsection" value="DAM" />
		 			<argument name="logdesc" value="Logout: UserID: #session.theuserid# eMail: #theuser.user_email# First Name: #theuser.user_first_name# Last Name: #theuser.user_last_name#" />
				</invoke>
			</true>
		</if>
		<set name="session.login" value="F" />
		<set name="session.weblogin" value="F" />
		<set name="session.thegroupofuser" value="" />
		<set name="session.theuserid" value="" />
		<set name="session.thedomainid" value="" />
		<do action="login" />
	</fuseaction>
	
	<!--
		START: GET SETTINGS FOR CALLS
	 -->
	
	<!-- Get Path to Assets -->
	<fuseaction name="assetpath">
		<invoke object="myFusebox.getApplicationData().settings" method="assetpath" returnvariable="attributes.assetpath" />
	</fuseaction>
	
	<!--
		END: GET SETTINGS FOR CALLS
	 -->
	
	<!--
		START: EXPLORER
	 -->
	
	<!-- Load Explorer -->
	<fuseaction name="explorer">
		<!-- Param -->
		<set name="attributes.cache" value="" />
		<set name="session.showmyfolder" value="F" overwrite="false" />
		<if condition="structkeyexists(attributes,'showmyfolder')">
			<true>
				<set name="session.showmyfolder" value="#attributes.showmyfolder#" />
			</true>
		</if>
		<!-- XFA -->
		<xfa name="folder" value="c.folder" />
		<xfa name="foldernew" value="c.folder_new" />
		<xfa name="collections" value="c.collections" />
		<!-- Set showmyfolder state -->
		<!-- Show -->
		<do action="ajax.explorer" />
	</fuseaction>
	
	<!-- Load Explorer -->
	<fuseaction name="explorer_col">
		<!-- XFA -->
		<xfa name="foldernew" value="c.folder_new" />
		<xfa name="collections" value="c.collections" />
		<!-- Set showmyfolder state -->
		<!-- Show -->
		<do action="ajax.explorer_col" />
	</fuseaction>
	
	<!-- Load Folders for tree -->
	<fuseaction name="getfolderfortree">
		<!-- Param -->
		<set name="attributes.col" value="F" overwrite="false" />
		<set name="attributes.id" value="0" overwrite="false" />
		<set name="attributes.actionismove" value="F" overwrite="false" />
		<set name="session.showmyfolder" value="F" overwrite="false" />
		<!-- Get folder record -->
		<invoke object="myFusebox.getApplicationData().folders" method="getfoldersfortree" returnvariable="qFolder">
			<argument name="thestruct" value="#attributes#" />
			<argument name="id" value="#attributes.id#" />
			<argument name="col" value="#attributes.col#" />
		</invoke>
	</fuseaction>
	
	
	
	<!--
		END: EXPLORER
	 -->
	
	<!--
		START: FAVORITES
	 -->
	
	<!-- Load Favorites -->
	<fuseaction name="favorites">
		<!-- XFA -->
		<xfa name="filedetail" value="c.files_detail" />
		<xfa name="imagedetail" value="c.images_detail" />
		<xfa name="videodetail" value="c.videos_detail" />
		<xfa name="audiodetail" value="c.audios_detail" />
		<xfa name="folder" value="c.folder" />
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- Action: Check storage
		<set name="attributes.isbrowser" value="#session.isbrowser#" />
		<do action="storage" /> -->
		<!-- CFC: Load users favorites -->
		<invoke object="myFusebox.getApplicationData().favorites" methodcall="readfavorites(attributes)" returnvariable="qry_favorites" />
		<set name="attributes.qrybasket" value="#qry_favorites#" />
		<!-- CFC: Get details for files -->
		<invoke object="myFusebox.getApplicationData().files" methodcall="detailforbasket(attributes)" returnvariable="qry_thefile" />
		<!-- CFC: Get details for images -->
		<invoke object="myFusebox.getApplicationData().images" methodcall="detailforbasket(attributes)" returnvariable="qry_theimage" />
		<!-- CFC: Get details for videos -->
		<invoke object="myFusebox.getApplicationData().videos" methodcall="detailforbasket(attributes)" returnvariable="qry_thevideo" />
		<!-- CFC: Get details for audios -->
		<invoke object="myFusebox.getApplicationData().audios" methodcall="detailforbasket(attributes)" returnvariable="qry_theaudio" />
		<!-- Show -->
		<do action="ajax.favorites" />
	</fuseaction>

	<!--
		END: FAVORITES
	 -->

	<!--
		START: BASKET
	 -->
	
	<!-- INCLUDE: Load Basket Include -->
	<fuseaction name="basket_include">
		<xfa name="filedetail" value="c.files_detail" />
		<xfa name="imagedetail" value="c.images_detail" />
		<xfa name="videodetail" value="c.videos_detail" />
		<xfa name="audiodetail" value="c.audios_detail" />
		<xfa name="fvideosloader" value="c.folder_videos_show" />
		<xfa name="sendemail" value="c.basket_email_form" />
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- Action: Check storage
		<set name="attributes.isbrowser" value="#session.isbrowser#" />
		<do action="storage" /> -->
		<!-- CFC: Load basket -->
		<invoke object="myFusebox.getApplicationData().basket" methodcall="readbasket(attributes)" returnvariable="qry_basket" />
		<set name="attributes.qrybasket" value="#qry_basket#" />
		<!-- CFC: Get details for files -->
		<invoke object="myFusebox.getApplicationData().files" methodcall="detailforbasket(attributes)" returnvariable="qry_thefile" />
		<!-- CFC: Get details for images -->
		<invoke object="myFusebox.getApplicationData().images" methodcall="detailforbasket(attributes)" returnvariable="qry_theimage" />
		<!-- CFC: Get details for videos -->
		<invoke object="myFusebox.getApplicationData().videos" methodcall="detailforbasket(attributes)" returnvariable="qry_thevideo" />
		<!-- CFC: Get details for audios -->
		<invoke object="myFusebox.getApplicationData().audios" methodcall="detailforbasket(attributes)" returnvariable="qry_theaudio" />
		<!-- CFC: Get related image records -->
		<set name="attributes.related" value="T" />
		<invoke object="myFusebox.getApplicationData().images" methodcall="detailforbasket(attributes)" returnvariable="qry_theimage_related" />
		<!-- CFC: Get related video records -->
		<set name="attributes.related" value="T" />
		<invoke object="myFusebox.getApplicationData().videos" methodcall="detailforbasket(attributes)" returnvariable="qry_thevideo_related" />
		<!-- CFC: Get related audio records -->
		<set name="attributes.related" value="T" />
		<invoke object="myFusebox.getApplicationData().audios" methodcall="detailforbasket(attributes)" returnvariable="qry_theaudio_related" />
		<!-- If from share we query downloadable settings -->
		<if condition="#attributes.fromshare# EQ 'T'">
			<true>
				<!-- CFC: Get folder or collection share options -->
				<if condition="#session.iscol# EQ 'F'">
					<true>
						<invoke object="myFusebox.getApplicationData().folders" methodcall="getfolder(session.fid)" returnvariable="qry_folder" />
					</true>
					<false>
						<!-- Param -->
						<set name="attributes.col_id" value="#session.fid#" />
						<set name="attributes.share" value="T" />
						<!-- CFC: Get folder share options -->
						<invoke object="myFusebox.getApplicationData().collections" methodcall="details(attributes)" returnvariable="qry_folder" />
					</false>
				</if>
				<!-- CFC: Get individual share options -->
				<invoke object="myFusebox.getApplicationData().global" methodcall="get_share_options(attributes)" returnvariable="qry_share_options" />
			</true>
		</if>
	</fuseaction>
	<!-- INCLUDE: Remove all items in basket -->
	<fuseaction name="basket_full_remove_all_include">
		<!-- CFC: Remove ALLItem in Basket -->
		<invoke object="myFusebox.getApplicationData().basket" methodcall="removebasket()" />
	</fuseaction>
	<!-- INCLUDE: Remove item in basket -->
	<fuseaction name="basket_full_remove_items">
		<!-- CFC: Remove Item in Basket -->
		<invoke object="myFusebox.getApplicationData().basket" methodcall="removeitem(attributes.id)" />
	</fuseaction>
	<!-- Load Basket -->
	<fuseaction name="basket">
		<!-- Param -->
		<set name="attributes.fromshare" value="F" overwrite="false" />
		<!-- Load include -->
		<do action="basket_include" />
		<!-- Show -->
		<do action="ajax.basket" />
	</fuseaction>
	<!-- Load full Basket -->
	<fuseaction name="basket_full">
		<!-- Param -->
		<set name="attributes.fromshare" value="F" overwrite="false" />
		<!-- Load include -->
		<do action="basket_include" />
		<!-- Show -->
		<do action="ajax.basket_full" />
	</fuseaction>
	<!-- Remove item -->
	<fuseaction name="basket_full_remove">
		<!-- Load include -->
		<do action="basket_full_remove_items" />
		<!-- Show -->
		<do action="basket_full" />
	</fuseaction>
	<!-- Remove all items in basket -->
	<fuseaction name="basket_full_remove_all">
		<!-- Load include -->
		<do action="basket_full_remove_all_include" />
		<!-- Show -->
		<do action="basket_full" />
	</fuseaction>
	<!-- Remove all items in basket -->
	<fuseaction name="basket_full_remove_all_footer">
		<!-- Load include -->
		<do action="basket_full_remove_all_include" />
		<!-- Show -->
		<do action="basket" />
	</fuseaction>
	<!-- Download Basket -->
	<fuseaction name="basket_download">
		<!-- Params -->
		<set name="attributes.thepath" value="#thispath#" />
		<set name="attributes.dynpath" value="#dynpath#" />
		<set name="attributes.pathoneup" value="#pathoneup#" />
		<set name="attributes.type" value="doc" />
		<set name="attributes.hostid" value="#session.hostid#" />
		<set name="attributes.httphost" value="#cgi.http_host#" />
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- Action: Storage -->
		<do action="storage" />
		<!-- CFC: Get items and download to system -->
		<invoke object="myFusebox.getApplicationData().basket" methodcall="writebasket(attributes)" returnvariable="attributes.dllinkbasket" />
	</fuseaction>
	<!-- Basket eMail Form -->
	<fuseaction name="basket_email_form">
		<!-- Params -->
		<xfa name="submit" value="c.basket_email_send" />
		<set name="attributes.file_id" value="" />
		<set name="attributes.thetype" value="" />
		<set name="attributes.frombasket" value="T" />
		<!-- CFC: Get user email -->
		<invoke object="myFusebox.getApplicationData().users" methodcall="user_email()" returnvariable="qryuseremail" />
		<!-- Show -->
		<do action="ajax.email_send" />
	</fuseaction>
	<!-- Basket eMail Form -->
	<fuseaction name="basket_email_send">
		<!-- Params -->
		<set name="attributes.hostid" value="#session.hostid#" />
		<set name="attributes.dynpath" value="#dynpath#" />
		<set name="attributes.pathoneup" value="#pathoneup#" />
		<set name="attributes.httphost" value="#cgi.http_host#" />
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- Action: Storage -->
		<do action="storage" />
		<!-- CFC: Get items and download to system -->
		<invoke object="myFusebox.getApplicationData().basket" methodcall="writebasket(attributes)" returnvariable="thebasket" />
		<!-- CFC: Send eMail -->
		<invoke object="myFusebox.getApplicationData().email" method="send_email">
			<argument name="to" value="#attributes.to#" />
			<argument name="cc" value="#attributes.cc#" />
			<argument name="bcc" value="#attributes.bcc#" />
			<argument name="to" value="#attributes.to#" />
			<argument name="subject" value="#attributes.subject#" />
			<argument name="attach" value="#thebasket#" />
			<argument name="themessage" value="#attributes.message#" />
			<argument name="thepath" value="#attributes.thepath#" />
			<argument name="sendaszip" value="T" />
		</invoke>
	</fuseaction>
	<!-- Basket FTP Form -->
	<fuseaction name="basket_ftp_form">
		<!-- Params -->
		<set name="attributes.frombasket" value="T" />
		<set name="attributes.file_id" value="0" />
		<set name="attributes.thetype" value="" />
		<!-- Show -->
		<do action="ajax.ftp_send" />
	</fuseaction>
	<!-- Basket FTP Put -->
	<fuseaction name="basket_ftp_put">
		<!-- Put session into attributes -->
		<set name="attributes.artofimage" value="#session.artofimage#" />
		<set name="attributes.artofvideo" value="#session.artofvideo#" />
		<set name="attributes.artofaudio" value="#session.artofaudio#" />
		<set name="attributes.artoffile" value="#session.artoffile#" />
		<set name="attributes.dynpath" value="#dynpath#" />
		<set name="attributes.pathoneup" value="#pathoneup#" />
		<!-- Params -->
		<set name="attributes.hostid" value="#session.hostid#" />
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- Action: Storage -->
		<do action="storage" />
		<!-- CFC: Get items and download to system -->
		<invoke object="myFusebox.getApplicationData().basket" methodcall="writebasket(attributes)" returnvariable="attributes.thefile" />
		<!-- CFC: Upload to FTP -->
		<invoke object="myFusebox.getApplicationData().ftp" methodcall="putfile(attributes)" />
	</fuseaction>
	<!-- Basket Save as ZIP FORM -->
	<fuseaction name="basket_saveas_zip">
		<!-- Param -->
		<set name="session.type" value="saveaszip" />
		<!-- Show the choose folder -->
		<do action="choose_folder" />
	</fuseaction>
	<!-- Basket Save as ZIP DO -->
	<fuseaction name="saveaszip_do">
		<!-- Param -->
		<set name="attributes.fromzip" value="T" />
		<set name="attributes.thepath" value="#thispath#" />
		<set name="attributes.folderpath" value="#thispath#/incoming" />
		<set name="attributes.hostid" value="#session.hostid#" />
		<set name="attributes.pathoneup" value="#pathoneup#" />
		<!-- Put session into attributes -->
		<set name="attributes.artofimage" value="#session.artofimage#" />
		<set name="attributes.artofvideo" value="#session.artofvideo#" />
		<set name="attributes.artofaudio" value="#session.artofaudio#" />
		<set name="attributes.artoffile" value="#session.artoffile#" />
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- Action: Storage -->
		<do action="storage" />
		<!-- CFC: Get items and download to system -->
		<invoke object="myFusebox.getApplicationData().basket" methodcall="writebasket(attributes)" returnvariable="attributes.thefile" />
		<!-- Do the upload from server which will add the zip file from above -->
		<do action="asset_upload_server" />
	</fuseaction>
	<!-- Basket Save as COLLECTION FORM -->
	<fuseaction name="basket_saveas_collection">
		<!-- Param -->
		<set name="session.type" value="saveascollection" />
		<set name="attributes.iscol" value="T" />
		<!-- Show the choose folder -->
		<do action="choose_folder" />
	</fuseaction>
	<!-- Basket Save as COLLECTION DO -->
	<fuseaction name="saveascollection_do">
		<!-- Put session into attributes -->
		<set name="attributes.artofimage" value="#session.artofimage#" />
		<set name="attributes.artofvideo" value="#session.artofvideo#" />
		<set name="attributes.artofaudio" value="#session.artofaudio#" />
		<set name="attributes.artoffile" value="#session.artoffile#" />
		<!-- CFC: Create the collection -->
		<invoke object="myFusebox.getApplicationData().collections" methodcall="add(attributes)" returnvariable="attributes.col_id" />
		<if condition="attributes.col_id NEQ 0">
			<true>
				<!-- CFC: Read the basket -->
				<invoke object="myFusebox.getApplicationData().basket" methodcall="readbasket(attributes)" returnvariable="attributes.qry_basket" />
				<!-- CFC: Add items to collection -->
				<invoke object="myFusebox.getApplicationData().collections" methodcall="add_assets(attributes)" />
			</true>
		</if>
	</fuseaction>
	<!-- Basket Choose COLLECTION FORM -->
	<fuseaction name="basket_choose_collection">
		<!-- Param -->
		<set name="session.type" value="choosecollection" />
		<set name="attributes.iscol" value="T" />
		<set name="session.file_id" value="" />
		<set name="session.thetype" value="" />
		<!-- Show the choose folder -->
		<do action="choose_folder" />
	</fuseaction>
	<!-- Basket Choose COLLECTION DO -->
	<fuseaction name="choosecollection_do">
		<!-- Put session into attributes -->
		<set name="attributes.artofimage" value="#session.artofimage#" />
		<set name="attributes.artofvideo" value="#session.artofvideo#" />
		<set name="attributes.artofaudio" value="#session.artofaudio#" />
		<set name="attributes.artoffile" value="#session.artoffile#" />
		<!-- If we come from a list we call another method -->
		<if condition="#session.artofimage# EQ 'list'">
			<true>
				<!-- CFC: Add items to collection -->
				<invoke object="myFusebox.getApplicationData().collections" methodcall="add_assets_loop(attributes)" />
			</true>
			<false>
				<!-- CFC: Read the basket -->
				<invoke object="myFusebox.getApplicationData().basket" methodcall="readbasket(attributes)" returnvariable="attributes.qry_basket" />
				<!-- CFC: Add items to collection -->
				<invoke object="myFusebox.getApplicationData().collections" methodcall="add_assets(attributes)" />
			</false>
		</if>
		<!-- Reset sessions for single choose
		<set name="session.file_id" value="" />
		<set name="session.thetype" value="" /> -->
	</fuseaction>
	<!-- Choose Collection -->
	<fuseaction name="choose_collection">
		<!-- Param -->
		<set name="session.type" value="choosecollection" />
		<set name="attributes.iscol" value="T" />
		<if condition="structkeyexists(attributes,'file_id')">
			<true>
				<set name="session.file_id" value="#attributes.file_id#" />
			</true>
		</if>
		<!-- Put art into sessions -->
		<set name="session.artofimage" value="#attributes.artofimage#" />
		<set name="session.artofvideo" value="#attributes.artofvideo#" />
		<set name="session.artofaudio" value="#attributes.artofaudio#" />
		<set name="session.artoffile" value="#attributes.artoffile#" />
		<!-- Show the choose folder -->
		<do action="choose_folder" />
	</fuseaction>
	<fuseaction name="choose_collection_do_single">
		<!-- Put session into attributes -->
		<set name="attributes.file_id" value="#session.file_id#" />
		<set name="attributes.thetype" value="#session.thetype#" />
		<!-- CFC: Add items to collection -->
		<invoke object="myFusebox.getApplicationData().collections" methodcall="add_assets_single(attributes)" />
	</fuseaction>
	<!-- Basket Order -->
	<fuseaction name="basket_order">
		<!-- CFC: Save order info to basket -->
		<invoke object="myFusebox.getApplicationData().basket" methodcall="basket_order(attributes)" />
	</fuseaction>
	
	<!--
		END: BASKET
	 -->

	<!--
		START: COLLECTIONS
	-->
	
	<!-- Load Collections Folder -->
	<fuseaction name="collections">
		<!-- Param -->
		<set name="attributes.iscol" value="T" />
		<!-- XFA -->
		<xfa name="collectionslist" value="c.collections_list" />
		<!-- CFC: CleanID -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="cleanid(attributes.folder_id)" returnvariable="attributes.folder_id" />
		<!-- CFC: Get access to this folder -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="setaccess(attributes.folder_id)" />
		<!-- Show -->
		<do action="folder" />
	</fuseaction>
	<!-- Load Collections List -->
	<fuseaction name="collections_list">
		<!-- Param -->
		<set name="attributes.withfolder" value="T" />
		<!-- XFA -->
		<xfa name="collectiondetail" value="c.collection_detail" />
		<!-- CFC: Get languages -->
		<do action="languages" />
		<!-- CFC: Get access to this folder -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="setaccess(attributes.folder_id)" />
		<!-- CFC: Get folder info -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="getfolder(attributes.folder_id)" returnvariable="qry_folder" />
		<!-- CFC: Get Collections -->
		<invoke object="myFusebox.getApplicationData().collections" methodcall="getAll(session.thelangid,attributes)" returnvariable="qry_col_list" />
		<!-- Show -->
		<do action="ajax.collections_list" />
	</fuseaction>
	<!-- Load Collection Detail -->
	<fuseaction name="collection_detail">
		<!-- XFA -->
		<xfa name="save" value="c.collection_update" />
		<xfa name="move" value="c.collection_move" />
		<xfa name="remove" value="ajax.collections_del_item" />
		<xfa name="detaildoc" value="c.files_detail" />
		<xfa name="detailimg" value="c.images_detail" />
		<xfa name="detailvid" value="c.videos_detail" />
		<xfa name="detailaud" value="c.audios_detail" />
		<!-- Param -->
		<set name="attributes.dam" value="T" />
		<!-- CFC: Get languages -->
		<do action="languages" />
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- Action: Check storage
		<set name="attributes.isbrowser" value="#session.isbrowser#" />
		<do action="storage" />	 -->
		<!-- Get labels -->
		<do action="labels" />
		<!-- Get labels for this record -->
		<invoke object="myFusebox.getApplicationData().labels" methodcall="getlabels(attributes.col_id,'collection')" returnvariable="qry_labels" />
		<!-- CFC: Get all users -->
		<invoke object="myFusebox.getApplicationData().users" methodcall="getall(attributes)" returnvariable="qry_users" />
		<!-- CFC: Get detail of Collections -->
		<invoke object="myFusebox.getApplicationData().collections" methodcall="details(attributes)" returnvariable="qry_detail" />
		<!-- CFC: Get assets of Collections -->
		<invoke object="myFusebox.getApplicationData().collections" methodcall="get_assets(attributes)" returnvariable="qry_assets" />
		<if condition="qry_assets.recordcount NEQ 0">
			<true>
				<set name="attributes.qrybasket" value="#qry_assets#" />
				<!-- CFC: Get details for files -->
				<invoke object="myFusebox.getApplicationData().files" methodcall="detailforbasket(attributes)" returnvariable="qry_thefile" />
				<!-- CFC: Get details for images -->
				<invoke object="myFusebox.getApplicationData().images" methodcall="detailforbasket(attributes)" returnvariable="qry_theimage" />
				<!-- CFC: Get details for videos -->
				<invoke object="myFusebox.getApplicationData().videos" methodcall="detailforbasket(attributes)" returnvariable="qry_thevideo" />
				<!-- CFC: Get details for audios -->
				<invoke object="myFusebox.getApplicationData().audios" methodcall="detailforbasket(attributes)" returnvariable="qry_theaudio" />
				<!-- CFC: Get related image records -->
				<set name="attributes.related" value="T" />
				<invoke object="myFusebox.getApplicationData().images" methodcall="detailforbasket(attributes)" returnvariable="qry_theimage_related" />
				<!-- CFC: Get related video records -->
				<set name="attributes.related" value="T" />
				<invoke object="myFusebox.getApplicationData().videos" methodcall="detailforbasket(attributes)" returnvariable="qry_thevideo_related" />
				<!-- CFC: Get related audio records -->
				<set name="attributes.related" value="T" />
				<invoke object="myFusebox.getApplicationData().audios" methodcall="detailforbasket(attributes)" returnvariable="qry_theaudio_related" />
			</true>
		</if>
		<!-- CFC: Load groups -->
		<invoke object="myFusebox.getApplicationData().groups" method="getall" returnvariable="qry_groups">
			<argument name="thestruct" value="#attributes#" />
			<argument name="mod_id" value="1" />
			<argument name="host_id" value="#session.hostid#" />
		</invoke>
		<!-- CFC: Load Groups of this Collection -->
		<invoke object="myFusebox.getApplicationData().collections" methodcall="getcollectiongroups(attributes.col_id,qry_groups)" returnvariable="qry_col_groups" />
		<!-- CFC: Load Groups of this folder for group 0 -->
		<invoke object="myFusebox.getApplicationData().collections" methodcall="getcollectiongroupszero(attributes.col_id)" returnvariable="qry_col_groups_zero" />
		<!-- Show -->
		<do action="ajax.collection_detail" />
	</fuseaction>
	<!-- Move Collection Item -->
	<fuseaction name="collection_move">
		<!-- CFC: Move collection item -->
		<invoke object="myFusebox.getApplicationData().collections" methodcall="move(attributes)" />
		<!-- Show collection list -->
		<do action="collection_detail" />
	</fuseaction>
	<!-- Remove Collection Item -->
	<fuseaction name="collection_item_remove">
		<!-- CFC: Move collection item -->
		<invoke object="myFusebox.getApplicationData().collections" methodcall="removeitem(attributes)" />
		<!-- Show collection list -->
		<do action="collection_detail" />
	</fuseaction>
	<!-- Remove Collection -->
	<fuseaction name="col_remove">
		<!-- CFC: Move collection item -->
		<invoke object="myFusebox.getApplicationData().collections" methodcall="remove(attributes)" />
		<!-- Show collection list -->
		<do action="collections" />
	</fuseaction>
	<!-- Update Collection -->
	<fuseaction name="collection_update">
		<!-- CFC: Update -->
		<invoke object="myFusebox.getApplicationData().collections" methodcall="update(attributes)" />
	</fuseaction>
	<!-- Add a new (empty) Collection -->
	<fuseaction name="collection_save">
		<!-- CFC: Update -->
		<invoke object="myFusebox.getApplicationData().collections" methodcall="add(attributes)" />
	</fuseaction>
	<!-- Just get the collection of this col folder -->
	<fuseaction name="collection_chooser">
		<!-- CFC: Get Collection to choose from -->
		<invoke object="myFusebox.getApplicationData().collections" methodcall="getAll(session.thelangid,attributes)" returnvariable="qry_col_list" />
		<!-- Show collection list -->
		<do action="ajax.collection_chooser" />
	</fuseaction>
	
	<!--
		END: COLLECTIONS
	-->

	<!--
		START: FOLDER CONTENT
	 -->
	
	<!-- Load the folder Tabs -->
	<fuseaction name="folder">
		<!-- Param -->
		<set name="attributes.iscol" value="F" overwrite="false" />
		<set name="attributes.cache" value="" />
		<!-- XFA -->
		<xfa name="fproperties" value="c.folder_edit" />
		<xfa name="fsharing" value="c.folder_sharing" />
		<xfa name="fcontent" value="c.folder_content" />
		<xfa name="ffiles" value="c.folder_files" />
		<xfa name="fimages" value="c.folder_images" />
		<xfa name="fvideos" value="c.folder_videos" />
		<xfa name="faudios" value="c.folder_audios" />
		<xfa name="assetadd" value="c.asset_add" />
		<!-- CFC: Permissions of this folder -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="setaccess(attributes.folder_id)" />
		<!-- CFC: Get the total of files count and kind of files -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="fileTotalAllTypes(attributes.folder_id)" returnvariable="qry_fileTotalAllTypes" />
		<!-- Show -->
		<do action="ajax.folder" />
	</fuseaction>
	<!-- Load Folder Properties -->
	<fuseaction name="folder_edit">
		<!-- Param -->
		<set name="attributes.isdetail" value="T" />
		<set name="attributes.theid" value="0" overwrite="false" />
		<set name="attributes.level" value="0" overwrite="false" />
		<set name="attributes.rid" value="0" overwrite="false" />
		<set name="attributes.iscol" value="F" overwrite="false" />
		<!-- XFA -->
		<xfa name="submitfolderform" value="c.folder_update" />
		<xfa name="foldernew" value="c.folder_new" />
		<!-- Show -->
		<do action="folder_new" />
	</fuseaction>
	<!-- Load Folder Files -->
	<fuseaction name="folder_files">
		<!-- XFAs -->
		<xfa name="assetadd" value="c.asset_add" />
		<xfa name="assetdetail" value="c.files_detail" />
		<!-- Params -->
		<set name="attributes.showsubfolders" value="#session.showsubfolders#" overwrite="false" />
		<set name="session.showsubfolders" value="#attributes.showsubfolders#" />
		<!-- Action: Set view -->
		<do action="set_view" />
		<!-- CFC: Get folder name -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="getfoldername(attributes.folder_id)" returnvariable="qry_foldername" />
		<!-- CFC: Get subfolders -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="getsubfolders(attributes.folder_id)" returnvariable="qry_subfolders" />
		<!-- CFC: Get the total file count -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="filetotaltype(attributes)" returnvariable="qry_filecount" />
		<set name="attributes.qry_filecount" value="#qry_filecount.thetotal#" overwrite="false" />
		<!-- CFC: Get user name -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="getusername(attributes.folder_id)" returnvariable="qry_user" />
		<!-- CFC: Get files -->
		<invoke object="myFusebox.getApplicationData().files" method="getFolderAssetDetails" returnvariable="qry_files">
			<argument name="folder_id" value="#attributes.folder_id#" />
			<argument name="columnlist" value="file_id, file_extension, file_type, file_create_date, file_change_date, file_owner, file_name, file_name_org, folder_id_r, path_to_asset, is_available, cloud_url" />
			<argument name="file_extension" value="#attributes.kind#" />
			<argument name="offset" value="#session.offset#" />
			<argument name="rowmaxpage" value="#session.rowmaxpage#" />
			<argument name="thestruct" value="#attributes#" />
		</invoke>
		<!-- Show -->
		<do action="ajax.folder_files" />
	</fuseaction>
	<!-- Load Folder Images -->
	<fuseaction name="folder_images">
		<!-- XFA -->
		<xfa name="fimages" value="c.folder_images" />
		<xfa name="assetadd" value="c.asset_add" />
		<xfa name="assetdetail" value="c.images_detail" />
		<!-- Params -->
		<set name="attributes.showsubfolders" value="#session.showsubfolders#" overwrite="false" />
		<set name="session.showsubfolders" value="#attributes.showsubfolders#" />
		<set name="attributes.cache" value="" />
		<!-- Action: Set view -->
		<do action="set_view" />
		<!-- CFC: Get folder name -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="getfoldername(attributes.folder_id)" returnvariable="qry_foldername" />
		<!-- CFC: Get subfolders -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="getsubfolders(attributes.folder_id)" returnvariable="qry_subfolders" />
		<!-- CFC: Get the total file count -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="filetotaltype(attributes)" returnvariable="qry_filecount" />
		<set name="attributes.qry_filecount" value="#qry_filecount.thetotal#" overwrite="false" />
		<!-- CFC: Get user name -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="getusername(attributes.folder_id)" returnvariable="qry_user" />
		<!-- CFC: Get images -->
		<invoke object="myFusebox.getApplicationData().images" method="getFolderAssetDetails" returnvariable="qry_files">
			<argument name="folder_id" value="#attributes.folder_id#" />
			<argument name="columnlist" value="i.img_id, i.img_filename, i.img_custom_id, i.img_create_date, i.img_change_date, i.folder_id_r, i.thumb_extension, i.link_kind, i.link_path_url, i.path_to_asset, i.is_available, i.cloud_url" />
			<argument name="offset" value="#session.offset#" />
			<argument name="rowmaxpage" value="#session.rowmaxpage#" />
			<argument name="thestruct" value="#attributes#" />
		</invoke>
		<!-- Show -->
		<do action="ajax.folder_images" />
	</fuseaction>
	<!-- Load Folder Videos -->
	<fuseaction name="folder_videos">
		<!-- XFA -->
		<xfa name="fvideos" value="c.folder_videos" />
		<xfa name="fvideosloader" value="c.folder_videos_show" />
		<xfa name="assetadd" value="c.asset_add" />
		<xfa name="assetdetail" value="c.videos_detail" />
		<!-- Params -->
		<set name="attributes.showsubfolders" value="#session.showsubfolders#" overwrite="false" />
		<set name="session.showsubfolders" value="#attributes.showsubfolders#" />
		<!-- Action: Set view -->
		<do action="set_view" />
		<!-- CFC: Get folder name -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="getfoldername(attributes.folder_id)" returnvariable="qry_foldername" />
		<!-- CFC: Get subfolders -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="getsubfolders(attributes.folder_id)" returnvariable="qry_subfolders" />
		<!-- CFC: Get the total file count -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="filetotaltype(attributes)" returnvariable="qry_filecount" />
		<set name="attributes.qry_filecount" value="#qry_filecount.thetotal#" overwrite="false" />
		<!-- CFC: Get user name -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="getusername(attributes.folder_id)" returnvariable="qry_user" />
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- CFC: Get Videos -->
		<invoke object="myFusebox.getApplicationData().videos" method="getFolderAssetDetails" returnvariable="qry_files">
			<argument name="folder_id" value="#attributes.folder_id#" />
			<argument name="columnlist" value="v.vid_id, v.vid_filename, v.folder_id_r, v.vid_custom_id, v.vid_create_date, v.vid_change_date, v.vid_name_image, v.vid_extension, v.link_kind, v.path_to_asset, v.is_available, v.cloud_url" />
			<argument name="offset" value="#session.offset#" />
			<argument name="rowmaxpage" value="#session.rowmaxpage#" />
			<argument name="thestruct" value="#attributes#" />
		</invoke>
		<!-- Show -->
		<do action="ajax.folder_videos" />
	</fuseaction>
	<!-- Load Folder Videos -->
	<fuseaction name="folder_videos_show">
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<set name="attributes.dynpath" value="#dynpath#" />
		<!-- CFC: Get Details -->
		<invoke object="myFusebox.getApplicationData().videos" method="getdetails" returnvariable="attributes.videodetails">
			<argument name="vid_id" value="#attributes.vid_id#" />
			<argument name="columnlist" value="v.vid_extension, v.vid_width vwidth, v.vid_height vheight, v.vid_preview_width, v.vid_preview_heigth, v.vid_name_org, v.vid_name_image, v.vid_name_pre, v.vid_name_pre_img, v.folder_id_r, v.vid_filename, v.path_to_asset, v.cloud_url, v.cloud_url_org" />
		</invoke>
		<!-- Action: Check storage
		<set name="attributes.isbrowser" value="#session.isbrowser#" />
		<do action="storage" /> -->
		<!-- CFC: Get video output -->
		<invoke object="myFusebox.getApplicationData().videos" methodcall="showvideo(attributes)" returnvariable="thevideo" />
		<!-- Show -->
		<do action="ajax.folder_videos_show" />
	</fuseaction>
	<!-- Load Folder Audios -->
	<fuseaction name="folder_audios">
		<!-- XFAs -->
		<xfa name="assetadd" value="c.asset_add" />
		<xfa name="assetdetail" value="c.audios_detail" />
		<!-- Params -->
		<set name="attributes.showsubfolders" value="#session.showsubfolders#" overwrite="false" />
		<set name="session.showsubfolders" value="#attributes.showsubfolders#" />
		<!-- Action: Set view -->
		<do action="set_view" />
		<!-- CFC: Get folder name -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="getfoldername(attributes.folder_id)" returnvariable="qry_foldername" />
		<!-- CFC: Get subfolders -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="getsubfolders(attributes.folder_id)" returnvariable="qry_subfolders" />
		<!-- CFC: Get the total file count -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="filetotaltype(attributes)" returnvariable="qry_filecount" />
		<set name="attributes.qry_filecount" value="#qry_filecount.thetotal#" overwrite="false" />
		<!-- CFC: Get user name -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="getusername(attributes.folder_id)" returnvariable="qry_user" />
		<!-- CFC: Get files -->
		<invoke object="myFusebox.getApplicationData().audios" method="getFolderAssets" returnvariable="qry_files">
			<argument name="folder_id" value="#attributes.folder_id#" />
			<argument name="offset" value="#session.offset#" />
			<argument name="rowmaxpage" value="#session.rowmaxpage#" />
			<argument name="thestruct" value="#attributes#" />
		</invoke>
		<!-- Show -->
		<do action="ajax.folder_audios" />
	</fuseaction>
	<!-- Load Folder Content INCLUDE -->
	<fuseaction name="folder_content_include">
		<!-- XFA -->
		<xfa name="ffiles" value="c.folder_files" />
		<xfa name="fimages" value="c.folder_images" />
		<xfa name="fvideos" value="c.folder_videos" />
		<xfa name="faudios" value="c.folder_audios" />
		<xfa name="assetadd" value="c.asset_add" />
		<xfa name="detaildoc" value="c.files_detail" />
		<xfa name="detailimg" value="c.images_detail" />
		<xfa name="detailvid" value="c.videos_detail" />
		<xfa name="detailaud" value="c.audios_detail" />
		<!-- Param -->
		<set name="kind" value="all" />
		<set name="url.kind" value="all" />
		<set name="attributes.showsubfolders" value="#session.showsubfolders#" overwrite="false" />
		<set name="session.showsubfolders" value="#attributes.showsubfolders#" />
		<set name="attributes.cache" value="" />
		<set name="attributes.json" value="f" overwrite="false" />
		<!-- Action: Set view -->
		<do action="set_view" />
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- CFC: Set Access -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="setaccess(attributes.folder_id)" returnvariable="qry_foldername" />
		<!-- CFC: Get the total file count -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="filetotalcount(attributes.folder_id)" returnvariable="qry_filecount" />
		<set name="attributes.qry_filecount" value="#qry_filecount.thetotal#" overwrite="false" />
		<!-- CFC: Get subfolders -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="getsubfolders(attributes.folder_id)" returnvariable="qry_subfolders" />
		<!-- CFC: Get all assets -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="getallassets(attributes)" returnvariable="qry_files" />
		<!-- CFC: Get user name -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="getusername(attributes.folder_id)" returnvariable="qry_user" />
	</fuseaction>
	<!-- Load Folder Content -->
	<fuseaction name="folder_content">
		<!-- Get Include -->
		<do action="folder_content_include" />
		<!-- Show -->
		<do action="ajax.folder_content" />
	</fuseaction>
	<!-- Load Folder Content LIST -->
	<fuseaction name="folder_content_list">
		<set name="attributes.json" value="t" />
		<!-- Get Include -->
		<do action="folder_content_include" />
		<!-- Show -->
		<do action="ajax.datatables_json" />
	</fuseaction>
	<!-- Load folder sharing -->
	<fuseaction name="folder_sharing">
		<!-- Params -->
		<xfa name="submitfolderform" value="c.folder_sharing_save" overwrite="false" />
		<set name="attributes.iscol" value="F" overwrite="false" />
		<!-- CFC: Load record -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="getfolder(attributes.folder_id)" returnvariable="qry_folder" />
		<!-- CFC: Get all users -->
		<invoke object="myFusebox.getApplicationData().users" methodcall="getall(attributes)" returnvariable="qry_users" />
		<!-- Show -->
		<do action="ajax.folder_sharing" />
	</fuseaction>
	<!-- Load Folder window -->
	<fuseaction name="folder_new">
		<xfa name="submitfolderform" value="c.folder_add" overwrite="false" />
		<set name="attributes.folder_id" value="0" overwrite="false" />
		<set name="attributes.theid" value="0" overwrite="false" />
		<set name="attributes.level" value="0" overwrite="false" />
		<set name="attributes.rid" value="0" overwrite="false" />
		<set name="attributes.isdetail" value="F" overwrite="false" />
		<set name="attributes.iscol" value="F" overwrite="false" />
		<set name="attributes.from" value="" overwrite="false" />
		<set name="attributes.dam" value="" />
		<!-- CFC: Load record -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="getfolder(attributes.folder_id)" returnvariable="qry_folder" />
		<!-- If rid or level are 0 -->
		<if condition="#attributes.from# EQ 'list'">
			<true>
				<invoke object="myFusebox.getApplicationData().folders" methodcall="getfolder(attributes.theid)" returnvariable="qry" />
				<set name="attributes.level" value="#qry.folder_level#" />
				<set name="attributes.rid" value="#qry.rid#" />
			</true>
		</if>
		<!-- CFC: Load descriptions -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="getfolderdesc(attributes.folder_id)" returnvariable="qry_folder_desc" />
		<!-- CFC: Load groups -->
		<invoke object="myFusebox.getApplicationData().groups" method="getall" returnvariable="qry_groups">
			<argument name="thestruct" value="#attributes#" />
			<argument name="mod_id" value="1" />
			<argument name="host_id" value="#session.hostid#" />
		</invoke>
		<!-- CFC: Load Groups of this folder -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="getfoldergroups(attributes.folder_id,qry_groups)" returnvariable="qry_folder_groups" />
		<!-- CFC: Load Groups of this folder for group 0 -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="getfoldergroupszero(attributes.folder_id)" returnvariable="qry_folder_groups_zero" />
		<!-- Get labels -->
		<do action="labels" />
		<!-- Get labels for this record -->
		<invoke object="myFusebox.getApplicationData().labels" methodcall="getlabels(attributes.folder_id,'folder')" returnvariable="qry_labels" />
		<!-- CFC: Get languages -->
		<do action="languages" />
		<!-- Show -->
		<do action="ajax.folder_new" />
	</fuseaction>
	<!-- Save sharing options -->
	<fuseaction name="folder_sharing_save">
		<set name="attributes.userid" value="#session.theuserid#" />
		<set name="attributes.coll_folder" value="F" overwrite="false" />
		<!-- CFC: save sharing options -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="update_sharing(attributes)" />
	</fuseaction>
	<!-- Add Folder -->
	<fuseaction name="folder_add">
		<set name="attributes.userid" value="#session.theuserid#" />
		<set name="attributes.coll_folder" value="F" overwrite="false" />
		<set name="attributes.thepath" value="#thispath#" />
		<set name="attributes.rootpath" value="#ExpandPath('../..')#" />
		<!-- CFC: Get asset path -->
		<do action="assetpath" />
		<!-- CFC: Add new folder -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="add(attributes)" />
	</fuseaction>
	<!-- Remove Folder -->
	<fuseaction name="folder_remove">
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- Action: Storage -->
		<do action="storage" />
		<!-- CFC: Remove folder -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="remove(attributes)" returnvariable="attributes.folder_id" />
		<!-- Show -->
		<if condition="#attributes.iscol# EQ 'f'">
			<true>
				<do action="explorer" />
			</true>
			<false>
				<do action="explorer_col" />
			</false>
		</if>
	</fuseaction>
	<!-- Update Folder -->
	<fuseaction name="folder_update">
		<set name="attributes.userid" value="#session.theuserid#" />
		<set name="attributes.folder_id" value="#attributes.theid#" />
		<!-- CFC: Update folder -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="update(attributes)" />
		<!-- Show -->
		<do action="folder_edit" />
	</fuseaction>
	<!-- Save Folder Combined -->
	<fuseaction name="folder_combined_save">
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- CFC: Update folder -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="combined_save(attributes)" />
	</fuseaction>
	<!-- LINK: folder Check -->
	<fuseaction name="folder_link_check">
		<!-- CFC: Check to be able to read folder -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="link_check(attributes)" returnvariable="attributes.checkstatus" />
		<!-- Show -->
		<do action="ajax.folder_check" />
	</fuseaction>
	<!--
		END: FOLDER CONTENT
	 -->
	 
	<!--
		START: COOLIRIS
	-->
	
	<!-- Show for a folder -->
	<fuseaction name="cooliris_folder">
		<!-- Action: Check storage -->
		<set name="attributes.isbrowser" value="#session.isbrowser#" />
		<do action="storage" />
		<!-- CFC: Do the Cooliris RSS -->
		<invoke object="myFusebox.getApplicationData().cooliris" methodcall="folder_rss(attributes)" returnvariable="folderfeed" />
	</fuseaction>
	
	<!--
		END: COOLIRIS
	-->
	
	<!--
		START: WORKING WITH ASSETS
	 -->
	
	<!-- ADD -->
	<fuseaction name="asset_add">
		<!-- XFA -->
		<xfa name="addsingle" value="c.asset_add_single" />
		<xfa name="addserver" value="c.asset_add_server" />
		<xfa name="addemail" value="c.asset_add_email" />
		<xfa name="addftp" value="c.asset_add_ftp" />
		<xfa name="addlink" value="c.asset_add_link" />
		<!-- Param
		<set name="attributes.tempid" value="#createuuid()#" />	 -->
		<!-- Show -->
		<do action="ajax.asset_add" />
	</fuseaction>
	<!-- Add Single Form -->
	<fuseaction name="asset_add_single">
		<!-- Params -->
		<set name="attributes.nopreview" value="0" overwrite="false" />
		<set name="attributes.av" value="0" overwrite="false" />
		<!-- XFA -->
		<xfa name="submitassetsingle" value="c.asset_upload_do" />
		<!-- CFC: Get languages -->
		<do action="languages" />
		<!-- Get settings -->
		<do action="asset_get_settings" />
		<!-- Show -->
		<do action="ajax.asset_add_single" />
	</fuseaction>
	<!-- Add Server Form -->
	<fuseaction name="asset_add_server">
		<xfa name="serverfolders" value="c.asset_add_server_folders" />
		<!-- Show -->
		<do action="ajax.asset_add_server" />
	</fuseaction>
	<!-- Add Server FOLDERLIST -->
	<fuseaction name="asset_add_server_folders">
		<xfa name="serverfolders" value="c.asset_add_server_folders" />
		<xfa name="servercontent" value="c.asset_add_server_content" />
		<!-- CFC: Get folder -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="getserverdir(#attributes.folderpath#)" returnvariable="qry_filefolders" />
		<!-- Show -->
		<do action="ajax.asset_add_server_folders" />
	</fuseaction>
	<!-- Add Server FOLDER CONTENT -->
	<fuseaction name="asset_add_server_content">
		<xfa name="serverfolders" value="c.asset_add_server_folders" />
		<xfa name="submitassetserver" value="c.asset_upload_server" />
		<!-- Get settings -->
		<do action="asset_get_settings" />
		<!-- CFC: get upload templates -->
		<invoke object="myFusebox.getApplicationData().global" methodcall="upl_templates(true)" returnvariable="qry_templates" />
		<!-- Show -->
		<do action="ajax.asset_add_server_content" />
	</fuseaction>
	<!-- Add from server -->
	<fuseaction name="asset_upload_server">
		<!-- Param -->
		<set name="attributes.rootpath" value="#ExpandPath('../..')#" />
		<set name="attributes.langcount" value="1" />
		<set name="attributes.dynpath" value="#dynpath#" />
		<set name="attributes.httphost" value="#cgi.http_host#" />
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- Action: Check storage -->
		<do action="storage" />
		<!-- CFC: Upload -->
		<invoke object="myFusebox.getApplicationData().assets" methodcall="addassetserver(attributes)" />		
	</fuseaction>
	<!-- Add eMail Form -->
	<fuseaction name="asset_add_email">
		<!-- Show -->
		<do action="ajax.asset_add_email" />
	</fuseaction>
	<!-- Add eMail Show -->
	<fuseaction name="asset_add_email_show">
		<xfa name="submitassetemail" value="c.asset_upload_email" />
		<!-- Store values in session since we need them later on some more -->
		<set name="session.email_server" value="#attributes.email_server#" />
		<set name="session.email_address" value="#attributes.email_address#" />
		<set name="session.email_pass" value="#attributes.email_pass#" />
		<set name="session.email_subject" value="#attributes.email_subject#" />
		<!-- Get settings -->
		<do action="asset_get_settings" />
		<!-- CFC: Get email messages -->
		<invoke object="myFusebox.getApplicationData().email" methodcall="emailheaders(attributes)" returnvariable="qry_emails" />
		<!-- Show -->
		<do action="ajax.asset_add_email_show" />
	</fuseaction>
	<!-- Add eMail Show Message -->
	<fuseaction name="asset_add_email_show_mail">
		<!-- CFC: Get email messages -->
		<invoke object="myFusebox.getApplicationData().email" methodcall="emailmessage(attributes.mailid,attributes.pathhere)" returnvariable="qry_emailmessage" />
		<!-- Show -->
		<do action="ajax.asset_add_email_show_mail" />
	</fuseaction>
	<!-- Add eMail Delete -->
	<fuseaction name="asset_add_email_delete">
		<!-- CFC: Remove message -->
		<invoke object="myFusebox.getApplicationData().email" methodcall="removemessage(attributes.mailid)" />
		<!-- Show -->
		<set name="attributes.email_server" value="#session.email_server#" />
		<set name="attributes.email_address" value="#session.email_address#" />
		<set name="attributes.email_pass" value="#session.email_pass#" />
		<set name="attributes.email_subject" value="#session.email_subject#" />
		<do action="asset_add_email_show" />
	</fuseaction>
	<!-- Add from email -->
	<fuseaction name="asset_upload_email">
		<!-- Param -->
		<set name="attributes.rootpath" value="#ExpandPath('../..')#" />
		<set name="attributes.langcount" value="1" />
		<set name="attributes.dynpath" value="#dynpath#" />
		<set name="attributes.httphost" value="#cgi.http_host#" />
		<!-- Action: Check storage -->
		<do action="storage" />
		<!-- CFC: Upload -->
		<invoke object="myFusebox.getApplicationData().assets" methodcall="addassetemail(attributes)" />		
	</fuseaction>
	<!-- Add FTP Form -->
	<fuseaction name="asset_add_ftp">
		<!-- Show -->
		<do action="ajax.asset_add_ftp" />
	</fuseaction>
	<!-- Add FTP Show -->
	<fuseaction name="asset_add_ftp_show">
		<xfa name="submitassetftp" value="c.asset_upload_ftp" overwrite="false" />
		<xfa name="reloadftp" value="c.asset_add_ftp_reload" />
		<!-- Store values in session since we need them later on some more -->
		<set name="session.ftp_server" value="#attributes.ftp_server#" />
		<set name="session.ftp_user" value="#attributes.ftp_user#" />
		<set name="session.ftp_pass" value="#attributes.ftp_pass#" />
		<set name="session.ftp_passive" value="#attributes.ftp_passive#" />
		<!-- Get settings -->
		<do action="asset_get_settings" />
		<!-- CFC: Get FTP directory -->
		<invoke object="myFusebox.getApplicationData().ftp" methodcall="getdirectory(attributes)" returnvariable="qry_ftp" />
		<!-- Show -->
		<do action="ajax.asset_add_ftp_show" />
	</fuseaction>
	<!-- Add FTP Show Reload -->
	<fuseaction name="asset_add_ftp_reload">
		<xfa name="submitassetftp" value="c.asset_upload_ftp" />
		<xfa name="reloadftp" value="c.asset_add_ftp_reload" />
		<!-- Get settings -->
		<do action="asset_get_settings" />
		<!-- CFC: Get ftp directory -->
		<invoke object="myFusebox.getApplicationData().ftp" methodcall="getdirectory(attributes)" returnvariable="qry_ftp" />
		<!-- Show -->
		<do action="ajax.asset_add_ftp_show" />
	</fuseaction>
	<!-- Add from ftp -->
	<fuseaction name="asset_upload_ftp">
		<!-- Param -->
		<set name="attributes.rootpath" value="#ExpandPath('../..')#" />
		<set name="attributes.langcount" value="1" />
		<set name="attributes.dynpath" value="#dynpath#" />
		<set name="attributes.httphost" value="#cgi.http_host#" />
		<!-- CFC: Get asset path -->
		<do action="assetpath" />
		<!-- Action: Check storage -->
		<do action="storage" />
		<!-- CFC: Upload -->
		<invoke object="myFusebox.getApplicationData().assets" methodcall="addassetftpthread(attributes)" />		
	</fuseaction>
	
	<!-- Get Add settings -->
	<fuseaction name="asset_get_settings">
		<!-- CFC: Get image settings -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="prefs_image()" returnvariable="settings_image" />
		<!-- CFC: Get video settings -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="prefs_video()" returnvariable="settings_video" />
	</fuseaction>
	
	<!-- Add Upload iFrame -->
	<fuseaction name="asset_add_upload">
		<!-- Set runtime session -->
		<if condition="cgi.http_user_agent CONTAINS 'windows' OR cgi.http_user_agent CONTAINS 'safari'">
			<true>
				<set name="session.pluploadruntimes" value="flash,html5,silverlight" overwrite="false" />
			</true>
			<false>
				<set name="session.pluploadruntimes" value="html5,flash,silverlight" overwrite="false" />
			</false>
		</if>
		<!-- Set params for function call in API -->
		<set name="attributes.theuserid" value="#session.theuserid#" />
		<set name="attributes.hostid" value="#session.hostid#" />
		<set name="attributes.hostdbprefix" value="#session.hostdbprefix#" />
		<!-- CFC: Create sessiontoken -->
		<invoke object="myFusebox.getApplicationData().login" methodcall="razunauploadsession(attributes)" returnvariable="attributes.sessiontoken" />
		<!-- CFC: get upload templates -->
		<invoke object="myFusebox.getApplicationData().global" methodcall="upl_templates(true)" returnvariable="qry_templates" />
		<!-- Show -->
		<do action="ajax.asset_add_upload" />
	</fuseaction>
	<!-- Upload JUST THE FILE -->
	<fuseaction name="asset_upload">
		<set name="attributes.user_id" value="#session.theuserid#" />	
		<set name="attributes.nopreview" value="0" overwrite="false" />
		<set name="attributes.av" value="0" overwrite="false" />
		<!-- CFC: Upload -->
		<invoke object="myFusebox.getApplicationData().assets" methodcall="upload(attributes)" returnvariable="result" />
		<!-- Show -->
		<do action="asset_add_upload" />
	</fuseaction>
	<!-- Upload -->
	<fuseaction name="asset_upload_do">
		<!-- Param -->
		<set name="attributes.rootpath" value="#ExpandPath('../..')#" />
		<set name="attributes.dynpath" value="#dynpath#" />
		<set name="attributes.httphost" value="#cgi.http_host#" />
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- Action: Check storage -->
		<do action="storage" />
		<!-- CFC: Upload -->
		<invoke object="myFusebox.getApplicationData().assets" methodcall="addasset(attributes)" />		
	</fuseaction>
	<!-- Upload from API -->
	<fuseaction name="apiupload">
		<!-- Param -->
		<set name="attributes.thepath" value="#thispath#" />
		<set name="attributes.rootpath" value="#ExpandPath('../..')#" />
		<set name="attributes.langcount" value="1" />
		<set name="attributes.file_desc_1" value="" />
		<set name="attributes.file_keywords_1" value="" />
		<set name="attributes.av" value="0" overwrite="false" />
		<set name="attributes.dynpath" value="#dynpath#" />
		<set name="attributes.httphost" value="#cgi.http_host#" />
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- Action: Check storage -->
		<do action="storage" />
		<!-- CFC: Upload -->
		<if condition="attributes.av EQ 0">
			<true>
				<invoke object="myFusebox.getApplicationData().assets" methodcall="addassetapi(attributes)" returnvariable="result" />
			</true>
			<false>
				<invoke object="myFusebox.getApplicationData().assets" methodcall="addassetav(attributes)" returnvariable="result" />
			</false>
		</if>
		<!-- Show -->
		<do action="ajax.api_feedback" />
	</fuseaction>
	
	<!-- Add LINK -->
	<fuseaction name="asset_add_link">
		<!-- XFA -->
		<xfa name="addlink" value="c.asset_add_link_do" />
		<!-- Show -->
		<do action="ajax.asset_add_link" />
	</fuseaction>
	<!-- Add LINK DO -->
	<fuseaction name="asset_add_link_do">
		<!-- Param -->
		<set name="attributes.thepath" value="#thispath#" />
		<set name="attributes.rootpath" value="#ExpandPath('../..')#" />
		<set name="attributes.langcount" value="1" />
		<set name="attributes.file_desc_1" value="" />
		<set name="attributes.file_keywords_1" value="" />
		<set name="attributes.dynpath" value="#dynpath#" />
		<set name="attributes.httphost" value="#cgi.http_host#" />
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- Action: Check storage -->
		<do action="storage" />
		<!-- CFC: Add link -->
		<invoke object="myFusebox.getApplicationData().assets" methodcall="addassetlink(attributes)" returnvariable="result" />
	</fuseaction>
	
	<!-- Add asset from path -->
	<fuseaction name="asset_add_path">
		<!-- Param -->
		<set name="attributes.rootpath" value="#ExpandPath('../..')#" />
		<set name="attributes.thepath" value="#thispath#" />
		<set name="attributes.dynpath" value="#dynpath#" />
		<set name="attributes.httphost" value="#cgi.http_host#" />
		<!-- Query folder -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="getfolder(attributes.theid)" returnvariable="qry" />
		<set name="attributes.level" value="#qry.folder_level#" />
		<set name="attributes.rid" value="#qry.rid#" />
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- Action: Check storage -->
		<do action="storage" />
		<!-- CFC: Add path -->
		<invoke object="myFusebox.getApplicationData().assets" methodcall="addassetpath(attributes)" />
	</fuseaction>
	
	<!-- Load history asset log -->
	<fuseaction name="log_history">
		<!-- Set offset for logs -->
		<do action="set_offset_admin" />
		<!-- Params -->
		<set name="attributes.logswhat" value="log_assets" />
		<!-- CFC -->
		<invoke object="myFusebox.getApplicationData().log" methodcall="get_log_assets(attributes)" returnvariable="qry_log" />
		<!-- Show -->
		<do action="ajax.log_history" />
	</fuseaction>
	<!-- Search log history -->
	<fuseaction name="log_history_search">
		<!-- CFC: Search log -->
		<invoke object="myFusebox.getApplicationData().log" methodcall="log_search(attributes)" returnvariable="qry_log" />
		<!-- Show -->
		<do action="ajax.log_history" />
	</fuseaction>
	<!-- Remove Log file -->
	<fuseaction name="log_history_remove">
		<!-- CFC: Remove log -->
		<invoke object="myFusebox.getApplicationData().log" methodcall="remove_log_assets(attributes.id)" />
		<!-- Show -->
		<do action="log_history" />
	</fuseaction>
	
	<!--
		END: WORKING WITH ASSETS
	 -->
	
	<!--
		START: FILE SPECIFIC SECTIONS
	 -->
	 
	<!-- Remove files -->
	<fuseaction name="files_remove">
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- Action: Storage -->
		<do action="storage" />
		<!-- CFC: Upload -->
		<invoke object="myFusebox.getApplicationData().files" methodcall="removefile(attributes)" />
		<!-- Show the folder listing -->
		<if condition="attributes.loaddiv EQ 'content'">
			<true>
				<do action="folder_content" />
			</true>
			<false>
				<do action="folder_files" />
			</false>
		</if>
	</fuseaction>
	<!-- Remove images -->
	<fuseaction name="images_remove">
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- Action: Storage -->
		<do action="storage" />
		<!-- CFC: Upload -->
		<invoke object="myFusebox.getApplicationData().images" methodcall="removeimage(attributes)" />
		<!-- Show the folder listing -->
		<if condition="attributes.loaddiv EQ 'content'">
			<true>
				<do action="folder_content" />
			</true>
			<false>
				<do action="folder_images" />
			</false>
		</if>
	</fuseaction>
	<!-- Remove videos -->
	<fuseaction name="images_remove_related">
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- Action: Storage -->
		<do action="storage" />
		<!-- CFC: Upload -->
		<invoke object="myFusebox.getApplicationData().images" methodcall="removeimage(attributes)" />
		<!-- Show the folder listing -->
		<do action="images_detail_related" />
	</fuseaction>
	<!-- Remove videos -->
	<fuseaction name="videos_remove">
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- Action: Storage -->
		<do action="storage" />
		<!-- CFC: Upload -->
		<invoke object="myFusebox.getApplicationData().videos" methodcall="removevideo(attributes)" />
		<!-- Show the folder listing -->
		<if condition="attributes.loaddiv EQ 'content'">
			<true>
				<do action="folder_content" />
			</true>
			<false>
				<do action="folder_videos" />
			</false>
		</if>
	</fuseaction>
	<!-- Remove related videos -->
	<fuseaction name="videos_remove_related">
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- Action: Storage -->
		<do action="storage" />
		<!-- CFC: Upload -->
		<invoke object="myFusebox.getApplicationData().videos" methodcall="removevideo(attributes)" />
		<!-- Show the folder listing -->
		<do action="videos_detail_related" />
	</fuseaction>
	<!-- Remove Audios -->
	<fuseaction name="audios_remove">
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- Action: Storage -->
		<do action="storage" />
		<!-- CFC: Upload -->
		<invoke object="myFusebox.getApplicationData().audios" methodcall="removeaudio(attributes)" />
		<!-- Show the folder listing -->
		<if condition="attributes.loaddiv EQ 'content'">
			<true>
				<do action="folder_content" />
			</true>
			<false>
				<do action="folder_audios" />
			</false>
		</if>
	</fuseaction>
	<!-- Remove related audios -->
	<fuseaction name="audios_remove_related">
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- Action: Storage -->
		<do action="storage" />
		<!-- CFC: Upload -->
		<invoke object="myFusebox.getApplicationData().audios" methodcall="removeaudio(attributes)" />
		<!-- Show the folder listing -->
		<do action="audios_detail_related" />
	</fuseaction>
	
	<!-- Remove files MANY -->
	<fuseaction name="doc_remove_many">
		<!-- Param -->
    	<set name="attributes.theuserid" value="#session.theuserid#" />
    	<set name="attributes.hostdbprefix" value="#session.hostdbprefix#" />
    	<set name="attributes.hostid" value="#session.hostid#" />
    	<!-- If we dont come fromall then assign session to id -->
    	<if condition="#attributes.kind# NEQ 'all'">
    		<true>
    			<set name="attributes.id" value="#session.file_id#" />
    		</true>
    	</if> 
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- Action: Storage -->
		<do action="storage" />
		<!-- CFC: Remove -->
		<invoke object="myFusebox.getApplicationData().files" methodcall="removefilemany(attributes)" />
		<!-- Show the folder listing -->
		<if condition="attributes.loaddiv NEQ 'content'">
			<true>
				<do action="folder_files" />
			</true>
		</if>
	</fuseaction>
	<!-- Remove images MANY -->
	<fuseaction name="img_remove_many">
    	<!-- Param -->
    	<set name="attributes.theuserid" value="#session.theuserid#" />
    	<set name="attributes.hostdbprefix" value="#session.hostdbprefix#" />
    	<set name="attributes.hostid" value="#session.hostid#" />
    	<!-- If we dont come fromall then assign session to id -->
    	<if condition="#attributes.kind# NEQ 'all'">
    		<true>
    			<set name="attributes.id" value="#session.file_id#" />
    		</true>
    	</if> 
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- Action: Storage -->
		<do action="storage" />
		<!-- CFC: Remove -->
		<invoke object="myFusebox.getApplicationData().images" methodcall="removeimagemany(attributes)" />
		<!-- Show the folder listing -->
		<if condition="attributes.loaddiv NEQ 'content'">
			<true>
				<do action="folder_images" />
			</true>
		</if>
	</fuseaction>
	<!-- Remove videos -->
	<fuseaction name="vid_remove_many">
		<!-- Param -->
    	<set name="attributes.theuserid" value="#session.theuserid#" />
    	<set name="attributes.hostdbprefix" value="#session.hostdbprefix#" />
    	<set name="attributes.hostid" value="#session.hostid#" />
    	<!-- If we dont come fromall then assign session to id -->
    	<if condition="#attributes.kind# NEQ 'all'">
    		<true>
    			<set name="attributes.id" value="#session.file_id#" />
    		</true>
    	</if> 
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- Action: Storage -->
		<do action="storage" />
		<!-- CFC: Remove -->
		<invoke object="myFusebox.getApplicationData().videos" methodcall="removevideomany(attributes)" />
		<!-- Show the folder listing -->
		<if condition="attributes.loaddiv NEQ 'content'">
			<true>
				<do action="folder_videos" />
			</true>
		</if>
	</fuseaction>
	<!-- Remove audios -->
	<fuseaction name="aud_remove_many">
		<!-- Param -->
    	<set name="attributes.theuserid" value="#session.theuserid#" />
    	<set name="attributes.hostdbprefix" value="#session.hostdbprefix#" />
    	<set name="attributes.hostid" value="#session.hostid#" />
    	<!-- If we dont come fromall then assign session to id -->
    	<if condition="#attributes.kind# NEQ 'all'">
    		<true>
    			<set name="attributes.id" value="#session.file_id#" />
    		</true>
    	</if> 
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- Action: Storage -->
		<do action="storage" />
		<!-- CFC: Remove -->
		<invoke object="myFusebox.getApplicationData().audios" methodcall="removeaudiomany(attributes)" />
		<!-- Show the folder listing -->
		<if condition="attributes.loaddiv NEQ 'content'">
			<true>
				<do action="folder_audios" />
			</true>
		</if>
	</fuseaction>
	<!-- Remove ALL -->
	<fuseaction name="all_remove_many">
		<!-- Param -->
    	<set name="attributes.theuserid" value="#session.theuserid#" />
    	<set name="attributes.hostdbprefix" value="#session.hostdbprefix#" />
    	<set name="attributes.hostid" value="#session.hostid#" />
    	<set name="attributes.id" value="#session.file_id#" />
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- Action: Storage -->
		<do action="storage" />
		<!-- CFC: Set the correct ids -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="removeall(attributes)" returnvariable="theids" />
		<!-- For Docs -->
		<if condition="#theids.docids# NEQ ''">
			<true>
				<set name="attributes.id" value="#theids.docids#" />
				<do action="doc_remove_many" />
			</true>
		</if>
		<!-- For Images -->
		<if condition="#theids.imgids# NEQ ''">
			<true>
				<set name="attributes.id" value="#theids.imgids#" />
				<do action="img_remove_many" />
			</true>
		</if>
		<!-- For Videos -->
		<if condition="#theids.vidids# NEQ ''">
			<true>
				<set name="attributes.id" value="#theids.vidids#" />
				<do action="vid_remove_many" />
			</true>
		</if>
		<!-- For Audios -->
		<if condition="#theids.audids# NEQ ''">
			<true>
				<set name="attributes.id" value="#theids.audids#" />
				<do action="aud_remove_many" />
			</true>
		</if>
		<!-- Show the folder listing -->
		<do action="folder_content" />
	</fuseaction>
	
	<!--
		START: DETAIL SECTION
	 -->
	
	<!-- Load Detail -->
	<fuseaction name="files_detail">
		<!-- XFA -->
		<xfa name="save" value="c.files_detail_save" />
		<xfa name="tobasket" value="c.basket_put" />
		<xfa name="tofavorites" value="c.favorites_put" />
		<xfa name="sendemail" value="c.email_send" />
		<xfa name="sendftp" value="c.ftp_send" />
		<!-- Param -->
		<set name="attributes.kind" value="files" />
		<set name="attributes.cf_show" value="doc" />
		<!-- CFC: Get languages -->
		<do action="languages" />
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- Action: Storage -->
		<set name="attributes.isbrowser" value="#session.isbrowser#" />
		<do action="storage" />
		<!-- Get labels -->
		<do action="labels" />
		<!-- Get labels for this record -->
		<invoke object="myFusebox.getApplicationData().labels" methodcall="getlabels(attributes.file_id,'doc')" returnvariable="qry_labels" />
		<!-- CFC: Get file detail -->
		<invoke object="myFusebox.getApplicationData().files" methodcall="detail(attributes)" returnvariable="qry_detail" />
		<!-- CFC: Get access -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="setaccess(attributes.folder_id)" />
		<!-- CFC: Check for custom fields -->
		<invoke object="myFusebox.getApplicationData().custom_fields" methodcall="getfields(attributes)" returnvariable="qry_cf" />
		<!-- CFC: Get how many comments there are -->
		<invoke object="myFusebox.getApplicationData().comments" methodcall="howmany(attributes)" returnvariable="qry_comments_total" />
		<!-- Show the folder listing -->
		<do action="ajax.files_detail" />
	</fuseaction>
	<!-- Save Detail -->
	<fuseaction name="files_detail_save">
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- Action: Storage -->
		<do action="storage" />
		<!-- CFC: Get image settings -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="prefs_image()" returnvariable="attributes.qry_settings_image" />
		<!-- Check if there are custom fields to be saved (we do this before because of indexing) -->
		<if condition="attributes.customfields NEQ 0">
			<true>
				<do action="custom_fields_save" />
			</true>
		</if>
		<!-- CFC: Save file detail -->
		<invoke object="myFusebox.getApplicationData().files" methodcall="update(attributes)" />
		<!-- CFC: Write Metadata to file  -->
		<if condition="attributes.file_extension EQ 'pdf' AND attributes.link_kind NEQ 'url'">
			<true>
				<invoke object="myFusebox.getApplicationData().xmp" methodcall="metatofile(attributes)" />
			</true>
		</if>
	</fuseaction>
	<!-- Serve File to the browser -->
	<fuseaction name="serve_file">
		<!-- Param -->
		<set name="attributes.thispath" value="#thispath#" />
		<!-- CFC: Get asset path -->
		<do action="assetpath" />
		<!-- CFC: Serve the file -->
		<invoke object="myFusebox.getApplicationData().files" methodcall="servefile(attributes)" returnvariable="qry_binary" />
		<!-- Show -->
		<do action="v.serve_asset" />
	</fuseaction>
	<!--
		START: DETAIL VIDEO SECTION
	 -->
	
	<!-- Load Video Detail -->
	<fuseaction name="videos_detail">
		<!-- XFA -->
		<xfa name="save" value="c.videos_detail_save" />
		<xfa name="tobasket" value="c.basket_put" />
		<xfa name="tofavorites" value="c.favorites_put" />
		<xfa name="sendemail" value="c.email_send" />
		<xfa name="sendftp" value="c.ftp_send" />
		<xfa name="fvideosloader" value="c.folder_videos_show" />
		<xfa name="assetdetail" value="c.videos_detail" />
		<!-- Params -->
		<set name="attributes.kind" value="videos" />
		<set name="attributes.cf_show" value="vid" />
		<!-- CFC: Get file detail -->
		<invoke object="myFusebox.getApplicationData().videos" methodcall="detail(attributes)" returnvariable="qry_detail" />
		<!-- CFC: Get access -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="setaccess(attributes.folder_id)" />
		<!-- CFC: Check for custom fields -->
		<invoke object="myFusebox.getApplicationData().custom_fields" methodcall="getfields(attributes)" returnvariable="qry_cf" />
		<!-- CFC: Get how many comments there are -->
		<invoke object="myFusebox.getApplicationData().comments" methodcall="howmany(attributes)" returnvariable="qry_comments_total" />
		<!-- CFC: Get languages -->
		<do action="languages" />
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- Get labels -->
		<do action="labels" />
		<!-- Get labels for this record -->
		<invoke object="myFusebox.getApplicationData().labels" methodcall="getlabels(attributes.file_id,'vid')" returnvariable="qry_labels" />
		<!-- Show the folder listing -->
		<do action="ajax.videos_detail" />
	</fuseaction>
	<!-- Load related videos -->
	<fuseaction name="videos_detail_related">
		<!-- CFC: Get related videos -->
		<invoke object="myFusebox.getApplicationData().videos" methodcall="relatedvideos(attributes)" returnvariable="qry_related" />
		<!-- Show the folder listing -->
		<do action="ajax.videos_detail_related" />
	</fuseaction>
	<!-- Save Detail -->
	<fuseaction name="videos_detail_save">
		<!-- Set the convert_to value to empty -->
		<set name="attributes.convert_to" value="" overwrite="false" />
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- Action: Storage -->
		<do action="storage" />
		<!-- Check if there are custom fields to be saved (we do this before because of indexing) -->
		<if condition="attributes.customfields NEQ 0">
			<true>
				<do action="custom_fields_save" />
			</true>
		</if>
		<!-- CFC: Save file detail -->
		<invoke object="myFusebox.getApplicationData().videos" methodcall="update(attributes)" />
		<!-- Check if we need to convert the video -->
		<if condition="attributes.convert_to NEQ ''">
			<true>
				<do action="videos_convert" />
			</true>
		</if>
	</fuseaction>
	<!-- Convert Video -->
	<fuseaction name="videos_convert">
		<!-- Param -->
		<set name="attributes.dynpath" value="#dynpath#" />
		<set name="attributes.httphost" value="#cgi.http_host#" />
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- CFC: Storage -->
		<do action="storage" />
		<!-- CFC: Get video settings -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="prefs_video()" returnvariable="attributes.qry_settings_video" />
		<!-- CFC: Get image settings -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="prefs_image()" returnvariable="attributes.qry_settings_image" />
		<!-- CFC: Get detail of original image
		<invoke object="myFusebox.getApplicationData().videos" methodcall="getdetails(attributes.file_id)" returnvariable="attributes.qry_detail" /> -->
		<!-- CFC: Convert video -->
		<invoke object="myFusebox.getApplicationData().videos" methodcall="convertvideothread(attributes)" />		
	</fuseaction>
	
	<!--
		END: DETAIL VIDEO SECTION
	 -->
	
	<!--
		START: DETAIL IMAGE SECTION
	 -->
	
	<!-- Load Image Detail -->
	<fuseaction name="images_detail">
		<!-- XFA -->
		<xfa name="save" value="c.images_detail_save" />
		<xfa name="tobasket" value="c.basket_put" />
		<xfa name="tofavorites" value="c.favorites_put" />
		<xfa name="sendemail" value="c.email_send" />
		<xfa name="sendftp" value="c.ftp_send" />
		<xfa name="assetdetail" value="c.images_detail" />
		<!-- Params -->
		<set name="attributes.kind" value="images" />
		<set name="attributes.cf_show" value="img" />
		<!-- CFC: Get languages -->
		<do action="languages" />
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- Get labels -->
		<do action="labels" />
		<!-- Get labels for this record -->
		<invoke object="myFusebox.getApplicationData().labels" methodcall="getlabels(attributes.file_id,'img')" returnvariable="qry_labels" />
		<!-- CFC: Get XMP value -->
		<invoke object="myFusebox.getApplicationData().xmp" methodcall="readxmpdb(attributes)" returnvariable="qry_xmp" />
		<!-- CFC: Get file detail -->
		<invoke object="myFusebox.getApplicationData().images" methodcall="detail(attributes)" returnvariable="qry_detail" />
		<set name="attributes.qry_detail" value="#qry_detail#" />
		<!-- CFC: Get access -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="setaccess(attributes.folder_id)" />
		<!-- CFC: Check for custom fields -->
		<invoke object="myFusebox.getApplicationData().custom_fields" methodcall="getfields(attributes)" returnvariable="qry_cf" />
		<!-- CFC: Get how many comments there are -->
		<invoke object="myFusebox.getApplicationData().comments" methodcall="howmany(attributes)" returnvariable="qry_comments_total" />
		<!-- Show the image detail window -->
		<do action="ajax.images_detail" />
	</fuseaction>
	<!-- Load related images -->
	<fuseaction name="images_detail_related">
		<!-- CFC: Get global settings -->
		<!-- <invoke object="myFusebox.getApplicationData().settings" methodcall="prefs_web()" returnvariable="qry_settings" /> -->
		<!-- CFC: Get related images -->
		<invoke object="myFusebox.getApplicationData().images" methodcall="relatedimages(attributes)" returnvariable="qry_related" />
		<!-- Show the folder listing -->
		<do action="ajax.images_detail_related" />
	</fuseaction>
	<!-- Save Detail -->
	<fuseaction name="images_detail_save">
		<!-- Params -->
		<set name="attributes.convert_to" value="" overwrite="false" />
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- Action: Storage -->
		<do action="storage" />
		<!-- CFC: Get image settings -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="prefs_image()" returnvariable="attributes.qry_settings_image" />
		<set name="attributes.file_ids" value="#attributes.file_id#" />
		<!-- Check if there are custom fields to be saved (we do this before because of indexing) -->
		<if condition="attributes.customfields NEQ 0">
			<true>
				<do action="custom_fields_save" />
			</true>
		</if>
		<!-- CFC: Save file detail -->
		<invoke object="myFusebox.getApplicationData().images" methodcall="update(attributes)" />
		<!-- CFC: Save XMP, but only for JPG/JPEG images -->
		<!-- (attributes.extension EQ 'jpg' OR attributes.extension EQ 'jpeg') AND  -->
		<if condition="attributes.link_kind NEQ 'url'">
			<true>
				<invoke object="myFusebox.getApplicationData().xmp" methodcall="xmpwritethread(attributes)" />
			</true>
		</if>
	</fuseaction>
	<!-- Convert Image -->
	<fuseaction name="images_convert">
		<!-- Param -->
		<set name="attributes.fromconverting" value="T" />
		<set name="attributes.dynpath" value="#dynpath#" />
		<set name="attributes.httphost" value="#cgi.http_host#" />
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- Action: Storage -->
		<do action="storage" />
		<!-- CFC: Get image settings -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="prefs_image()" returnvariable="attributes.qry_settings_image" />
		<!-- CFC: Convert images -->	
		<invoke object="myFusebox.getApplicationData().images" methodcall="convertimage(attributes)" />
	</fuseaction>
	
	<!--
		END: DETAIL IMAGE SECTION
	-->
	 
	<!--
		START: DETAIL AUDIO SECTION
	-->
	
	<!-- Load Detail -->
	<fuseaction name="audios_detail">
		<!-- XFA -->
		<xfa name="save" value="c.audios_detail_save" />
		<xfa name="tobasket" value="c.basket_put" />
		<xfa name="tofavorites" value="c.favorites_put" />
		<xfa name="sendemail" value="c.email_send" />
		<xfa name="sendftp" value="c.ftp_send" />
		<!-- Param -->
		<set name="attributes.kind" value="audios" />
		<set name="attributes.cf_show" value="aud" />
		<!-- CFC: Get languages -->
		<do action="languages" />
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- Get labels -->
		<do action="labels" />
		<!-- Get labels for this record -->
		<invoke object="myFusebox.getApplicationData().labels" methodcall="getlabels(attributes.file_id,'aud')" returnvariable="qry_labels" />
		<!-- CFC: Get file detail -->
		<invoke object="myFusebox.getApplicationData().audios" methodcall="detail(attributes)" returnvariable="qry_detail" />
		<!-- CFC: Get access -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="setaccess(attributes.folder_id)" />
		<!-- CFC: Check for custom fields -->
		<invoke object="myFusebox.getApplicationData().custom_fields" methodcall="getfields(attributes)" returnvariable="qry_cf" />
		<!-- CFC: Get how many comments there are -->
		<invoke object="myFusebox.getApplicationData().comments" methodcall="howmany(attributes)" returnvariable="qry_comments_total" />
		<!-- Show the folder listing -->
		<do action="ajax.audios_detail" />
	</fuseaction>
	<!-- Save Detail -->
	<fuseaction name="audios_detail_save">
		<!-- Set the convert_to value to empty -->
		<set name="attributes.convert_to" value="" overwrite="false" />
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- Action: Storage -->
		<do action="storage" />
		<!-- Check if there are custom fields to be saved (we do this before because of indexing) -->
		<if condition="attributes.customfields NEQ 0">
			<true>
				<do action="custom_fields_save" />
			</true>
		</if>
		<!-- CFC: Save file detail -->
		<invoke object="myFusebox.getApplicationData().audios" methodcall="update(attributes)" />
		<!-- Check if we need to convert the video -->
		<if condition="attributes.convert_to NEQ ''">
			<true>
				<do action="audios_convert" />
			</true>
		</if>
	</fuseaction>
	<!-- Convert Audio -->
	<fuseaction name="audios_convert">
		<!-- Param -->
		<set name="attributes.dynpath" value="#dynpath#" />
		<set name="attributes.httphost" value="#cgi.http_host#" />
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- CFC: Storage -->
		<do action="storage" />
		<!-- CFC: Get video settings -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="prefs_video()" returnvariable="attributes.qry_settings_video" />
		<!-- CFC: Get detail of original audio
		<invoke object="myFusebox.getApplicationData().audios" methodcall="detail(attributes)" returnvariable="attributes.qry_detail" /> -->
		<!-- CFC: Convert video -->
		<invoke object="myFusebox.getApplicationData().audios" methodcall="convertaudiothread(attributes)" />		
	</fuseaction>
	<!-- Load related audios -->
	<fuseaction name="audios_detail_related">
		<!-- CFC: Get related audios -->
		<invoke object="myFusebox.getApplicationData().audios" methodcall="relatedaudios(attributes)" returnvariable="qry_related" />
		<!-- Show the folder listing -->
		<do action="ajax.audios_detail_related" />
	</fuseaction>
	
	<!--
		END: DETAIL AUDIO SECTION
	-->
	
	<!--
		START: SAVE CUSTOM FIELDS VALUES
	-->
	
	<fuseaction name="custom_fields_save">
		<!-- CFC: Save field values -->
		<invoke object="myFusebox.getApplicationData().custom_fields" methodcall="savevalues(attributes)" />
	</fuseaction>
	
	<!--
		END: SAVE CUSTOM FIELDS VALUES
	-->
	
	<!--
		END: FILE SPECIFIC SECTIONS
	-->
	 
	<!--
		START: BASKET
	-->
	<!-- Basket include -->
	<fuseaction name="basket_put_include">
		<!-- CFC: Put file into basket -->
		<invoke object="myFusebox.getApplicationData().basket" methodcall="tobasket(attributes)" />
	</fuseaction>
	<!-- Put into basket -->
	<fuseaction name="basket_put">
		<!-- CFC: Put file into basket -->
		<do action="basket_put_include" />
		<!-- Show -->
		<do action="basket" />
	</fuseaction>
	<!-- Remove item -->
	<fuseaction name="basket_remove">
		<!-- CFC: Remove Item in Basket -->
		<invoke object="myFusebox.getApplicationData().basket" methodcall="removeitem(attributes.id)" />
		<!-- Show -->
		<do action="basket" />
	</fuseaction>
	 
	 
	<!--
		END: BASKET
	-->
	
	<!--
		START: FAVORITES
	--> 
	<!-- Put into favorites -->
	<fuseaction name="favorites_put">
		<!-- CFC: Put file into favorites -->
		<invoke object="myFusebox.getApplicationData().favorites" methodcall="tofavorites(attributes)" />
		<!-- Show -->
		<do action="favorites" />
	</fuseaction>
	<!-- Remove item -->
	<fuseaction name="favorites_remove">
		<!-- CFC: Remove Item in Basket -->
		<invoke object="myFusebox.getApplicationData().favorites" methodcall="removeitem(attributes.id)" />
		<!-- Show -->
		<do action="favorites" />
	</fuseaction>
	 
	 
	<!--
		END: FAVORITES
	--> 
	 
	<!--
		START: EMAIL
	--> 
	
	<!-- Send an eMail -->
	<fuseaction name="email_send">
		<!-- XFA -->
		<xfa name="submit" value="c.email_send_action" />
		<!-- Params -->
		<set name="attributes.user_id" value="#session.theuserid#" />
		<set name="attributes.frombasket" value="F" />
		<set name="attributes.artofimage" value="" />
		<set name="attributes.artofvideo" value="" />
		<set name="attributes.artofaudio" value="" />
		<set name="attributes.artoffile" value="" />
		<set name="attributes.email" value="" />
		<!-- CFC: Get asset path -->
		<do action="assetpath" />
		<!-- CFC: Get user email -->
		<invoke object="myFusebox.getApplicationData().users" methodcall="user_email()" returnvariable="qryuseremail" />
		<!-- CFC: Get file detail -->
		<if condition="attributes.thetype EQ 'doc'">
			<true>
				<invoke object="myFusebox.getApplicationData().files" methodcall="detail(attributes)" returnvariable="qry_asset" />
				<set name="attributes.filename" value="#qry_asset.detail.file_name#" />
			</true>
		</if>
		<!-- CFC: Get video detail -->
		<if condition="attributes.thetype EQ 'vid'">
			<true>
				<!-- CFC: Get details -->
				<invoke object="myFusebox.getApplicationData().videos" method="getdetails" returnvariable="qry_asset.detail">
					<argument name="vid_id" value="#attributes.file_id#" />
					<argument name="ColumnList" value="v.vid_filename, v.vid_extension, v.vid_width vwidth, v.vid_height vheight, v.vid_preview_width, v.vid_preview_heigth, v.vid_size vlength, v.vid_prev_size vprevlength, v.link_kind, v.link_path_url,v.path_to_asset" />
				</invoke>
				<set name="attributes.filename" value="#qry_asset.detail.vid_filename#" />
				<!-- CFC: Get related videos -->
				<invoke object="myFusebox.getApplicationData().videos" methodcall="relatedvideos(attributes)" returnvariable="qry_related" />
			</true>
		</if>
		<!-- CFC: Get image detail -->
		<if condition="attributes.thetype EQ 'img'">
			<true>
				<!-- CFC: Get details -->
				<invoke object="myFusebox.getApplicationData().images" methodcall="detail(attributes)" returnvariable="qry_asset" />
				<set name="attributes.filename" value="#qry_asset.detail.img_filename#" />
				<!-- CFC: Get related images -->
				<invoke object="myFusebox.getApplicationData().images" methodcall="relatedimages(attributes)" returnvariable="qry_related" />
			</true>
		</if>
		<!-- CFC: Get audio detail -->
		<if condition="attributes.thetype EQ 'aud'">
			<true>
				<!-- CFC: Get details -->
				<invoke object="myFusebox.getApplicationData().audios" methodcall="detail(attributes)" returnvariable="qry_asset" />
				<set name="attributes.filename" value="#qry_asset.detail.aud_name#" />
				<!-- CFC: Get related images -->
				<invoke object="myFusebox.getApplicationData().audios" methodcall="relatedaudios(attributes)" returnvariable="qry_related" />
			</true>
		</if>
		<!-- Show -->
		<do action="ajax.email_send" />
	</fuseaction>
	<!-- Send Action -->
	<fuseaction name="email_send_action">
		<set name="attributes.embedurl" value="F" overwrite="false" />
		<!-- If we need to send as attachments -->
		<if condition="attributes.sendaszip EQ 'T'">
			<true>
				<!-- Action: Get asset path -->
				<do action="assetpath" />
				<!-- Action: Storage -->
				<do action="storage" />
				<!-- Documents -->
				<if condition="attributes.thetype EQ 'doc'">
					<true>
						<!-- CFC: Write file to system -->
						<invoke object="myFusebox.getApplicationData().files" methodcall="writefile(attributes)" returnvariable="thefile" />
					</true>
				</if>
				<!-- Videos -->
				<if condition="attributes.thetype EQ 'vid'">
					<true>
						<!-- CFC: Write file to system -->
						<invoke object="myFusebox.getApplicationData().videos" methodcall="writevideo(attributes)" returnvariable="thefile" />
					</true>
				</if>
				<!-- Images -->
				<if condition="attributes.thetype EQ 'img'">
					<true>
						<!-- CFC: Write file to system -->
						<invoke object="myFusebox.getApplicationData().images" methodcall="writeimage(attributes)" returnvariable="thefile" />
					</true>
				</if>
				<!-- Images -->
				<if condition="attributes.thetype EQ 'aud'">
					<true>
						<!-- CFC: Write file to system -->
						<invoke object="myFusebox.getApplicationData().audios" methodcall="writeaudio(attributes)" returnvariable="thefile" />
					</true>
				</if>
				<!-- CFC: Send eMail -->
				<invoke object="myFusebox.getApplicationData().email" method="send_email">
					<argument name="to" value="#attributes.to#" />
					<argument name="cc" value="#attributes.cc#" />
					<argument name="bcc" value="#attributes.bcc#" />
					<argument name="to" value="#attributes.to#" />
					<argument name="subject" value="#attributes.subject#" />
					<argument name="attach" value="#thefile#" />
					<argument name="themessage" value="#attributes.message#" />
					<argument name="thepath" value="#attributes.thepath#" />
					<argument name="sendaszip" value="#attributes.sendaszip#" />
					<argument name="prefix" value="#session.hostdbprefix#" />
				</invoke>
				<!-- Remove file from system -->
				
			</true>
			<!-- We only need to send the email -->
			<false>
				<!-- CFC: Send eMail -->
				<invoke object="myFusebox.getApplicationData().email" method="send_email">
					<argument name="to" value="#attributes.to#" />
					<argument name="cc" value="#attributes.cc#" />
					<argument name="bcc" value="#attributes.bcc#" />
					<argument name="to" value="#attributes.to#" />
					<argument name="subject" value="#attributes.subject#" />
					<argument name="themessage" value="#attributes.message#" />
					<argument name="sendaszip" value="#attributes.sendaszip#" />
					<argument name="prefix" value="#session.hostdbprefix#" />
				</invoke>
			</false>
		</if>
		
		
	</fuseaction>
	
	<!--
		END: EMAIL
	--> 
	
	<!--
		START: FTP
	--> 
	
	<!-- FTP Form -->
	<fuseaction name="ftp_send">
		<!-- XFA -->
		<xfa name="submit" value="c.ftp_gologin" />
		<!-- Params -->
		<set name="attributes.frombasket" value="F" />
		<set name="attributes.artofimage" value="" />
		<set name="attributes.artofvideo" value="" />
		<set name="attributes.artofaudio" value="" />
		<set name="attributes.artoffile" value="" />
		<!-- CFC: Get file detail -->
		<if condition="attributes.thetype EQ 'doc'">
			<true>
				<invoke object="myFusebox.getApplicationData().files" methodcall="detail(attributes)" returnvariable="qry_asset" />
				<set name="attributes.filename" value="#qry_asset.detail.file_name#" />
			</true>
		</if>
		<!-- CFC: Get video detail -->
		<if condition="attributes.thetype EQ 'vid'">
			<true>
				<!-- CFC: Get Details -->
				<invoke object="myFusebox.getApplicationData().videos" method="getdetails" returnvariable="qry_asset">
					<argument name="vid_id" value="#attributes.file_id#" />
					<argument name="columnlist" value="v.vid_FILENAME, v.vid_extension, v.vid_width vwidth, v.vid_height vheight, v.vid_preview_width, v.vid_preview_heigth, v.vid_size vlength, v.vid_prev_size vprevlength,v.path_to_asset" />
				</invoke>
				<set name="attributes.filename" value="#qry_asset.vid_filename#" />
				<!-- CFC: Get related videos -->
				<invoke object="myFusebox.getApplicationData().videos" methodcall="relatedvideos(attributes)" returnvariable="qry_related" />
			</true>
		</if>
		<!-- CFC: Get image detail -->
		<if condition="attributes.thetype EQ 'img'">
			<true>
				<!-- CFC: Get details -->
				<invoke object="myFusebox.getApplicationData().images" methodcall="detail(attributes)" returnvariable="qry_asset" />
				<set name="attributes.filename" value="#qry_asset.detail.img_filename#" />
				<!-- CFC: Get related images -->
				<invoke object="myFusebox.getApplicationData().images" methodcall="relatedimages(attributes)" returnvariable="qry_related" />
			</true>
		</if>
		<!-- CFC: Get audio detail -->
		<if condition="attributes.thetype EQ 'aud'">
			<true>
				<!-- CFC: Get details -->
				<invoke object="myFusebox.getApplicationData().audios" methodcall="detail(attributes)" returnvariable="qry_asset" />
				<set name="attributes.filename" value="#qry_asset.detail.aud_name#" />
				<!-- CFC: Get related images -->
				<invoke object="myFusebox.getApplicationData().audios" methodcall="relatedaudios(attributes)" returnvariable="qry_related" />
			</true>
		</if>
		<!-- Show -->
		<do action="ajax.ftp_send" />
	</fuseaction>
	<!-- FTP Login to Server -->
	<fuseaction name="ftp_gologin">
		<!-- XFA -->
		<xfa name="submitassetftp" value="c.ftp_put" />
		<xfa name="reloadftp" value="c.ftp_put_reload" />
		<!-- Params -->
		<set name="attributes.frombasket" value="F" overwrite="false" />
		<set name="attributes.sendaszip" value="T" overwrite="false" />
		<set name="attributes.zipname" value="" overwrite="false" />
		<set name="attributes.file_id" value="" overwrite="false" />
		<set name="attributes.foldername" value="" overwrite="false" />
		<set name="attributes.folderpath" value="" overwrite="false" />
		<set name="attributes.artofimage" value="" overwrite="false" />
		<!-- Store values in session since we need them later on some more -->
		<set name="session.ftp_server" value="#attributes.ftp_server#" />
		<set name="session.ftp_user" value="#attributes.ftp_user#" />
		<set name="session.ftp_pass" value="#attributes.ftp_pass#" />
		<set name="session.ftp_passive" value="#attributes.ftp_passive#" />
		<set name="session.zipname" value="#attributes.zipname#" />
		<set name="session.file_id" value="#attributes.file_id#" />
		<set name="session.thetype" value="#attributes.thetype#" />
		<set name="session.sendaszip" value="#attributes.sendaszip#" />
		<set name="session.frombasket" value="F" />
		<!-- If this comes from the scheduled uploads -->
		<if condition="attributes.thetype EQ 'sched'">
			<true>
				<set name="session.frombasket" value="S" />
			</true>
		</if>
		<!-- If this is a video, image or audio -->
		<if condition="attributes.thetype EQ 'vid' OR attributes.thetype EQ 'img' OR attributes.thetype EQ 'aud' OR attributes.thetype EQ 'doc'">
			<true>
				<set name="session.artofimage" value="#attributes.artofimage#" />
			</true>
		</if>
		<!-- If this is from the basket -->
		<if condition="attributes.frombasket EQ 'T'">
			<true>
				<set name="session.frombasket" value="T" />
			</true>
		</if>
		<!-- Get settings -->
		<do action="asset_get_settings" />
		<!-- CFC: Get languages -->
		<do action="languages" />
		<!-- CFC: Get FTP directory -->
		<invoke object="myFusebox.getApplicationData().ftp" methodcall="getdirectory(attributes)" returnvariable="qry_ftp" />
		<!-- Show -->
		<do action="ajax.ftp_put" />
	</fuseaction>
	<!-- FTP PUT Reload -->
	<fuseaction name="ftp_put_reload">
		<xfa name="submitassetftp" value="c.ftp_put" />
		<xfa name="reloadftp" value="c.ftp_put_reload" />
		<!-- CFC: Get languages -->
		<do action="languages" />
		<!-- Get settings -->
		<do action="asset_get_settings" />
		<!-- CFC: Get FTP directory -->
		<invoke object="myFusebox.getApplicationData().ftp" methodcall="getdirectory(attributes)" returnvariable="qry_ftp" />
		<!-- Show -->
		<do action="ajax.ftp_put" />
	</fuseaction>
	<!-- FTP PUT (Upload file to FTP Server) -->
	<fuseaction name="ftp_put">
		<set name="attributes.zipname" value="#session.zipname#" />
		<set name="attributes.sendaszip" value="#session.sendaszip#" />
		<set name="attributes.file_id" value="#session.file_id#" />
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- Action: Storage -->
		<do action="storage" />
		<!-- CFC: Write file to system -->
		<if condition="session.thetype EQ 'doc'">
			<true>
				<set name="attributes.artofimage" value="#session.artofimage#" />
				<invoke object="myFusebox.getApplicationData().files" methodcall="writefile(attributes)" returnvariable="attributes.thefile" />
			</true>
		</if>
		<!-- CFC: Write video to system -->
		<if condition="session.thetype EQ 'vid'">
			<true>
				<set name="attributes.artofimage" value="#session.artofimage#" />
				<!-- CFC: Write -->
				<invoke object="myFusebox.getApplicationData().videos" methodcall="writevideo(attributes)" returnvariable="attributes.thefile" />
			</true>
		</if>
		<!-- CFC: Write audio to system -->
		<if condition="session.thetype EQ 'aud'">
			<true>
				<set name="attributes.artofimage" value="#session.artofimage#" />
				<!-- CFC: Write -->
				<invoke object="myFusebox.getApplicationData().audios" methodcall="writeaudio(attributes)" returnvariable="attributes.thefile" />
			</true>
		</if>
		<!-- CFC: Write image to system -->
		<if condition="session.thetype EQ 'img'">
			<true>
				<set name="attributes.artofimage" value="#session.artofimage#" />
				<!-- CFC: Write -->
				<invoke object="myFusebox.getApplicationData().images" methodcall="writeimage(attributes)" returnvariable="attributes.thefile" />
			</true>
		</if>
		<!-- CFC: Upload to FTP -->
		<invoke object="myFusebox.getApplicationData().ftp" methodcall="putfile(attributes)" />
	</fuseaction>
	
	<!--
		END: FTP
	--> 
	
	<!--
		START: SEARCH
	--> 
	
	<!-- Simple Search -->
	<fuseaction name="search_simple">
		<!-- Param -->
		<set name="attributes.folder_id" value="0" overwrite="false" />
		<set name="attributes.iscol" value="F" overwrite="false" />
		<!-- XFA -->
		<xfa name="folder" value="c.folder" />
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- If we got a folder_id then we search from this folder on -->
		<if condition="attributes.folder_id NEQ '' OR attributes.folder_id NEQ 0">
			<true>
				<!-- CFC: Load recfolder list -->
				<invoke object="myFusebox.getApplicationData().folders" methodcall="recfolder(attributes.folder_id)" returnvariable="attributes.list_recfolders" />
			</true>
		</if>
		<!-- ACTION: Search all -->
		<if condition="#attributes.thetype# EQ 'all'">
			<true>
				<!-- ACTION: Search Files -->
				<do action="search_files" />
				<!-- ACTION: Search Images -->
				<do action="search_images" />
				<!-- ACTION: Search Videos -->
				<do action="search_videos" />
				<!-- ACTION: Search Audios -->
				<do action="search_audios" />
			</true>
		</if>
		<!-- ACTION: Search Files -->
		<if condition="#attributes.thetype# EQ 'doc'">
			<true>
				<do action="search_files" />
			</true>
		</if>
		<!-- ACTION: Search Images -->
		<if condition="#attributes.thetype# EQ 'img'">
			<true>
				<do action="search_images" />
			</true>
		</if>
		<!-- ACTION: Search Videos -->
		<if condition="#attributes.thetype# EQ 'vid'">
			<true>
				<do action="search_videos" />
			</true>
		</if>
		<!-- ACTION: Search Audios -->
		<if condition="#attributes.thetype# EQ 'aud'">
			<true>
				<do action="search_audios" />
			</true>
		</if>
		<!-- CFC: Custom fields -->
		<invoke object="myFusebox.getApplicationData().custom_fields" methodcall="getfieldssearch(attributes)" returnvariable="qry_cf_fields" />
		<!-- Show -->
		<do action="ajax.search" />
	</fuseaction>
	<!-- Search: Files only -->
	<fuseaction name="search_files_do">
		<!-- Params -->
		<set name="attributes.folder_id" value="0" overwrite="false" />
		<set name="attributes.searchtype" value="" overwrite="false" />
		<set name="attributes.thetype" value="doc" overwrite="false" />
		<if condition="#attributes.searchtype# EQ 'adv'">
			<true>
				<set name="attributes.rowmax" value="200" />
			</true>
		</if>
		<!-- XFA -->
		<xfa name="folder" value="c.folder" />
		<!-- ACTION: Search Files -->
		<do action="search_files" />
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- CFC: Custom fields -->
		<invoke object="myFusebox.getApplicationData().custom_fields" methodcall="getfieldssearch(attributes)" returnvariable="qry_cf_fields" />
		<!-- Show -->
		<do action="ajax.search" />
	</fuseaction>
	<!-- Search: Images only -->
	<fuseaction name="search_images_do">
		<!-- Params -->
		<set name="attributes.searchtype" value="" overwrite="false" />
		<set name="attributes.thetype" value="img" overwrite="false" />
		<if condition="#attributes.searchtype# EQ 'adv'">
			<true>
				<set name="attributes.rowmax" value="200" />
			</true>
		</if>
		<!-- XFA -->
		<xfa name="folder" value="c.folder" />
		<!-- ACTION: Search Files -->
		<do action="search_images" />
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- CFC: Custom fields -->
		<invoke object="myFusebox.getApplicationData().custom_fields" methodcall="getfieldssearch(attributes)" returnvariable="qry_cf_fields" />
		<!-- Show -->
		<do action="ajax.search" />
	</fuseaction>
	<!-- Search: Videos only -->
	<fuseaction name="search_videos_do">
		<!-- Params -->
		<set name="attributes.searchtype" value="" overwrite="false" />
		<set name="attributes.thetype" value="vid" overwrite="false" />
		<if condition="#attributes.searchtype# EQ 'adv'">
			<true>
				<set name="attributes.rowmax" value="200" />
			</true>
		</if>
		<!-- XFA -->
		<xfa name="folder" value="c.folder" />
		<!-- ACTION: Search Files -->
		<do action="search_videos" />
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- CFC: Custom fields -->
		<invoke object="myFusebox.getApplicationData().custom_fields" methodcall="getfieldssearch(attributes)" returnvariable="qry_cf_fields" />
		<!-- Show -->
		<do action="ajax.search" />
	</fuseaction>
	<!-- Search: Audios only -->
	<fuseaction name="search_audios_do">
		<!-- Params -->
		<set name="attributes.searchtype" value="" overwrite="false" />
		<set name="attributes.thetype" value="aud" overwrite="false" />
		<if condition="#attributes.searchtype# EQ 'adv'">
			<true>
				<set name="attributes.rowmax" value="200" />
			</true>
		</if>
		<!-- XFA -->
		<xfa name="folder" value="c.folder" />
		<!-- ACTION: Search Files -->
		<do action="search_audios" />
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- CFC: Custom fields -->
		<invoke object="myFusebox.getApplicationData().custom_fields" methodcall="getfieldssearch(attributes)" returnvariable="qry_cf_fields" />
		<!-- Show -->
		<do action="ajax.search" />
	</fuseaction>
	
	<!-- Search: Files -->
	<fuseaction name="search_files">
		<!-- XFA -->
		<xfa name="filedetail" value="c.files_detail" />
		<!-- CFC: Search Files -->
		<invoke object="myFusebox.getApplicationData().search" methodcall="search_files(attributes)" returnvariable="qry_results_files" />
	</fuseaction>
	<!-- Search: Images -->
	<fuseaction name="search_images">
		<!-- XFA -->
		<xfa name="imagedetail" value="c.images_detail" />
		<!-- CFC: Search Images -->
		<invoke object="myFusebox.getApplicationData().search" methodcall="search_images(attributes)" returnvariable="qry_results_images" />
	</fuseaction>
	<!-- Search: Videos -->
	<fuseaction name="search_videos">
		<!-- XFA -->
		<xfa name="videodetail" value="c.videos_detail" />
		<xfa name="fvideosloader" value="c.folder_videos_show" />
		<!-- CFC: Search Videos -->
		<invoke object="myFusebox.getApplicationData().search" methodcall="search_videos(attributes)" returnvariable="qry_results_videos" />
	</fuseaction>
	<!-- Search: Audios -->
	<fuseaction name="search_audios">
		<!-- XFA -->
		<xfa name="audiodetail" value="c.audios_detail" />
		<!-- CFC: Search Audios -->
		<invoke object="myFusebox.getApplicationData().search" methodcall="search_audios(attributes)" returnvariable="qry_results_audios" />
	</fuseaction>
	
	<!-- Search: AJAX -->
	<fuseaction name="search_suggest">
		<!-- CFC: Search Files -->
		<invoke object="myFusebox.getApplicationData().search" methodcall="search_suggest(attributes.suggest)" returnvariable="qry_suggest" />
	</fuseaction>
	
	<!-- Search: Advanced -->
	<fuseaction name="search_advanced">
		<!-- CFC: Custom fields -->
		<invoke object="myFusebox.getApplicationData().custom_fields" methodcall="getfieldssearch(attributes)" returnvariable="qry_fields" />
		<!-- Show -->
		<do action="ajax.search_advanced" />
	</fuseaction>
	
	<!--
		END: SEARCH
	--> 
	
	<!--
		START: CHOOSE FOLDER
	--> 
	
	<!-- Choose: Show window -->
	<fuseaction name="choose_folder">
		<!-- Params -->
		<set name="attributes.folder_id" value="0" overwrite="false" />
		<set name="attributes.theid" value="0" overwrite="false" />
		<set name="attributes.level" value="0" overwrite="false" />
		<set name="attributes.rid" value="0" overwrite="false" />
		<set name="attributes.iscol" value="0" overwrite="false" />
		<!-- For scheduled uploads do... -->
		<if condition="session.type EQ 'scheduler'">
			<true>
				<set name="session.savehere" value="c.scheduler_choose_folder_do" />
			</true>
		</if>
		<!-- If we save the basket as zip in this folder do... -->
		<if condition="session.type EQ 'saveaszip'">
			<true>
				<set name="session.savehere" value="c.saveaszip_form" />
			</true>
		</if>
		<!-- If we save the basket as collection in this folder do... -->
		<if condition="session.type EQ 'saveascollection'">
			<true>
				<set name="session.savehere" value="c.saveascollection_form" />
			</true>
		</if>
		<!-- If we choose the basket as collection in this folder do... -->
		<if condition="session.type EQ 'choosecollection'">
			<true>
				<!-- XFA -->
				<if condition="#isnumeric(session.file_id)#">
					<true>
						<set name="session.savehere" value="c.choose_collection_do_single" />
					</true>
					<false>
						<set name="session.savehere" value="c.choosecollection_do" />
					</false>
				</if>
			</true>
		</if>
		<!-- If we move a file in this folder do... -->
		<if condition="session.type EQ 'movefile'">
			<true>
				<set name="session.savehere" value="c.move_file_do" />
			</true>
		</if>
		<!-- If we move a FOLDER in this folder do... -->
		<if condition="session.type EQ 'movefolder'">
			<true>
				<set name="session.savehere" value="c.move_folder_do" />
			</true>
		</if>
		<!-- Decide on the collection param -->
		<if condition="attributes.iscol EQ 'T'">
			<true>
				<set name="ignoreCollections" value="0" />
				<set name="onlyCollections" value="1" />
			</true>
			<false>
				<set name="ignoreCollections" value="1" />
				<set name="onlyCollections" value="0" />
			</false>
		</if>
		<!-- Show -->
		<do action="ajax.choose_folder" />
	</fuseaction>
	<!-- SaveAsCollection -->
	<fuseaction name="saveascollection_form">
		<!-- CFC: Get languages -->
		<do action="languages" />
		<!-- Show -->
		<do action="ajax.saveascollection_form" />
	</fuseaction>
	<!-- SaveAsZip -->
	<fuseaction name="saveaszip_form">
		<!-- CFC: Get languages -->
		<do action="languages" />
		<!-- Show -->
		<do action="ajax.saveaszip_form" />
	</fuseaction>
	
	<!--
		END: CHOOSE FOLDER
	--> 
	
	<!--
		START: MOVING FOLDER AND FILES
	-->
	
	<!-- Set params for the choose folder dialog -->
	<fuseaction name="move_file">
		<!-- Param -->
		<set name="session.type" value="#attributes.type#" />
		<set name="session.thetype" value="#attributes.thetype#" />
		<set name="session.thefolderorg" value="#attributes.folder_id#" />
		<!-- Put file id into session if the attribute exsists -->
		<if condition="structkeyexists(attributes,'file_id')">
			<true>
				<set name="session.thefileid" value="#attributes.file_id#" />
			</true>
		</if>
		<!-- If we move a folder -->
		<if condition="attributes.type EQ 'movefolder'">
			<true>
				<set name="session.thefolderorglevel" value="#attributes.folder_level#" />
			</true>
		</if>
		<!-- Show the choose folder -->
		<do action="choose_folder" />
	</fuseaction>
	<!-- Move the file into the desired folder -->
	<fuseaction name="move_file_do">
		<!-- Param -->
		<set name="attributes.file_id" value="#session.thefileid#" />
		<set name="attributes.thispath" value="#thispath#" />
		<set name="attributes.hostid" value="#session.hostid#" />
		<set name="attributes.thetype" value="#session.thetype#" />
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- Action: Storage -->
		<do action="storage" />
		<!-- If we are files -->
		<if condition="session.thetype EQ 'doc'">
			<true>
				<invoke object="myFusebox.getApplicationData().files" methodcall="movethread(attributes)" />
			</true>
		</if>
		<!-- If we are images -->
		<if condition="session.thetype EQ 'img'">
			<true>
				<invoke object="myFusebox.getApplicationData().images" methodcall="movethread(attributes)" />
			</true>
		</if>
		<!-- If we are videos -->
		<if condition="session.thetype EQ 'vid'">
			<true>
				<invoke object="myFusebox.getApplicationData().videos" methodcall="movethread(attributes)" />
			</true>
		</if>
		<!-- If we are audios -->
		<if condition="session.thetype EQ 'aud'">
			<true>
				<invoke object="myFusebox.getApplicationData().audios" methodcall="movethread(attributes)" />
			</true>
		</if>
		<!-- If we come from a overview -->
		<if condition="session.thetype EQ 'all'">
			<true>
				<invoke object="myFusebox.getApplicationData().files" methodcall="movethread(attributes)" />
				<invoke object="myFusebox.getApplicationData().images" methodcall="movethread(attributes)" />
				<invoke object="myFusebox.getApplicationData().videos" methodcall="movethread(attributes)" />
				<invoke object="myFusebox.getApplicationData().audios" methodcall="movethread(attributes)" />
			</true>
		</if>
	</fuseaction>
	<!-- Move the folder into the desired folder -->
	<fuseaction name="move_folder_do">
		<!-- Param -->
		<set name="attributes.tomovefolderid" value="#session.thefolderorg#" />
		<!-- <set name="attributes.difflevel" value="#attributes.intolevel# - #session.thefolderorglevel#" /> -->
		<set name="attributes.folder_id" value="#attributes.tomovefolderid#" />
		<!-- CFC: Get asset path -->
		<do action="assetpath" />
		<!-- CFC: Move Folder -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="move(attributes)" />
		<!-- Go to show the folder -->
		<do action="folder" />
	</fuseaction>
	
	<!--
		END: MOVING FOLDER AND FILES
	-->
	
	
	<!--
		START: BATCHING OF MANY FILES
	-->
	
	<!-- Call the batch form -->
	<fuseaction name="batch_form">
		<!-- XFA -->
		<xfa name="batchdo" value="c.batch_do" />
		<!-- CFC: Get languages -->
		<do action="languages" />
		<!-- If we are images -->
		<if condition="attributes.what EQ 'img' OR session.thefileid CONTAINS '-img'">
			<true>
				<!-- CFC: Get XMP value -->
				<invoke object="myFusebox.getApplicationData().xmp" methodcall="readxmpdb(attributes)" returnvariable="qry_xmp" />
				<!-- CFC: Get file detail -->
				<invoke object="myFusebox.getApplicationData().images" methodcall="detail(attributes)" returnvariable="qry_detail" />
			</true>
		</if>
		<!-- Go to show the folder -->
		<do action="ajax.batch_form" />
	</fuseaction>
	<!-- Do the batch -->
	<fuseaction name="batch_do">
		<!-- Set the ids in the normale file_id attribute as the functions will loop over it -->
		<set name="attributes.file_id" value="#attributes.file_ids#" />
		<set name="attributes.frombatch" value="T" />
		<!-- CFC: Get asset path -->
		<do action="assetpath" />
		<!-- CFC: Storage -->
		<do action="storage" />
		<!-- If we are files -->
		<if condition="attributes.what EQ 'doc'">
			<true>
				<invoke object="myFusebox.getApplicationData().files" methodcall="update(attributes)" />
			</true>
		</if>
		<!-- If we are videos -->
		<if condition="attributes.what EQ 'vid'">
			<true>
				<invoke object="myFusebox.getApplicationData().videos" methodcall="update(attributes)" />
			</true>
		</if>
		<!-- If we are images -->
		<if condition="attributes.what EQ 'img'">
			<true>
				<!-- CFC: Get image settings -->
				<invoke object="myFusebox.getApplicationData().settings" methodcall="prefs_image()" returnvariable="attributes.qry_settings_image" />
				<!-- CFC: Save keywords and description -->
				<invoke object="myFusebox.getApplicationData().images" methodcall="update(attributes)" />
				<!-- CFC: Save XMP -->
				<set name="attributes.qrysettings" value="#attributes.qry_settings_image#" />
				<invoke object="myFusebox.getApplicationData().xmp" methodcall="xmpwritethread(attributes)" />
			</true>
		</if>
		<!-- If we are audios -->
		<if condition="attributes.what EQ 'aud'">
			<true>
				<invoke object="myFusebox.getApplicationData().audios" methodcall="update(attributes)" />
			</true>
		</if>
		<!-- If we come from all -->
		<if condition="attributes.what EQ 'all'">
			<true>
				<!-- We get the correct type and IDs -->
				<set name="attributes.id" value="#attributes.file_ids#" />
				<invoke object="myFusebox.getApplicationData().folders" methodcall="removeall(attributes)" returnvariable="theids" />
				<!-- For Docs -->
				<if condition="#theids.docids# NEQ ''">
					<true>
						<set name="attributes.file_id" value="#theids.docids#" />
						<invoke object="myFusebox.getApplicationData().files" methodcall="update(attributes)" />
					</true>
				</if>
				<!-- For Images -->
				<if condition="#theids.imgids# NEQ ''">
					<true>
						<set name="attributes.file_id" value="#theids.imgids#" />
						<!-- CFC: Get image settings -->
						<invoke object="myFusebox.getApplicationData().settings" methodcall="prefs_image()" returnvariable="attributes.qry_settings_image" />
						<!-- CFC: Save keywords and description -->
						<invoke object="myFusebox.getApplicationData().images" methodcall="update(attributes)" />
						<!-- CFC: Save XMP -->
						<set name="attributes.qrysettings" value="#attributes.qry_settings_image#" />
						<invoke object="myFusebox.getApplicationData().xmp" methodcall="xmpwritethread(attributes)" />
					</true>
				</if>
				<!-- For Videos -->
				<if condition="#theids.vidids# NEQ ''">
					<true>
						<set name="attributes.file_id" value="#theids.vidids#" />
						<invoke object="myFusebox.getApplicationData().videos" methodcall="update(attributes)" />
					</true>
				</if>
				<!-- For Audios -->
				<if condition="#theids.audids# NEQ ''">
					<true>
						<set name="attributes.file_id" value="#theids.audids#" />
						<invoke object="myFusebox.getApplicationData().audios" methodcall="update(attributes)" />
					</true>
				</if>
			</true>
		</if>
	</fuseaction>
	<!-- Enable sharing for selected items -->
	<fuseaction name="batch_sharing">
		<!-- Action: Check storage -->
		<!-- <set name="attributes.isbrowser" value="#session.isbrowser#" /> -->
		<do action="storage" />
		<invoke object="myFusebox.getApplicationData().folders" methodcall="batch_sharing(attributes)" />
	</fuseaction>
	
	<!--
		END: BATCHING OF MANY FILES
	-->
	
	<!--
		START: SERVE TO BROWSER (CALLS FROM EXTERNAL URL)
	-->
	
	<!-- FILES -->
	<fuseaction name="sf">
		<!-- Params -->
		<set name="attributes.file_id" value="#attributes.f#" />
		<set name="attributes.type" value="doc" />
		<!-- Do -->
		<do action="serve_file" />
	</fuseaction>
	<!-- VIDEOS -->
	<fuseaction name="sv">
		<!-- Params -->
		<set name="attributes.vid_id" value="#attributes.f#" />
		<set name="attributes.type" value="vid" />
		<if condition="attributes.v EQ 'o'">
			<true>
				<set name="attributes.videofield" value="video" />
			</true>
			<false>
				<set name="attributes.videofield" value="video_preview" />
			</false>
		</if>
		<!-- Do -->
		<do action="folder_videos_show" />
	</fuseaction>
	<!-- IMAGES -->
	<fuseaction name="si">
		<!-- Params -->
		<set name="attributes.file_id" value="#attributes.f#" />
		<set name="attributes.type" value="img" />
		<!-- Action: Check storage
		<set name="attributes.isbrowser" value="#session.isbrowser#" />
		<do action="storage" /> -->
		<!-- CFC: Get asset path -->
		<do action="assetpath" />
		<!-- CFC: Get images -->
		<invoke object="myFusebox.getApplicationData().images" method="filedetail" returnvariable="qry_detail">
			<argument name="theid" value="#attributes.f#" />
			<argument name="thecolumn" value="img_id,thumb_width,thumb_height,folder_id_r,img_width,img_height,img_filename_org,thumb_extension,img_extension,img_filename,path_to_asset,cloud_url,cloud_url_org" />
		</invoke>
		<!-- Do -->
		<do action="ajax.serve_image" />
	</fuseaction>
	<!-- PDFJPGS -->
	<fuseaction name="sp">
		<!-- Params -->
		<set name="attributes.file_id" value="#attributes.f#" />
		<!-- Action: Check storage -->
		<!-- <set name="attributes.isbrowser" value="#session.isbrowser#" /> -->
		<do action="storage" />
		<!-- CFC: Get asset path -->
		<do action="assetpath" />
		<!-- CFC: Get file detail -->
		<invoke object="myFusebox.getApplicationData().files" methodcall="detail(attributes)" returnvariable="qry_detail" />
		<!-- CFC: Get images -->
		<invoke object="myFusebox.getApplicationData().files" methodcall="pdfjpgs(attributes)" returnvariable="qry_pdfjpgs" />
		<!-- Action: Check storage -->
		<set name="attributes.isbrowser" value="#session.isbrowser#" />
		<do action="storage" />
		<!-- Do -->
		<do action="ajax.serve_pdfjpgs" />
	</fuseaction>
	<!-- AUDIOS -->
	<fuseaction name="sa">
		<!-- Params -->
		<set name="attributes.file_id" value="#attributes.f#" />
		<!-- CFC: Get file detail -->
		<invoke object="myFusebox.getApplicationData().audios" methodcall="detail(attributes)" returnvariable="qry_detail_aud" />
		<!-- Params some more -->
		<set name="attributes.path_to_asset" value="#qry_detail_aud.detail.path_to_asset#" />
		<set name="attributes.aud_name" value="#qry_detail_aud.detail.aud_name_org#" />
		<set name="attributes.aud_extension" value="#qry_detail_aud.detail.aud_extension#" />
		<set name="attributes.link_kind" value="#qry_detail_aud.detail.link_kind#" />
		<set name="attributes.link_path_url" value="#qry_detail_aud.detail.link_path_url#" />
		<set name="attributes.cloud_url" value="#qry_detail_aud.detail.cloud_url#" />
		<set name="attributes.cloud_url_org" value="#qry_detail_aud.detail.cloud_url_org#" />
		<!-- Action: Check storage
		<do action="storage" /> -->
		<!-- Do -->
		<do action="ajax.audios_detail_flash" />
	</fuseaction>

	<!--
		END: SERVE TO BROWSER (CALLS FROM EXTERNAL URL)
	-->
	
	<!--  -->
	<!-- ADMIN SECTION -->
	<!--  -->
	
	<!--  -->
	<!-- ADMIN: USERS -->
	<!--  -->

	<!-- Users List -->
	<fuseaction name="users">
		<!-- Set rowmax and rowmin -->
		<set name="attributes.rowmax" value="1000" />
		<set name="attributes.rowmin" value="0" />
		<set name="attributes.dam" value="T" />
		<!-- CFC: Get all users -->
		<invoke object="myFusebox.getApplicationData().users" methodcall="getall(attributes)" returnvariable="qry_users" />
		<!-- Show  -->
		<do action="ajax.admin_users" />
	</fuseaction>
	<!-- Users Search -->
	<fuseaction name="users_search">
		<set name="attributes.dam" value="T" />
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
		<!-- CFC: Get users of the admin group -->
		<invoke object="myFusebox.getApplicationData().groups_users" method="getUsersOfGroup" returnvariable="qry_groups_users">
			<argument name="grp_id" value="2" />
		</invoke>
		<!-- Show -->
		<do action="ajax.users_detail" />
	</fuseaction>
	<!-- Save new or existing user -->
	<fuseaction name="users_save">
		<!-- Param -->
		<set name="attributes.dam" value="T" />
		<set name="attributes.intrauser" value="T" />
		<set name="attributes.hostid" value="#session.hostid#" />
		<!-- CFC: If it is a new user then add, else update -->
		<if condition="#attributes.user_id# EQ 0">
			<true>
				<!-- CFC: Add user to db -->
				<invoke object="myFusebox.getApplicationData().users" methodcall="add(attributes)" returnvariable="attributes.newid" />
				<!-- CFC: Get all modules -->
				<invoke object="myFusebox.getApplicationData().modules" methodcall="getIdStruct()" returnvariable="attributes.module_id_struct" />
				<!-- CFC: Insert user to groups -->
				<invoke object="myFusebox.getApplicationData().groups_users" methodcall="addtogroups(attributes)" />
			</true>
			<false>
				<set name="attributes.newid" value="#attributes.user_id#" />
				<!-- CFC: Get all modules -->
				<invoke object="myFusebox.getApplicationData().modules" methodcall="getIdStruct()" returnvariable="attributes.module_id_struct" />
				<!-- CFC: Remove groups from user
				<invoke object="myFusebox.getApplicationData().groups_users" methodcall="deleteUser(attributes)" /> -->
				<!-- CFC: Update the user -->
				<invoke object="myFusebox.getApplicationData().users" methodcall="update(attributes)" />
				<!-- CFC: Insert user to groups -->
				<invoke object="myFusebox.getApplicationData().groups_users" methodcall="addtogroups(attributes)" />
			</false>
		</if>
	</fuseaction>
	<!-- Delete -->
	<fuseaction name="users_remove">
		<set name="attributes.logsection" value="DAM" />
		<!-- CFC: Delete user -->
		<invoke object="myFusebox.getApplicationData().users" methodcall="delete(attributes)" />
		<!-- CFC: Delete user groups -->
		<set name="attributes.newid" value="#attributes.id#" />
		<invoke object="myFusebox.getApplicationData().groups_users" methodcall="deleteUser(attributes)" />
		<!-- Show  -->
		<do action="users" />
	</fuseaction>
	<!-- Check for the email -->
	<fuseaction name="checkemail">
		<!-- CFC: Check -->
		<invoke object="myFusebox.getApplicationData().users" methodcall="check(attributes)" returnvariable="qry_check" />
		<!-- Show -->
		<do action="ajax.users_check" />
	</fuseaction>
	<!-- Check for the user name -->
	<fuseaction name="checkusername">
		<!-- CFC: Check -->
		<invoke object="myFusebox.getApplicationData().users" methodcall="check(attributes)" returnvariable="qry_check" />
		<!-- Show -->
		<do action="ajax.users_check" />
	</fuseaction>
	
	<!--  -->
	<!-- ADMIN: USERS END -->
	<!--  -->
	
	<!--  -->
	<!-- ADMIN: GROUPS START -->
	<!--  -->

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
		<invoke object="myFusebox.getApplicationData().modules" methodcall="getid(#attributes.kind#)" returnvariable="attributes.modules_dam_id" />
		<!-- CFC: Add the new group -->
		<invoke object="myFusebox.getApplicationData().groups" methodcall="insertRecord(attributes)" />
		<!-- Show -->
		<do action="groups_list" />
	</fuseaction>
	<!-- Groups Detail -->
	<fuseaction name="groups_detail">
		<!-- CFC: Get details -->
		<invoke object="myFusebox.getApplicationData().groups" methodcall="getdetailedit(attributes)" returnvariable="qry_detail" />
		<!-- CFC: Get all users -->
		<invoke object="myFusebox.getApplicationData().users" methodcall="getall(attributes)" returnvariable="qry_users" />
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
	<!-- Groups Update -->
	<fuseaction name="groups_remove">
		<!-- CFC: Update -->
		<invoke object="myFusebox.getApplicationData().groups" methodcall="remove(attributes)" />
		<!-- Show -->
		<do action="groups_list" />
	</fuseaction>
	<!-- Load list of users of the group -->
	<fuseaction name="groups_list_users">
		<!-- CFC: Update -->
		<invoke object="myFusebox.getApplicationData().groups_users" methodcall="getUsersOfGroup('#attributes.grp_id#')" returnvariable="qry_groupusers" />
		<!-- Show -->
		<do action="ajax.groups_list_users" />
	</fuseaction>
	<!-- Remove user from group -->
	<fuseaction name="groups_list_users_remove">
		<!-- CFC: Update -->
		<invoke object="myFusebox.getApplicationData().groups_users" methodcall="removeuserfromgroup('#attributes.grp_id#','#attributes.user_id#')" />
		<!-- Show -->
		<do action="groups_list_users" />
	</fuseaction>
	<!-- Add user to group -->
	<fuseaction name="groups_list_users_add">
		<!-- CFC: Update -->
		<invoke object="myFusebox.getApplicationData().groups_users" methodcall="addusertogroup('#attributes.grp_id#','#attributes.user_id#')" />
		<!-- Show -->
		<do action="groups_list_users" />
	</fuseaction>

	<!--  -->
	<!-- ADMIN: GROUPS END -->
	<!--  -->
	
	<!--  -->
	<!-- ADMIN: SCHEDULER START -->
	<!--  -->
	
	<!-- Scheduler List -->
	<fuseaction name="scheduler_list">
		<set name="qry_sched_status" value="sched_actions" overwrite="false" />
		<!-- CFC: Get all schedules -->
		<invoke object="myFusebox.getApplicationData().scheduler" methodcall="getAllEvents()" returnvariable="qry_schedules" />
		<!-- Show -->
		<do action="ajax.scheduler_list" />
	</fuseaction>
	<!-- Scheduler Detail or add -->
	<fuseaction name="scheduler_detail">
		<!-- CFC: Get the server folder -->
		<invoke object="myFusebox.getApplicationData().scheduler" method="listServerFolder" returnvariable="qry_serverfolder">
			<argument name="thepath" value="#thispath#" />
		</invoke>
		<!-- CFC: get details -->
		<invoke object="myFusebox.getApplicationData().scheduler" methodcall="detail(attributes.sched_id)" returnvariable="qry_detail" />
		<!-- Show -->
		<do action="ajax.scheduler_detail" />
	</fuseaction>
	<!-- Scheduler Detail or add -->
	<fuseaction name="scheduler_save">
		<!-- Save the schedule -->
		<if condition="#attributes.sched_id# EQ 0">
			<true>
				<!-- CFC: New schedule -->
				<invoke object="myFusebox.getApplicationData().scheduler" methodcall="add(attributes)" />
			</true>
			<false>
				<!-- CFC: Update schedule -->
				<invoke object="myFusebox.getApplicationData().scheduler" methodcall="update(attributes)" />
			</false>
		</if>
	</fuseaction>
	<!-- Scheduler Remove -->
	<fuseaction name="scheduler_remove">
		<!-- CFC: Remove schedule -->
		<invoke object="myFusebox.getApplicationData().scheduler" methodcall="remove(attributes.id)" />
		<!-- Show -->
		<do action="scheduler_list" />
	</fuseaction>
	<!-- Choose Folder for Scheduler -->
	<fuseaction name="scheduler_choose_folder">
		<!-- Param -->
		<set name="session.type" value="scheduler" />
		<!-- Show the choose folder -->
		<do action="choose_folder" />
	</fuseaction>
	<!-- Run Schedule -->
	<fuseaction name="scheduler_run">
		<!-- CFC: Run schedule -->
		<invoke object="myFusebox.getApplicationData().scheduler" methodcall="run(attributes.sched_id)" returnvariable="qry_sched_status" />
		<!-- Show -->
		<do action="ajax.scheduler_status" />
	</fuseaction>
	<!-- Schedule Log -->
	<fuseaction name="scheduler_log">
		<!-- CFC: Run schedule -->
		<invoke object="myFusebox.getApplicationData().scheduler" methodcall="getlog(attributes.sched_id)" returnvariable="qry_sched_log" />
		<!-- Show -->
		<do action="ajax.scheduler_log" />
	</fuseaction>
	<!-- Schedule Log -->
	<fuseaction name="scheduler_log_remove">
		<!-- CFC: Run schedule -->
		<invoke object="myFusebox.getApplicationData().scheduler" methodcall="removelog(attributes.sched_id)" />
		<!-- Show -->
		<do action="scheduler_log" />
	</fuseaction>
	<!-- Schedule Run from the tasks -->
	<fuseaction name="scheduler_doit">
		<!-- CFC: Get the Schedule -->
		<invoke object="myFusebox.getApplicationData().scheduler" methodcall="doit(attributes.sched_id)" returnvariable="thetask" />
		<!-- Action: Languages -->
		<do action="languages" />
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- Action: Storage -->
		<do action="storage" />
		<!-- Params -->
		<set name="attributes.sched" value="T" />
		<set name="attributes.thepath" value="#thispath#" />
		<set name="attributes.langcount" value="#qry_langs.recordcount#" />
		<set name="attributes.folder_id" value="#thetask.qry_detail.sched_folder_id_r#" />
		<set name="session.theuserid" value="#thetask.qry_detail.sched_user#" />
		<set name="attributes.sched_action" value="#thetask.qry_detail.sched_server_files#" />
		<set name="attributes.rootpath" value="#ExpandPath('../..')#" />
		<!-- CFC: Log start -->
		<invoke object="myFusebox.getApplicationData().scheduler" method="tolog">
			<argument name="theschedid" value="#attributes.sched_id#" />
			<argument name="theaction" value="Upload" />
			<argument name="thedesc" value=">>> Start Processing Scheduled Upload" />
		</invoke>
		<!-- ACTION: FOR SERVER -->
		<if condition="thetask.qry_detail.sched_method EQ 'server'">
			<true>
				<!-- Set params for adding assets -->
				<set name="attributes.thefile" value="#thetask.dirlist#" />
				<!-- CFC: Add to system -->
				<invoke object="myFusebox.getApplicationData().assets" methodcall="addassetserver(attributes)" />		
			</true>
		</if>	
		<!-- ACTION: FOR FTP -->
		<if condition="thetask.qry_detail.sched_method EQ 'ftp'">
			<true>
				<!-- Params -->
				<set name="session.ftp_server" value="#thetask.qry_detail.sched_ftp_server#" />
				<set name="session.ftp_user" value="#thetask.qry_detail.sched_ftp_user#" />
				<set name="session.ftp_pass" value="#thetask.qry_detail.sched_ftp_pass#" />
				<set name="session.ftp_passive" value="#thetask.qry_detail.sched_ftp_passive#" />
				<set name="attributes.folderpath" value="#thetask.qry_detail.sched_ftp_folder#" />
				<!-- CFC: Get FTP directory for adding to the system -->
				<invoke object="myFusebox.getApplicationData().ftp" methodcall="getdirectory(attributes)" returnvariable="thefiles" />
				<set name="attributes.thefile" value="#valuelist(thefiles.ftplist.name)#" />
				<!-- CFC: Add to system -->
				<invoke object="myFusebox.getApplicationData().assets" methodcall="addassetftpthread(attributes)" />
			</true>
		</if>	
		<!-- ACTION: FOR EMAIL -->
		<if condition="thetask.qry_detail.sched_method EQ 'mail'">
			<true>
				<!-- Params -->
				<set name="attributes.email_server" value="#thetask.qry_detail.sched_mail_pop#" />
				<set name="attributes.email_address" value="#thetask.qry_detail.sched_mail_user#" />
				<set name="attributes.email_pass" value="#thetask.qry_detail.sched_mail_pass#" />
				<set name="attributes.email_subject" value="#thetask.qry_detail.sched_mail_subject#" />
				<set name="session.email_server" value="#thetask.qry_detail.sched_mail_pop#" />
				<set name="session.email_address" value="#thetask.qry_detail.sched_mail_user#" />
				<set name="session.email_pass" value="#thetask.qry_detail.sched_mail_pass#" />
				<!-- CFC: Get the email ids for adding to the system -->
				<invoke object="myFusebox.getApplicationData().email" methodcall="emailheaders(attributes)" returnvariable="themails" />
				<set name="attributes.emailid" value="#valuelist(themails.qryheaders.messagenumber)#" />
				<!-- CFC: Add to system -->
				<invoke object="myFusebox.getApplicationData().assets" methodcall="addassetemail(attributes)" />	
			</true>
		</if>	
		<!-- CFC: Log end -->
		<invoke object="myFusebox.getApplicationData().scheduler" method="tolog">
			<argument name="theschedid" value="#attributes.sched_id#" />
			<argument name="theaction" value="Upload" />
			<argument name="thedesc" value=">>> End Processing Scheduled Upload" />
		</invoke>
	</fuseaction>
		
	<!--  -->
	<!-- ADMIN: SCHEDULER END -->
	<!--  -->
	
	<!--  -->
	<!-- ADMIN: UPLOAD TEMPLATES START -->
	<!--  -->
	
	<!-- Templates List -->
	<fuseaction name="upl_templates">
		<!-- CFC: get templates -->
		<invoke object="myFusebox.getApplicationData().global" methodcall="upl_templates()" returnvariable="qry_templates" />
		<!-- Show -->
		<do action="ajax.upl_templates" />
	</fuseaction>
	<!-- Templates Detail or add -->
	<fuseaction name="upl_template_detail">
		<if condition="attributes.upl_temp_id EQ 0">
			<true>
				<set name="attributes.upl_temp_id" value="#replace(createuuid(),'-','','all')#" />
			</true>
		</if>
		<!-- CFC: get details -->
		<invoke object="myFusebox.getApplicationData().global" methodcall="upl_template_detail(attributes.upl_temp_id)" returnvariable="qry_detail" />
		<!-- Show -->
		<do action="ajax.upl_template_detail" />
	</fuseaction>
	<!-- Templates Save -->
	<fuseaction name="upl_template_save">
		<!-- CFC: save -->
		<invoke object="myFusebox.getApplicationData().global" methodcall="upl_template_save(attributes)" />
	</fuseaction>
	<!-- Templates Remove -->
	<fuseaction name="upl_templates_remove">
		<!-- CFC: save -->
		<invoke object="myFusebox.getApplicationData().global" methodcall="upl_templates_remove(attributes)" />
		
		<do action="upl_templates" />
	</fuseaction>
	
	<!--  -->
	<!-- ADMIN: IMPORT TEMPLATES START -->
	<!--  -->
	
	<!-- Templates List -->
	<fuseaction name="imp_templates">
		<!-- CFC: get templates -->
		<invoke object="myFusebox.getApplicationData().import" methodcall="gettemplates()" returnvariable="qry_templates" />
		<!-- Show -->
		<do action="ajax.imp_templates" />
	</fuseaction>
	<!-- Templates Detail or add -->
	<fuseaction name="imp_template_detail">
		<!-- Param -->
		<set name="attributes.meta_keys" value="id,filename" />
		<set name="attributes.meta_default" value="labels,keywords,description,type" />
		<set name="attributes.meta_img" value="iptcsubjectcode,creator,title,authorstitle,descwriter,iptcaddress,category,categorysub,urgency,iptccity,iptccountry,iptclocation,iptczip,iptcemail,iptcwebsite,iptcphone,iptcintelgenre,iptcinstructions,iptcsource,iptcusageterms,copystatus,iptcjobidentifier,copyurl,iptcheadline,iptcdatecreated,iptcimagecity,iptcimagestate,iptcimagecountry,iptcimagecountrycode,iptcscene,iptcstate,iptccredit,copynotice" />
		<set name="attributes.meta_doc" value="author,rights,authorsposition,captionwriter,webstatement,rightsmarked" />
		<!-- Create new ID -->
		<if condition="attributes.imp_temp_id EQ 0">
			<true>
				<set name="attributes.imp_temp_id" value="#replace(createuuid(),'-','','all')#" />
			</true>
		</if>
		<!-- CFC: get details -->
		<invoke object="myFusebox.getApplicationData().import" methodcall="gettemplatedetail(attributes.imp_temp_id)" returnvariable="qry_detail" />
		<!-- Show -->
		<do action="ajax.imp_template_detail" />
	</fuseaction>
	<!-- Templates Save -->
	<fuseaction name="imp_template_save">
		<!-- CFC: save -->
		<invoke object="myFusebox.getApplicationData().import" methodcall="settemplate(attributes)" />
	</fuseaction>
	<!-- Templates Remove -->
	<fuseaction name="imp_templates_remove">
		<!-- CFC: save -->
		<invoke object="myFusebox.getApplicationData().import" methodcall="removetemplate(attributes)" />
		<!-- Show -->
		<do action="imp_templates" />
	</fuseaction>
	
	<!--  -->
	<!-- ADMIN: UPLOAD TEMPLATES STOP -->
	<!--  -->
	
	
	
	
	<!--  -->
	<!-- ADMIN: LOG USERS START -->
	<!--  -->
	
	<!-- Get Log files -->
	<fuseaction name="log_search">
		<!-- CFC: Search log -->
		<invoke object="myFusebox.getApplicationData().log" methodcall="log_search(attributes)" returnvariable="qry_log" />
		<!-- Show -->
		<do action="ajax.log_search" />
	</fuseaction>
	
	<!-- Get Log files -->
	<fuseaction name="log_users">
		<!-- Set offset for logs -->
		<do action="set_offset_admin" />
		<!-- Params -->
		<set name="attributes.logsection" value="dam" />
		<set name="attributes.logswhat" value="log_users" />
		<!-- CFC: Get log -->
		<invoke object="myFusebox.getApplicationData().log" methodcall="get_log_users(attributes)" returnvariable="qry_log" />
		<!-- Show -->
		<do action="ajax.log_users" />
	</fuseaction>
	<!-- Remove Log file -->
	<fuseaction name="log_users_remove">
		<!-- CFC: Remove log -->
		<invoke object="myFusebox.getApplicationData().log" methodcall="remove_log_users()" />
		<!-- Show -->
		<do action="log_users" />
	</fuseaction>
	
	<!--  -->
	<!-- ADMIN: LOG USERS END -->
	<!--  -->
	
	<!--  -->
	<!-- ADMIN: LOG ASSETS START -->
	<!--  -->
	
	<!-- Get Log files -->
	<fuseaction name="log_assets">
		<!-- Set offset for logs -->
		<do action="set_offset_admin" />
		<!-- Params -->
		<set name="attributes.logswhat" value="log_assets" />
		<!-- CFC: Get log -->
		<invoke object="myFusebox.getApplicationData().log" methodcall="get_log_assets(attributes)" returnvariable="qry_log" />
		<!-- Show -->
		<do action="ajax.log_assets" />
	</fuseaction>
	<!-- Remove Log file -->
	<fuseaction name="log_assets_remove">
		<!-- CFC: Remove log -->
		<invoke object="myFusebox.getApplicationData().log" methodcall="remove_log_assets()" />
		<!-- Show -->
		<do action="log_assets" />
	</fuseaction>
	
	<!--  -->
	<!-- ADMIN: LOG ASSETS END -->
	<!--  -->
	
	<!--  -->
	<!-- ADMIN: LOG FOLDERS START -->
	<!--  -->
	
	<!-- Get Log files -->
	<fuseaction name="log_folders">
		<!-- Set offset for logs -->
		<do action="set_offset_admin" />
		<!-- Params -->
		<set name="attributes.logswhat" value="log_folders" />
		<!-- CFC: Get log -->
		<invoke object="myFusebox.getApplicationData().log" methodcall="get_log_folders(attributes)" returnvariable="qry_log" />
		<!-- Show -->
		<do action="ajax.log_folders" />
	</fuseaction>
	<!-- Remove Log file -->
	<fuseaction name="log_folders_remove">
		<!-- CFC: Remove log -->
		<invoke object="myFusebox.getApplicationData().log" methodcall="remove_log_folders()" />
		<!-- Show -->
		<do action="log_folders" />
	</fuseaction>
	
	<!--  -->
	<!-- ADMIN: LOG FOLDERS END -->
	<!--  -->
	
	<!--  -->
	<!-- ADMIN: LOG SEARCHES START -->
	<!--  -->
	
	<!-- Get Log files -->
	<fuseaction name="log_searches">
		<!-- Set offset for logs -->
		<do action="set_offset_admin" />
		<!-- Params -->
		<set name="attributes.logswhat" value="log_searches" />
		<!-- CFC: Get log -->
		<invoke object="myFusebox.getApplicationData().log" methodcall="get_log_searches(attributes)" returnvariable="qry_log" />
		<!-- Show -->
		<do action="ajax.log_searches" />
	</fuseaction>
	<!-- Get Log files SUMMARIZED -->
	<fuseaction name="log_searches_sum">
		<!-- CFC: Get log -->
		<invoke object="myFusebox.getApplicationData().log" methodcall="get_log_searches_sum(attributes)" returnvariable="qry_log_searches" />
		<!-- Show -->
		<do action="ajax.log_searches_sum" />
	</fuseaction>
	<!-- Remove Log file -->
	<fuseaction name="log_searches_remove">
		<!-- CFC: Remove log -->
		<invoke object="myFusebox.getApplicationData().log" methodcall="remove_log_searches()" />
		<!-- Show -->
		<do action="log_searches" />
	</fuseaction>
	
	<!--  -->
	<!-- ADMIN: LOG SEARCHES END -->
	<!--  -->
	
	<!--  -->
	<!-- ADMIN: LOG ERRORS START -->
	<!--  -->
	
	<!-- Get Log files -->
	<fuseaction name="log_errors">
		<!-- Set offset for logs -->
		<do action="set_offset_admin" />
		<!-- Params -->
		<set name="attributes.logswhat" value="log_errors" />
		<!-- CFC: Get log -->
		<invoke object="myFusebox.getApplicationData().log" methodcall="get_log_errors(attributes)" returnvariable="qry_log" />
		<!-- Show -->
		<do action="ajax.log_errors" />
	</fuseaction>
	<!-- Get Log detail -->
	<fuseaction name="log_errors_detail">
		<!-- CFC: Get log detail -->
		<invoke object="myFusebox.getApplicationData().log" methodcall="get_log_errors_detail(attributes.id)" returnvariable="qry_err_detail" />
		<!-- Show -->
		<do action="ajax.log_errors_detail" />
	</fuseaction>
	<!-- Remove Log file -->
	<fuseaction name="log_errors_remove">
		<!-- CFC: Remove log -->
		<invoke object="myFusebox.getApplicationData().log" methodcall="remove_log_errors()" />
		<!-- Show -->
		<do action="log_errors" />
	</fuseaction>
	<!-- Get Log send window -->
	<fuseaction name="log_errors_win">
		<!-- CFC: Get user email -->
		<invoke object="myFusebox.getApplicationData().users" methodcall="user_email()" returnvariable="qryuseremail" />
		<!-- Show -->
		<do action="ajax.log_errors_win" />
	</fuseaction>
	<!-- Send Log -->
	<fuseaction name="log_errors_send">
		<!-- CFC: get mail server setings -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="prefs_global()" returnvariable="attributes.qrysettings" />
		<!-- CFC: Send the error log -->
		<invoke object="myFusebox.getApplicationData().log" methodcall="send_log_error(attributes)" />
	</fuseaction>
	
	<!--  -->
	<!-- ADMIN: LOG ERRORS END -->
	<!--  -->
	
	<!--  -->
	<!-- ADMIN: CUSTOM FIELDS START -->
	<!--  -->
	
	<!-- Get custom fields -->
	<fuseaction name="custom_fields">
		<!-- CFC: Get languages -->
		<do action="languages" />
		<!-- Show -->
		<do action="ajax.custom_fields" />
	</fuseaction>
	<!-- Get existing custom fields -->
	<fuseaction name="custom_fields_existing">
		<!-- CFC: Get fields -->
		<invoke object="myFusebox.getApplicationData().custom_fields" methodcall="get(attributes)" returnvariable="qry_fields" />
		<!-- Show -->
		<do action="ajax.custom_fields_existing" />
	</fuseaction>
	<!-- Add custom fields -->
	<fuseaction name="custom_field_add">
		<!-- CFC: Add field -->
		<invoke object="myFusebox.getApplicationData().custom_fields" methodcall="add(attributes)" />
	</fuseaction>
	<!-- Get custom field for detail -->
	<fuseaction name="custom_fields_detail">
		<!-- CFC: Get languages -->
		<do action="languages" />
		<!-- CFC: Get fields -->
		<invoke object="myFusebox.getApplicationData().custom_fields" methodcall="getdetail(attributes)" returnvariable="qry_field" />
		<!-- Show -->
		<do action="ajax.custom_fields_detail" />
	</fuseaction>
	<!-- Update custom fields -->
	<fuseaction name="custom_field_update">
		<!-- CFC: Add field -->
		<invoke object="myFusebox.getApplicationData().custom_fields" methodcall="update(attributes)" />
	</fuseaction>
	<!-- Remove custom fields -->
	<fuseaction name="custom_fields_remove">
		<!-- CFC: Add field -->
		<invoke object="myFusebox.getApplicationData().custom_fields" methodcall="delete(attributes)" />
		<!-- Show -->
		<do action="custom_fields_existing" />
	</fuseaction>
	
	<!--  -->
	<!-- ADMIN: CUSTOM FIELDS END -->
	<!--  -->
	
	<!--  -->
	<!-- ADMIN: ISP SETTINGS START -->
	<!--  -->
	
	<!-- Get settings -->
	<fuseaction name="isp_settings">
		<!-- Params -->
		
		<!-- CFC: Get languages -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="lang_get()" returnvariable="qry_langs" />
		<!-- Show -->
		<do action="ajax.isp_settings" />
	</fuseaction>
	<!-- Update languages -->
	<fuseaction name="isp_settings_updatelang">
		<!-- Params -->
		<set name="attributes.thepath" value="#thispath#" />		
		<!-- CFC: Get languages -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="lang_get_langs(attributes)" />
		<!-- Show -->
		<do action="isp_settings" />
	</fuseaction>
	<!-- Update languages -->
	<fuseaction name="isp_settings_langsave">
		<!-- CFC: Get languages -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="lang_save(attributes)" />
	</fuseaction>
	<!-- Image Upload -->
	<fuseaction name="prefs_imgupload">
		<set name="attributes.uploadnow" value="F" overwrite="false" />
		<!-- CFC: Upload file -->
		<if condition="#attributes.uploadnow# EQ 'T'">
			<true>
				<!-- CFC: upload logo -->
				<invoke object="myFusebox.getApplicationData().settings" methodcall="upload(attributes)" returnvariable="result" />
			</true>
		</if>
		<!-- Show  -->
		<do action="ajax.isp_settings_upload" />
	</fuseaction>
	
	<!--  -->
	<!-- ADMIN: ISP SETTINGS END -->
	<!--  -->
	
	<!--  -->
	<!-- ADMIN: MAINTENANCE START -->
	<!--  -->
	
	<!-- For loading maitenance -->
	<fuseaction name="admin_maintenance">
		<!-- Params -->
		<set name="attributes.hostid" value="#session.hostid#" />
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- Action: Storage
		<do action="storage" /> -->
		<!-- CFC
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="get_backup(attributes.hostid)" returnvariable="qry_backup" /> -->
		<!-- Show -->
		<do action="ajax.admin_maintenance" />
	</fuseaction>
	<!-- Do the rebuild -->
	<fuseaction name="admin_rebuild_do">
		<set name="attributes.thispath" value="#thispath#" />
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- Action: Storage -->
		<do action="storage" />
		<!-- CFC: Get all the asset -->
		<invoke object="myFusebox.getApplicationData().lucene" methodcall="rebuild(attributes)" />
	</fuseaction>
	<!-- For System Information -->
	<fuseaction name="admin_system">
		<!-- CFC: Count all files -->
		<invoke object="myFusebox.getApplicationData().Folders" methodcall="filetotalcount(0,'T')" returnvariable="totalcount" />
		<!-- Show -->
		<do action="ajax.admin_system" />
	</fuseaction>
	<!-- Backup -->
	<fuseaction name="admin_backup">
		<!-- Param -->
		<set name="attributes.thepath" value="#thispath#" />
		<set name="attributes.hostid" value="#session.hostid#" />
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- Action: Storage -->
		<do action="storage" />
		<!-- CFC: Backup -->
		<if condition="#attributes.tofiletype# EQ 'raz'">
			<true>
				<invoke object="myFusebox.getApplicationData().backuprestore" methodcall="backuptodb(attributes)" />
			</true>
			<false>
				<invoke object="myFusebox.getApplicationData().backuprestore" methodcall="backupxml(attributes)" />
			</false>
		</if>
	</fuseaction>
	<!-- Restore from filesystem -->
	<fuseaction name="admin_restore">
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- Action: Storage -->
		<do action="storage" />
		<!-- CFC: Do the restore -->
		<invoke object="myFusebox.getApplicationData().backuprestore" methodcall="restorexml(attributes)" />
	</fuseaction>
	<!-- Restore from upload -->
	<fuseaction name="admin_restore_upload">
		<!-- Param -->
		<set name="attributes.thepath" value="#thispath#" />
		<set name="attributes.uploadxml" value="T" />
		<!-- Action: Get asset path -->
		<do action="assetpath" />
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
	<!-- Cleaner -->
	<fuseaction name="admin_cleaner">
		<set name="attributes.thispath" value="#thispath#" />
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- Action: Storage -->
		<do action="storage" />
		<!-- CFC: Get audios -->
		<invoke object="myFusebox.getApplicationData().audios" methodcall="getempty(attributes)" returnvariable="qry_audios" />
		<!-- CFC: Get images -->
		<invoke object="myFusebox.getApplicationData().images" methodcall="getempty(attributes)" returnvariable="qry_images" />
		<!-- CFC: Get videos -->
		<invoke object="myFusebox.getApplicationData().videos" methodcall="getempty(attributes)" returnvariable="qry_videos" />
		<!-- CFC: Get files -->
		<invoke object="myFusebox.getApplicationData().files" methodcall="getempty(attributes)" returnvariable="qry_files" />
		<!-- Show -->
		<do action="ajax.admin_maintenance_cleaner" />
	</fuseaction>
	<!-- Cleaner: remove -->
	<fuseaction name="admin_cleaner_delete">
		<!-- Include the remove code -->
		<do action="inc_admin_cleaner_delete" />
		<!-- Show -->
		<do action="admin_cleaner" />
	</fuseaction>
	<!-- Cleaner remove from asset -->
	<fuseaction name="admin_cleaner_check_asset_delete">
		<!-- Include the remove code -->
		<do action="inc_admin_cleaner_delete" />
		<!-- Show -->
		<do action="admin_cleaner_check_asset" />
	</fuseaction>
	<!-- Cleaner -->
	<fuseaction name="admin_cleaner_check_asset">
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- Action: Storage -->
		<do action="storage" />
		<!-- Call CFCs -->
		<invoke object="myFusebox.getApplicationData().global" methodcall="checkassets(attributes)" />
	</fuseaction>
	<!-- Cleaner -->
	<fuseaction name="inc_admin_cleaner_delete">
		<!-- Param -->
    	<set name="attributes.theuserid" value="#session.theuserid#" />
    	<set name="attributes.hostdbprefix" value="#session.hostdbprefix#" />
    	<set name="attributes.hostid" value="#session.hostid#" />
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- Action: Storage -->
		<do action="storage" />
		<!-- Call CFCs to delete record -->
		<if condition="attributes.thetype EQ 'img'">
			<true>
				<invoke object="myFusebox.getApplicationData().images" methodcall="removeimagemany(attributes)" />
			</true>
		</if>
		<if condition="attributes.thetype EQ 'doc'">
			<true>
				<invoke object="myFusebox.getApplicationData().files" methodcall="removefilemany(attributes)" />
			</true>
		</if>
		<if condition="attributes.thetype EQ 'vid'">
			<true>
				<invoke object="myFusebox.getApplicationData().videos" methodcall="removevideomany(attributes)" />
			</true>
		</if>
		<if condition="attributes.thetype EQ 'aud'">
			<true>
				<invoke object="myFusebox.getApplicationData().audios" methodcall="removeaudiomany(attributes)" />
			</true>
		</if>
	</fuseaction>
	<!--  -->
	<!-- ADMIN: MAINTENANCE END -->
	<!--  -->
	
	<!--  -->
	<!-- ADMIN: LABELS START -->
	<!--  -->
	
	<!-- Loading labels -->
	<fuseaction name="admin_labels">
		<!-- CFC: Get setting -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="get_label_set()" returnvariable="qry_labels_setting" />
		<!-- CFC: Get all labels -->
		<invoke object="myFusebox.getApplicationData().labels" methodcall="admin_get()" returnvariable="qry_labels" />
		<!-- Show -->
		<do action="ajax.admin_labels" />
	</fuseaction>
	<!-- removing labels -->
	<fuseaction name="labels_remove">
		<!-- CFC: remove label -->
		<invoke object="myFusebox.getApplicationData().labels" methodcall="admin_remove(attributes.id)" />
		<!-- Show -->
		<do action="admin_labels" />
	</fuseaction>
	<!-- Add/Edit Label -->
	<fuseaction name="admin_labels_add">
		<!-- CFC: Get label -->
		<invoke object="myFusebox.getApplicationData().labels" methodcall="admin_get_one(attributes.label_id)" returnvariable="qry_label" />
		<!-- Show -->
		<do action="ajax.admin_labels_add" />
	</fuseaction>
	<!-- Update Label -->
	<fuseaction name="admin_labels_update">
		<!-- CFC: Get label -->
		<invoke object="myFusebox.getApplicationData().labels" methodcall="admin_update(attributes)" />
		<!-- Show -->
		<do action="admin_labels" />
	</fuseaction>
	<!-- Save Label setting -->
	<fuseaction name="admin_labels_setting">
		<!-- CFC: Save label -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="set_label_set(attributes.label_users)" />
	</fuseaction>
	
	
	<!--  -->
	<!-- ADMIN: LABELS STOP -->
	<!--  -->
	
	<!--  -->
	<!-- ADMIN SECTION END -->
	<!--  -->
	
	<!-- For loading Gears -->
	<fuseaction name="gears">
		<!-- Show -->
		<do action="v.gears" />
	</fuseaction>
	
	<!-- Window for Print to PDF -->
	<fuseaction name="topdf">
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- Action: Storage -->
		<!-- <set name="attributes.isbrowser" value="#session.isbrowser#" />
		<do action="storage" /> -->
		<!-- If we need to show all -->
		<if condition="#attributes.kind# EQ 'all'">
			<true>
				<invoke object="myFusebox.getApplicationData().folders" methodcall="filetotalcount(attributes.folder_id)" returnvariable="qry_filecount" />
				<set name="attributes.qry_filecount" value="#qry_filecount.thetotal#" overwrite="false" />
				<invoke object="myFusebox.getApplicationData().folders" methodcall="getallassets(attributes)" returnvariable="qry_files" />
			</true>
		</if>
		<!-- Only images -->
		<if condition="#attributes.kind# EQ 'img'">
			<true>
				<!-- CFC: Get images -->
				<invoke object="myFusebox.getApplicationData().images" method="getFolderAssetDetails" returnvariable="qry_files">
					<argument name="folder_id" value="#attributes.folder_id#" />
					<argument name="columnlist" value="i.img_id id, i.img_filename filename, i.img_custom_id, i.img_create_date, i.img_change_date, i.folder_id_r, i.thumb_extension ext, i.img_filename_org filename_org, i.path_to_asset, i.is_available, i.cloud_url" />
					<argument name="offset" value="#session.offset#" />
					<argument name="rowmaxpage" value="#session.rowmaxpage#" />
					<argument name="thestruct" value="#attributes#" />
				</invoke>
				<!-- If this is a list we need to get description and keywords as well -->
				<if condition="#attributes.view# EQ 'list'">
					<true>
						<invoke object="myFusebox.getApplicationData().images" methodcall="gettext(qry_files)" returnvariable="qry_files_text" />
					</true>
				</if>
			</true>
		</if>
		<!-- Only Videos -->
		<if condition="#attributes.kind# EQ 'vid'">
			<true>
				<invoke object="myFusebox.getApplicationData().videos" method="getFolderAssetDetails" returnvariable="qry_files">
					<argument name="folder_id" value="#attributes.folder_id#" />
					<argument name="columnlist" value="v.vid_id id, v.vid_filename filename, v.folder_id_r, v.vid_custom_id, v.vid_create_date, v.vid_change_date, v.vid_name_image, v.vid_extension ext, v.vid_name_image filename_org, v.path_to_asset, v.is_available, v.cloud_url" />
					<argument name="offset" value="#session.offset#" />
					<argument name="rowmaxpage" value="#session.rowmaxpage#" />
					<argument name="thestruct" value="#attributes#" />
				</invoke>
				<!-- If this is a list we need to get description and keywords as well -->
				<if condition="#attributes.view# EQ 'list'">
					<true>
						<invoke object="myFusebox.getApplicationData().videos" methodcall="gettext(qry_files)" returnvariable="qry_files_text" />
					</true>
				</if>
			</true>
		</if>
		<!-- Only Audios -->
		<if condition="#attributes.kind# EQ 'aud'">
			<true>
				<!-- Param -->
				<set name="attributes.columnlist" value="a.aud_id id, a.aud_name filename, a.aud_extension ext, a.aud_create_date, a.aud_change_date, a.folder_id_r, a.is_available, a.path_to_asset, a.cloud_url, a.cloud_url_org" />
				<!-- CFC -->
				<invoke object="myFusebox.getApplicationData().audios" method="getFolderAssets" returnvariable="qry_files">
					<argument name="folder_id" value="#attributes.folder_id#" />
					<argument name="offset" value="#session.offset#" />
					<argument name="rowmaxpage" value="#session.rowmaxpage#" />
					<argument name="thestruct" value="#attributes#" />
				</invoke>
				<!-- If this is a list we need to get description and keywords as well -->
				<if condition="#attributes.view# EQ 'list'">
					<true>
						<invoke object="myFusebox.getApplicationData().audios" methodcall="gettext(qry_files)" returnvariable="qry_files_text" />
					</true>
				</if>
			</true>
		</if>
		<!-- Only Files -->
		<if condition="#attributes.kind# NEQ 'all' AND #attributes.kind# NEQ 'img' AND #attributes.kind# NEQ 'vid' AND #attributes.kind# NEQ 'aud'">
			<true>
				<invoke object="myFusebox.getApplicationData().files" method="getFolderAssetDetails" returnvariable="qry_files">
					<argument name="folder_id" value="#attributes.folder_id#" />
					<argument name="columnlist" value="file_id id, file_extension ext, file_type, file_create_date, file_change_date, file_owner, file_name filename, file_name_org filename_org, folder_id_r, path_to_asset, is_available, cloud_url, cloud_url_org" />
					<argument name="file_extension" value="#attributes.kind#" />
					<argument name="offset" value="#session.offset#" />
					<argument name="rowmaxpage" value="#session.rowmaxpage#" />
					<argument name="thestruct" value="#attributes#" />
				</invoke>
				<!-- If this is a list we need to get description and keywords as well -->
				<if condition="#attributes.view# EQ 'list'">
					<true>
						<invoke object="myFusebox.getApplicationData().files" methodcall="gettext(qry_files)" returnvariable="qry_files_text" />
					</true>
				</if>
			</true>
		</if>
		<!-- If this is a detail page -->
		<if condition="#attributes.kind# EQ 'detail'">
			<true>
				<!-- For images -->
				<if condition="#attributes.thetype# EQ 'img'">
					<true>
						<invoke object="myFusebox.getApplicationData().images" methodcall="detail(attributes)" returnvariable="qry_detail" />
					</true>
				</if>
				<!-- For Videos -->
				<if condition="#attributes.thetype# EQ 'vid'">
					<true>
						<invoke object="myFusebox.getApplicationData().videos" methodcall="detail(attributes)" returnvariable="qry_detail" />
					</true>
				</if>
				<!-- For Audios -->
				<if condition="#attributes.thetype# EQ 'aud'">
					<true>
						<invoke object="myFusebox.getApplicationData().audios" methodcall="detail(attributes)" returnvariable="qry_detail" />
					</true>
				</if>
				<!-- For Files -->
				<if condition="#attributes.thetype# EQ 'doc'">
					<true>
						<invoke object="myFusebox.getApplicationData().files" methodcall="detail(attributes)" returnvariable="qry_detail" />
					</true>
				</if>
			</true>
		</if>
		<!-- Show -->
		<do action="ajax.topdf" />
	</fuseaction>
	
	<!--  -->
	<!-- COMMENTS: START -->
	<!--  -->
	
	<!-- Show Comments -->
	<fuseaction name="comments">
		<!-- XFA -->
		<xfa name="comadd" value="c.comments_add" />
		<xfa name="comlist" value="c.comments_list" />
		<!-- Get labels -->
		<do action="labels" />
		<!-- Session for the new comment id -->
		<set name="session.newcommentid" value="#replace(createuuid(),'-','','all')#" />
		<!-- Show -->
		<do action="ajax.comments" />
	</fuseaction>
	<!-- Get Comments -->
	<fuseaction name="comments_list">
		<!-- XFA -->
		<xfa name="comlist" value="c.comments_save" />
		<!-- CFC: Get Comments -->
		<invoke object="myFusebox.getApplicationData().comments" methodcall="get(attributes)" returnvariable="qry_comments" />
		<!-- Show -->
		<do action="ajax.comments_list" />
	</fuseaction>
	<!-- Add Comment -->
	<fuseaction name="comments_add">
		<!-- CFC: Add Comment -->
		<invoke object="myFusebox.getApplicationData().comments" methodcall="add(attributes)" />
		<!-- Show
		<do action="comments_list" /> -->
	</fuseaction>
	<!-- Remove Comment -->
	<fuseaction name="comments_remove">
		<!-- CFC: Remove Comment -->
		<invoke object="myFusebox.getApplicationData().comments" methodcall="remove(attributes)" />
		<!-- CFC: Remove labels -->
		<invoke object="myFusebox.getApplicationData().labels" methodcall="label_ct_remove(attributes.id)" />
		<!-- Show -->
		<do action="comments_list" />
	</fuseaction>
	<!-- Edit Comment -->
	<fuseaction name="comments_edit">
		<!-- Get labels -->
		<do action="labels" />
		<!-- Get labels for this record -->
		<invoke object="myFusebox.getApplicationData().labels" methodcall="getlabels(attributes.com_id,'comment')" returnvariable="qry_labels" />
		<!-- CFC: Add Comment -->
		<invoke object="myFusebox.getApplicationData().comments" methodcall="edit(attributes)" returnvariable="qry_comment" />
		<!-- Show -->
		<do action="ajax.comments_edit" />
	</fuseaction>
	<!-- Update Comment -->
	<fuseaction name="comments_update">
		<!-- CFC: Update Comment -->
		<invoke object="myFusebox.getApplicationData().comments" methodcall="update(attributes)" />
		<!-- Show -->
		<do action="comments_list" />
	</fuseaction>
	
	<!--  -->
	<!-- COMMENTS: END -->
	<!--  -->
	
	<!--  -->
	<!-- SHARING: START -->
	<!--  -->
	
	<!-- This if for a shared collection -->
	<fuseaction name="sharec">
		<!-- Param -->
		<set name="session.iscol" value="T" />
		<set name="attributes.fromcol" value="T" />
		<!-- Show -->
		<do action="share" />
	</fuseaction>
	
	<!-- First entry when sharing is activated -->
	<fuseaction name="share">
		<!-- Param -->
		<set name="attributes.shared" value="T" />
		<set name="attributes.wid" value="0" />
		<set name="attributes.fromcol" value="F" overwrite="false" />
		<set name="attributes.fp" value="F" overwrite="false" />
		<set name="attributes.perm_password" value="F" />
		<!-- Folder id into session -->
		<set name="session.fid" value="#attributes.fid#" />
		<if condition="#attributes.fromcol# EQ 'F'">
			<true>
				<set name="session.iscol" value="F" />
			</true>
		</if>
		<!-- XFA -->
		<xfa name="submitform" value="c.share_login" />
		<xfa name="forgotpass" value="c.forgotpass" />
		<xfa name="switchlang" value="c.switchlang" />
		<!-- Check if folder is shared, secured. If so display log in -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="sharecheckperm(attributes)" returnvariable="shared" />
		<!-- CFC: Get languages -->
		<do action="languages" />
		<!-- If ISP (for now) -->
		<if condition="#application.razuna.isp#">
			<true>
				<set name="attributes.frontpage" value="true" />
				<invoke object="myFusebox.getApplicationData().settings" methodcall="news_get(attributes)" returnvariable="attributes.qry_news" />
			</true>
		</if>
		<!-- If not shared -->
		<if condition="#shared.sharedfolder# EQ 'F'">
			<true>
				<!-- Param -->
				<set name="attributes.shared" value="F" />
				<!-- Show -->
				<do action="v.share_login" />
			</true>
			<false>
				<!-- Show -->
				<do action="v.share_login" />
			</false>
		</if>
		<!-- If shared with everyone -->
		<if condition="#shared.everyone# EQ 'T'">
			<true>
				<if condition="structkeyexists(session,'theuserid') AND #session.theuserid# NEQ ''">
					<false>
						<set name="session.theuserid" value="0" />
					</false>
				</if>
				<!-- Show -->
				<do action="sharep" />
			</true>
		</if>
	</fuseaction>
	<!-- Do Login -->
	<fuseaction name="share_login">
		<!-- Param -->
		<set name="session.iscol" value="T" overwrite="false" />
		<!-- Check the user and let him in ot nor -->
		<invoke object="myFusebox.getApplicationData().Login" method="login" returnvariable="logindone">
			<argument name="name" value="#attributes.name#" />
			<argument name="pass" value="#attributes.pass#" />
			<argument name="loginto" value="dam" />
			<argument name="from_share" value="t" />
		</invoke>
		<!-- User is found -->
		<if condition="logindone.notfound EQ 'F'">
    		<true>
				<!-- set host again with real value -->
				<invoke object="myFusebox.getApplicationData().security" methodcall="initUser(Session.hostid,logindone.qryuser.user_id,'adm')" returnvariable="Request.securityobj" />
				<!-- Folder id into session -->
				<set name="session.fid" value="#attributes.fid#" />
				<!-- CFC: Check if user is allowed for this folder -->
				<invoke object="myFusebox.getApplicationData().folders" methodcall="sharecheckpermfolder(session.fid)" />
				<!-- Relocate -->
				<relocate url="#variables.thehttp##cgi.http_host##myself#c.sharep" />
			</true>
			<!-- User not found -->
			<false>
				<!-- Param -->
		   		<set name="attributes.loginerror" value="T" />
				<!-- Show -->
				<!-- <do action="share" /> -->
				<!-- Relocate -->
				<relocate url="#variables.thehttp##cgi.http_host##myself#c.share&amp;le=t&amp;fid=#attributes.fid#" />
		   	</false>
		</if>
	</fuseaction>
	<!-- Share Proxy -->
	<fuseaction name="sharep">
		<!-- Param -->
		<set name="shared.everyone" value="F" overwrite="false" />
		<do action="v.share" />
	</fuseaction>
	<!-- Get Content -->
	<fuseaction name="share_content">
		<!-- XFA -->
		<xfa name="ffiles" value="c.folder_files" />
		<xfa name="fimages" value="c.folder_images" />
		<xfa name="fvideos" value="c.folder_videos" />
		<xfa name="faudios" value="c.folder_audios" />
		<xfa name="assetadd" value="c.asset_add" />
		<xfa name="detaildoc" value="c.files_detail" />
		<xfa name="detailimg" value="c.images_detail" />
		<xfa name="detailvid" value="c.videos_detail" />
		<xfa name="detailaud" value="c.audios_detail" />
		<!-- Param -->
		<if condition="NOT structkeyexists(session,'fid')">
			<true>
				<relocate url="#variables.thehttp##cgi.http_host##myself#c.share&amp;fid=#attributes.fid#" />
			</true>
		</if>
		<set name="attributes.folder_id" value="#session.fid#" overwrite="false" />
		<set name="kind" value="all" />
		<set name="url.kind" value="all" />
		<set name="attributes.showsubfolders" value="F" overwrite="false" />
		<set name="session.showsubfolders" value="F" />
		<set name="attributes.pages" value="" />
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- CFC: Get languages -->
		<do action="languages" />
		<!-- Action: Set view -->
		<do action="set_view" />
		<!-- Get assets from folder or from collection -->
		<if condition="#session.iscol# EQ 'F'">
			<true>
				<!-- if the folder_id_r is in the URL scope  -->
				<if condition="structkeyexists(url,'folder_id_r')">
					<true>
						<set name="attributes.folder_id" value="#url.folder_id#" />
						<!-- CFC: Get Breadcrumb -->
						<invoke object="myFusebox.getApplicationData().folders" methodcall="getbreadcrumb(url.folder_id_r)" returnvariable="qry_breadcrumb" />
					</true>
				</if>
				<!-- CFC: Get folder share options -->
				<invoke object="myFusebox.getApplicationData().folders" methodcall="getfolderproperties(attributes.folder_id)" returnvariable="qry_folder" />
				<!-- CFC: Get subfolders -->
				<invoke object="myFusebox.getApplicationData().folders" methodcall="getsubfolders(attributes.folder_id)" returnvariable="qry_subfolders" />
				<!-- CFC: Get the total file count -->
				<invoke object="myFusebox.getApplicationData().folders" methodcall="filetotalcount(attributes.folder_id)" returnvariable="qry.qry_filecount" />
				<set name="attributes.qry_filecount" value="#qry.qry_filecount.thetotal#" overwrite="false" />
				<!-- CFC: Get all assets -->
				<invoke object="myFusebox.getApplicationData().folders" methodcall="getallassets(attributes)" returnvariable="qry.qry_files" />
			</true>
			<false>
				<!-- Param -->
				<set name="attributes.col_id" value="#session.fid#" />
				<set name="attributes.share" value="T" />
				<!-- CFC: Get folder share options -->
				<invoke object="myFusebox.getApplicationData().collections" methodcall="details(attributes)" returnvariable="qry_folder" />
				<!-- CFC: Get assets of Collections -->
				<invoke object="myFusebox.getApplicationData().collections" methodcall="get_assets(attributes)" returnvariable="attributes.qry_files" />
				<!-- CFC: Query the assets -->
				<invoke object="myFusebox.getApplicationData().collections" methodcall="getallassets(attributes)" returnvariable="qry" />
			</false>
		</if>
		<!-- Show -->
		<do action="ajax.share_content" />
	</fuseaction>
	<!-- Get latest comment -->
	<fuseaction name="share_comments_latest">
		<!-- CFC: Update Comment -->
		<invoke object="myFusebox.getApplicationData().comments" methodcall="getlatest(attributes)" returnvariable="qry_com_latest" />
		<!-- Show -->
		<do action="ajax.share_comments_latest" />
	</fuseaction>
	<!-- Add Comment -->
	<fuseaction name="share_comments_add">
		<!-- Param -->
		<set name="session.theuserid" value="1" />
		<!-- Session for the new comment id -->
		<set name="session.newcommentid" value="#replace(createuuid(),'-','','all')#" />
		<!-- CFC: Add Comment -->
		<invoke object="myFusebox.getApplicationData().comments" methodcall="add(attributes)" />
		<!-- Show -->
		<do action="share_comments_latest" />
	</fuseaction>
	<!-- Get Comments -->
	<fuseaction name="share_comments_list">
		<!-- CFC: Get Comments -->
		<invoke object="myFusebox.getApplicationData().comments" methodcall="get(attributes)" returnvariable="qry_comments" />
		<!-- Show -->
		<do action="ajax.share_comments_list" />
	</fuseaction>
	<!-- Edit Comment -->
	<fuseaction name="share_comments_edit">
		<!-- Param -->
		<set name="qry_labels" value="" />
		<set name="attributes.thelabels" value="" />
		<!-- CFC: Add Comment -->
		<invoke object="myFusebox.getApplicationData().comments" methodcall="edit(attributes)" returnvariable="qry_comment" />
		<!-- Show -->
		<do action="ajax.comments_edit" />
	</fuseaction>
	<!-- Update Comment -->
	<fuseaction name="share_comments_update">
		<!-- CFC: Update Comment -->
		<invoke object="myFusebox.getApplicationData().comments" methodcall="update(attributes)" />
		<!-- Show -->
		<do action="share_comments_list" />
	</fuseaction>
	<!-- Update Comment -->
	<fuseaction name="share_comments_remove">
		<!-- CFC: Update Comment -->
		<invoke object="myFusebox.getApplicationData().comments" methodcall="remove(attributes)" />
		<!-- Show -->
		<do action="share_comments_list" />
	</fuseaction>
	<!-- Search -->
	<fuseaction name="share_search">
		<!-- If folder_id comes in attributes -->
		<if condition="structkeyexists(attributes,'folder_id')">
			<true>
				<set name="attributes.fid" value="#attributes.folder_id#" />
			</true>
		</if>
		<!-- Folder id into session -->
		<set name="session.fid" value="#attributes.fid#" />
		<!-- Param -->
		<set name="attributes.folder_id" value="#session.fid#" />
		<set name="attributes.iscol" value="#session.iscol#" />
		<!-- If this is a collection get the list of assets for the search -->
		<if condition="#session.iscol# EQ 'T'">
			<true>
				<!-- Param -->
				<set name="attributes.col_id" value="#session.fid#" />
				<!-- CFC: Get assets of Collections -->
				<invoke object="myFusebox.getApplicationData().collections" methodcall="get_assets(attributes)" returnvariable="attributes.qry_files" />
				<!-- CFC: Query the assets -->
				<invoke object="myFusebox.getApplicationData().collections" methodcall="getallassets(attributes)" returnvariable="attributes.qry" />
			</true>
			<!-- We have a folder id thus need get all folders we are allowed to search for -->
			<false>
				<!-- CFC: Load recfolder list -->
				<invoke object="myFusebox.getApplicationData().folders" methodcall="recfolder(attributes.folder_id)" returnvariable="attributes.list_recfolders" />
			</false>
		</if>
		<!-- Jump to the normal search -->
		<do action="search_simple" />
	</fuseaction>
	<!-- Logoff -->
	<fuseaction name="share_logout">
		<!-- Param -->
		<set name="session.login" value="F" />
		<set name="session.weblogin" value="F" />
		<set name="session.thegroupofuser" value="" />
		<set name="session.theuserid" value="" />
		<set name="session.thedomainid" value="" />
		<set name="attributes.fid" value="#session.fid#" />
		<!-- Show -->
		<do action="share" />
	</fuseaction>
	<!-- Add to basket -->
	<fuseaction name="share_basket_put">
		<!-- CFC: Put file into basket -->
		<invoke object="myFusebox.getApplicationData().basket" methodcall="tobasket(attributes)" />
		<!-- Show -->
		<do action="share_basket" />
	</fuseaction>
	<!-- Show basket -->
	<fuseaction name="share_basket">
		<!-- Param -->
		<set name="attributes.fromshare" value="T" />
		<!-- Show -->
		<do action="basket_full" />
	</fuseaction>
	<!-- Remove from basket -->
	<fuseaction name="share_remove_basket">
		<!-- Load include -->
		<do action="basket_full_remove_items" />
		<!-- Show -->
		<do action="basket_full" />
	</fuseaction>
	<fuseaction name="share_remove_basket_all">
		<!-- Load include -->
		<do action="basket_full_remove_all_include" />
		<!-- Show -->
		<do action="basket_full" />
	</fuseaction>
	
	<!--  -->
	<!-- SHARING: END -->
	<!--  -->
	
	<!--  -->
	<!-- VERSIONS: START -->
	<!--  -->
	
	<!-- The initial call -->
	<fuseaction name="versions">
		<!-- Param -->
		<set name="attributes.tempid" value="#createuuid()#" />
		<!-- Show -->
		<do action="ajax.versions" />
	</fuseaction>
	<!-- Get all versions for list -->
	<fuseaction name="versions_list">
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- Action: Check storage
		<set name="attributes.isbrowser" value="#session.isbrowser#" />
		<do action="storage" /> -->
		<!-- CFC: Query the versions -->
		<invoke object="myFusebox.getApplicationData().versions" methodcall="get(attributes)" returnvariable="qry_versions" />
		<!-- Show -->
		<do action="ajax.versions_list" />
	</fuseaction>
	<!-- Upload a new version -->
	<fuseaction name="versions_add">
		<!-- Param -->
		<set name="attributes.zip_extract" value="0" />
		<set name="attributes.sendemail" value="false" />
		<set name="attributes.thepath" value="#thispath#" />
		<set name="attributes.rootpath" value="#ExpandPath('../..')#" />
		<set name="attributes.dynpath" value="#dynpath#" />
		<set name="attributes.httphost" value="#cgi.http_host#" />
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- Action: Check storage -->
		<do action="storage" />
		<!-- CFC: Add the new version to the system -->
		<invoke object="myFusebox.getApplicationData().assets" methodcall="addasset(attributes)" />
		<!-- Show -->
		<do action="versions_list" />
	</fuseaction>
	<!-- Remove version -->
	<fuseaction name="versions_remove">
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- Action: Check storage -->
		<do action="storage" />
		<!-- CFC: Remove version -->
		<invoke object="myFusebox.getApplicationData().versions" methodcall="remove(attributes)" />
		<!-- Show -->
		<do action="versions_list" />
	</fuseaction>
	<!-- Playback a version -->
	<fuseaction name="versions_playback">
		<!-- Param -->
		<set name="attributes.dynpath" value="#dynpath#" />
		<set name="attributes.httphost" value="#cgi.http_host#" />
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- Action: Check storage -->
		<do action="storage" />
		<!-- CFC: Playback version -->
		<invoke object="myFusebox.getApplicationData().versions" methodcall="playback(attributes)" />
		<!-- Show -->
		<do action="versions_list" />
	</fuseaction>
	<!-- Add Upload iFrame -->
	<fuseaction name="versions_upload">
		<!-- Show -->
		<do action="ajax.versions_upload" />
	</fuseaction>
	
	<!--  -->
	<!-- VERSIONS: STOP -->
	<!--  -->
	
	<!-- Random Password -->
	<fuseaction name="randompass">
		<!-- CFC: Random Password -->
		<invoke object="myFusebox.getApplicationData().Login" methodcall="randompass()" returnvariable="attributes.thepass" />
		<!-- Show -->
		<do action="ajax.randompass" />
	</fuseaction>
	
	<!-- Parse FB -->
	<fuseaction name="fbparsecmd">
		<do action="ajax.fbparsecmd" />
	</fuseaction>
	
	<!-- Send Feedback -->
	<fuseaction name="send_feedback">
		<invoke object="myFusebox.getApplicationData().global" methodcall="send_feedback(attributes)" />
	</fuseaction>
	
	<!-- Get asset shared option -->
	<fuseaction name="share_options">
		<!-- CFC: Load folder record -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="getfolderproperties(attributes.folder_id)" returnvariable="qry_folder" />
		<!-- CFC: Get related image records -->
		<if condition="#attributes.type# EQ 'img'">
			<true>
				<invoke object="myFusebox.getApplicationData().images" method="getAssetDetails" returnvariable="qry_detail">
					<argument name="file_id" value="#attributes.file_id#" />
					<argument name="ColumnList" value="thumb_extension, thumb_size, thumb_width, thumb_height, img_extension, img_size, img_width, img_height, link_kind" />
				</invoke>
				<invoke object="myFusebox.getApplicationData().images" methodcall="relatedimages(attributes)" returnvariable="attributes.qry_related" />
			</true>
		</if>
		<!-- CFC: Get related video records -->
		<if condition="#attributes.type# EQ 'vid'">
			<true>
				<!-- CFC: Get Details -->
				<invoke object="myFusebox.getApplicationData().videos" method="getdetails" returnvariable="qry_detail">
					<argument name="vid_id" value="#attributes.file_id#" />
					<argument name="columnlist" value="v.vid_extension, v.vid_width, v.vid_height, v.vid_size, v.link_kind" />
				</invoke>
				<invoke object="myFusebox.getApplicationData().videos" methodcall="relatedvideos(attributes)" returnvariable="attributes.qry_related" />
			</true>
		</if>
		<!-- CFC: Get related audio records -->
		<if condition="#attributes.type# EQ 'aud'">
			<true>
				<!-- CFC: Get file detail -->
				<invoke object="myFusebox.getApplicationData().audios" methodcall="detail(attributes)" returnvariable="qry_detail" />
				<invoke object="myFusebox.getApplicationData().audios" methodcall="relatedaudios(attributes)" returnvariable="attributes.qry_related" />
			</true>
		</if>
		<!-- CFC: Get related audio records -->
		<if condition="#attributes.type# EQ 'doc'">
			<true>
				<!-- CFC: Get file detail -->
				<invoke object="myFusebox.getApplicationData().files" method="filedetail" returnvariable="qry_detail">
					<argument name="theid" value="#attributes.file_id#" />
					<argument name="thecolumn" value="file_extension, file_size, link_kind" />
				</invoke>
			</true>
		</if>
		<!-- CFC: Get share options -->
		<invoke object="myFusebox.getApplicationData().global" methodcall="get_share_options(attributes)" returnvariable="qry_share_options" />
		<!-- Show -->
		<do action="ajax.share_options" />
	</fuseaction>
	<!-- SAVE asset shared option -->
	<fuseaction name="share_options_save">
		<!-- CFC: Save share options -->
		<invoke object="myFusebox.getApplicationData().global" methodcall="save_share_options(attributes)" />
	</fuseaction>
	<!-- SAVE asset shared option -->
	<fuseaction name="share_reset_dl">
		<!-- CFC: Save share options -->
		<invoke object="myFusebox.getApplicationData().global" methodcall="share_reset_dl(attributes)" />
	</fuseaction>
	
	<!--  -->
	<!-- Preview Images: START -->
	<!--  -->
	
	<!-- Start -->
	<fuseaction name="previewimage">
		<!-- Param -->
		<set name="attributes.tempid" value="#createuuid()#" />
		<!-- Show -->
		<do action="ajax.previewimage" />
	</fuseaction>
	<!-- Show preview image -->
	<fuseaction name="previewimage_prev">
		<!-- CFC: Get record -->
		<invoke object="myFusebox.getApplicationData().assets" methodcall="gettemprecord(attributes)" returnvariable="qry_temp" />
		<!-- Show -->
		<do action="ajax.previewimage_prev" />
	</fuseaction>
	<!-- Activate preview image -->
	<fuseaction name="previewimage_activate">
		<!-- Get asset path -->
		<do action="assetpath" />
		<!-- Action: Check storage -->
		<do action="storage" />
		<!-- CFC: Get record -->
		<invoke object="myFusebox.getApplicationData().assets" methodcall="previewimageactivate(attributes)" />
	</fuseaction>
	<!-- Recreate preview image -->
	<fuseaction name="recreatepreview">
		<if condition="!structkeyexists(attributes,'file_id')">
			<true>
				<set name="attributes.file_id" value="#session.file_id#" />
			</true>
		</if>
		<!-- Get asset path -->
		<do action="assetpath" />
		<!-- Action: Check storage -->
		<do action="storage" />
		<!-- CFC: Get image settings -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="prefs_image()" returnvariable="attributes.qry_settings_image" />
		<!-- CFC: Recreate it -->
		<invoke object="myFusebox.getApplicationData().assets" methodcall="recreatepreviewimage(attributes)" />
	</fuseaction>
		
		
	<!--  -->
	<!-- ORDERS: START -->
	<!--  -->
	
	<!-- Get orders -->
	<fuseaction name="orders">
		<!-- CFC: Get Orders -->
		<invoke object="myFusebox.getApplicationData().basket" methodcall="get_orders(attributes)" returnvariable="qry_orders" />
		<!-- Show -->
		<do action="ajax.orders" />
	</fuseaction>
	<!-- Reset CART ID -->
	<fuseaction name="orders_reset">
		<set name="session.thecart" value="#createuuid()#" />
		<!-- Show -->
		<do action="orders" />
	</fuseaction>
	<!-- Order Done -->
	<fuseaction name="order_done">
		<!-- CFC: Set Done -->
		<invoke object="myFusebox.getApplicationData().basket" methodcall="set_done(attributes)" />
	</fuseaction>
	<!-- Get orders -->
	<fuseaction name="order_show">
		<!-- Param -->
		<set name="session.thecart" value="#attributes.cart_id#" />
		<!-- Show -->
		<do action="basket_full" />
	</fuseaction>
	<!-- Remove all items in basket -->
	<fuseaction name="order_remove">
		<!-- Param -->
		<set name="session.thecart" value="#attributes.cart_id#" />
		<!-- Load include -->
		<do action="basket_full_remove_all_include" />
		<!-- Show -->
		<do action="orders" />
	</fuseaction>
	
	<!--  -->
	<!-- ORDERS: STOP -->
	<!--  -->
	
	<!--  -->
	<!-- VIEWS: START -->
	<!--  -->
	
	<!-- View includes -->
	<fuseaction name="view_includes">
		<!-- Params -->
		<set name="attributes.view" value="combined" />
		<set name="session.iscol" value="#attributes.col#" />
		<!-- Set security only if we have no userid in the session -->
		<if condition="NOT StructKeyExists(session, 'theuserid')">
			<true>
				<!-- Param -->
				<set name="session.theuserid" value="0" />
				<!-- set host again with real value -->
				<invoke object="myFusebox.getApplicationData().security" methodcall="initUser(Session.hostid,0,'adm')" returnvariable="Request.securityobj" />
				<!-- CFC: Set Access -->
				<invoke object="myFusebox.getApplicationData().folders" methodcall="setaccess(attributes.folder_id)" returnvariable="qry_foldername" />
			</true>
		</if>
	</fuseaction>
	
	<!-- View includes -->
	<fuseaction name="view_includes_queries">
		<!-- ALL -->
		<if condition="#attributes.kind# EQ 'all'">
			<true>
				<!-- Get assets from folder or from collection -->
				<if condition="#session.iscol# EQ 'F'">
					<true>
						<!-- CFC: Get the total file count -->
						<invoke object="myFusebox.getApplicationData().folders" methodcall="filetotalcount(attributes.folder_id)" returnvariable="qry_filecount" />
						<set name="attributes.qry_filecount" value="#qry_filecount.thetotal#" overwrite="false" />
						<set name="attributes.rowmaxpage" value="#qry_filecount.thetotal#" />
						<!-- CFC: Get all assets -->
						<invoke object="myFusebox.getApplicationData().folders" methodcall="getallassets(attributes)" returnvariable="attributes.qry_files" />
					</true>
					<false>
						<!-- Param -->
						<set name="attributes.col_id" value="#session.fid#" />
						<set name="attributes.share" value="T" />
						<!-- CFC: Get folder share options -->
						<invoke object="myFusebox.getApplicationData().collections" methodcall="details(attributes)" returnvariable="qry_folder" />
						<!-- CFC: Get assets of Collections -->
						<invoke object="myFusebox.getApplicationData().collections" methodcall="get_assets(attributes)" returnvariable="attributes.qry_files" />
						<!-- CFC: Query the assets -->
						<invoke object="myFusebox.getApplicationData().collections" methodcall="getallassets(attributes)" returnvariable="attributes.qry_files" />
					</false>
				</if>
			</true>
		</if>
		<!-- IMAGES -->
		<if condition="#attributes.kind# EQ 'img'">
			<true>
				<!-- CFC: Get the total file count -->
				<invoke object="myFusebox.getApplicationData().folders" methodcall="filetotaltype(attributes)" returnvariable="qry_filecount" />
				<set name="attributes.qry_filecount" value="#qry_filecount.thetotal#" overwrite="false" />
				<!-- CFC: Get images -->
				<invoke object="myFusebox.getApplicationData().images" method="getFolderAssetDetails" returnvariable="attributes.qry_files">
					<argument name="folder_id" value="#attributes.folder_id#" />
					<argument name="columnlist" value="i.img_id id, i.img_filename filename, i.img_filename_org filename_org, i.folder_id_r, i.thumb_extension ext, i.link_kind, i.link_path_url, i.path_to_asset, i.cloud_url, i.cloud_url_org" />
					<argument name="offset" value="0" />
					<argument name="rowmaxpage" value="#qry_filecount.thetotal#" />
					<argument name="thestruct" value="#attributes#" />
				</invoke>
			</true>
		</if>
		<!-- VIDEOS -->
		<if condition="#attributes.kind# EQ 'vid'">
			<true>
				<!-- CFC: Get the total file count -->
				<invoke object="myFusebox.getApplicationData().folders" methodcall="filetotaltype(attributes)" returnvariable="qry_filecount" />
				<set name="attributes.qry_filecount" value="#qry_filecount.thetotal#" overwrite="false" />
				<!-- CFC: Get Videos -->
				<invoke object="myFusebox.getApplicationData().videos" method="getFolderAssetDetails" returnvariable="attributes.qry_files">
					<argument name="folder_id" value="#attributes.folder_id#" />
					<argument name="columnlist" value="v.vid_id id, v.vid_filename filename, v.folder_id_r, v.vid_name_org filename_org, v.vid_name_image, v.vid_extension ext, v.link_kind, v.path_to_asset, v.cloud_url, v.cloud_url_org" />
					<argument name="offset" value="0" />
					<argument name="rowmaxpage" value="#qry_filecount.thetotal#" />
					<argument name="thestruct" value="#attributes#" />
				</invoke>
			</true>
		</if>
		<!-- AUDIOS -->
		<if condition="#attributes.kind# EQ 'aud'">
			<true>
				<!-- CFC: Get the total file count -->
				<invoke object="myFusebox.getApplicationData().folders" methodcall="filetotaltype(attributes)" returnvariable="qry_filecount" />
				<set name="attributes.qry_filecount" value="#qry_filecount.thetotal#" overwrite="false" />
				<set name="attributes.columnlist" value="a.aud_id id, a.folder_id_r, a.aud_name filename, a.aud_extension ext, a.aud_name_org filename_org, a.link_kind, a.path_to_asset, a.cloud_url, a.cloud_url_org" />
				<!-- CFC: Get files -->
				<invoke object="myFusebox.getApplicationData().audios" method="getFolderAssets" returnvariable="attributes.qry_files">
					<argument name="folder_id" value="#attributes.folder_id#" />
					<argument name="offset" value="0" />
					<argument name="rowmaxpage" value="#qry_filecount.thetotal#" />
					<argument name="thestruct" value="#attributes#" />
				</invoke>
			</true>
		</if>
		<!-- FILES -->
		<if condition="#attributes.kind# NEQ 'img' AND #attributes.kind# NEQ 'vid' AND #attributes.kind# NEQ 'aud' AND #attributes.kind# NEQ 'all'">
			<true>
				<!-- CFC: Get the total file count -->
				<invoke object="myFusebox.getApplicationData().folders" methodcall="filetotaltype(attributes)" returnvariable="qry_filecount" />
				<set name="attributes.qry_filecount" value="#qry_filecount.thetotal#" overwrite="false" />
				<!-- CFC: Get files -->
				<invoke object="myFusebox.getApplicationData().files" method="getFolderAssetDetails" returnvariable="attributes.qry_files">
					<argument name="folder_id" value="#attributes.folder_id#" />
					<argument name="columnlist" value="file_id id, file_extension ext, file_type, file_name filename, file_name_org filename_org, folder_id_r, link_kind, path_to_asset, cloud_url, cloud_url_org" />
					<argument name="file_extension" value="#attributes.kind#" />
					<argument name="offset" value="0" />
					<argument name="rowmaxpage" value="#qry_filecount.thetotal#" />
					<argument name="thestruct" value="#attributes#" />
				</invoke>
			</true>
		</if>
	</fuseaction>
	
	<!-- View: RSS -->
	<fuseaction name="view_rss">
		<!-- Call include -->
		<do action="view_includes" />
		<!-- Param -->
		<set name="attributes.thisview" value="rss" />
		<!-- Call queries include -->
		<do action="view_includes_queries" />
		<!-- CFC: Call VIEW -->
		<invoke object="myFusebox.getApplicationData().views" methodcall="rss(attributes)" returnvariable="theview" />
		<!-- Show -->
		<do action="ajax.views" />
	</fuseaction>
	
	<!-- View: Excel -->
	<fuseaction name="view_xls">
		<!-- Call include -->
		<do action="view_includes" />
		<!-- Param -->
		<set name="attributes.thisview" value="xls" />
		<!-- Call queries include -->
		<do action="view_includes_queries" />
		<!-- CFC: Call VIEW -->
		<invoke object="myFusebox.getApplicationData().views" methodcall="xls(attributes)" returnvariable="theview" />
		<!-- Show -->
		<do action="ajax.views" />
	</fuseaction>
	
	<!-- View: Doc -->
	<fuseaction name="view_doc">
		<!-- Call include -->
		<do action="view_includes" />
		<!-- Param -->
		<set name="attributes.thisview" value="doc" />
		<!-- Call queries include -->
		<do action="view_includes_queries" />
		<!-- CFC: Call VIEW -->
		<invoke object="myFusebox.getApplicationData().views" methodcall="doc(attributes)" returnvariable="theview" />
		<!-- Show -->
		<do action="ajax.views" />
	</fuseaction>
	
	
	<!--  -->
	<!-- VIEWS: STOP -->
	<!--  -->
	
	<!--  -->
	<!-- WIDGETS: START -->
	<!--  -->
	
	<!-- Initial View -->
	<fuseaction name="widgets">
		<!-- XFA -->
		<xfa name="remove" value="ajax.collections_del_item" />
		<!-- CFC: Query Widgets -->
		<invoke object="myFusebox.getApplicationData().widgets" methodcall="getwidgets(attributes)" returnvariable="qry_widgets" />
		<!-- Show -->
		<do action="ajax.widgets" />
	</fuseaction>
	<!-- Add/Edit Widget -->
	<fuseaction name="widget_detail">
		<!-- CFC: Query Widgets -->
		<invoke object="myFusebox.getApplicationData().widgets" methodcall="detail(attributes)" returnvariable="qry_widget" />
		<!-- Show -->
		<do action="ajax.widget_detail" />
	</fuseaction>
	<!-- Update Widget -->
	<fuseaction name="widget_update">
		<!-- CFC: Query Widgets -->
		<invoke object="myFusebox.getApplicationData().widgets" methodcall="update(attributes)" />
	</fuseaction>
	<!-- External call: Get the widget -->
	<fuseaction name="w">
		<!-- Params -->
		<set name="attributes.external" value="T" />
		<set name="session.widget_id" value="#attributes.wid#" />
		<set name="attributes.widget_id" value="#session.widget_id#" />
		<set name="attributes.shared" value="T" />
		<set name="attributes.perm_password" value="F" />
		<set name="session.theuserid" value="0" overwrite="false" />
		<set name="attributes.qry_news.news_title" value="" overwrite="false" />
		<set name="attributes.qry_news.news_text" value="" overwrite="false" />
		<set name="session.widget_login" value="F" />
		<!-- XFA -->
		<xfa name="switchlang" value="c.switchlang" />
		<!-- CFC: Get languages -->
		<do action="languages" />
		<!-- Get how the widget is being shared -->
		<invoke object="myFusebox.getApplicationData().widgets" methodcall="detail(attributes)" returnvariable="qry_widget" />
		<!-- Set folder ID -->
		<if condition="qry_widget.col_id_r EQ ''">
			<true>
				<set name="session.fid" value="#qry_widget.folder_id_r#" />
				<set name="attributes.fid" value="#qry_widget.folder_id_r#" />
				<set name="session.iscol" value="F" />
			</true>
			<false>
				<set name="session.fid" value="1" />
				<set name="attributes.fid" value="1" />
				<set name="session.iscol" value="T" />
			</false>
		</if>
		<!-- Permission: Public -->
		<if condition="qry_widget.widget_permission EQ 'f'">
			<true>
				<set name="session.widget_login" value="T" />
				<do action="w_content" />
			</true>
		</if>
		<!-- Permission: Password protected -->
		<if condition="qry_widget.widget_permission EQ 'p'">
			<true>
				<xfa name="submitform" value="c.w_login_password" />
				<set name="attributes.perm_password" value="T" />
				<do action="v.share_login" />
			</true>
		</if>
		<!-- Permission: Group protected -->
		<if condition="qry_widget.widget_permission EQ 'g'">
			<true>
				<xfa name="submitform" value="c.w_login" />
				<do action="v.share_login" />
			</true>
		</if>
	</fuseaction>
	<!-- External call: Widget PRoxy -->
	<fuseaction name="w_proxy">
		<relocate url="#variables.thehttp##cgi.http_host##myself#c.w_content&amp;wid=#session.widget_id#" />
	</fuseaction>
	<!-- External call: Get content -->
	<fuseaction name="w_content">
		<if condition="NOT structkeyexists(session,'widget_login')">
			<true>
				<relocate url="#variables.thehttp##cgi.http_host##myself#c.w&amp;wid=#attributes.wid#" />
			</true>
		</if>
		<!-- If this fuse is called directly then redirect to the w -->
		<if condition="cgi.query_string CONTAINS 'w_content' AND session.widget_login NEQ 'T'">
			<true>
				<relocate url="#variables.thehttp##cgi.http_host##myself#c.w&amp;wid=#attributes.wid#" />
			</true>
		</if>
		<if condition="NOT structkeyexists(session,'widget_id') OR session.widget_id EQ '' OR session.widget_id EQ 0">
			<true>
				<relocate url="#variables.thehttp##cgi.http_host##myself#v.share_login&amp;shared=F" />
			</true>
		</if>
		<!-- set host again with real value -->
		<invoke object="myFusebox.getApplicationData().security" methodcall="initUser(Session.hostid,0,'adm')" returnvariable="Request.securityobj" />
		<!-- Params -->
		<set name="attributes.external" value="t" />
		<set name="attributes.widget_id" value="#session.widget_id#" />
		<set name="attributes.wid" value="#session.widget_id#" />
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- CFC: Get languages -->
		<do action="languages" />
		<!-- Action: Set view -->
		<do action="set_view" />
		<!-- CFC: Query Widget -->
		<invoke object="myFusebox.getApplicationData().widgets" methodcall="detail(attributes)" returnvariable="qry_widget" />
		<set name="attributes.folder_id" value="#qry_widget.folder_id_r#" />
		<set name="attributes.fid" value="#qry_widget.folder_id_r#" />
		<!-- Depending if there is a collection or not we call the content -->
		<if condition="#session.iscol# EQ 'F'">
			<true>
				<!-- if the folder_id_r is in the URL scope  -->
				<if condition="structkeyexists(url,'folder_id_r')">
					<true>
						<set name="attributes.folder_id" value="#url.folder_id#" />
						<!-- CFC: Get Breadcrumb -->
						<invoke object="myFusebox.getApplicationData().folders" methodcall="getbreadcrumb(url.folder_id_r)" returnvariable="qry_breadcrumb" />
					</true>
				</if>
				<!-- CFC: Get folder share options -->
				<invoke object="myFusebox.getApplicationData().folders" methodcall="getfolderproperties(attributes.folder_id)" returnvariable="qry_folder" />
				<!-- CFC: Get subfolders -->
				<invoke object="myFusebox.getApplicationData().folders" methodcall="getsubfolders(attributes.folder_id,attributes.external)" returnvariable="qry_subfolders" />
				<!-- CFC: Get the total file count -->
				<invoke object="myFusebox.getApplicationData().folders" methodcall="filetotalcount(attributes.folder_id)" returnvariable="qry.qry_filecount" />
				<set name="attributes.qry_filecount" value="#qry.qry_filecount.thetotal#" overwrite="false" />
				<!-- CFC: Get all assets -->
				<invoke object="myFusebox.getApplicationData().folders" methodcall="getallassets(attributes)" returnvariable="qry.qry_files" />
			</true>
			<false>
				<!-- Param -->
				<set name="attributes.col_id" value="#qry_widget.col_id_r#" />
				<set name="attributes.share" value="T" />
				<!-- CFC: Get assets of Collections -->
				<invoke object="myFusebox.getApplicationData().collections" methodcall="get_assets(attributes)" returnvariable="attributes.qry_files" />
				<!-- CFC: Query the assets -->
				<invoke object="myFusebox.getApplicationData().collections" methodcall="getallassets(attributes)" returnvariable="qry" />
			</false>
		</if>
		<!-- Show -->
		<do action="ajax.widget_iframe" />
	</fuseaction>
	<!-- Download asset from widget -->
	<fuseaction name="widget_download">
		<!-- Set fileid into session for upload -->
		<set name="attributes.widget_download" value="true" />
		<!-- Get link to assets for downloading -->
		<if condition="attributes.kind EQ 'img'">
			<true>
				<invoke object="myFusebox.getApplicationData().images" methodcall="detail(attributes)" returnvariable="attributes.qry_detail" />
				<invoke object="myFusebox.getApplicationData().images" methodcall="relatedimages(attributes)" returnvariable="attributes.qry_related" />
			</true>
		</if>
		<if condition="attributes.kind EQ 'vid'">
			<true>
				<invoke object="myFusebox.getApplicationData().videos" methodcall="detail(attributes)" returnvariable="attributes.qry_detail" />
				<invoke object="myFusebox.getApplicationData().videos" methodcall="relatedvideos(attributes)" returnvariable="attributes.qry_related" />
			</true>
		</if>
		<if condition="attributes.kind EQ 'aud'">
			<true>
				<invoke object="myFusebox.getApplicationData().audios" methodcall="detail(attributes)" returnvariable="attributes.qry_detail" />
				<invoke object="myFusebox.getApplicationData().audios" methodcall="relatedaudios(attributes)" returnvariable="attributes.qry_related" />
			</true>
		</if>
		<!-- CFC: Get individual share options -->
		<invoke object="myFusebox.getApplicationData().global" methodcall="get_share_options(attributes)" returnvariable="qry_share_options" />
		<!-- Show -->
		<do action="ajax.widget_download" />
	</fuseaction>
	<!-- Widget Remove -->
	<fuseaction name="widget_remove">
		<invoke object="myFusebox.getApplicationData().widgets" methodcall="widget_remove(attributes)" />
		<!-- Show -->
		<do action="widgets" />
	</fuseaction>
	<!-- External call: Login with password only -->
	<fuseaction name="w_login_password">
		<set name="attributes.widget_id" value="#session.widget_id#" />
		<set name="session.fid" value="#attributes.fid#" />
		<!-- CFC: Query for the correct password -->
		<invoke object="myFusebox.getApplicationData().widgets" methodcall="getpassword(attributes)" returnvariable="qry_wp" />
	</fuseaction>
	<!-- External call: Login -->
	<fuseaction name="w_login">
		<!-- Check the user and let him in ot nor -->
		<invoke object="myFusebox.getApplicationData().Login" method="login" returnvariable="logindone">
			<argument name="name" value="#attributes.name#" />
			<argument name="pass" value="#attributes.pass#" />
			<argument name="loginto" value="dam" />
			<argument name="from_share" value="t" />
		</invoke>
		<!-- User is found -->
		<if condition="logindone.notfound EQ 'F'">
    		<true>
				<!-- set host again with real value -->
				<invoke object="myFusebox.getApplicationData().security" methodcall="initUser(Session.hostid,logindone.qryuser.user_id,'adm')" returnvariable="Request.securityobj" />
				<!-- Folder id into session -->
				<set name="session.fid" value="#attributes.fid#" />
				<set name="session.widget_login" value="T" />
				<relocate url="#variables.thehttp##cgi.http_host##myself#c.w_content&amp;wid=#session.widget_id#" />
			</true>
			<!-- User not found -->
			<false>
				<!-- Param -->
		   		<set name="attributes.loginerror" value="T" />
				<set name="session.widget_login" value="F" />
				<!-- Show -->
				<!-- <do action="w" /> -->
				<relocate url="#variables.thehttp##cgi.http_host##myself#c.w&amp;wid=#attributes.wid#&amp;le=T" />
		   	</false>
		</if>
	</fuseaction>

	<!--  -->
	<!-- WIDGETS: STOP -->
	<!--  -->
	
	<!--  -->
	<!-- ADDITIONAL VERSIONS: START -->
	<!--  -->
	
	<!-- Initial View -->
	<fuseaction name="adi_versions">
		<!-- Set fileid into session for upload -->
		<set name="session.asset_id_r" value="#attributes.file_id#" />
		<!-- CFC: Get asset path -->
		<do action="assetpath" />
		<!-- CFC: Query Widgets -->
		<invoke object="myFusebox.getApplicationData().global" methodcall="get_versions_link(attributes)" returnvariable="qry_av" />
		<!-- Show -->
		<do action="ajax.adi_versions" />
	</fuseaction>
	<!-- Save -->
	<fuseaction name="adi_versions_add">
		<!-- CFC: Query Widgets -->
		<invoke object="myFusebox.getApplicationData().global" methodcall="save_add_versions_link(attributes)" />
		<!-- Show -->
		<do action="adi_versions" />
	</fuseaction>
	<!-- Remove Link -->
	<fuseaction name="av_link_remove">
		<!-- CFC: Query Widgets -->
		<invoke object="myFusebox.getApplicationData().global" methodcall="remove_av_link(attributes)" />
		<!-- Show -->
		<do action="adi_versions" />
	</fuseaction>
	<!-- Edit Link -->
	<fuseaction name="av_edit">
		<!-- CFC: Query Widgets -->
		<invoke object="myFusebox.getApplicationData().global" methodcall="getav(attributes)" returnvariable="qry_av" />
		<!-- Show -->
		<do action="ajax.av_edit" />
	</fuseaction>
	<!-- Update Link -->
	<fuseaction name="av_update">
		<!-- CFC: Query Widgets -->
		<invoke object="myFusebox.getApplicationData().global" methodcall="updateav(attributes)" />
	</fuseaction>
	<!-- Called from the detail pages -->
	<fuseaction name="av_load">
		<!-- CFC: Query Widgets -->
		<invoke object="myFusebox.getApplicationData().global" methodcall="get_versions_link(attributes)" returnvariable="qry_av" />
		<!-- Show -->
		<do action="ajax.av_load" />
	</fuseaction>
	
	<!--  -->
	<!-- ADDITIONAL VERSIONS: STOP -->
	<!--  -->
	
	<!--  -->
	<!-- FLUSHCACHE: START -->
	<!--  -->
	
	<fuseaction name="flushcache">
		<!-- Images -->
		<invoke object="myFusebox.getApplicationData().global" method="clearcache">
			<argument name="theaction" value="flushall" />
			<argument name="thedomain" value="#session.theuserid#_images" />
		</invoke>
		<!-- Videos -->
		<invoke object="myFusebox.getApplicationData().global" method="clearcache">
			<argument name="theaction" value="flushall" />
			<argument name="thedomain" value="#session.theuserid#_videos" />
		</invoke>
		<!-- Audios -->
		<invoke object="myFusebox.getApplicationData().global" method="clearcache">
			<argument name="theaction" value="flushall" />
			<argument name="thedomain" value="#session.theuserid#_audios" />
		</invoke>
		<!-- Files -->
		<invoke object="myFusebox.getApplicationData().global" method="clearcache">
			<argument name="theaction" value="flushall" />
			<argument name="thedomain" value="#session.theuserid#_files" />
		</invoke>
	</fuseaction>
	
	<!--  -->
	<!-- FLUSHCACHE: STOP -->
	<!--  -->
	
	<!--  -->
	<!-- MINI: START -->
	<!--  -->
	
	<!-- Initial action on calling the mini version -->
	<fuseaction name="mini">
		<!-- XFA -->
		<xfa name="submitform" value="c.mini_login_do" />
		<xfa name="forgotpass" value="c.forgotpass" />
		<xfa name="switchlang" value="c.switchlang" />
		<xfa name="req_access" value="c.req_access" />
		<!-- Params -->
		<set name="attributes.loginerror" value="F" overwrite="false" />
		<set name="attributes.passsend" value="F" overwrite="false" />
		<set name="attributes.sameuser" value="F" overwrite="false" />
		<if condition="#session.hostid# NEQ ''">
			<true>
				<!-- CFC: Check for collection -->
				<invoke object="myFusebox.getApplicationData().lucene" methodcall="exists()" />
				<!-- CFC: Get languages -->
				<do action="languages" />
			</true>
		</if>
		<!-- Show -->
		<do action="v.login_mini" />
	</fuseaction>
	<!-- Log this user in or not -->
	<fuseaction name="mini_login_do">
		<invoke object="myFusebox.getApplicationData().Login" methodcall="checkhost(attributes)" returnvariable="logindone" />
	</fuseaction>
	<!-- Call the mini browser -->
	<fuseaction name="mini_browser">
		<if condition="#session.login# EQ 'T'">
	 		<true>
	 			<!-- Param -->
	 			<set name="session.hosttype" value="" overwrite="false" />
				<set name="attributes.folder_id" value="0" overwrite="false" />
				<set name="attributes.file_id" value="0" overwrite="false" />
				<!-- For Nirvanix get usage count -->
				<if condition="application.razuna.storage EQ 'nirvanix' OR session.hosttype EQ 'f'">
					<true>
						<!-- Action: Check storage -->
						<do action="storage" />
						<invoke object="myFusebox.getApplicationData().Nirvanix" methodcall="GetAccountUsage(session.hostid,attributes.nvxsession)" returnvariable="attributes.nvxusage" />
					</true>
				</if>
				<!-- Action: Get asset path -->
				<do action="assetpath" />
				<!-- If this is a file request -->
				<if condition="attributes.file_id NEQ 0">
					<true>
						<!-- Action: Storage -->
						<do action="storage" />
						<!-- Get link to assets for downloading -->
						<if condition="attributes.kind EQ 'img'">
							<true>
								<invoke object="myFusebox.getApplicationData().images" methodcall="detail(attributes)" returnvariable="qry_detail" />
								<invoke object="myFusebox.getApplicationData().images" methodcall="relatedimages(attributes)" returnvariable="qry_related" />
							</true>
						</if>
						<if condition="attributes.kind EQ 'vid'">
							<true>
								<invoke object="myFusebox.getApplicationData().videos" methodcall="detail(attributes)" returnvariable="qry_detail" />
								<invoke object="myFusebox.getApplicationData().videos" methodcall="relatedvideos(attributes)" returnvariable="qry_related" />
							</true>
						</if>
						<if condition="attributes.kind EQ 'aud'">
							<true>
								<invoke object="myFusebox.getApplicationData().audios" methodcall="detail(attributes)" returnvariable="qry_detail" />
								<invoke object="myFusebox.getApplicationData().audios" methodcall="relatedaudios(attributes)" returnvariable="qry_related" />
							</true>
						</if>
					</true>
					<false>
						<!-- CFC: Get folder properties -->
						<invoke object="myFusebox.getApplicationData().folders" methodcall="getfolderproperties(attributes.folder_id)" returnvariable="qry_folder" />
						<!-- CFC: Set Access -->
						<invoke object="myFusebox.getApplicationData().folders" methodcall="setaccess(attributes.folder_id)" returnvariable="qry_foldername" />
						<!-- CFC: Get the total file count -->
						<invoke object="myFusebox.getApplicationData().folders" methodcall="filetotalcount(attributes.folder_id)" returnvariable="qry_filecount" />
						<set name="attributes.qry_filecount" value="#qry_filecount.thetotal#" overwrite="false" />
						<!-- CFC: Get subfolders -->
						<invoke object="myFusebox.getApplicationData().folders" methodcall="getsubfolders(attributes.folder_id)" returnvariable="qry_subfolders" />
						<!-- CFC: Get all assets -->
						<invoke object="myFusebox.getApplicationData().folders" methodcall="getallassets(attributes)" returnvariable="qry_files" />
					</false>
				</if>
				
				<!-- Get View -->
				<do action="v.mini_browser" />
			</true>
			<false>
				 <do action="mini" />
			</false>
		</if>
	</fuseaction>
	<!-- Mini Logoff -->
	<fuseaction name="mini_logoff">
		<if condition="structkeyexists(session,'theuserid') AND session.theuserid NEQ ''">
			<true>
				<!-- CFC: User info for log -->
				<set name="attributes.user_id" value="#session.theuserid#" />
				<invoke object="myFusebox.getApplicationData().users" methodcall="details(attributes)" returnvariable="theuser" />
				<!-- Log -->
				<invoke object="myFusebox.getApplicationData().log" method="log_users">
					<argument name="theuserid" value="#session.theuserid#" />
					<argument name="logaction" value="Logout" />
					<argument name="logsection" value="DAM" />
		 			<argument name="logdesc" value="Logout: UserID: #session.theuserid# eMail: #theuser.user_email# First Name: #theuser.user_first_name# Last Name: #theuser.user_last_name#" />
				</invoke>
			</true>
		</if>
		<set name="session.login" value="F" />
		<set name="session.weblogin" value="F" />
		<set name="session.thegroupofuser" value="" />
		<set name="session.theuserid" value="" />
		<set name="session.thedomainid" value="" />
		<do action="mini" />
	</fuseaction>
	
	<!--  -->
	<!-- MINI: STOP -->
	<!--  -->
	
	<!--  -->
	<!-- LABELS: START -->
	<!--  -->
	
	<!-- Load the label explorer -->
	<fuseaction name="labels_list">
		<!-- CFC -->
		<invoke object="myFusebox.getApplicationData().labels" methodcall="labels(attributes)" returnvariable="qry_labels" />
		<!-- Show -->
		<do action="ajax.labels" />
	</fuseaction>
	<!-- Update labels of the item -->
	<fuseaction name="label_update">
		<!-- CFC -->
		<invoke object="myFusebox.getApplicationData().labels" methodcall="label_update(attributes)" />
	</fuseaction>
	<!-- Remove labels of the item -->
	<fuseaction name="label_remove">
		<!-- CFC -->
		<invoke object="myFusebox.getApplicationData().labels" methodcall="label_remove(attributes)" />
	</fuseaction>
	<!-- Update label for all -->
	<fuseaction name="label_add_all">
		<!-- CFC -->
		<invoke object="myFusebox.getApplicationData().labels" methodcall="label_add_all(attributes)" />
	</fuseaction>
	<!-- Label MAIN (Load Label tabs) -->
	<fuseaction name="labels_main">
		<!-- CFC: count how many label types there are -->
		<invoke object="myFusebox.getApplicationData().labels" methodcall="labels_count(attributes.label_id)" returnvariable="qry_labels_count" />
		<!-- Show -->
		<do action="ajax.labels_main" />
	</fuseaction>
	<!-- Label MAIN: Get assets -->
	<fuseaction name="labels_main_assets">
		<!-- XFA -->
		<xfa name="detaildoc" value="c.files_detail" />
		<xfa name="detailimg" value="c.images_detail" />
		<xfa name="detailvid" value="c.videos_detail" />
		<xfa name="detailaud" value="c.audios_detail" />
		<!-- Param -->
		<set name="kind" value="all" />
		<set name="url.kind" value="all" />
		<set name="url.folder_id" value="0" />
		<set name="attributes.folder_id" value="0" />
		<set name="attributes.showsubfolders" value="#session.showsubfolders#" overwrite="false" />
		<set name="session.showsubfolders" value="#attributes.showsubfolders#" />
		<set name="attributes.view" value="" overwrite="false" />
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- CFC: get label text -->
		<invoke object="myFusebox.getApplicationData().labels" methodcall="getlabeltext(attributes.label_id)" returnvariable="qry_labels_text" />
		<!-- CFC: count how many label types there are -->
		<invoke object="myFusebox.getApplicationData().labels" methodcall="labels_assets(attributes.label_id, attributes.label_kind)" returnvariable="qry_labels_assets" />
		<!-- Show -->
		<do action="ajax.labels_main_assets" />
	</fuseaction>
	<!-- Label MAIN: Get folders -->
	<fuseaction name="labels_main_folders">
		<!-- CFC: get label text -->
		<invoke object="myFusebox.getApplicationData().labels" methodcall="getlabeltext(attributes.label_id)" returnvariable="qry_labels_text" />
		<!-- CFC: count how many label types there are -->
		<invoke object="myFusebox.getApplicationData().labels" methodcall="labels_assets(attributes.label_id, attributes.label_kind)" returnvariable="qry_labels_folders" />
		<!-- Show -->
		<do action="ajax.labels_main_folders" />
	</fuseaction>
	<!-- Label MAIN: Get collections -->
	<fuseaction name="labels_main_collections">
		<!-- CFC: get label text -->
		<invoke object="myFusebox.getApplicationData().labels" methodcall="getlabeltext(attributes.label_id)" returnvariable="qry_labels_text" />
		<!-- CFC: count how many label types there are -->
		<invoke object="myFusebox.getApplicationData().labels" methodcall="labels_assets(attributes.label_id, attributes.label_kind)" returnvariable="qry_labels_collections" />
		<!-- Show -->
		<do action="ajax.labels_main_collections" />
	</fuseaction>
	
	<!--  -->
	<!-- LABELS: STOP -->
	<!--  -->
	
	<!--  -->
	<!-- RFS: START -->
	<!--  -->
	
	<!-- Pick up asset from rfs -->
	<fuseaction name="rfs">
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- CFC -->
		<invoke object="myFusebox.getApplicationData().rfs" methodcall="pickup(attributes)" />
	</fuseaction>
	
	<!--  -->
	<!-- RFS: STOP -->
	<!--  -->
	
	<!--  -->
	<!-- EXPORT METADATA: START -->
	<!--  -->
	
	<!-- Export -->
	<fuseaction name="meta_export">
		<!-- Param -->
		<set name="attributes.what" value="" overwrite="false" />
		<set name="attributes.folder_id" value="" overwrite="false" />
		<!-- Show -->
		<do action="ajax.meta_export" />
	</fuseaction>
	<!-- Export DO -->
	<fuseaction name="meta_export_do">
		<!-- Param -->
		<set name="attributes.thepath" value="#thispath#" />
		<!-- CFC -->
		<invoke object="myFusebox.getApplicationData().xmp" methodcall="meta_export(attributes)" />
	</fuseaction>
	
	<!--  -->
	<!-- EXPORT METADATA: STOP -->
	<!--  -->
	
	<!--  -->
	<!-- IMPORT METADATA: START -->
	<!--  -->
	
	<!-- Import show window -->
	<fuseaction name="meta_imp">
		<!-- Param -->
		<set name="attributes.tempid" value="#replace(createuuid(),'-','','all')#" />
		<!-- CFC -->
		<invoke object="myFusebox.getApplicationData().import" methodcall="getTemplates(false)" returnvariable="qry_imptemp" />
		<!-- Show -->
		<do action="ajax.meta_imp" />
	</fuseaction>
	<!-- Upload file -->
	<fuseaction name="meta_imp_upload_do">
		<!-- CFC -->
		<invoke object="myFusebox.getApplicationData().import" methodcall="upload(attributes)" />
	</fuseaction>
	<!-- Import DO -->
	<fuseaction name="meta_imp_do">
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- CFC -->
		<invoke object="myFusebox.getApplicationData().import" methodcall="doimport(attributes)" />
	</fuseaction>
	
	
	<!--  -->
	<!-- IMPORT METADATA: STOP -->
	<!--  -->
	
	<!-- Store Art values -->
	<fuseaction name="store_art_values">
		<set name="session.artofimage" value="#attributes.artofimage#" />
		<set name="session.artofvideo" value="#attributes.artofvideo#" />
		<set name="session.artofaudio" value="#attributes.artofaudio#" />
		<set name="session.artoffile" value="#attributes.artoffile#" />
	</fuseaction>
	
	<!-- Store fileids and filetypes in session (takes care for more then 75 assets at once -->
	<fuseaction name="store_file_values">
		<!-- Params -->
		<set name="attributes.file_id" value="" overwrite="false" />
		<set name="attributes.thetype" value="" overwrite="false" />
		<!-- Set session -->
		<set name="session.file_id" value="#attributes.file_id#" />
		<set name="session.thefileid" value="#attributes.file_id#" />
		<set name="session.thetype" value="#attributes.thetype#" />
	</fuseaction>
	
	<!-- Set view and maxpage and offset -->
	<fuseaction name="set_view">
		<!-- Set the rowmaxpage -->
		<if condition="structkeyexists(attributes,'rowmaxpage')">
			<true>
				<set name="session.rowmaxpage" value="#attributes.rowmaxpage#" />
			</true>
		</if>
		<!-- Set the offset -->
		<if condition="structkeyexists(attributes,'offset')">
			<true>
				<set name="session.offset" value="#attributes.offset#" />
			</true>
		</if>
		<!-- Set the view -->
		<if condition="structkeyexists(attributes,'view')">
			<true>
				<if condition="#attributes.view# EQ ''">
					<true>
						<set name="session.view" value="" />
						<set name="attributes.view" value="" />
					</true>
				</if>
				<if condition="#attributes.view# EQ 'list'">
					<true>
						<set name="session.view" value="list" />
						<set name="attributes.view" value="list" />
					</true>
				</if>
				<if condition="#attributes.view# EQ 'combined'">
					<true>
						<set name="session.view" value="combined" />
						<set name="attributes.view" value="combined" />
					</true>
				</if>
			</true>
		</if>
	</fuseaction>
	
	<!-- Set offset for log -->
	<fuseaction name="set_offset_admin">
		<!-- Set the offset -->
		<if condition="structkeyexists(attributes,'offset_log')">
			<true>
				<set name="session.offset_log" value="#attributes.offset_log#" />
			</true>
		</if>
		
	</fuseaction>
	
</circuit>
