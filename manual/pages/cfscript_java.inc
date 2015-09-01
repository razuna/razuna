<cfset request.page.title = "CFSCRIPT language='java'">
<cfset request.page.section = "adv">
<cfset request.page.desc	= "Extending CFSCRIPT with pure Java">

<div class="subnav">
  <div class="container">
    <ul class="breadcrumb">
      <li><a href="./?/advanced">Advanced</a></li>
      <li class="active"><a href="./?/cfscript_java"><cfoutput>#request.page.title#</cfoutput></a></li>
    </ul>
  </div>
</div>


<div class="content" id="content">
	<div class="container cf">

		<h1 style="text-transform:none">&lt;CFSCRIPT language="java"&gt;</h1>
		
		<cfinclude template="pages/sidebar_advanced.inc" />
		
		<div class="section">
	
<p>
The <a href="./?/tag/CFSCRIPT">CFSCRIPT</a> tag is a powerful addition to the CFML language allowing developers to
express their applications using a Javascript-esq syntax notation.   However, OpenBD has the ability to allow developers
extend <a href="./?/tag/CFSCRIPT">CFSCRIPT</a> to support additional deep language integration.   You can easily write
complete CFC using Java without manually compiling and building JAR files.
</p>

<p>
This extension to the <a href="./?/tag/CFSCRIPT">CFSCRIPT</a> tag offers pure Java support within CFML pages and components.
On-the-fly compilation and hotspot optimzation and easy marshalling of data from CFML -&gt; Java -&gt; CFML, this gives a high
performance window to embed full Java within the CFML framework.
</p>

<p>
Here is an example of how easy it is to use pure Java inside of a CFML page, moving variables in and out.
</p>

<pre class="cfml">
&lt;cfset s = ["A","B","C","D","E","F"]>

&lt;cfscript language="java">
  // Retrieve the CFML object
  cfArray d = cf.getArray("s");

  for ( int x=0; x < d.size(); x++ ){
    cf.print( d.get(x) );
  }

  cf.print( cf.get("CGI.SCRIPT_NAME") );

  // Creating an array in Java, and then setting it for the CFML
  List fromJava	= Arrays.asList(new String[] { "aa", "bb", "cc", "dd" });
  cf.set( "abc", fromJava );

  // Calling out to a cfml function
  String a = (String)cf.call( "listgetat", "a,b,c,d", 3 );
  cf.print( a );

&lt;/cfscript>

&lt;cfdump var="#abc#">
</pre>

<p>There is much more power underneath the bonnet here than this simple example illustrates.  The rest of this page will look
at some of the advanced functionality.</p>

<ul>
	<li><a href="#import">Importing Packages</a></li>
	<li class="padtop"><a href="#javafunctions">Inner Java Functions</a></li>
	<li class="padtop"><a href="#cf">cf - context object</a></li>
	<li class="padtop"><a href="#cfarray">cfArray object</a></li>
	<li class="padtop"><a href="#cfstruct">cfStruct object</a></li>
	<li class="padtop"><a href="#cfquery">cfQuery object</a></li>
	<li class="padtop"><a href="#notes">Hints and Tips</a></li>
</ul>

<a name="import"></a>
<h2 style="text-transform:none">Importing Packages</h2>

<p>
Java requires that you tell it which packages you will be using classes from.  There are a couple of ways we can do this in
Java.  The first way, is to always use the full qualified package name for a given class.  For example <b>java.util.Date</b>.  However
this makes code quickly become bloated and very verbose.
</p>

<p>
An alternative is to declare which packages you wish to by using the Java <b>import</b> statement, that tells it to look up
this package for its classes.
</p>

<p>
We can pass this information to our CFML Java block in two ways.
</p>

<p>
The first way is to simply write the import statements straight inside the <a href="./?/tag/CFSCRIPT">CFSCRIPT</a> body.  For example:
</p>

<pre class="cfml">
&lt;cfscript language="java">
  import java.util.*;

  // Creating an array in Java, and then setting it for the CFML
  List fromJava	= Arrays.asList(new String[] { "aa", "bb", "cc", "dd" });
  cf.set( "abc", fromJava );
