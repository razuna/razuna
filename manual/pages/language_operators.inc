<cfset request.page.section = "basic">
<cfset request.page.title = "CFML Data Operators">
<cfset request.page.desc	= "You can use a variety of different operators within CFML">

<div class="subnav">
	<div class="container">
		<ul class="breadcrumb">
			<li><a href="./?/basic_cfml">Basic CFML</a></li>
			<li class="active"><a href="./?/language_operators"><cfoutput>#request.page.title#</cfoutput></a></li>
		</ul>
	</div>
</div>


<div class="content" id="content">
	<div class="container cf">

		<h1>CFML Data Operators</h1>
		
		<cfinclude template="pages/sidebar_basic.inc" />
		
		<div class="section">

<p>You can make use of all the following operators in your OpenBD apps.</p>

<ul>
<li>Assignment
	<ul>
		<li><strong>=</strong></li>
		<li><strong>+=</strong></li>
		<li><strong>-=</strong></li>
		<li><strong>%=</strong></li>
		<li><strong>/=</strong></li>
		<li><strong>*=</strong></li>
		<li><strong>&amp;=</strong></li>
	</ul>
</li>
<li>Unary Arithmetic
	<ul>
		<li><strong>++</strong></li>
		<li><strong>--</strong></li>
		<li><strong>+</strong></li>
		<li><strong>-</strong></li>
		<li><strong>/</strong></li>
		<li><strong>*</strong></li>
	</ul>
</li>
<li>Binary Arithmetic:
	<ul>
		<li><strong>%</strong> or <strong>MOD</strong></li>
	</ul>
</li>
<li>Comparators
	<ul>
		<li><strong>==</strong> or <strong>EQ</strong></li>
		<li><strong>!=</strong> or <strong>NEQ</strong> or <strong>NOT EQUAL</strong></li>
		<li><strong>&lt;</strong> or <strong>LT</strong> or <strong>LESS THAN</strong></li>
		<li><strong>&gt;</strong> or <strong>GT</strong> or <strong>GREATER THAN</strong></li>
		<li><strong>&lt;=</strong> or <strong>LTE</strong> or <strong>LESS THAN OR EQUAL TO</strong></li>
		<li><strong>&gt;=</strong> or <strong>GTE</strong> or <strong>GREATER THAN OR EQUAL TO</strong></li>
		<li><strong>IMP</strong></li>
		<li><strong>EQV</strong></li>
		<li><strong>IS</strong></li>
		<li><strong>IS NOT</strong></li>
		<li><strong>CONTAINS</strong></li>
	</ul>
</li>
<li>Logical
	<ul>
		<li><strong>!</strong> or <strong>NOT</strong></li>
		<li><strong>||</strong> or <strong>OR</strong></li>
		<li><strong>&amp;&amp;</strong> or <strong>AND</strong></li>
		<li><strong>XOR</strong></li>
	</ul>
</li>
</ul>

<p>Some examples of this in usage</p>

<pre class="cfml">
&lt;cfset a = 1>
&lt;cfset a++>

&lt;if ( a &lt; 2 )>
  &lt;cfset a-->
&lt;/if>

&lt;if a LTE 2>
  &lt;cfset a-->
&lt;/if>

&lt;cfscript&gt;
if ( a == "b" && c != "d" ){
  d &= "append";
}
&lt;/cfscript&gt;
</pre>

<p><strong>Note</strong> if you use the comparators inside of a CFIF tag, then please be use to wrap it in (), otherwise you will throw a parsing error.</p>

		</div><!--- .section --->

	</div><!--- .container --->
</div><!--- .content --->