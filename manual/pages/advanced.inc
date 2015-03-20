<cfset request.page.section = "adv">
<cfset request.page.title 	= "Advanced Concepts">
<cfset request.page.desc	= "Advanced CFML Concepts">

<div class="subnav">
	<div class="container">
		<ul class="breadcrumb">
			<li class="active"><a href="./?/advanced">Advanced</a></li>
		</ul>
	</div>
</div>


<div class="content" id="content">
	<div class="container cf">
	
	<h1>Advanced CFML Concepts</h1>
	
	<cfinclude template="pages/sidebar_advanced.inc" />
	
	<div class="section">
	
		<p>Here we document some of the advance concepts</p>

			<h4><a href="./?/database_offrequest">Background Queries</a></h4>
			<p>You can push some queries to the background instead of waiting for them to complete in a web request</p>

			<h4><a href="./?/database_mongodb">MongoDB</a></h4>
			<p>See how easy it is to work with the popular NoSQL MongoDB database with your CFML applications</p>

			<h4><a href="./?/cookies">Cookies</a></h4>
			<p>OpenBD has some advanced features for cookie handling</p>

			<h4><a href="./?/cfscript_java">Embedded Java</a></h4>
			<p>Did you know you can drop complete blocks of raw Java code/functions straight into your CFML pages.</p>

			<h4><a href="./?/cfmlmanipulation">CFML Manipulation</a></h4>
			<p>You can manipulate CFML pages from within CFML.  OpenBD provide helper functions/techniques for this.</td>

			<h4><a href="./?/search">Search</a></h4>
			<p>OpenBD comes with an advanced embedded search engine that can be used to index data, files and websites.</p>

			<h4><a href="./?/webservices">Web Services</a></h4>
			<p>An overview of how easy it is to utilise web services with OpenBD CFML.</p>

			<h4><a href="./?/webservices_restlet">RESTlet</a></h4>
			<p>You can easily create hosted RESTlet services for Javascript applications or other servers to consume.</p>
			
			<h4><a href="./?/webservices_json">JSONP</a></h4>
			<p>JSONP is a technique for Javascript applications to easily consume web services without breaking the browsers security.</p>

			<h4><a href="./?/webservices_soap_producing">SOAP - Producing</a></h4>
			<p>You can produce SOAP endpoints for your CFC's advertising their properties via WSDL.</p>

			<h4><a href="./?/webservices_soap_consuming">SOAP - Consuming</a></h4>
			<p>You can consume SOAP endpoints via their WSDL within your applications.</p>

			<h4><a href="./?/amazon_s3">Amazon S3</a></h4>
			<p>Discover how to work with Amazon's popular S3 cloud file storage.</p>

			<h4><a href="./?/amazon_simpledb">Amazon SimpleDB</a></h4>
			<p>See how you can work with Amazon's SimpleDB key/value cloud database.</p>

			<h4><a href="./?/amazon_sqs">Amazon SQS</a></h4>
			<p>Amazon Simple Queuing Server lets you send and consume messages.</p>

			<h4><a href="./?/embedded_database">Embedded Database</a></h4>
			<p>OpenBD ships with the popular embedded H2 relational database. Discover how to use this powerful addition to create onthefly databases.</p>

			<h4><a href="./?/journal">Journal</a></h4>
			<p>OpenBD can record percisely the files, tags and functions any single request performs.  An excellent tool for testing to ensure maximum code coverage.</p>
		
		</div><!--- .section --->

	</div><!--- .container --->
</div><!--- .content --->