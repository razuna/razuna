<cfset request.page.title 	= "Searching with OpenBD CFML">
<cfset request.page.section = "adv">
<cfset request.page.desc	= "OpenBD ships with a powerful embedded search engine that lets you build manage and maintain a number of different collections">

<div class="subnav">
	<div class="container">
		<ul class="breadcrumb">
			<li><a href="./?/advanced">Advanced</a></li>
			<li class="active"><a href="./?/search"><cfoutput>#request.page.title#</cfoutput></a></li>
		</ul>
	</div>
</div>


<div class="content" id="content">
	<div class="container cf">

	<h1>Search with OpenBD CFML</h1>

	<cfinclude template="pages/sidebar_advanced.inc" />
	
	<div class="section">

<p>
OpenBD ships with the powerful and popular <a href="http://lucene.apache.org/">Apache Lucene</a> search engine in its core distribution and is accessible
through a series of specialized tags and functions.   Indexing, or building a collection, is done through either passing in query objects, indexing individual
files, transversing directories of files, or spidering web sites.
</p>

<p>
OpenBD supports a wide range of different file formats, enabling the indexing the content locked within each one.  These include MS Word documents, PDF,
JPG (including all EXIF data), MP3 (ID3 tags), plain and HTML documents.
</p>

<p>
CFML arranges search groups into collections.  A collection can be thought of like a database.  Each collection is completely separate from one another and cannot
be merged together in searches.  A collection contains a series of documents.  Each document represents a single unit of searchable content.  A document can have
many different attributes that you can individually search against.   OpenBD places no restrictions on the number of attributes a document can have.
</p>

<ul>
 <li><a href="#managingcollections">Managing Collections</a></li>
 <li><a href="#adding">Adding/Updating/Deleting documents in a collection</a></li>
 <li><a href="#searching">Searching Collections</a></li>
 <li><a href="#lucene">Apache Lucene Query Syntax Reference</a></li>
</ul>

<a name="managingcollections"></a>
<h2>Managing Collections</h2>

<p>
Collections can be easily manipulated using the inbuilt functions.  The collection is stored in a directory on the server,
defaults to the "cfcollection" directory under the working directory of OpenBD.  A collection has the option of being able to
store a complete, unindexed, copy of the content it is indexing.   This is something that is not recommended as it takes up a lot of unnecessary space.
Instead a collection should be seen like a set of pointers or meta-data to the real data.
</p>

<table width="90%" align="center" cellpadding="5" cellspacing="0">
<thead>
	<tr>
		<th>Function Name</th>
		<th>Description</th>
	</tr>
</thead>
<tbody>
	<tr>
		<td width="1%" nowrap align="right"><a href="./?/function/collectioncreate">CollectionCreate</a></td>
		<td>Creates a brand new collection.  If it already exists then this function will throw an exception</td>
	</tr>
	<tr>
		<td width="1%" nowrap align="right"><a href="./?/function/collectionlist">CollectionList</a></td>
		<td>Lists all the collections registered.  A query is returned detailing information about each collection</td>
	</tr>
	<tr>
		<td width="1%" nowrap align="right"><a href="./?/function/collectiondelete">CollectionDelete</a></td>
		<td>Deletes the collection.  All files will be removed and the collection will no longer be available for use</td>
	</tr>
	<tr>
		<td width="1%" nowrap align="right"><a href="./?/function/collectionlistcategory">CollectionListCategory</a></td>
		<td>Lists all the categories this collection uses and the counts for each one.  A struct with all the counts are returned</td>
	</tr>
	<tr>
		<td width="1%" nowrap align="right"><a href="./?/tag/cfcollection">CFCOLLECTION</a></td>
		<td>The tag version of the above functions</td>
	</tr>
</tbody>
</table>

<p>
Below is some sample code to create a new collection.
</p>

<cfsavecontent variable="cfml"><nocfml>
<cfscript>
CollectionCreate( collection="mycollection", storebody=false );

WriteDump( CollectionList() );
</cfscript>
</nocfml></cfsavecontent>
<pre class="cfml"><cfoutput>#XmlFormat( Trim(cfml) )#</cfoutput></pre>

<a name="adding"></a>
<h2>Adding/Updating/Deleting documents in a collection</h2>

<p>
A document is a single entity in the collection, much like what a row is to a database.  A document contains a number of different attributes and by default must
include at least an KEY, which is a unique identifier for that document.   If you insert a new document whose KEY matches an existing KEY in the collection, then
the original document will be replaced with the new one.
</p>

