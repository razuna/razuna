<cfinclude template="../assets/_secure_header.cfm">

<div class="content" id="content">
	<div class="container cf">
		
		<h1>Secure</h1>

		<p>This is now the secure area. Here you have the standard <code>session</code> scope available where you can store
			various objects and properties associated with this particular user. The underlying <code>Application.cfc</code>
			makes sure they are still logged in, and if not, throws them back to the main page.</p>

		<p>From here you can now create as many pages as you wish inside this <code>/secure</code> folder and they will all
			be covered by the same control logic.  In CFML there is no way to bypass the processing of the <code>Application.cfc</code>
			handler.</p>

		<p>Please view the <code>secure/Application.cfc</code> file for details on the options you have for authenticating the incoming
			user.</p>

	</div><!--- .container --->
</div><!--- .content --->

<cfinclude template="../assets/_secure_footer.cfm">