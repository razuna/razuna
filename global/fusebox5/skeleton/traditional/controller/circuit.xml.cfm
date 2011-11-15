<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE circuit>
<!--
	Example circuit.xml file for the controller portion of an application.
	Only the controller circuit has public access - the controller circuit
	contains all of the fuseactions that are used in links and form posts
	within your application.
-->
<circuit access="public" xmlns:cf="cf/">
	
	<!--
		Apply a standard layout to the result of every request.
		This is fine for simple applications that have just one layout but
		for more complicated situations you will need to do something more
		advanced.
	-->
	<postfuseaction>
		<do action="layout.mainLayout" />
	</postfuseaction>
	
	<!--
		Default fuseaction for application, uses model and view circuits
		to do all of its work:
	-->
	<fuseaction name="welcome">
		<do action="time.getTime" />
		<do action="display.sayHello" />
	</fuseaction>
		
</circuit>
