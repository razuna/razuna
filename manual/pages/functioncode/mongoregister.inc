<p>The format of the MongoURI is:</p>
<pre>mongodb://[username:password@]host1[:port1][,host2[:port2],...[,hostN[:portN]]][/database[?options]]</pre>
<ul>
	<li>The database is required</li>
  <li><code>mongodb://</code> is a required prefix to identify that this is a string in the standard connection format.</li>
  <li><code>username:password@</code> are optional. If given, the driver will attempt to login to a database after connecting to a database server.</li>
  <li><code>host1</code> is required part of the URI. It identifies a server address to connect to.</li>
  <li><code>:portX</code> is optional and defaults to :27017 if not provided.</li>
  <li><code>/database</code> is the name of the database to login to and thus is only relevant if the <code>username:password@</code> syntax is used. If not specified the "admin" database will be used by default.</li>
  <li><code>?options</code> are connection options. Note that if <code>database</code> is absent there is still a <code>/</code> required between the last host and the <code>?</code> introducing the options. Options are name=value pairs and the pairs are separated by "&amp;". For backwards
  compatibility, ";" is accepted as a separator in addition to "&amp;", but should be considered as deprecated.</li>
</ul>
<p>The Java driver supports the following options (case insensitive):</p>
<p>Replica set configuration:</p>
<ul>
  <li>
  <code>replicaSet=name</code>: Implies that the hosts given are a seed list, and the driver will attempt to find all members of the set.</li>
</ul>
<p>Connection Configuration:</p>
<ul>
  <li><code>connectTimeoutMS=ms</code>: How long a connection can take to be opened before timing out.</li>
  <li><code>socketTimeoutMS=ms</code>: How long a send or receive on a socket can take before timing out.</li>
</ul>
<p>Connection pool configuration:</p>
<ul>
  <li><code>maxPoolSize=n</code>: The maximum number of connections in the connection pool.</li>
  <li><code>waitQueueMultiple=n</code>: this multiplier, multiplied with the maxPoolSize setting, gives the maximum number of threads
  that may be waiting for a connection to become available from the pool. All further threads will get an exception right away.</li>
  <li><code>waitQueueTimeoutMS=ms</code>: The maximum wait time in milliseconds that a thread may wait for a connection to become available.</li>
</ul>
<p>Write concern configuration:</p>
<ul>
  <li><code>safe=true|false</code>
    <ul>
      <li><code>true</code>: the driver sends a getLastError command after every update to ensure that the update succeeded.</li>
      <li><code>false</code>: the driver does not send a getLastError command after every update.</li>
    </ul>
  </li>
  <li>
    <code>w=wValue</code>
    <ul>
      <li>The driver adds { w : wValue } to the getLastError command. Implies <code>safe=true</code>.</li>
      <li>wValue is typically a number, but can be any string in order to allow for specifications like <code>"majority"</code></li>
    </ul>
  </li>
  <li>
    <code>wtimeoutMS=ms</code>
    <ul>
      <li>The driver adds { wtimeout : ms } to the getlasterror command. Implies <code>safe=true</code>.</li>
      <li>Used in combination with <code>w</code></li>
    </ul>
  </li>
</ul>
<p>Read preference configuration:</p>
<ul>
  <li><code>slaveOk=true|false</code>: Whether a driver connected to a replica set will send reads to slaves/secondaries.</li>
  <li><code>readPreference=enum</code>: The read preference for this connection. If set, it overrides any slaveOk value. 
  <ul>
	<li>Enumerated values: 
    <ul>
      <li><code>primary</code></li>
      <li><code>primaryPreferred</code></li>
      <li><code>secondary</code></li>
      <li><code>secondaryPreferred</code></li>
      <li><code>nearest</code></li>
    </ul></li>
  </ul></li>
  <li>
  <code>readPreferenceTags=string</code>. A representation of a tag set as a comma-separated list of colon-separated key-value pairs, e.g. 
  <code>"dc:ny,rack:1</code>". Spaces are stripped from beginnin and end of all keys and values. To specify a list of tag sets,
  using multiple readPreferenceTags, e.g. <code>readPreferenceTags=dc:ny,rack:1;readPreferenceTags=dc:ny;readPreferenceTags=</code>
  <ul>
    <li>Note the empty value for the last one, which means match any secondary as a last resort.</li>
    <li>Order matters when using multiple readPreferenceTags.</li>
  </ul></li>
</ul>

<p>Reference <a href="http://api.mongodb.org/java/current/com/mongodb/MongoClientURI.html">MongoClientURI documentation</a>.</p>