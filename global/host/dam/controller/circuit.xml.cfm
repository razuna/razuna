<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE circuit>

<circuit access="public" xmlns:cf="cf/">

	<!-- Cache Tag for layouts -->
	<fuseaction name="cachetag">
		<set name="attributes.cachetag" value="2014.08.05.1" />
	</fuseaction> 
	
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
		<set name="attributes.shared" value="F" overwrite="false" />
		<set name="attributes.fid" value="0" overwrite="false" />
		<set name="attributes.wid" value="0" overwrite="false" />
		<set name="jr_enable" value="false" overwrite="false" />
		<if condition="session.hostid NEQ ''">
			<true>
				<!-- CFC: Get languages -->
				<do action="languages" />
				<!-- Check for JanRain -->
				<invoke object="myFusebox.getApplicationData().Settings" methodcall="thissetting('janrain_enable')" returnvariable="jr_enable" />
				<invoke object="myFusebox.getApplicationData().Settings" methodcall="thissetting('janrain_appurl')" returnvariable="jr_url" />
			</true>
		</if>
		<!-- news -->
		<if condition="cgi.http_host CONTAINS 'razuna.com'">
			<true>
				<set name="attributes.frontpage" value="true" />
				<invoke object="myFusebox.getApplicationData().settings" methodcall="news_get(attributes)" returnvariable="attributes.qry_news" />
			</true>
		</if>
		<!-- Get the Cache tag -->
		<do action="cachetag" />
		<!-- CFC: Get customization -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="get_customization()" returnvariable="cs" />
		<!-- Show -->
		<do action="v.login" />
	</fuseaction>
	<!--
		Check the login, write a log entry and let the user in or not
	-->
	<fuseaction name="dologin">
		<!-- Params -->
		<set name="attributes.rem_login" value="F" overwrite="false" />
		<set name="attributes.redirectto" value="" overwrite="false" />
		<set name="attributes.loginto" value="dam" overwrite="false" />
		<set name="session.indebt" value="false" />
		<!-- Get AD server Deatils -->
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="thissetting('ad_server_name')" returnvariable="attributes.ad_server_name" />
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="thissetting('ad_server_port')" returnvariable="attributes.ad_server_port" />
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="thissetting('ad_server_filter')" returnvariable="attributes.ad_server_filter" />
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="thissetting('ad_server_start')" returnvariable="attributes.ad_server_start" />
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="thissetting('ad_server_secure')" returnvariable="attributes.ad_server_secure" />
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="thissetting('ad_ldap')" returnvariable="attributes.ad_ldap" />
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="thissetting('ad_domain')" returnvariable="attributes.ad_domain" />
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="thissetting('ldap_dn')" returnvariable="attributes.ldap_dn" />

		<!-- Check the user and let him in ot nor -->
		<invoke object="myFusebox.getApplicationData().Login" methodcall="login(attributes)" returnvariable="logindone" />
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
				<!-- <invoke object="myFusebox.getApplicationData().groups" methodcall="getdetail('SystemAdmin')" />
				<invoke object="myFusebox.getApplicationData().groups" methodcall="getdetail('Administrator')" /> -->
				<!-- <invoke object="myFusebox.getApplicationData().groups_users" method="getGroupsOfUser">
					<argument name="user_id" value="#logindone.qryuser.user_id#" />
					<argument name="host_id" value="#Session.hostid#" />
				</invoke> -->
				<!-- CFC: Check for collection -->
				<!-- <invoke object="myFusebox.getApplicationData().lucene" methodcall="exists()" /> -->
				<!-- set host again with real value -->
				<invoke object="myFusebox.getApplicationData().security" methodcall="initUser(Session.hostid,logindone.qryuser.user_id,'adm')" returnvariable="Request.securityobj" />
				<!-- Redirect request -->
				<if condition="attributes.redirectto NEQ ''">
					<true>
						<relocate url="#session.thehttp##cgi.http_host##myself##attributes.redirectto#&amp;_v=#createuuid('')#" />
					</true>
				</if>
				<!-- TL = Transparent login. In other words this action is called directly -->
				<if condition="structkeyexists(attributes,'tl')">
					<true>
						<relocate url="#session.thehttp##cgi.http_host##myself#c.main&amp;_v=#createuuid('')#" />
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
						<relocate url="#session.thehttp##cgi.http_host##myself#c.logout&amp;loginerror=T" />
					</true>
				</if>
		   		<!-- <do action="login" /> -->
		   	</false>
		</if>
	</fuseaction>
	
	<!-- Login: Janrain -->
	<fuseaction name="login_janrain">
		<!-- Params -->
		<set name="session.indebt" value="false" />
		<!-- Get Janrain API key -->
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="thissetting('janrain_apikey')" returnvariable="attributes.jr_apikey" />
		<!-- CFC -->
		<invoke object="myFusebox.getApplicationData().Login" methodcall="login_janrain(attributes)" returnvariable="loginstatus" />
		<!-- Let user in -->
		<if condition="loginstatus NEQ 0">
    		<true>
    			<!-- If this is NOT for a share -->
    			<if condition="attributes.shared EQ 'F'">
    				<true>
						<!-- Log -->
						<invoke object="myFusebox.getApplicationData().log" method="log_users">
							<argument name="theuserid" value="#loginstatus#" />
							<argument name="logaction" value="Login" />
							<argument name="logsection" value="DAM" />
		    				<argument name="logdesc" value="Login: User-ID: #loginstatus# with Janrain" />
						</invoke>
						<!-- check groups -->
						<invoke object="myFusebox.getApplicationData().groups" methodcall="getdetail('SystemAdmin')" />
						<invoke object="myFusebox.getApplicationData().groups" methodcall="getdetail('Administrator')" />
						<invoke object="myFusebox.getApplicationData().groups_users" method="getGroupsOfUser">
							<argument name="user_id" value="#loginstatus#" />
							<argument name="host_id" value="#Session.hostid#" />
						</invoke>
						<!-- CFC: Check for collection -->
						<!-- <invoke object="myFusebox.getApplicationData().lucene" methodcall="exists()" /> -->
						<!-- set host again with real value -->
						<invoke object="myFusebox.getApplicationData().security" methodcall="initUser(Session.hostid,loginstatus,'adm')" returnvariable="Request.securityobj" />
						<!-- Relocate -->
						<relocate url="#session.thehttp##cgi.http_host##myself#c.main&amp;_v=#createuuid('')#" />
					</true>
					<!-- This is for shared login -->
					<false>
						<!-- set host again with real value -->
						<invoke object="myFusebox.getApplicationData().security" methodcall="initUser(Session.hostid,loginstatus,'adm')" returnvariable="Request.securityobj" />
						<!-- Folder id into session -->
						<set name="session.fid" value="#attributes.fid#" />
						<!-- Only for the shared folder -->
						<if condition="attributes.wid EQ 0">
							<true>
								<!-- CFC: Check if user is allowed for this folder -->
								<invoke object="myFusebox.getApplicationData().folders" methodcall="sharecheckpermfolder(session.fid)" />
								<!-- Relocate -->
								<relocate url="#session.thehttp##cgi.http_host##myself#c.sharep&amp;fid=#attributes.fid#&amp;_v=#createuuid('')#" />
							</true>
							<false>
								<set name="session.widget_login" value="T" />
								<relocate url="#session.thehttp##cgi.http_host##myself#c.w_content&amp;wid=#attributes.wid#&amp;_v=#createuuid('')#" />
							</false>
						</if>
					</false>
				</if>
			</true>
			<false>
				<if condition="attributes.shared EQ 'F'">
    				<true>
						<!-- Log -->
						<invoke object="myFusebox.getApplicationData().log" method="log_users">
							<argument name="theuserid" value="0" />
							<argument name="logaction" value="Error" />
							<argument name="logsection" value="DAM" />
		    				<argument name="logdesc" value="Login Error for user: #loginstatus# with Janrain" />
						</invoke>
				   		<set name="attributes.loginerror" value="T" />
				   		<!-- Relocate -->
				   		<relocate url="#session.thehttp##cgi.http_host##myself#c.logout&amp;loginerror=T" />
				   	</true>
				   	<!-- This is for shared login -->
					<false>
						<!-- Param -->
				   		<set name="attributes.loginerror" value="T" />
						<!-- Only for the shared folder -->
						<if condition="attributes.wid EQ 0">
							<true>
								<!-- Relocate -->
								<relocate url="#session.thehttp##cgi.http_host##myself#c.share&amp;le=t&amp;fid=#attributes.fid#&amp;_v=#createuuid('')#" />
							</true>
							<false>
								<!-- Param -->
								<set name="session.widget_login" value="F" />
								<!-- Relocate -->
								<relocate url="#session.thehttp##cgi.http_host##myself#c.w&amp;wid=#attributes.wid#&amp;le=T&amp;_v=#createuuid('')#" />
							</false>
						</if>
					</false>
				</if>
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
	 	<!-- Params -->
	 	<!-- Set bucket -->
		<set name="attributes.akaurl" value="" overwrite="false" />
		<set name="attributes.akaimg" value="" overwrite="false" />
		<set name="attributes.akavid" value="" overwrite="false" />
		<set name="attributes.akaaud" value="" overwrite="false" />
		<set name="attributes.akadoc" value="" overwrite="false" />
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
				<set name="attributes.set2_img_format" value="#qry_storage.set2_img_format#" />
			</true>
		</if>
		<if condition="application.razuna.storage EQ 'akamai'">
			<true>
				<!-- query -->
				<invoke object="myFusebox.getApplicationData().settings" methodcall="prefs_storage()" returnvariable="qry_storage" />
				<!-- Set bucket -->
				<set name="attributes.akaurl" value="#qry_storage.set2_aka_url#" />
				<set name="attributes.akaimg" value="#qry_storage.set2_aka_img#" />
				<set name="attributes.akavid" value="#qry_storage.set2_aka_vid#" />
				<set name="attributes.akaaud" value="#qry_storage.set2_aka_aud#" />
				<set name="attributes.akadoc" value="#qry_storage.set2_aka_doc#" />
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
		<invoke object="myFusebox.getApplicationData().labels" methodcall="labels_dropdown()" returnvariable="qry_labels" />
		<!-- Set as attributes also -->
		<!-- <set name="attributes.thelabels" value="#qry_labels.l#" /> -->
		<set name="attributes.thelabelsqry" value="#qry_labels#" />
	</fuseaction>
	
	<!--
		For the main layout queries and settings
	 -->
	 <fuseaction name="main">
	 	<if condition="#session.login# EQ 'T'">
	 		<true>
	 			<!-- Param -->
	 			<set name="session.hosttype" value="" overwrite="false" />
	 			<set name="attributes.redirectmain" value="false" overwrite="false" />
	 			<!-- Set that we are in custom view -->
				<set name="session.customview" value="false" />
	 			<!-- For Nirvanix get usage count -->
				<!-- <if condition="application.razuna.storage EQ 'nirvanix'">
					<true>
						<do action="storage" />
						<invoke object="myFusebox.getApplicationData().Nirvanix" methodcall="GetAccountUsage(session.hostid,attributes.nvxsession)" returnvariable="attributes.nvxusage" />
					</true>
				</if> -->
	 			<!-- If ISP (for now) -->
				<if condition="cgi.http_host CONTAINS 'razuna.com'">
					<true>
						<!-- Get News -->
						<invoke object="myFusebox.getApplicationData().settings" methodcall="news_get(attributes)" returnvariable="attributes.qry_news" />
						<!-- Get Invoices -->
						<invoke object="myFusebox.getApplicationData().global" methodcall="getaccount(session.hostid)" returnvariable="res_account" />
					</true>
				</if>
				<!-- WL -->
				<if condition="application.razuna.whitelabel">
					<true>
						<!-- Get main static text -->
						<invoke object="myFusebox.getApplicationData().settings" methodcall="get_options_one_host('wl_main_static_#session.hostid#')" returnvariable="attributes.wl_main_static" />
						<!-- Show updates -->
						<invoke object="myFusebox.getApplicationData().settings" methodcall="get_options_one_host('wl_show_updates_#session.hostid#')" returnvariable="attributes.wl_show_updates" />
						<!-- Get rss -->
						<invoke object="myFusebox.getApplicationData().settings" methodcall="get_options_one_host('wl_news_rss_#session.hostid#')" returnvariable="attributes.wl_news_rss" />
						<!-- If rss is empty -->
						<if condition="attributes.wl_news_rss EQ ''">
							<true>
								<invoke object="myFusebox.getApplicationData().settings" methodcall="get_news_host()" returnvariable="attributes.qry_news" />
							</true>
							<false>
								<invoke object="myFusebox.getApplicationData().rssparser" methodcall="rssparse(attributes.wl_news_rss,7)" returnvariable="attributes.qry_news" />
							</false>
						</if>
						<!-- Most Recently added assets -->
						<if condition="structkeyexists(attributes,'wl_show_updates') AND attributes.wl_show_updates EQ 'true'">
							<true>
								<!-- Params -->
								<set name="attributes.logswhat" value="log_assets" />
								<set name="attributes.is_dashboard_update" value="yes" />
								<!-- CFC: Get log -->
								<invoke object="myFusebox.getApplicationData().log" methodcall="get_log_assets(attributes)" returnvariable="attributes.qry_log" />
				  			</true>
				  		</if>
		  			</true>
		  		</if>
				<!-- CFC: Get languages -->
				<do action="languages" />
				<!-- CFC: Custom fields -->
				<invoke object="myFusebox.getApplicationData().custom_fields" methodcall="getfieldssearch(attributes)" returnvariable="qry_cf_fields" />
				<!-- CFC: Get Wisdom phrases -->
				<!-- <invoke object="myFusebox.getApplicationData().Global" methodcall="wisdom()" returnvariable="wisdom" /> -->
				<!-- CFC: Get Orders of this user -->
				<invoke object="myFusebox.getApplicationData().basket" methodcall="get_orders()" returnvariable="qry_orders" />
				<!-- CFC: Get customization -->
				<invoke object="myFusebox.getApplicationData().settings" methodcall="get_customization()" returnvariable="cs" />
				<!-- CFC: Get config -->
				<invoke object="myFusebox.getApplicationData().settings" methodcall="getconfig('prerelease')" returnvariable="prerelease" />
				<!-- CFC: Get settings -->
				<invoke object="myFusebox.getApplicationData().settings" methodcall="getsettingsfromdam()" returnvariable="prefs" />
				<!-- CFC: Get plugin actions -->
				<invoke object="myFusebox.getApplicationData().plugins" methodcall="getactions('on_main_page',attributes)" returnvariable="pl" />
				<!-- CFC: Get Access Control Settings -->
				<invoke object="myFusebox.getApplicationData().settings" methodcall="getaccesscontrol()" returnvariable="access_struct" />
				<!-- CFC: Get Access Control Settings -->
				<invoke object="myFusebox.getApplicationData().settings" methodcall="getuseraccesscontrols(access_struct)" returnvariable="tabaccess_struct" />
				<!-- Get user groups  -->
				<invoke object="myFusebox.getApplicationData().groups_users" method="getredirectfolders" returnvariable="redirectfolders" />
				<!-- Get the Cache tag -->
				<do action="cachetag" />
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
		<set name="attributes.aduser" value="F" overwrite="false" />
		<!-- Check the email address of the user -->
		<invoke object="myFusebox.getApplicationData().Login" methodcall="sendpassword(attributes.email)" returnvariable="status" />
		<!-- If the user is found an email has been sent thus return to the main layout with a message -->
		<if condition="status.notfound EQ 'F'">
			<true>
				<!-- Check the user is AD user -->
				<if condition="status.aduser EQ 'T'">
					<true>
						<set name="attributes.aduser" value="T" />
					</true>
					<false>
						<set name="attributes.passsend" value="T" />
					</false>
				</if>
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
		<!-- XFA -->
		<xfa name="submitform" value="c.req_access_send" />
		<xfa name="linkback" value="c.login" />
		<!-- CFC: Check for custom fields -->
		<set name="attributes.cf_show" value="users" />
		<set name="attributes.cf_in_form" value="true" />
		<set name="attributes.file_id" value="0" />
		<set name="session.theuserid" value="0" />
		<set name="session.thegroupofuser" value="0" />
		<invoke object="myFusebox.getApplicationData().custom_fields" methodcall="getfields(attributes)" returnvariable="qry_cf" />	
		<!-- CFC: Customization -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="get_customization()" returnvariable="cs" />
		<!-- Show -->
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
		<if condition="status NEQ 0">
			<true>
				<!-- Check if there are custom fields to be saved -->
				<if condition="attributes.customfields NEQ 0">
					<true>
						<set name="attributes.file_id" value="#status#" />
						<do action="custom_fields_save" />
					</true>
				</if>
				<!-- Send out the email -->
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
		<!-- Param -->
		<set name="attributes.to" value="" overwrite="false" />
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
		<set name="session.thegroupofuser" value="0" />
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
	
	<!-- Get Path to Assets -->
	<fuseaction name="watermark">
		<!-- CFC: get templates -->
		<invoke object="myFusebox.getApplicationData().global" methodcall="getwmtemplates(true)" returnvariable="attributes.wmtemplates" />
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
		<set name="session.showmyfolder" value="F" overwrite="false" />
		<set name="session.type" value="" />
		<if condition="structkeyexists(attributes,'showmyfolder')">
			<true>
				<set name="session.showmyfolder" value="#attributes.showmyfolder#" />
			</true>
		</if>
		<!-- XFA -->
		<xfa name="folder" value="c.folder" />
		<xfa name="foldernew" value="c.folder_new" />
		<xfa name="collections" value="c.collections" />
		<!-- CFC: Get customization -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="get_customization()" returnvariable="cs" />
		<!-- Show -->
		<do action="ajax.explorer" />
	</fuseaction>
	
	<!-- Load Explorer -->
	<fuseaction name="explorer_col">
		<!-- XFA -->
		<xfa name="foldernew" value="c.folder_new" />
		<xfa name="collections" value="c.collections" />
		<!-- CFC: Get customization -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="get_customization()" returnvariable="cs" />
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
	
	<fuseaction name="searchforcopymetadata">
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
 	<!-- Load Trash Folder-->
    <fuseaction name="folder_explorer_trash">
    	<!-- Param -->
		<set name="attributes.trashall" value="false" overwrite="false" />
		<set name="attributes.restoreall" value="false" overwrite="false" />
		<set name="attributes.removeselecteditems" value="false" overwrite="false" />
		<!-- Set the offset -->
		<if condition="structkeyexists(attributes,'offset')" >
			<true>
				<set name="session.trash_offset" value="#attributes.offset#" />
				<set name="session.trash_folder_offset" value="#attributes.offset#" />
			</true>
		</if>
		<!-- Set the rowmaxpage -->
		<if condition="structkeyexists(attributes,'rowmaxpage')">
			<true>
				<set name="session.trash_rowmaxpage" value="#attributes.rowmaxpage#" />
				<set name="session.trash_folder_rowmaxpage" value="#attributes.rowmaxpage#" />
			</true>
			<false>
				<set name="session.trash_rowmaxpage" value="25" />
				<set name="session.trash_folder_rowmaxpage" value="25" />
			</false>
		</if>
		<!-- Remove folders-->
		<if condition="structkeyexists(attributes,'selected') AND attributes.selected EQ 'folders'">
			<true>
				<set name="attributes.removeselecteditems" value="true" />
				<!-- Execute remove -->
				<do action="trashfolders_remove" />
			</true>
		</if>
		<!-- Remove assets -->
		<if condition="structkeyexists(attributes,'selected') AND attributes.selected EQ 'assets'">
			<true>
				<set name="attributes.removeselecteditems" value="true" />
				<!-- Execute remove -->
				<do action="trashfiles_remove" />
			</true>
		</if>
		
		<!-- Param -->
		<set name="session.file_id" value="" />
		<!-- CFC -->
		<!-- trash assets count -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="trashcount(attributes)" returnvariable="file_trash_count" />
		<!-- trash folder count-->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="folderTrashCount(attributes)" returnvariable="folder_trash_count" />
		<!-- Show -->
		<do action="ajax.folder_trash" />
	</fuseaction>
	
	<!-- This loads all files in trash -->
	<fuseaction name="trash_assets">
		<!-- Params -->
		<set name="attributes.offset" value="#session.trash_offset#" overwrite="false" />
		<set name="session.file_id" value="" overwrite="false" />
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- Set the offset -->
		<if condition="structkeyexists(attributes,'offset')">
			<true>
				<set name="session.trash_offset" value="#attributes.offset#" />
			</true>
			<false>
				<set name="session.trash_offset" value="0" />
			</false>
		</if>
		<!-- Set the rowmaxpage -->
		<if condition="structkeyexists(attributes,'rowmaxpage')">
			<true>
				<set name="session.trash_rowmaxpage" value="#attributes.rowmaxpage#" />
			</true>
		</if>
		<!--Path-->
		<set name="attributes.showsubfolders" value="#session.showsubfolders#" overwrite="false" />
		<!-- Call include in order ot get all files -->
		<do action="get_all_in_trash" />
		<!-- Show -->
		<do action="ajax.trash_assets" />
	</fuseaction>
	
	<!-- This loads all files in trash -->
	<fuseaction name="trash_remove_all">
		<!-- Param -->
		<set name="attributes.type" value="#session.type#" />
		<set name="attributes.trashall" value="true" />
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- Action: Check storage -->
		<do action="storage" />
		<!-- Decide on files or collection -->
		<if condition="!attributes.col">
			<!-- Files -->
			<true>
				<!-- Call include in order to get all files in trash -->
				<do action="get_all_in_trash" />
				<!-- CFC: Remove all -->
				<invoke object="myFusebox.getApplicationData().folders" methodcall="trash_remove_all(qry_trash,attributes)" />
				<!-- Show -->
				<do action="folder_explorer_trash" />
			</true>
			<false>
				<!-- CFC: Get all for collection trash -->
				<invoke object="myFusebox.getApplicationData().collections" methodcall="trash_remove_all(attributes)" />
				<!-- Show -->
				<do action="collection_explorer_trash" />
			</false>
		</if>
	</fuseaction>
	
	<!-- Remove the selected files in trash-->
	<fuseaction name="trashfiles_remove">
		<!-- Param -->
	    	<set name="attributes.hostid" value="#session.hostid#" />
	    	<set name="attributes.id" value="#session.file_id#" />
		<set name="attributes.trashkind" value="assets" />
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- CFC: Remove the selected trash files -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="trashfiles_remove(attributes)" />
		<!-- Show -->
		<!--<do action="trash_assets" />-->
	</fuseaction>
	
	<!-- This loads all files in trash -->
	<fuseaction name="trash_restore_all">
		<!-- Param -->
		<set name="session.type" value="#attributes.type#" />
		<!-- Show the choose folder -->
		<do action="choose_folder" />
	</fuseaction>
	
	<!-- Restore all files in trash -->
	<fuseaction name="restore_allfile_do">
		<!-- Param -->
		<set name="attributes.file_id" value="#session.file_id#" />
		<set name="attributes.thispath" value="#thispath#" />
		<set name="attributes.hostid" value="#session.hostid#" />
		<set name="attributes.restoreall" value="true" />
		<set name="attributes.loaddiv" value="content" />
		<set name="session.trash" value="F" />
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- Action: Storage -->
		<do action="storage" />
		<!-- Call include in order to get all files in trash -->
		<do action="get_all_in_trash_noread" />
		<!-- CFC: Restore all -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="trash_restore_all(qry_trash,attributes)" />
		<!-- Show -->
		<do action="folder_explorer_trash" />
	</fuseaction>
	
	<!-- Restore selected files -->
	<fuseaction name="restore_selected_files">
		<!-- Param -->
		<set name="session.type" value="#attributes.type#" />
		<set name="attributes.fromtrash" value="true" />
		<set name="attributes.loaddiv" value="assets" />
		<!-- Show the choose folder -->
		<do action="choose_folder" />
	</fuseaction>
	<!-- Restore selected files -->
	<fuseaction name="restore_selected_files_do">
		<!-- Param -->
	    	<set name="attributes.hostid" value="#session.hostid#" />
	    	<set name="attributes.id" value="#session.file_id#" />
		<set name="attributes.trashkind" value="assets" />
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- Action: Storage -->
		<do action="storage" />
		<!-- CFC: Restore files-->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="restoreselectedfiles(attributes)" />
		<!-- Show -->
		<!-- <do action="folder_explorer_trash" /> -->
	</fuseaction>
	<!-- Include for getting all files and folders in trash -->
	<fuseaction name="get_all_in_trash">
		<!--CFC: Get trash images-->
		<invoke object="myFusebox.getApplicationData().images" methodcall="gettrashimage()" returnvariable="attributes.imagetrash" />
		<!-- CFC: Get trash audios -->
		<invoke object="myFusebox.getApplicationData().audios" methodcall="gettrashaudio()" returnvariable="attributes.audiotrash" />
		<!-- CFC: Get trash files-->
		<invoke object="myFusebox.getApplicationData().files" methodcall="gettrashfile()" returnvariable="attributes.filetrash" />
		<!-- CFC: Get trash videos-->
		<invoke object="myFusebox.getApplicationData().videos" methodcall="gettrashvideos()" returnvariable="attributes.videotrash" />
		<!-- Combine queries above -->
		<invoke object="myFusebox.getApplicationData().folders" method="gettrashcombined" returnvariable="qry_trash">
			<argument name="qry_images" value="#attributes.imagetrash#" />
			<argument name="qry_audios" value="#attributes.audiotrash#" />
			<argument name="qry_files" value="#attributes.filetrash#" />
			<argument name="qry_videos" value="#attributes.videotrash#" />
		</invoke>
	</fuseaction>
	
		<!-- Include for getting all files and folders in trash -->
	<fuseaction name="get_all_in_trash_noread">
		<!--CFC: Get trash images-->
		<invoke object="myFusebox.getApplicationData().images" methodcall="gettrashimage(noread=true)" returnvariable="attributes.imagetrash" />
		<!-- CFC: Get trash audios -->
		<invoke object="myFusebox.getApplicationData().audios" methodcall="gettrashaudio(noread=true)" returnvariable="attributes.audiotrash" />
		<!-- CFC: Get trash files-->
		<invoke object="myFusebox.getApplicationData().files" methodcall="gettrashfile(noread=true)" returnvariable="attributes.filetrash" />
		<!-- CFC: Get trash videos-->
		<invoke object="myFusebox.getApplicationData().videos" methodcall="gettrashvideos(noread=true)" returnvariable="attributes.videotrash" />
		<!-- Combine queries above -->
		<invoke object="myFusebox.getApplicationData().folders" method="gettrashcombined" returnvariable="qry_trash">
			<argument name="qry_images" value="#attributes.imagetrash#" />
			<argument name="qry_audios" value="#attributes.audiotrash#" />
			<argument name="qry_files" value="#attributes.filetrash#" />
			<argument name="qry_videos" value="#attributes.videotrash#" />
		</invoke>
	</fuseaction>

	<!-- Include the trash folders-->
	<fuseaction name="trash_folders">
		<!--CFC: Get trash folder-->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="gettrashfolder()" returnvariable="qry_trash" />
	</fuseaction>

	<!-- Include the trash folders-->
	<fuseaction name="trash_folders_noread">
		<!--CFC: Get trash folder-->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="gettrashfolder(noread=true)" returnvariable="qry_trash" />
	</fuseaction>
	
	<!-- Loads all folders in trash-->
	<fuseaction name="trash_folder_all">
		<!-- Params -->
		<set name="attributes.offset" value="#session.trash_folder_offset#" overwrite="false" />
		<!-- Set the page -->
		<if condition="!structkeyexists(attributes,'page')">
			<true>
				<set name="session.file_id" value=""  />
			</true>
		</if>	
		<!-- Set the offset -->
		<if condition="structkeyexists(attributes,'offset')">
			<true>
				<set name="session.trash_folder_offset" value="#attributes.offset#" />
			</true>
			<false>
				<set name="session.trash_folder_offset" value="0" />
			</false>
		</if>
		<!-- Set the rowmaxpage -->
		<if condition="structkeyexists(attributes,'rowmaxpage')">
			<true>
				<set name="session.trash_folder_rowmaxpage" value="#attributes.rowmaxpage#" />
			</true>
		</if>
		<!--Path-->
		<set name="attributes.showsubfolders" value="#session.showsubfolders#" overwrite="false" />
		<!-- Call include in order to get all folders in trash -->
		<do action="trash_folders" />
		<!-- Show -->
		<do action="ajax.trash_folder_all" />
	</fuseaction>
	
	<!-- This loads all folders in trash -->
	<fuseaction name="trash_remove_folder">
		<!-- Param -->
		<set name="attributes.trashall" value="true" />
		<!-- Action: Check storage -->
		<do action="storage" />
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- Decide on files or collection -->
		<if condition="!attributes.col">
			<!-- Files -->
			<true>
				<!-- Call include in order to get all folders in trash -->
				<do action="trash_folders" />
				<!-- CFC: Remove all -->
				<invoke object="myFusebox.getApplicationData().folders" methodcall="trash_remove_folder(qry_trash,attributes)" />
				<!-- Show -->
				<do action="folder_explorer_trash" />
			</true>
			<false>
				<!-- CFC: Get all for collection trash -->
				<invoke object="myFusebox.getApplicationData().collections" methodcall="trash_remove_folder(attributes)" />
				<!-- Show -->
				<do action="collection_explorer_trash" />
			</false>
		</if>
	</fuseaction>
	
	<!-- Remove selected folders in the trash-->
	<fuseaction name="trashfolders_remove">
		<!-- Param -->
	    	<set name="attributes.hostid" value="#session.hostid#" />
	    	<set name="attributes.id" value="#session.file_id#" />
		<set name="attributes.trashkind" value="folders" />
		<!-- Action: Check storage -->
		<do action="storage" />
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- CFC: Remove the selected trash folder -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="trashfolders_remove(attributes)" />
		<!-- Show -->
		<!--<do action="trash_folder_all" />-->
	</fuseaction>
		
	<!-- Restore all folders in the trash -->
	<fuseaction name="trash_restore_folders">
		<!-- Param -->
		<set name="session.type" value="#attributes.type#" />
		<!-- Show the choose folder -->
		<do action="choose_folder" />
	</fuseaction>
	
	<!-- This loads all folders in trash -->
	<fuseaction name="folder_restore">
		<!-- Param -->
		<set name="attributes.type" value="restorefolder" />
		<set name="attributes.fromtrash" value="true" />
		<set name="session.type" value="#attributes.type#" />
		<!-- Put folder id into session if the attribute exsists -->
		<set name="session.thefolderorg" value="#attributes.folder_id#" />
		<!-- If we move a folder -->
		<set name="session.thefolderorglevel" value="#attributes.folder_level#" />
		<!-- Show the choose folder -->
		<do action="choose_folder" />
	</fuseaction>
	
	<!-- Restore folders in trash-->
	<fuseaction name="restore_folder_do">
		<!-- Param -->
		<set name="attributes.thispath" value="#thispath#" />
		<set name="attributes.hostid" value="#session.hostid#" />
		<set name="attributes.trashkind" value="folders" />
		<set name="attributes.tomovefolderid" value="#session.thefolderorg#" />
		<set name="session.trash" value="F" />
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- Action: Storage -->
		<do action="storage" />
		<!-- CFC: Restore Folder -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="restorefolder(attributes)" />
		<!-- Show -->
		<!--<do action="folder_explorer_trash" />-->
		<do action="trash_folder_all" />
	</fuseaction>
	
	<!-- Restore selected folders in the trash-->
	<fuseaction name="restore_selected_folders">
		<!-- Param -->
		<set name="session.type" value="#attributes.type#" />
		<!-- Show the choose folder -->
		<do action="choose_folder" />
	</fuseaction>
	
	<!-- Restore selected folders in the trash-->
	<fuseaction name="restore_selected_folders_do">
		<!-- Param -->
    	<set name="attributes.hostid" value="#session.hostid#" />
    	<set name="attributes.id" value="#session.file_id#" />
		<set name="attributes.trashkind" value="folders" />
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- Action: Storage -->
		<do action="storage" />
		<!-- CFC: Restore files-->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="restoreselectedfolders(attributes)" />
		<!-- Show -->
		<!--<do action="trash_folder_all" />-->
		<do action="folder_explorer_trash" />
	</fuseaction>
	
	<!-- Restore all folders in trash -->
	<fuseaction name="restore_allfolder_do">
		<!-- Param -->
		<set name="attributes.thispath" value="#thispath#" />
		<set name="attributes.hostid" value="#session.hostid#" />
		<set name="attributes.trashkind" value="folders" />
		<set name="attributes.restoreall" value="true" />
		<set name="session.trash" value="F" />
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- Action: Storage -->
		<do action="storage" />
		<!-- Call include in order to get all files in trash -->
		<do action="trash_folders_noread" />
		<!-- CFC: Restore all -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="trash_restore_folders(qry_trash,attributes)" />
		<!-- Show -->
		<do action="folder_explorer_trash" />
	</fuseaction>
	
	
	<!-- Incl-->
	
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
		<!-- CFC: Get settings -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="prefs_dam()" returnvariable="attributes.prefs" />
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
		<if condition="attributes.fromshare EQ 'T'">
			<true>
				<!-- CFC: Get folder or collection share options -->
				<if condition="isdefined('session.iscol') AND session.iscol EQ 'F'">
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
			</true>
		</if>
		<!-- CFC: Get Additional Versions -->
		<invoke object="myFusebox.getApplicationData().basket" methodcall="additional_versions()" returnvariable="qry_addition_version" />
		<!-- CFC: Get individual share options -->
		<invoke object="myFusebox.getApplicationData().global" methodcall="get_share_options(attributes)" returnvariable="qry_share_options" />
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
		<!-- CFC: Get settings -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="prefs_dam()" returnvariable="attributes.prefs" />
		<!-- Load include -->
		<do action="basket_include" />
		<!-- Show -->
		<do action="ajax.basket" />
	</fuseaction>
	<!-- Load Basket Save window -->
	<fuseaction name="basket_save">
		<!-- CFC: Customization -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="get_customization()" returnvariable="cs" />		
		<!-- Show -->
		<do action="ajax.basket_save" />
	</fuseaction>
	<!-- Load full Basket -->
	<fuseaction name="basket_full">
		<!-- Param -->
		<set name="attributes.fromshare" value="F" overwrite="false" />
		<set name="qry_folder.share_dl_org" value="F" overwrite="false" />
		<set name="qry_folder.share_order" value="" overwrite="false" />
		<!-- CFC: Get settings -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="prefs_dam()" returnvariable="attributes.prefs" />
		<!-- CFC: Get Customization -->
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="get_customization()" returnvariable="qry_customization" />
		<!-- CFC: Get buckets -->
		<invoke object="myFusebox.getApplicationData().oauth" methodcall="check('aws_bucket_name')" returnvariable="qry_s3_buckets" />
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
		<set name="attributes.what" value="basket" overwrite="false" />
		<set name="attributes.format" value="csv" overwrite="false" />
		<set name="attributes.meta_export" value="T" overwrite="false" />
		<set name="attributes.exportname" value="basket_#randrange(1,10000)#" overwrite="false" />
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- Action: Storage -->
		<do action="storage" />
		<!-- Get DAM settings -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="getsettingsfromdam()" returnvariable="attributes.prefs" />
		<if condition="attributes.prefs.set2_meta_export EQ 't'">
			<true>
				<!-- Action: Export Metadata -->
				<do action="meta_export_do" />
			</true>
		</if>
		<!-- Get user groups  -->
		<invoke object="myFusebox.getApplicationData().groups_users" method="getGroupsOfUser" returnvariable="attributes.qry_GroupsOfUser" >
			<argument name="user_id" value="#session.theuserid#" />
			<argument name="host_id" value="#session.hostid#" />
			<argument name="check_upc_size" value="true" />
		</invoke>
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
		<!-- Put session into attributes -->
		<set name="attributes.artofimage" value="#session.artofimage#" />
		<set name="attributes.artofvideo" value="#session.artofvideo#" />
		<set name="attributes.artofaudio" value="#session.artofaudio#" />
		<set name="attributes.artoffile" value="#session.artoffile#" />
		<set name="attributes.hostid" value="#session.hostid#" />
		<!-- Params -->
		<set name="attributes.dynpath" value="#dynpath#" />
		<set name="attributes.pathoneup" value="#pathoneup#" />
		<set name="attributes.httphost" value="#cgi.http_host#" />
		<set name="attributes.noemail" value="true" />
		<set name="attributes.what" value="basket" overwrite="false" />
		<set name="attributes.format" value="csv" overwrite="false" />
		<set name="attributes.exportname" value="basket_#randrange(1,10000)#" overwrite="false" />
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- Action: Storage -->
		<do action="storage" />
		<!-- Get DAM settings -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="getsettingsfromdam()" returnvariable="attributes.prefs" />
		<if condition="attributes.prefs.set2_meta_export EQ 't'">
			<true>
				<!-- Action: Export Metadata -->
				<do action="meta_export_do" />
			</true>
		</if>
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
			<argument name="isbasket" value="T" />
		</invoke>
	</fuseaction>
	<!-- Basket FTP Form -->
	<fuseaction name="basket_ftp_form">
		<set name="session.ftp_server" value="" overwrite="false" />
		<set name="session.ftp_user" value="" overwrite="false" />
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
		<!-- Params -->
		<set name="attributes.dynpath" value="#dynpath#" />
		<set name="attributes.pathoneup" value="#pathoneup#" />
		<set name="attributes.hostid" value="#session.hostid#" />
		<set name="attributes.noemail" value="true" />
		<set name="attributes.what" value="basket" overwrite="false" />
		<set name="attributes.format" value="csv" overwrite="false" />
		<set name="attributes.meta_export" value="T" overwrite="false" />
		<set name="attributes.exportname" value="basket_#randrange(1,10000)#" overwrite="false" />
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- Action: Storage -->
		<do action="storage" />
		<!-- Get DAM settings -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="getsettingsfromdam()" returnvariable="attributes.prefs" />
		<if condition="attributes.prefs.set2_meta_export EQ 't'">
			<true>
				<!-- Action: Export Metadata -->
				<do action="meta_export_do" />
			</true>
		</if>
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
		<set name="attributes.what" value="basket" overwrite="false" />
		<set name="attributes.format" value="csv" overwrite="false" />
		<!-- Put session into attributes -->
		<set name="attributes.artofimage" value="#session.artofimage#" />
		<set name="attributes.artofvideo" value="#session.artofvideo#" />
		<set name="attributes.artofaudio" value="#session.artofaudio#" />
		<set name="attributes.artoffile" value="#session.artoffile#" />
		<!-- Preserve langcount attribute in langs as it is overwritten by asset_upload_server method  and is needed by savedesckey method afterwards -->
		<set name="attributes.langs" value="#attributes.langcount#" /> 
		<set name="attributes.exportname" value="basket_#randrange(1,10000)#" overwrite="false" />
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- Action: Storage -->
		<do action="storage" />
		<!-- Get DAM settings -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="getsettingsfromdam()" returnvariable="attributes.prefs" />
		<if condition="attributes.prefs.set2_meta_export EQ 't'">
			<true>
				<!-- Action: Export Metadata -->
				<do action="meta_export_do" />
			</true>
		</if>
		<!-- CFC: Get items and download to system -->
		<invoke object="myFusebox.getApplicationData().basket" methodcall="writebasket(attributes)" returnvariable="attributes.thefile" />
		<!-- Do the upload from server which will add the zip file from above -->
		<do action="asset_upload_server" />
		<!-- CFC: save description and keywords -->
		<invoke object="myFusebox.getApplicationData().basket" methodcall="savedesckey(attributes)" />
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
		<set name="attributes.released" value="false" overwrite="false" />
		<!-- XFA -->
		<xfa name="collectionslist" value="c.collections_list" />
		<!-- CFC: CleanID -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="cleanid(attributes.folder_id)" returnvariable="attributes.folder_id" />
		<!-- CFC: Get access to this folder -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="setaccess(attributes.folder_id)" returnvariable="attributes.folderaccess" />
		<!-- Show -->
		<do action="folder" />
	</fuseaction>
	<!-- Load Collections List -->
	<fuseaction name="collections_list">
		<!-- Param -->
		<set name="attributes.withfolder" value="T" />
		<set name="attributes.released" value="false" overwrite="false" />
		<!-- XFA -->
		<xfa name="collectiondetail" value="c.collection_detail" />
		<xfa name="trash" value="ajax.collections_trash_item" />
		<!-- CFC: Get languages -->
		<do action="languages" />
		<!-- CFC: Get access to this folder -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="setaccess(attributes.folder_id)" returnvariable="attributes.folderaccess" />
		<!-- CFC: Get folder info -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="getfolder(attributes.folder_id)" returnvariable="qry_folder" />
		<!-- CFC: Customization -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="get_customization()" returnvariable="cs" />
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
		<xfa name="trash" value="ajax.collections_trash_item" />
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
		<!-- CFC: Permissions of this Collection -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="setaccess(attributes.folder_id)" returnvariable="attributes.colaccess" />
		<!-- CFC: Get assets of Collections -->
		<invoke object="myFusebox.getApplicationData().collections" methodcall="get_assets(attributes)" returnvariable="qry_assets" />
		<!-- CFC: Get settings -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="prefs_dam()" returnvariable="attributes.prefs" />
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
		<!-- CFC: Customization -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="get_customization()" returnvariable="cs" />
		<!-- CFC: Get config -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="get_label_set()" returnvariable="qry_label_set" />
		<!-- CFC: Permissions of this Collection (we do this here at the end since other function also call the permissions) -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="setaccess(attributes.folder_id)" returnvariable="attributes.folderaccess" />
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
		<!-- Param-->
		<set name="attributes.trashkind" value="files" />
		<!-- CFC: Move collection item -->
		<invoke object="myFusebox.getApplicationData().collections" methodcall="removeitem(attributes)" />
		<!-- Show collection list -->
		<do action="collection_explorer_trash" />
	</fuseaction>
	<!-- Remove Collection -->
	<fuseaction name="col_remove">
		<!-- CFC: Move collection item -->
		<invoke object="myFusebox.getApplicationData().collections" methodcall="remove(attributes)" />
		<!-- Show trash collection -->
		<do action="col_get_trash" />
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
		<!-- CFC: Get access to this folder -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="setaccess(attributes.folder_id)" returnvariable="attributes.folderaccess" />
		<!-- CFC: Get Collection to choose from -->
		<invoke object="myFusebox.getApplicationData().collections" methodcall="getAll(session.thelangid,attributes)" returnvariable="qry_col_list" />
		<!-- Show collection list -->
		<do action="ajax.collection_chooser" />
	</fuseaction>
	<!-- Release Collection -->
	<fuseaction name="col_release">
		<!-- CFC -->
		<invoke object="myFusebox.getApplicationData().collections" methodcall="doRelease(attributes)" />
	</fuseaction>
	<!-- Copy Collection (show window) -->
	<fuseaction name="col_copy">
		<!-- CFC: Get languages -->
		<do action="languages" />
		<!-- Get labels -->
		<!-- <do action="labels" /> -->
		<!-- Get labels for this record -->
		<!-- <invoke object="myFusebox.getApplicationData().labels" methodcall="getlabels(attributes.col_id,'collection')" returnvariable="qry_labels" /> -->
		<!-- CFC: Get detail of Collections -->
		<invoke object="myFusebox.getApplicationData().collections" methodcall="details(attributes)" returnvariable="qry_detail" />
		<!-- Show -->
		<do action="ajax.col_copy" />
	</fuseaction>
	<!-- Copy Collection DO -->
	<fuseaction name="col_copy_do">
		<!-- CFC: Copy Collection -->
		<invoke object="myFusebox.getApplicationData().collections" methodcall="docopy(attributes)" />
	</fuseaction>
	
	<!--collection assets move to trash-->
	<fuseaction name="col_asset_move_trash">
		<!-- CFC:move collection asset to trash-->
		<invoke object="myFusebox.getApplicationData().collections" methodcall="col_asset_move_trash(attributes)" />
		<!-- Show -->
		<do action="collection_detail" />
	</fuseaction>
	
	<!-- Load Trash Collection-->
    <fuseaction name="collection_explorer_trash">
    	<!-- Param -->
		<set name="attributes.trashall" value="false" overwrite="false" />
		<set name="attributes.restoreall" value="false" overwrite="false" />
		<set name="attributes.removeselecteditems" value="false" overwrite="false" />
		<!-- Set the offset -->
		<if condition="structkeyexists(attributes,'offset')" >
			<true>
				<set name="session.col_trash_offset" value="#attributes.offset#" />
				<set name="session.col_trash_folder_offset" value="#attributes.offset#" />
				<set name="session.trash_collection_offset" value="#attributes.offset#" />
			</true>
		</if>
		<!-- Set the rowmaxpage -->
		<if condition="structkeyexists(attributes,'rowmaxpage')">
			<true>
				<set name="session.col_trash_rowmaxpage" value="#attributes.rowmaxpage#" />
				<set name="session.col_trash_folder_rowmaxpage" value="#attributes.rowmaxpage#" />
				<set name="session.trash_collection_rowmaxpage" value="#attributes.rowmaxpage#" />
			</true>
			<false>
				<set name="session.col_trash_rowmaxpage" value="25" />
				<set name="session.col_trash_folder_rowmaxpage" value="25" />
				<set name="session.trash_collection_rowmaxpage" value="25" />
			</false>
		</if>
		<!-- Remove files -->
		<if condition="structkeyexists(attributes,'selected') AND attributes.selected EQ 'files'">
			<true>
				<set name="attributes.removeselecteditems" value="true" />
				<!-- Execute remove -->
				<do action="col_selected_files_remove" />
			</true>
		</if>
		<!-- Remove folders -->
		<if condition="structkeyexists(attributes,'selected') AND attributes.selected EQ 'folders'">
			<true>
				<set name="attributes.removeselecteditems" value="true" />
				<!-- Execute remove -->
				<do action="selected_col_folder_remove" />
			</true>
		</if>
		<!-- Remove collections -->
		<if condition="structkeyexists(attributes,'selected') AND attributes.selected EQ 'collection'">
			<true>
				<set name="attributes.removeselecteditems" value="true" />
				<!-- Execute remove -->
				<do action="selected_collection_remove" />
			</true>
		</if>
		
		<!-- Param -->
		<set name="session.file_id" value="" />
    	<!-- XFA -->
    	<xfa name="ftrashcol" value="c.col_get_trash" />
		<!-- CFC:Get collection trash count collections-->
		<invoke object="myFusebox.getApplicationData().collections" methodcall="get_col_count()" returnvariable="col_count_trash" />
		<!-- CFC:Get folder trash count in collections-->
		<invoke object="myFusebox.getApplicationData().collections" methodcall="getCollectionFolderCount()" returnvariable="qry_folder_count" />
		<!-- CFC:Get file trash count collection-->
		<invoke object="myFusebox.getApplicationData().collections" methodcall="getCollectionFileCount()" returnvariable="qry_file_count" />
		<!-- Show -->
		<do action="ajax.collection_trash" />
	</fuseaction>
	
	<!--collection move to trash-->
	<fuseaction name="col_move_trash">
		<!-- CFC:move collection to trash-->
		<invoke object="myFusebox.getApplicationData().collections" methodcall="col_move_trash(attributes)" />
		<!-- Show -->
		<do action="collections" />
	</fuseaction>
	
	<!-- Load collection in the trash -->
	<fuseaction name="col_get_trash">
		<!-- Params -->
		<set name="attributes.offset" value="#session.trash_collection_offset#" overwrite="false" />
		<set name="attributes.showsubfolders" value="#session.showsubfolders#" overwrite="false" />
		<!-- Set the page -->
		<if condition="!structkeyexists(attributes,'page')">
			<true>
				<set name="session.file_id" value=""  />
			</true>
		</if>	
		<!-- Set the offset -->
		<if condition="structkeyexists(attributes,'offset')">
			<true>
				<set name="session.trash_collection_offset" value="#attributes.offset#" />
			</true>
			<false>
				<set name="session.trash_collection_offset" value="0" />
			</false>
		</if>
		<!-- Set the rowmaxpage -->
		<if condition="structkeyexists(attributes,'rowmaxpage')">
			<true>
				<set name="session.trash_collection_rowmaxpage" value="#attributes.rowmaxpage#" />
			</true>
		</if>
		<!-- CFC: Get all for collection trash -->
		<invoke object="myFusebox.getApplicationData().collections" methodcall="get_trash_collection()" returnvariable="qry_trash" />
		<!-- Show -->
		<do action="ajax.collection_item_trash" />
	</fuseaction>
	
	<!-- Load collection files in the trash -->
	<fuseaction name="get_collection_trash_files">
		<!-- Param -->
		<set name="attributes.showsubfolders" value="#session.showsubfolders#" overwrite="false" />
		<!-- Params -->
		<set name="attributes.offset" value="#session.col_trash_offset#" overwrite="false" />
		<set name="session.file_id" value="" overwrite="false" />
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- Set the offset -->
		<if condition="structkeyexists(attributes,'offset')">
			<true>
				<set name="session.col_trash_offset" value="#attributes.offset#" />
			</true>
			<false>
				<set name="session.col_trash_offset" value="0" />
			</false>
		</if>
		<!-- Set the rowmaxpage -->
		<if condition="structkeyexists(attributes,'rowmaxpage')">
			<true>
				<set name="session.col_trash_rowmaxpage" value="#attributes.rowmaxpage#" />
			</true>
		</if>
		<!-- CFC: Get all for collection trash -->
		<invoke object="myFusebox.getApplicationData().collections" methodcall="get_trash_files()" returnvariable="qry_trash" />
		<!-- Show -->
		<do action="ajax.col_file_trash" />
	</fuseaction>
	
	<!-- Load collection folders in the trash -->
	<fuseaction name="get_collection_trash_folders">
		<!-- Params -->
		<set name="attributes.offset" value="#session.col_trash_folder_offset#" overwrite="false" />
		<set name="attributes.showsubfolders" value="#session.showsubfolders#" overwrite="false" />
		<!-- Set the page -->
		<if condition="!structkeyexists(attributes,'page')">
			<true>
				<set name="session.file_id" value=""  />
			</true>
		</if>	
		<!-- Set the offset -->
		<if condition="structkeyexists(attributes,'offset')">
			<true>
				<set name="session.col_trash_folder_offset" value="#attributes.offset#" />
			</true>
			<false>
				<set name="session.col_trash_folder_offset" value="0" />
			</false>
		</if>
		<!-- Set the rowmaxpage -->
		<if condition="structkeyexists(attributes,'rowmaxpage')">
			<true>
				<set name="session.col_trash_folder_rowmaxpage" value="#attributes.rowmaxpage#" />
			</true>
		</if>
		<!-- CFC: Get all for collection trash -->
		<invoke object="myFusebox.getApplicationData().collections" methodcall="get_trash_folders()" returnvariable="qry_trash" />
		<!-- Show -->
		<do action="ajax.col_folder_trash" />
	</fuseaction>
	
	<!-- Remove all trash collection -->
	<fuseaction name="remove_collection_trash_all">
		<!-- param -->
		<set name="attributes.trashall" value="true" />
		<!-- CFC: Get all for collection trash -->
		<invoke object="myFusebox.getApplicationData().collections" methodcall="trash_remove_all(attributes)" />
		<!-- Show -->
		<do action="collection_explorer_trash" />
	</fuseaction>
	
	<!-- Restore Collections-->
	<fuseaction name="collection_file_restore">
		<!-- param -->
		<set name="attributes.trashkind" value="files" />
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- Action: Storage -->
		<do action="storage" />
		<!-- HTTP referer for workflow -->
		<set name="attributes.thispath" value="#thispath#" />
		<set name="attributes.comingfrom" value="#cgi.http_referer#" />
		<!-- CFC: Upload -->
		<invoke object="myFusebox.getApplicationData().collections" methodcall="restore_col_asset(attributes)" returnvariable="attributes.is_trash" />
		<set name="attributes.artofimage" value="" />
		<set name="attributes.artofaudio" value="" />
		<set name="attributes.artoffile" value="" />
		<set name="attributes.artofvideo" value="" />
		<set name="session.file_id" value="#attributes.file_id#" />
		<!-- show -->
		<do action="get_collection_trash_files" />
		
		<!-- <if condition="attributes.loaddiv NEQ ''">
			<true>
				<if condition="attributes.loaddiv EQ 'collection'">
					<true>
						<do action="col_get_trash" />
					</true>
					<false>
						<do action="folder_images" />
					</false>
				</if>
			</true>
		</if> -->
	</fuseaction>
	
	<!-- Restore all collection files in the trash -->
	<fuseaction name="restore_all_collection_files">
		<!-- param -->
		<set name="attributes.iscol" value="T" />
		<set name="session.type" value="#attributes.type#" />
		<!-- CFC:Get all collection files in the trash -->
		<invoke object="myFusebox.getApplicationData().collections" methodcall="restoreallcollectionfiles()"/>
		<!-- Show the choose folder -->
		<do action="choose_folder" />
	</fuseaction>
	
	<!--Restore all collection files-->
	<fuseaction name="restore_all_col_file_do">
		<!-- Param -->
		<set name="attributes.file_id" value="#session.file_id#" />
		<set name="attributes.restoreall" value="true" />
		<set name="attributes.trashkind" value="files" />
		<!-- CFC:Update collection ct files -->
		<invoke object="myFusebox.getApplicationData().collections" methodcall="restore_col_file(attributes)"/>	
		<!-- Show -->
		<do action="collection_explorer_trash" />
	</fuseaction>
	
	<!-- Restore choose collection -->
	<fuseaction name="restore_choose_collection">
		<!-- Param -->
		<set name="session.type" value="restore_collection_file" />
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
	
	<!-- Restore collection ct files-->	
	<fuseaction name="restore_col_file_do">
		<!-- Param -->
		<set name="attributes.file_id" value="#session.file_id#" />
		<!-- CFC:Update collection ct files -->
		<invoke object="myFusebox.getApplicationData().collections" methodcall="restoreasset(attributes)"/>
	</fuseaction>
	
	<!-- Restore collection -->
	<fuseaction name="collection_restore">
		<invoke object="myFusebox.getApplicationData().collections" methodcall="restore_collection(attributes)" returnvariable="attributes.is_trash" />
		<set name="attributes.artofimage" value="" />
		<set name="attributes.artofaudio" value="" />
		<set name="attributes.artoffile" value="" />
		<set name="attributes.artofvideo" value="" />
		<!-- Show collection trash -->
		<do action="col_get_trash" /> 
	</fuseaction>
	
	<!-- Check the folder to restore collection -->
	<fuseaction name="restore_trash_collection">
		<!-- Param -->
		<set name="session.type" value="restore_collection" />
		<set name="attributes.iscol" value="T" />
		<if condition="structkeyexists(attributes,'col_id')">
			<true>
				<set name="session.col_id" value="#attributes.col_id#" />
			</true>
		</if>
		<!-- Show the choose folder -->
		<do action="choose_folder" />
	</fuseaction>
	
	<!-- Restore collections-->
	<fuseaction name="restore_collection_do">
		<!-- Param -->
		<set name="attributes.col_id" value="#session.col_id#" />
		<!-- CFC:Update collection -->
		<invoke object="myFusebox.getApplicationData().collections" methodcall="restorecollection(attributes)"/>
		<!-- Show trash collection -->
		<!--<do action="col_get_trash" />-->
	</fuseaction>
	
	<!-- Restore all collections in the trash-->
	<fuseaction name="restore_all_collections">
		<!-- param -->
		<set name="session.type" value="#attributes.type#" />
		<set name="attributes.iscol" value="T" />
		<!-- CFC:Get all collection in the trash -->
		<invoke object="myFusebox.getApplicationData().collections" methodcall="restoreallcollections()"/>
		<!-- Show the choose folder -->
		<do action="choose_folder" />
	</fuseaction>
	
	<!-- Restore all collections in the trash-->
	<fuseaction name="restore_all_collections_do">
		<!-- Param -->
		<set name="attributes.col_id" value="#session.file_id#" />
		<set name="attributes.restoreall" value="true" />
		<!-- CFC:Update collection -->
		<invoke object="myFusebox.getApplicationData().collections" methodcall="restore_all_collections(attributes)"/>
		<!-- Show -->
		<do action="collection_explorer_trash" />
	</fuseaction>
	
	<!-- Restore collection folder in the trash-->
	<fuseaction name="restore_col_folder">
		<set name="session.type" value="#attributes.type#" />
		<set name="attributes.iscol" value="T" />
		<!-- Put folder id into session if the attribute exsists -->
		<set name="session.thefolderorg" value="#attributes.folder_id#" />
		<!-- If we move a folder -->
		<set name="session.thefolderorglevel" value="#attributes.folder_level#" />
		<!-- Show the choose folder -->
		<do action="choose_folder" />
	</fuseaction>
	
	<!-- Restore collection folder in the trash-->
	<fuseaction name="restore_col_folder_do">
		<!-- Param -->
		<set name="attributes.thispath" value="#thispath#" />
		<set name="attributes.hostid" value="#session.hostid#" />
		<set name="attributes.trashkind" value="folders" />
		<set name="attributes.tomovefolderid" value="#session.thefolderorg#" />
		<set name="session.trash" value="F" />
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- Action: Storage -->
		<do action="storage" />
		<!-- CFC: Restore Folder -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="restorefolder(attributes)" />
		<!-- show -->
		<do action="get_collection_trash_folders" />
	</fuseaction>
	
	<!-- Restore all collection folder in the trash-->
	<fuseaction name="restore_col_folder_all">
		<set name="session.type" value="#attributes.type#" />
		<set name="attributes.iscol" value="T" />
		<!-- Show the choose folder -->
		<do action="choose_folder" />
	</fuseaction>
	
	<fuseaction name="restore_col_folder_all_do">
		<!-- Param -->
		<set name="attributes.thispath" value="#thispath#" />
		<set name="attributes.hostid" value="#session.hostid#" />
		<set name="attributes.trashkind" value="folders" />
		<set name="attributes.restoreall" value="true"  />
		<set name="session.trash" value="F" />
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- Action: Storage -->
		<do action="storage" />
		<!-- Call include in order to get all files in trash -->
		<invoke object="myFusebox.getApplicationData().collections" methodcall="get_trash_folders(noread=true)" returnvariable="qry_trash" />
		<!-- CFC: Restore all folders -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="trash_restore_folders(qry_trash,attributes)" />
		<!-- Show -->
		<do action="collection_explorer_trash" />
	</fuseaction>
	
	<!--Restore selected collection files -->
	<fuseaction name="restore_selected_col_files">
		<set name="session.type" value="#attributes.type#" />
		<set name="attributes.iscol" value="T" />
		<!-- Show the choose folder -->
		<do action="choose_folder" />
	</fuseaction>
	
	<!--Restore selected collection files -->
	<fuseaction name="restore_selected_col_file_do">
		<!-- Param -->
		<set name="attributes.file_id" value="#session.file_id#" />
		<!-- CFC:Update collection ct files -->
		<invoke object="myFusebox.getApplicationData().collections" methodcall="restore_col_file(attributes)"/>
	</fuseaction>

	<!--Remove selected collection files in the trash -->
	<fuseaction name="col_selected_files_remove">
		<!-- Param -->
		<set name="attributes.trashkind" value="files" />
		<set name="attributes.file_id" value="#session.file_id#" />
		<!-- CFC:Remove selected collection files -->
		<invoke object="myFusebox.getApplicationData().collections" methodcall="remove_selected_col_files(attributes)"/>
		<!-- Show -->
		<!--<do action="collection_explorer_trash" />-->
	</fuseaction>
	
	<!--Restore selected collections -->
	<fuseaction name="restore_selected_collection">
		<!-- param -->
		<set name="session.type" value="#attributes.type#" />
		<set name="attributes.iscol" value="T" />
		<!-- Show the choose folder -->
		<do action="choose_folder" />
	</fuseaction>
	
	<!--Restore selected collections -->
	<fuseaction name="restore_selected_collections_do">
		<!-- Param -->
		<set name="attributes.col_id" value="#session.file_id#" />
		<!-- CFC:Update collection -->
		<invoke object="myFusebox.getApplicationData().collections" methodcall="restore_selected_collections(attributes)"/>
		<!-- Show -->
		<do action="col_get_trash" />
	</fuseaction>
	
	<!--Remove selected collections -->
	<fuseaction name="selected_collection_remove">
		<!-- Param -->
		<set name="attributes.col_id" value="#session.file_id#" />
		<!-- CFC:Remove selected collection -->
		<invoke object="myFusebox.getApplicationData().collections" methodcall="selected_collection_remove(attributes)"/>
		<!-- Show -->
		<!--<do action="col_get_trash" />-->
	</fuseaction>
	
	<!-- Restore selected collection folder-->
	<fuseaction name="restore_selected_col_folder">
		<set name="session.type" value="#attributes.type#" />
		<set name="attributes.iscol" value="T" />
		<!-- Show the choose folder -->
		<do action="choose_folder" />
	</fuseaction>
	
	<!-- Restore selected collection folder -->
	<fuseaction name="restore_selected_col_folder_do">
		<!-- Param -->
    	<set name="attributes.hostid" value="#session.hostid#" />
    	<set name="attributes.id" value="#session.file_id#" />
		<set name="attributes.trashkind" value="folders" />
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- Action: Storage -->
		<do action="storage" />
		<!-- CFC: Restore files-->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="restoreselectedfolders(attributes)" />
		<!-- show -->
		<do action="get_collection_trash_folders" />
	</fuseaction>
	
	<!-- Remove selected collection folder -->
	<fuseaction name="selected_col_folder_remove">
		<!-- Param -->
    	<set name="attributes.hostid" value="#session.hostid#" />
    	<set name="attributes.id" value="#session.file_id#" />
		<set name="attributes.trashkind" value="folders" />
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- Action: Storage -->
		<do action="storage" />
		<!-- CFC: Remove the selected trash folder -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="trashfolders_remove(attributes)" />
		<!-- show -->
		<!--<do action="get_collection_trash_folders" />-->
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
		<set name="attributes.trash" value="F" overwrite="false" />
		<set name="attributes.trashkind" value="assets" overwrite="false" />
		<if condition="structkeyexists(attributes,'showsubfolders')">
			<true>
				<set name="session.showsubfolders" value="#attributes.showsubfolders#" />
				<set name="attributes.showsubfolders" value="#session.showsubfolders#" />
			</true>
		</if>
		<!-- XFA -->
		<xfa name="fproperties" value="c.folder_edit" />
		<xfa name="fsharing" value="c.folder_sharing" />
		<xfa name="fcontent" value="c.folder_content" />
		<xfa name="ffiles" value="c.folder_files" />
		<xfa name="fimages" value="c.folder_images" />
		<xfa name="fvideos" value="c.folder_videos" />
		<xfa name="faudios" value="c.folder_audios" />
		<xfa name="assetadd" value="c.asset_add" />
		<xfa name="collectionslist" value="c.collections_list" />
		<!-- Reset session -->
		<set name="session.file_id" value="" />
		<set name="session.thefileid" value="" />
		<set name="session.trash" value="F" overwrite="false" /> 
		<if condition="!session.customview">
			<true>
				<set name="session.customaccess" value="" />
				<set name="session.customfileid" value="" />
			</true>
		</if>
		<!-- CFC: Permissions of this folder -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="setaccess(attributes.folder_id)" returnvariable="attributes.folderaccess" />
		<!-- CFC: Get the total of files count and kind of files -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="fileTotalAllTypes(attributes.folder_id, attributes.folderaccess)" returnvariable="qry_fileTotalAllTypes" />
		<!-- CFC: Customization -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="get_customization()" returnvariable="cs" />
		<!-- Show -->
		<if condition="session.trash EQ 'T'">
			<true>
				<set name="session.trash" value="F" />
				<do action="folder_explorer_trash" />
			</true>
			<false>
				<do action="ajax.folder" />
			</false>
		</if>
	</fuseaction>
	<!-- Check for the same folder name -->
	<fuseaction name="folder_namecheck">
		<!-- CFC: check for same name -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="samefoldernamecheck(attributes)" returnvariable="attributes.samefoldername" />
		<!-- Show -->
		<do action="ajax.folder_namecheck" />
	</fuseaction>
	<!-- Check for the same collection name -->
	<fuseaction name="collection_namecheck">
		<!-- CFC: check for same name -->
		<invoke object="myFusebox.getApplicationData().collections" methodcall="samecollectionnamecheck(attributes)" returnvariable="attributes.samecollectionname" />
		<!-- Show -->
		<do action="ajax.collection_namecheck" />
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
		<!-- CFC: Customization -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="get_customization()" returnvariable="cs" />
		<!-- Show -->
		<do action="folder_new" />
	</fuseaction>
	<!-- Load Folder Files -->
	<fuseaction name="folder_files">
		<!-- XFAs -->
		<xfa name="assetadd" value="c.asset_add" />
		<xfa name="assetdetail" value="c.files_detail" />
		<xfa name="sendemail" value="c.email_send" />
		<!-- Params -->
		<set name="attributes.showsubfolders" value="#session.showsubfolders#" overwrite="false" />
		<set name="session.showsubfolders" value="#attributes.showsubfolders#" />
		<set name="attributes.sortby" value="#session.sortby#" overwrite="false" />
		<set name="session.sortby" value="#attributes.sortby#" />
		<set name="attributes.issearch" value="false" overwrite="false" />
		<if condition="!structkeyexists(attributes,'offset')">
			<true>
				<set name="session.file_id" value="" />
				<set name="session.thefileid" value="#session.file_id#" />
			</true>
		</if>
		<!-- Action: Set view -->
		<do action="set_view" />
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- CFC: Customization -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="get_customization()" returnvariable="cs" />
		<set name="attributes.cs" value="#cs#" />
		<!-- CFC: Get placement for fields-->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="get_customization_placement(cs)" returnvariable="cs_place" />
		<set name="attributes.cs_place" value="#cs_place#" />
		<!-- CFC: Folder access -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="setaccess(attributes.folder_id)" returnvariable="attributes.folderaccess" />
		<!-- CFC: Get folder info -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="getfolder(attributes.folder_id)" returnvariable="qry_folder" />
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
		<!-- CFC: Get breadcrumb -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="getbreadcrumb(attributes.folder_id)" returnvariable="qry_breadcrumb" />
		<!-- Get labels -->
		<do action="labels" />
		<!-- CFC: Get plugin actions -->
		<set name="attributes.nameOfVariable" value="plwx" />
		<invoke object="myFusebox.getApplicationData().plugins" methodcall="getactions('show_in_folderview_select_wx',attributes)" returnvariable="plwx" />
		<!-- CFC: Get plugin actions -->
		<set name="attributes.nameOfVariable" value="plr" />
		<invoke object="myFusebox.getApplicationData().plugins" methodcall="getactions('show_in_folderview_select_r',attributes)" returnvariable="plr" />
		<!-- Show -->
		<do action="ajax.folder_files" />
	</fuseaction>
	<!-- Load Folder Images -->
	<fuseaction name="folder_images">
		<!-- XFA -->
		<xfa name="fimages" value="c.folder_images" />
		<xfa name="assetadd" value="c.asset_add" />
		<xfa name="assetdetail" value="c.images_detail" />
		<xfa name="sendemail" value="c.email_send" />
		<!-- Params -->
		<set name="attributes.showsubfolders" value="#session.showsubfolders#" overwrite="false" />
		<set name="session.showsubfolders" value="#attributes.showsubfolders#" />
		<set name="attributes.sortby" value="#session.sortby#" overwrite="false" />
		<set name="session.sortby" value="#attributes.sortby#" />
		<set name="attributes.issearch" value="false" overwrite="false" />
		<if condition="!structkeyexists(attributes,'offset')">
			<true>
				<set name="session.file_id" value="" />
				<set name="session.thefileid" value="#session.file_id#" />
			</true>
		</if>
		<!-- Action: Set view -->
		<do action="set_view" />
		<!-- CFC: Customization -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="get_customization()" returnvariable="cs" />
		<set name="attributes.cs" value="#cs#" />
		<!-- CFC: Get placement for fields-->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="get_customization_placement(cs)" returnvariable="cs_place" />
		<set name="attributes.cs_place" value="#cs_place#" />
		<!-- CFC: Get folder info -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="getfolder(attributes.folder_id)" returnvariable="qry_folder" />
		<!-- CFC: Get folder name -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="getfoldername(attributes.folder_id)" returnvariable="qry_foldername" />
		<!-- CFC: Get subfolders -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="getsubfolders(attributes.folder_id)" returnvariable="qry_subfolders" />
		<!-- CFC: Folder access -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="setaccess(attributes.folder_id)" returnvariable="attributes.folderaccess" />
		<!-- CFC: Get the total file count -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="filetotaltype(attributes)" returnvariable="qry_filecount" />
		<set name="attributes.qry_filecount" value="#qry_filecount.thetotal#" overwrite="false" />
		<!-- CFC: Get user name -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="getusername(attributes.folder_id)" returnvariable="qry_user" />
		<!-- CFC: Get images -->
		<invoke object="myFusebox.getApplicationData().images" method="getFolderAssetDetails" returnvariable="qry_files">
			<argument name="folder_id" value="#attributes.folder_id#" />
			<argument name="columnlist" value="i.img_id, i.img_filename, i.img_custom_id, i.img_create_date, i.img_change_date, i.img_create_time, i.img_change_time, i.folder_id_r, i.thumb_extension, i.link_kind, i.link_path_url, i.path_to_asset, i.is_available, i.cloud_url" />
			<argument name="offset" value="#session.offset#" />
			<argument name="rowmaxpage" value="#session.rowmaxpage#" />
			<argument name="thestruct" value="#attributes#" />
		</invoke>
		<!-- CFC: Get breadcrumb -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="getbreadcrumb(attributes.folder_id)" returnvariable="qry_breadcrumb" />
		<!-- Get labels -->
		<do action="labels" />
		<!-- CFC: Get plugin actions -->
		<set name="attributes.nameOfVariable" value="plwx" />
		<invoke object="myFusebox.getApplicationData().plugins" methodcall="getactions('show_in_folderview_select_wx',attributes)" returnvariable="plwx" />
		<!-- CFC: Get plugin actions -->
		<set name="attributes.nameOfVariable" value="plr" />
		<invoke object="myFusebox.getApplicationData().plugins" methodcall="getactions('show_in_folderview_select_r',attributes)" returnvariable="plr" />
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
		<xfa name="sendemail" value="c.email_send" />
		<!-- Params -->
		<set name="attributes.showsubfolders" value="#session.showsubfolders#" overwrite="false" />
		<set name="session.showsubfolders" value="#attributes.showsubfolders#" />
		<set name="attributes.sortby" value="#session.sortby#" overwrite="false" />
		<set name="session.sortby" value="#attributes.sortby#" />
		<set name="attributes.issearch" value="false" overwrite="false" />
		<if condition="!structkeyexists(attributes,'offset')">
			<true>
				<set name="session.file_id" value="" />
				<set name="session.thefileid" value="#session.file_id#" />
			</true>
		</if>
		<!-- Action: Set view -->
		<do action="set_view" />
		<!-- CFC: Customization -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="get_customization()" returnvariable="cs" />
		<set name="attributes.cs" value="#cs#" />
		<!-- CFC: Get placement for fields-->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="get_customization_placement(cs)" returnvariable="cs_place" />
		<set name="attributes.cs_place" value="#cs_place#" />
		<!-- CFC: Get folder info -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="getfolder(attributes.folder_id)" returnvariable="qry_folder" />
		<!-- CFC: Get folder name -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="getfoldername(attributes.folder_id)" returnvariable="qry_foldername" />
		<!-- CFC: Get subfolders -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="getsubfolders(attributes.folder_id)" returnvariable="qry_subfolders" />
		<!-- CFC: Folder access -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="setaccess(attributes.folder_id)" returnvariable="attributes.folderaccess" />
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
			<argument name="columnlist" value="v.vid_id, v.vid_filename, v.folder_id_r, v.vid_custom_id, v.vid_create_date, v.vid_change_date, v.vid_create_time, v.vid_change_time, v.vid_name_image, v.vid_extension, v.link_kind, v.path_to_asset, v.is_available, v.cloud_url" />
			<argument name="offset" value="#session.offset#" />
			<argument name="rowmaxpage" value="#session.rowmaxpage#" />
			<argument name="thestruct" value="#attributes#" />
		</invoke>
		<!-- CFC: Get breadcrumb -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="getbreadcrumb(attributes.folder_id)" returnvariable="qry_breadcrumb" />
		<!-- Get labels -->
		<do action="labels" />
		<!-- CFC: Get plugin actions -->
		<set name="attributes.nameOfVariable" value="plwx" />
		<invoke object="myFusebox.getApplicationData().plugins" methodcall="getactions('show_in_folderview_select_wx',attributes)" returnvariable="plwx" />
		<!-- CFC: Get plugin actions -->
		<set name="attributes.nameOfVariable" value="plr" />
		<invoke object="myFusebox.getApplicationData().plugins" methodcall="getactions('show_in_folderview_select_r',attributes)" returnvariable="plr" />
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
		<!-- Action: Check storage -->
		<set name="attributes.isbrowser" value="#session.isbrowser#" />
		<do action="storage" />
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
		<xfa name="sendemail" value="c.email_send" />
		<!-- Params -->
		<set name="attributes.showsubfolders" value="#session.showsubfolders#" overwrite="false" />
		<set name="session.showsubfolders" value="#attributes.showsubfolders#" />
		<set name="attributes.sortby" value="#session.sortby#" overwrite="false" />
		<set name="session.sortby" value="#attributes.sortby#" />
		<set name="attributes.issearch" value="false" overwrite="false" />
		<if condition="!structkeyexists(attributes,'offset')">
			<true>
				<set name="session.file_id" value="" />
				<set name="session.thefileid" value="#session.file_id#" />
			</true>
		</if>
		<!-- Action: Set view -->
		<do action="set_view" />
		<!-- CFC: Customization -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="get_customization()" returnvariable="cs" />
		<set name="attributes.cs" value="#cs#" />
		<!-- CFC: Get placement for fields-->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="get_customization_placement(cs)" returnvariable="cs_place" />
		<set name="attributes.cs_place" value="#cs_place#" />
		<!-- CFC: Get folder info -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="getfolder(attributes.folder_id)" returnvariable="qry_folder" />
		<!-- CFC: Get folder name -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="getfoldername(attributes.folder_id)" returnvariable="qry_foldername" />
		<!-- CFC: Get subfolders -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="getsubfolders(attributes.folder_id)" returnvariable="qry_subfolders" />
		<!-- CFC: Folder access -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="setaccess(attributes.folder_id)" returnvariable="attributes.folderaccess" />
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
		<!-- CFC: Get breadcrumb -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="getbreadcrumb(attributes.folder_id)" returnvariable="qry_breadcrumb" />
		<!-- Get labels -->
		<do action="labels" />
		<!-- CFC: Get plugin actions -->
		<set name="attributes.nameOfVariable" value="plwx" />
		<invoke object="myFusebox.getApplicationData().plugins" methodcall="getactions('show_in_folderview_select_wx',attributes)" returnvariable="plwx" />
		<!-- CFC: Get plugin actions -->
		<set name="attributes.nameOfVariable" value="plr" />
		<invoke object="myFusebox.getApplicationData().plugins" methodcall="getactions('show_in_folderview_select_r',attributes)" returnvariable="plr" />
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
		<xfa name="sendemail" value="c.email_send" />
		<!-- Param -->
		<set name="kind" value="all" />
		<set name="url.kind" value="all" />
		<set name="attributes.json" value="f" overwrite="false" />
		<set name="attributes.trash" value="F" overwrite="false" />
		<if condition="structkeyexists(attributes,'showsubfolders')">
			<true>
				<set name="session.showsubfolders" value="#attributes.showsubfolders#" />
			</true>
		</if>
		<set name="attributes.showsubfolders" value="#session.showsubfolders#" />
		<set name="attributes.sortby" value="#session.sortby#" overwrite="false" />
		<set name="session.sortby" value="#attributes.sortby#" />
		<set name="attributes.issearch" value="false" overwrite="false" />
		<if condition="!structkeyexists(attributes,'offset')">
			<true>
				<set name="session.file_id" value="" />
				<set name="session.thefileid" value="#session.file_id#" />
			</true>
		</if>
		<!-- Action: Set view -->
		<do action="set_view" />
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- CFC: Load record -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="getfolder(attributes.folder_id)" returnvariable="qry_folder" />
		<!-- CFC: Set Access -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="setaccess(attributes.folder_id)" returnvariable="attributes.folderaccess" />
		<!-- CFC: Get subfolders -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="getsubfolders(attributes.folder_id)" returnvariable="qry_subfolders" />
		<!-- CFC: Customization -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="get_customization()" returnvariable="cs" />
		<set name="attributes.cs" value="#cs#" /> 
		<!-- CFC: Get placement for fields-->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="get_customization_placement(cs)" returnvariable="cs_place" />
		<set name="attributes.cs_place" value="#cs_place#" /> 
		<!-- CFC: Get settings -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="getsettingsfromdam()" returnvariable="prefs" />
		<!-- Only if it NOT from search -->
		<if condition="!#attributes.issearch#">
			<true>
				<!-- CFC: Get the total file count -->
				<invoke object="myFusebox.getApplicationData().folders" methodcall="filetotalcount(attributes.folder_id)" returnvariable="qry_filecount" />
				<set name="attributes.qry_filecount" value="#qry_filecount.thetotal#" overwrite="false" />
				<!-- CFC: Get all assets -->
				<invoke object="myFusebox.getApplicationData().folders" methodcall="getallassets(attributes)" returnvariable="qry_files" />
			</true>
		</if>
		<!-- CFC: Get folder name -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="getfoldername(attributes.folder_id)" returnvariable="qry_foldername" />
		<!-- CFC: Get user name -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="getusername(attributes.folder_id)" returnvariable="qry_user" />
		<!-- CFC: Get breadcrumb -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="getbreadcrumb(attributes.folder_id)" returnvariable="qry_breadcrumb" />
		<!-- Get labels -->
		<do action="labels" />
		<!-- CFC: Get plugin actions -->
		<set name="attributes.nameOfVariable" value="plwx" />
		<invoke object="myFusebox.getApplicationData().plugins" methodcall="getactions('show_in_folderview_select_wx',attributes)" returnvariable="plwx" />
		<!-- CFC: Get plugin actions -->
		<set name="attributes.nameOfVariable" value="plr" />
		<invoke object="myFusebox.getApplicationData().plugins" methodcall="getactions('show_in_folderview_select_r',attributes)" returnvariable="plr" />
	</fuseaction>
	<!-- Load Folder Content -->
	<fuseaction name="folder_content">
		<!-- Reset session -->
		<!-- <set name="session.file_id" value="" /> -->
		<!-- <set name="session.thefileid" value="" /> -->
		<do action="folder_content_include" />
		<!-- Show -->
		<do action="ajax.folder_content" />
	</fuseaction>
	<!-- Load Folder Content for Search -->
	<fuseaction name="folder_content_results">
		<!-- Params -->
		<set name="url.folder_id" value="#attributes.folder_id#" />
		<set name="attributes.issearch" value="true" />
		<!-- The total of found records is within the query itself -->
		<if condition="!structkeyexists(attributes,'search_simple')">
			<true>
				<set name="qry_filecount.thetotal" value="#qry_files.qall.recordcount#" />
			</true>
		</if>
		<!-- Get Include -->
		<do action="folder_content_include" />
		<!-- Overwrite params from the include above -->
		<set name="kind" value="search" />
		<set name="url.kind" value="search" />
		<set name="session.thetype" value="all" />
		<!-- Show -->
		<do action="ajax.folder_content_results" />
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
		<!-- CFC: Get parent folder details  -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="getfolder(qry_folder.folder_id_r)" returnvariable="qry_root_folder" />
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
		<!-- If this is for a new sub folder then query for the permissions of the parent folder. Set the folder id to the parent one  -->
		<if condition="attributes.folder_id EQ 0 AND attributes.rid NEQ 0">
			<true>
				<set name="attributes.folder_id_org" value="#attributes.folder_id#" />
				<set name="attributes.folder_id" value="#attributes.rid#" />
			</true>
		</if> 
		<!-- CFC: Load Groups of this folder -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="getfoldergroups(attributes.folder_id,qry_groups)" returnvariable="qry_folder_groups" />
		<!-- CFC: Load Groups of this folder for group 0 -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="getfoldergroupszero(attributes.theid)" returnvariable="qry_folder_groups_zero" />
		<!-- Get labels -->
		<do action="labels" />
		<!-- Get labels for this record -->
		<invoke object="myFusebox.getApplicationData().labels" methodcall="getlabels(attributes.folder_id,'folder')" returnvariable="qry_labels" />
		<!--RAZ-2207 Get the groups of this user -->
		<invoke object="myFusebox.getApplicationData().groups_users" method="getGroupsOfUser" returnvariable="qry_GroupsOfUser" >
			<argument name="user_id" value="#session.theuserid#" />
			<argument name="host_id" value="#session.hostid#" />
		</invoke>
		<!-- CFC: Get config -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="get_label_set()" returnvariable="qry_label_set" />
		<!-- CFC: Get languages -->
		<do action="languages" />
		<!-- Reset folder id again  -->
		<if condition="attributes.folder_id EQ 0 AND attributes.rid NEQ 0">
			<true>
				<set name="attributes.folder_id" value="#attributes.folder_id_org#" />
			</true>
		</if>
		<!-- CFC: Get plugin actions -->
		<invoke object="myFusebox.getApplicationData().plugins" methodcall="getactions('on_folder_settings',attributes)" returnvariable="pl" />
		<!-- CFC: Get access -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="setaccess(attributes.folder_id)" returnvariable="attributes.folderaccess" />
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
		<!-- Action: Storage -->
		<do action="storage" />
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
		<!--<do action="trash_folder_all" />-->
		<!-- <if condition="attributes.loaddiv EQ 'assets'">
			<true>
				<do action="trash_assets" />
			</true>
		</if>
		<if condition="attributes.loaddiv EQ 'collection'">
			<true>
				<do action="col_get_trash" />
			</true>
		</if> -->
	</fuseaction>
	<!-- Trash Folder -->
	<fuseaction name="folder_trash">
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- Action: Storage -->
		<do action="storage" />
		<!-- Path -->
		<set name="attributes.thepathup" value="#ExpandPath('../../')#" />
		<!-- Set folder directory-->
		<set name="attributes.thetrash" value="trash" />
		<!-- CFC: Trash folder -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="trash(attributes)" returnvariable="attributes.folder_id" />
		<!-- Show -->
		<!-- <if condition="#attributes.iscol# EQ 'f'">
			<true>
				<do action="folder_content" />
			</true>
			<false>
				<do action="explorer_col" />
			</false>
		</if> -->
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
		<!-- Param -->
		<set name="session.type" value="" />
		<set name="session.currentupload" value="0" />
		<!-- XFA -->
		<xfa name="addsingle" value="c.asset_add_single" />
		<xfa name="addserver" value="c.asset_add_server" />
		<xfa name="addemail" value="c.asset_add_email" />
		<xfa name="addftp" value="c.asset_add_ftp" />
		<xfa name="addlink" value="c.asset_add_link" />
		<!-- CFC: Customization -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="get_customization()" returnvariable="cs" />
		<!-- Show -->
		<do action="ajax.asset_add" />
	</fuseaction>
	<!-- Add Single Form -->
	<fuseaction name="asset_add_single">
		<!-- Params -->
		<set name="attributes.nopreview" value="0" overwrite="false" />
		<set name="attributes.av" value="0" overwrite="false" />
		<if condition="structkeyexists(attributes,'folder_id')">
			<true>
				<set name="session.fid" value="#attributes.folder_id#" />
			</true>
		</if>
		<if condition="structkeyexists(attributes,'fromshare')">
			<true>
				<set name="session.fromshare" value="true" />
				<set name="attributes.fromshare" value="true" />
			</true>
			<false>
				<set name="session.fromshare" value="false" />
			</false>
		</if>
		<!-- XFA -->
		<xfa name="submitassetsingle" value="c.asset_upload_do" />
		<!-- CFC: Get languages -->
		<do action="languages" />
		<!-- CFC: Customization -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="get_customization()" returnvariable="cs" />
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
		<invoke object="myFusebox.getApplicationData().folders" methodcall="getserverdir(attributes.folderpath)" returnvariable="qry_filefolders" />
		<!-- Show -->
		<do action="ajax.asset_add_server_folders" />
	</fuseaction>
	<!-- Add Server FOLDER CONTENT -->
	<fuseaction name="asset_add_server_content">
		<xfa name="serverfolders" value="c.asset_add_server_folders" />
		<xfa name="submitassetserver" value="c.asset_upload_server" />
		<!-- Get settings -->
		<!-- <do action="asset_get_settings" /> -->
		<!-- CFC: get upload templates -->
		<invoke object="myFusebox.getApplicationData().global" methodcall="upl_templates(true)" returnvariable="qry_templates" />
		<!-- CFC: Get plugin actions -->
		<invoke object="myFusebox.getApplicationData().plugins" methodcall="getactions('on_file_add_done')" returnvariable="pl_return" />
		<set name="pl_return.cfc.pl.loadform.active" value="false" overwrite="false" />
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
		<!-- CFC: Get plugin actions -->
		<invoke object="myFusebox.getApplicationData().plugins" methodcall="getactions('on_file_add_done')" returnvariable="pl_return" />
		<set name="pl_return.cfc.pl.loadform.active" value="false" overwrite="false" />
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
		<!-- CFC: get upload templates -->
		<invoke object="myFusebox.getApplicationData().global" methodcall="upl_templates(true)" returnvariable="qry_templates" />
		<!-- CFC: Get plugin actions -->
		<invoke object="myFusebox.getApplicationData().plugins" methodcall="getactions('on_file_add_done')" returnvariable="pl_return" />
		<set name="pl_return.cfc.pl.loadform.active" value="false" overwrite="false" />
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
		<!-- CFC: get upload templates -->
		<invoke object="myFusebox.getApplicationData().global" methodcall="upl_templates(true)" returnvariable="qry_templates" />
		<!-- CFC: Get plugin actions -->
		<invoke object="myFusebox.getApplicationData().plugins" methodcall="getactions('on_file_add_done')" returnvariable="pl_return" />
		<set name="pl_return.cfc.pl.loadform.active" value="false" overwrite="false" />
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
		<set name="session.currentupload" value="0" />
		<!-- Set runtime session -->
		<if condition="cgi.http_user_agent CONTAINS 'windows' OR cgi.http_user_agent CONTAINS 'safari'">
			<true>
				<set name="session.pluploadruntimes" value="flash,html5,silverlight" overwrite="false" />
			</true>
			<false>
				<set name="session.pluploadruntimes" value="html5,flash,silverlight" overwrite="false" />
			</false>
		</if>
		<!-- Get the Cache tag -->
		<do action="cachetag" />
		<!-- CFC: get upload templates -->
		<invoke object="myFusebox.getApplicationData().global" methodcall="upl_templates(true)" returnvariable="qry_templates" />
		<!-- CFC: Get plugin actions -->
		<invoke object="myFusebox.getApplicationData().plugins" methodcall="getactions('on_file_add_done')" returnvariable="pl_return" />
		<set name="pl_return.cfc.pl.loadform.active" value="false" overwrite="false" />
		<!-- Show -->
		<do action="ajax.asset_add_upload" />
	</fuseaction>
	<!-- Upload JUST THE FILE -->
	<fuseaction name="asset_upload">
		<set name="attributes.user_id" value="#session.theuserid#" />	
		<set name="attributes.nopreview" value="0" overwrite="false" />
		<set name="attributes.av" value="0" overwrite="false" />
		<set name="attributes.thepath" value="#thispath#" />
		<!-- CFC: Upload -->
		<invoke object="myFusebox.getApplicationData().assets" methodcall="upload(attributes)" returnvariable="result" />
		<!-- RAZ-2907 upload Bulk versions -->
		<!-- Versions Add -->
		<if condition="structkeyexists(attributes,'extjs') AND attributes.extjs EQ 'T' ">
			<true>
				<do action = "versions_add" />
			</true>
		</if>		
		<!-- Show -->
		<do action="ajax.versions_upload" />
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
		<if condition="structkeyexists(attributes,'assetid') AND attributes.assetid NEQ ''">
			<true>
				<set name="session.asset_id_r" value="#attributes.assetid#" />
				<set name="attributes.av" value="1" />
			</true>
		</if>
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- Action: Check storage -->
		<do action="storage" />
		<!-- CFC: Get settings -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="getsettingsfromdam()" returnvariable="attributes.prefs" />
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
	
	<!-- Called from uploader directly -->
	<fuseaction name="w_import_from_uploader">
		<!-- Param -->
		<set name="attributes.updater" value="false" overwrite="false" />
		<set name="session.hostid" value="#attributes.hostid#" />
		<set name="attributes.host_id" value="#attributes.hostid#" />
		<!-- Get userid by apikey -->
		<invoke object="myFusebox.getApplicationData().users" methodcall="getUserbyApiKey(attributes.apikey)" returnvariable="qry_user" />
		<!-- Set userid into session -->
		<set name="session.theuserid" value="#qry_user.user_id#" />
		<!-- Set proper host data -->
		<invoke object="myFusebox.getApplicationData().hosts" methodcall="getdetail(attributes)" returnvariable="qry_host" />
		<set name="session.hostdbprefix" value="#qry_host.host_shard_group#" />
		<!-- Set to not create a folder since we only upload files -->
		<set name="attributes.nofolder" value="true" />
		<!-- Set langcount -->
		<set name="attributes.langcount" value="1" />
		<!-- If we are updater or not -->
		<if condition="attributes.updater">
			<true>
				<!-- Call updater -->
				<do action="asset_add_updater" />
			</true>
			<false>
				<!-- Finally call function to import from path -->
				<do action="asset_add_path" />
			</false>
		</if>
	</fuseaction>

	<!-- Add asset from path -->
	<fuseaction name="asset_add_updater">
		<!-- Param -->
		<set name="attributes.rootpath" value="#ExpandPath('../..')#" />
		<set name="attributes.thepath" value="#thispath#" />
		<set name="attributes.link_path" value="#attributes.folder_path#" />
		<set name="attributes.dynpath" value="#dynpath#" />
		<set name="attributes.httphost" value="#cgi.http_host#" />
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- Action: Check storage -->
		<do action="storage" />
		<!-- CFC: Get image settings -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="prefs_image()" returnvariable="attributes.qry_settings_image" />
		<!-- Add file -->
		<invoke object="myFusebox.getApplicationData().assets" methodcall="addassetpath_updater(attributes)" />
	</fuseaction>

	<!-- Add asset from path -->
	<fuseaction name="asset_add_path">
		<!-- Param -->
		<set name="attributes.rootpath" value="#ExpandPath('../..')#" />
		<set name="attributes.thepath" value="#thispath#" />
		<set name="attributes.link_path" value="#attributes.folder_path#" />
		<set name="attributes.dynpath" value="#dynpath#" />
		<set name="attributes.httphost" value="#cgi.http_host#" />
		<set name="attributes.av" value="false" overwrite="false" />
		<set name="attributes.nofolder" value="false" overwrite="false" />
		<!-- Query folder -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="getfolder(attributes.theid)" returnvariable="qry" />
		<set name="attributes.level" value="#qry.folder_level#" />
		<set name="attributes.rid" value="#qry.rid#" />
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- Action: Check storage -->
		<do action="storage" />
		<!-- CFC: Check to be able to read folder -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="link_check(attributes)" returnvariable="attributes.checkstatus" />
		<!-- Show -->
		<if condition="attributes.checkstatus.dir EQ 'no'">
			<true>
				<do action="ajax.folder_check" />
			</true>
			<false>
				<!-- CFC: Add path -->
				<if condition="!attributes.av">
					<true>
						<invoke object="myFusebox.getApplicationData().assets" methodcall="addassetpath(attributes)" />
					</true>
					<false>
						<invoke object="myFusebox.getApplicationData().assets" methodcall="add_av_from_path(attributes)" />
					</false>
				</if>
			</false>
		</if>
	</fuseaction>
	
	<!-- Load history asset log -->
	<fuseaction name="log_history">
		<!-- Set offset for logs -->
		<do action="set_offset_admin" />
		<!-- Params -->
		<set name="attributes.logswhat" value="log_assets" />
		<!-- CFC -->
		<invoke object="myFusebox.getApplicationData().log" methodcall="get_log_assets(attributes)" returnvariable="qry_log" />
		<!-- CFC: Customization -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="get_customization()" returnvariable="cs" />
		<!-- Show -->
		<do action="ajax.log_history" />
	</fuseaction>
	<!-- Search log history -->
	<fuseaction name="log_history_search">
		<!-- CFC: Search log -->
		<invoke object="myFusebox.getApplicationData().log" methodcall="log_search(attributes)" returnvariable="qry_log" />
		<!-- CFC: Customization -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="get_customization()" returnvariable="cs" />
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
	
	<!-- Show Alias usage -->
	<fuseaction name="usage_alias">
		<!-- CFC -->
		<invoke object="myFusebox.getApplicationData().global" methodcall="getUsageAlias(attributes.id)" returnvariable="qry_alias" />
		<!-- Show -->
		<do action="ajax.usage_alias" />
	</fuseaction>

	<!--
		END: WORKING WITH ASSETS
	 -->
	
	<!--
		START: FILE SPECIFIC SECTIONS
	 -->
	 
	<!-- Move file to trash-->
	<fuseaction name="files_trash">
		<!-- HTTP referer for workflow -->
		<set name="attributes.comingfrom" value="#cgi.http_referer#" />
		<set name="attributes.trash" value="T" />
		<!-- CFC: Trash -->
		<invoke object="myFusebox.getApplicationData().files" methodcall="trashfile(attributes)" />
		<!-- Show the folder listing -->
		<if condition="attributes.loaddiv NEQ ''">
			<true>
				<if condition="attributes.loaddiv EQ 'content'">
					<true>
						<do action="folder_content" />
					</true>
					<false>
						<do action="folder_files" />
					</false>
				</if>
			</true>
		</if>
		<if condition="isdefined('attributes.label_id') AND attributes.label_id NEQ ''">
			<true>
				<do action="labels_main" />
			</true>
		</if>
	</fuseaction>
	<!-- Restore files-->
	<fuseaction name="files_restore">
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- Action: Storage -->
		<do action="storage" />
		<!-- HTTP referer for workflow -->
		<set name="attributes.comingfrom" value="#cgi.http_referer#" />
		<set name="attributes.trash" value="F" />
		<set name="attributes.trashkind" value="assets" />
		<!-- CFC: Upload -->
		<invoke object="myFusebox.getApplicationData().files" methodcall="restorefile(attributes)" returnvariable="attributes.is_trash" />
		<!-- Show the folder listing -->
		<set name="attributes.thetype" value="doc" />
		<set name="attributes.type" value="restorefile" />
		<set name="attributes.kind" value="files" />
		<set name="session.thetype" value="#attributes.thetype#" />
		<set name="seesion.type" value="#attributes.type#" />
		<!-- Action: Get trash -->
		<do action="trash_assets" />
	</fuseaction>
	<!-- Remove files -->
	<fuseaction name="files_remove">
		<!-- HTTP referer for workflow -->
		<set name="attributes.comingfrom" value="#cgi.http_referer#" />
		<set name="attributes.trashkind" value="assets" />
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- Action: Storage -->
		<do action="storage" />
		<!-- CFC: Remove -->
		<invoke object="myFusebox.getApplicationData().files" methodcall="removefile(attributes)" />
		<!-- Show the folder listing -->
		<if condition="attributes.loaddiv NEQ ''">
			<true>
				<if condition="attributes.loaddiv EQ 'content'">
					<true>
						<do action="folder_content"/>
					</true>
					<false>
						<do action="folder_files" />
					</false>
				</if>
			</true>
		</if>
	</fuseaction>
	<!-- Move images to trash-->
	<fuseaction name="images_trash">
		<!-- HTTP referer for workflow -->
		<set name="attributes.comingfrom" value="#cgi.http_referer#" />
		<!--Set image trsh-->
		<set name="attributes.trash" value="T" overwrite="false" />
		<!-- CFC: Trash -->
		<invoke object="myFusebox.getApplicationData().images" methodcall="trashimage(attributes)" />
		<!-- Show the folder listing -->
		<if condition="attributes.loaddiv NEQ ''">
			<true>
				<if condition="attributes.loaddiv EQ 'content'">
					<true>
						<do action="folder_content"/>
					</true>
					<false>
						<do action="folder_images" />
					</false>
				</if>
			</true>
		</if>
		<if condition="isdefined('attributes.label_id') AND attributes.label_id NEQ ''">
			<true>
				<do action="labels_main" />
			</true>
		</if>
	</fuseaction>
	<!-- Restore images-->
	<fuseaction name="images_restore">
		<!-- HTTP referer for workflow -->
		<set name="attributes.comingfrom" value="#cgi.http_referer#" />
		<set name="attributes.trash" value="F" overwrite="false" />
		<set name="attributes.trashkind" value="assets" />
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- Action: Storage -->
		<do action="storage" />
		<!-- CFC: Restore -->
		<invoke object="myFusebox.getApplicationData().images" methodcall="restoreimage(attributes)" returnvariable="attributes.is_trash" />
		<!-- Show the folder listing -->
		<set name="attributes.thetype" value="img" />
		<set name="attributes.type" value="restorefile" />
		<set name="attributes.kind" value="images" />
		<set name="session.thetype" value="#attributes.thetype#" />
		<set name="seesion.type" value="#attributes.type#" />
		<!-- Action: Get trash -->
		<do action="trash_assets" />
	</fuseaction>
	<!-- Remove images -->
	<fuseaction name="images_remove">
		<!-- HTTP referer for workflow -->
		<set name="attributes.comingfrom" value="#cgi.http_referer#" />
		<set name="attributes.trashkind" value="assets" />
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- Action: Storage -->
		<do action="storage" />
		<!-- CFC: Remove -->
		<invoke object="myFusebox.getApplicationData().images" methodcall="removeimage(attributes)" />
		<!-- Show the folder listing -->
		<if condition="attributes.loaddiv NEQ ''">
			<true>
				<if condition="attributes.loaddiv EQ 'content'">
					<true>
						<do action="folder_content"/>
					</true>
					<false>
						<do action="folder_images" />
					</false>
				</if>
			</true>
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
		<!-- <do action="images_detail_related" /> -->
	</fuseaction>
	<!-- Move video to trash-->
	<fuseaction name="videos_trash">
		<!-- HTTP referer for workflow -->
		<set name="attributes.comingfrom" value="#cgi.http_referer#" />
		<set name="attributes.trash" value="T" />
		<!-- CFC: Trash -->
		<invoke object="myFusebox.getApplicationData().videos" methodcall="trashvideo(attributes)" />
		<!-- Show the folder listing -->
		<if condition="attributes.loaddiv NEQ ''">
			<true>
				<if condition="attributes.loaddiv EQ 'content'">
					<true>
						<do action="folder_content" />
					</true>
					<false>
						<do action="folder_videos" />
					</false>
				</if>
			</true>
		</if>
		<if condition="isdefined('attributes.label_id') AND attributes.label_id NEQ ''">
			<true>
				<do action="labels_main" />
			</true>
		</if>
	</fuseaction> 
	<!-- Restore videos-->
	<fuseaction name="videos_restore">
		<!-- HTTP referer for workflow -->
		<set name="attributes.comingfrom" value="#cgi.http_referer#" />
		<set name="attributes.trash" value="F" />
		<set name="attributes.trashkind" value="assets" />
		<!-- CFC: Restore -->
		<invoke object="myFusebox.getApplicationData().videos" methodcall="restorevideos(attributes)" returnvariable="attributes.is_trash" />
	</fuseaction>
	<!-- Remove videos -->
	<fuseaction name="videos_remove">
		<!-- HTTP referer for workflow -->
		<set name="attributes.comingfrom" value="#cgi.http_referer#" />
		<set name="attributes.trashkind" value="assets" />
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- Action: Storage -->
		<do action="storage" />
		<!-- CFC: Remove -->
		<invoke object="myFusebox.getApplicationData().videos" methodcall="removevideo(attributes)" />
		<!-- Show the folder listing -->
		<if condition="attributes.loaddiv NEQ ''">
			<true>
				<if condition="attributes.loaddiv EQ 'content'">
					<true>
						<do action="folder_content"/>
					</true>
					<false>
						<do action="folder_videos" />
					</false>
				</if>
			</true>
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
		<!-- <do action="videos_detail_related" /> -->
	</fuseaction>
	<!-- Move audio to trash-->
	<fuseaction name="audios_trash">
		<!-- HTTP referer for workflow -->
		<set name="attributes.comingfrom" value="#cgi.http_referer#" />
		<set name="attributes.trash" value="T" overwrite="false"/>
		<!-- CFC: Trash -->
		<invoke object="myFusebox.getApplicationData().audios" methodcall="trashaudio(attributes)" />
		<!-- Show the folder listing -->
		<if condition="attributes.loaddiv NEQ ''">
			<true>
				<if condition="attributes.loaddiv EQ 'content'">
					<true>
						<do action="folder_content" />
					</true>
					<false>
						<do action="folder_audios" />
					</false>
				</if>
			</true>
		</if>
		<if condition="isdefined('attributes.label_id') AND attributes.label_id NEQ ''">
			<true>
				<do action="labels_main" />
			</true>
		</if>
	</fuseaction>
	<!-- Restore audios-->
	<fuseaction name="audios_restore">
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- Action: Storage -->
		<do action="storage" />
		<!-- HTTP referer for workflow -->
		<set name="attributes.comingfrom" value="#cgi.http_referer#" />
		<set name="attributes.trash" value="F" />
		<set name="attributes.trashkind" value="assets" />
		<!-- CFC: Upload -->
		<invoke object="myFusebox.getApplicationData().audios" methodcall="restoreaudio(attributes)" returnvariable="attributes.is_trash" />
		<!-- Show the folder listing -->
		<set name="attributes.thetype" value="aud" />
		<set name="attributes.type" value="restorefile" />
		<set name="attributes.kind" value="audios" />
		<set name="session.thetype" value="#attributes.thetype#" />
		<set name="session.thefileid" value=",#attributes.id#-aud," />
		<set name="seesion.type" value="#attributes.type#" />
		<!--Action: Get trash-->
		<do action="trash_assets" />
	</fuseaction>
	<!-- Remove Audios -->
	<fuseaction name="audios_remove">
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- Action: Storage -->
		<do action="storage" />
		<!-- HTTP referer for workflow -->
		<set name="attributes.comingfrom" value="#cgi.http_referer#" />
		<set name="attributes.trashkind" value="assets" />
		<!--Path-->
	        <set name="attributes.thepathup" value="#expandPath('../../')#" />
	        <!--Set trash directory path-->
	        <set name="attributes.thetrash" value="trash" />
		<!-- CFC: Upload -->
		<invoke object="myFusebox.getApplicationData().audios" methodcall="removeaudio(attributes)" />
		<!-- Show the folder listing -->
		<if condition="attributes.loaddiv NEQ ''">
			<true>
				<if condition="attributes.loaddiv EQ 'content'">
					<true>
						<do action="folder_content"/>
					</true>
					<false>
						<do action="folder_audios" />
					</false>
				</if>
			</true>
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
		<!-- <do action="audios_detail_related" /> -->
	</fuseaction>
	
	<!-- Remove files MANY -->
	<fuseaction name="doc_remove_many">
		<!-- Param -->
    	<set name="attributes.theuserid" value="#session.theuserid#" />
    	<set name="attributes.hostdbprefix" value="#session.hostdbprefix#" />
    	<set name="attributes.hostid" value="#session.hostid#" />
    	<!-- HTTP referer for workflow -->
		<set name="attributes.comingfrom" value="#cgi.http_referer#" />
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
		<if condition="attributes.loaddiv NEQ 'content' AND attributes.loaddiv NEQ ''">
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
    	<!-- HTTP referer for workflow -->
		<set name="attributes.comingfrom" value="#cgi.http_referer#" />
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
		<if condition="attributes.loaddiv NEQ 'content' AND attributes.loaddiv NEQ ''">
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
    	<!-- HTTP referer for workflow -->
		<set name="attributes.comingfrom" value="#cgi.http_referer#" />
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
		<if condition="attributes.loaddiv NEQ 'content' AND attributes.loaddiv NEQ ''">
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
    	<!-- HTTP referer for workflow -->
		<set name="attributes.comingfrom" value="#cgi.http_referer#" />
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
		<if condition="attributes.loaddiv NEQ 'content' AND attributes.loaddiv NEQ ''">
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
    	<!-- HTTP referer for workflow -->
		<set name="attributes.comingfrom" value="#cgi.http_referer#" />
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
		<if condition="attributes.loaddiv NEQ ''">
			<true>
				<do action="folder" />
			</true>
		</if>
	</fuseaction>
	
	<!-- Trash files MANY -->
	<fuseaction name="doc_trash_many">
		<!-- Param -->
    	<set name="attributes.hostid" value="#session.hostid#" />
		<set name="attributes.trash" value="T" />
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
		<!-- CFC: Trash -->
		<invoke object="myFusebox.getApplicationData().files" methodcall="trashfilemany(attributes)" />
		<!-- Show the folder listing -->
		<if condition="attributes.loaddiv NEQ 'content' AND attributes.loaddiv NEQ ''">
			<true>
				<do action="folder_files" />
			</true>
		</if>
	</fuseaction>
	<!-- Trash images MANY -->
	<fuseaction name="img_trash_many">
    	<!-- Param -->
    	<set name="attributes.hostid" value="#session.hostid#" />
		<set name="attributes.trash" value="T"/>
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
		<!-- CFC: Trash -->
		<invoke object="myFusebox.getApplicationData().images" methodcall="trashimagemany(attributes)" />
		<!-- Show the folder listing -->
		<if condition="attributes.loaddiv NEQ 'content' AND attributes.loaddiv NEQ ''">
			<true>
				<do action="folder_images" />
			</true>
		</if>
	</fuseaction>
	<!-- Trash videos -->
	<fuseaction name="vid_trash_many">
		<!-- Param -->
    	<set name="attributes.hostid" value="#session.hostid#" />
		<set name="attributes.trash" value="T" />
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
		<!-- CFC: Trash -->
		<invoke object="myFusebox.getApplicationData().videos" methodcall="trashvideomany(attributes)" />
		<!-- Show the folder listing -->
		<if condition="attributes.loaddiv NEQ 'content' AND attributes.loaddiv NEQ ''">
			<true>
				<do action="folder_videos" />
			</true>
		</if>
	</fuseaction>
	<!-- Trash audios -->
	<fuseaction name="aud_trash_many">
		<!-- Param -->
    	<set name="attributes.hostid" value="#session.hostid#" />
		<set name="attributes.trash" value="T" />
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
		<!-- CFC: Trash -->
		<invoke object="myFusebox.getApplicationData().audios" methodcall="trashaudiomany(attributes)" />
		<!-- Show the folder listing -->
		<if condition="attributes.loaddiv NEQ 'content' AND attributes.loaddiv NEQ ''">
			<true>
				<do action="folder_audios" />
			</true>
		</if>
	</fuseaction>
	<!-- Trash ALL -->
	<fuseaction name="all_trash_many">
		<!-- Param -->
    	<set name="attributes.hostid" value="#session.hostid#" />
    	<set name="attributes.id" value="#session.file_id#" />
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- Action: Storage -->
		<do action="storage" />
		<!-- CFC: Set the correct ids -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="trashall(attributes)" returnvariable="theids" />
		<!-- For Docs -->
		<if condition="#theids.docids# NEQ ''">
			<true>
				<set name="attributes.id" value="#theids.docids#" />
				<do action="doc_trash_many" />
			</true>
		</if>
		<!-- For Images -->
		<if condition="#theids.imgids# NEQ ''">
			<true>
				<set name="attributes.id" value="#theids.imgids#" />
				<do action="img_trash_many" />
			</true>
		</if>
		<!-- For Videos -->
		<if condition="#theids.vidids# NEQ ''">
			<true>
				<set name="attributes.id" value="#theids.vidids#" />
				<do action="vid_trash_many" />
			</true>
		</if>
		<!-- For Audios -->
		<if condition="#theids.audids# NEQ ''">
			<true>
				<set name="attributes.id" value="#theids.audids#" />
				<do action="aud_trash_many" />
			</true>
		</if>
		<!-- Show the folder listing -->
		<if condition="attributes.loaddiv NEQ ''">
			<true>
				<do action="folder" />
			</true>
		</if>
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
		<!-- CFC: Get folder info -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="getfolder(attributes.folder_id)" returnvariable="qry_folder" />
		<!-- CFC: Get access -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="setaccess(attributes.folder_id)" returnvariable="attributes.folderaccess" />
		<!-- CFC: Check for custom fields -->
		<invoke object="myFusebox.getApplicationData().custom_fields" methodcall="getfields(attributes)" returnvariable="qry_cf" />
		<!-- CFC: Get how many comments there are -->
		<invoke object="myFusebox.getApplicationData().comments" methodcall="howmany(attributes)" returnvariable="qry_comments_total" />
		<!-- CFC: Customization -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="get_customization()" returnvariable="cs" />
		<!-- RAZ-2207 Get the groups of this user -->
		<invoke object="myFusebox.getApplicationData().groups_users" method="getGroupsOfUser" returnvariable="qry_GroupsOfUser" >
			<argument name="user_id" value="#session.theuserid#" />
			<argument name="host_id" value="#session.hostid#" />
		</invoke>
		<!-- CFC: Get config -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="get_label_set()" returnvariable="qry_label_set" />
		<!-- CFC: Get settings -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="getsettingsfromdam()" returnvariable="prefs" />
		<!-- CFC: Get plugin actions -->
		<set name="attributes.nameOfVariable" value="plwx" />
		<invoke object="myFusebox.getApplicationData().plugins" methodcall="getactions('add_tab_detail_wx',attributes)" returnvariable="plwx" />
		<!-- CFC: Get plugin actions -->
		<set name="attributes.nameOfVariable" value="plr" />
		<invoke object="myFusebox.getApplicationData().plugins" methodcall="getactions('add_tab_detail_r',attributes)" returnvariable="plr" />
		<!-- CFC: Get plugin actions -->
		<set name="attributes.nameOfVariable" value="pllink" />
		<invoke object="myFusebox.getApplicationData().plugins" methodcall="getactions('show_in_detail_link_wx',attributes)" returnvariable="pllink" />
		<!-- CFC: Get individual share options -->
		<invoke object="myFusebox.getApplicationData().global" methodcall="get_share_options(attributes)" returnvariable="qry_share_options" />
		<!-- Check if there are any aliases -->
		<invoke object="myFusebox.getApplicationData().global" methodcall="getUsageAlias(attributes.file_id)" returnvariable="qry_aliases" />
		<!-- Show the folder listing -->
		<do action="ajax.files_detail" />
	</fuseaction>
	<!-- Save Detail -->
	<fuseaction name="files_detail_save">
		<!-- Params -->
		<set name="attributes.comingfrom" value="#cgi.http_referer#" />
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
		<set name="attributes.dynpath" value="#dynpath#" />
		<!-- CFC: Get settings -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="getsettingsfromdam()" returnvariable="prefs" />
		<set name="attributes.set2_custom_file_ext" value="#prefs.set2_custom_file_ext#" />
		<!-- CFC: Get asset path -->
		<do action="assetpath" />
		<!-- CFC: Get asset path -->
		<do action="storage" />
		<!-- CFC: Serve the file -->
		<invoke object="myFusebox.getApplicationData().files" methodcall="servefile(attributes)" returnvariable="qry_binary" />
		<!-- Get the Cache tag -->
		<do action="cachetag" />
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
		<!-- CFC: Get folder info -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="getfolder(attributes.folder_id)" returnvariable="qry_folder" />
		<!-- CFC: Get access -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="setaccess(attributes.folder_id)" returnvariable="attributes.folderaccess" />
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
		<!-- CFC: Customization -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="get_customization()" returnvariable="cs" />
		<!-- RAZ-2207 Get the groups of this user -->
		<invoke object="myFusebox.getApplicationData().groups_users" method="getGroupsOfUser" returnvariable="qry_GroupsOfUser" >
			<argument name="user_id" value="#session.theuserid#" />
			<argument name="host_id" value="#session.hostid#" />
		</invoke>
		<!-- CFC: Get config -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="get_label_set()" returnvariable="qry_label_set" />
		<!-- CFC: Get settings -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="getsettingsfromdam()" returnvariable="prefs" />
		<!-- CFC: Get plugin actions -->
		<set name="attributes.nameOfVariable" value="plwx" />
		<invoke object="myFusebox.getApplicationData().plugins" methodcall="getactions('add_tab_detail_wx',attributes)" returnvariable="plwx" />
		<!-- CFC: Get plugin actions -->
		<set name="attributes.nameOfVariable" value="plr" />
		<invoke object="myFusebox.getApplicationData().plugins" methodcall="getactions('add_tab_detail_r',attributes)" returnvariable="plr" />
		<!-- CFC: Get plugin actions -->
		<set name="attributes.nameOfVariable" value="pllink" />
		<invoke object="myFusebox.getApplicationData().plugins" methodcall="getactions('show_in_detail_link_wx',attributes)" returnvariable="pllink" />
		<!-- CFC: Get individual share options -->
		<invoke object="myFusebox.getApplicationData().global" methodcall="get_share_options(attributes)" returnvariable="qry_share_options" />
		<!-- Check if there are any aliases -->
		<invoke object="myFusebox.getApplicationData().global" methodcall="getUsageAlias(attributes.file_id)" returnvariable="qry_aliases" />
		<!-- Show the folder listing -->
		<do action="ajax.videos_detail" />
	</fuseaction>
	<!-- Videos Rendition -->
	<fuseaction name="exist_rendition_videos">
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
		<invoke object="myFusebox.getApplicationData().folders" methodcall="setaccess(attributes.folder_id)" returnvariable="attributes.folderaccess" />
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
		<!-- CFC: Customization -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="get_customization()" returnvariable="cs" />
		<!-- CFC: Get config -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="get_label_set()" returnvariable="qry_label_set" />
		<!-- CFC: Get plugin actions -->
		<set name="attributes.nameOfVariable" value="plwx" />
		<invoke object="myFusebox.getApplicationData().plugins" methodcall="getactions('add_tab_detail_wx',attributes)" returnvariable="plwx" />
		<!-- CFC: Get plugin actions -->
		<set name="attributes.nameOfVariable" value="plr" />
		<invoke object="myFusebox.getApplicationData().plugins" methodcall="getactions('add_tab_detail_r',attributes)" returnvariable="plr" />
		<!-- CFC: Get plugin actions -->
		<set name="attributes.nameOfVariable" value="pllink" />
		<invoke object="myFusebox.getApplicationData().plugins" methodcall="getactions('show_in_detail_link_wx',attributes)" returnvariable="pllink" />
		<!-- Show the folder listing -->
		<do action="ajax.exist_rendition_videos" />
	</fuseaction>
	<!-- Load related videos -->
	<fuseaction name="videos_detail_related">
		<invoke object="myFusebox.getApplicationData().folders" methodcall="setaccess(attributes.folder_id)" returnvariable="attributes.folderaccess" />
		<!-- CFC: Get related videos -->
		<invoke object="myFusebox.getApplicationData().videos" methodcall="relatedvideos(attributes)" returnvariable="qry_related" />
		<!-- Show the folder listing -->
		<do action="ajax.videos_detail_related" />
	</fuseaction>
	<!-- Save Detail -->
	<fuseaction name="videos_detail_save">
		<!-- Params -->
		<set name="attributes.comingfrom" value="#cgi.http_referer#" />
		<!-- Set the convert_to value to empty -->
		<set name="attributes.convert_to" value="" overwrite="false" />
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- Action: Storage -->
		<do action="storage" />
		<!-- Variables for API -->
		<set name="attributes.thefiletype" value="vid" />
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- Action: Storage -->
		<do action="storage" />
		<!-- CFC: Get video settings -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="prefs_video()" returnvariable="attributes.qry_settings_video" />
		<!-- Rendition metadata settings -->
		<set name="attributes.option_rendition_meta" value="#attributes.qry_settings_video.set2_rendition_metadata#" />
		<!-- CFC: Get related videos -->
		<invoke object="myFusebox.getApplicationData().videos" methodcall="relatedvideos(attributes)" returnvariable="attributes.qry_related" />
		<!-- Check if there are custom fields to be saved (we do this before because of indexing) -->
		<if condition="attributes.customfields NEQ 0">
			<true>
				<do action="custom_fields_save" />
			</true>
		</if>
		<!-- CFC: Save file detail -->
		<invoke object="myFusebox.getApplicationData().videos" methodcall="update(attributes)" />
	</fuseaction>
	<!-- Convert Video -->
	<fuseaction name="videos_convert">
		<!-- Param -->
		<set name="attributes.dynpath" value="#dynpath#" />
		<set name="attributes.httphost" value="#cgi.http_host#" />
		<set name="attributes.cf_show" value="vid" />
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- CFC: Storage -->
		<do action="storage" />
		<!-- CFC: Get video settings -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="prefs_video()" returnvariable="attributes.qry_settings_video" />
		<!-- Rendition metadata settings -->
		<set name="attributes.option_rendition_meta" value="#attributes.qry_settings_video.set2_rendition_metadata#" />
		<!-- CFC: Check for custom fields -->
		<invoke object="myFusebox.getApplicationData().custom_fields" methodcall="getfields(attributes)" returnvariable="attributes.qry_cf" />
		<!-- CFC: Convert video -->
		<invoke object="myFusebox.getApplicationData().videos" methodcall="convertvideothread(attributes)" />		
	</fuseaction>
	<!-- Videos Rendition Convert -->
	<fuseaction name="rendition_videos_convert">
		<!-- Param -->
		<set name="attributes.dynpath" value="#dynpath#" />
		<set name="attributes.httphost" value="#cgi.http_host#" />
		<set name="attributes.cf_show" value="vid" />
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- CFC: Storage -->
		<do action="storage" />
		<!-- CFC: Get video settings -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="prefs_video()" returnvariable="attributes.qry_settings_video" />
		<!-- Rendition metadata settings -->
		<set name="attributes.option_rendition_meta" value="#attributes.qry_settings_video.set2_rendition_metadata#" />
		<!-- CFC: Check for custom fields -->
		<invoke object="myFusebox.getApplicationData().custom_fields" methodcall="getfields(attributes)" returnvariable="attributes.qry_cf" />
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
		<!-- Get watermark templates -->
		<do action="watermark" />
		<!-- Get labels for this record -->
		<invoke object="myFusebox.getApplicationData().labels" methodcall="getlabels(attributes.file_id,'img')" returnvariable="qry_labels" />
		<!-- CFC: Get XMP value -->
		<invoke object="myFusebox.getApplicationData().xmp" methodcall="readxmpdb(attributes)" returnvariable="qry_xmp" />
		<!-- CFC: Get file detail -->
		<invoke object="myFusebox.getApplicationData().images" methodcall="detail(attributes)" returnvariable="qry_detail" />
		<set name="attributes.qry_detail" value="#qry_detail#" />
		<!-- CFC: Get folder info -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="getfolder(attributes.folder_id)" returnvariable="qry_folder" />
		<!-- CFC: Get access -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="setaccess(attributes.folder_id)" returnvariable="attributes.folderaccess" />
		<!-- CFC: Check for custom fields -->
		<invoke object="myFusebox.getApplicationData().custom_fields" methodcall="getfields(attributes)" returnvariable="qry_cf" />
		<!-- CFC: Get how many comments there are -->
		<invoke object="myFusebox.getApplicationData().comments" methodcall="howmany(attributes)" returnvariable="qry_comments_total" />
		<!-- CFC: Customization -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="get_customization()" returnvariable="cs" />
		<!--RAZ-2207 Get the groups of this user -->
		<invoke object="myFusebox.getApplicationData().groups_users" method="getGroupsOfUser" returnvariable="qry_GroupsOfUser" >
			<argument name="user_id" value="#session.theuserid#" />
			<argument name="host_id" value="#session.hostid#" />
		</invoke>
		<!-- CFC: Get config -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="get_label_set()" returnvariable="qry_label_set" />
		<!-- CFC: Get settings -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="getsettingsfromdam()" returnvariable="prefs" />
		<!-- CFC: Get plugin actions -->
		<set name="attributes.nameOfVariable" value="plwx" />
		<invoke object="myFusebox.getApplicationData().plugins" methodcall="getactions('add_tab_detail_wx',attributes)" returnvariable="plwx" />
		<!-- CFC: Get plugin actions -->
		<set name="attributes.nameOfVariable" value="plr" />
		<invoke object="myFusebox.getApplicationData().plugins" methodcall="getactions('add_tab_detail_r',attributes)" returnvariable="plr" />
		<!-- CFC: Get plugin actions -->
		<set name="attributes.nameOfVariable" value="pllink" />
		<invoke object="myFusebox.getApplicationData().plugins" methodcall="getactions('show_in_detail_link_wx',attributes)" returnvariable="pllink" />
		<!-- CFC: Get individual share options -->
		<invoke object="myFusebox.getApplicationData().global" methodcall="get_share_options(attributes)" returnvariable="qry_share_options" />
		<!-- Check if there are any aliases -->
		<invoke object="myFusebox.getApplicationData().global" methodcall="getUsageAlias(attributes.file_id)" returnvariable="qry_aliases" />
		<!-- Show the image detail window -->
		<do action="ajax.images_detail" />
	</fuseaction>
	<!-- Load related images -->
	<fuseaction name="images_detail_related">
		<invoke object="myFusebox.getApplicationData().settings" methodcall="prefs_image()" returnvariable="qry_settings_image" />
		<!-- CFC: Get global settings -->
		<!-- <invoke object="myFusebox.getApplicationData().settings" methodcall="prefs_web()" returnvariable="qry_settings" /> -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="setaccess(attributes.folder_id)" returnvariable="attributes.folderaccess" />
		<!-- CFC: Get related images -->
		<invoke object="myFusebox.getApplicationData().images" methodcall="relatedimages(attributes)" returnvariable="qry_related" />
		<!-- Show the folder listing -->
		<do action="ajax.images_detail_related" />
	</fuseaction>
	<!-- Images Renditions -->
	<fuseaction name="exist_rendition_images">
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
		<!-- Get watermark templates -->
		<do action="watermark" />
		<!-- Get labels for this record -->
		<invoke object="myFusebox.getApplicationData().labels" methodcall="getlabels(attributes.file_id,'img')" returnvariable="qry_labels" />
		<!-- CFC: Get XMP value -->
		<invoke object="myFusebox.getApplicationData().xmp" methodcall="readxmpdb(attributes)" returnvariable="qry_xmp" />
		<!-- CFC: Get file detail -->
		<invoke object="myFusebox.getApplicationData().images" methodcall="detail(attributes)" returnvariable="qry_detail" />
		<set name="attributes.qry_detail" value="#qry_detail#" />
		<!-- CFC: Get access -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="setaccess(attributes.folder_id)" returnvariable="attributes.folderaccess" />
		<!-- CFC: Check for custom fields -->
		<invoke object="myFusebox.getApplicationData().custom_fields" methodcall="getfields(attributes)" returnvariable="qry_cf" />
		<!-- CFC: Get how many comments there are -->
		<invoke object="myFusebox.getApplicationData().comments" methodcall="howmany(attributes)" returnvariable="qry_comments_total" />
		<!-- CFC: Customization -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="get_customization()" returnvariable="cs" />
		<!-- CFC: Get config -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="get_label_set()" returnvariable="qry_label_set" />
		<!-- CFC: Get plugin actions -->
		<set name="attributes.nameOfVariable" value="plwx" />
		<invoke object="myFusebox.getApplicationData().plugins" methodcall="getactions('add_tab_detail_wx',attributes)" returnvariable="plwx" />
		<!-- CFC: Get plugin actions -->
		<set name="attributes.nameOfVariable" value="plr" />
		<invoke object="myFusebox.getApplicationData().plugins" methodcall="getactions('add_tab_detail_r',attributes)" returnvariable="plr" />
		<!-- CFC: Get plugin actions -->
		<set name="attributes.nameOfVariable" value="pllink" />
		<invoke object="myFusebox.getApplicationData().plugins" methodcall="getactions('show_in_detail_link_wx',attributes)" returnvariable="pllink" />
		<!-- Show the image detail window -->
		<do action="ajax.exist_rendition_images" />
	</fuseaction>
	<!-- Save Detail -->
	<fuseaction name="images_detail_save">
		<!-- Params -->
		<set name="attributes.convert_to" value="" overwrite="false" />
		<set name="attributes.thefiletype" value="img" />
		<set name="attributes.comingfrom" value="#cgi.http_referer#" />
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- Action: Storage -->
		<do action="storage" />
		<!-- CFC: Get image settings -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="prefs_image()" returnvariable="attributes.qry_settings_image" />
		<set name="attributes.file_ids" value="#attributes.file_id#" />
		<!-- Rendition metadata settings -->
		<set name="attributes.option_rendition_meta" value="#attributes.qry_settings_image.set2_rendition_metadata#" />
		<!-- CFC: Get related images -->
		<invoke object="myFusebox.getApplicationData().images" methodcall="relatedimages(attributes)" returnvariable="attributes.qry_related" />
		<!-- Check if there are custom fields to be saved (we do this before because of indexing) -->
		<if condition="attributes.customfields NEQ 0">
			<true>
				<do action="custom_fields_save" />
			</true>
		</if>
		<!-- CFC: Save file detail -->
		<invoke object="myFusebox.getApplicationData().images" methodcall="update(attributes)" />
		<!-- CFC: Save XMP -->
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
		<set name="attributes.rootpath" value="#ExpandPath('../..')#" />
		<set name="attributes.cf_show" value="img" />
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- Action: Storage -->
		<do action="storage" />
		<!-- CFC: Get image settings -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="prefs_image()" returnvariable="attributes.qry_settings_image" />
		<!-- Rendition metadata settings -->
		<set name="attributes.option_rendition_meta" value="#attributes.qry_settings_image.set2_rendition_metadata#" />
		<!-- CFC: Check for custom fields -->
		<invoke object="myFusebox.getApplicationData().custom_fields" methodcall="getfields(attributes)" returnvariable="attributes.qry_cf" />
		<!-- CFC: Convert images -->	
		<invoke object="myFusebox.getApplicationData().images" methodcall="convertimage(attributes)" />
	</fuseaction>
	<!-- Images Renditions Convert -->
	<fuseaction name="rendition_images_convert">
		<!-- Param -->
		<set name="attributes.fromconverting" value="T" />
		<set name="attributes.dynpath" value="#dynpath#" />
		<set name="attributes.httphost" value="#cgi.http_host#" />
		<set name="attributes.rootpath" value="#ExpandPath('../..')#" />
		<set name="attributes.cf_show" value="img" />
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- Action: Storage -->
		<do action="storage" />
		<!-- CFC: Get image settings -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="prefs_image()" returnvariable="attributes.qry_settings_image" />
		<!-- Rendition metadata settings -->
		<set name="attributes.option_rendition_meta" value="#attributes.qry_settings_image.set2_rendition_metadata#" />
		<!-- CFC: Check for custom fields -->
		<invoke object="myFusebox.getApplicationData().custom_fields" methodcall="getfields(attributes)" returnvariable="attributes.qry_cf" />
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
		<!-- CFC: Get folder info -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="getfolder(attributes.folder_id)" returnvariable="qry_folder" />
		<!-- CFC: Get access -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="setaccess(attributes.folder_id)" returnvariable="attributes.folderaccess" />
		<!-- CFC: Check for custom fields -->
		<invoke object="myFusebox.getApplicationData().custom_fields" methodcall="getfields(attributes)" returnvariable="qry_cf" />
		<!-- CFC: Get how many comments there are -->
		<invoke object="myFusebox.getApplicationData().comments" methodcall="howmany(attributes)" returnvariable="qry_comments_total" />
		<!-- CFC: Customization -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="get_customization()" returnvariable="cs" />
		<!-- RAZ-2207 Get the groups of this user -->
		<invoke object="myFusebox.getApplicationData().groups_users" method="getGroupsOfUser" returnvariable="qry_GroupsOfUser" >
			<argument name="user_id" value="#session.theuserid#" />
			<argument name="host_id" value="#session.hostid#" />
		</invoke>
		<!-- CFC: Get config -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="get_label_set()" returnvariable="qry_label_set" />
		<!-- CFC: Get settings -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="getsettingsfromdam()" returnvariable="prefs" />
		<!-- CFC: Get plugin actions -->
		<set name="attributes.nameOfVariable" value="plwx" />
		<invoke object="myFusebox.getApplicationData().plugins" methodcall="getactions('add_tab_detail_wx',attributes)" returnvariable="plwx" />
		<!-- CFC: Get plugin actions -->
		<set name="attributes.nameOfVariable" value="plr" />
		<invoke object="myFusebox.getApplicationData().plugins" methodcall="getactions('add_tab_detail_r',attributes)" returnvariable="plr" />
		<!-- CFC: Get plugin actions -->
		<set name="attributes.nameOfVariable" value="pllink" />
		<invoke object="myFusebox.getApplicationData().plugins" methodcall="getactions('show_in_detail_link_wx',attributes)" returnvariable="pllink" />
		<!-- CFC: Get individual share options -->
		<invoke object="myFusebox.getApplicationData().global" methodcall="get_share_options(attributes)" returnvariable="qry_share_options" />
		<!-- Check if there are any aliases -->
		<invoke object="myFusebox.getApplicationData().global" methodcall="getUsageAlias(attributes.file_id)" returnvariable="qry_aliases" />
		<!-- Show the folder listing -->
		<do action="ajax.audios_detail" />
	</fuseaction>
	<!-- Save Detail -->
	<fuseaction name="audios_detail_save">
		<!-- Params -->
		<set name="attributes.comingfrom" value="#cgi.http_referer#" />
		<!-- Set the convert_to value to empty -->
		<set name="attributes.convert_to" value="" overwrite="false" />
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- Action: Storage -->
		<do action="storage" />
		<!-- Variables for API -->
		<set name="attributes.thefiletype" value="aud" />
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- Action: Storage -->
		<do action="storage" />
		<!-- CFC: Get related audios -->
		<invoke object="myFusebox.getApplicationData().audios" methodcall="relatedaudios(attributes)" returnvariable="attributes.qry_related" />
		<!-- CFC: Get video settings -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="prefs_video()" returnvariable="attributes.qry_settings_video" />
		<!-- Rendition metadata settings -->
		<set name="attributes.option_rendition_meta" value="#attributes.qry_settings_video.set2_rendition_metadata#" />
		<!-- Check if there are custom fields to be saved (we do this before because of indexing) -->
		<if condition="attributes.customfields NEQ 0">
			<true>
				<do action="custom_fields_save" />
			</true>
		</if>
		<!-- CFC: Save file detail -->
		<invoke object="myFusebox.getApplicationData().audios" methodcall="update(attributes)" />
	</fuseaction>
	<!-- Audios Renditions -->
	<fuseaction name="exist_rendition_audios">
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
		<invoke object="myFusebox.getApplicationData().folders" methodcall="setaccess(attributes.folder_id)" returnvariable="attributes.folderaccess" />
		<!-- CFC: Check for custom fields -->
		<invoke object="myFusebox.getApplicationData().custom_fields" methodcall="getfields(attributes)" returnvariable="qry_cf" />
		<!-- CFC: Get how many comments there are -->
		<invoke object="myFusebox.getApplicationData().comments" methodcall="howmany(attributes)" returnvariable="qry_comments_total" />
		<!-- CFC: Customization -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="get_customization()" returnvariable="cs" />
		<!-- CFC: Get config -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="get_label_set()" returnvariable="qry_label_set" />
		<!-- CFC: Get plugin actions -->
		<set name="attributes.nameOfVariable" value="plwx" />
		<invoke object="myFusebox.getApplicationData().plugins" methodcall="getactions('add_tab_detail_wx',attributes)" returnvariable="plwx" />
		<!-- CFC: Get plugin actions -->
		<set name="attributes.nameOfVariable" value="plr" />
		<invoke object="myFusebox.getApplicationData().plugins" methodcall="getactions('add_tab_detail_r',attributes)" returnvariable="plr" />
		<!-- CFC: Get plugin actions -->
		<set name="attributes.nameOfVariable" value="pllink" />
		<invoke object="myFusebox.getApplicationData().plugins" methodcall="getactions('show_in_detail_link_wx',attributes)" returnvariable="pllink" />
		<!-- Show the folder listing -->
		<do action="ajax.exist_rendition_audios" />
	</fuseaction>
	<!-- Convert Audio -->
	<fuseaction name="audios_convert">
		<!-- Param -->
		<set name="attributes.dynpath" value="#dynpath#" />
		<set name="attributes.httphost" value="#cgi.http_host#" />
		<set name="attributes.cf_show" value="aud" />
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- CFC: Storage -->
		<do action="storage" />
		<!-- CFC: Get video settings -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="prefs_video()" returnvariable="attributes.qry_settings_video" />
		<!-- Rendition metadata settings -->
		<set name="attributes.option_rendition_meta" value="#attributes.qry_settings_video.set2_rendition_metadata#" />
		<!-- CFC: Get detail of original audio
		<invoke object="myFusebox.getApplicationData().audios" methodcall="detail(attributes)" returnvariable="attributes.qry_detail" /> -->
		<!-- CFC: Check for custom fields -->
		<invoke object="myFusebox.getApplicationData().custom_fields" methodcall="getfields(attributes)" returnvariable="attributes.qry_cf" />
		<!-- CFC: Convert video -->
		<invoke object="myFusebox.getApplicationData().audios" methodcall="convertaudio(attributes)" />		
	</fuseaction>
	<!-- Audio Rendtions Convert-->
	<fuseaction name="rendition_audios_convert">
		<!-- Param -->
		<set name="attributes.dynpath" value="#dynpath#" />
		<set name="attributes.httphost" value="#cgi.http_host#" />
		<set name="attributes.cf_show" value="aud" />
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- CFC: Storage -->
		<do action="storage" />
		<!-- CFC: Get video settings -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="prefs_video()" returnvariable="attributes.qry_settings_video" />
		<!-- Rendition metadata settings -->
		<set name="attributes.option_rendition_meta" value="#attributes.qry_settings_video.set2_rendition_metadata#" />
		<!-- CFC: Check for custom fields -->
		<invoke object="myFusebox.getApplicationData().custom_fields" methodcall="getfields(attributes)" returnvariable="attributes.qry_cf" />
		<!-- CFC: Get detail of original audio
		<invoke object="myFusebox.getApplicationData().audios" methodcall="detail(attributes)" returnvariable="attributes.qry_detail" /> -->
		<!-- CFC: Convert video -->
		<invoke object="myFusebox.getApplicationData().audios" methodcall="convertaudio(attributes)" />		
	</fuseaction>
	<!-- Load related audios -->
	<fuseaction name="audios_detail_related">
		<!-- Get permissions of this folder -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="setaccess(attributes.folder_id)" returnvariable="attributes.folderaccess" />
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
	<!-- Save custom fields order -->
	<fuseaction name="custom_fields_save_order">
		<!-- CFC: Save field values -->
		<invoke object="myFusebox.getApplicationData().custom_fields" methodcall="saveorder(attributes)" />
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
		<!-- Put session file_id into attributes -->
		<if condition="!structkeyexists(attributes,'file_id') AND isdefined('session.file_id')">
			<true>
				<set name="attributes.file_id" value="#session.file_id#" />
			</true>
		</if>
		<!-- IF we come from search we need to set the ids from the passed form submit -->
		<if condition=" isdefined('attributes.thekind') AND attributes.thekind EQ 'search'">
			<true>
				<set name="attributes.file_id" value="#attributes.edit_ids#" />
			</true>
		</if>
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
		<!-- Set the sessions for the art -->
		<do action="store_art_values" />
		<!-- CFC: Get asset path -->
		<do action="assetpath" />
		<!-- CFC: Get user email -->
		<invoke object="myFusebox.getApplicationData().users" methodcall="user_email()" returnvariable="qryuseremail" />
		<!-- CFC: Get file detail -->
		<if condition="attributes.thetype EQ 'doc' OR attributes.thetype EQ 'other'">
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
		<!-- CFC: Get share options -->
		<invoke object="myFusebox.getApplicationData().global" methodcall="get_share_options(attributes)" returnvariable="qry_share_options" />
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
					<argument name="from" value="#attributes.from#" />
					<argument name="to" value="#attributes.to#" />
					<argument name="cc" value="#attributes.cc#" />
					<argument name="bcc" value="#attributes.bcc#" />
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
					<argument name="from" value="#attributes.from#" />
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
		<set name="session.ftp_server" value="" overwrite="false" />
		<set name="session.ftp_user" value="" overwrite="false" />
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
		<set name="attributes.createzip" value="" overwrite="false" />
		<!-- Store values in session since we need them later on some more -->
		<set name="session.ftp_server" value="#attributes.ftp_server#" />
		<set name="session.ftp_user" value="#attributes.ftp_user#" />
		<set name="session.ftp_pass" value="#attributes.ftp_pass#" />
		<set name="session.ftp_passive" value="#attributes.ftp_passive#" />
		<set name="session.zipname" value="#attributes.zipname#" />
		<set name="session.file_id" value="#attributes.file_id#" />
		<set name="session.thetype" value="#attributes.thetype#" />
		<set name="session.sendaszip" value="#attributes.sendaszip#" />
		<set name="session.createzip" value="#attributes.createzip#" />
		<set name="session.frombasket" value="F" />
		<!-- If this comes from the scheduled uploads -->
		<if condition="attributes.thetype EQ 'sched'">
			<true>
				<set name="session.frombasket" value="S" />
			</true>
		</if>
		<!-- If this is a video, image or audio -->
		<!-- <if condition="attributes.thetype EQ 'vid' OR attributes.thetype EQ 'img' OR attributes.thetype EQ 'aud' OR attributes.thetype EQ 'doc'">
			<true>
				<set name="session.artofimage" value="#attributes.artofimage#" />
			</true>
		</if> -->
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
				<invoke object="myFusebox.getApplicationData().files" methodcall="writefile(attributes)" returnvariable="attributes.thefile" />
			</true>
		</if>
		<!-- CFC: Write video to system -->
		<if condition="session.thetype EQ 'vid'">
			<true>
				<!-- CFC: Write -->
				<invoke object="myFusebox.getApplicationData().videos" methodcall="writevideo(attributes)" returnvariable="attributes.thefile" />
			</true>
		</if>
		<!-- CFC: Write audio to system -->
		<if condition="session.thetype EQ 'aud'">
			<true>
				<!-- CFC: Write -->
				<invoke object="myFusebox.getApplicationData().audios" methodcall="writeaudio(attributes)" returnvariable="attributes.thefile" />
			</true>
		</if>
		<!-- CFC: Write image to system -->
		<if condition="session.thetype EQ 'img'">
			<true>
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
	
	<!-- INCLUDE for Search -->
	<fuseaction name="search_include">
		<!-- Param -->
		<set name="attributes.newsearch" value="t" overwrite="false" />
		<set name="attributes.folder_id" value="0" overwrite="false" />
		<set name="attributes.iscol" value="F" overwrite="false" />
		<set name="attributes.showsubfolders" value="F" overwrite="false" />
		<set name="attributes.fcall" value="false" overwrite="false" />
		<set name="attributes.listdocid" value="0" overwrite="false" />
		<set name="attributes.listimgid" value="0" overwrite="false" />
		<set name="attributes.listvidid" value="0" overwrite="false" />
		<set name="attributes.listaudid" value="0" overwrite="false" />
		<set name="attributes.filename" value="" overwrite="false" />
		<set name="attributes.keywords" value="" overwrite="false" />
		<set name="attributes.description" value="" overwrite="false" />
		<set name="attributes.extension" value="" overwrite="false" />
		<set name="attributes.metadata" value="" overwrite="false" />
		<set name="attributes.andor" value="and" overwrite="false" />
		<set name="attributes.flabel" value="" overwrite="false" />
		<set name="attributes.on_day" value="" overwrite="false" />
		<set name="attributes.on_month" value="" overwrite="false" />
		<set name="attributes.on_year" value="" overwrite="false" />
		<set name="attributes.change_day" value="" overwrite="false" />
		<set name="attributes.change_month" value="" overwrite="false" />
		<set name="attributes.change_year" value="" overwrite="false" />
		<set name="attributes.thetype" value="all" overwrite="false" />
		<set name="attributes.kind" value="search" />
		<set name="attributes.sortby" value="#session.sortby#" overwrite="false" />
		<set name="session.sortby" value="#attributes.sortby#" />
		<set name="session.file_id" value="" overwrite="false" />
		<set name="session.view" value="" />
		<set name="attributes.share" value="F" overwrite="false" />
		<set name="attributes.cv" value="false" overwrite="false" />
		<!-- For smart folders -->
		<set name="attributes.from_sf" value="false" overwrite="false" />
		<set name="attributes.sf_id" value="0" overwrite="false" />
		<!-- For search with in search -->
		<set name="session.search.newsearch" value="#attributes.newsearch#" />
		<set name="session.search.folder_id"	value="#attributes.folder_id#" />
		<set name="session.search.iscol"	value="#attributes.iscol#" />
		<set name="session.search.showsubfolders"	value="#attributes.showsubfolders#" />
		<set name="session.search.listdocid"	value="#attributes.listdocid#" />
		<set name="session.search.listimgid"	value="#attributes.listimgid#" />
		<set name="session.search.listvidid"	value="#attributes.listvidid#" />
		<set name="session.search.listaudid"	value="#attributes.listaudid#" />
		<set name="session.search.filename"	value="#attributes.filename#" />
		<set name="session.search.keywords"	value="#attributes.keywords#" />
		<set name="session.search.description"	value="#attributes.description#" />
		<set name="session.search.extension"	value="#attributes.extension#" />
		<set name="session.search.metadata"	value="#attributes.metadata#" />
		<set name="session.search.andor"	value="#attributes.andor#" />
		<set name="session.search.flabel"	value="#attributes.flabel#" />
		<set name="session.search.on_day"	value="#attributes.on_day#" />
		<set name="session.search.on_month"	value="#attributes.on_month#" />
		<set name="session.search.on_year"	value="#attributes.on_year#" />
		<set name="session.search.change_day"	value="#attributes.change_day#" />
		<set name="session.search.change_month"	value="#attributes.change_month#" />
		<set name="session.search.change_year"	value="#attributes.change_year#" />
		<set name="session.search.thetype"	value="#attributes.thetype#" />
		<set name="session.search.kind"	value="#attributes.kind#" />
		<!-- XFA -->
		<xfa name="folder" value="c.folder" />
		<xfa name="fcontent" value="c.folder_content" />
		<xfa name="ffiles" value="c.folder_files" />
		<xfa name="fimages" value="c.folder_images" />
		<xfa name="fvideos" value="c.folder_videos" />
		<xfa name="faudios" value="c.folder_audios" />
		<xfa name="detaildoc" value="c.files_detail" />
		<xfa name="detailimg" value="c.images_detail" />
		<xfa name="detailvid" value="c.videos_detail" />
		<xfa name="detailaud" value="c.audios_detail" />
		<xfa name="sendemail" value="c.email_send" />
		<if condition="!attributes.cv">
			<true>
				<set name="session.customaccess" value="" />
			</true>
		</if>
		<!-- Action: Set view -->
		<do action="set_view" />
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- If we got a folder_id then we search from this folder on -->
		<if condition="attributes.folder_id NEQ '' OR attributes.folder_id NEQ 0">
			<true>
				<!-- CFC: Load recfolder list -->
				<invoke object="myFusebox.getApplicationData().folders" methodcall="recfolder(attributes.folder_id)" returnvariable="attributes.list_recfolders" />
			</true>
		</if>
		<!-- Get labels -->
		<do action="labels" />
		<!-- CFC: Custom fields -->
		<invoke object="myFusebox.getApplicationData().custom_fields" methodcall="getfieldssearch(attributes)" returnvariable="qry_cf_fields" />
		<!-- CFC: Customization -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="get_customization()" returnvariable="cs" />
		<!-- CFC: Folder access -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="setaccess(attributes.folder_id)" returnvariable="attributes.folderaccess" />
	</fuseaction>


	<fuseaction name="searchupc">
		<!-- Set search simple  -->
		<set name="attributes.search_simple" value="false" />
		<!-- Set database  -->
		<set name="attributes.database" value="#application.razuna.thedatabase#" />
		<!-- set default search count call -->
		<set name="attributes.isCountOnly" value="0" />
		<!-- set share attribute  -->
		<set name="attributes.share" value="F" overwrite="false"/>
		<!-- Include the aearch include -->
		<do action="search_include" />
		<!-- If we come from saved search we query folderaccess -->
		<if condition="attributes.from_sf">
			<true>
				<!-- CFC: Get access -->
				<invoke object="myFusebox.getApplicationData().folders" methodcall="setaccess(session.sf_id,true)" returnvariable="attributes.folderaccess" />
			</true>
		</if>
		<!-- CFC: Get placement for fields-->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="get_customization_placement(cs)" returnvariable="cs_place" />
		<set name="attributes.cs_place" value="#cs_place#" />
		<!-- ACTION: Search all -->
		<if condition="attributes.thetype EQ 'all'">
			<true>
				<!-- CFC: Customization -->
				<invoke object="myFusebox.getApplicationData().settings" methodcall="get_customization()" returnvariable="cs" />
				<set name="attributes.cs" value="#cs#" />
				<!-- CFC: Get settings -->
				<invoke object="myFusebox.getApplicationData().settings" methodcall="getsettingsfromdam()" returnvariable="prefs" />
				<!-- Check the DataBase  -->
				<if condition="attributes.database EQ 'mysql' OR attributes.database EQ 'h2'">
					<true>
						<!-- set search count call -->
						<set name="attributes.isCountOnly" value="1" />
						<!-- CFC: Combine search total count call -->
						<invoke object="myFusebox.getApplicationData().search" methodcall="search_combine_upc(attributes)" returnvariable="qry_files_count.qall" />
						<!-- Set the total -->
						<set name="qry_filecount.thetotal" value="#qry_files_count.qall.cnt#" />
						<!-- Set the session offset -->
						<if condition="qry_filecount.thetotal LTE session.rowmaxpage">
							<true>
								<set name="session.offset" value="0" />
							</true>
						</if>
						<!-- set search count call -->
						<set name="attributes.isCountOnly" value="0" />
						<!-- CFC: Combine searches -->
						<invoke object="myFusebox.getApplicationData().search" methodcall="search_combine_upc(attributes)" returnvariable="qry_files.qall" />
					</true>
					<false>
						<!-- CFC: Combine searches -->
						<invoke object="myFusebox.getApplicationData().search" methodcall="search_combine_upc(attributes)" returnvariable="qry_files.qall" />
						<!-- Set results into different variable name -->
						<set name="qry_files_count.qall" value="#qry_files.qall#" />
						<!-- Set the total -->
						<set name="qry_filecount.thetotal" value="#qry_files_count.qall.cnt#" />
					</false>
				</if>
			</true>
		</if>
		<!-- ACTION: Search Files -->
		<if condition="attributes.thetype EQ 'doc'">
			<true>
				<!-- Check the DataBase  -->
				<if condition="attributes.database EQ 'mysql' OR attributes.database EQ 'h2'">
					<true>
						<!-- CFC: Customization -->
						<invoke object="myFusebox.getApplicationData().settings" methodcall="get_customization()" returnvariable="cs" />
						<set name="attributes.cs" value="#cs#" />
						<!-- CFC: Get settings -->
						<invoke object="myFusebox.getApplicationData().settings" methodcall="getsettingsfromdam()" returnvariable="prefs" />
						<!-- set search count call -->
						<set name="attributes.isCountOnly" value="1" />
						<!-- CFC: Combine search total count call -->
						<invoke object="myFusebox.getApplicationData().search" methodcall="search_combine_upc(attributes)" returnvariable="qry_files_count.qall" />
						<!-- Set the total -->
						<set name="qry_filecount.thetotal" value="#qry_files_count.qall.cnt#" />
						<!-- Set the session offset -->
						<if condition="qry_filecount.thetotal LTE session.rowmaxpage">
							<true>
								<set name="session.offset" value="0" />
							</true>
						</if>
						<!-- set search count call -->
						<set name="attributes.isCountOnly" value="0" />
						<!-- Search -->
						<do action="search_files" />
						<!-- Set results into different variable name -->
						<set name="qry_files.qall" value="#qry_results_files#" />
						<!-- Put id's into lists -->
						<set name="attributes.listdocid" value="#valuelist(qry_results_files.id)#" />
					</true>
					<false>
						<!-- set search count call -->
						<set name="attributes.isCountOnly" value="0" />
						<!-- Search -->
						<do action="search_files" />
						<!-- Set results into different variable name -->
						<set name="qry_files.qall" value="#qry_results_files#" />
						<!-- Put id's into lists -->
						<set name="attributes.listdocid" value="#valuelist(qry_results_files.id)#" />
						<!-- Set the total -->
						<set name="qry_filecount.thetotal" value="#qry_files.qall.cnt#" />
					</false>
				</if>
			</true>
		</if>
		<!-- ACTION: Search Images -->
		<if condition="attributes.thetype EQ 'img'">
			<true>
				<!-- Check the DataBase  -->
				<if condition="attributes.database EQ 'mysql' OR attributes.database EQ 'h2'">
					<true>
						<!-- CFC: Customization -->
						<invoke object="myFusebox.getApplicationData().settings" methodcall="get_customization()" returnvariable="cs" />
						<set name="attributes.cs" value="#cs#" />
						<!-- CFC: Get settings -->
						<invoke object="myFusebox.getApplicationData().settings" methodcall="getsettingsfromdam()" returnvariable="prefs" />
						<!-- set search count call -->
						<set name="attributes.isCountOnly" value="1" />
						<!-- CFC: Combine search total count call -->
						<invoke object="myFusebox.getApplicationData().search" methodcall="search_combine_upc(attributes)" returnvariable="qry_files_count.qall" />
						<!-- Set the total -->
						<set name="qry_filecount.thetotal" value="#qry_files_count.qall.cnt#" />
						<!-- Set the session offset -->
						<if condition="qry_filecount.thetotal LTE session.rowmaxpage">
							<true>
								<set name="session.offset" value="0" />
							</true>
						</if>
						<!-- set search count call -->
						<set name="attributes.isCountOnly" value="0" />
						<!-- Search -->
						<do action="search_images" />
						<!-- Set results into different variable name -->
						<set name="qry_files.qall" value="#qry_results_images#" />
						<!-- Put id's into lists -->
						<set name="attributes.listimgid" value="#valuelist(qry_results_images.id)#" />
					</true>
					<false>
						<!-- set search count call -->
						<set name="attributes.isCountOnly" value="0" />
						<!-- Search -->
						<do action="search_images" />
						<!-- Set results into different variable name -->
						<set name="qry_files.qall" value="#qry_results_images#" />
						<!-- Put id's into lists -->
						<set name="attributes.listimgid" value="#valuelist(qry_results_images.id)#" />
						<!-- Set the total -->
						<set name="qry_filecount.thetotal" value="#qry_files.qall.cnt#" />
					</false>
				</if>
			</true>
		</if>
		<!-- ACTION: Search Videos -->
		<if condition="attributes.thetype EQ 'vid'">
			<true>
				<!-- Check the DataBase  -->
				<if condition="attributes.database EQ 'mysql' OR attributes.database EQ 'h2'">
					<true>
						<!-- CFC: Customization -->
						<invoke object="myFusebox.getApplicationData().settings" methodcall="get_customization()" returnvariable="cs" />
						<set name="attributes.cs" value="#cs#" />
						<!-- CFC: Get settings -->
						<invoke object="myFusebox.getApplicationData().settings" methodcall="getsettingsfromdam()" returnvariable="prefs" />
						<!-- set search count call -->
						<set name="attributes.isCountOnly" value="1" />
						<!-- CFC: Combine search total count call -->
						<invoke object="myFusebox.getApplicationData().search" methodcall="search_combine_upc(attributes)" returnvariable="qry_files_count.qall" />
						<!-- Set the total -->
						<set name="qry_filecount.thetotal" value="#qry_files_count.qall.cnt#" />
						<!-- Set the session offset -->
						<if condition="qry_filecount.thetotal LTE session.rowmaxpage">
							<true>
								<set name="session.offset" value="0" />
							</true>
						</if>
						<!-- set search count call -->
						<set name="attributes.isCountOnly" value="0" />
						<!-- Search -->
						<do action="search_videos" />
						<!-- Set results into different variable name -->
						<set name="qry_files.qall" value="#qry_results_videos#" />
						<!-- Put id's into lists -->
						<set name="attributes.listvidid" value="#valuelist(qry_results_videos.id)#" />		
					</true>
					<false>
						<!-- set search count call -->
						<set name="attributes.isCountOnly" value="0" />
						<!-- Search -->
						<do action="search_videos" />
						<!-- Set results into different variable name -->
						<set name="qry_files.qall" value="#qry_results_videos#" />
						<!-- Put id's into lists -->
						<set name="attributes.listvidid" value="#valuelist(qry_results_videos.id)#" />
						<!-- Set the total -->
						<set name="qry_filecount.thetotal" value="#qry_files.qall.cnt#" />
					</false>
				</if>
			</true>
		</if>
		<!-- ACTION: Search Audios -->
		<if condition="attributes.thetype EQ 'aud'">
			<true>
				<!-- Check the DataBase  -->
				<if condition="attributes.database EQ 'mysql' OR attributes.database EQ 'h2'">
					<true>
						<!-- CFC: Customization -->
						<invoke object="myFusebox.getApplicationData().settings" methodcall="get_customization()" returnvariable="cs" />
						<set name="attributes.cs" value="#cs#" />
						<!-- CFC: Get settings -->
						<invoke object="myFusebox.getApplicationData().settings" methodcall="getsettingsfromdam()" returnvariable="prefs" />
						<!-- set search count call -->
						<set name="attributes.isCountOnly" value="1" />
						<!-- CFC: Combine search total count call -->
						<invoke object="myFusebox.getApplicationData().search" methodcall="search_combine_upc(attributes)" returnvariable="qry_files_count.qall" />
						<!-- Set the total -->
						<set name="qry_filecount.thetotal" value="#qry_files_count.qall.cnt#" />
						<!-- Set the session offset -->
						<if condition="qry_filecount.thetotal LTE session.rowmaxpage">
							<true>
								<set name="session.offset" value="0" />
							</true>
						</if>
						<!-- set search count call -->
						<set name="attributes.isCountOnly" value="0" />
						<!-- Search -->
						<do action="search_audios" />
						<!-- Set results into different variable name -->
						<set name="qry_files.qall" value="#qry_results_audios#" />
						<!-- Put id's into lists -->
						<set name="attributes.listaudid" value="#valuelist(qry_results_audios.id)#" />
					</true>
					<false>
						<!-- set search count call -->
						<set name="attributes.isCountOnly" value="0" />
						<!-- Search -->
						<do action="search_audios" />
						<!-- Set results into different variable name -->
						<set name="qry_files.qall" value="#qry_results_audios#" />
						<!-- Put id's into lists -->
						<set name="attributes.listaudid" value="#valuelist(qry_results_audios.id)#" />
						<!-- Set the total -->
						<set name="qry_filecount.thetotal" value="#qry_files.qall.cnt#" />
					</false>
				</if>
			</true>
		</if>
		<!-- Show -->
		<if condition="!structkeyexists(attributes,'mobile_view')">
			<true>
				<if condition="!structkeyexists(attributes,'iscopymetadata')">
					<true>
						<if condition="!attributes.fcall">
							<true>
								<do action="ajax.search" />
							</true>
							<false>
								<do action="folder_content_results" />
							</false>
						</if>
					</true>
				</if>
			</true>
		</if>
	</fuseaction>
	
	<!-- Simple Search -->
	<fuseaction name="search_simple">
		<!-- Params -->
		<!-- RAZ-2708 set value to session -->
		<set name="session.search.labels_all" value="" />
		<set name="session.search.labels_img" value="" />
		<set name="session.search.labels_aud" value="" />
		<set name="session.search.labels_vid" value="" />
		<set name="session.search.labels_doc" value="" />
		<!-- Set search simple  -->
		<set name="attributes.search_simple" value="true" />
		<!-- Set database  -->
		<set name="attributes.database" value="#application.razuna.thedatabase#" />
		<!-- set default search count call -->
		<set name="attributes.isCountOnly" value="0" />
		<!-- set share attribute  -->
		<set name="attributes.share" value="F" overwrite="false"/>

		<!-- Include the aearch include -->
		<do action="search_include" />
		<!-- If we come from saved search we query folderaccess -->
		<if condition="attributes.from_sf">
			<true>
				<!-- CFC: Get access -->
				<invoke object="myFusebox.getApplicationData().folders" methodcall="setaccess(session.sf_id,true)" returnvariable="attributes.folderaccess" />
			</true>
		</if>
		<!-- ACTION: Search all -->
		<if condition="attributes.thetype EQ 'all'">
			<true>
					<!-- XFA -->
					<xfa name="filedetail" value="c.files_detail" />
					<xfa name="imagedetail" value="c.images_detail" />
					<xfa name="videodetail" value="c.videos_detail" />
					<xfa name="fvideosloader" value="c.folder_videos_show" />
					<xfa name="audiodetail" value="c.audios_detail" />
					<!-- CFC: Customization -->
					<invoke object="myFusebox.getApplicationData().settings" methodcall="get_customization()" returnvariable="cs" />
					<set name="attributes.cs" value="#cs#" />
