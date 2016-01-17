<cfset request.page.section = "basic">
<cfset request.page.title = "Variable Scopes in CFCs">
<cfset request.page.desc	= "Since CFCs are modular software components that are accessed by other components within an application, it is very important to consider the scope within which data are placed when developing CFCs">

<div class="subnav">
    <div class="container">
        <ul class="breadcrumb">
            <li><a href="./?/basic_cfml">Basic CFML</a></li>
            <li class="active"><a href="./?/cfc_variables"><cfoutput>#request.page.title#</cfoutput></a></li>
        </ul>
    </div>
</div>


<div class="content" id="content">
	<div class="container cf">

		<h1>Variable Scopes in CFCs</h1>

		<cfinclude template="pages/sidebar_basic.inc" />
		
		<div class="section">

<p>
Since CFCs are modular software components that are accessed by other components within an application, it is very important to consider the scope within which data are placed when developing CFCs. The main scopes used (or not used in the case of a particular scope!) within a CFC are the "this" scope, the variables scope, and "var-scoped" variables.
</p>

<h2>the "this" scope</h2>

<p>The <em>this</em> scope is a global scope within the CFC. Any <em>this</em> scoped variables are accessible directly both inside and
outside the CFC. For example, if the firstName attribute in the Person CFC was placed in the this scope, it could be
accessed directly by using dot notation.</p>

<p>
Let's create an instance of a Person CFC called bob. The firstName attribute can be accessed as follows:
&lt;cfset bobsFirstName = bob.firstName /&gt;.  In addition, the firstName value can be set as
follows: &lt;cfset bob.firstName = "Bill" /&gt;
</p>

<p>
Although the above code may be convenient, it provides no data protection whatsoever. If the getter and setter functions are
eliminated, there is nothing to stop someone from doing this: &lt;cfset bob.firstName = "Bill" /&gt;.  This <a href="./?/tag/CFSET">cfset</a> statement would
execute without throwing an error. Without using a setter function to protect the data, Bob's birth date could easily be set to a
string value. This type of code makes debugging difficult because the error will be unknown until the value "Bill" is accessed
and used as a date.
</p>

<p>
The <em>this</em> scope is common in all OO languages. The this scope in CFML, however, functions quite differently than it does in
other OO languages, such as Java. It is important to remember that the this scope in a CFC is completely public.
Therefore, it is strongly recommended that the "<em>this</em>" scope never be used. Many large-scale object-oriented CFML
applications have been built since the addition of CFCs to CFML without ever using the this scope.
</p>

<h2>the "variables" scope</h2>

<p>
Unlike the this scope, the variables scope is private to the CFC.  For example, &lt;cfset bob.firstName = "Bill" /&gt; cannot be called
to set the firstName attribute on the bob instance of the Person CFC. Instead, the getter and setter methods that are made available
need to be used. The variables scope not only provides a simple API for the outside world to access the Person CFC's data, but it also
encapsulates functionality that the Person CFC does not want or need to expose.
</p>

<p>
Consider the birthdate attribute again. If a developer used a setBirthdate() method that explicitly specifies the expectation to
receive a date value as an argument, calling &lt;cfset bob.setBirthdate("Bill") /&gt; would throw an error. This kind of error is
helpful because it tells developers that functions are not getting what they expected, which makes debugging much easier.
</p>

<p>
Note that variables-scoped variables are available throughout the CFC. Any function within the CFC can access variables in the
variables scope, but variables-scoped data are not accessible directly to any code outside the CFC itself.
</p>

<h2>the "var" scope</h2>

<p>
Var-scoped variables are declared within <a href="./?/tag/CFFUNCTION">cffunction</a> tags, in Open BlueDragon you may use the
var keyword anywhere within your functions. Unlike variables in the variables scope, var-scoped variables are local to
the <a href="./?/tag/CFFUNCTION">cffunction</a> within which they are declared.
</p>

