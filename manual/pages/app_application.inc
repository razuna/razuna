<cfset request.page.section = "basic">
<cfset request.page.title = "CFML Applications">
<cfset request.page.desc	= "CFML Applications are a powerful way of grouping and managing data">

<div class="subnav">
	<div class="container">
		<ul class="breadcrumb">
			<li><a href="./?/basic_cfml">Basic CFML</a></li>
			<li class="active"><a href="./?/cfc_introduction"><cfoutput>#request.page.title#</cfoutput></a></li>
		</ul>
	</div>
</div>


<div class="content" id="content">
	<div class="container cf">

		<h1>cfApplication - the makeup of a CFML application</h1>
		
		<cfinclude template="pages/sidebar_basic.inc" />
		
		<div class="section">

<p>
CFML has a very powerful organizing principal that can be utilised to make it easier to manage web applications.  The cfApplication, or <strong>application</strong> scope, allows you
to define global parameters and functionality that is available to any page/template that resides inside that application.
</p>

<p>
Think of it like it a like a global scope that is present, for only a subset of templates, that you don't have to worry about always loading and unloading.
</p>

<p>
Historically, a CFML cfApplication was setup using the CFAPPLICATION tag that would traditionally be placed inside an Application.cfm file.   This would then setup the <strong>application</strong>
scope that was then available to any template or CFC that was called as part of the request.
</p>

<p>
An application is defined basically, as any directory that has an Application.cfm or Application.cfc contained within it.  Any subdirectories within that folder is also considered part of the
same application.   If any subdirectories contain their own Applicaton.cfm/cfc file then this overrides the top-level application.
</p>

<p>
cfApplication's have properties associated with them (see Application.cfc documentation) that control the behaviour of the application.
</p>

<p>
cfApplication is a very good organizing principal and gives CFML web applications a very tight framework to control the access and security of templates/pages as this method cannot be
overridden by any external forces.   If an Application.cfm/cfc is present in the server web space, it will be called each and every time without fail.
</p>

<p>
You can make use of the Application.cfm/cfc processing characteristics without necessarily setting up an official cfApplication scope.
</p>

<ul>

	<li><a href="./?/app_application_cfm">Application.cfm</a></li>
	<li><a href="./?/app_application_cfc">Application.cfc</a></li>

</ul>

		</div><!--- .section --->

	</div><!--- .container --->
</div><!--- .content --->