&lt;/cfscript>
</pre>

<p>
Alternatively, you can pass in a comma-separated list of imports to use as a tag attribute to <a href="./?/tag/CFSCRIPT">CFSCRIPT</a>.
</p>

<pre class="cfml">
&lt;cfscript language="java" import="java.util.*">
  // Creating an array in Java, and then setting it for the CFML
  List fromJava	= Arrays.asList(new String[] { "aa", "bb", "cc", "dd" });
  cf.set( "abc", fromJava );
&lt;/cfscript>
</pre>

<p>
Either way is acceptable and it doesn't matter if you repeat your imports.  The compiler will soon complain if you are missing
one.
</p>


<a name="javafunctions"></a>
<h2 style="text-transform:none">Inner Java Functions</h2>

<p>
There are basically 2 modes to which you can embed Java code.  As you have seen so far, the first and easiest way, is to simply
write your Java code and when the tag gets executed, your Java code will get executed inline with it.   If you wish to develop
more, you can provide complete sets of Java functions that can be used internal to the Java code.
</p>

<p>
Let us look at an example of this in action.  As you can see below, we are effectively embedding a Java class into the
<a href="./?/tag/CFSCRIPT">CFSCRIPT</a> tag.  So all the usual rules of Java apply here.
</p>

<pre class="cfml">
&lt;cfscript language="java" import="java.util.*">
<span class="hi">public void tagRun()</span> {
  Date d = fromJava();
  cf.print( d );
}

public Date fromJava(){
  return new Date();
}
&lt;/cfscript>
</pre>

<p>
Notice the core inner-method <strong>public void tagRun()</strong>. This is a helper method you can override if you wish you to still
execute code when the <a href="./?/tag/CFSCRIPT">CFSCRIPT</a> is encountered.
</p>


<a name="javafunctions"></a>
<h2 style="text-transform:none">Writing CFC components with Java</h2>

<p>
One of the exciting developments is the ability to write complete or partial CFC components using Java.  Any public method
you declare in Java is available as part of the CFC component to the outside calling world.   Only Java methods declared
'public' are exported to the CFC.
</p>

<pre class="cfml">
&lt;cfcomponent>

&lt;cffunction name="fromCfml">
  &lt;cfreturn now()>
&lt;/cffunction>


&lt;cfscript language="java">
long start = System.currentTimeMillis();

public long getStart(){
  return start;
}

public Date fromJava(){
  return new Date();
}

public String echo(String al){
  return al;
}

// Will not get exported
private void myPrivate(){
}
&lt;/cfscript>

&lt;/cfcomponent>
</pre>

<p>
You can then use this CFC as you would any other CFC.  Assuming we save the above component in the file; compj.cfc,
we could then use it very easily and quickly.
</p>

<pre class="cfml">&lt;cfoutput>
&lt;cfscript>
cfc1 = CreateObject("compj");
cfc2 = new compj();

cfc1.getStart()   = cfc1.getStart();
cfc2.getStart()   = cfc2.getStart();
cfc2.echo("alan") = cfc2.echo("alan");
&lt;/cfscript>
&lt;cfoutput></pre>

<p>
This gives the CFML developer the power to write their CFC components using tags, cfscript or java, or even all 3 at the same time!
</p>

<a name="cf"></a>
<h2 style="text-transform:none">cf - context object</h2>

<p>
To facilitate communications with the underlying CFML platform, the <strong>cf</strong> object is available to the Java
code and makes it easy to bring objects in and out.  You do not need to declare it, it is automatically made available
to your code and is contextually aware to the given request. Available methods from this object include:
</p>

<style>
.hi{
	color: #8dc63f;
}
</style>

<pre class="cfml">
/**
 * Returns the CFML variable as a Java String object
 *
 * @param var - CFML path eg "form.param1"
 * @return
 */
<span class="hi">public String getString( String var );</span>

/**
 * Returns the CFML variable as a Java integer
 *
 * @param var - CFML path eg "form.param1"
 * @return
 */
