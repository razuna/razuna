<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE circuit>
<!--
	Example circuit.xml file for the model portion of an application.
-->
<circuit access="internal">
	
	<!--
		Example model fuseaction that just references an action fuse.
		Model fuseactions should only reference actions and queries.
	-->
	<fuseaction name="getTime">
		<include template="act_get_time" />
	</fuseaction>
	
	<!--
		This is executed at application startup (from <appinit>) and
		therefore is thread safe (and does not need a lock):
	-->
	<fuseaction name="initialize">
		<set name="myFusebox.getApplication().getApplicationData().startTime" value="#now()#" />
	</fuseaction>
	
</circuit>
