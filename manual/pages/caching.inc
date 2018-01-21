<cfset request.page.title = "Caching">
<cfset request.page.section = "adv">
<cfset request.page.desc	= "Using and managing caches within OpenBD">

<div class="subnav">
	<div class="container">
		<ul class="breadcrumb">
			<li><a href="./?/advanced">Advanced</a></li>
			<li class="active"><a href="./?/caching"><cfoutput>#request.page.title#</cfoutput></a></li>
		</ul>
	</div>
</div>


<div class="content" id="content">
	<div class="container cf">

		<h1>Caching</h1>

		<cfinclude template="pages/sidebar_advanced.inc" />

		<div class="section">

<h2>Cache Functions</h2>

<p>
	Caching allows you to save the results of a potentially long running operation (such as a query or remote webservice)
	and utilise that the next time.  You place an item into the cache (or store) using a unique key, which using that key,
	you pull the content back out again.  You can specify how long an item in the cache should remain active/valid for by
	using a timeout attribute.   If you reach into a cache for a given key and it is not there, then you must re-create that
	object and place it back into the cache for the next time.
</p>

<p>
	Caching can make a huge performance difference to your application by reducing the overhead associated with producing
	repeated blocks of functionality.  Using a cache inside of OpenBD is extremely easy, allowing you a wide variety of ways
	to not only access the cache, but how you manage and store this cache using both memory, disk, Memcached, MongoDB and CouchBase.
</p>

<p>
	Consider the following example that illustrates the most basic use of the cache.  You make call <a href="./?/function/cacheget">CacheGet</a>
	to see if the item, identified by 'somekey' is in the cache.  This will return a CFML null if it is not, which you test for using <a href="./?/function/isnull">IsNull()</a>.
	If it is not found, then we need to create it again.  This example is very simple, but at this point you would run a query, or something
	that is worthy of caching.  Then you call <a href="./?/function/cacheput">CachePut</a> to put the item in the cache for the next time.
	Note however we are timing it to be only valid in the cache for 10 seconds.  As soon as the item in the cache is older than 10seconds, null
	will be returned and the item will have to be recreated and put back into the cache.
</p>

<cfsavecontent variable="cfml"><nocfml>
<cfset myitem = CacheGet("somekey")>

<cfif isNull(myitem)>
  <cfset myitem = now()>
  <cfset CachePut("somekey", myitem, CreateTimeSpan(0,0,0,10))>
</cfif>

<cfoutput>#myitem#</cfoutput>
</nocfml></cfsavecontent>
<pre class="cfml"><cfoutput>#XmlFormat( Trim(cfml) )#</cfoutput></pre>

<p>
OpenBD has a number of different functions available for managing and interacting with caches.  A cache storage engine is referred to as
a 'region'.  A region can be anything from in-memory, disk or even a remote caching server such as the popular Memcached, MongoDB or CouchBase.
Configuring a region is done using the CacheRegionXXX() functions.  The properties of each of these regions can be seen below in the 'Cache Engine' section.
</p>

<table class="zebra-striped" style="margin-top: 20px">
<thead>
	<tr>
		<th>Function Name</th>
		<th>Description</th>
	</tr>
