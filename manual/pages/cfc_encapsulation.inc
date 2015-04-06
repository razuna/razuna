<cfset request.page.section = "basic">
<cfset request.page.title = "Encapsulation and Information Hiding">
<cfset request.page.desc	= "Since CFCs are modular software components that are accessed by other components within an application, it is very important to consider the scope within which data are placed when developing CFCs">

<div class="subnav">
  <div class="container">
    <ul class="breadcrumb">
      <li><a href="./?/basic_cfml">Basic CFML</a></li>
      <li class="active"><a href="./?/cfc_encapsulation"><cfoutput>#request.page.title#</cfoutput></a></li>
    </ul>
  </div>
</div>


<div class="content" id="content">
	<div class="container cf">

		<h1>Encapsulation and Information Hiding</h1>

		<cfinclude template="pages/sidebar_basic.inc" />
		
		<div class="section">

<p>
Encapsulation and information hiding are two very important concepts of object-oriented programming. Both of these
are available to CFML developers by using CFCs in an OO fashion. In its simplest sense, encapsulation
refers to bundling together, into a single component, data and the methods that operate on that data.
</p>

<p>
A related but slightly different concept is information hiding, which refers to hiding the inner workings or
implementation details of functionality within the software components. If the inner workings of a particular
method in an object change, the rest of the system should not even be aware that the change has occurred, as
long as the arguments passed to the method and the datatype returned from the method do not change. This stable,
unchanging external interface is critical to the stability and flexibility of an OO application.
</p>

<p>
Let's look at a couple of examples of information hiding to illustrate how this works within the context of a CFC.
First, let's add a getAge() method to the Person CFC. Another component calling this method should not need to know
how the age is calculated; it only needs to know that the Person CFC has a getAge() method that returns the person's age.
The getAge() method might look something like this:
</p>

<pre class="cfml">
&lt;cffunction name="getAge" access="public" output="false" returntype="numeric"
    hint="I return the age of the Person">
  &lt;cfreturn dateDiff("y", getBirthdate(), now()) />
&lt;/cffunction>
</pre>

<p>
By wrapping the functionality to calculate the person's age in a <a href="./?/tag/CFFUNCTION">cffunction</a>, the implementation details
(i.e., business logic) of this function are hidden to the caller. In this simple example, information hiding
probably is not critical, but it is easy to see the power of hiding these details from the components calling
this method. Since the Person CFC owns both its data and its behavior, the means to calculate the age could be
changed at any time and a component calling the getAge() method would be none the wiser.
</p>

<p>
Now let's add a getSalary() method to the Person CFC (see below). This is sensitive data to which individuals should have limited
access. Since the salary variable is in the CFC's variables scope, a component within the application wanting to retrieve this
information needs to go through the getter method to access it. This gives developers the opportunity to add security to the
getSalary() method by requiring the caller to pass in the current user's user type, for example. In a real application, security
responsibilities would likely fall elsewhere in the architecture (i.e., they would not exist directly in a single method in the
Person CFC), but this example works well for illustrative purposes.
</p>

<pre class="cfml">
&lt;cffunction name="getSalary" access="public" output="false" returntype="numeric"
    hint="I return the Person's salary">
  &lt;cfargument name="userType" type="string" required="true" />
   
  &lt;cfif arguments.userType is not "manager">
    &lt;cfthrow type="securityError"
        message="Security Violation"
        detail="You do not have permission to access the salary." />
  &lt;cfelse>
    &lt;cfreturn variables.salary />
  &lt;/cfif>
&lt;/cffunction>
</pre>

<p>
If the type of user that can access salary data were to change, or if the way in which the user type was determined within
the getSalary() method were to change, the rest of the application should not be aware of the change and should not break as
a result of the change. Building all CFCs in this way helps developers create systems that can be more easily maintained
because a change to one piece of the application has little or no impact on any other part of the application.
</p>

<h2>Using the Person CFC</h2>

<p>
Let's assume we have a CFML template and we want to create an instance of the Person CFC, set the first name, last name,
and birthdate values, and then display these values on the screen.
</p>

