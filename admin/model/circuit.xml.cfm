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
		<!-- folders -->
		<instantiate class="folders" object="myFusebox.getApplicationData().Folders" overwrite="true">
			<argument name="dsn" value="#application.razuna.datasource#" />
			<argument name="database" value="#application.razuna.thedatabase#" />
		</instantiate>
		<!-- end : folder files -->
		<instantiate class="security" object="myFusebox.getApplicationData().security" arguments="application.razuna.datasource" overwrite="true" />
		<!-- RSS -->
		<instantiate class="rssparser" object="myFusebox.getApplicationData().rssparser" arguments="" overwrite="true" />
		<!-- update -->
		<instantiate class="update" object="myFusebox.getApplicationData().update" overwrite="true">
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
		<!-- Defaults -->
		<instantiate class="defaults" object="myFusebox.getApplicationData().defaults" overwrite="true">
			<argument name="dsn" value="#application.razuna.datasource#" />
		</instantiate>
		<!-- Maintenance -->
		<instantiate class="backuprestore" object="myFusebox.getApplicationData().backuprestore" overwrite="true">
			<argument name="dsn" value="#application.razuna.datasource#" />
			<argument name="database" value="#application.razuna.thedatabase#" />
		</instantiate>
		<!-- RFS -->
		<instantiate class="rfs" object="myFusebox.getApplicationData().rfs" overwrite="true">
			<argument name="dsn" value="#application.razuna.datasource#" />
			<argument name="database" value="#application.razuna.thedatabase#" />
		</instantiate>
		<!-- Plugins -->
		<instantiate class="plugins" object="myFusebox.getApplicationData().plugins" overwrite="true">
			<argument name="dsn" value="#application.razuna.datasource#" />
			<argument name="database" value="#application.razuna.thedatabase#" />
		</instantiate>
		<!-- ResourceManager -->
		<instantiate class="resourcemanager" object="application.razuna.trans" overwrite="true">
			<argument name="resourcePackagePath" value="translations" />
			<argument name="baseLocale" value="en" />
			<argument name="admin" value="admin" />
		</instantiate>
		<!-- Scheduler -->
		<instantiate class="scheduler" object="myFusebox.getApplicationData().scheduler" overwrite="true">
			<argument name="dsn" value="#application.razuna.datasource#" />
			<argument name="database" value="#application.razuna.thedatabase#" />
			<argument name="setid" value="#application.razuna.setid#" />
		</instantiate>
		<!-- Lucene -->
		<instantiate class="lucene" object="myFusebox.getApplicationData().lucene" overwrite="true">
			<argument name="dsn" value="#application.razuna.datasource#" />
			<argument name="database" value="#application.razuna.thedatabase#" />
		</instantiate>
	</fuseaction>

</circuit>
