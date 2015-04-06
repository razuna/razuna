<cfset request.page.section = "basic">
<cfset request.page.title = "Why Use CFCs?">
<cfset request.page.desc	= "For many CFML developers, using CFCs may appear to be extra work. But the long term pay off is extreme">

<div class="subnav">
	<div class="container">
		<ul class="breadcrumb">
			<li><a href="./?/basic_cfml">Basic CFML</a></li>
			<li class="active"><a href="./?/cfc_whyuse"><cfoutput>#request.page.title#</cfoutput></a></li>
		</ul>
	</div>
</div>


<div class="content" id="content">
	<div class="container cf">

		<h1>Why Use CFCs?</h1>

		<cfinclude template="pages/sidebar_basic.inc" />
		
		<div class="section">
<p>
For many CFML developers, using CFCs may appear to be extra work. In addition, CFML developers with a procedural background will need to learn new approaches and techniques. The long-term payoff, however, is well worth the effort for the following reasons:
</p>

<ul>
<li>
First and foremost, every modern programming language involves OO features, and today nearly all software is built using object-oriented programming techniques. It is rare for developers to build purely procedural applications. This is not surprising, considering that OO development has existed for over 40 years. Although OOP is not a new concept, it is relatively new in the CFML world, and it is imperative that CFML developers embrace and learn OOP to be competitive with developers who use other technologies.
</li>

<li class="padtop">
Second, CFCs provide developers a better way to build applications. Developers can build flexible, maintainable, and robust applications that are easy to test and debug by working with software objects as they exist in the real world. It may take additional effort for CFML developers more accustomed to older-style CFML coding to internalize these techniques, but most CFML developers who have made the switch cannot even imagine developing applications in any other way.
</li>

<li class="padtop">
Finally, since CFCs are used for a host of other purposes within CFML, understanding CFCs is vital for taking full advantage of the following features in CFML:
<ul>
	<li>Web Services</li>
	<li>Flex (AMF) Integration</li>
	<li>AJAX Integration</li>
	<li>SMTP Integration</li>
</ul>
</li>

</ul>

<h2>Summary</h2>

<p>
With the addition of CFCs to the CFML language, CFML developers can now build fully object-oriented applications that are modularized,
flexible, and easier to test, debug, and maintain. The encapsulation of related attributes (data) and behavior (methods) within a
single component is a simple but powerful concept resulting in safer applications that are easy to extend. By providing the foundation for
modeling real-world objects as software components, CFCs also give developers the opportunity to be more expressive and to create larger and
more complex applications.
</p>

<p><small>&copy; Copyright 2008 GreatBizTools, LLC All rights reserved. <a href="./?/acknowledgement#greatbiztools">Republishing rights</a> have been granted to the Open BlueDragon project by GreatBizTools, LLC.</small></p>

		</div><!--- .section --->

	</div><!--- .container --->
</div><!--- .content --->