<p>
First, we instantiate the CFC by using the <a href="./?/function/createobject">CreateObject()</a> function in CFML. There are numerous ways to instantiate CFCs,
but the most frequently used method for instantiating CFCs in OO applications is <a href="./?/function/createobject">CreateObject()</a>. The <a href="./?/function/createobject">CreateObject()</a> function
takes two arguments: first, the object type, which in this case will be component since a CFC is being created; and second,
the type of CFC to be instantiated, which in this case is Person. Note that the .cfc extension is not added to the end of
the CFC type argument to the <a href="./?/function/createobject">CreateObject()</a> function.
</p>

<p>
Remember that an init() method within the CFC was created to act as a constructor. After we call <a href="./?/function/createobject">CreateObject()</a>,
the init() method on the object will be immediately called. Since the init() method returns the object itself, a
fully instantiated Person CFC will be created.
&lt;cfset bob = CreateObject("component", "Person").init() /&g;
</p>

<p>
The variable called bob is of type Person.  But the values of firstName, lastName, and birthdate are the default values. The
correct values for Bob can be set in different ways.
After instantiating the object, the setter methods can simply be called to set the data:
</p>

<pre class="cfml">
&lt;cfset bob.setFirstName("Bob") />
&lt;cfset bob.setLastName("Dylan") />
&lt;cfset bob.setBirthdate("5/24/1941") />
</pre>

<p>
Another way that the data can be set is to pass the values directly to the init() constructor method in the order in which the arguments are declared within the init() method:
</p>

<pre class="cfml">
&lt;cfset bob = CreateObject("component", "Person").init("Bob", "Dylan", "5/24/1941") />
</pre>

<p>With the data set, it can be output on the screen by calling the getter methods of the Person CFC:</p>

<pre class="cfml">
&lt;cfoutput>#bob.getFirstName()# #bob.getLastName()# was born on #bob.getBirthdate()#&lt;/cfoutput>
</pre>

<h2>Other Ways to Pass Data to Methods</h2>

<p>In the two examples above, individual setter methods were called to set the values of the attributes in the
bob instance of the Person CFC. Another method illustrated was to pass all the values to the init() method in the order in
which the arguments are declared within the init() method. In some cases it may be inconvenient or impossible to pass data
to the constructor or other methods in this way. For example, some arguments may be required and other arguments may be optional,
and it may not be possible to use them as ordered arguments.
</p>

<p>
Fortunately, other ways exist for passing data to methods. One method is to pass arguments to the constructor as explicit
name-value pairs. This method is useful for passing certain arguments to the constructor but omitting others, and this
eliminates the reliance upon the order in which the arguments are declared within the init() method.
</p>

<p>
For example, let's create a Person object for Madonna, who has only a first name and a birthdate. In this case,
init("Madonna", "8/16/1958") cannot be called because this would set Madonna's last name to "8/16/1958". This
would not throw an error because the setLastName() method would accept this date string as a string, but the
state of the data within the object would not be correct.
</p>

<p>
By explicitly specifying name-value pairs, a developer can tell the init() method exactly what it is receiving, and the order of the arguments no longer matters:
</p>

<pre class="cfml">
&lt;cfset madonna = CreateObject("component", "Person").init(firstName = "Madonna", birthdate = "8/16/1958")>
</pre>

<p>
Another method for passing data to a function is to use a structure with named keys. When using this method, note that the key names
 of the structure must match the name of the init method's arguments. In the Madonna example, a struct can be built with the
data, and then this struct can be passed to the init() method as a single argument collection:
</p>

<pre class="cfml">
&lt;cfset madonnaData = StructNew() />
&lt;cfset madonnaData.firstName = "Madonna" />
&lt;cfset madonnaData.birthdate = "8/16/1958" />

&lt;cfset madonna = CreateObject("component", "Person").init(argumentcollection = madonnaData) />
</pre>

<p>
These four methods of passing arguments to functions give developers a great deal of flexibility regardless of the order in
which the arguments are declared, and regardless of whether or not the arguments are required.
</p>

<p align="right"><a href="./?/cfc_whyuse">next 'Why use CFC' &raquo;</a></p>
<p><small>&copy; Copyright 2008 GreatBizTools, LLC All rights reserved. <a href="./?/acknowledgement#greatbiztools">Republishing rights</a> have been granted to the Open BlueDragon project by GreatBizTools, LLC.</small></p>

		</div><!--- .section --->

	</div><!--- .container --->
</div><!--- .content --->