<p>
To highlight the importance of the var keyword, consider the following example. Assume there is a CFC containing two functions,
 both of which contain a <a href="./?/tag/CFLOOP">cfloop</a> with an index variable of i.  Keeping the variable i local to the function is crucial;
otherwise, the value of i would be available to the two functions simultaneously, which would likely cause unexpected behavior.
</p>

<p>
Use of the <em>var</em> keyword is also critical to making CFCs thread-safe. Variables that are not var scoped and do not have another
scope declared are put into the <em>variables</em> scope, which means they are global to the CFC. As shown by the loop counter example
above, this can cause unexpected behavior that is very difficult to debug. Moreover, errors or unexpected behavior may begin to
appear only when the application is under heavy load.
</p>

<p>
It is extremely important for ALL variables in CFCs that are local to functions to be var scoped. This may seem a simple thing to do at
first, but keep in mind that this rule applies to all variables that are explicitly created, PLUS variables that are created as a result
of calls to functions or the execution of CFML tags.
</p>

<p>
Some of these cases are obvious, but others are not. The loop counter example is a not-so-obvious case because developers usually
do not think about the loop index variable until the <a href="./?/tag/CFLOOP">cfloop</a> tag is used. Other tags that produce results that must be var
scoped include <a href="./?/tag/CFQUERY">cfquery</a>, <a href="./?/tag/CFHTTP">cfhttp</a>, calls to custom tags, and UDFs that return variables. Be sure to remember that any
variables that are explicitly created, or any variables that are generated by calls to CFML tags, custom tags, or UDFs,
must be var scoped.
</p>

<p>
The following is an example of a <a href="./?/tag/CFFUNCTION">cffunction</a> that contains a <a href="./?/tag/CFQUERY">cfquery</a> and a <a href="./?/tag/CFLOOP">cfloop</a> and returns a simple string:
</p>

<pre class="cfml">
&lt;cffunction name="varScopeFunc" access="public" output="false" returntype="string"
    hint="I am a var scope example">
    &lt;!--- cfargument tags come first --->
    &lt;cfargument name="foo" type="string" required="false" default="" />

    &lt;!--- var scoped variables for the entire function must be declared
        immediately following the cfargument tags!!! --->
    &lt;cfset var i = 0 />
    &lt;cfset var myQuery = 0 />
    &lt;cfset var returnString = "" />

    &lt;!--- now with the var scoped variables declared, we can safely do our work --->
    &lt;cfquery name="myQuery" datasource="#myDSN#">
        SELECT firstName, lastName
        FROM person
        WHERE id = &lt;cfqueryparam value="1" cfsqltype="cf_sql_integer" />
    &lt;/cfquery>
   
    &lt;cfloop index="i" from="1" to="10" step="1">
      &lt;cfset returnString = returnString & "Loop iteration #i#&lt;br />" />
    &lt;/cfloop>

    &lt;cfreturn returnString />
&lt;/cffunction>
</pre>

<p>
Note that the loop counter i, the myQuery variable, and the returnString variable have to be var scoped and be set to a
default value before completing the rest of the function. It may seem odd to set the default value of the query to 0,
but since the initial value of the variable does not matter, this is a simple way to set default values for complex
objects like queries. While this isn't the case in Open BlueDragon, in versions of ColdFusion prior to ColdFusion 9,
var-scoped variables cannot be declared anywhere in the <a href="./?/tag/CFFUNCTION">cffunction</a> other than immediately following the <a href="./?/tag/CFARGUMENT">cfargument</a>
tags (trying to do so will throw a compiler error), so developers may need to do some planning before adding new variables to functions.
</p>

<p align="right"><a href="./?/cfc_encapsulation">next 'CFC Encapsulation' &raquo;</a></p>
<p><small>&copy; Copyright 2008 GreatBizTools, LLC All rights reserved. <a href="./?/acknowledgement#greatbiztools">Republishing rights</a> have been granted to the Open BlueDragon project by GreatBizTools, LLC.</small></p>

		</div><!--- .section --->

	</div><!--- .container --->
</div><!--- .content --->