<table width="90%" align="center" cellpadding="5" cellspacing="0">
<thead>
	<tr>
		<th>Function Name</th>
		<th>Description</th>
	</tr>
</thead>
<tbody>
	<tr>
		<td width="1%" nowrap align="right" valign="top"><a href="./?/function/collectionindexcustom">CollectionIndexCustom</a></td>
		<td>Inserts/Updates a document into the collection.  The key is the unique identifier for each document.  Each field in the document can be searched against.  If a query is presented then the fields represent columns into the query.  If the column does not exist then an exception is thrown. The index can still be searched while an update is happening, however the new documents will not be available in the search until this operation has completed. Note that all fields are treated as strings and will be indexed accordingly.</td>
	</tr>
	<tr>
		<td width="1%" nowrap align="right" valign="top"><a href="./?/function/collectionindexdelete">CollectionIndexDelete</a></td>
		<td>Deletes the given key from the collection.   If a query is specified then the key parameter is the column where the unique identifier is.  The query is then looped over and all the values deleted from the index</td>
	</tr>
	<tr>
		<td width="1%" nowrap align="right" valign="top"><a href="./?/function/collectionindexfile">CollectionIndexFile</a></td>
		<td>Inserts/Updates a file into the collection.  The key is the unique file for each document.  Each field in the document can be searched against.  If a query is presented then the fields represent columns into the query.  If the column does not exist then an exception is thrown. The index can still be searched while an update is happening, however the new documents will not be available in the search until this operation has completed. Note that all fields are treated as strings and will be indexed accordingly.</td>
	</tr>
	<tr>
		<td width="1%" nowrap align="right" valign="top"><a href="./?/function/collectionindexpath">CollectionIndexPath</a></td>
		<td>Inserts/Updates a path into the collection.  The key is the unique path for each directory that all files inside will be handled.  Each field in the document can be searched against.  If a query is presented then the fields represent columns into the query.  If the column does not exist then an exception is thrown. The index can still be searched while an update is happening, however the new documents will not be available in the search until this operation has completed. Note that all fields are treated as strings and will be indexed accordingly.</td>
	</tr>
	<tr>
		<td width="1%" nowrap align="right" valign="top"><a href="./?/function/collectionindexpurge">CollectionIndexPurge</a></td>
		<td>Removes all the documents in this collection.  This does not delete the collection, merely empties the collection ready for further updates</td>
	</tr>
	<tr>
		<td width="1%" nowrap align="right" valign="top"><a href="./?/function/collectionindexweb">CollectionIndexWeb</a></td>
		<td>Inserts/Updates a webpage into the collection.  The URL is the unique key for each document.  Each field in the document can be searched against.  The index can still be searched while an update is happening, however the new documents will not be available in the search until this operation has completed. Note that all fields are treated as strings and will be indexed accordingly.  The webpage will be automatically crawled for links and only internal links will be followed.  A maximum for 100 URLs will be indexed at once.</td>
	</tr>
	<tr>
		<td width="1%" nowrap align="right" valign="top"><a href="./?/tag/cfindex">CFINDEX</a></td>
		<td>The tag version of the above functions</td>
	</tr>
</tbody>
</table>

<p>
Here is a sample piece of CFML showing how easily it is to index content.   OpenBD can recognize and extract
information from WORD, PDF, MP3, JPG, TIFF, Plain and HTML files.
</p>

<cfsavecontent variable="cfml"><nocfml>
<cfscript>
// Indexing a photo folder; subdirectories will be indexed
args = {
  collection : "photocollection",
  recurse : true,
  extensions : ".jpg",
  key : "P:\myphotos\"
};
results = CollectionIndexPath( argumentCollection=args );


// Indexing a website; all internal links will also be indexed
args = {
  collection : "webcollection",
  key : "http://openbd.org/"
};
results = CollectionIndexWeb( argumentCollection=args );


// Indexing a query; each field is a pointer to the column name in the query to pick up the data
args = {
  collection : "customcollection",
  query : myQuery,
  key : "COLUMN_1"
  body : "COLUMN_2,COLUMN3",
  custommap :{
    mycustom : "COLUMN4"
  }
};
results = CollectionIndexCustom( argumentCollection=args );
</cfscript>
</nocfml></cfsavecontent>
<pre class="cfml"><cfoutput>#XmlFormat( Trim(cfml) )#</cfoutput></pre>