<span class="hi">public int getInt( String var );</span>

/**
 * Returns the CFML variable as a Java long
 *
 * @param var - CFML path eg "form.param1"
 * @return
 */
<span class="hi">public long getLong( String var );</span>

/**
 * Returns the CFML variable as a Java boolean
 *
 * @param var - CFML path eg "form.param1"
 * @return
 */
<span class="hi">public boolean getBoolean( String var );</span>

/**
 * Returns the CFML variable as a Java Date
 *
 * @param var - CFML path eg "form.param1"
 * @return
 */
<span class="hi">public Date getDate( String var );</span>

/**
 * Returns the CFML variable as a Java Object
 *
 * @param var - CFML path eg "form.param1"
 * @return
 */
<span class="hi">public Object get( String var );</span>

/**
 * Returns the CFML array as a Java cfArray
 *
 * @param var - CFML path eg "form.param1"
 * @return - null if not found or not an array
 */
<span class="hi">public cfArray getArray( String var );</span>

/**
 * Returns the CFML array as a Java cfQuery
 *
 * @param var - CFML path eg "form.param1"
 * @return - null if not found or not an query
 */
<span class="hi">public cfQuery getQuery( String var );</span>

/**
 * Returns the CFML array as a Java cfStruct
 *
 * @param var - CFML path eg "form.param1"
 * @return - null if not found or not an struct
 */
<span class="hi">public cfStruct getStruct( String var );</span>

/**
 * Sets the given Java object to the CFML path.
 * It will automatically convert to Array, Struct accordingly
 *
 * @param var - CFML path eg "form.param1"
 * @param data
 */
<span class="hi">public void set( String var, Object data );</span>

/**
 * Prints the given parameter to the request output
 * @param s
 */
<span class="hi">public void print(String s);</span>
<span class="hi">public void print(int s);</span>
<span class="hi">public void print(StringBuilder s);</span>
<span class="hi">public void print(long s);</span>
<span class="hi">public void print(double s);</span>
<span class="hi">public void print(boolean s);</span>
<span class="hi">public void print(byte s);</span>
<span class="hi">public void print(Object s);</span>

/**
 * Attributes for storing Java objects between calls
 */
<span class="hi">public void setAttribute(String name, Object o);</span>
<span class="hi">public Object getAttribute(String name);</span>
<span class="hi">public void removeAttribute(String name);</span>
<span class="hi">public Iterator<String> getAttributeNames();</span>

/**
 * Executes a CFML function returning back the Java object
 *
 * @param function
 * @param objects
 * @return
 * @throws Exception
 */
<span class="hi">public Object call( String function, Object... objects ) throws Exception ;</span>
</pre>

<a name="cfarray"></a>
<h2 style="text-transform:none">cfArray - object</h2>

<p>
The <strong>cfArray</strong> object makes it easy to work with CFML arrays with minimal overhead.  It implements
the <a href="http://download.oracle.com/javase/6/docs/api/java/util/List.html" target="_blank">java.util.List</a> interface.
</p>

<p>
Any operations performed on a <strong>cfArray</strong> object will adjust the original CFML object.
</p>

<pre class="cfml"><span class="hi">public Object get(int index);
public boolean add(Object value);
public void add(int index, Object value);
public boolean addAll(Collection col);
public boolean addAll(int index, Collection col);

public void clear();
public boolean contains(Object arg0);
public boolean containsAll(Collection arg0);
public int indexOf(Object arg0);
public boolean isEmpty();
public Iterator iterator();

public int lastIndexOf(Object arg0);
public ListIterator listIterator();
public ListIterator listIterator(int arg0);

public boolean remove(Object arg0);
public Object remove(int index);
public boolean removeAll(Collection arg0);
public boolean retainAll(Collection arg0);

public Object set(int index, Object value);
public int size();
public List subList(int arg0, int arg1);

public Object[] toArray();
public Object[] toArray(Object[] arg0);</span>
</pre>

<p>
All index references, are 0 (zero) based, unlike CFML, which is 1 (one) based.
</p>

