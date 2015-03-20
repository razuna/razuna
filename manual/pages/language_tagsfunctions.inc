<cfset request.page.section = "basic">
<cfset request.page.title = "Getting Started within CFML">
<cfset request.page.desc	= "CFML has a rich array of functions and rich variable types within the language to use">

<div class="subnav">
	<div class="container">
		<ul class="breadcrumb">
			<li><a href="./?/basic_cfml">Basic CFML</a></li>
			<li class="active"><a href="./?/language_tagsfunctions"><cfoutput>#request.page.title#</cfoutput></a></li>
		</ul>
	</div>
</div>


<div class="content" id="content">
	<div class="container cf">

		<h1>Getting Started within CFML</h1>

		<cfinclude template="pages/sidebar_basic.inc" />

		<div class="section">

			<p>CFML is primarily a tag based language.  But what does that mean exactly?  It means that all the directive for interacting with the core engine is performed through special tags that tell the engine to do something special.  All of the CFML tags begin with the prefix <strong>CF</strong>. The OpenBD engine ignores all other tags looking only for those ones.  Therefore, mixing CF tags in with HTML pages is perfectly safe and legal.</p>

			<p>Consider the example below. It is a standard HTML page that has CFML tags embedded within it.  The OpenBD CFML does not see the HTML
			tags simply treating them as a text. It is interested in only tags that it can process.   It will take that tag, execute its functionality
			accordingly and output (if there is any) in the position it resides.  So this example, will loop 10 times, creating a LI tags for each
			iteration.</p>

<cfsavecontent variable="cfml"><nocfml>
<html>
 <body>
  <h1>My First CFML Page</h1>

  <ul>
   <cfloop index="x" from="1" to="10">
    <li><cfoutput>#x#</cfoutput></li>
   </cfloop>
  </ul>
  
 </body>
</html>
</nocfml></cfsavecontent>
<pre class="cfml"><cfoutput>#XmlFormat( Trim(cfml) )#</cfoutput></pre>

			<p>By default, the engine is setup to process files that end with the <strong>.cfml</strong> and <strong>.cfm</strong> extensions.  Although it
			is possible to setup OpenBD to process a whole variety of different file types.</p>

			<p>The rest of this page will look at the basics of what makes up a CFML language.</p>

			<ul>
				<li><a href="#simple">Simple Data Creation</a></li>
				<li><a href="#poundsign">Dynamic String Output</a></li>
				<li><a href="#tagvars">Using variables with tag attributes</a></li>
				<li><a href="#functions">Using Functions</a></li>
				<li><a href="#namedparams">Function Named Parameter Calling</a></li>
				<li><a href="#cfscript">Embedded Script</a></li>
			</ul>

			<h2><a name="simple"></a>Simple Data Creation</h2>

			<p>CFML supports a wide range of different data types (String, number, date, boolean, structures, arrays) and unlike many languages, CFML is
			considered "typeless".  That means you don't have to worry too much about mixing types together, and in the times when you have to, there is
			plenty of helper functions to let you know what type of object it is you are operating with.</p>

			<p>Variables exist throughout your CFML application. There are variables that describe the state of the server, type of request, the URL/FORM
			parameters passed in. In addition to these, there the variables that you can create as a CFML developer, that can persist over the duration
			of the request, function call, or even forever in a server.</p>

			<p>The quickest and easiest way to see what variables are available to you, use the <a href="./?/tag/CFDUMP">CFDUMP</a> tag in your CFML page and reload it
			through a browser.</p>

<cfsavecontent variable="cfml"><nocfml>
<cfdump>

<!--- See the server engine variables --->
<cfdump var="#server#">

<!--- See the HTTP headers --->
<cfdump var="#cgi#">
</nocfml></cfsavecontent>
<pre class="cfml"><cfoutput>#XmlFormat( Trim(cfml) )#</cfoutput></pre>


			<p>CFML does a lot of pre-processing for you to get the variables ready for your application to consume.   FORM/URL variables are automatically
			parsed and decoded and available to you in the <strong>form</strong> and <strong>url</strong> scopes.  Cookies are parsed and made
			available using the <strong>cookie</strong> scope.  There are a number of <a href="./?/language_scopes">special scopes</a> that are available to you depending on where
			you are in your CFML application.</p>
			
			<p>Creating a variable you simply declare it using the <a href="./?/tag/CFSET">CFSET</a> tag, giving it a name and value.  You don't have to
			specify the type of the variable, the OpenBD engine, will decide which data type is appropriate for the data in question.   In many requests,
			CFML is very similiar to Javascript in this manner.</p>
			
