<p>
	Along with the CF_SQL prefixed CFSQLTYPE's you can also use them without the prefix
</p>

<ul>
	<li>CF_SQL_BIGINT - <strong>BIGINT</strong></li>
	<li>CF_SQL_BIT - <strong>BIT</strong></li>
	<li>CF_SQL_CHAR - <strong>CHAR</strong></li>
	<li>CF_SQL_BLOB - <strong>BLOB</strong></li>
	<li>CF_SQL_CLOB - <strong>CLOB</strong></li>
	<li>CF_SQL_DATE - <strong>DATE</strong></li>
	<li>CF_SQL_DECIMAL - <strong>DECIMAL</strong></li>
	<li>CF_SQL_DOUBLE - <strong>DOUBLE</strong></li>
	<li>CF_SQL_FLOAT - <strong>FLOAT</strong></li>
	<li>CF_SQL_IDSTAMP - <strong>IDSTAMP</strong></li>
	<li>CF_SQL_INTEGER - <strong>INTEGER</strong></li>
	<li>CF_SQL_LONGVARCHAR - <strong>LONGVARCHAR</strong></li>
	<li>CF_SQL_MONEY - <strong>MONEY</strong></li>
	<li>CF_SQL_MONEY4 - <strong>MONEY4</strong></li>
	<li>CF_SQL_NUMERIC - <strong>NUMERIC</strong></li>
	<li>CF_SQL_REAL - <strong>REAL</strong></li>
	<li>CF_SQL_REFCURSOR - <strong>REFCURSOR</strong></li>
	<li>CF_SQL_SMALLINT - <strong>SMALLINT</strong></li>
	<li>CF_SQL_TIME - <strong>TIME</strong></li>
	<li>CF_SQL_TIMESTAMP - <strong>TIMESTAMP</strong></li>
	<li>CF_SQL_TINYINT - <strong>TINYINT</strong></li>
	<li>CF_SQL_VARCHAR - <strong>VARCHAR</strong></li>
	<li>CF_SQL_BINARY - <strong>BINARY</strong></li>
	<li>CF_SQL_VARBINARY - <strong>VARBINARY</strong></li>
	<li>CF_SQL_NCLOB - <strong>NCLOB</strong></li>
	<li>CF_SQL_NCHAR - <strong>NCHAR</strong></li>
	<li>CF_SQL_NVARCHAR - <strong>NVARCHAR</strong></li>
</ul>

<h2>Examples</h2>

<pre class="cfml">
	<cfquery name="qry" datasource="datasource">
		SELECT *
		FROM test
		WHERE age = <cfqueryparam value="27" cfsqltype="cf_sql_integer">
		AND name = <cfqueryparam value="Matthew" cfsqltype="cf_sql_varchar">
	</cfquery>
</pre>

<pre class="cfml">
	<cfquery name="qry" datasource="datasource">
		SELECT *
		FROM test
		WHERE age = <cfqueryparam value="27" cfsqltype="integer">
		AND name = <cfqueryparam value="Matthew" cfsqltype="varchar">
	</cfquery>
</pre>