</thead>
<tbody>
	<tr>
		<td width="1%" nowrap align="right"><a href="./?/function/cacheget">CacheGet</a></td>
		<td>Returns the data addressed by the id; returns a null if the object does not exist (use <a href="./?/function/isnull">IsNull()</a> to test)</td>
	</tr>
	<tr>
		<td width="1%" nowrap align="right"><a href="./?/function/cachegetmetadata">CacheGetMetaData</a></td>
		<td>Returns the meta-data runtime data for this cache type</td>
	</tr>
	<tr>
		<td width="1%" nowrap align="right"><a href="./?/function/cachegetproperties">CacheGetProperties</a></td>
		<td>Returns the properties for this cache type</td>
	</tr>
	<tr>
		<td width="1%" nowrap align="right"><a href="./?/function/cacheidexists">CacheIdExists</a></td>
		<td>Determines if the object is in the cache</td>
	</tr>
	<tr>
		<td width="1%" nowrap align="right"><a href="./?/function/cacheput">CachePut</a></td>
		<td>Places the object into the cache</td>
	</tr>
	<tr>
		<td width="1%" nowrap align="right"><a href="./?/function/cacheremove">CacheRemove</a></td>
		<td>Removes one or more keys</td>
	</tr>
	<tr>
		<td width="1%" nowrap align="right"><a href="./?/function/cacheremoveall">CacheRemoveAll</a></td>
		<td>Removes all the data in the cache</td>
	</tr>
	<tr>
		<td width="1%" nowrap align="right"><a href="./?/function/cacheregionexists">CacheRegionExists</a></td>
		<td>Determines if the region exists</td>
	</tr>
	<tr>
		<td width="1%" nowrap align="right"><a href="./?/function/cacheregiongetall">CacheRegionGetAll</a></td>
		<td>Returns all the active regions (including internal ones)</td>
	</tr>
	<tr>
		<td width="1%" nowrap align="right"><a href="./?/function/cacheregionnew">CacheRegionNew</a></td>
		<td>Create a new region for caching</td>
	</tr>
	<tr>
		<td width="1%" nowrap align="right"><a href="./?/function/cacheregionremove">CacheRegionRemove</a></td>
		<td>Removes the region.  This merely deletes the cache reference.  No data held in the cache will be purged</td>
	</tr>
	<tr>
		<td width="1%" nowrap align="right"><a href="./?/function/cachesetproperties">CacheSetProperties</a></td>
		<td>Changes the properties of the cache engine if the underlying implementation supports it</td>
	</tr>
</tbody>
</table>

<h2>Function/Tags Cache Enabled</h2>

<p>
	Caching is integrated into a number of other areas of the OpenBD engine.  Tags <a href="./?/tag/CFQUERY">CFQUERY</a>,
	<a href="./?/tag/CFCACHECONTENT">CFQUERY</a>, <a href="./?/function/queryrun">QueryRun()</a> and <a href="./?/function/salesforcequery">SalesForceQuery()</a> have been
	enabled to use the region caching engine.
</p>

<p>
	This lets you control the precise sort of cache these tags will use by simply passing in the 'region' attribute/parameter
	to them.
</p>


<h3>CFFUNCTION caching</h3>

<p>
	You can also easily attach caching to functions by using the REGION/CACHEDWITHIN attributes of <a href="./?/tag/CFFUNCTION">CFFUNCTION</a>.
	This lets you wrap up expensive calls and make them cachable very easy.
</p>

<p>
	The cache key is automatically generated for you, using the function and a hash of all the parameters passed in.  However only simple
	parameters are considered for the key calculation (objects for example are not).   There is a region 'function' that is setup for the
	use of function calls.
</p>

<p>
	See an example of this in action <a href="./?/tag/CFFUNCTION">CFFUNCTION</a>.
</p>

<h2>Cache Engines</h2>

<p>
	The following cache engines are available to you within OpenBD: memorydisk, memcached, mongo, redis and null.
	This section highlights how you can configure each of these types.  These sample blocks are what you pass into
	<a href="./?/function/cacheregionnew">CacheRegionNew</a> function.  Normally you would create these at the start
	of your application (such as <a href="./?/app_server_cfc">/Server.cfc</a>).
</p>

<h3>type : 'memorydisk'</h3>

<p>
	This cache pages to the local server memory using the disk as an overflow.  You control
	how many items are in memory before they are aged out to disk.  This cached is not shared
	among servers.  This is the default setup for many of the OpenBD sub-systems (CFQUERY, SALESFORCE, CFCACHECONTENT)
</p>

<pre>{
  type : 'memorydisk',
  size : 52,
  diskpersistent : true,
  diskspooldir : '/tmp',
  diskcleanonstart : true,
  diskmaxsizemb : 25
}</pre>

<p>
	<strong>size</strong> is the number of items stored in memory, defaults to 100.
	<strong>diskpersistent</strong> controls whether or not items will be stored on disk. Defaults to false.
	<strong>diskspooldir</strong> is the directory where the disk items will be stored. Defaults to the OpenBD temporary directory.
	<strong>diskcleanonstart</strong> is a flag that will delete any files that currently exist in that folder.  Defaults to false.
	<strong>diskmaxsizemb</strong> is the total size the disk cache will occupy.  Defaults to 25MB.  Items will be removed to make space for newer items.