<a name="cfstruct"></a>
<h2 style="text-transform:none">cfStruct - object</h2>

<p>
The <strong>cfStruct</strong> object makes it easy to work with CFML structures with minimal overhead.  It implements
the <a href="http://download.oracle.com/javase/6/docs/api/java/util/Map.html" target="_blank">java.util.Map</a> interface.
</p>

<p>
Any operations performed on a <strong>cfStruct</strong> object will adjust the original CFML structure.
</p>

<pre class="cfml"><span class="hi">public java.lang.Object get(String name);
public Object get(Object arg0);

public void put(String name, Object value);
public Object put(Object name, Object value);
public void putAll(Map arg0)

public void clear();
public Object remove(Object arg0);

public boolean containsKey(Object key);
public boolean containsValue(Object arg0);
public Collection values();
public Set entrySet();
public Set keySet();

public boolean isEmpty();
public int size();
</span></pre>


<a name="cfquery"></a>
<h2 style="text-transform:none">cfQuery - object</h2>

<p>
The <strong>cfQuery</strong> object makes it easy to work with CFML arrays with minimal overhead.
</p>

<p>
Any operations performed on a <strong>cfQuery</strong> object will adjust the original CFML query object.
</p>

<pre class="cfml"><span class="hi">public String[] getColumns();
public int size();

public int addRow();
public void deleteRow(int index);

public Object get(int iRow, int iCol);
public String getString(int iRow, int iCol);
public int getInt(int iRow, int iCol);
public long getLong(int iRow, int iCol);
public boolean getBoolean(int iRow, int iCol);
public Date getDate(int iRow, int iCol);

public void set(int iRow,int iCol,String data);
public void set(int iRow,int iCol,int data);
public void set(int iRow,int iCol,boolean data);
public void set(int iRow,int iCol,Date date);
</span></pre>

<p>
All index references, are 0 (zero) based, unlike CFML, which is 1 (one) based.
</p>

<a name="notes"></a>
<h2 style="text-transform:none">Hints and Tips</h2>

<ul>
	<li>In order for this extension to operate correctly, the tools.jar must be in the classpath of the Application server</li>
	<li>Java 6 is minimum requirement for this plugin</li>
	<li>Each Java snippet is compiled and operated in memory.  No overhead of disk is incurred</li>
	<li>All index operations are 0 (zero) based</li>
	<li>Dynamic compilation is performed at page load time, and performed once.</li>
	<li>The common Java packages are imported automatically for you (java.io, java.lang, java.util, java.net, java.math)</li>
	<li>Any class you wish to use, specify its full package name</li>
	<li>Use cfArray, cfStruct, cfQuery for manipulating existing CFML data elements as they are extremely fast and provide as late-binding as possible for all inner objects</li>
	<li>The full Java language and syntax is available.  No preprocessing by OpenBD is performed.</li>
	<li>The Attribute store associate with the cf context is a raw storage mechanism for objects with no CFML transformations</li>
	<li>Use the optional JARLIST attribute to specify which jar files the compiler should use.  Jar files must be in the /WEB-INF/lib/ folder</li>
</ul>

<p>
Here is an example of interacting with the popular <a href="http://www.mongodb.org/">MongoDB</a> after dropping the jar file into the <strong>/WEB-INF/lib/</strong> folder.
We add the jar file to the tag, and then we look to see if we have initialised this before, and if not, we create a new one, and put it into the java object store.
</p>

<pre class="cfml">&lt;cfscript language="java" jarlist="mongo-2.0.jar" import="com.mongodb.*">
Mongo mongoConnection = (Mongo)cf.getAttribute("mongo");

if ( mongoConnection == null ){
  try{
    Mongo mongoConnection = new Mongo();
    cf.setAttribute( "mongo", mongoConnection );
  }catch(Exception e){
    cf.print( "Something went wrong: " + e.getMessage() );
  }
}

&lt;/cfscript>
</pre>

</p>

		</div><!--- .section --->

	</div><!--- .container --->
</div><!--- .content --->