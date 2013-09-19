<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE circuit>
<!--
	Example circuit.xml file for the model portion of an application.
-->
<circuit access="internal">
	
	<!--
		Example model fuseaction that just references an action fuse.
		Model fuseactions should only reference actions and queries.
	
	<fuseaction name="getTime">
		<include template="act_get_time" />
	</fuseaction>-->
	
	<!--
		This is executed at application startup (from <appinit>) and
		therefore is thread safe (and does not need a lock):
	-->
	<fuseaction name="initialize">
		<!-- Instantiate CFC's' -->
		<instantiate class="login" object="myFusebox.getApplicationData().Login" arguments="application.razuna.datasource, application.razuna.thedatabase" overwrite="true" />
		<instantiate class="groups" object="myFusebox.getApplicationData().Groups" arguments="application.razuna.datasource, application.razuna.thedatabase" overwrite="true" />
		<instantiate class="groups_users" object="myFusebox.getApplicationData().Groups_Users" arguments="application.razuna.datasource, application.razuna.thedatabase" overwrite="true" />
		<instantiate class="users" object="myFusebox.getApplicationData().Users" arguments="application.razuna.datasource, application.razuna.thedatabase" overwrite="true" />
		<instantiate class="modules" object="myFusebox.getApplicationData().Modules" arguments="application.razuna.datasource, application.razuna.thedatabase" overwrite="true" />
		<instantiate class="global" object="myFusebox.getApplicationData().Global" arguments="application.razuna.datasource, application.razuna.thedatabase" overwrite="true" />
		<instantiate class="hosts" object="myFusebox.getApplicationData().Hosts" arguments="application.razuna.datasource, application.razuna.thedatabase" overwrite="true" />
		<!-- Settings -->
		<instantiate class="settings" object="myFusebox.getApplicationData().Settings" overwrite="true">
			<argument name="dsn" value="#application.razuna.datasource#" />
			<argument name="database" value="#application.razuna.thedatabase#" />
			<argument name="setid" value="#application.razuna.setid#" />
		</instantiate>
		<instantiate class="folders" object="myFusebox.getApplicationData().Folders" overwrite="true">
			<argument name="dsn" value="#application.razuna.datasource#" />
			<argument name="database" value="#application.razuna.thedatabase#" />
		</instantiate>
		<!-- start : folder files -->
		<instantiate class="images" object="myFusebox.getApplicationData().images" overwrite="true">
			<argument name="dsn" value="#application.razuna.datasource#" />
			<argument name="database" value="#application.razuna.thedatabase#" />
		</instantiate>
		<instantiate class="videos" object="myFusebox.getApplicationData().videos" overwrite="true">
			<argument name="dsn" value="#application.razuna.datasource#" />
			<argument name="database" value="#application.razuna.thedatabase#" />
		</instantiate>
		<instantiate class="files" object="myFusebox.getApplicationData().files" overwrite="true">
			<argument name="dsn" value="#application.razuna.datasource#" />
			<argument name="database" value="#application.razuna.thedatabase#" />
		</instantiate>
		<instantiate class="audios" object="myFusebox.getApplicationData().audios" overwrite="true">
			<argument name="dsn" value="#application.razuna.datasource#" />
			<argument name="database" value="#application.razuna.thedatabase#" />
		</instantiate>
		<!-- end : folder files -->
		<!-- assets -->
		<instantiate class="assets" object="myFusebox.getApplicationData().assets" overwrite="true">
			<argument name="dsn" value="#application.razuna.datasource#" />
			<argument name="database" value="#application.razuna.thedatabase#" />
			<argument name="setid" value="#application.razuna.setid#" />
		</instantiate>
		<instantiate class="security" object="myFusebox.getApplicationData().security" arguments="#application.razuna.datasource#" overwrite="true" />
		<instantiate class="rssparser" object="myFusebox.getApplicationData().rssparser" arguments="" overwrite="true" />
		<!-- eMail -->
		<instantiate class="email" object="myFusebox.getApplicationData().email" overwrite="true">
			<argument name="dsn" value="#application.razuna.datasource#" />
			<argument name="database" value="#application.razuna.thedatabase#" />
		</instantiate>
		<!-- FTP -->
		<instantiate class="ftp" object="myFusebox.getApplicationData().ftp" overwrite="true">
			<argument name="dsn" value="#application.razuna.datasource#" />
			<argument name="database" value="#application.razuna.thedatabase#" />
		</instantiate>
		<!-- Basket -->
		<instantiate class="basket" object="myFusebox.getApplicationData().basket" overwrite="true">
			<argument name="dsn" value="#application.razuna.datasource#" />
			<argument name="database" value="#application.razuna.thedatabase#" />
		</instantiate>
		<!-- Favorites -->
		<instantiate class="favorites" object="myFusebox.getApplicationData().favorites" overwrite="true">
			<argument name="dsn" value="#application.razuna.datasource#" />
			<argument name="database" value="#application.razuna.thedatabase#" />
		</instantiate>
		<!-- XMP -->
		<instantiate class="xmp" object="myFusebox.getApplicationData().xmp" overwrite="true">
			<argument name="dsn" value="#application.razuna.datasource#" />
			<argument name="database" value="#application.razuna.thedatabase#" />
		</instantiate>
		<!-- Search -->
		<instantiate class="search" object="myFusebox.getApplicationData().search" overwrite="true">
			<argument name="dsn" value="#application.razuna.datasource#" />
			<argument name="database" value="#application.razuna.thedatabase#" />
		</instantiate>
		<!-- Collections -->
		<instantiate class="collections" object="myFusebox.getApplicationData().collections" overwrite="true">
			<argument name="dsn" value="#application.razuna.datasource#" />
			<argument name="database" value="#application.razuna.thedatabase#" />
		</instantiate>
		<!-- Scheduler -->
		<instantiate class="scheduler" object="myFusebox.getApplicationData().scheduler" overwrite="true">
			<argument name="dsn" value="#application.razuna.datasource#" />
			<argument name="database" value="#application.razuna.thedatabase#" />
			<argument name="setid" value="#application.razuna.setid#" />
		</instantiate>
		<!-- Log -->
		<instantiate class="log" object="myFusebox.getApplicationData().log" overwrite="true">
			<argument name="dsn" value="#application.razuna.datasource#" />
			<argument name="database" value="#application.razuna.thedatabase#" />
		</instantiate>
		<!-- Lucene -->
		<instantiate class="lucene" object="myFusebox.getApplicationData().lucene" overwrite="true">
			<argument name="dsn" value="#application.razuna.datasource#" />
			<argument name="database" value="#application.razuna.thedatabase#" />
		</instantiate>
		<!-- Custom Fields -->
		<instantiate class="custom_fields" object="myFusebox.getApplicationData().custom_fields" overwrite="true">
			<argument name="dsn" value="#application.razuna.datasource#" />
			<argument name="database" value="#application.razuna.thedatabase#" />
		</instantiate>
		<!-- Nirvanix -->
		<!-- <instantiate class="nirvanix" object="myFusebox.getApplicationData().nirvanix" overwrite="true">
			<argument name="appkey" value="#application.razuna.nvxappkey#" />
		</instantiate> -->
		<!-- Amazon -->
		<instantiate class="amazon" object="myFusebox.getApplicationData().amazon" overwrite="true">
		</instantiate>
		<!-- Akamai -->
		<instantiate class="akamai" object="myFusebox.getApplicationData().akamai" overwrite="true">
		</instantiate>
		<!-- Comments -->
		<instantiate class="comments" object="myFusebox.getApplicationData().comments" overwrite="true">
			<argument name="dsn" value="#application.razuna.datasource#" />
			<argument name="database" value="#application.razuna.thedatabase#" />
		</instantiate>
		<!-- Versions -->
		<instantiate class="versions" object="myFusebox.getApplicationData().versions" overwrite="true">
			<argument name="dsn" value="#application.razuna.datasource#" />
			<argument name="database" value="#application.razuna.thedatabase#" />
		</instantiate>
		<!-- Defaults -->
		<instantiate class="defaults" object="myFusebox.getApplicationData().defaults" overwrite="true">
			<argument name="dsn" value="#application.razuna.datasource#" />
		</instantiate>
		<!-- Maintenance -->
		<instantiate class="backuprestore" object="myFusebox.getApplicationData().backuprestore" overwrite="true">
			<argument name="dsn" value="#application.razuna.datasource#" />
			<argument name="database" value="#application.razuna.thedatabase#" />
		</instantiate>
		<!-- Views -->
		<instantiate class="views" object="myFusebox.getApplicationData().views" overwrite="true">
			<argument name="dsn" value="#application.razuna.datasource#" />
			<argument name="database" value="#application.razuna.thedatabase#" />
		</instantiate>
		<!-- Widgets -->
		<instantiate class="widgets" object="myFusebox.getApplicationData().widgets" overwrite="true">
			<argument name="dsn" value="#application.razuna.datasource#" />
			<argument name="database" value="#application.razuna.thedatabase#" />
		</instantiate>
		<!-- Labels -->
		<instantiate class="labels" object="myFusebox.getApplicationData().labels" overwrite="true">
			<argument name="dsn" value="#application.razuna.datasource#" />
			<argument name="database" value="#application.razuna.thedatabase#" />
		</instantiate>
		<!-- RFS -->
		<instantiate class="rfs" object="myFusebox.getApplicationData().rfs" overwrite="true">
			<argument name="dsn" value="#application.razuna.datasource#" />
			<argument name="database" value="#application.razuna.thedatabase#" />
		</instantiate>
		<!-- Import -->
		<instantiate class="import" object="myFusebox.getApplicationData().import" overwrite="true">
			<argument name="dsn" value="#application.razuna.datasource#" />
			<argument name="database" value="#application.razuna.thedatabase#" />
		</instantiate>
		<!-- Plugins -->
		<instantiate class="plugins" object="myFusebox.getApplicationData().plugins" overwrite="true">
			<argument name="dsn" value="#application.razuna.datasource#" />
			<argument name="database" value="#application.razuna.thedatabase#" />
		</instantiate>
		<!-- API -->
		<instantiate class="api" object="myFusebox.getApplicationData().api" overwrite="true">
			<argument name="dsn" value="#application.razuna.datasource#" />
			<argument name="database" value="#application.razuna.thedatabase#" />
		</instantiate>
		<!-- ResourceManager -->
		<instantiate class="resourcemanager" object="application.razuna.trans" overwrite="true">
			<argument name="resourcePackagePath" value="translations" />
			<argument name="baseLocale" value="en" />
		</instantiate>
		<!-- SmartFolders -->
		<instantiate class="smartfolders" object="myFusebox.getApplicationData().smartfolders" overwrite="true">
			<argument name="dsn" value="#application.razuna.datasource#" />
			<argument name="database" value="#application.razuna.thedatabase#" />
		</instantiate>
		<!-- Oauth -->
		<instantiate class="oauth" object="myFusebox.getApplicationData().oauth" overwrite="true">
		</instantiate>
		<!-- Oauth -->
		<instantiate class="dropbox" object="myFusebox.getApplicationData().dropbox" overwrite="true">
		</instantiate>
	</fuseaction>
	
</circuit>
