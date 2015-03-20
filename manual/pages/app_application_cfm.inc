<cfset request.page.section = "basic">
<cfset request.page.title = "Application.cfm">
<cfset request.page.desc	= "This is file is called at the start of every request">

<div class="subnav">
	<div class="container">
		<ul class="breadcrumb">
			<li><a href="./?/basic_cfml">Basic CFML</a></li>
			<li class="active"><a href="./?/app_application_cfm"><cfoutput>#request.page.title#</cfoutput></a></li>
		</ul>
	</div>
</div>


<div class="content" id="content">
	<div class="container cf">

		<h1>Application.cfm</h1>
		
		<cfinclude template="pages/sidebar_basic.inc" />
		
		<div class="section">
		
<p>
The original design of this file was to be used with the CFAPPLICATION but it has uses beyond that.   This file is called before the requesting template
at the start of any request.
</p>

<p>
This is a standard template that has no special formatting except it must be named observing the case.  For example application.cfm is not the same.
</p>

<p>
You can place anything you wish inside of this file, including any content that will produce output, as this will be rendered to the client.   If you do not
wish this then place all your logic inside a CFSILENT tag.  Traditionally this is where you would place your call to CFAPPLICATION to setup the application
scope for this application.
</p>

<p>
This template is considered the same as any other template, so any output will be sent to the client as well as any errors.  If this template errors, then
the request will stop.  You may also call CFABORT within this tag which will stop the requesting template from being executed, without necessarily indicating
an error to the client.
</p>

<p>
This template is very useful for security provisioning, as it can't be bypassed by the client request no matter what template they request.
</p>

<h2>Location</h2>

<p>
When each request comes in, the engine looks for the <strong>Application.cfm</strong> in the same directory as the requesting template.  If the file is not found,
then it will continue back up the parent directory stack until it finds one.   As soon as it finds one, it will be rendered.
</p>

<p>
This is a very powerful feature, as it allows you to have one top-level <strong>Applciation.cfm</strong> managing setup and security, with all subdirectories utilizing
that same one.
</p>

		</div><!--- .section --->

	</div><!--- .container --->
</div><!--- .content --->