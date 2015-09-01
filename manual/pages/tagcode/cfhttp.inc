<p>
You can use CFHTTP to download large files very efficiently without having to download the file into memory and instead go straight to the
disk.  You can specify this using the PATH/FILE attributes.   When you do this, the 'cfhttp.filecontent' will contain the full path of the
downloaded file.
</p>

<pre class="cfml">
<cfhttp url="http://www.openbd.org/manual/sd_openBD_32.png" file="logo.png" path="#ExpandPath(".")#"></cfhttp>
</pre>