<!-- CFC: Get settings -->
				<invoke object="myFusebox.getApplicationData().settings" methodcall="getsettingsfromdam()" returnvariable="prefs" />
					<!-- CFC: Get placement for fields-->
					<invoke object="myFusebox.getApplicationData().settings" methodcall="get_customization_placement(cs)" returnvariable="cs_place" />
					<set name="attributes.cs_place" value="#cs_place#" />
					<!-- CFC: Get settings -->
				<invoke object="myFusebox.getApplicationData().folders" methodcall="getbreadcrumb(attributes.folder_id)" returnvariable="qry_breadcrumb" />	
				<!-- Check the DataBase  -->
				<if condition="attributes.database EQ 'mysql' OR attributes.database EQ 'h2'">
					<true>
						<!-- set search count call -->
						<set name="attributes.isCountOnly" value="1" />
						<!-- CFC: Combine search total count call -->
						<invoke object="myFusebox.getApplicationData().search" methodcall="search_combine(attributes)" returnvariable="qry_files_count.qall" />
						<!-- Set the total -->
						<set name="qry_filecount.thetotal" value="#qry_files_count.qall.cnt#" />
						<!-- Set the session offset -->
						<if condition="qry_filecount.thetotal LTE session.rowmaxpage">
							<true>
								<set name="session.offset" value="0" />
							</true>
						</if>
						<!-- set search count call -->
						<set name="attributes.isCountOnly" value="0" />
						<!-- CFC: Combine searches -->
						<invoke object="myFusebox.getApplicationData().search" methodcall="search_combine(attributes)" returnvariable="qry_files.qall" />
					</true>
					<false>
						<!-- CFC: Combine searches -->
						<invoke object="myFusebox.getApplicationData().search" methodcall="search_combine(attributes)" returnvariable="qry_files.qall" />
						<!-- Set results into different variable name -->
						<set name="qry_files_count.qall" value="#qry_files.qall#" />
						<!-- Set the total -->
						<set name="qry_filecount.thetotal" value="#qry_files_count.qall.cnt#" />
					</false>
				</if>
			</true>
		</if>
		<!-- ACTION: Search Files -->
		<if condition="attributes.thetype EQ 'doc'">
			<true>
				<!-- Check the DataBase  -->
				<if condition="attributes.database EQ 'mysql' OR attributes.database EQ 'h2'">
					<true>
						<!-- CFC: Customization -->
						<invoke object="myFusebox.getApplicationData().settings" methodcall="get_customization()" returnvariable="cs" />
						<set name="attributes.cs" value="#cs#" />
						<!-- CFC: Get placement for fields-->
						<invoke object="myFusebox.getApplicationData().settings" methodcall="get_customization_placement(cs)" returnvariable="cs_place" />
						<set name="attributes.cs_place" value="#cs_place#" />
						<!-- CFC: Get settings -->
						<invoke object="myFusebox.getApplicationData().settings" methodcall="getsettingsfromdam()" returnvariable="prefs" />
						<!-- set search count call -->
						<set name="attributes.isCountOnly" value="1" />
						<!-- CFC: Combine search total count call -->
						<invoke object="myFusebox.getApplicationData().search" methodcall="search_combine(attributes)" returnvariable="qry_files_count.qall" />
						<!-- Set the total -->
						<set name="qry_filecount.thetotal" value="#qry_files_count.qall.cnt#" />
						<!-- Set the session offset -->
						<if condition="qry_filecount.thetotal LTE session.rowmaxpage">
							<true>
								<set name="session.offset" value="0" />
							</true>
						</if>
						<!-- set search count call -->
						<set name="attributes.isCountOnly" value="0" />
						<!-- Search -->
						<do action="search_files" />
						<!-- Set results into different variable name -->
						<set name="qry_files.qall" value="#qry_results_files#" />
						<!-- Put id's into lists -->
						<set name="attributes.listdocid" value="#valuelist(qry_results_files.id)#" />
					</true>
					<false>
						<!-- set search count call -->
						<set name="attributes.isCountOnly" value="0" />
						<!-- Search -->
						<do action="search_files" />
						<!-- Set results into different variable name -->
						<set name="qry_files.qall" value="#qry_results_files#" />
						<!-- Put id's into lists -->
						<set name="attributes.listdocid" value="#valuelist(qry_results_files.id)#" />
						<!-- Set the total -->
						<set name="qry_filecount.thetotal" value="#qry_files.qall.cnt#" />
					</false>
				</if>
			</true>
		</if>
		<!-- ACTION: Search Images -->
		<if condition="attributes.thetype EQ 'img'">
			<true>
				<!-- Check the DataBase  -->
				<if condition="attributes.database EQ 'mysql' OR attributes.database EQ 'h2'">
					<true>
						<!-- CFC: Customization -->
						<invoke object="myFusebox.getApplicationData().settings" methodcall="get_customization()" returnvariable="cs" />
						<set name="attributes.cs" value="#cs#" />
						<!-- CFC: Get placement for fields-->
						<invoke object="myFusebox.getApplicationData().settings" methodcall="get_customization_placement(cs)" returnvariable="cs_place" />
						<set name="attributes.cs_place" value="#cs_place#" />
						<!-- CFC: Get settings -->
						<invoke object="myFusebox.getApplicationData().settings" methodcall="getsettingsfromdam()" returnvariable="prefs" />
						<!-- set search count call -->
						<set name="attributes.isCountOnly" value="1" />
						<!-- CFC: Combine search total count call -->
						<invoke object="myFusebox.getApplicationData().search" methodcall="search_combine(attributes)" returnvariable="qry_files_count.qall" />
						<!-- Set the total -->
						<set name="qry_filecount.thetotal" value="#qry_files_count.qall.cnt#" />
						<!-- Set the session offset -->
						<if condition="qry_filecount.thetotal LTE session.rowmaxpage">
							<true>
								<set name="session.offset" value="0" />
							</true>
						</if>
						<!-- set search count call -->
						<set name="attributes.isCountOnly" value="0" />
						<!-- Search -->
						<do action="search_images" />
						<!-- Set results into different variable name -->
						<set name="qry_files.qall" value="#qry_results_images#" />
						<!-- Put id's into lists -->
						<set name="attributes.listimgid" value="#valuelist(qry_results_images.id)#" />
					</true>
					<false>
						<!-- set search count call -->
						<set name="attributes.isCountOnly" value="0" />
						<!-- Search -->
						<do action="search_images" />
						<!-- Set results into different variable name -->
						<set name="qry_files.qall" value="#qry_results_images#" />
						<!-- Put id's into lists -->
						<set name="attributes.listimgid" value="#valuelist(qry_results_images.id)#" />
						<!-- Set the total -->
						<set name="qry_filecount.thetotal" value="#qry_files.qall.cnt#" />
					</false>
				</if>
			</true>
		</if>
		<!-- ACTION: Search Videos -->
		<if condition="attributes.thetype EQ 'vid'">
			<true>
				<!-- Check the DataBase  -->
				<if condition="attributes.database EQ 'mysql' OR attributes.database EQ 'h2'">
					<true>
						<!-- CFC: Customization -->
						<invoke object="myFusebox.getApplicationData().settings" methodcall="get_customization()" returnvariable="cs" />
						<set name="attributes.cs" value="#cs#" />
						<!-- CFC: Get placement for fields-->
						<invoke object="myFusebox.getApplicationData().settings" methodcall="get_customization_placement(cs)" returnvariable="cs_place" />
						<set name="attributes.cs_place" value="#cs_place#" />
						<!-- CFC: Get settings -->
						<invoke object="myFusebox.getApplicationData().settings" methodcall="getsettingsfromdam()" returnvariable="prefs" />
						<!-- set search count call -->
						<set name="attributes.isCountOnly" value="1" />
						<!-- CFC: Combine search total count call -->
						<invoke object="myFusebox.getApplicationData().search" methodcall="search_combine(attributes)" returnvariable="qry_files_count.qall" />
						<!-- Set the total -->
						<set name="qry_filecount.thetotal" value="#qry_files_count.qall.cnt#" />
						<!-- Set the session offset -->
						<if condition="qry_filecount.thetotal LTE session.rowmaxpage">
							<true>
								<set name="session.offset" value="0" />
							</true>
						</if>
						<!-- set search count call -->
						<set name="attributes.isCountOnly" value="0" />
						<!-- Search -->
						<do action="search_videos" />
						<!-- Set results into different variable name -->
						<set name="qry_files.qall" value="#qry_results_videos#" />
						<!-- Put id's into lists -->
						<set name="attributes.listvidid" value="#valuelist(qry_results_videos.id)#" />		
					</true>
					<false>
						<!-- set search count call -->
						<set name="attributes.isCountOnly" value="0" />
						<!-- Search -->
						<do action="search_videos" />
						<!-- Set results into different variable name -->
						<set name="qry_files.qall" value="#qry_results_videos#" />
						<!-- Put id's into lists -->
						<set name="attributes.listvidid" value="#valuelist(qry_results_videos.id)#" />
						<!-- Set the total -->
						<set name="qry_filecount.thetotal" value="#qry_files.qall.cnt#" />
					</false>
				</if>
			</true>
		</if>
		<!-- ACTION: Search Audios -->
		<if condition="attributes.thetype EQ 'aud'">
			<true>
				<!-- Check the DataBase  -->
				<if condition="attributes.database EQ 'mysql' OR attributes.database EQ 'h2'">
					<true>
						<!-- CFC: Customization -->
						<invoke object="myFusebox.getApplicationData().settings" methodcall="get_customization()" returnvariable="cs" />
						<set name="attributes.cs" value="#cs#" />
						<!-- CFC: Get placement for fields-->
						<invoke object="myFusebox.getApplicationData().settings" methodcall="get_customization_placement(cs)" returnvariable="cs_place" />
						<set name="attributes.cs_place" value="#cs_place#" />
						<!-- CFC: Get settings -->
						<invoke object="myFusebox.getApplicationData().settings" methodcall="getsettingsfromdam()" returnvariable="prefs" />
						<!-- set search count call -->
						<set name="attributes.isCountOnly" value="1" />
						<!-- CFC: Combine search total count call -->
						<invoke object="myFusebox.getApplicationData().search" methodcall="search_combine(attributes)" returnvariable="qry_files_count.qall" />
						<!-- Set the total -->
						<set name="qry_filecount.thetotal" value="#qry_files_count.qall.cnt#" />
						<!-- Set the session offset -->
						<if condition="qry_filecount.thetotal LTE session.rowmaxpage">
							<true>
								<set name="session.offset" value="0" />
							</true>
						</if>
						<!-- set search count call -->
						<set name="attributes.isCountOnly" value="0" />
						<!-- Search -->
						<do action="search_audios" />
						<!-- Set results into different variable name -->
						<set name="qry_files.qall" value="#qry_results_audios#" />
						<!-- Put id's into lists -->
						<set name="attributes.listaudid" value="#valuelist(qry_results_audios.id)#" />
					</true>
					<false>
						<!-- set search count call -->
						<set name="attributes.isCountOnly" value="0" />
						<!-- Search -->
						<do action="search_audios" />
						<!-- Set results into different variable name -->
						<set name="qry_files.qall" value="#qry_results_audios#" />
						<!-- Put id's into lists -->
						<set name="attributes.listaudid" value="#valuelist(qry_results_audios.id)#" />
						<!-- Set the total -->
						<set name="qry_filecount.thetotal" value="#qry_files.qall.cnt#" />
					</false>
				</if>
			</true>
		</if>
		<!-- Show -->
		<if condition="!structkeyexists(attributes,'mobile_view')">
			<true>
				<if condition="!structkeyexists(attributes,'iscopymetadata')">
					<true>
						<if condition="!attributes.fcall">
							<true>
								<do action="ajax.search" />
							</true>
							<false>
								<do action="folder_content_results" />
							</false>
						</if>
					</true>
				</if>
			</true>
		</if>
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
		<!-- If we got a folder_id then we search from this folder on -->
		<if condition="attributes.folder_id NEQ '' OR attributes.folder_id NEQ 0">
			<true>
				<!-- CFC: Load recfolder list -->
				<invoke object="myFusebox.getApplicationData().folders" methodcall="recfolder(attributes.folder_id)" returnvariable="attributes.list_recfolders" />
			</true>
		</if>
		<!-- XFA -->
		<xfa name="folder" value="c.folder" />
		<!-- ACTION: Search Files -->
		<do action="search_files" />
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- Get labels -->
		<do action="labels" />
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
		<!-- If we got a folder_id then we search from this folder on -->
		<if condition="attributes.folder_id NEQ '' OR attributes.folder_id NEQ 0">
			<true>
				<!-- CFC: Load recfolder list -->
				<invoke object="myFusebox.getApplicationData().folders" methodcall="recfolder(attributes.folder_id)" returnvariable="attributes.list_recfolders" />
			</true>
		</if>
		<!-- XFA -->
		<xfa name="folder" value="c.folder" />
		<!-- ACTION: Search Files -->
		<do action="search_images" />
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- Get labels -->
		<do action="labels" />
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
		<!-- If we got a folder_id then we search from this folder on -->
		<if condition="attributes.folder_id NEQ '' OR attributes.folder_id NEQ 0">
			<true>
				<!-- CFC: Load recfolder list -->
				<invoke object="myFusebox.getApplicationData().folders" methodcall="recfolder(attributes.folder_id)" returnvariable="attributes.list_recfolders" />
			</true>
		</if>
		<!-- XFA -->
		<xfa name="folder" value="c.folder" />
		<!-- ACTION: Search Files -->
		<do action="search_videos" />
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- Get labels -->
		<do action="labels" />
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
		<!-- If we got a folder_id then we search from this folder on -->
		<if condition="attributes.folder_id NEQ '' OR attributes.folder_id NEQ 0">
			<true>
				<!-- CFC: Load recfolder list -->
				<invoke object="myFusebox.getApplicationData().folders" methodcall="recfolder(attributes.folder_id)" returnvariable="attributes.list_recfolders" />
			</true>
		</if>
		<!-- XFA -->
		<xfa name="folder" value="c.folder" />
		<!-- ACTION: Search Files -->
		<do action="search_audios" />
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- Get labels -->
		<do action="labels" />
		<!-- CFC: Custom fields -->
		<invoke object="myFusebox.getApplicationData().custom_fields" methodcall="getfieldssearch(attributes)" returnvariable="qry_cf_fields" />
		<!-- Show -->
		<do action="ajax.search" />
	</fuseaction>
	
	<!-- Search: Files -->
	<fuseaction name="search_files">
		<!-- XFA -->
		<xfa name="filedetail" value="c.files_detail" />
		<!-- CFC: Customization -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="get_customization()" returnvariable="cs" />
		<set name="attributes.cs" value="#cs#" />
		<!-- CFC: Search Files -->
		<invoke object="myFusebox.getApplicationData().search" methodcall="search_files(attributes)" returnvariable="qry_results_files" />
	</fuseaction>
	<!-- Search: Images -->
	<fuseaction name="search_images">
		<!-- XFA -->
		<xfa name="imagedetail" value="c.images_detail" />
		<!-- CFC: Customization -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="get_customization()" returnvariable="cs" />
		<set name="attributes.cs" value="#cs#" />
		<!-- CFC: Search Images -->
		<invoke object="myFusebox.getApplicationData().search" methodcall="search_images(attributes)" returnvariable="qry_results_images" />
	</fuseaction>
	<!-- Search: Videos -->
	<fuseaction name="search_videos">
		<!-- XFA -->
		<xfa name="videodetail" value="c.videos_detail" />
		<xfa name="fvideosloader" value="c.folder_videos_show" />
		<!-- CFC: Customization -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="get_customization()" returnvariable="cs" />
		<set name="attributes.cs" value="#cs#" />
		<!-- CFC: Search Videos -->
		<invoke object="myFusebox.getApplicationData().search" methodcall="search_videos(attributes)" returnvariable="qry_results_videos" />
	</fuseaction>
	<!-- Search: Audios -->
	<fuseaction name="search_audios">
		<!-- XFA -->
		<xfa name="audiodetail" value="c.audios_detail" />
		<!-- CFC: Customization -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="get_customization()" returnvariable="cs" />
		<set name="attributes.cs" value="#cs#" />
		<!-- CFC: Search Audios -->
		<invoke object="myFusebox.getApplicationData().search" methodcall="search_audios(attributes)" returnvariable="qry_results_audios" />
	</fuseaction>
	
	<!-- Search: AJAX -->
	<fuseaction name="search_suggest">
		<!-- CFC: Search Files -->
		<invoke object="myFusebox.getApplicationData().search" methodcall="search_suggest(attributes.term)" returnvariable="qry_suggest" />
	</fuseaction>
	
	<!-- Search: Advanced -->
	<fuseaction name="search_advanced">
		<!-- Params -->
		<set name="session.search.labels_all" value="" />
		<set name="session.search.labels_img" value="" />
		<set name="session.search.labels_aud" value="" />
		<set name="session.search.labels_vid" value="" />
		<set name="session.search.labels_doc" value="" />
		<if condition="structkeyexists(attributes,'fromshare')">
			<true>
				<set name="attributes.fromshare" value="true" />
			</true>
			<false>
				<set name="attributes.fromshare" value="false" />
			</false>
		</if>
		<!-- Get labels -->
		<do action="labels" />
		<!-- CFC: Customization -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="get_customization()" returnvariable="cs" />
		<!-- CFC: Custom fields -->
		<invoke object="myFusebox.getApplicationData().custom_fields" methodcall="getfieldssearch(attributes)" returnvariable="qry_fields" />
		<!-- if we need to query the search selection folders -->
		<if condition="cs.search_selection">
			<true>
				<invoke object="myFusebox.getApplicationData().folders" methodcall="getInSearchSelection()" returnvariable="qry_searchselection" />
			</true>
		</if>
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
		<set name="attributes.iscol" value="f" overwrite="false" />
		<set name="attributes.kind" value="" overwrite="false" />
		<set name="attributes.fromtrash" value="false" overwrite="false" />
		<if condition="session.type NEQ 'movefile' AND session.type NEQ 'movefolder' AND session.type NEQ 'copyfolder' AND session.type NEQ 'restorefolder' AND session.type NEQ 'restorecolfolder'">
			<true>
				<set name="session.thefolderorg" value="0" />
			</true>
		</if>
		<!-- For main page upload do... -->
		<if condition="attributes.folder_id EQ 'x'">
			<true>
				<set name="session.type" value="uploadinto" />
				<set name="session.savehere" value="c.asset_add" />
			</true>
		</if>
		<!-- For customization do... -->
		<if condition="session.type EQ 'customization' OR session.type EQ 'groups_detail'">
			<true>
				<set name="session.savehere" value="" />
			</true>
		</if>
		<!-- For scheduled uploads do... -->
		<if condition="session.type EQ 'scheduler'">
			<true>
				<set name="session.savehere" value="" />
			</true>
		</if>
		<!-- For scheduled uploads do... -->
		<if condition="session.type EQ 'plugin'">
			<true>
				<set name="session.savehere" value="" />
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
		<!-- If we restore the asset record in this collection do...-->
		<if condition="session.type EQ 'restore_collection_file'">
			<true>
				<set name="session.savehere" value="c.restore_col_file_do" />
			</true>
		</if>
		<!-- If we restore all collection files in this collection do..-->
		<if condition="session.type EQ 'restoreallcollectionfiles'">
			<true>
				<set name="session.savehere" value="c.restore_all_col_file_do" />
			</true>
		</if>
		<!-- If we restore selected  collection files do..-->
		<if condition="session.type EQ 'restoreselectedcolfiles'">
			<true>
				<set name="session.savehere" value="c.restore_selected_col_file_do" />
			</true>
		</if>
		<!-- If we restore all collection-->
		<if condition="session.type EQ 'restoreallcollections'">
			<true>
				<set name="session.savehere" value="c.restore_all_collections_do" />
			</true>
		</if>
		<!-- If we restore selected collection-->
		<if condition="session.type EQ 'restoreselectedcollection'">
			<true>
				<set name="session.savehere" value="c.restore_selected_collections_do" />
			</true>
		</if>
		<!-- If we restore the collection in this directory do...-->
		<if condition="session.type EQ 'restore_collection'">
			<true>
				<set name="session.savehere" value="c.restore_collection_do" />
			</true>
		</if>
		<!-- If we restore collection folder in the trash-->
		<if condition="session.type EQ 'restorecolfolder'">
			<true>
				<set name="session.savehere" value="c.restore_col_folder_do" />
			</true>
		</if>
		<!-- If we restore all collection folder in the trash-->
		<if condition="session.type EQ 'restorecolfolderall'">
			<true>
				<set name="session.savehere" value="c.restore_col_folder_all_do" />
			</true>
		</if>
		<!-- If we restore selected collection folder in the trash -->
		<if condition="session.type EQ 'restoreselectedcolfolder'">
			<true>
				<set name="session.savehere" value="c.restore_selected_col_folder_do" />
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
		<!-- If we copy a FOLDER in this folder do... -->
		<if condition="session.type EQ 'copyfolder'">
			<true>
				<set name="session.savehere" value="c.copy_folder" />
				<!--<set name="session.type" value="movefolder" />-->
			</true>
		</if>
		<!-- Choose the folder for get asset-->
		<if condition="session.type EQ 'copymetadata'">
			<true>
				<set name="session.savehere" value="c.get_meta_folder" />
			</true>
		</if>
		<!-- If we restore a file in this folder do... -->
		<if condition="session.type EQ 'restorefile'">
			<true>
				<set name="session.savehere" value="c.restore_file_do" />
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
		<!-- If we download from smart folders -->
		<if condition="session.type EQ 'sf_download'">
			<true>
				<set name="session.savehere" value="c.sf_load_download" />
			</true>
		</if>
		<!-- If we restore all files in trash -->
		<if condition="session.type EQ 'restorefileall'">
			<true>
				<set name="session.savehere" value="c.restore_allfile_do" />
			</true>
		</if>
		<!-- If we restore all folders in trash -->
		<if condition="session.type EQ 'restorefolderall'">
			<true>
				<set name="session.savehere" value="c.restore_allfolder_do" />
			</true>
		</if>
		<!-- If we restore the folder in trash -->
		<if condition="session.type EQ 'restorefolder'">
			<true>
				<set name="session.savehere" value="c.restore_folder_do" />
			</true>
		</if>
		<!-- If we restore the selected folder in trash -->
		<if condition="session.type EQ 'restoreselectedfolders'">
			<true>
				<set name="session.savehere" value="c.restore_selected_folders_do" />
			</true>
		</if>
		<!-- If we restore selected files in trash -->
		<if condition="session.type EQ 'restoreselectedfiles'">
			<true>
				<set name="session.savehere" value="c.restore_selected_files_do" />
			</true>
		</if>
		<!-- If we create an alias -->
		<if condition="session.type EQ 'alias'">
			<true>
				<set name="session.savehere" value="c.alias_create" />
			</true>
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
	
	<!-- Alias -->
	<fuseaction name="alias_create">
		<invoke object="myFusebox.getApplicationData().global" methodcall="alias_create(attributes)" />
	</fuseaction>

	<!-- Alias Remove -->
	<fuseaction name="alias_remove">
		<!-- CFC -->
		<invoke object="myFusebox.getApplicationData().global" methodcall="alias_remove(attributes)" />
		<!-- Show -->
		<if condition="attributes.loaddiv EQ 'content'">
			<true>
				<do action="folder" />
			</true>
		</if>
		<if condition="attributes.loaddiv EQ 'img'">
			<true>
				<do action="folder_images" />
			</true>
		</if>
		<if condition="attributes.loaddiv EQ 'aud'">
			<true>
				<do action="folder_audios" />
			</true>
		</if>
		<if condition="attributes.loaddiv EQ 'vid'">
			<true>
				<do action="folder_videos" />
			</true>
		</if>
		<if condition="attributes.loaddiv EQ 'other' OR attributes.loaddiv EQ 'pdf' OR attributes.loaddiv contains 'doc' OR attributes.loaddiv contains 'xls' OR attributes.loaddiv EQ 'file'">
			<true>
				<do action="folder_files" />
			</true>
		</if>

	</fuseaction>

	<!-- Set params for the choose folder dialog -->
	<fuseaction name="move_file">
		<!-- Param -->
		<set name="session.type" value="#attributes.type#" />
		<set name="session.thetype" value="#attributes.thetype#" />
		<!-- Put folder id into session if the attribute exsists -->
		<if condition="structkeyexists(attributes,'folder_id')">
			<true>
				<set name="session.thefolderorg" value="#attributes.folder_id#" />
			</true>
		</if>
		<!-- Put file id into session if the attribute exsists -->
		<if condition="structkeyexists(attributes,'file_id')">
			<true>
				<set name="session.thefileid" value="#attributes.file_id#" />
			</true>
		</if>
		<!-- If we copy a folder -->
		<if condition="attributes.type EQ 'copyfolder'">
			<true>
				<set name="session.thefolderorglevel" value="#attributes.folder_level#" />
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
	
	<!-- Copy Metadata -->
	<fuseaction name="copy_metadata">
		<if condition="attributes.what EQ 'images'">
			<true>
				<!-- XFA -->
				<xfa name="save" value="c.copy_metadata_image_do" />
			</true>
		</if>
		<if condition="attributes.what EQ 'audios'">
			<true>
				<!-- XFA -->
				<xfa name="save" value="c.copy_metadata_audio_do" />
			</true>
		</if>
		<if condition="attributes.what EQ 'videos'">
			<true>
				<!-- XFA -->
				<xfa name="save" value="c.copy_metadata_video_do" />
			</true>
		</if>
		<if condition="attributes.what EQ 'files'">
			<true>
				<!-- XFA -->
				<xfa name="save" value="c.copy_metadata_files_do" />
			</true>
		</if>
		<do action="ajax.copy_metadata" />
	</fuseaction>
	<!-- Copy Metadata to assign asset -->
	<fuseaction name="copy_metadata_do">
		<!-- CFC: Customization -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="get_customization()" returnvariable="cs" />
		<set name="attributes.cs" value="#cs#" />
		<set name="attributes.iscopymetadata" value="True" />
		<set name="attributes.avoidpagination" value="True" />
		<!-- CFC:search images-->
		<if condition="attributes.thetype EQ 'images'">
			<true>
				<set name="attributes.thetype" value="img" />
			</true>
		</if>
		<!-- CFC:search audios-->
		<if condition="attributes.thetype EQ 'audios'">
			<true>
				<set name="attributes.thetype" value="aud" />
			</true>
		</if>
		<!-- CFC:search videos-->
		<if condition="attributes.thetype EQ 'videos'">
			<true>
				<set name="attributes.thetype" value="vid" />
			</true>
		</if>
		<!-- CFC:search files-->
		<if condition="attributes.thetype EQ 'files'">
			<true>
				<set name="attributes.thetype" value="doc" />
			</true>
		</if>
		<!-- do -->
		<do action="search_simple" />
		<!-- Set result variable for folder and common search -->
		<set name="qry_results" value="#qry_files.qall#" />
		<do action="ajax.copy_metadata_do" />
	</fuseaction>
	
	<!-- Update the metadata to selected image assets-->
	<fuseaction name="copy_metadata_image_do">
		<invoke object="myFusebox.getApplicationData().images" methodcall="copymetadataupdate(attributes)" />
	</fuseaction>
	
	<!-- Update the metadata to selected audio assets-->
	<fuseaction name="copy_metadata_audio_do">
		<invoke object="myFusebox.getApplicationData().audios" methodcall="copymetadataupdate(attributes)" />
	</fuseaction>
	
	<!-- Update the metadata to selected video assets-->
	<fuseaction name="copy_metadata_video_do">
		<invoke object="myFusebox.getApplicationData().videos" methodcall="copymetadataupdate(attributes)" />
	</fuseaction>
	
	<!-- Update the metadata to selected file assets-->
	<fuseaction name="copy_metadata_files_do">
		<invoke object="myFusebox.getApplicationData().files" methodcall="copymetadataupdate(attributes)" />
	</fuseaction>
	
	<!-- Folders folders for metadata-->
	<fuseaction name="metadata_choose_folder">
		<!-- Param -->
		<set name="session.type" value="copymetadata" />
		<set name="session.thetype" value="#attributes.what#" />
		<set name="session.file_id" value="#attributes.file_id#" />
		<!-- Show the choose folder -->
		<do action="choose_folder" />
	</fuseaction>
	
	<!-- Get Metadata from Folders -->
	<fuseaction name="get_meta_folder">
		<if condition="attributes.what EQ 'images'">
			<true>
				<invoke object="myFusebox.getApplicationData().images" methodcall="getAllFolderAsset(attributes)" returnvariable="qry_results"/>
			</true>
		</if>
		<if condition="attributes.what EQ 'audios'">
			<true>
				<invoke object="myFusebox.getApplicationData().audios" methodcall="getAllFolderAsset(attributes)" returnvariable="qry_results"/>
			</true>
		</if>
		<if condition="attributes.what EQ 'videos'">
			<true>
				<invoke object="myFusebox.getApplicationData().videos" methodcall="getAllFolderAsset(attributes)" returnvariable="qry_results"/>
			</true>
		</if>
		<if condition="attributes.what EQ 'files'">
			<true>
				<invoke object="myFusebox.getApplicationData().files" methodcall="getAllFolderAsset(attributes)" returnvariable="qry_results"/>
			</true>
		</if>
		<do action="ajax.copy_metadata_do" />
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
		<if condition="attributes.iscol NEQ 't'">
			<true>
				<do action="folder" />
			</true>
		</if>
	</fuseaction>
	
	<!-- START RESTORE FILES-->
	
	<!-- Restore file -->
	<fuseaction name="restore_file">
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
		<!-- Show the choose folder -->
		<do action="choose_folder" />
	</fuseaction>
	
	<!-- Restore file into the desired directory-->
	<fuseaction name="restore_file_do">
		<!-- Param -->
		<set name="attributes.file_id" value="#session.thefileid#" />
		<set name="attributes.thispath" value="#thispath#" />
		<set name="attributes.hostid" value="#session.hostid#" />
		<set name="attributes.thetype" value="#session.thetype#" />
		<set name="session.trash" value="T" />
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
		
	</fuseaction>
	
	 <!-- Copy the folder into the desired folder -->
	<fuseaction name="copy_folder">
		<!-- Param -->
		<set name="attributes.thepath" value="#thispath#" />
		<set name="attributes.rootpath" value="#ExpandPath('../..')#" />
		<set name="attributes.tocopyfolderid" value="#session.thefolderorg#" />
		<!-- <set name="attributes.difflevel" value="#attributes.intolevel# - #session.thefolderorglevel#" /> -->
		<set name="attributes.folder_id" value="#attributes.tocopyfolderid#" />
		<!-- Set a flag for renaming the folder to be copied -->
		<set name="attributes.count" value="0" />
		<!-- Path for link_path_url -->
		<set name="attributes.path" value="#expandpath('/')#" />
		<!-- CFC: Get asset path -->
		<do action="assetpath" />
		<!-- Action: Storage -->
		<do action="storage" />
		<!-- CFC: Get customization -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="get_customization()" returnvariable="attributes.cs" />
		<!-- CFC: Move Folder -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="copy(attributes)" />
		<!-- Go to show the folder -->
		<if condition="attributes.iscol NEQ 't'">
			<true>
				<do action="folder" />
			</true>
		</if>
	</fuseaction>
	<!--
		END: MOVING FOLDER AND FILES
	-->
	
	<!-- external calls -->
	<fuseaction name="w_hosts_remove">
		<set name="attributes.theschema" value="#application.razuna.theschema#" />
		<set name="attributes.dsn" value="#application.razuna.datasource#" />
		<set name="attributes.database" value="#application.razuna.thedatabase#" />
		<set name="attributes.storage" value="#application.razuna.storage#" />
		<!-- CFC: Remove host -->
		<invoke object="myFusebox.getApplicationData().hosts" methodcall="remove(attributes)" />
	</fuseaction>
	<!-- default values -->
	<fuseaction name="w_insert_default_values">
		<set name="attributes.dsn" value="#application.razuna.datasource#" />
		<set name="attributes.database" value="#application.razuna.thedatabase#" />
		<set name="attributes.storage" value="#application.razuna.storage#" />
		<!-- CFC: insert_default_values -->
		<invoke object="myFusebox.getApplicationData().hosts" methodcall="insert_default_values(attributes)" />
	</fuseaction>

	<!--
		START: BATCHING OF MANY FILES
	-->
	
	<!-- Call the batch form -->
	<fuseaction name="batch_form">
		<!-- XFA -->
		<xfa name="batchdo" value="c.batch_do" />
		<!-- CFC: Get languages -->
		<do action="languages" />
		<!-- CFC: Check for custom fields -->
		<invoke object="myFusebox.getApplicationData().custom_fields" methodcall="getfields(attributes)" returnvariable="qry_cf" />
		<!-- CFC: Permissions of this folder -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="setaccess(attributes.folder_id)" returnvariable="attributes.folderaccess" />
		<!-- If we are images -->
		<if condition="attributes.what EQ 'img' OR session.thefileid CONTAINS '-img'">
			<true>
				<!-- CFC: Get XMP value -->
				<invoke object="myFusebox.getApplicationData().xmp" methodcall="readxmpdb(attributes)" returnvariable="qry_xmp" />
				<!-- CFC: Get file detail -->
				<invoke object="myFusebox.getApplicationData().images" methodcall="detail(attributes)" returnvariable="qry_detail" />
			</true>
		</if>
		<!-- Get labels -->
		<do action="labels" />
		<!-- CFC: Customization -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="get_customization()" returnvariable="cs" />
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
		<!-- Check if there are custom fields to be saved (we do this before because of indexing) -->
		<if condition="attributes.customfields NEQ 0">
			<true>
				<invoke object="myFusebox.getApplicationData().custom_fields" methodcall="savebatchvalues(attributes)" />
			</true>
		</if>
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
		<!-- Add Labels -->
		<invoke object="myFusebox.getApplicationData().labels" methodcall="label_add_batch(attributes)" />
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
		<!-- Action: Check storage -->
		<set name="attributes.isbrowser" value="#session.isbrowser#" />
		<do action="storage" />
		<!-- CFC: Get asset path -->
		<do action="assetpath" />
		<!-- CFC: Get images -->
		<invoke object="myFusebox.getApplicationData().images" method="filedetail" returnvariable="qry_detail">
			<argument name="theid" value="#attributes.f#" />
			<argument name="thecolumn" value="img_id,thumb_width,thumb_height,folder_id_r,img_width,img_height,img_filename_org,thumb_extension,img_extension,img_filename,path_to_asset,cloud_url,cloud_url_org,hashtag,expiry_date" />
		</invoke>
		<!-- Do -->
		<do action="ajax.serve_image" />
	</fuseaction>
	<!-- PDFJPGS -->
	<fuseaction name="sp">
		<!-- Params -->
		<set name="attributes.file_id" value="#attributes.f#" />
		<!-- Action: Check storage -->
		<set name="attributes.isbrowser" value="T" />
		<do action="storage" />
		<!-- CFC: Get asset path -->
		<do action="assetpath" />
		<!-- CFC: Get file detail -->
		<invoke object="myFusebox.getApplicationData().files" methodcall="detail(attributes)" returnvariable="qry_detail" />
		<!-- CFC: Get images -->
		<invoke object="myFusebox.getApplicationData().files" methodcall="pdfjpgs(attributes)" returnvariable="qry_pdfjpgs" />
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
		<!-- Action: Check storage -->
		<set name="attributes.isbrowser" value="#session.isbrowser#" />
		<do action="storage" />
		<!-- Do -->
		<do action="ajax.audios_detail_flash" />
	</fuseaction>

	<!--
		END: SERVE TO BROWSER (CALLS FROM EXTERNAL URL)
	-->
	
	<!--  -->
	<!-- ADMIN SECTION -->
	<!--  -->
	
	<!-- Calling the main admin -->
	<fuseaction name="admin">
		<!-- CFC: Get Access Control Settings -->
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="getaccesscontrol()" returnvariable="access_struct" />
		<!-- CFC: Get Access Control Settings -->
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="getuseraccesscontrols(access_struct)" returnvariable="tabaccess_struct" />
		<!-- Check on activated plugins here -->
		<invoke object="myFusebox.getApplicationData().plugins" methodcall="getalldb(dam='true')" returnvariable="qry_plugins" />
		<!-- Do -->
		<do action="ajax.admin" />
	</fuseaction>
	<!-- Showing plugin information page -->
	<fuseaction name="admin_plugin_one">
		<!-- Get this one plugin -->
		<invoke object="myFusebox.getApplicationData().plugins" methodcall="getone(attributes.p_id)" returnvariable="qry_plugin" />
		<!-- Do -->
		<do action="ajax.plugin_info" />
	</fuseaction>
	<!-- Load the plugin settings page -->
	<fuseaction name="plugin_settings">
		<!-- Get this one plugin -->
		<invoke object="myFusebox.getApplicationData().plugins" methodcall="getone(attributes.p_id)" returnvariable="qry_plugin" />
		<!-- CFC: Get plugin actions -->
		<invoke object="myFusebox.getApplicationData().plugins" methodcall="getactions('settings',attributes)" returnvariable="pl" />
		<!-- Do -->
		<do action="ajax.plugin_settings_loader" />
	</fuseaction>
	<!-- Save the plugin settings page -->
	<fuseaction name="plugin_save">
		<!-- CFC: Get plugin actions -->
		<invoke object="myFusebox.getApplicationData().plugins" methodcall="getactions(attributes.p_action,attributes)" returnvariable="pl" />
	</fuseaction>

	<!-- Call plugin method directly -->
	<fuseaction name="plugin_direct">
		<!-- CFC: Get plugin actions -->
		<invoke object="myFusebox.getApplicationData().plugins" methodcall="callDirect(attributes)" returnvariable="pl" />
		<!-- Do -->
		<do action="ajax.plugin_loader" />
	</fuseaction>

	<!-- If we call the choose folder within the plugin -->
	<fuseaction name="plugin_choose_folder">
		<!-- Param -->
		<set name="session.type" value="plugin" />
		<!-- Show the choose folder -->
		<do action="choose_folder" />
	</fuseaction>

	<!--  -->
	<!-- ADMIN: USERS -->
	<!--  -->

	<!-- Users List -->
	<fuseaction name="users">
		<!-- Param -->
		<set name="attributes.dam" value="T" />
		<!-- Set the offset -->
		<if condition="structkeyexists(attributes,'offset')">
			<true>
				<set name="session.offset" value="#attributes.offset#" />
			</true>
			<false>
				<set name="session.offset" value="0" />
			</false>
		</if>
		<!-- CFC: Get all users -->
		<invoke object="myFusebox.getApplicationData().users" methodcall="getall(attributes)" returnvariable="qry_users" />
		<!-- Show  -->
		<do action="ajax.admin_users" />
	</fuseaction>
	<!-- AD Services -->
	<fuseaction name="ad_Services">
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="thissetting('ad_server_name')" returnvariable="ad_server_name" />
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="thissetting('ad_server_port')" returnvariable="ad_server_port" />
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="thissetting('ad_server_username')" returnvariable="ad_server_username" />
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="thissetting('ad_server_password')" returnvariable="ad_server_password" />
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="thissetting('ad_server_secure')" returnvariable="ad_server_secure" />
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="thissetting('ad_server_filter')" returnvariable="ad_server_filter" />
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="thissetting('ad_server_start')" returnvariable="ad_server_start" />
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="thissetting('ad_ldap')" returnvariable="ad_ldap" />
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="thissetting('ad_domain')" returnvariable="ad_domain" />
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="thissetting('ldap_dn')" returnvariable="ldap_dn" />
		<!-- Show -->
		<do action="ajax.admin_ad_services" />
	</fuseaction>
	<!-- For saving AD Server customization -->
	<fuseaction name="admin_ad_services_save">
		<!-- CFC -->
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="set_ad_server(attributes.ad_server_name,attributes.ad_server_port,attributes.ad_server_username,attributes.ad_server_password,attributes.ad_server_secure,attributes.ad_server_filter,attributes.ad_server_start,attributes.ad_ldap, attributes.ad_domain, attributes.ldap_dn)" />
	</fuseaction>
	<!-- Users Search -->
	<fuseaction name="ad_server_users_list">
		<!-- Get AD server Deatils -->
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="thissetting('ad_server_name')" returnvariable="attributes.ad_server_name" />
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="thissetting('ad_server_port')" returnvariable="attributes.ad_server_port" />
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="thissetting('ad_server_username')" returnvariable="attributes.ad_server_username" />
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="thissetting('ad_server_password')" returnvariable="attributes.ad_server_password" />
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="thissetting('ad_server_filter')" returnvariable="attributes.ad_server_filter" />
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="thissetting('ad_server_start')" returnvariable="attributes.ad_server_start" />
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="thissetting('ad_server_secure')" returnvariable="attributes.ad_server_secure" />
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="thissetting('ad_ldap')" returnvariable="attributes.ad_ldap" />
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="thissetting('ad_domain')" returnvariable="attributes.ad_domain" />
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="thissetting('ldap_dn')" returnvariable="attributes.ldap_dn" />
		<!-- Show  -->
		<do action="ajax.ad_server_users_list" />
	</fuseaction>
	<fuseaction name="ad_server_users_list_do">
		<!-- Get AD server Deatils -->
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="thissetting('ad_server_name')" returnvariable="attributes.ad_server_name" />
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="thissetting('ad_server_port')" returnvariable="attributes.ad_server_port" />
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="thissetting('ad_server_username')" returnvariable="attributes.ad_server_username" />
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="thissetting('ad_server_password')" returnvariable="attributes.ad_server_password" />
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="thissetting('ad_server_filter')" returnvariable="attributes.ad_server_filter" />
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="thissetting('ad_server_start')" returnvariable="attributes.ad_server_start" />
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="thissetting('ad_server_secure')" returnvariable="attributes.ad_server_secure" />
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="thissetting('ad_ldap')" returnvariable="attributes.ad_ldap" />
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="thissetting('ad_domain')" returnvariable="attributes.ad_domain" />
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="thissetting('ldap_dn')" returnvariable="attributes.ldap_dn" />
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="get_ad_server()" returnvariable="qry_ad_server" />
		<!-- CFC: Load groups -->
		<invoke object="myFusebox.getApplicationData().groups" method="getall" returnvariable="qry_groups">
			<argument name="host_id" value="#session.hostid#" />
			<argument name="orderBy" value="grp_name ASC" />
		</invoke>
		<!-- Show  -->
		<do action="ajax.ad_server_users_list_do" />
	</fuseaction>

	<!-- Save AD server Users -->
	<fuseaction name="ad_server_users_save">
		<!-- CFC -->
		<invoke object="myFusebox.getApplicationData().Users" methodcall="ad_server_user(attributes)" />
	</fuseaction>
	
	<!-- Users Search -->
	<fuseaction name="users_search">
		<!-- Param -->
		<set name="attributes.dam" value="T" />
		<set name="session.offset" value="0" />
		<!-- CFC: Search users -->
		<invoke object="myFusebox.getApplicationData().users" methodcall="quicksearch(attributes)" returnvariable="qry_users" />
		<!-- Show  -->
		<do action="ajax.users_search" />
	</fuseaction>
	<!-- Get Details -->
	<fuseaction name="users_detail">
		<set name="attributes.myinfo" value="false" overwrite="false" />
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
			<argument name="nosessionoverwrite" value="true"/>
		</invoke>
		<set name="grpnrlist" value="#valuelist(qry_usergroup.grp_id)#" />
		<!-- Get DAM groups of this user and put into list -->
		<invoke object="myFusebox.getApplicationData().groups_users" method="getGroupsOfUser" returnvariable="qry_usergroupdam">
			<argument name="user_id" value="#attributes.user_id#" />
			<argument name="mod_short" value="ecp" />
			<argument name="host_id" value="#session.hostid#" />
			<argument name="nosessionoverwrite" value="true"/>
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
			<argument name="nosessionoverwrite" value="true"/>
		</invoke>
		<!-- CFC: Customization -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="get_customization()" returnvariable="cs" />
		<!-- CFC: Check if Janrain is enabled -->
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="thissetting('janrain_enable')" returnvariable="jr_enable" />
		<!-- CFC: Get social -->
		<invoke object="myFusebox.getApplicationData().users" methodcall="getsocial(attributes)" returnvariable="qry_social" />
		<!-- CFC: Check for custom fields -->
		<set name="attributes.cf_show" value="users" />
		<set name="attributes.file_id" value="#attributes.user_id#" />
		<invoke object="myFusebox.getApplicationData().custom_fields" methodcall="getfields(attributes)" returnvariable="qry_cf" />
		<!-- Get the folder selection but only if we need to -->
		<if condition="cs.search_selection">
			<true>
				<invoke object="myFusebox.getApplicationData().folders" methodcall="getInSearchSelection()" returnvariable="qry_search_selection" />
			</true>
		</if>
		<!-- Show -->
		<do action="ajax.users_detail" />
	</fuseaction>
	<!-- Save new or existing user -->
	<fuseaction name="users_save">
		<!-- Param -->
		<set name="attributes.dam" value="T" />
		<set name="attributes.intrauser" value="T" />
		<set name="attributes.hostid" value="#session.hostid#" />
		<set name="attributes.emailinfo" value="false" overwrite="false" />
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
		<!-- CFC: Check if Janrain is enabled -->
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="thissetting('janrain_enable')" returnvariable="jr_enable" />
		<!-- CFC: Save social accounts -->
		<if condition="jr_enable EQ 'true'">
			<true>
				<set name="attributes.user_id" value="#attributes.newid#" />
				<invoke object="myFusebox.getApplicationData().users" methodcall="savesocial(attributes)" />
			</true>
		</if>
		<!-- Check if there are custom fields to be saved (we do this before because of indexing) -->
		<if condition="attributes.customfields NEQ 0">
			<true>
				<set name="attributes.file_id" value="#attributes.newid#" />
				<do action="custom_fields_save" />
			</true>
		</if>
	</fuseaction>
	<!-- Import Users -->
	<fuseaction name="users_import">
		<!-- Get AD server Details -->
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="thissetting('ad_server_name')" returnvariable="attributes.ad_server_name" />
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="thissetting('ad_server_username')" returnvariable="attributes.ad_server_username" />
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="thissetting('ad_server_password')" returnvariable="attributes.ad_server_password" />
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="thissetting('ad_server_start')" returnvariable="attributes.ad_server_start" />
		<!-- Show  -->
		<do action="ajax.users_import" />
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
	<fuseaction name="admin_user_api">
		<!-- Param -->
		<set name="attributes.reset" value="false" overwrite="false" />
		<!-- CFC: Check API key -->
		<invoke object="myFusebox.getApplicationData().users" methodcall="getapikey(attributes.user_id,attributes.reset)" returnvariable="qry_api_key" />
		<!-- Get Admin groups of this user and put into list -->
		<invoke object="myFusebox.getApplicationData().groups_users" method="getGroupsOfUser" returnvariable="qry_usergroup">
			<argument name="user_id" value="#attributes.user_id#" />
			<argument name="mod_short" value="adm" />
			<argument name="host_id" value="#session.hostid#" />
			<argument name="nosessionoverwrite" value="true"/>
		</invoke>
		<set name="grpnrlist" value="#valuelist(qry_usergroup.grp_id)#" />
		<!-- Show -->
		<do action="ajax.admin_user_api" />
	</fuseaction>
	<!-- Export DO -->
	<fuseaction name="users_export_do">
		<!-- Param -->
		<set name="attributes.thepath" value="#thispath#" />
		<!-- CFC -->
		<invoke object="myFusebox.getApplicationData().users" methodcall="users_export(attributes)" />
	</fuseaction>
	<!-- Import DO -->
	<fuseaction name="users_import_do">
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- CFC -->
		<invoke object="myFusebox.getApplicationData().users" methodcall="users_import(attributes)" />
	</fuseaction>
	<!-- Upload file -->
	<fuseaction name="users_upload_do">
		<!-- CFC -->
		<invoke object="myFusebox.getApplicationData().import" methodcall="upload(attributes)" />
		<!-- Show -->
		<do action="ajax.users_import_upload" />
	</fuseaction>
	<!-- Remove users coming from the select -->
	<fuseaction name="users_remove_select">
		<!-- CFC -->
		<invoke object="myFusebox.getApplicationData().users" methodcall="delete_selects(attributes)" />
		<!-- Show -->
		<!-- <do action="users" /> -->
	</fuseaction>

	<!-- Send email to selected users -->
	<fuseaction name="send_useremails">
		<!-- CFC -->
		<invoke object="myFusebox.getApplicationData().users" methodcall="send_emails(attributes)" />
		<!-- Show -->
		<!-- <do action="users" /> -->
	</fuseaction>	
	<!--  -->
	<!-- ADMIN: USERS END -->
	<!--  -->
	
	<!--  -->
	<!-- ADMIN: GROUPS START -->
	<!--  -->

	<!-- Groups List -->
	<fuseaction name="groups_list">
		<!-- CFC: Get detail of Administrator group -->
		<invoke object="myFusebox.getApplicationData().groups" method="getdetail" returnvariable="qry_admin">
			<argument name="grp_id" value="2" />
		</invoke>
		<!-- CFC: Get all groups -->
		<invoke object="myFusebox.getApplicationData().groups" method="getall" returnvariable="qry_groups">
			<argument name="thestruct" value="#attributes#" />
			<argument name="mod_short" value="#attributes.kind#" />
			<argument name="host_id" value="#session.hostid#" />
		</invoke>
		<!-- CFC: Get settings -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="getsettingsfromdam()" returnvariable="prefs" />
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
		<!-- CFC: Get settings -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="getsettingsfromdam()" returnvariable="prefs" />
		<!-- Get folder name selected for re-direction -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="getfoldername(qry_detail.folder_redirect)" returnvariable="qry_foldername" />

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
	<!-- Group Notifications Unsubscribe -->
	<fuseaction name="group_notifications_unsubscribe">
		<!-- CFC: Update -->
		<invoke object="myFusebox.getApplicationData().groups" methodcall="notifications_unsubscribe('#attributes.group_id#')" />
		<!-- Show -->
		<!-- <do action="groups_list" /> -->
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
		<!-- Set the offset -->
		<if condition="structkeyexists(attributes,'offset_sched')">
			<true>
				<set name="session.offset_sched" value="#attributes.offset_sched#" />
			</true>
		</if>
		<!-- CFC: Get all schedules -->
		<invoke object="myFusebox.getApplicationData().scheduler" methodcall="getAllEvents()" returnvariable="qry_schedules" />
		<!-- CFC: Get schedules -->
		<invoke object="myFusebox.getApplicationData().scheduler" methodcall="getEvents()" returnvariable="qry_sched" />
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
		<!-- CFC: get upload templates -->
		<invoke object="myFusebox.getApplicationData().global" methodcall="upl_templates(true)" returnvariable="qry_templates" />
		<!-- CFC: Load groups -->
		<invoke object="myFusebox.getApplicationData().groups" method="getall" returnvariable="qry_groups">
			<argument name="host_id" value="#session.hostid#" />
			<argument name="orderBy" value="grp_name ASC" />
		</invoke>
		<!-- Get AD server Details -->
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="thissetting('ad_server_name')" returnvariable="attributes.ad_server_name" />
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="thissetting('ad_server_port')" returnvariable="attributes.ad_server_port" />
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="thissetting('ad_server_username')" returnvariable="attributes.ad_server_username" />
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="thissetting('ad_server_password')" returnvariable="attributes.ad_server_password" />
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="thissetting('ad_server_secure')" returnvariable="attributes.ad_server_secure" />
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="thissetting('ad_server_filter')" returnvariable="attributes.ad_server_filter" />
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="thissetting('ad_server_start')" returnvariable="attributes.ad_server_start" />
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="thissetting('ad_ldap')" returnvariable="attributes.ad_ldap" />
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="thissetting('ad_domain')" returnvariable="attributes.ad_domain" />
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="thissetting('ldap_dn')" returnvariable="attributes.ldap_dn" />

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
		<!-- Action: Languages -->
		<do action="languages" />
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- Action: Storage -->
		<do action="storage" />
		<!-- Get AD server Deatils -->
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="thissetting('ad_server_name')" returnvariable="attributes.ad_server_name" />
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="thissetting('ad_server_port')" returnvariable="attributes.ad_server_port" />
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="thissetting('ad_server_username')" returnvariable="attributes.ad_server_username" />
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="thissetting('ad_server_password')" returnvariable="attributes.ad_server_password" />
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="thissetting('ad_server_secure')" returnvariable="attributes.ad_server_secure" />
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="thissetting('ad_server_filter')" returnvariable="attributes.ad_server_filter" />
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="thissetting('ad_server_start')" returnvariable="attributes.ad_server_start" />
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="thissetting('ad_ldap')" returnvariable="attributes.ad_ldap" />
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="thissetting('ad_domain')" returnvariable="attributes.ad_domain" />
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="thissetting('ldap_dn')" returnvariable="attributes.ldap_dn" />
		<!-- CFC: Get the Schedule -->
		<invoke object="myFusebox.getApplicationData().scheduler" method="doit" returnvariable="thetask">
			<argument name="sched_id" value="#attributes.sched_id#" />
			<argument name="incomingpath" value="#thispath#/incoming" />
			<argument name="sched" value="T" />
			<argument name="thepath" value="#thispath#" />
			<argument name="langcount" value="#qry_langs.recordcount#" />
			<argument name="rootpath" value="#ExpandPath('../..')#" />
			<argument name="assetpath" value="#attributes.assetpath#" />
			<argument name="dynpath" value="#dynpath#" />
			<argument name="ad_server_name" value="#attributes.ad_server_name#" />
			<argument name="ad_server_port" value="#attributes.ad_server_port#" />
			<argument name="ad_server_username" value="#attributes.ad_server_username#" />
			<argument name="ad_server_password" value="#attributes.ad_server_password#" />
			<argument name="ad_server_filter" value="#attributes.ad_server_filter#" />
			<argument name="ad_server_start" value="#attributes.ad_server_start#" />
			<argument name="ad_server_secure" value="#attributes.ad_server_secure#" />
			<argument name="ad_ldap" value="#attributes.ad_ldap#" />
			<argument name="ad_domain" value="#attributes.ad_domain#" />
			<argument name="ldap_dn" value="#attributes.ldap_dn#" />
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
				<set name="attributes.upl_temp_id" value="#createuuid('')#" />
			</true>
		</if>
		<!-- CFC: get details -->
		<invoke object="myFusebox.getApplicationData().global" methodcall="upl_template_detail(attributes.upl_temp_id)" returnvariable="qry_detail" />
		<!-- Get watermark templates -->
		<do action="watermark" />
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
		<set name="attributes.meta_img" value="iptcsubjectcode,creator,title,authorstitle,descwriter,iptcaddress,category,categorysub,urgency,iptccity,iptccountry,iptclocation,iptczip,iptcemail,iptcwebsite,iptcphone,iptcintelgenre,iptcinstructions,iptcsource,iptcusageterms,copystatus,iptcjobidentifier,copyurl,iptcheadline,iptcdatecreated,iptcimagecity,iptcimagestate,iptcimagecountry,iptcimagecountrycode,iptcscene,iptcstate,iptccredit,copynotice,upc_number" />
		<set name="attributes.meta_doc" value="author,rights,authorsposition,captionwriter,webstatement,rightsmarked" />
		<!-- Get Custom fields -->
		<invoke object="myFusebox.getApplicationData().custom_fields" methodcall="get(true)" returnvariable="attributes.meta_cf" />
		<!-- Create new ID -->
		<if condition="attributes.imp_temp_id EQ 0">
			<true>
				<set name="attributes.imp_temp_id" value="#createuuid('')#" />
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
	

	<!-- Get folder Summary -->
	<fuseaction name="log_folder_summary">
		<!-- CFC: Count all files -->
		<invoke object="myFusebox.getApplicationData().log" methodcall="log_folder_summary(#attributes.folder_id#)" returnvariable="folders" />
		<!-- Show -->
		<do action="ajax.log_folder_summary" />
	</fuseaction>

	<!-- Get Folder Summary Report -->
	<fuseaction name="log_folder_summary_report">
		<!-- CFC: Count all files -->
		<invoke object="myFusebox.getApplicationData().log" methodcall="log_folder_summary(#attributes.folder_id#,'true','f.folder_main_id_r,f.folder_level asc')" returnvariable="folders" />
		<!-- Show -->
		<do action="ajax.log_folder_summary_report" />
	</fuseaction>

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
		<!-- CFC: Get groups -->
		<invoke object="myFusebox.getApplicationData().groups" method="getall" returnvariable="qry_groups">
			<argument name="mod_id" value="1" />
		</invoke>
		<!-- CFC: Get users -->
		<invoke object="myFusebox.getApplicationData().users" methodcall="getall(attributes)" returnvariable="qry_users" />		
		<!-- Show -->
		<do action="ajax.custom_fields" />
	</fuseaction>
	<!-- Get existing custom fields -->
	<fuseaction name="custom_fields_existing">
		<!-- CFC: Get fields -->
		<invoke object="myFusebox.getApplicationData().custom_fields" methodcall="get()" returnvariable="qry_fields" />
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
		<!-- CFC: Get groups -->
		<invoke object="myFusebox.getApplicationData().groups" method="getall" returnvariable="qry_groups">
			<argument name="mod_id" value="1" />
		</invoke>
		<!-- CFC: Get users -->
		<invoke object="myFusebox.getApplicationData().users" methodcall="getall(attributes)" returnvariable="qry_users" />
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
		<!-- CFC: Get image settings -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="getsettingsfromdam()" returnvariable="prefs" />
		<!-- CFC: Get languages -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="lang_get()" returnvariable="qry_langs" />
		<!-- Show -->
		<do action="ajax.isp_settings" />
	</fuseaction>
	<!-- Update languages -->
	<fuseaction name="isp_settings_updatelang">
		<!-- Params -->
		<set name="attributes.thepath" value="#ExpandPath('../..')#" />		
		<!-- CFC: Get languages -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="lang_get_langs(attributes)" />
		<!-- Show -->
		<do action="isp_settings" />
	</fuseaction>
	<!-- Update languages -->
	<fuseaction name="isp_settings_langsave">
		<!-- CFC: Save settings -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="setsettingsfromdam(attributes)" />
		<!-- CFC: Get languages -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="lang_save(attributes)" />
	</fuseaction>
	<!-- Image Upload -->
	<fuseaction name="prefs_imgupload">
		<set name="attributes.uploadnow" value="F" overwrite="false" />
		<!-- CFC: Upload file -->
		<if condition="attributes.uploadnow EQ 'T'">
			<true>
				<!-- CFC: upload logo -->
				<invoke object="myFusebox.getApplicationData().settings" methodcall="upload(attributes)" returnvariable="result" />
			</true>
		</if>
		<!-- Show  -->
		<do action="ajax.isp_settings_upload" />
	</fuseaction>
	<!-- ADMIN: ISP SETTINGS END -->
	<!--  -->
	
	<!--  -->
	<!-- ADMIN: CUSTOMIZATION START -->
	<!--  -->
	
	<!-- For loading customization -->
	<fuseaction name="admin_customization">
		<!-- Param -->
		<set name="attributes.meta_keys" value="id,filename" />
		<set name="attributes.meta_default" value="labels,keywords,description,type" />
		<set name="attributes.meta_img" value="subjectcode,creator,title,authorsposition,captionwriter,ciadrextadr,category,supplementalcategories,urgency,ciadrcity,ciadrctry,location,ciadrpcode,ciemailwork,ciurlwork,citelwork,intellectualgenre,instructions,source,usageterms,copyrightstatus,transmissionreference,webstatement,headline,datecreated,city,ciadrregion,country,countrycode,scene,state,credit,rights,colorspace,xres,yres,resunit" />
		<set name="attributes.meta_doc" value="author,rights,authorsposition,captionwriter,webstatement,rightsmarked" />
		<!-- CFC: Get Customization -->
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="get_customization()" returnvariable="qry_customization" />
		<!-- CFC: Get settings -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="getsettingsfromdam()" returnvariable="prefs" />
		<!-- CFC: Get folder name -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="getfoldername(qry_customization.folder_redirect)" returnvariable="qry_foldername" />
		<!-- CFC: Get fields -->
		<invoke object="myFusebox.getApplicationData().custom_fields" methodcall="get()" returnvariable="qry_fields" />
		<!-- CFC: Get groups -->
		<invoke object="myFusebox.getApplicationData().groups" method="getall" returnvariable="qry_groups">
			<argument name="mod_id" value="1" />
		</invoke>
		<!-- CFC: Get users -->
		<invoke object="myFusebox.getApplicationData().users" methodcall="getall(attributes)" returnvariable="qry_users" />
		<!-- Show -->
		<do action="ajax.admin_customization" />
	</fuseaction>
	<!-- For saving customization -->
	<fuseaction name="admin_customization_save">
		<!-- Path -->
		<set name="attributes.thepathup" value="#ExpandPath('../../')#" />
		<!-- CFC -->
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="set_customization(attributes)" />
	</fuseaction>
	<!-- Choose Folder for folder redirect -->
	<fuseaction name="admin_customization_choose_folder">
		<!-- Param -->
		<set name="session.type" value="customization" />
		<!-- Show the choose folder -->
		<do action="choose_folder" />
	</fuseaction>
	<!-- Choose Folder for folder redirect in groups detail -->
	<fuseaction name="groups_choose_folder">
		<!-- Param -->
		<set name="session.type" value="groups_detail" />
		<!-- Show the choose folder -->
		<do action="choose_folder" />
	</fuseaction>
	
	<!--  -->
	<!-- ADMIN: CUSTOMIZATION STOP -->
	<!--  -->