<h3>Updating and Searching</h3>

<p>
It is safe to continue searching while a collection is being updated.  However,  new updated results will not become available until the operation
has completed.  For example, if you are adding a query for example, or indexing a whole directory.
</p>


<a name="searching"></a>
<h2>Searching a collection</h2>

<p>
Searching against a collection is a very simple manner.  Each collection will return a query, with each column representing an attribute in the document.
If a document does not have that particular field then the column will be null.   You can check for this with the <a href="./?/function/isnull">isNull()</a> function.
</p>

<table width="90%" align="center" cellpadding="5" cellspacing="0">
<thead>
	<tr>
		<th>Function Name</th>
		<th>Description</th>
	</tr>
</thead>
<tbody>
	<tr>
		<td width="1%" nowrap align="right" valign="top"><a href="./?/function/collectionsearch">CollectionSearch</a></td>
		<td>Performs searches against the registered collection using the Apache Lucene internal engine</td>
	</tr>
	<tr>
		<td width="1%" nowrap align="right" valign="top"><a href="./?/tag/cfsearch">CFSEARCH</a></td>
		<td>The tag version of the above function</td>
	</tr>
</tbody>
</table>

<p>
Searching can be done using either the tag or the function versions.
</p>

<cfsavecontent variable="cfml"><nocfml>
<cfset args = {
  collection: "mycollection",
  criteria : "openbd",

  maxrows : 5,
  startrow : 10
}>

<cfset searchresults = CollectionSearch( argumentCollection=args )>
</nocfml></cfsavecontent>
<pre class="cfml"><cfoutput>#XmlFormat( Trim(cfml) )#</cfoutput></pre>

<p>
The query string can be built up using a variety of complex types.  For example, say you had a custom field indexed as "cartype" then you could perform a search
using the <code>criteria="cartype:bmw"</code> which would look in that given custom field for the indexes.
</p>

<p>
OpenBD has a couple of small tricks to keep the performance and memory usage of searching down.  For example, if you wish to have contextpassages returned then you
must store the body.  However, you generally don't need the full body at that point if you are going to be using the context.  So you can set the flag, <strong>contents=false</strong>,
to the <a href="./?/function/collectionsearch">CollectionSearch</a> function and the main CONTENTS field will not be returned in the query.
</p>

<p>
Another performance feature, is the ability to limit the search results.  If you have a given collection that has a lot of repeated results.  For example, imagine you have
indexed all the comments for a blog and when you search you want simply the blog entry, then you can set the <strong>unqiuecolumn="blogid"</strong> flag on the
<a href="./?/function/collectionsearch">CollectionSearch</a> function to only return one of the same column.   Think of this like a SQL DISTINCT for search.
</p>

<a name="lucene"></a>
<h2>Apache Lucene Query Syntax Reference</h2>

<p>
OpenBD does not pre-process the syntax format and simply passes the criteria section straight down to the Lucene drivers.   To that end, you can build up
complex queries using the Lucene syntax detailed here.
</p>

<p>
The following content has been reproduced from <a href="http://lucene.apache.org/java/2_3_2/queryparsersyntax.html">http://lucene.apache.org/java/2_3_2/queryparsersyntax.html</a>.
</p>

<a name="N10032"></a><a name="Terms"></a>
<h3 class="boxed">Terms</h3>
<p>A query is broken up into terms and operators. There are two types of terms: Single Terms and Phrases.</p>
<p>A Single Term is a single word such as "test" or "hello".</p>
<p>A Phrase is a group of words surrounded by double quotes such as "hello dolly".</p>
<p>Multiple terms can be combined together with Boolean operators to form a more complex query (see below).</p>
<p>Note: The analyzer used to create the index will be used on the terms and phrases in the query string. So it is important to choose an analyzer that will not interfere with the terms used in the query string.</p>



<a name="N10048"></a><a name="Fields"></a>
<h3 class="boxed">Fields</h3>
<p>Lucene supports fielded data. When performing a search you can either specify a field, or use the default field. The field names and default field is implementation specific.</p>
<p>You can search any field by typing the field name followed by a colon ":" and then the term you are looking for. </p>
<p>As an example, let's assume a Lucene index contains two fields, title and text and text is the default field.
        If you want to find the document entitled "The Right Way" which contains the text "don't go this way", you can enter: </p>
