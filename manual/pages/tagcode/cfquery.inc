<h3>Query Object</h3>

<p>This tag creates a query object, providing this information in query variables:</p>

<table border="0" cellpadding="0" cellspacing="3">
	<thead>
		<tr>
			<th>Object variables</th>
			<th>Description</th>
		</tr>
	</thead>
	<tbody>
		<tr>
			<td align="left">
				currentRow
			</td>
			<td>
				Current row of query.
			</td>
		</tr>
		<tr>
			<td align="left">
				columnList
			</td>
			<td align="left">
				Comma-separated list of the query columns.
			</td>
		</tr>
		<tr>
			<td align="left">
				recordcount
			</td>
			<td align="left">
				Number of records (rows) returned from the query.
			</td>
		</tr>
	</tbody>
</table>

<h3>Query of Query</h3>

<p>A Query of Query (QoQ) can be done with adding "query" to the dbtype:</p>

<pre class="cfml">
<cfquery name="qcf" dbtype="query">
SELECT *
FROM {previousqueryresult}
</cfquery>
</pre>

<p>Note: There are some limitations to a QoQ as no subselects are allowed.</p>

<h3>Using cachename and cachedomain to improve performance</h3>

<p>You can improve your queries manifold by using the internal cache system or memcache. Here is an example how to cache your queries with the internal cache.</p>

<pre class="cfml">
<cfquery name="qcf" datasource="mysql" cachename="myquery">
SELECT id, columm
FROM mytable
WHERE id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#id#">
</cfquery>
</pre>

<p>Now all queries that will use this table will not hit the database anymore, but will use the cache. You can see that the cache is being used by dumping the query result.</p>

<p>If you want to group your cache you can do so by adding cachedomain to the query above. This is useful for flushing the cache in one go. Say you have different caches for one table with the cachedomain you can flush all the caches for this one table.</p>

<pre class="cfml">
<cfquery name="qcf" datasource="mysql" cachename="myquery" cachedomain="mytable">
SELECT id, columm
FROM mytable
WHERE id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#id#">
</cfquery>
</pre>

<p>In order to flush the cache you simply issue a cfquery tag again as in:</p>

<pre class="cfml">
<cfquery datasource="mysql" action="flushall" cachedomain="mytable" />
</pre>

<p>or for flushing all caches</p>

<pre class="cfml">
<cfquery datasource="mysql" action="flushall" />
</pre>