<cfset request.page.section = "basic">
<cfset request.page.title = "Scripting within CFML with cfSCRIPT">
<cfset request.page.desc	= "cfScript with its Javascript like syntax lets you build fast business logic">

<style>.opt {color: red}</style>

<div class="subnav">
  <div class="container">
    <ul class="breadcrumb">
      <li><a href="./?/basic_cfml">Basic CFML</a></li>
      <li class="active"><a href="./?/cfscript"><cfoutput>#request.page.title#</cfoutput></a></li>
    </ul>
  </div>
</div>


<div class="content" id="content">
	<div class="container cf">

		<h1 style="text-transform:none">Using &lt;CFSCRIPT&gt;</h1>

		<cfinclude template="pages/sidebar_basic.inc" />
		
		<div class="section">

<p>
CFSCRIPT brings the power of a fully blown language deep inside your CFML applications.
Not dissimilar to Javascript, you can easily and quickly build
complete blocks of code, including functions, to easily build out logic.
All of the standard CFML functions are available including any User Defined Functions (UDF).
</p>

<p>
Statements are written usually one per line, but the delimiter is the semi-colon (;).  Be careful with {} brackets, for everyone you open, you have to close.
</p>

<ul>
	<li><a href="#simple">Simple Constructs</a></li>
	<li class="padtop"><a href="#functions">Declaring Functions</a></li>
	<li class="padtop"><a href="#if">Conditional Logic - if / elseif / else</a></li>
	<li class="padtop"><a href="#switch">Conditional Logic - switch</a></li>
	<li class="padtop"><a href="#for">Loops: for</a></li>
	<li class="padtop"><a href="#while">Loops: while</a></li>
	<li class="padtop"><a href="#do">Loops: do / while</a></li>
	<li class="padtop"><a href="#try">Exception Handling: try / catch / finally</a></li>
	<li class="padtop"><a href="#abort">abort / exit</a></li>
	<li class="padtop"><a href="#import">Object creation: import / new</a></li>
	<li class="padtop"><a href="#param">Parameter Initialization</a></li>
	<li class="padtop"><a href="#lock">Locking blocks</a></li>
	<li class="padtop"><a href="#thread">Thread Creation</a></li>
	<li class="padtop"><a href="#transaction">Transaction</a></li>
</ul>


<!--- -------------------------------------------------------- --->
<a name="simple"></a>
<h2>Simple Constructs</h2>

<p>Writing cfscript code is quick - declare the CFSCRIPT tag and place your script code inside the tags.</p>

<pre class="cfml"><strong>&lt;cfscript></strong>

// This is a comment
// Declaring a variable
x = 0;

/*
 * You can also put comments in blocks like this
 */
WriteOutput( "Outputs content" );

<strong>&lt;/cfscript></strong></pre>


<!--- -------------------------------------------------------- --->
<a name="functions"></a>
<h2>Declaring Functions</h2>

<p>Any function declared inside a CFSCRIPT block is available as a UDF.   You declare functions inside in CFC's using this technique instead of <a href="./?/tag/CFFUNCTION">CFFUNCTION</a>.</p>

<pre class="cfml"><strong>&lt;cfscript></strong>

function myFunction( param1, param2 ){
  var x = arguments.param1;
  var y = arguments.param2;
  return x+y;
}

<strong>&lt;/cfscript></strong></pre>

<p>Functions have in themselves plenty of parameters you can use.</p>

<strong>Defining Attributes of the function</strong>

<p>
The attributes of the function can be declared between the last ")" and the "{" as a key=value pair.   All the attributes available to <a href="./?/tag/CFFUNCTION">CFFUNCTION</a> can be expressed here.
</p>

<pre class="cfml">[<span class="opt">public</span>|<span class="opt">private</span>|<span class="opt">remote</span>|<span class="opt">package</span>] [<span class="opt">returntype</span>] function myFunction( param1, param2 )
  [<span class="opt">output=true</span> <span class="opt">foo="bar"</span> <span class="opt">description="my description"</span> <span class="opt">roles="my roles"</span> <span class="opt">hint="my hint"</span> <span class="opt">displayname="my displayname"</span>]
{
}
</pre>

<p>An example of this in use.</p>

<pre class="cfml"><strong>&lt;cfscript></strong>

// Marks this function as private
private numeric function myFunction( param1, param2 )
  hint="this is a private function"
{
  var x = arguments.param1;
  var y = arguments.param2;
  return x+y;
}

<strong>&lt;/cfscript></strong></pre>

<strong>Defining Attributes of the arguments</strong>

<p>Attributes for a function are usually expressed in <a href="./?/tag/CFARGUMENT">CFARGUMENT</a> tag.  You can pass in the same attributes but more the style of traditional langauges.</p>

<pre class="cfml">function myFunction( [<span class="opt">required</span>] [<span class="opt">type</span>] param1[<span class="opt">="default value"</span>] )</pre>