</p>

<h3>type : 'memcached'</h3>

<p>
 This cache uses a remote memcached (or CouchBase) server as its storage mechanism.  The size of this cache is
 controlled by the server, with items being auto-aged to make room for new items.
</p>

<pre>{
  type : 'memcached',
  server : '10.0.0.1:11211 10.0.0.2:11211',
  waittimeseconds : 5
}</pre>

<p>
	<strong>server</strong> is the list of one or more memcached servers that the cache will connect to.
	<strong>waittimeseconds</strong> is the time that OpenBD will wait for before cancelling the operation to the server.
	If all the servers go away, then the system will operate as normal, except the cache will simply return nothing.
</p>

<p>
	Note that the memcached type of cache does not support the partial removal of keys.  You must know the full cache
	key to be able to delete it.
</p>

<h3>type : 'mongo'</h3>

<p>
	Using a MongoDB as a caching server is an effective use of this powerful remote document store.  OpenBD utilises
	the MongoDB architecture as efficiently as possible, ensuring the minimum overhead is placed in the cache
	management.
</p>

<pre>{
  type : 'mongo',
  server : '10.0.0.1:27017 10.0.0.2:27017',
  db : 'openbd',
  collection : 'nameofregion',
  user : 'username',
  password : 'password'
}</pre>

<p>
	<strong>server</strong> is the list of MongoDB servers that will be used.  This is designed to utilise replica shards.
	<strong>db</strong> is the name of the database, which defaults to 'openbd'.
	<strong>collection</strong> is the name of the collection to use, which defaults to the name of the cachce region when created.
	<strong>user</strong> if the remote MongoDB is protected by a username/password, this is the username.
	<strong>password</strong> password if protected
</p>

<p>
	Depending on the data being cached, it will be stored as either a raw UTF string (best performance) or as a byte array representing
	the serialized object.  This cache engine supports partial delete keys (for example delete everything that starts with 'xyz').
</p>

<h3>type : 'redis'</h3>

<p>
This cache uses a Redis cache server that uses an in-memory data structure as its storage mechanism.
The size of this cache is controlled by the server, with items being auto-aged to make room for new items.
</p>

<pre>{
  type : 'redis',
  server : 'redis://127.0.0.1:6379',
  waittimeseconds : 5
}</pre>

<p>
	<strong>server</strong> (required) is the URI for the redis master the cache will connect to.
	<strong>waittimeseconds</strong> (optional) is the time that OpenBD will wait for before cancelling the operation to the server.
	If all the servers go away, then the system will operate as normal, except the cache will simply return nothing.
</p>

<p>
	Note that current redis implementation was built on top of AWS ElasticCache with a configuration comprising one shard with two nodes, master and slave, and cluster mode disabled.
	It should scale for additional nodes.
	However, it provides no guarantees for configurations with additional shards or cluster mode enabled.
</p>

<h3>type : 'null'</h3>

<p>
	This is a special caching type that performs absolutely no caching.  This is very handy to do,
	allowing you to use a 'region' like you would a datasource, defining at the start of the application
	how will control caching.   So you could write all your queries with the region set to 'mycache' and
	then define 'mycache' to use the null engine to begin with, letting you layer in different types of engines without
	having to revisit your code base.
</p>

<pre>{
  type : 'null'
}</pre>

<h3>More Information</h3>

<p>
	You can find more information about how to configure a remote caching server that OpenBD supports here:
</p>

<ul>
	<li><a href="http://memcached.org/">Memcached</a></li>
	<li><a href="http://mongodb.org/">MongoDB</a></li>
	<li><a href="http://couchbase.com/">CouchBase</a></li>
	<li><a href="http://aws.amazon.com/elasticache/">Amazon ElastiCache</a></li>
</ul>

		</div><!--- .section --->

	</div><!--- .container --->
</div><!--- .content --->
