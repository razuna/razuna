<cfinclude template="../assets/_secure_header.cfm">

<div class="content" id="content">
	<div class="container cf">
	
		<h1>Log Out</h1>

		<div>
			<p>Are you sure you wish to logout?</p>
			<p><a class="btn logout" href="../">Yes, log me out</a></p>
		</div>

		<div class="alert-message block-message success">
			<p><strong>CFML Bootstrap Help</strong> Clicking this button will take you to a page on the outside of this directory. There the <code>Application.cfc</code>
			will simply delete the necessary keys from the <code>session</code> scope making sure you can't get back in again.</p>
		</div>

	</div><!--- .container --->
</div><!--- .content --->

<cfinclude template="../assets/_secure_footer.cfm">