<cfsavecontent variable="cfml"><nocfml>
<cfset myname = "Lewis">
<cfset myage = 6>
<cfset mygender = "female">
<cfset myModeIsHappy = true>
</nocfml></cfsavecontent>
<pre class="cfml"><cfoutput>#XmlFormat( Trim(cfml) )#</cfoutput></pre>
			
			<p>As we can see in the example above, we simply create our variables, quoting strings accordingly.</p>
			
			<h2><a name="poundsign"></a>Dynamic String Output</h2>
			
			<p><a href="./?/tag/CFOUTPUT">CFOUTPUT</a> tag is used to tell the engine that you are looking to output variables.  Once you have
			declared this tag, anything in between, is treated by the engine for dynamic string replacement.  It looks for the hash (#) directives
			that delimit the name of a variable inside a string.</p>
			
			<cfsavecontent variable="cfml"><nocfml>
			<cfoutput>My Name is #myname#</cfoutput> or i can use <cfoutput>#myname#</cfoutput>
			</nocfml></cfsavecontent>
			<pre class="cfml"><cfoutput>#XmlFormat( Trim(cfml) )#</cfoutput></pre>
			
			<p>The <a href="./?/tag/CFOUTPUT">CFOUTPUT</a> tag can contain any number of inner tags.  The #..# characters tell the engine to go into
			server-side mode and look for a variable (or function) to replace the content with.   You can't put other CFTAG's inside these #..# but
			you may put function calls.</p>

			<p>But what if you want to actually output a # symbol?  If you simply put in a # on its own, while the engine is processing a
			<a href="./?/tag/CFOUTPUT">CFOUTPUT</a> tag, then the engine will throw an error letting you know you have neglected to close the right
			hand # tag.  To achieve the output of a # tag, you simply escape it with another #.  For example:</p>
			
			<cfsavecontent variable="cfml"><nocfml>
			<cfoutput>My Name is #myname# and this is a single ## hash output</cfoutput>
			</nocfml></cfsavecontent>
			<pre class="cfml"><cfoutput>#XmlFormat( Trim(cfml) )#</cfoutput></pre>
			
			<p>Finally, while you can wrap the whole page in a single pair of <a href="./?/tag/CFOUTPUT">CFOUTPUT</a> tags, is not advisable.  This makes
			it slightly harder to read and debug should things go wrong.   It is much better to target the output tags in areas that make the most
			logical sense.</p>
			
			<h2><a name="tagvars"></a>Using variables with tag attributes</h2>
			
			<p>It can be very confusing at times as to when and where to use the hash (##) signs when it comes to interacting with variables.  In the main,
			you use the ##..## symbols when you want to include the value of a variable (or function) within a string.  However, due to the way tags
			are constructed, with attributes wrapped in the quotes "" then this can make things look confusing.</p>
			
			<p>The key thing to remember is that you are not really processing a string at this point in time, but giving the server-side tag a directive
			that you wish to use the value of the variable (or function) and not the string literal.</p>
			
			<cfsavecontent variable="cfml"><nocfml>
			<!--- Using a #..# in a tag attribute:	this will dump out the whole data structure of 'server'	--->
			<cfdump var="#server#">
			
			<!--- This will simply dump the string literal of 'server' --->
			<cfdump var="server">
			</nocfml></cfsavecontent>
			<pre class="cfml"><cfoutput>#XmlFormat( Trim(cfml) )#</cfoutput></pre>
			
			<p>The general rule of thumb when it comes to #..# usage is <em>less is more</em>.  While the engine will be forgiven to incorrect usage it is
			good practice to get it right from the start.   Too many #..# can be confusing to read and maintain.</p>

			<h2><a name="functions"></a>Using Functions</h2>

			<p>CFML language has a very rich array of functions at its disposal.   There over <a href="/?/function/all">400 functions</a> for you to play with, ranging over a wide
			variety of areas, from simple string manipulate, to dates, arrays, structures and remote calls.</p>
			
			<p>Functions are split into 2 broad types; Core and UDF (User Defined Functions).   Core functions are the ones provided by the underlying engine
			and are highly optimized.   UDF functions on the other hand, are functions that are declared using other CFML tags and functions and created
			on demand by the CFML application.</p>
			
			<p>Usage of the functions are precisely the same and in many respects you don't know you are actually using a UDF function.   The only thing you
			can be assured of, is that a UDF can not re-declare the functionality of a built-in core function.</p>
			
			<p>A function is made up of a name and optionally a list of parameters.  Let us look at an example.  Say we wish to create a date, we can use
			the <a href="./?/function/createdate">CreateDate()</a> function.   As you can see from the documentation, it takes in 3 parameters, year, month and day.</p>

			<cfsavecontent variable="cfml"><nocfml>
			<cfset myDate = CreateDate( 1989, 9, 25 )>
			
			<!--- random day --->
			<cfset myDate2 = CreateDate( 2000, 1, RandRange(1,30) )>
			
			<cfset myYear = 2010>
			<cfset myDate3 = CreateDate( myYear, 1, 1 )>
			
			</nocfml></cfsavecontent>
			<pre class="cfml"><cfoutput>#XmlFormat( Trim(cfml) )#</cfoutput></pre>
			
			<p>
			The above example illustrates a number of different ways to pass variables to a function (note the lack of #..#; you never require to use
			these in parameter passing).
			</p>
			
			<p>
			Functions can be used as parameters to other functions with no problems.  You can also use functions as values to attributes.
			</p>
			
			<cfsavecontent variable="cfml"><nocfml>
			<cfcookie name="mycookie" value="My Value" expires="#CreateDate( 2011, 1, RandRange(1,30) )#">
			</nocfml></cfsavecontent>
			<pre class="cfml"><cfoutput>#XmlFormat( Trim(cfml) )#</cfoutput></pre>
			
			<p>
			Functions are a very powerful way to manipulate data and services.  You will generally find a function that will do what you need most of
			the time.   If you don't; then create one as a UDF!
			</p>
			
			<a name="namedparams"></a>
			<h2>Function Named Parameter Calling</h2>
			
			<p>
			With traditional function calling, you place the parameters in the order the function requires them in.  CFML supports a variable number of
			arguments to functions.   That is a function can take a minimum and maximum set of parameters and as long as the caller puts in the minimum
			set it won't create an error.
			</p>
			
			<p>
			One of the features that UDF functions have enjoyed historically, is the ability to name the parameters you wish to pass into a function.
			This lets you not worry about the order of the parameters or even the specifying them individually, allowing you to pass in a structure
			of all the parameters.
			</p>
			
			<p>This functionality, with OpenBD, is no longer restricted to just UDF.  Core functions can now also enjoy this very rich interface to calling
			functions without any performance penalty. (<em>note at the time of writing not all core functions have been adapted for this feature yet, but the individual function documentation
			will indicate if you can call it this way or not</em>).</p>
			
			<p>Let us look at the different ways you can use this unique support by calling the example <a href="./?/function/writelog">WriteLog()</a>
			function.</p>
			
			<cfsavecontent variable="cfml"><nocfml>
			<cfset WriteLog( "MyOutput", "application" )>
			
			<cfset WriteLog( type="application", text="MyOuptut" )>
			
			<cfset args = {
				text : "MyOutput",
				type : "application"
				}>
			<cfset WriteLog( argumentCollection=args )>
			
			</nocfml></cfsavecontent>
			<pre class="cfml"><cfoutput>#XmlFormat( Trim(cfml) )#</cfoutput></pre>
			
			<p>As you can see with the above 3 examples, each one results in the same function being called. It is down to you as a CFML developer
			to which one type your prefer. For functions that take in a large number of parameters, named-parameters make it very easy to read
			and support.</p>
			
			<h2><a name="cfscript"></a>Embedded Script</h2>
			
			<p>CFSCRIPT brings the power of a fully blown language deep inside your CFML applications. Not dissimilar to
			Javascript/Java, you can easily and quickly build complete blocks of code, including functions, to easily build
			out logic. All of the standard CFML functions are available including any User Defined Functions (UDF).</p>
			
			<p>For more information find out how to <a href="./?/cfscript">write script blocks within CFML</a>.</p>

		</div><!--- .section --->

	</div><!--- .container --->
</div><!--- .content --->