<p>
Mappings are a way to create logical top-level URI (web) directories that map into a directory or a secure OpenBD archive.
An OpenBD archive is a means of packaging up your CFML and CFC resources into a single file which the webapp serves
directly from there.   These files look like a ZIP file, but are encrpyted inside using an AES algorithm.
</p>

<p>
The following code snippet creates a new OpenBD archive.  You specify the full pathname of the archive you want to create,
and then the directory to which you wish to create the archive from.  All .cfm, .cfc, .htm, .html, .inc files will be included, leaving out any .svn/.git/.csv directories.
</p>

<pre class="cfml">
<cfset MappingCreateArchive( "e:\tmp\myarchive.openbd", "E:\war\mywebapp\rpc\", true )>
</pre>

<p>
Once you have created this OpenBD archive you can move this file anywhere, to any machine.   Next you must register
this new file.   You can do this a number of ways:
</p>

<ul>
	<li>Use <a href="./?/tag/cfmapping">CFMAPPING</a></li>
	<li>Use <a href="./?/function/mappingadd">MappingAdd()</a></li>
	<li>Register it with <a href="./?/engine_bluedragonxml">bluedragon.xml</a></li>
	<li>Register it with <a href="./?/app_application_cfc">Application.cfc</a></li>
</ul>

<p>
Let us look at registering it using the function <a href="./?/function/mappingadd">MappingAdd()</a>.  The following
example will create a logical mapping of "aw2" reaching into the OpenBD archive for the files.   It will also create
this mapping at the "global" level, meaning it will persist after this call for all subsequent requests. 
</p>

<pre class="cfml">
<cfset MappingAdd( logicalpath="aw2", archive="e:\tmp\myarchive.openbd", scope="global" )>
</pre>

<p>
Once this is registered, any request to http://myserver/aw2/ for example http://myserver/aw2/test.cfm it will look for
"test.cfm" inside the archive file myarchive.openbd
</p>

<p>
Mapping Notes:
</p>

<ul>
	<li>Subdirectories are supported inside the OpenBD archive</li>
	<li>Specify the archive in bluedragon.xml/Application.cfc as: <b>openbd://<i>full-path-of-archive</i>@</b></li>
	<li>The mapping is not only for CFINCLUDE/CFMODULE/CreateObject calls, but will also operate directly.  For example
	you could put all your remote AJAX endpoints into an archive</li>
	<li>If you update your archive, then be sure to clear the file cache <a href="./?/function/systemfilecacheflush">SystemFileCacheFlush()</a></li>
	<li>Files in mappings will be searched after it is determined the file does not exist in the phsyical location</li>
	<li>Once the file has been found and cached, no more searching will be made.  Flush the file cache.</li>
</ul>