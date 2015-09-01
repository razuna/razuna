<cfsilent>
	<cfset request.page.section = "basic">
	<cfset request.page.title 	= "Bootstrap App">
</cfsilent>


<cfinclude template="./assets/_public_header.cfm">


<div class="content" id="content">
	<div class="container cf">

		<h1>Login</h1>

		<div>
		<p><strong>CFML Bootstrap Help</strong> This is the main login page. Here we have a basic form that accepts the username/password for an application.</p>
		<p>We control this using a simple Application.cfc setup; with the /secure/ directory being the place you have to be authenticated to be inside.</p>
		<p>At this level, all pages are considered public. Use <strong>demo</strong> / <strong>password</strong> to login.</p>
		</div>

		<form class="login" action="./secure/" method="post">

			<cfif StructKeyExists(session,"error")>
				<div class="alert-message error">
	  	    <p><cfoutput>#session.error#</cfoutput></p>
  	    </div>
				<cfset StructDelete(session,"error")>
			</cfif>

			<fieldset>
	      <label for="form_user">Username</label>
	      <input id="form_user" name="_user" size="30" type="text" />


	      <label for="form_password">Password</label>
	      <input id="form_password" name="_pass" size="30" type="password" />
			</fieldset>

			<div class="actions cf">
				<input class="btn" value="login" type="submit" />
			</div>

		</form>

	</div><!--- .container --->
</div><!--- .content --->

<script>
// Little piece of javascript to give the username input focus
document.getElementById("form_user").focus();
</script>

<cfinclude template="./assets/_public_footer.cfm">