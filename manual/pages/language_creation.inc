<cfset request.page.section = "basic">
<cfset request.page.title = "CFML Advanced Variables">
<cfset request.page.desc	= "Creating data within CFML is very quick and easy, utilising both functions and Javascript type methods">

<div class="subnav">
  <div class="container">
    <ul class="breadcrumb">
      <li><a href="./?/basic_cfml">Basic CFML</a></li>
      <li class="active"><a href="./?/language_creation"><cfoutput>#request.page.title#</cfoutput></a></li>
    </ul>
  </div>
</div>


<div class="content" id="content">
	<div class="container cf">

		<h1>Using Variables</h1>
		
		<cfinclude template="pages/sidebar_basic.inc" />

		<div class="section">
		
			<p>Variables can be created within CFML a variety of different ways.  Apart from the simple types, there are complex types supported at a language level.</p>

			<ul>
				<li><a href="#simple">Simple Values</a></li>
				<li><a href="#array">Arrays</a></li>
				<li><a href="#struct">Structures</a></li>
				<li><a href="#object">Objects</a></li>
			</ul>
			
			<h2>Simple Values</h2>

			<p>You can create new variables by simply using the tag <a href="/manual/?/tag/CFSET">CFSET</a> and assigning them to a new variable name.</p>
			
<pre class="cfml">&lt;cfset a = 1>
&lt;cfset b = true>
&lt;cfset c = now()>
&lt;cfset d = "StringValue"></pre>
			
			<a name="array"></a>
			<h2>Creating Arrays</h2>
			
			<p>An array is a list of simple values, complex types or objects that are referenced using the indexed they occupy in the list.  Array's in CFML
			are 1 (one) based and not 0 (zero) based like Javascript or Java.</p>
			
			<p>There are mainly two ways to create arrays.  The classic approach is to use the <a href="/manual/?/function/arraynew">ArrayNew()</a> function,
			passing in an optional dimension element.</p>

<pre class="cfml">&lt;cfset myArray = ArrayNew()>
&lt;cfset myTwoDimensionalArray = ArrayNew(2)></pre>
			
			<p>Once created, you can address elements using the [] notation, with it creating extra space in the array accordingly.
			For example the following will add two elements to the array, blanking out the elements in between that have not been addressed.</p>
			
<pre class="cfml">&lt;cfset myArray = ArrayNew()>
&lt;cfset myArray[1] = "Alan">
&lt;cfset myArray[5] = "Ceri">
</pre>

<p>Alternatively you can create arrays and initialize them at the same time using implicit creation.</p>

<pre class="cfml">&lt;!--- create an empty array ---&gt;
&lt;cfset myarray = []&gt;


&lt;!--- create an array with 3 numeric elements ---&gt;
&lt;cfset myarray = [1,2,3]&gt;


&lt;!--- create an array with mixed element types ---&gt;
&lt;cfset myarray = [true,'andy',3]&gt;


&lt;!--- create an array with mixed element types; carriage returns are ignored ---&gt;
&lt;cfset myarray = [
  true,
  'andy',
  3]&gt;


&lt;!--- create an array of arrays ---&gt;
&lt;cfset myArray = [ [1,2], [3] ]&gt;
</pre>
			
			<a name="struct"></a>
			<h2>Creating Structures</h2>

			<p>A structure (sometimes referred to as a map or a collection) is a collection of data, arranged in key/data pairs.  A structure can only have unique keys and data is
			accessed by specifying the key.   The majority of CFML scopes are structures (form, server, request etc) and can be accessed using the key notation.</p>
			
			<p>Creating a structure can be done using the classic approach of calling the <a href="/manual/?/function/structnew">StructNew()</a> function.  Once
			created you can use the [] or the . (dot) notation to get and set data.</p>
			
<pre class="cfml">&lt;cfset myStruct = StructNew()>
&lt;cfset myStruct["name"] = "Alan">
&lt;cfset myStruct.location = "Scotland">
&lt;cfset myStruct.created = now()>
</pre>
			
			<p>Alternatively, you can create and set data in a structure using implicit creation.  Note OpenBD supports the Javascript method of creating
			structures, using the : (colon) delimiter.</p>
			
<pre class="cfml">
&lt;!--- create an empty struct ---&gt;
&lt;cfset myStruct = {}&gt;


&lt;!--- create a struct with fields, using CFML syntax ---&gt;
&lt;cfset myStruct = {
  name = "Andy",
  country = "Scotland" }&gt;


&lt;!--- create a struct with fields, using Javascript syntax ---&gt;
&lt;cfset myStruct = {
  name : "Andy",
  country : "Scotland" }&gt;


&lt;!--- create structs within a struct ---&gt;
&lt;cfset myStruct={ a.c = 1, a.b.c = 3 }&gt;


&lt;!--- Mixed example ---&gt;
&lt;cfscript&gt;
people = [ { name = 'Andy', country = 'Scotland' },
           { name = 'Matt', country = 'USA' },
           { name = 'Alan', country = 'Scotland' },
           { name = 'John', country = 'Australia' } ];

scottishCount = 0;
for ( i = 1; i &lt; arraylen(people); i++ ){
  if ( people[i].country == 'Scotland' ){
    scottishCount++;
  }
}
&lt;/cfscript&gt;
</pre>
			
			<a name="object"></a>
			<h2>Creating Objects</h2>
			
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
			
			<p>Some advanced examples:</p>
			
<pre class="cfml">&lt;!--- simple cfc path ---&gt;
&lt;cfset obj = new test()&gt;

&lt;!--- full cfc path ---&gt;
&lt;cfset obj = new full.path.to.test()&gt;

&lt;!--- cfc path as string ---&gt;
&lt;cfset obj = new "test"()&gt;

&lt;!--- full cfc path as string ---&gt;

&lt;cfset obj = new "full.path.to.test"()&gt;

&lt;!--- with arguments ---&gt;
&lt;cfset t = new test( "foo", "bar" )&gt;

&lt;!--- with named arguments ---&gt;
&lt;cfset t = new test( bar: "bar", foo: "foo")&gt;

&lt;!--- with args passed in as argumentcollection ---&gt;
&lt;cfset args = { bar = 2, foo = 1 }&gt;

&lt;cfset t = new test( argumentcollection: args )&gt;
</pre>

		</div><!--- .section --->

	</div><!--- .container --->
</div><!--- .content --->