<pre class="cfml">title:"The Right Way" AND text:go</pre>
<p>or</p>
<pre class="cfml">title:"Do it right" AND right</pre>
<p>Since text is the default field, the field indicator is not required.</p>
<p>Note: The field is only valid for the term that it directly precedes, so the query</p>
<pre class="cfml">title:Do it right</pre>
<p>Will only find "Do" in the title field. It will find "it" and "right" in the default field (in this case the text field). </p>


<a name="N1006D"></a><a name="Term Modifiers"></a>
<h3 class="boxed">Term Modifiers</h3>
<p>Lucene supports modifying query terms to provide a wide range of searching options.</p>
<a name="N10076"></a><a name="Wildcard Searches"></a>
<h3 class="boxed">Wildcard Searches</h3>
<p>Lucene supports single and multiple character wildcard searches within single terms
        (not within phrase queries).</p>
<p>To perform a single character wildcard search use the "?" symbol.</p>
<p>To perform a multiple character wildcard search use the "*" symbol.</p>
<p>The single character wildcard search looks for terms that match that with the single character replaced. For example, to search for "text" or "test" you can use the search:</p>
<pre class="cfml">te?t</pre>
<p>Multiple character wildcard searches looks for 0 or more characters. For example, to search for test, tests or tester, you can use the search: </p>
<pre class="cfml">test*</pre>
<p>You can also use the wildcard searches in the middle of a term.</p>
<pre class="cfml">te*t</pre>
<p>Note: You cannot use a * or ? symbol as the first character of a search.</p>
<a name="N1009B"></a><a name="Fuzzy Searches"></a>
<h3 class="boxed">Fuzzy Searches</h3>
<p>Lucene supports fuzzy searches based on the Levenshtein Distance, or Edit Distance algorithm. To do a fuzzy search use the tilde, "~", symbol at the end of a Single word Term. For example to search for a term similar in spelling to "roam" use the fuzzy search: </p>
<pre class="cfml">roam~</pre>
<p>This search will find terms like foam and roams.</p>
<p>Starting with Lucene 1.9 an additional (optional) parameter can specify the required similarity. The value is between 0 and 1, with a value closer to 1 only terms with a higher similarity will be matched. For example:</p>
<pre class="cfml">roam~0.8</pre>
<p>The default that is used if the parameter is not given is 0.5.</p>
<a name="N100B4"></a><a name="Proximity Searches"></a>
<h3 class="boxed">Proximity Searches</h3>
<p>Lucene supports finding words are a within a specific distance away. To do a proximity search use the tilde, "~", symbol at the end of a Phrase. For example to search for a "apache" and "jakarta" within 10 words of each other in a document use the search: </p>
<pre class="cfml">"jakarta apache"~10</pre>

<a name="N100C1"></a><a name="Range Searches"></a>
<h3 class="boxed">Range Searches</h3>
<p>Range Queries allow one to match documents whose field(s) values
            are between the lower and upper bound specified by the Range Query.
            Range Queries can be inclusive or exclusive of the upper and lower bounds.
            Sorting is done lexicographically.</p>
<pre class="cfml">mod_date:[20020101 TO 20030101]</pre>
<p>This will find documents whose mod_date fields have values between 20020101 and 20030101, inclusive.
            Note that Range Queries are not reserved for date fields.  You could also use range queries with non-date fields:</p>
<pre class="cfml">title:{Aida TO Carmen}</pre>
<p>This will find all documents whose titles are between Aida and Carmen, but not including Aida and Carmen.</p>
<p>Inclusive range queries are denoted by square brackets.  Exclusive range queries are denoted by
            curly brackets.</p>
<a name="N100DA"></a><a name="Boosting a Term"></a>
<h3 class="boxed">Boosting a Term</h3>
<p>Lucene provides the relevance level of matching documents based on the terms found. To boost a term use the caret, "^", symbol with a boost factor (a number) at the end of the term you are searching. The higher the boost factor, the more relevant the term will be.</p>
<p>Boosting allows you to control the relevance of a document by boosting its term. For example, if you are searching for</p>
<pre class="cfml">jakarta apache</pre>
<p>and you want the term "jakarta" to be more relevant boost it using the ^ symbol along with the boost factor next to the term.
        You would type:</p>