<p>An example of this in use.</p>

<pre class="cfml"><strong>&lt;cfscript></strong>

// Marks this function as private
private function myFunction( required numeric param1, Array param2="#[1,2,3]#" )
  hint="this is a private function"
{
  var x = arguments.param1;
  var y = arguments.param2[1];
  return x+y;
}

<strong>&lt;/cfscript></strong></pre>

<!--- -------------------------------------------------------- --->
<a name="if"></a>
<h2>Conditional Logic - if / elseif / else</h2>

<p>You can easily utilise conditional logic inside your script, utilising all the usual operators associated with Javascript/Java.</p>

<pre class="cfml"><strong>&lt;cfscript></strong>

if ( isDefined("form.name") ){
  // do something
} else if ( isDefined("form.age") && form.age > 19 ) {
  // do something
} else {
  // do something
}

<strong>&lt;/cfscript></strong></pre>



<!--- -------------------------------------------------------- --->
<a name="switch"></a>
<h2>Conditional Logic - switch</h2>

<p>The switch statement is a good alternative to multiple if statements</p>

<pre class="cfml"><strong>&lt;cfscript></strong>

switch (form.name){
  case "alan":
    WriteOutput( "Welcome Alan" );
    break;

  case "andy":
    WriteOutput( "Welcome Andy" );
    break;

  case 321:
    WriteOutput( "321" );
    break;

  default:
    WriteOutput( "Welcome" );
}

<strong>&lt;/cfscript></strong></pre>



<!--- -------------------------------------------------------- --->
<a name="for"></a>
<h2>Looping: for</h2>

<p>You can loop over data in a variety of ways using CFSCRIPT.</p>

<pre class="cfml"><strong>&lt;cfscript></strong>

// Looping Simple
for ( x=1; x <= 5; x++ ){
  WriteOutput( x );
}


// Looping over an array
myArray = ["openbd","openbluedragon"];
for ( x=1; x <= ArrayLen(myArray); x=x+1 ){
  WriteOutput( myArray[x] );
}


// Looping over a collection/struct
myStruct = {
  name : "alan",
  location : "scotland"
};
for ( key in myStruct ){
  WriteOutput( myStruct[key] );
}


// Looping over an array
myArray = ["alan","andy","ceri"];
for ( arrElement in myArray ){
  WriteOutput( arrElement );
}


// Looping over query
qry = QueryNew( 'name' );
QueryAddrow( qry, 1 );
QuerySetCell( qry, 'name', 'Andy' );
QueryAddRow( qry, 1 );
QuerySetCell( qry, 'name', 'Alan' );

for ( x=1; x <= qry.recordcount; x++ ){
  writeoutput( qry.name[x] );
}

<strong>&lt;/cfscript></strong></pre>

<p>You can easily break out of a loop or skip to the next iteration using the keywords: <strong>continue</strong> and <strong>break</strong>.</p>

<p>In addition, if you are inside a function you can declare the variable there and then inside the for() block:</p>

<pre class="cfml"><strong>&lt;cfscript></strong>

function xyx(){

  // Looping Simple
  for ( var x=1; x <= 5; x++ ){
    WriteOutput( x );
  }

}
<strong>&lt;/cfscript></strong></pre>

<!--- -------------------------------------------------------- --->
<a name="while"></a>
<h2>Looping: while</h2>

<pre class="cfml"><strong>&lt;cfscript></strong>

// Looping Simple
x = 0;
while ( x < 10 ) {
  WriteOutput( x );
  x++;
}

<strong>&lt;/cfscript></strong></pre>


<a name="do"></a>
<h2>Looping: do</h2>

<p>An alternative is to use do/while construct.  Particularly handy if you know you want to execute the body of the loop at least once.</p>

<pre class="cfml"><strong>&lt;cfscript></strong>

// Looping Simple
x = 0;
do{
  WriteOutput( x );
  x++;
} while ( x < 10 );


// Looping over query
qry = QueryNew( 'name' );
QueryAddrow( qry, 1 );
QuerySetCell( qry, 'name', 'Andy' );
QueryAddRow( qry, 1 );
QuerySetCell( qry, 'name', 'Alan' );

qry.reset();
while ( qry.nextRow() ) {
  writeoutput( qry.name );
}

<strong>&lt;/cfscript></strong></pre>


<!--- -------------------------------------------------------- --->
<a name="try"></a>
<h2>Exception Handling: try / catch / finally</h2>

<p>You can easily trap for exceptions using the standard try/catch mechanism, with the optional finally block.  The finally block will always execute,
even if an exception is thrown.  This is very useful when you want to clean up resources (delete a temp file) irrespective of whether or not an exception
is thrown.</p>

<pre class="cfml"><strong>&lt;cfscript></strong>
try{

} catch( Any e ){

} finally {

}
<strong>&lt;/cfscript></strong></pre>