<!--  -->
	<!-- ADMIN: NOTIFICATION START -->
	<!--  -->
	
	<!-- For loading notification -->
	<fuseaction name="admin_notification">
		<!-- Param -->
		<do action="getimgmeta_map" />
		<set name="attributes.meta_doc" value="author,rights,authorsposition,captionwriter,webstatement,rightsmarked" />
		<!-- Get Custom fields -->
		<invoke object="myFusebox.getApplicationData().custom_fields" methodcall="get(true)" returnvariable="attributes.meta_cf" />
		<!-- Get Notification data -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="get_notifications()" returnvariable="attributes.notifications" />
		<!-- Show -->
		<do action="ajax.admin_notification" />
	</fuseaction>
	<!-- For saving notification -->
	<fuseaction name="admin_notification_save">
		<!-- Save form data -->
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="set_notifications(attributes)" />
	</fuseaction>
	
	<fuseaction name="getimgmeta_map">
		<!-- Save form data -->
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="getimgmeta_map()" returnvariable="attributes.meta_img" />
	</fuseaction>

	<!--  -->
	<!-- ADMIN: NOTIFICATION STOP -->
	<!--  -->

	<!--  -->
	<!-- ADMIN: INTEGRATION START -->
	<!--  -->
	
	<!-- For loading integration -->
	<fuseaction name="admin_integration">
		<!-- Janrain -->
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="thissetting('janrain_enable')" returnvariable="jr_enable" />
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="thissetting('janrain_apikey')" returnvariable="jr_apikey" />
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="thissetting('janrain_appurl')" returnvariable="jr_appurl" />
		<!-- Dropbox -->
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="thissetting('dropbox_uid')" returnvariable="dropbox_uid" />
		<!-- We expect a boolean value for jr_enable but since it will return an empty string if not found -->
		<if condition="jr_enable EQ ''">
			<true>
				<set name="jr_enable" value="false" />
			</true>
		</if>
		<!-- Show -->
		<do action="ajax.admin_integration" />
	</fuseaction>
	<!-- For saving customization -->
	<fuseaction name="admin_integration_save">
		<!-- CFC -->
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="set_janrain(attributes.janrain_enable,attributes.janrain_apikey,attributes.janrain_appurl)" />
	</fuseaction>
	<!-- Load S3 -->
	<fuseaction name="admin_integration_s3">
		<!-- CFC: Get all S3 account -->
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="get_s3()" returnvariable="qry_s3" />
		<!-- Show -->
		<do action="ajax.admin_integration_s3" />
	</fuseaction>
	<!-- Save S3 -->
	<fuseaction name="admin_integration_s3_save">
		<!-- CFC: Set -->
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="set_s3(attributes)" />
	</fuseaction>
	
	<!--  -->
	<!-- ADMIN: INTEGRATION STOP -->
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
		<set name="attributes.thepath" value="#thispath#" />
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- Action: Storage -->
		<do action="storage" />
		<!-- CFC: Get all the asset -->
		<invoke object="myFusebox.getApplicationData().lucene" methodcall="index_update(thestruct=attributes)" />
	</fuseaction>
	<!-- For System Information -->
	<fuseaction name="admin_system">
		<!-- CFC: Count all files -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="filetotalcount(0,'T')" returnvariable="totalcount" />
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
	<!-- Flush database cache -->
	<fuseaction name="admin_flush_db">
		<invoke object="myFusebox.getApplicationData().global" methodcall="clearcache()" />
	</fuseaction>
	<!-- For loading maintenance cloud -->
	<fuseaction name="admin_maintenance_cloud">
		<!-- Show -->
		<do action="ajax.admin_maintenance_cloud" />
	</fuseaction>
	<!-- For loading maintenance cloud do -->
	<fuseaction name="admin_maintenance_cloud_do">
		<!-- Action: Storage -->
		<do action="storage" />
		<!-- Call CFC -->
		<invoke object="myFusebox.getApplicationData().global" methodcall="rebuildurl(attributes)" />
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
		<!-- CFC: Get groups -->
		<invoke object="myFusebox.getApplicationData().groups" method="getall" returnvariable="qry_groups">
			<argument name="mod_short" value="ecp" />
			<argument name="host_id" value="#session.hostid#" />
		</invoke> 
		<!-- CFC: Get users -->
		<invoke object="myFusebox.getApplicationData().users" methodcall="getall(attributes)" returnvariable="qry_users" />		
		<!-- Show -->
		<!-- CFC: Get all labels -->
		<invoke object="myFusebox.getApplicationData().labels" methodcall="labels_dropdown()" returnvariable="qry_labels" />
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
		<!-- Param -->
    	<set name="attributes.closewin" value="1" overwrite="false" />
    	<set name="attributes.selectid" value="" overwrite="false" />
		<!-- CFC: Get label -->
		<invoke object="myFusebox.getApplicationData().labels" methodcall="admin_get_one(attributes.label_id)" returnvariable="qry_label" />
		<!-- CFC: Get all labels -->
		<invoke object="myFusebox.getApplicationData().labels" methodcall="labels_dropdown()" returnvariable="list_labels_dropdown" />
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
	
	<!-- We moved labels for 1.5 to user view now -->
	
	<!-- Add or Update Label -->
	<fuseaction name="labels_add">
		<!-- CFC: Get label -->
		<invoke object="myFusebox.getApplicationData().labels" methodcall="admin_update(attributes)" />
		<!-- Show -->
		<do action="labels_list" />
	</fuseaction>
	
	<!--  -->
	<!-- ADMIN: LABELS STOP -->
	<!--  -->
	
	<!--  -->
	<!-- ADMIN: WATERMARK START -->
	<!--  -->

	<!-- Watermark templates list -->
	<fuseaction name="admin_watermark_templates">
		<!-- CFC: get templates -->
		<invoke object="myFusebox.getApplicationData().global" methodcall="getwmtemplates()" returnvariable="qry_templates" />
		<!-- Show -->
		<do action="ajax.admin_watermark_templates" />
	</fuseaction>
	<!-- Templates Detail or add -->
	<fuseaction name="admin_watermark_template_detail">
		<!-- Param -->
		<!-- Create new ID -->
		<if condition="attributes.wm_temp_id EQ 0">
			<true>
				<set name="attributes.wm_temp_id" value="#createuuid('')#" />
			</true>
		</if>
		<!-- CFC: get details -->
		<invoke object="myFusebox.getApplicationData().global" methodcall="getwmtemplatedetail(attributes.wm_temp_id)" returnvariable="qry_detail" />
		<!-- Show -->
		<do action="ajax.admin_watermark_template_detail" />
	</fuseaction>
	<!-- Templates Save -->
	<fuseaction name="admin_watermark_template_save">
		<!-- CFC: save -->
		<invoke object="myFusebox.getApplicationData().global" methodcall="setwmtemplate(attributes)" />
	</fuseaction>
	<!-- Templates Remove -->
	<fuseaction name="wm_templates_remove">
		<!-- Path -->
		<set name="attributes.thepathup" value="#ExpandPath('../..')#" />
		<!-- CFC: save -->
		<invoke object="myFusebox.getApplicationData().global" methodcall="removewmtemplate(attributes)" />
		<!-- Show -->
		<do action="admin_watermark_templates" />
	</fuseaction>
	<!-- Add Upload iFrame -->
	<fuseaction name="admin_watermark_upload">
		<!-- CFC: upload -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="upload_watermark(attributes)" returnvariable="wmupload" />
		<!-- Show -->
		<do action="ajax.admin_watermark_upload" />
	</fuseaction>

	<!--  -->
	<!-- ADMIN: WATERMARK STOP -->
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
		<!-- CFC: Get total file count -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="filetotalcount(attributes.folder_id)" returnvariable="qry_filecount" />
		<set name="attributes.qry_filecount" value="#qry_filecount.thetotal#" overwrite="false" />
		<!-- CFC: Customization -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="get_customization()" returnvariable="cs" />
		<set name="attributes.cs" value="#cs#" />
		<!-- Action: Storage -->
		<!-- <set name="attributes.isbrowser" value="#session.isbrowser#" />
		<do action="storage" /> -->
		<!-- If we need to show all -->
		<if condition="#attributes.kind# EQ 'all'">
			<true>
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
					<argument name="columnlist" value="file_id id, file_extension ext, file_type, file_create_date, file_change_date, file_owner, file_name filename, file_name_org filename_org, folder_id_r, path_to_asset, is_available, cloud_url, cloud_url_org, file_id" />
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
		<set name="session.newcommentid" value="#createuuid('')#" />
		<!-- Show -->
		<do action="ajax.comments" />
	</fuseaction>
	<!-- Get Comments -->
	<fuseaction name="comments_list">
		<!-- XFA -->
		<xfa name="comlist" value="c.comments_save" />
		<invoke object="myFusebox.getApplicationData().folders" methodcall="setaccess(attributes.folder_id)" returnvariable="attributes.folderaccess" />
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
	
	<!-- This is for a shared collection -->
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
		<set name="attributes.share" value="T" />
		<set name="attributes.wid" value="0" />
		<set name="attributes.fromcol" value="F" overwrite="false" />
		<set name="attributes.fp" value="F" overwrite="false" />
		<set name="attributes.perm_password" value="F" />
		<!-- Folder id into session -->
		<set name="session.fid" value="#attributes.fid#" />
		<if condition="#attributes.fromcol# EQ 'F' OR NOT structkeyexists(session,'iscol')">
			<true>
				<set name="session.iscol" value="F" />
			</true>
		</if>
		<!-- XFA -->
		<xfa name="submitform" value="c.share_login" />
		<xfa name="forgotpass" value="c.forgotpass" />
		<xfa name="switchlang" value="c.switchlang" />
		<set name="jr_enable" value="false" overwrite="false" />
		<!-- CFC: Custom fields -->
		<invoke object="myFusebox.getApplicationData().custom_fields" methodcall="getfieldssearch(attributes)" returnvariable="qry_cf_fields" />
		<if condition="#session.hostid# NEQ ''">
			<true>
				<!-- CFC: Get languages -->
				<do action="languages" />
				<!-- Check for JanRain -->
				<invoke object="myFusebox.getApplicationData().Settings" methodcall="thissetting('janrain_enable')" returnvariable="jr_enable" />
				<invoke object="myFusebox.getApplicationData().Settings" methodcall="thissetting('janrain_appurl')" returnvariable="jr_url" />
			</true>
		</if>
		<!-- Check if folder is shared, secured. If so display log in -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="sharecheckperm(attributes)" returnvariable="shared" />
		<!-- Get the Cache tag -->
		<do action="cachetag" />
		<!-- If ISP (for now) -->
		<if condition="cgi.http_host CONTAINS 'razuna.com'">
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
		<set name="session.iscol" value="F" overwrite="false" />
		<set name="attributes.loginto" value="dam" />
		<set name="attributes.from_share" value="t" />
		<!-- Check the user and let him in ot nor -->
		<invoke object="myFusebox.getApplicationData().Login" methodcall="login(attributes)" returnvariable="logindone" />
		<!-- User is found -->
		<if condition="logindone.notfound EQ 'F'">
    		<true>
				<!-- set host again with real value -->
				<invoke object="myFusebox.getApplicationData().security" methodcall="initUser(Session.hostid,logindone.qryuser.user_id,'adm')" returnvariable="Request.securityobj" />
				<!-- Folder id into session -->
				<set name="session.fid" value="#attributes.fid#" />
				<!-- CFC: Check if user is allowed for this folder -->
				<invoke object="myFusebox.getApplicationData().folders" methodcall="sharecheckpermfolder(session.fid)" />
				<!-- If user does not have permission then redirect to login screen-->
				<if condition="#request.shareperm_fldr# EQ 'locked'">
					<true>
						<!-- Relocate to login -->
						<relocate url="#session.thehttp##cgi.http_host##myself#c.share&amp;le=t&amp;fid=#attributes.fid#" />
					</true>
				</if>
				<!-- Encode login vars and pass it to sharep which will verify login with it -->
				<invoke object="myFusebox.getApplicationData().security" methodcall="encrypt('#logindone.qryuser.user_id#','#logindone.notfound#')" returnvariable="ls" />
				<!-- Relocate -->
				<relocate url="#session.thehttp##cgi.http_host##myself#c.sharep&amp;fid=#attributes.fid#&amp;ls=#urlencodedformat(ls)#&amp;_v=#createuuid('')#" />
			</true>
			<!-- User not found -->
			<false>
				<!-- Param -->
		   		<set name="attributes.loginerror" value="T" />
				<!-- Show -->
				<!-- <do action="share" /> -->
				<!-- Relocate -->
				<relocate url="#session.thehttp##cgi.http_host##myself#c.share&amp;le=t&amp;fid=#attributes.fid#" />
		   	</false>
		</if>
	</fuseaction>
	<!-- Share Proxy -->
	<fuseaction name="sharep">
		<!-- Get the Cache tag -->
		<do action="cachetag" />
		<!-- Folder id into session -->
		<if condition="structkeyexists(attributes,'fid')">
			<true>
				<set name="session.fid" value="#attributes.fid#" />
			</true>
		</if>

		<!-- Check if folder is shared, secured. If so display log in -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="sharecheckperm(attributes)" returnvariable="shared" />

		<!-- If folder is open to everyone then bypass login checks -->
		<if condition="#shared.everyone# EQ 'F'">
			<true>
				<!-- If login credentials not passed then redirect to login screen -->
				<if condition="not isdefined('attributes.ls') eq true">
					<true>
						<!-- Relocate to login -->
						<relocate url="#session.thehttp##cgi.http_host##myself#c.share&amp;le=t&amp;fid=#attributes.fid#" />
					</true>
				</if>
				<!-- Decode and validate login credentials  -->
				<!-- Decode login vars -->
				<invoke object="myFusebox.getApplicationData().security" methodcall="decrypt('#urldecode(attributes.ls)#','F')" returnvariable="userid" />
				<!-- Check if decoded userid exists in database -->
				<invoke object="myFusebox.getApplicationData().security" methodcall="isuser('#userid#')" returnvariable="logcheck" />
				<if condition="logcheck eq false">
					<true>
						<!-- Relocate to login -->
						<relocate url="#session.thehttp##cgi.http_host##myself#c.share&amp;le=t&amp;fid=#attributes.fid#" />
					</true>
				</if>
			</true>
		</if>
		<!-- CFC: Custom fields -->
		<invoke object="myFusebox.getApplicationData().custom_fields" methodcall="getfieldssearch(attributes)" returnvariable="qry_cf_fields" />
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
				<relocate url="#session.thehttp##cgi.http_host##myself#c.share&amp;fid=#attributes.fid#" />
			</true>
		</if>
		<if condition="NOT structkeyexists(session,'iscol')">
			<true>
				<set name="session.iscol" value="F" />
			</true>
		</if>
		<set name="attributes.folder_id" value="#session.fid#" overwrite="false" />
		<set name="kind" value="all" />
		<set name="url.kind" value="all" />
		<set name="attributes.showsubfolders" value="F" overwrite="false" />
		<set name="session.showsubfolders" value="F" />
		<set name="attributes.pages" value="" />
		<set name="session.offset" value="0" />
		<set name="attributes.share" value="T" />
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- CFC: Get languages -->
		<do action="languages" />
		<!-- Action: Set view -->
		<do action="set_view" />
		<!-- CFC: Get settings -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="prefs_dam()" returnvariable="attributes.prefs" />
		<!-- CFC: Customization -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="get_customization()" returnvariable="cs" />
		<set name="attributes.cs" value="#cs#" />
		<!-- Get assets from folder or from collection -->
		<if condition="#session.iscol# EQ 'F'">
			<true>
				<!-- if the folder_id_r is in the URL scope  -->
				<if condition="structkeyexists(url,'folder_id_r')">
					<true>
						<set name="attributes.folder_id" value="#url.folder_id#" />
						<!-- CFC: Get Breadcrumb -->
						<invoke object="myFusebox.getApplicationData().folders" method="getbreadcrumb" returnvariable="qry_breadcrumb">
							<argument name="folder_id_r" value="#url.folder_id_r#" />
							<argument name="fromshare" value="true" />
						</invoke>
					</true>
				</if>
				<!-- CFC: Permissions of this folder -->
				<invoke object="myFusebox.getApplicationData().folders" methodcall="setaccess(attributes.folder_id)" returnvariable="attributes.folderaccess" />
				<!-- CFC: Get folder share options -->
				<invoke object="myFusebox.getApplicationData().folders" methodcall="getfolderproperties(attributes.folder_id)" returnvariable="qry_folder" />
				<!-- CFC: Get subfolders -->
				<invoke object="myFusebox.getApplicationData().folders" methodcall="getsubfolders(attributes.folder_id)" returnvariable="qry_subfolders" />
				<!-- CFC: Get the total file count -->
				<invoke object="myFusebox.getApplicationData().folders" methodcall="filetotalcount(attributes.folder_id, attributes.folderaccess)" returnvariable="qry.qry_filecount" />
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
				<!-- CFC: Get permissions for collection -->
				<set name="attributes.colaccess" value="#qry_folder.colaccess#" />
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
		<set name="session.newcommentid" value="#createuuid('')#" />
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
		<set name="attributes.share" value="T" />
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
		<set name="session.thegroupofuser" value="0" />
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
		<!-- CFC: Get access -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="setaccess(attributes.folder_id)" returnvariable="attributes.folderaccess" />	
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
		<!-- CFC: Get access -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="setaccess(attributes.folder_id)" returnvariable="attributes.folderaccess" />
		<!-- CFC: Get image settings -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="prefs_image()" returnvariable="attributes.qry_settings_image" />
		<!-- CFC: Query the versions -->
		<invoke object="myFusebox.getApplicationData().versions" methodcall="get(attributes)" returnvariable="qry_versions" />
		<!-- Show -->
		<do action="ajax.versions_list" />
	</fuseaction>
	<!-- Upload a new version -->
	<fuseaction name="versions_add">
		<!-- RAZ-2907 for set zip extraction value -->
		<!-- Param -->
		<if condition="!structkeyexists(attributes,'extjs')">
			<true>
		<set name="attributes.zip_extract" value="0" />
			</true>
		</if>
		<set name="attributes.sendemail" value="false" />
		<set name="attributes.thepath" value="#thispath#" />
		<set name="attributes.rootpath" value="#ExpandPath('../..')#" />
		<set name="attributes.dynpath" value="#dynpath#" />
		<set name="attributes.httphost" value="#cgi.http_host#" />
		<set name="attributes.langcount" value="1" />
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- Action: Check storage -->
		<do action="storage" />
		<!-- CFC: Get temp file details -->
		<invoke object="myFusebox.getApplicationData().assets" methodcall="addassetsendmail(attributes)" returnvariable="attributes.qryfile"/>
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
		<!-- CFC: Get access -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="setaccess(attributes.folder_id)" returnvariable="attributes.folderaccess" />
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
		<set name="attributes.langcount" value="1" />
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
				<invoke object="myFusebox.getApplicationData().global" methodcall="getAdditionalVersions(attributes)" returnvariable="attributes.qry_additional_versions" />
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
				<invoke object="myFusebox.getApplicationData().global" methodcall="getAdditionalVersions(attributes)" returnvariable="attributes.qry_additional_versions" />
			</true>
		</if>
		<!-- CFC: Get related audio records -->
		<if condition="#attributes.type# EQ 'aud'">
			<true>
				<!-- CFC: Get file detail -->
				<invoke object="myFusebox.getApplicationData().audios" methodcall="detail(attributes)" returnvariable="qry_detail" />
				<invoke object="myFusebox.getApplicationData().audios" methodcall="relatedaudios(attributes)" returnvariable="attributes.qry_related" />
				<invoke object="myFusebox.getApplicationData().global" methodcall="getAdditionalVersions(attributes)" returnvariable="attributes.qry_additional_versions" />
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
				<invoke object="myFusebox.getApplicationData().global" methodcall="getAdditionalVersions(attributes)" returnvariable="attributes.qry_additional_versions" />
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
				<invoke object="myFusebox.getApplicationData().folders" methodcall="setaccess(attributes.folder_id)" returnvariable="attributes.folderaccess" />
			</true>
		</if>
	</fuseaction>
	
	<!-- View includes -->
	<fuseaction name="view_includes_queries">
		<!-- CFC: Customization -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="get_customization()" returnvariable="cs" />
		<set name="attributes.cs" value="#cs#" />
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
					<argument name="columnlist" value="file_id id, file_extension ext, file_type, file_name filename, file_name_org filename_org, folder_id_r, link_kind, path_to_asset, cloud_url, cloud_url_org, file_id" />
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
	<!-- FLODER THUMBNAIL: START -->
	<!--  -->
	
	<!-- Initial View -->
	<fuseaction name="folder_thumbnail">
		<!-- Param -->
		<set name="attributes.isdetail" value="T" />
		<set name="attributes.theid" value="0" overwrite="false" />
		<set name="attributes.level" value="0" overwrite="false" />
		<set name="attributes.iscol" value="F" overwrite="false" />
		<set name="attributes.qry_filecount" value="0"  />
		<set name="attributes.kind" value="img"  />
		<xfa name="submitfolderform" value="c.folder_thumbnail_save" overwrite="false" />
		<!-- CFC: Customization -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="get_customization()" returnvariable="cs" />
		<set name="attributes.cs" value="#cs#" />
		<!-- CFC: Get images -->
		<invoke object="myFusebox.getApplicationData().images" method="getFolderAssetDetails" returnvariable="qry_files">
			<argument name="folder_id" value="#attributes.folder_id#" />
			<argument name="columnlist" value="i.img_id, i.img_filename, i.img_custom_id, i.img_create_date, i.img_change_date, i.img_create_time, i.img_change_time, i.folder_id_r, i.thumb_extension, i.link_kind, i.link_path_url, i.path_to_asset, i.is_available, i.cloud_url" />
			<argument name="offset" value="0" />
			<argument name="rowmaxpage" value="1000" />
			<argument name="thestruct" value="#attributes#" />
		</invoke>
		<!-- Show -->
		<do action="ajax.folder_thumbnail" />
	</fuseaction>
	
	<fuseaction name="folder_thumbnail_save">
		<xfa name="submitfolderform" value="c.folder_thumbnail_save" overwrite="false" />
		<set name="attributes.uploadnow" value="F" overwrite="false" />
		<set name="attributes.folder_id" value="#attributes.folderid#" overwrite="false" />
		<set name="attributes.theid" value="0" overwrite="false" />
		<!-- CFC: Upload file -->
		<if condition="attributes.uploadnow EQ 'T'">
			<true>
				<!-- CFC: upload logo -->
				<invoke object="myFusebox.getApplicationData().settings" methodcall="Upload_folderThumbnail(attributes)" returnvariable="result" />
			</true>
		</if>
		<!-- Show  -->
		<do action="c.folder_thumbnail" />
	</fuseaction>

	<!-- Reset folder thumbnail -->
	<fuseaction name="folder_thumbnail_reset">
		<!-- CFC -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="folderthumbnail_reset(attributes.folder_id)" />
		<!-- Show  -->
		<do action="c.folder_thumbnail" />
	</fuseaction>

	<!--  -->
	<!-- FLODER THUMBNAIL: STOP -->
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
		<set name="session.offset" value="0" />
		<set name="jr_enable" value="false" overwrite="false" />
		<!-- XFA -->
		<xfa name="switchlang" value="c.switchlang" />
		<if condition="#session.hostid# NEQ ''">
			<true>
				<!-- CFC: Get languages -->
				<do action="languages" />
				<!-- Check for JanRain -->
				<invoke object="myFusebox.getApplicationData().Settings" methodcall="thissetting('janrain_enable')" returnvariable="jr_enable" />
				<invoke object="myFusebox.getApplicationData().Settings" methodcall="thissetting('janrain_appurl')" returnvariable="jr_url" />
			</true>
		</if>
		<!-- Get the Cache tag -->
		<do action="cachetag" />
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
		<relocate url="#session.thehttp##cgi.http_host##myself#c.w_content&amp;wid=#session.widget_id#&amp;_v=#createuuid('')#" />
	</fuseaction>
	<!-- External call: Get content -->
	<fuseaction name="w_content">
		<if condition="NOT structkeyexists(session,'widget_login')">
			<true>
				<relocate url="#session.thehttp##cgi.http_host##myself#c.w&amp;wid=#attributes.wid#" />
			</true>
		</if>
		<!-- If this fuse is called directly then redirect to the w -->
		<if condition="cgi.query_string CONTAINS 'w_content' AND session.widget_login NEQ 'T'">
			<true>
				<relocate url="#session.thehttp##cgi.http_host##myself#c.w&amp;wid=#attributes.wid#" />
			</true>
		</if>
		<if condition="NOT structkeyexists(session,'widget_id') OR session.widget_id EQ '' OR session.widget_id EQ 0">
			<true>
				<relocate url="#session.thehttp##cgi.http_host##myself#c.w&amp;wid=#attributes.wid#&amp;le=T" />
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
		<!-- Get the Cache tag -->
		<do action="cachetag" />
		<!-- CFC: Customization -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="get_customization()" returnvariable="cs" />
		<set name="attributes.cs" value="#cs#" />
		<!-- CFC: Query Widget -->
		<invoke object="myFusebox.getApplicationData().widgets" methodcall="detail(attributes)" returnvariable="qry_widget" />
		<set name="attributes.folder_id" value="#qry_widget.folder_id_r#" />
		<set name="attributes.fid" value="#qry_widget.folder_id_r#" />
		<!-- set widget style-->
		<set name="attributes.widget_style" value="#qry_widget.widget_style#" />
		<!-- Depending if there is a collection or not we call the content -->
		<if condition="#session.iscol# EQ 'F'">
			<true>
				<!-- if the folder_id_r is in the URL scope  -->
				<if condition="structkeyexists(url,'folder_id_r')">
					<true>
						<set name="attributes.folder_id" value="#url.folder_id#" />
						<!-- CFC: Get Breadcrumb -->
						<invoke object="myFusebox.getApplicationData().folders" method="getbreadcrumb" returnvariable="qry_breadcrumb">
							<argument name="folder_id_r" value="#url.folder_id_r#" />
							<argument name="fromshare" value="true" />
						</invoke>
					</true>
				</if>
				<!-- CFC: Permissions of this folder -->
				<invoke object="myFusebox.getApplicationData().folders" methodcall="setaccess(attributes.folder_id)" returnvariable="attributes.folderaccess" />
				<!-- CFC: Get folder share options -->
				<invoke object="myFusebox.getApplicationData().folders" methodcall="getfolderproperties(attributes.folder_id)" returnvariable="qry_folder" />
				<!-- CFC: Get subfolders -->
				<invoke object="myFusebox.getApplicationData().folders" methodcall="getsubfolders(attributes.folder_id,attributes.external)" returnvariable="qry_subfolders" />
				<!-- CFC: Get the total file count -->
				<invoke object="myFusebox.getApplicationData().folders" methodcall="filetotalcount(attributes.folder_id,attributes.folderaccess)" returnvariable="qry.qry_filecount" />
				<set name="attributes.qry_filecount" value="#qry.qry_filecount.thetotal#" overwrite="false" />
				<!-- CFC: Get all assets -->
				<invoke object="myFusebox.getApplicationData().folders" methodcall="getallassets(attributes)" returnvariable="qry.qry_files" />
			</true>
			<false>
				<!-- Param -->
				<set name="attributes.col_id" value="#qry_widget.col_id_r#" />
				<set name="attributes.share" value="T" />
				<!-- CFC: Get folder share options -->
				<invoke object="myFusebox.getApplicationData().collections" methodcall="details(attributes)" returnvariable="qry_folder" />
				<!-- CFC: Get permissions for collection -->
				<set name="attributes.colaccess" value="#qry_folder.colaccess#" />
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
		<set name="attributes.widget_id" value="#attributes.wid#" />
		<set name="attributes.external" value="t" />
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
		<if condition="attributes.kind EQ 'doc'">
			<true>
				<invoke object="myFusebox.getApplicationData().files" methodcall="detail(attributes)" returnvariable="attributes.qry_detail" />
			</true>
		</if>
		<!-- CFC: Get Additional versions -->
		<invoke object="myFusebox.getApplicationData().global" methodcall="get_versions_link(attributes)" returnvariable="qry_av" />
		<!-- CFC: Get individual share options -->
		<invoke object="myFusebox.getApplicationData().global" methodcall="get_share_options(attributes)" returnvariable="qry_share_options" />
		<!-- CFC: Get widget share options -->
		<invoke object="myFusebox.getApplicationData().widgets" methodcall="detail(attributes)" returnvariable="qry_widget" />
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
		<!-- Param -->
		<if condition="NOT structkeyexists(session,'widget_id')">
			<true>
				<relocate url="#session.thehttp##cgi.http_host##myself#c.w&amp;wid=#attributes.wid#&amp;le=T" />
			</true>
		</if>
		<!-- Check the user and let him in ot nor -->
		<set name="attributes.loginto" value="dam" />
		<invoke object="myFusebox.getApplicationData().Login" methodcall="login(attributes)" returnvariable="logindone" />
		<!-- User is found -->
		<if condition="logindone.notfound EQ 'F'">
    		<true>
				<!-- set host again with real value -->
				<invoke object="myFusebox.getApplicationData().security" methodcall="initUser(Session.hostid,logindone.qryuser.user_id,'adm')" returnvariable="Request.securityobj" />
				<!-- Folder id into session -->
				<set name="session.fid" value="#attributes.fid#" />
				<set name="session.widget_login" value="T" />
				<relocate url="#session.thehttp##cgi.http_host##myself#c.w_content&amp;wid=#session.widget_id#&amp;_v=#createuuid('')#" />
			</true>
			<!-- User not found -->
			<false>
				<!-- Param -->
		   		<set name="attributes.loginerror" value="T" />
				<set name="session.widget_login" value="F" />
				<!-- Show -->
				<!-- <do action="w" /> -->
				<relocate url="#session.thehttp##cgi.http_host##myself#c.w&amp;wid=#attributes.wid#&amp;le=T" />
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
		<!-- CFC: Query -->
		<invoke object="myFusebox.getApplicationData().global" methodcall="get_versions_link(attributes)" returnvariable="qry_av" />
		<!-- CFC: Get access to this folder -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="setaccess(attributes.folder_id)" returnvariable="attributes.folderaccess" />
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
		<do action="av_link_remove_new" />
		<!-- Show -->
		<do action="adi_versions" />
	</fuseaction>
	<!-- Remove Link 2 -->
	<fuseaction name="av_link_remove_new">
		<!-- CFC: Query Widgets -->
		<invoke object="myFusebox.getApplicationData().global" methodcall="remove_av_link(attributes)" />
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
		<!-- CFC: Get access to this folder -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="setaccess(attributes.folder_id)" returnvariable="attributes.folderaccess" />
		<!-- CFC: Query Widgets -->
		<invoke object="myFusebox.getApplicationData().global" methodcall="get_versions_link(attributes)" returnvariable="qry_av" />
		<!-- Show -->
		<do action="ajax.av_load" />
	</fuseaction>
	
	<!--  -->
	<!-- ADDITIONAL VERSIONS: STOP -->
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
		<set name="cookie.razminipath" value="0" overwrite="false" />
		<if condition="#session.hostid# NEQ ''">
			<true>
				<!-- CFC: Check for collection -->
				<!-- <invoke object="myFusebox.getApplicationData().lucene" methodcall="exists()" /> -->
				<!-- CFC: Get languages -->
				<do action="languages" />
			</true>
		</if>
		<!-- Get the Cache tag -->
		<do action="cachetag" />
		<!-- Show -->
		<do action="v.login_mini" />
	</fuseaction>
	<!-- Log this user in or not -->
	<fuseaction name="mini_login_do">
		<!-- Get AD server Deatils -->
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="thissetting('ad_server_name')" returnvariable="attributes.ad_server_name" />
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="thissetting('ad_server_port')" returnvariable="attributes.ad_server_port" />
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="thissetting('ad_server_username')" returnvariable="attributes.ad_server_username" />
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="thissetting('ad_server_password')" returnvariable="attributes.ad_server_password" />
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="thissetting('ad_server_filter')" returnvariable="attributes.ad_server_filter" />
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="thissetting('ad_server_start')" returnvariable="attributes.ad_server_start" />
		<!-- Do login -->
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
				<set name="attributes.pages" value="chrome" overwrite="false" />
				<set name="attributes.start" value="false" overwrite="false" />
				<!-- Set the path -->
				<set name="cookie.razminipath" value="#attributes.folder_id#" />
				<!-- If start is true we open the extension window -->
				<if condition="attributes.start AND cookie.razminipath NEQ 0">
					<true>
						<relocate url="#myself#c.mini_browser&amp;folder_id=#cookie.razminipath#" />
					</true>
				</if>
				<!-- Action: Get asset path -->
				<do action="assetpath" />
				<!-- Action: Storage -->
				<do action="storage" />
				<!-- For Nirvanix get usage count -->
				<!-- <if condition="application.razuna.storage EQ 'nirvanix' OR session.hosttype EQ 'f'">
					<true>
						<invoke object="myFusebox.getApplicationData().Nirvanix" methodcall="GetAccountUsage(session.hostid,attributes.nvxsession)" returnvariable="attributes.nvxusage" />
					</true>
				</if> -->
				<!-- CFC: Get customization -->
				<invoke object="myFusebox.getApplicationData().settings" methodcall="get_customization()" returnvariable="cs" />
				<set name="attributes.cs" value="#cs#" />
				<!-- CFC: Get folder properties -->
				<invoke object="myFusebox.getApplicationData().folders" methodcall="getfolderproperties(attributes.folder_id)" returnvariable="qry_folder" />
				<!-- CFC: Get folder name -->
				<invoke object="myFusebox.getApplicationData().folders" methodcall="getfoldername(attributes.folder_id)" returnvariable="qry_foldername" />
				<!-- CFC: Set Access -->
				<invoke object="myFusebox.getApplicationData().folders" methodcall="setaccess(attributes.folder_id)" returnvariable="attributes.folderaccess" />
				<!-- CFC: Get the total file count -->
				<invoke object="myFusebox.getApplicationData().folders" methodcall="filetotalcount(attributes.folder_id)" returnvariable="qry_filecount" />
				<set name="attributes.qry_filecount" value="#qry_filecount.thetotal#" overwrite="false" />
				<!-- CFC: Get subfolders -->
				<invoke object="myFusebox.getApplicationData().folders" methodcall="getsubfolders(attributes.folder_id)" returnvariable="qry_subfolders" />
				<!-- CFC: Get all assets -->
				<invoke object="myFusebox.getApplicationData().folders" methodcall="getallassets(attributes)" returnvariable="qry_files" />
				<!-- CFC: Get Breadcrumb -->
				<invoke object="myFusebox.getApplicationData().folders" methodcall="getbreadcrumb(attributes.folder_id)" returnvariable="qry_breadcrumb" />	
				<!-- Get the Cache tag -->
				<do action="cachetag" />
				<!-- Get View -->
				<do action="v.mini_browser" />
			</true>
			<false>
				 <do action="mini" />
			</false>
		</if>
	</fuseaction>
	<!-- Get the files only (for slider) -->
	<fuseaction name="mini_browser_files">
		<!-- Action: Get asset path -->
		<do action="assetpath" />
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
		<if condition="attributes.kind NEQ 'img' AND attributes.kind NEQ 'vid' AND attributes.kind NEQ 'aud'">
			<true>
				<invoke object="myFusebox.getApplicationData().files" methodcall="detail(attributes)" returnvariable="qry_detail" />
			</true>
		</if>
		<!-- Show -->
		<do action="ajax.mini_browser_files" />
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
		<set name="session.thegroupofuser" value="0" />
		<set name="session.theuserid" value="" />
		<set name="session.thedomainid" value="" />
		<do action="mini" />
	</fuseaction>
	<!-- Mini Search -->
	<fuseaction name="mini_search">
		<!-- Params -->
		<set name="attributes.mobile_view" value="true"  />
		<set name="attributes.thetype" value="all"  />
		<set name="attributes.avoidpagination" value="True" />
		<!-- ACTION: Search simple -->
		<do action="search_simple" />
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- Show -->
		<do action="ajax.mini_search" />
	</fuseaction>
	
	<!--  -->
	<!-- MINI: STOP -->
	<!--  -->
	
	<!--  -->
	<!-- LABELS: START -->
	<!--  -->
	
	<!-- Load the label explorer -->
	<fuseaction name="labels_list">
		<!-- Params -->
		<set name="attributes.id" value="0" overwrite="false" />
		<!-- CFC: Get setting -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="get_label_set()" returnvariable="qry_labels_setting" />
		<!-- CFC -->
		<invoke object="myFusebox.getApplicationData().labels" methodcall="labels_dropdown()" returnvariable="list_labels_dropdown" />
		<!-- Show -->
		<do action="ajax.labels" />
	</fuseaction>
	<!-- Load the label explorer -->
	<fuseaction name="labels_tree">
		<!-- CFC -->
		<invoke object="myFusebox.getApplicationData().labels" methodcall="labels(attributes, attributes.id)" returnvariable="qry_labels" />
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
		<!-- Get the assets -->
		<invoke object="myFusebox.getApplicationData().labels" method="labels_assets" returnvariable="qry_labels_assets">
			<argument name="label_id" value="#attributes.label_id#" />
			<argument name="label_kind" value="asset" />
		</invoke>
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
		<xfa name="sendemail" value="c.email_send" />
		<!-- Param -->
		<set name="kind" value="all" />
		<set name="url.kind" value="all" />
		<set name="url.folder_id" value="0" />
		<set name="attributes.folder_id" value="0" />
		<set name="attributes.showsubfolders" value="#session.showsubfolders#" overwrite="false" />
		<set name="session.showsubfolders" value="#attributes.showsubfolders#" />
		<set name="attributes.view" value="" overwrite="false" />
		<set name="attributes.sortby" value="#session.sortby#" overwrite="false" />
		<set name="session.sortby" value="#attributes.sortby#" />
		<set name="attributes.rowmaxpage" value="#session.rowmaxpage#" overwrite="false" />
		<set name="session.rowmaxpage" value="#attributes.rowmaxpage#" />
		<set name="attributes.offset" value="#session.offset#" overwrite="false" />
		<set name="session.offset" value="#attributes.offset#" />
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- CFC: get label text -->
		<invoke object="myFusebox.getApplicationData().labels" methodcall="getlabeltext(attributes.label_id)" returnvariable="qry_labels_text" />
		<!-- CFC: count how many label types there are -->
		<invoke object="myFusebox.getApplicationData().labels" methodcall="labels_count(attributes.label_id)" returnvariable="qry_labels_count" />
		<!-- CFC: Customization -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="get_customization()" returnvariable="cs" />
		<set name="attributes.cs" value="#cs#" />
		<!-- CFC: Get placement for fields-->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="get_customization_placement(cs)" returnvariable="cs_place" />
		<set name="attributes.cs_place" value="#cs_place#" />
		<!-- CFC: Get settings -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="getsettingsfromdam()" returnvariable="prefs" />
		<!-- Get the assets -->
		<invoke object="myFusebox.getApplicationData().labels" method="labels_assets" returnvariable="qry_labels_assets">
			<argument name="thestruct" value="#attributes#" />
			<argument name="label_id" value="#attributes.label_id#" />
			<argument name="label_kind" value="#attributes.label_kind#" />
			<argument name="rowmaxpage" value="#attributes.rowmaxpage#" />
			<argument name="offset" value="#attributes.offset#" />
			<argument name="labels_count" value="#qry_labels_count#" />
		</invoke>
		<!-- CFC: Get plugin actions -->
		<set name="attributes.nameOfVariable" value="plwx" />
		<invoke object="myFusebox.getApplicationData().plugins" methodcall="getactions('show_in_folderview_select_wx',attributes)" returnvariable="plwx" />
		<!-- CFC: Get plugin actions -->
		<set name="attributes.nameOfVariable" value="plr" />
		<invoke object="myFusebox.getApplicationData().plugins" methodcall="getactions('show_in_folderview_select_r',attributes)" returnvariable="plr" />
		<!-- Show -->
		<do action="ajax.labels_main_assets" />
	</fuseaction>
	<!-- Label MAIN: Get folders -->
	<fuseaction name="labels_main_folders">
		<!-- CFC: get label text -->
		<invoke object="myFusebox.getApplicationData().labels" methodcall="getlabeltext(attributes.label_id)" returnvariable="qry_labels_text" />
		<!-- CFC: count how many label types there are -->
		<invoke object="myFusebox.getApplicationData().labels" method="labels_assets" returnvariable="qry_labels_folders">
			<argument name="label_id" value="#attributes.label_id#" />
			<argument name="label_kind" value="#attributes.label_kind#" />
		</invoke>
		<!-- Show -->
		<do action="ajax.labels_main_folders" />
	</fuseaction>
	<!-- Label MAIN: Get collections -->
	<fuseaction name="labels_main_collections">
		<!-- CFC: get label text -->
		<invoke object="myFusebox.getApplicationData().labels" methodcall="getlabeltext(attributes.label_id)" returnvariable="qry_labels_text" />
		<!-- CFC: count how many label types there are -->
		<invoke object="myFusebox.getApplicationData().labels" method="labels_assets" returnvariable="qry_labels_collections">
			<argument name="label_id" value="#attributes.label_id#" />
			<argument name="label_kind" value="#attributes.label_kind#" />
		</invoke>
		<!-- Show -->
		<do action="ajax.labels_main_collections" />
	</fuseaction>
	<!-- Label MAIN: Get properties -->
	<fuseaction name="labels_main_properties">
		<!-- CFC: get label text -->
		<invoke object="myFusebox.getApplicationData().labels" methodcall="admin_get_one(attributes.label_id)" returnvariable="qry_label" />
		<!-- CFC -->
		<invoke object="myFusebox.getApplicationData().labels" methodcall="labels_dropdown()" returnvariable="list_labels_dropdown" />
		<!-- Show -->
		<do action="ajax.labels_main_properties" />
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
		<!-- CFC: Get export template -->
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="get_export_template_details()" returnvariable="qry_details" />
		<!-- Param -->
		<set name="attributes.export_template" value="#qry_details#" />
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
		<set name="attributes.tempid" value="#createuuid('')#" />
		<!-- CFC -->
		<invoke object="myFusebox.getApplicationData().import" methodcall="getTemplates(false)" returnvariable="qry_imptemp" />
		<!-- Show -->
		<do action="ajax.meta_imp" />
	</fuseaction>
	<!-- Upload file -->
	<fuseaction name="meta_imp_upload_do">
		<!-- CFC -->
		<invoke object="myFusebox.getApplicationData().import" methodcall="upload(attributes)" />
		<!-- Show iframe again -->
		<do action="ajax.meta_imp_upload" />
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
	
	<!--  -->
	<!-- DOWNLOAD FOLDER: START -->
	<!--  -->
	
	<!-- Download Folder -->
	<fuseaction name="download_folder_do">
		<!-- Param -->
		<set name="attributes.what" value="folder" overwrite="false" />
		<set name="attributes.expwhat" value="folder" overwrite="false" />
		<set name="attributes.meta_export" value="T" overwrite="false" />
		<set name="attributes.format" value="csv" overwrite="false" />
		<set name="attributes.thepath" value="#thispath#" />
		<set name="attributes.pages" value="download" />
		<set name="attributes.download_thumbnails" value="false" overwrite="false" />
		<set name="attributes.download_originals" value="false" overwrite="false" />
		<set name="attributes.download_renditions" value="false" overwrite="false" />
		<set name="attributes.download_subfolders" value="false" overwrite="false" />
		<set name="attributes.exportname" value="folder_#attributes.folder_id#" overwrite="false" />
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- Action: Storage -->
		<do action="storage" />
		<!-- Get DAM settings -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="getsettingsfromdam()" returnvariable="attributes.prefs" />
		<!-- CFC: Customization -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="get_customization()" returnvariable="attributes.cs" />
		<!-- If label we do not need to query everything -->
		<if condition="attributes.folder_id EQ 'labels'">
			<true>
				<!-- CFC: get label text -->
				<invoke object="myFusebox.getApplicationData().labels" methodcall="getlabeltext(attributes.label_id)" returnvariable="attributes.qry_labels_text" />
				<!-- Get the assets -->
				<invoke object="myFusebox.getApplicationData().labels" method="labels_assets" returnvariable="attributes.qry_files">
					<argument name="label_id" value="#attributes.label_id#" />
					<argument name="label_kind" value="assets" />
					<argument name="thestruct" value="#attributes#" />
				</invoke>
				<if condition="attributes.prefs.set2_meta_export EQ 't'">
					<true>
						<!-- Action: Export Metadata -->
						<do action="meta_export_do" />
					</true>
				</if>
				<!-- Invoke export -->
				<invoke object="myFusebox.getApplicationData().folders" methodcall="download_folder_structure_flat(attributes)" />
			</true>
			<false>
				<!-- CFC: Get all assets -->
				<invoke object="myFusebox.getApplicationData().folders" methodcall="getallassets(attributes)" returnvariable="attributes.qry_files" />
				<!-- Get user groups  -->
				<invoke object="myFusebox.getApplicationData().groups_users" method="getGroupsOfUser" returnvariable="attributes.qry_GroupsOfUser" >
					<argument name="user_id" value="#session.theuserid#" />
					<argument name="host_id" value="#session.hostid#" />
					<argument name="check_upc_size" value="true" />
				</invoke>
				<!-- Check the current folder having label text as upc -->
				<invoke object="myFusebox.getApplicationData().labels" method="getlabels" returnvariable="attributes.qry_labels" >
					<argument name="theid" value="#attributes.folder_id#" />
					<argument name="thetype" value="folder" />
					<argument name="checkUPC" value="true" />
				</invoke>
				<!-- Check the UPC folder download -->
				<if condition="attributes.qry_GroupsOfUser.recordcount NEQ '0' AND attributes.qry_GroupsOfUser.upc_size NEQ '' AND attributes.qry_labels NEQ ''">
					<true>
						<if condition="attributes.prefs.set2_meta_export EQ 't'">
							<true>
								<!-- Action: Export Metadata -->
								<do action="meta_export_do" />
							</true>
						</if>
						<!-- CFC: Show the progress UPC download -->
						<invoke object="myFusebox.getApplicationData().folders" methodcall="download_upc_folder(attributes)" />
					</true>
					<false>
						<if condition="attributes.prefs.set2_meta_export EQ 't'">
							<true>
								<!-- Action: Export Metadata -->
								<do action="meta_export_do" />
							</true>
						</if>
						<!-- RAZ-2901 CFC: Show the progress download -->
						<invoke object="myFusebox.getApplicationData().folders" methodcall="download_folder_structure(attributes)" />
					</false>
				</if>
			</false>
		</if>
	</fuseaction>
	
	<!--  -->
	<!-- DOWNLOAD FOLDER: STOP -->
	<!--  -->
	
	<!-- Store Art values -->
	<fuseaction name="store_art_values">
		<set name="session.artofimage" value="#attributes.artofimage#" />
		<set name="session.artofvideo" value="#attributes.artofvideo#" />
		<set name="session.artofaudio" value="#attributes.artofaudio#" />
		<set name="session.artoffile" value="#attributes.artoffile#" />
	</fuseaction>
	
	<!-- Store fileids and filetypes in session (takes care for more then 75 assets at once) -->
	<fuseaction name="store_file_values">
		<!-- Params -->
		<set name="attributes.file_id" value="" overwrite="false" />
		<set name="attributes.thetype" value="" overwrite="false" />
		<!-- Put existing values together -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="store_selection(attributes)" />
	</fuseaction>
	
	<!-- Store all ids -->
	<fuseaction name="store_file_all">
		<if condition="attributes.folder_id NEQ '0'">
			<true>
				<!-- CFC: Store -->
				<invoke object="myFusebox.getApplicationData().folders" methodcall="store_values(attributes)" />
			</true>
		</if>
		<!-- for folder trash files-->
		<if condition="attributes.folder_id EQ '0' AND attributes.thekind EQ 'trashfiles'">
			<true>
				<!-- CFC: Store trash file ids-->
				<invoke object="myFusebox.getApplicationData().folders" methodcall="trash_file_values()" />
			</true>
		</if>
		<!-- for trash folder-->
		<if condition="attributes.folder_id EQ '0' AND attributes.thekind EQ 'trashfolder'">
			<true>
				<!-- CFC: Store trash folder ids-->
				<invoke object="myFusebox.getApplicationData().folders" methodcall="trash_folder_values()" />
			</true>
		</if>
		<!-- for collection trash files-->
		<if condition="attributes.folder_id EQ '0' AND attributes.thekind EQ 'colfiles'">
			<true>
				<!-- CFC: Store trash collection files ids-->
				<invoke object="myFusebox.getApplicationData().collections" methodcall="trash_file_values()" />
			</true>
		</if>
		<!-- for trash collection -->
		<if condition="attributes.folder_id EQ '0' AND attributes.thekind EQ 'collections'">
			<true>
				<!-- CFC: Store trash collection ids-->
				<invoke object="myFusebox.getApplicationData().collections" methodcall="trash_col_values()" />
			</true>
		</if>
		<!-- for collection trash folders -->
		<if condition="attributes.folder_id EQ '0' AND attributes.thekind EQ 'colfolders'">
			<true>
				<!-- CFC: Collection trash folder ids-->
				<invoke object="myFusebox.getApplicationData().collections" methodcall="trash_folder_values()" />
			</true>
		</if>
	</fuseaction>

	<!-- Store all ids for search -->
	<fuseaction name="store_file_search">
		<!-- Simply set sessions -->
		<set name="session.file_id" value="#attributes.fileids#" />
		<set name="session.thefileid" value="#session.file_id#" />
		<if condition="isdefined('attributes.editids')">
			<true>
				<set name="session.editids" value="#attributes.editids#" />
			</true>
		</if>
	</fuseaction>

	<!-- Swap session for editids -->
	<fuseaction name="swap_store_file_ids">
		<!-- Simply set sessions -->
		<set name="session.file_id" value="#session.editids#" />
		<set name="session.thefileid" value="#session.file_id#" />
	</fuseaction>

	<!-- Set view and maxpage and offset -->
	<fuseaction name="set_view">
		<!-- Param -->
		<set name="session.offset" value="0" />
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
	
	<!-- Download asset window -->
	<fuseaction name="file_download">
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
		<if condition="attributes.kind EQ 'doc' OR attributes.kind EQ 'other'">
			<true>
				<invoke object="myFusebox.getApplicationData().files" methodcall="detail(attributes)" returnvariable="attributes.qry_detail" />
			</true>
		</if>
		<!-- CFC: Get Additional versions -->
		<invoke object="myFusebox.getApplicationData().global" methodcall="get_versions_link(attributes)" returnvariable="qry_av" />
		<!-- CFC: Get individual share options -->
		<invoke object="myFusebox.getApplicationData().global" methodcall="get_share_options(attributes)" returnvariable="qry_share_options" />
		<!-- Show -->
		<do action="ajax.file_download" />
	</fuseaction>
	<!-- Show metadata for renditions -->
	<fuseaction name="rend_meta">
		<!-- <set name="attributes.av" value="0" /> -->
		<!-- Get Languages -->
		<do action="languages" />
		<!-- Images -->
		<if condition="attributes.thetype EQ 'img'">
			<true>
				<!-- Set field names -->
				<set name="attributes.desc" value="img_desc_" />
				<set name="attributes.keys" value="img_keywords_" />
				<!-- CFC: Get file detail -->
				<invoke object="myFusebox.getApplicationData().images" methodcall="detail(attributes)" returnvariable="qry_detail" />
				<!-- If additional version then get filename from additional_versions table -->
				<if condition ="isdefined('attributes.av') AND attributes.av eq '1'">
					<true>
						<set name="attributes.useavid" value="1" />
						<!-- CFC: Get Additional versions -->
						<invoke object="myFusebox.getApplicationData().global" methodcall="get_versions_link(attributes)" returnvariable="qry_av" />
						<!-- Set filename -->
						<set name="attributes.filename" value="#qry_av.assets.av_link_title#" />
					</true>	
					<false>
						<!-- Set filename -->
						<set name="attributes.filename" value="#qry_detail.detail.img_filename#" />
					</false>
				</if>
			
			</true>
		</if>
		<!-- Videos -->
		<if condition="attributes.thetype EQ 'vid'">
			<true>
				<!-- Set field names -->
				<set name="attributes.desc" value="vid_desc_" />
				<set name="attributes.keys" value="vid_keywords_" />
				<!-- CFC: Get file detail -->
				<invoke object="myFusebox.getApplicationData().videos" methodcall="detail(attributes)" returnvariable="qry_detail" />
				<!-- If additional version then get filename from additional_versions table -->
				<if condition ="isdefined('attributes.av') AND attributes.av eq '1'">
					<true>
						<set name="attributes.useavid" value="1" />
						<!-- CFC: Get Additional versions -->
						<invoke object="myFusebox.getApplicationData().global" methodcall="get_versions_link(attributes)" returnvariable="qry_av" />
						<!-- Set filename -->
						<set name="attributes.filename" value="#qry_av.assets.av_link_title#" />
					</true>	
					<false>
						<!-- Set filename -->
						<set name="attributes.filename" value="#qry_detail.detail.vid_filename#" />
					</false>
				</if>
			</true>
		</if>
		<!-- Audios -->
		<if condition="attributes.thetype EQ 'aud'">
			<true>
				<!-- Set field names -->
				<set name="attributes.desc" value="aud_desc_" />
				<set name="attributes.keys" value="aud_keywords_" />
				<!-- CFC: Get file detail -->
				<invoke object="myFusebox.getApplicationData().audios" methodcall="detail(attributes)" returnvariable="qry_detail" />
				<!-- If additional version then get filename from additional_versions table -->
				<if condition ="isdefined('attributes.av') AND attributes.av eq '1'">
					<true>
						<set name="attributes.useavid" value="1" />
						<!-- CFC: Get Additional versions -->
						<invoke object="myFusebox.getApplicationData().global" methodcall="get_versions_link(attributes)" returnvariable="qry_av" />
						<!-- Set filename -->
						<set name="attributes.filename" value="#qry_av.assets.av_link_title#" />
					</true>	
					<false>
						<!-- Set filename -->
						<set name="attributes.filename" value="#qry_detail.detail.aud_name#" />
					</false>
				</if>
			</true>
		</if>
		<!-- Files -->
		<if condition="attributes.thetype EQ 'doc'">
			<true>
				<!-- Set field names -->
				<set name="attributes.desc" value="file_desc_" />
				<set name="attributes.keys" value="file_keywords_" />
				<!-- CFC: Get file detail -->
				<invoke object="myFusebox.getApplicationData().files" methodcall="detail(attributes)" returnvariable="qry_detail" />
				<!-- If additional version then get filename from additional_versions table -->
				<if condition ="isdefined('attributes.av') AND attributes.av eq '1'">
					<true>
						<set name="attributes.useavid" value="1" />
						<!-- CFC: Get Additional versions -->
						<invoke object="myFusebox.getApplicationData().global" methodcall="get_versions_link(attributes)" returnvariable="qry_av" />
						<!-- Set filename -->
						<set name="attributes.filename" value="#qry_av.assets.av_link_title#" />
					</true>	
					<false>
						<!-- Set filename -->
						<set name="attributes.filename" value="#qry_detail.file_name#" />
					</false>
				</if>
			</true>
		</if>
		<!-- CFC: Check for custom fields -->
		<invoke object="myFusebox.getApplicationData().custom_fields" methodcall="getfields(attributes)" returnvariable="qry_cf" />

		<!-- CFC: Get customization -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="get_customization()" returnvariable="cs" />

		<!-- Show -->
		<do action="ajax.rend_meta" />
	</fuseaction>
	<!-- Save rend metadata -->
	<fuseaction name="rend_meta_save">
		<!-- Check if there are custom fields to be saved (we do this before because of indexing) -->
		<if condition="attributes.customfields NEQ 0">
			<true>
				<do action="custom_fields_save" />
			</true>
		</if>
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- Images -->
		<if condition="attributes.thetype EQ 'img'">
			<true>
				<!-- CFC: Save file detail -->
				<invoke object="myFusebox.getApplicationData().images" methodcall="update(attributes)" />
			</true>
		</if>
		<!-- If we are files -->
		<if condition="attributes.thetype EQ 'doc'">
			<true>
				<invoke object="myFusebox.getApplicationData().files" methodcall="update(attributes)" />
			</true>
		</if>
		<!-- If we are videos -->
		<if condition="attributes.thetype EQ 'vid'">
			<true>
				<invoke object="myFusebox.getApplicationData().videos" methodcall="update(attributes)" />
			</true>
		</if>
		<!-- If we are audios -->
		<if condition="attributes.thetype EQ 'aud'">
			<true>
				<invoke object="myFusebox.getApplicationData().audios" methodcall="update(attributes)" />
			</true>
		</if>
	</fuseaction>

	<!-- Show custom Razuna -->
	<fuseaction name="view_custom">
		<!-- Check that API key is valid -->
		<invoke object="myFusebox.getApplicationData().users" methodcall="checkapikey(attributes.api_key)" />
		<!-- If there is a userid then set sessions to userid -->
		<if condition="structkeyexists(url,'userid')">
			<true>
				<!-- Set session to the userid -->
				<set name="session.theuserid" value="#url.userid#" />
				<!-- Get the groups of this user -->
				<invoke object="myFusebox.getApplicationData().groups_users" method="getGroupsOfUser">
					<argument name="user_id" value="#url.userid#" />
					<argument name="host_id" value="#session.hostid#" />
				</invoke>				
 			</true>
		</if>
		<!-- If there is a userid then set sessions to userid -->
		<if condition="structkeyexists(url,'sortby')">
			<true>
				<set name="session.sortby" value="#url.sortby#" />
			</true>
		</if>
		<!-- If there is a customparam then set it in a session -->
		<if condition="structkeyexists(url,'customparams')">
			<true>
				<set name="session.customparams" value="#url.customparams#" />
			</true>
		</if>
		<!-- Param -->
		<set name="attributes.access" value="r" overwrite="false" />
		<set name="attributes.fileid" value="" overwrite="false" />
		<set name="attributes.showsubfolders" value="F" overwrite="false" />
		<!-- Reset the rowmax and offset values -->
		<set name="session.rowmaxpage" value="25" />
		<set name="session.offset" value="0" />
		<!-- Put the custom access into a session -->
		<set name="session.customaccess" value="#attributes.access#" />
		<!-- Put the custom fileid into session -->
		<set name="session.customfileid" value="#attributes.fileid#" />
		<!-- Set that we are in custom view -->
		<set name="session.customview" value="true" />
		<!-- CFC: Custom fields -->
		<invoke object="myFusebox.getApplicationData().custom_fields" methodcall="getfieldssearch(attributes)" returnvariable="qry_cf_fields" />
		<!-- Show main page -->
		<do action="v.view_custom" />
	</fuseaction>

	<!-- Simple Search -->
	<fuseaction name="search_simple_custom">
		<!-- Params -->
		<set name="attributes.searchtext" value="#attributes.searchfor#" />
		<set name="attributes.ui" value="true" />
		<set name="application.razuna.api.dynpath" value="#dynpath#" />
		<set name="session.qimg" value="" overwrite="false" />
		<set name="session.qvid" value="" overwrite="false" />
		<set name="session.qaud" value="" overwrite="false" />
		<set name="session.qdoc" value="" overwrite="false" />
		<set name="session.listdocid" value="" overwrite="false" />
		<set name="session.listimgid" value="" overwrite="false" />
		<set name="session.listvidid" value="" overwrite="false" />
		<set name="session.listaudid" value="" overwrite="false" />
		<!-- Include the search include -->
		<do action="search_include" />
		<!-- CFC: Get customization -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="get_customization()" returnvariable="attributes.cs" />
		<!-- Call search API -->
		<invoke object="myFusebox.getApplicationData().search" methodcall="search_api(attributes)" returnvariable="qry_files" />
		<!-- Set results into different variable name -->
		<set name="qry_files_count" value="#qry_files#" />
		<!-- Put id's into lists -->
		<set name="attributes.listdocid" value="#session.listdocid#" />
		<set name="attributes.listimgid" value="#session.listimgid#" />
		<set name="attributes.listvidid" value="#session.listvidid#" />
		<set name="attributes.listaudid" value="#session.listaudid#" />
		<!-- Set each query -->
		<set name="qry_files.qimg.cnt" value="#session.qimg#" />
		<set name="qry_files.qvid.cnt" value="#session.qvid#" />
		<set name="qry_files.qaud.cnt" value="#session.qaud#" />
		<set name="qry_files.qdoc.cnt" value="#session.qdoc#" />
		<!-- Set the total -->
		<set name="qry_filecount.thetotal" value="#session.thetotal#" />
		<!-- Show -->
		<if condition="!attributes.fcall">
			<true>
				<do action="ajax.search" />
			</true>
			<false>
				<do action="folder_content_results" />
			</false>
		</if>
	</fuseaction>

	<!-- START: Smart Folders -->

	<!-- Get all -->
	<fuseaction name="smart_folders">
		<!-- CFC: Get customization -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="get_customization()" returnvariable="cs" />
		<!-- CFC: Get folders -->
		<invoke object="myFusebox.getApplicationData().smartfolders" methodcall="getall(attributes)" returnvariable="qry_sf" />
		<!-- Show -->
		<do action="ajax.smart_folders" />
	</fuseaction>
	<!-- Get settings -->
	<fuseaction name="smart_folders_settings">
		<!-- Param -->
		<set name="attributes.searchtext" value="" overwrite="false" />
		<!-- CFC: Get one -->
		<invoke object="myFusebox.getApplicationData().smartfolders" methodcall="getone(attributes.sf_id)" returnvariable="qry_sf" />
		<!-- CFC: Check if account is authenticated -->
		<invoke object="myFusebox.getApplicationData().oauth" methodcall="check('dropbox')" returnvariable="chk_dropbox" />
		<!-- CFC: Check if account is authenticated -->
		<invoke object="myFusebox.getApplicationData().oauth" methodcall="check('aws_access_key_id')" returnvariable="chk_s3" />
		<!-- CFC: Get buckets -->
		<invoke object="myFusebox.getApplicationData().oauth" methodcall="check('aws_bucket_name')" returnvariable="qry_s3_buckets" />
		<!-- CFC: Check if account is authenticated -->
		<!-- <invoke object="myFusebox.getApplicationData().oauth" methodcall="check('box')" returnvariable="chk_box" /> -->
		<!-- CFC: Load groups -->
		<invoke object="myFusebox.getApplicationData().groups" method="getall" returnvariable="qry_groups">
			<argument name="thestruct" value="#attributes#" />
			<argument name="mod_id" value="1" />
			<argument name="host_id" value="#session.hostid#" />
		</invoke>
		<!-- CFC: Load Groups of this folder -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="getfoldergroups(attributes.sf_id,qry_groups)" returnvariable="qry_folder_groups" />
		<!-- CFC: Load Groups of this folder for group 0 -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="getfoldergroupszero(attributes.sf_id)" returnvariable="qry_folder_groups_zero" />
		<!-- Params -->
		<if condition="qry_sf.sf.sf_type EQ 'saved_search' AND attributes.searchtext EQ ''">
			<true>
				<set name="attributes.searchtext" value="#qry_sf.sfprop.sf_prop_value#" />
			</true>
		</if>
		<!-- Show -->
		<do action="ajax.smart_folders_settings" />
	</fuseaction>
	<!-- Save settings -->
	<fuseaction name="smart_folders_update">
		<!-- CFC: Update -->
		<invoke object="myFusebox.getApplicationData().smartfolders" methodcall="update(attributes)" />
	</fuseaction>
	<!-- Get content -->
	<fuseaction name="smart_folders_content">
		<!-- Only set the session if we come from the folder list (the first time) -->
		<if condition="structkeyexists(attributes,'root')">
			<true>
				<set name="session.sf_id" value="#attributes.sf_id#" />
			</true>
		</if>
		<!-- CFC: Get one -->
		<invoke object="myFusebox.getApplicationData().smartfolders" methodcall="getone(attributes.sf_id)" returnvariable="qry_sf" />
		<!-- CFC: Get access -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="setaccess(session.sf_id,true)" returnvariable="attributes.folderaccess" />
		<!-- Show -->
		<do action="ajax.smart_folders_content" />
	</fuseaction>
	<!-- Remove folder -->
	<fuseaction name="smart_folders_remove">
		<!-- CFC: Remove sf -->
		<invoke object="myFusebox.getApplicationData().smartfolders" methodcall="remove(attributes.sf_id)" />
	</fuseaction>
	<!-- Remove folder with name -->
	<fuseaction name="smart_folders_remove_name">
		<!-- CFC: Remove sf -->
		<invoke object="myFusebox.getApplicationData().smartfolders" methodcall="removeWithName(attributes.account)" />
	</fuseaction>

	<!-- Load account API and so on -->
	<fuseaction name="sf_load_account">
		<!-- Param -->
		<set name="attributes.noview" value="false" overwrite="false" />
		<set name="session.sf_account" value="#attributes.sf_type#" />
		<set name="attributes.path" value="/" overwrite="false" />
		<set name="attributes.thumbpath" value="#dynpath#/global/host/dropbox/#session.hostid#" overwrite="false" />
		<!-- CFC: get class according to type -->
		<invoke object="myFusebox.getApplicationData()['#session.sf_account#']" method="metadata_and_thumbnails" returnvariable="qry_sf_list">
			<argument name="path" value="#attributes.path#" />
			<argument name="sf_id" value="#session.sf_id#" />
		</invoke>
		<!-- CFC: Get access -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="setaccess(session.sf_id,true)" returnvariable="attributes.folderaccess" />
		<!-- Show -->
		<if condition="!attributes.noview">
			<true>
				<do action="ajax.sf_load_account" />
			</true>
		</if>
	</fuseaction>
	<!-- Show file -->
	<fuseaction name="sf_load_file">
		<!-- CFC: get class according to type -->
		<invoke object="myFusebox.getApplicationData()['#session.sf_account#']" methodcall="media(attributes.path)" />
	</fuseaction>
	<!-- Download file -->
	<fuseaction name="sf_load_download">
		<!-- Param -->
		<set name="attributes.rootpath" value="#ExpandPath('../..')#" />
		<set name="attributes.langcount" value="1" />
		<set name="attributes.dynpath" value="#dynpath#" />
		<set name="attributes.httphost" value="#cgi.http_host#" />
		<!-- All files are being download into the account folder -->
		<set name="attributes.folderpath" value="#gettempdirectory()##session.sf_account#" />
		<set name="attributes.thepath" value="#thispath#" />
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- Action: Check storage -->
		<do action="storage" />
		<!-- Set that function should move file instead of copy -->
		<set name="attributes.actionforfile" value="move" />
		<!-- CFC: Get one -->
		<invoke object="myFusebox.getApplicationData().smartfolders" methodcall="getone(session.sf_id)" returnvariable="qry_sf" />
		<set name="attributes.zip_extract" value="#qry_sf.sf.sf_zipextract#" />
		<!-- CFC: get class according to type -->
		<invoke object="myFusebox.getApplicationData()['#session.sf_account#']" methodcall="downloadfiles(session.sf_path,attributes)" returnvariable="attributes.thefile" />		
		<!-- Call CFC -->
		<!-- <do action="asset_upload_server" /> -->
	</fuseaction>
	<!-- If we call the choose folder within the plugin -->
	<fuseaction name="sf_load_download_folder">
		<!-- Call the include but only if we path have defined (needed so we don't overwrite it when coming from multi select) -->
		<if condition="structkeyexists(attributes,'path')">
			<true>
				<do action="sf_load_download_folder_include" />
			</true>
		</if>
		<!-- Param -->
		<set name="session.type" value="sf_download" />
		<!-- Show the choose folder -->
		<do action="choose_folder" />
	</fuseaction>
	<!-- This is just an include and can be called to store the paths -->
	<fuseaction name="sf_load_download_folder_include">
		<!-- Set path in session -->
		<set name="session.sf_path" value="#attributes.path#" />
	</fuseaction>

	<!-- END: Smart Folders -->

	<!-- START: OAUTH -->

	<!-- Get application Keys -->
	<fuseaction name="getappkey">
		<if condition="!structKeyExists(session, '#attributes.account#')">
			<true>
				<!-- Set DB connection for keys -->
				<do action="setdbrazclients" />
				<!-- CFC -->
				<invoke object="myFusebox.getApplicationData().settings" methodcall="getappkey(attributes.account)" />
			</true>
		</if>
	</fuseaction>
	<!-- Authenticate -->
	<fuseaction name="oauth_authenticate">
		<!-- Get the app keys -->
		<do action="getappkey" />
		<!-- CFC -->
		<invoke object="myFusebox.getApplicationData().oauth" methodcall="authenticate(attributes.account)" />
	</fuseaction>
	<!-- Return from authentication -->
	<fuseaction name="oauth_authenticate_return">
		<!-- CFC -->
		<invoke object="myFusebox.getApplicationData().oauth" methodcall="authenticate_return(attributes)" />
	</fuseaction>
	<!-- Disconnect account -->
	<fuseaction name="oauth_remove">
		<!-- CFC -->
		<invoke object="myFusebox.getApplicationData().oauth" methodcall="remove(attributes.account)" />
		<!-- Load integration again -->
		<do action="admin_integration" />
	</fuseaction>

	<!-- Set database connection for razuna_clients -->
	<fuseaction name="setdbrazclients">
		<!-- Set values from form into the sessions -->
		<set name="session.firsttime.database" value="razuna_client" />
		<!-- CFC: Check if there is a DB Connection -->
		<invoke object="myFusebox.getApplicationData().global" methodcall="verifydatasource()" returnvariable="theconnection" />
		<!-- Only execute if we don't have a connection -->
		<if condition="theconnection NEQ 'true'">
			<true>
				<!-- Set db values -->
				<set name="session.firsttime.database_type" value="mysql" />
				<set name="session.firsttime.db_name" value="razuna_clients" />
				<set name="session.firsttime.db_server" value="db.razuna.com" />
				<set name="session.firsttime.db_port" value="3306" />
				<set name="session.firsttime.db_user" value="razuna_client" />
				<set name="session.firsttime.db_pass" value="D63E61251" />
				<set name="session.firsttime.db_action" value="create" />
				<!-- CFC: Add the datasource -->
				<invoke object="myFusebox.getApplicationData().global" methodcall="setdatasource()" />
			</true>
		</if>
	</fuseaction>

	<!-- Detail Proxy Service -->
	<fuseaction name="detail_proxy">
		<!-- Query details -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="getdetailnextback(attributes)" returnvariable="qry_f" />
		<set name="attributes.file_id" value="#qry_f.fileid#" />
		<!-- <set name="attributes.row" value="#qry_f.row#" /> -->
		<set name="attributes.what" value="#qry_f.type#" />
		<!-- Redirect to detail according to type -->
		<if condition="qry_f.type EQ 'images'">
			<true>
				<do action="images_detail" />
			</true>
		</if>
		<if condition="qry_f.type EQ 'videos'">
			<true>
				<do action="videos_detail" />
			</true>
		</if>
		<!-- Redirect to detail according to 'files' type -->
		<if condition="qry_f.type EQ 'doc' OR qry_f.type EQ 'other' OR qry_f.type EQ 'files'">
			<true>
				<do action="files_detail" />
			</true>
		</if>
		<if condition="qry_f.type EQ 'audios'">
			<true>
				<do action="audios_detail" />
			</true>
		</if>
	</fuseaction>

	<!-- Select Label popup-->
	<fuseaction name="select_label_popup">
		<!-- Param -->
		<set name="attributes.file_id" value="#attributes.file_id#" />
		<set name="attributes.file_type" value="#attributes.file_type#" />
		<set name="attributes.show" value="default" />
		<!-- Get search label index (A,B,..Z)-->
		<invoke object="myFusebox.getApplicationData().labels" methodcall="get_search_label_index(attributes)" returnvariable="qry_search_label_index" />
		<!-- Show the choose folder -->
		<do action="ajax.select_label_popup" />
	</fuseaction>
	
	<!-- Search label for the asset-->
	<fuseaction name="search_label_for_asset">
		<!-- Param -->
		<set name="attributes.show" value="#attributes.show#" />
		<!-- Get labels for this record -->
		<invoke object="myFusebox.getApplicationData().labels" methodcall="getlabels(attributes.file_id,attributes.file_type)" returnvariable="attributes.asset_labels_list" />
		<!-- CFC -->
		<invoke object="myFusebox.getApplicationData().labels" methodcall="get_all_labels_for_show(attributes)" returnvariable="qry_labels" />
		<!-- Get the groups of this user -->
		<invoke object="myFusebox.getApplicationData().groups_users" method="getGroupsOfUser" returnvariable="qry_GroupsOfUser" >
			<argument name="user_id" value="#session.theuserid#" />
			<argument name="host_id" value="#session.hostid#" />
		</invoke>
		<!-- CFC: Get setting -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="get_label_set(attributes)" returnvariable="qry_labels_setting" />
		<!-- Show the choose folder -->
		<do action="ajax.search_label_for_asset" />
	</fuseaction>
	
	<!-- Add or Remove the label for asset -->
	<fuseaction name="asset_label_add_remove">
		<!-- CFC -->
		<if condition="attributes.fileid NEQ '0'">
			<true>
				<invoke object="myFusebox.getApplicationData().labels" methodcall="asset_label_add_remove(attributes)" />
			</true>
			<false>
				<!-- RAZ - 2708 advanced search : Set selected labels id to assign the session variable  -->
				<if condition="attributes.checked EQ 'true' AND attributes.thetype EQ 'all'">
					<true>
						<set name="session.search.labels_all" value="#listappend(session.search.labels_all,attributes.labels,',')#" />
					</true>
					<false>
						<set name="session.search.labels_all" value="#ListDeleteAt( session.search.labels_all, ListFind(session.search.labels_all,attributes.labels,','), ',')#" />
					</false>
				</if>
				<if condition="attributes.checked EQ 'true' AND attributes.thetype EQ 'img'">
					<true>
						<set name="session.search.labels_img" value="#listappend(session.search.labels_img,attributes.labels,',')#" />
					</true>
					<false>
						<set name="session.search.labels_img" value="#ListDeleteAt( session.search.labels_img, ListFind(session.search.labels_img,attributes.labels,','), ',')#" />
					</false>
				</if>
				<if condition="attributes.checked EQ 'true' AND attributes.thetype EQ 'aud'">
					<true>
						<set name="session.search.labels_aud" value="#listappend(session.search.labels_aud,attributes.labels,',')#" />
					</true>
					<false>
						<set name="session.search.labels_aud" value="#ListDeleteAt( session.search.labels_aud, ListFind(session.search.labels_aud,attributes.labels,','), ',')#" />
					</false>
				</if>
				<if condition="attributes.checked EQ 'true' AND attributes.thetype EQ 'vid'">
					<true>
						<set name="session.search.labels_vid" value="#listappend(session.search.labels_vid,attributes.labels,',')#" />
					</true>
					<false>
						<set name="session.search.labels_vid" value="#ListDeleteAt( session.search.labels_vid, ListFind(session.search.labels_vid,attributes.labels,','), ',')#" />
					</false>
				</if>
				<if condition="attributes.checked EQ 'true' AND attributes.thetype EQ 'doc'">
					<true>
						<set name="session.search.labels_doc" value="#listappend(session.search.labels_doc,attributes.labels,',')#" />
					</true>
					<false>
						<set name="session.search.labels_doc" value="#ListDeleteAt( session.search.labels_doc, ListFind(session.search.labels_doc,attributes.labels,','), ',')#" />
					</false>
				</if>
			</false>
		</if>
	</fuseaction>

	<!-- Folder subscribe -->
	<fuseaction name="folder_subscribe">
		<!-- Param -->
		<set name="attributes.theid" value="0" overwrite="false" />
		<set name="attributes.emailnotify" value="no" overwrite="false" />
		<set name="attributes.emailinterval" value="0" overwrite="false" />
		<!-- CFC: Subscribe -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="getsubscribefolder(attributes.theid)" returnvariable="qry_folder" />
		<!-- XFA -->
		<xfa name="submitfolderform" value="c.folder_subscribe_save" />
		<!-- Show -->
		<do action="ajax.folder_subscribe" />
	</fuseaction>

	<!-- Save Folder subscribe details -->
	<fuseaction name="folder_subscribe_save">
		<!-- Param -->
		<set name="attributes.theid" value="0" overwrite="false" />
		<!-- CFC: Subscribe -->
		<invoke object="myFusebox.getApplicationData().folders" methodcall="subscribe(attributes)" />
	</fuseaction>
	
	<!-- Run Folder subscribe schedule tasks -->
	<fuseaction name="folder_subscribe_task">
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- Action: Storage -->
		<do action="storage" /> 
		<!-- CFC: Get the Schedule -->
		<invoke object="myFusebox.getApplicationData().scheduler" methodcall="folder_subscribe_task()" returnvariable="thetask" />
	</fuseaction>

	<!-- Lucene index for hosted -->
	<fuseaction name="req_index_update_hosted">
		<!-- Params -->
		<set name="attributes.thepath" value="#thispath#" />
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- Action: Storage -->
		<do action="storage" />
		<!-- CFC: update -->
		<invoke object="myFusebox.getApplicationData().lucene" methodcall="index_update_hosted(thestruct=attributes)" />
	</fuseaction>

	<!-- Metadata export template -->
	<fuseaction name="admin_export_template">
		<!-- Param -->
		<set name="attributes.meta_keys" value="id,filename" />
		<set name="attributes.meta_default" value="labels,keywords,description,type" />
		<set name="attributes.meta_img" value="iptcsubjectcode,creator,title,authorstitle,descwriter,iptcaddress,category,categorysub,urgency,iptccity,iptccountry,iptclocation,iptczip,iptcemail,iptcwebsite,iptcphone,iptcintelgenre,iptcinstructions,iptcsource,iptcusageterms,copystatus,iptcjobidentifier,copyurl,iptcheadline,iptcdatecreated,iptcimagecity,iptcimagestate,iptcimagecountry,iptcimagecountrycode,iptcscene,iptcstate,iptccredit,copynotice" />
		<set name="attributes.meta_doc" value="author,rights,authorsposition,captionwriter,webstatement,rightsmarked" />
		<!-- CFC: Get settings -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="getsettingsfromdam()" returnvariable="prefs" />
		<!-- CFC: Get export template -->
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="get_export_template(attributes)" returnvariable="qry_export" />
		<!-- Get Custom fields -->
		<invoke object="myFusebox.getApplicationData().custom_fields" methodcall="get(true)" returnvariable="meta_cf" />
		<!-- Show metadata export template -->
		<do action="ajax.admin_export_template" />
	</fuseaction>

	<!-- Metadata export template save -->
	<fuseaction name="admin_export_template_save">
		<!-- Path -->
		<set name="attributes.thepathup" value="#ExpandPath('../../')#" />
		<!-- CFC -->
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="set_export_template(attributes)" />
	</fuseaction>

	<!-- Updater Tool -->
	<fuseaction name="updater_tool">
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- CFC -->
		<invoke object="myFusebox.getApplicationData().global" methodcall="updaterLogs()" returnvariable="qry_logs" />
		<!-- Show -->
		<do action="ajax.updater_tool" />
	</fuseaction>

	<!-- Metadata export template save -->
	<fuseaction name="updater_tool_clean_log">
		<!-- CFC -->
		<invoke object="myFusebox.getApplicationData().global" methodcall="updaterLogsClean()" />
		<!-- Show -->
		<do action="updater_tool" />
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

	<!-- Admin Access Control -->
	<fuseaction name="admin_access">
		<!-- CFC: Get groups -->
		<invoke object="myFusebox.getApplicationData().groups" method="getall" returnvariable="qry_groups">
			<argument name="mod_id" value="1" />
		</invoke>
		<!-- CFC: Get users -->
		<invoke object="myFusebox.getApplicationData().users" methodcall="getall(attributes)" returnvariable="qry_users" />
		<!-- CFC: Get Access Control Settings -->
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="getaccesscontrol()" returnvariable="access_struct" />
		<!-- Show -->
		<do action="ajax.admin_access" />
	</fuseaction>

	<fuseaction name="admin_access_save">
		<!-- CFC: Save data -->
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="setaccesscontrol(attributes)" />
	</fuseaction>

	<fuseaction name="basket_upload2local">
		<set name="attributes.hostid" value="#session.hostid#" />
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- CFC: Write basket to local folder -->
		<invoke object="myFusebox.getApplicationData().basket" methodcall="writebasket2local(attributes)" returnvariable="thebasket" />
	</fuseaction>

	<fuseaction name="basket_upload2aws">
		<set name="attributes.hostid" value="#session.hostid#" />
		<!-- Action: Get asset path -->
		<do action="assetpath" />
		<!-- CFC: Get customization -->
		<invoke object="myFusebox.getApplicationData().settings" methodcall="get_customization()" returnvariable="cs" />
		<set name="attributes.cs" value="#cs#" />
		<!-- CFC: Write basket to AWS -->
		<invoke object="myFusebox.getApplicationData().basket" methodcall="writebasket2aws(attributes)" returnvariable="thebasket" />
	</fuseaction>

	<!--  -->
	<!-- START: White-Labelling of hosts -->
	<!--  -->

	<!-- Get wl values -->
	<fuseaction name="wl_host">
		<!-- CFC: Get values -->
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="get_options_hosts()" returnvariable="qry_wl" />
		<!-- Show -->
		<do action="ajax.wl_host" />
	</fuseaction>

	<!-- Save wl values -->
	<fuseaction name="wl_host_save">
		<!-- Save WL -->
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="set_options_host(attributes)" />
	</fuseaction>
	<!-- News -->
	<fuseaction name="wl_news">
		<!-- Get options for rss -->
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="get_options_one_host('wl_news_rss_#session.hostid#')" returnvariable="attributes.rss" />
		<!-- Get news -->
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="get_news(hostid=session.hostid)" returnvariable="qry_news" />
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
		<invoke object="myFusebox.getApplicationData().Settings" methodcall="get_news_edit(thestruct=attributes,hostid=session.hostid)" returnvariable="qry_news_edit" />
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

	<!--  -->
	<!-- END: White-Labelling of hosts -->
	<!--  -->
	<!-- Swap rendition with original -->
	<fuseaction name="swap_rendition_original">
		<!-- save record -->
		<invoke object="myFusebox.getApplicationData().assets" methodcall="swap_rendition_original(attributes)" />
	</fuseaction>

	<!-- Use rendition image for preview -->
	<fuseaction name="use_rendition_for_preview">
		<set name="attributes.thepath" value="#thispath#" />
		<!--  Activate preview image -->
		<do action = "previewimage_activate" />
	</fuseaction>


</circuit>
