<cfset request.page.section = "basic">
<cfset request.page.title = "CFC Components">
<cfset request.page.desc	= "ColdFusion Components (CFCs) serve as the basis for object-oriented programming (OOP) in CFML">

<div class="subnav">
	<div class="container">
		<ul class="breadcrumb cf">
			<li><a href="./?/basic_cfml">Basic CFML</a></li>
			<li class="active"><a href="./?/cfc_introduction"><cfoutput>#request.page.title#</cfoutput></a></li>
		</ul>
	</div>
</div>


<div class="content" id="content">
	<div class="container cf">

		<h1>CFC Introduction</h1>

		<cfinclude template="pages/sidebar_basic.inc" />
		
		<div class="section">
<p>
ColdFusion Components (CFCs) serve as the basis for object-oriented programming (OOP) in CFML. This CFC Primer was created to
give developers some background and history of the CFML language from the standpoint of enabling modular application development.
The primer also intends to introduce developers to the power of CFCs and why it is important to take advantage of CFCs in building applications.
</p>

<p>
CFCs are CFML's version of objects. Although CFCs are technically not as powerful as Java objects, CFCs also eliminate much of
the complexity and strictness of Java while providing almost complete OO functionality. CFML is not a fully object-oriented
language. CFCs allow CFML developers, however, to build OO applications that architecturally resemble OO applications in
Java and other languages that are completely object-oriented.
</p>

<p>
CFML developers can use CFCS to build tiered applications in which presentation logic and business logic are completely
separate from each another. This separation of presentation and business logic helps developers create applications
that are easier to build and maintain.
</p>

<p>
The following discussion explains the evolution of modular development in CFML, the precursors of CFCs, and the significance
of CFCs in giving CFML developers the power to create modular applications.
</p>

<h2>cfinclude</h2>

<p>
<a href="./?/tag/CFINCLUDE">cfinclude</a> allows developers to write bits of code in CFML templates that can be included anywhere
within an application.  While <a href="./?/tag/CFINCLUDE">cfinclude</a> is not very powerful for writing modular
code, it avoids the need to cut and paste common code within an application. Using <a href="./?/tag/CFINCLUDE">cfinclude</a>, a
piece of functionality contained in an included template can easily be revised in a single place, and these changes will immediately
be reflected in every instance of the included CFML template throughout an application. Although <a href="./?/tag/CFINCLUDE">cfinclude</a> makes code
reusable in a very basic sense, it does not allow for the development of modular, tiered applications in which presentation logic and business logic
are truly separated.
</p>

<h2>Custom Tags</h2>

<p>
Custom tags allow developers to customize CFML code that can be called in similar fashion to built-in CFML tags
(e.g. &lt;cf_mytag&gt;). They represent a significant advancement over <a href="./?/tag/CFINCLUDE">cfinclude</a>.
Custom tags have their own scope and multiple execution modes (start, body, and end),
they are powerful tools for encapsulating CFML code in a reusable, easy-to-use construct. Custom tags added considerable modular
development capabilities to CFML, but it is still rather difficult to develop fully modular applications by using only custom tags.
</p>

<h2>User-Defined Functions (UDFs)</h2>

<p>
User-defined functions (UDFs) allow CFML developers to write customized functionality that is more flexible and more
discrete than functionality created with custom tags. While UDFs are not as powerful as custom tags in one respect, UDFs are more useful for smaller bits of
functionality or logic and have less performance overhead than custom tags.   UDFs can be written within a <a href="./?/tag/CFSCRIPT">cfscript</a> block.
</p>

<p>
Addition of <a href="./?/tag/CFFUNCTION">cffunction</a>, <a href="./?/tag/CFARGUMENT">cfargument</a>, and <a href="./?/tag/CFRETURN">cfreturn</a> to the language
greatly expanded the power and utility of UDFs, and these tags also serve as the basic building blocks of CFCs.
</p>

<h2>CFC</h2>

<p>
CFCs allow CFML developers to create self-contained modular software components that include both functions in the form of
UDFs (called methods in many other OO languages) as well as object data. The CFML language became much more powerful with
the addition of CFCs, because for the first time it became possible to develop fully modular CFML applications. Many CFML
developers are still learning how to take advantage of this capability. By combining UDFs with object-specific data in the
form of a CFC, it is now possible to build truly modular, tiered, OO applications in CFML.
</p>

<p>
The combination of behavior (functions) and attributes (data) within a single object allows CFML developers to model
real-world objects as software components. Therefore, now it is much easier to conceptualize and develop complex
applications in CFML than it was in the past. In addition, CFCs allow developers to create objects that are cohesive
(single-purposed) and loosely coupled to other CFCs within an application, which makes applications much more flexible and easier to maintain.
</p>

<p align="right"><a href="./?/cfc_structure">next 'CFC Structure' &raquo;</a></p>

<p><small>&copy; Copyright 2008 GreatBizTools, LLC All rights reserved. <a href="./?/acknowledgement#greatbiztools">Republishing rights</a> have been granted to the Open BlueDragon project by GreatBizTools, LLC.</small></p>

		</div><!--- .section --->

	</div><!--- .container --->
</div><!--- .content --->