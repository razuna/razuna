<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE circuit>
<!--
	Example circuit.xml file for the model portion of an application.
-->
<circuit access="internal">

	<fuseaction name="preprocess">
		<set name="attributes.razuna" value="#structnew()#" />
		<set name="attributes.razuna.application" value="#application.razuna#" />
		<set name="attributes.razuna.session" value="#session#" />
		<!-- <set name="request.razuna" value="#attributes#" />
		<include template="t" /> -->
	</fuseaction>

	<!--
		This is executed at application startup (from <appinit>) and
		therefore is thread safe (and does not need a lock):
	-->
	<fuseaction name="initialize">
		<!-- Instantiate CFC's' -->
		<instantiate class="login" object="myFusebox.getApplicationData().Login" overwrite="true" />
		<instantiate class="groups" object="myFusebox.getApplicationData().Groups" overwrite="true" />
		<instantiate class="groups_users" object="myFusebox.getApplicationData().Groups_Users" overwrite="true" />
		<instantiate class="users" object="myFusebox.getApplicationData().Users" overwrite="true" />
		<instantiate class="modules" object="myFusebox.getApplicationData().Modules" overwrite="true" />
		<instantiate class="global" object="myFusebox.getApplicationData().Global" overwrite="true" />
		<instantiate class="hosts" object="myFusebox.getApplicationData().Hosts" overwrite="true" />
		<!-- Settings -->
		<instantiate class="settings" object="myFusebox.getApplicationData().Settings" overwrite="true" />
		<!-- folders -->
		<instantiate class="folders" object="myFusebox.getApplicationData().Folders" overwrite="true" />
		<!-- update -->
		<instantiate class="update" object="myFusebox.getApplicationData().update" overwrite="true" />
		<!-- Amazon -->
		<instantiate class="amazon" object="myFusebox.getApplicationData().amazon" overwrite="true" />
		<!-- Defaults -->
		<instantiate class="defaults" object="myFusebox.getApplicationData().defaults" overwrite="true" />
		<!-- Maintenance -->
		<instantiate class="backuprestore" object="myFusebox.getApplicationData().backuprestore" overwrite="true" />
		<!-- RFS -->
		<instantiate class="rfs" object="myFusebox.getApplicationData().rfs" overwrite="true" />
		<!-- Plugins -->
		<instantiate class="plugins" object="myFusebox.getApplicationData().plugins" overwrite="true" />
		<!-- ResourceManager -->
		<instantiate class="resourcemanager" object="application.razuna.trans" overwrite="true">
			<argument name="resourcePackagePath" value="translations" />
			<argument name="baseLocale" value="en" />
			<argument name="admin" value="admin" />
		</instantiate>
		<!-- Scheduler -->
		<instantiate class="scheduler" object="myFusebox.getApplicationData().scheduler" overwrite="true" />
		<!-- Lucene -->
		<instantiate class="lucene" object="myFusebox.getApplicationData().lucene" overwrite="true" />
	</fuseaction>

</circuit>