<p>Alternatively, you can throw exceptions to indicate something has gone wrong.  You can also use the <a href="/manual/?/function/throw">throw()</a> function
that lets you control all aspects of the throw exception.  If you are already inside a catch block you can rethrow the exception to the next level.</p>

<pre class="cfml"><strong>&lt;cfscript></strong>
// Throw an exception
throw;

// Throw with an error
throw "Stopping Now";

// Using the function alternative
throw("Application","Message","Extra Detail","errorcode","extendinfo");

// Rethrow
try{

}catch(Any e){
  rethrow;
}
<strong>&lt;/cfscript></strong></pre>


<!--- -------------------------------------------------------- --->
<a name="abort"></a>
<h2>abort / exit</h2>

<p>You can stop the processing of the current request immediately using the <strong>abort</strong> keyword, or using the <strong>exit</strong> you
can exit the current loop, tag, or file.</p>

<pre class="cfml"><strong>&lt;cfscript></strong>
// Stop now
abort;

// Stop now, with an optional message
abort "Stopping Now";

// Exits
exit;

// Exit the tag
exit "exittag";

// Exit the loop
exit "loop";
<strong>&lt;/cfscript></strong></pre>



<!--- -------------------------------------------------------- --->
<a name="import"></a>
<h2>Object creation: import / new</h2>

<p>There is a more Java like way of creating your objects. Instead of using <a href="/manual/?/function/createobject">CreateObject()</a>,
you can now use the new Object() syntax, in much the same way you would declare objects in Java.</p>

<p>In addition to this, the unofficial/official constructor for CFC's, the init() function, is also called
at object creation time, if found.   Which incidentally means, that the init() function no longer needs to return back "this" which is
the standard pattern in CFC creation at the moment.  Naturally, you can still do that with no side effects.</p>

<p>The import statement defines the packages/paths that will be searched for the CFC when you are using the "new" operator.</p>

<pre class="cfml"><strong>&lt;cfscript></strong>
import "org.openbluedragon.importexample";
import org.openbluedragon.importexample;

obj = new Test();
obj = new Test( arg1, arg2 );
obj = new org.openbluedragon.importexample.Test();
<strong>&lt;/cfscript></strong></pre>



<!--- -------------------------------------------------------- --->
<a name="param"></a>
<h2>Parameter Initialization</h2>

<p>Instead of using <a href="/manual/?/tag/CFPARAM">CFPARAM</a> tag outside of the CFSCRIPT block, you can utilise
this powerful directive to initalize your variables in a single statement instead of complicated if blocks.</p>

<pre class="cfml"><strong>&lt;cfscript></strong>
// check "foo" exists
param name="foo";

// check 'bar' is of string type and default 'bar' to "foo" if it doesn't already exist
param name="bar" type="string" default="foo";

// check retest is defined and contains alpha chars only
param name="retest" type="regex" pattern="[a-zA-Z]+";
<strong>&lt;/cfscript></strong></pre>


<!--- -------------------------------------------------------- --->
<a name="lock"></a>
<h2>Locking blocks</h2>

<p>Instead of using <a href="/manual/?/tag/CFLOCK">CFLOCK</a> tag to lock blocks of CFML code from concurrent execution, you can
use the lock directive.</p>

<pre class="cfml"><strong>&lt;cfscript></strong>
lock name="testlock" timeout="5" type="exclusive" {
  // lock body

}
<strong>&lt;/cfscript></strong></pre>



<!--- -------------------------------------------------------- --->
<a name="thread"></a>
<h2>Thread Creation</h2>

<p>Instead of using <a href="/manual/?/tag/CFTHREAD">CFTHREAD</a> tag to create blocks of concurrent execution, you can simply
declare them using the thread directive.</p>

<pre class="cfml"><strong>&lt;cfscript></strong>
thread name="thread1" {
  // thread body
}

thread name="thread2" foo="bar" {
  // thread body
}
<strong>&lt;/cfscript></strong></pre>

<p>Once created, you have control over how you interact with the threads.</p>

<pre class="cfml"><strong>&lt;cfscript></strong>
// sleep for 50ms
thread action="sleep" duration="50";

// terminate thread1
thread action="terminate" name="thread1";

// join on thread1 and thread2
thread action="join" name="thread1,thread2";
<strong>&lt;/cfscript></strong></pre>



<!--- -------------------------------------------------------- --->
<a name="transaction"></a>
<h2>Transaction</h2>

<p>Instead of using <a href="/manual/?/tag/CFTRANSACTION">CFTRANSACTION</a> tag to create blocks of transaction SQL execution, you can simply
declare them using the transaction directive.</p>

<pre class="cfml"><strong>&lt;cfscript></strong>
transaction action="begin" {

  ...

  if ( someConditional ){
    transaction action="rollback";
  }else{
    transaction action="commit";
  }

  ...
}
<strong>&lt;/cfscript></strong></pre>

		</div><!--- .section --->

	</div><!--- .container --->
</div><!--- .content --->