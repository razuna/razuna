<p>
For more information on using MongoDB, visit the <a href="./?/database_mongodb">MongoCFML page</a>
</p>

<p>
For functions that update data, you can pass in the <strong>writeconcern</strong>.  The possible values are:
</p>

<ul>
<li><code>FSYNC_SAFE</code><br>Exceptions are raised for network issues, and server errors; the write operation waits for the server to flush the data to disk</li>
<li><code>JOURNAL_SAFE</code><br>Exceptions are raised for network issues, and server errors; the write operation waits for the server to group commit to the journal file on disk</li>
<li><code>MAJORITY</code><br>Exceptions are raised for network issues, and server errors; waits on a majority of servers for the write operation</li>
<li><code>NONE</code><br>No exceptions are raised, even for network issues</li>
<li><code>NORMAL</code><br>Exceptions are raised for network issues, but not server errors</li>
<li><code>REPLICAS_SAFE</code><br>Exceptions are raised for network issues, and server errors; waits for at least 2 servers for the write operation</li>
<li><code>SAFE</code><br>Exceptions are raised for network issues, and server errors; waits on a server for the write operation</li>
</ul>