<pre class="cfml">jakarta^4 apache</pre>
<p>This will make documents with the term jakarta appear more relevant. You can also boost Phrase Terms as in the example: </p>
<pre class="cfml">"jakarta apache"^4 "Apache Lucene"</pre>
<p>By default, the boost factor is 1. Although the boost factor must be positive, it can be less than 1 (e.g. 0.2)</p>



<a name="N100FA"></a><a name="Boolean operators"></a>
<h3 class="boxed">Boolean Operators</h3>
<p>Boolean operators allow terms to be combined through logic operators.
        Lucene supports AND, "+", OR, NOT and "-" as Boolean operators(Note: Boolean operators must be ALL CAPS).</p>
<a name="N10103"></a><a name="OR"></a>
<h4 class="boxed">OR</h4>
<p>The OR operator is the default conjunction operator. This means that if there is no Boolean operator between two terms, the OR operator is used.
        The OR operator links two terms and finds a matching document if either of the terms exist in a document. This is equivalent to a union using sets.
        The symbol || can be used in place of the word OR.</p>
<p>To search for documents that contain either "jakarta apache" or just "jakarta" use the query:</p>
<pre class="cfml">"jakarta apache" jakarta</pre>
<p>or</p>
<pre class="cfml">"jakarta apache" OR jakarta</pre>
<a name="N10116"></a><a name="AND"></a>
<h4 class="boxed">AND</h4>
<p>The AND operator matches documents where both terms exist anywhere in the text of a single document.
        This is equivalent to an intersection using sets. The symbol &amp;&amp; can be used in place of the word AND.</p>
<p>To search for documents that contain "jakarta apache" and "Apache Lucene" use the query: </p>
<pre class="cfml">"jakarta apache" AND "Apache Lucene"</pre>
<a name="N10126"></a><a name="+"></a>
<h4 class="boxed">+</h4>
<p>The "+" or required operator requires that the term after the "+" symbol exist somewhere in a the field of a single document.</p>
<p>To search for documents that must contain "jakarta" and may contain "lucene" use the query:</p>
<pre class="cfml">+jakarta lucene</pre>
<a name="N10136"></a><a name="NOT"></a>
<h4 class="boxed">NOT</h4>
<p>The NOT operator excludes documents that contain the term after NOT.
        This is equivalent to a difference using sets. The symbol ! can be used in place of the word NOT.</p>
<p>To search for documents that contain "jakarta apache" but not "Apache Lucene" use the query: </p>
<pre class="cfml">"jakarta apache" NOT "Apache Lucene"</pre>
<p>Note: The NOT operator cannot be used with just one term. For example, the following search will return no results:</p>
<pre class="cfml">NOT "jakarta apache"</pre>
<a name="N1014C"></a><a name="-"></a>
<h4 class="boxed">-</h4>
<p>The "-" or prohibit operator excludes documents that contain the term after the "-" symbol.</p>
<p>To search for documents that contain "jakarta apache" but not "Apache Lucene" use the query: </p>
<pre class="cfml">"jakarta apache" -"Apache Lucene"</pre>


<a name="N1015D"></a><a name="Grouping"></a>
<h3 class="boxed">Grouping</h3>
<p>Lucene supports using parentheses to group clauses to form sub queries. This can be very useful if you want to control the boolean logic for a query.</p>
<p>To search for either "jakarta" or "apache" and "website" use the query:</p>
<pre class="cfml">(jakarta OR apache) AND website</pre>
<p>This eliminates any confusion and makes sure you that website must exist and either term jakarta or apache may exist.</p>


<a name="N10170"></a><a name="Field Grouping"></a>
<h3 class="boxed">Field Grouping</h3>
<p>Lucene supports using parentheses to group multiple clauses to a single field.</p>
<p>To search for a title that contains both the word "return" and the phrase "pink panther" use the query:</p>
<pre class="cfml">title:(+return +"pink panther")</pre>


<a name="N10180"></a><a name="Escaping Special Characters"></a>
<h3 class="boxed">Escaping Special Characters</h3>
<p>Lucene supports escaping special characters that are part of the query syntax. The current list special characters are</p>
<p>+ - &amp;&amp; || ! ( ) { } [ ] ^ " ~ * ? : \</p>
<p>To escape these character use the \ before the character. For example to search for (1+1):2 use the query:</p>
<pre class="cfml">\(1\+1\)\:2</pre>

		</div><!--- .section --->

	</div><!--- .container --->
</div><!--- .content --->