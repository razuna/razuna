<cfsilent>
	<cfset request.page.title = "SVN Repository Plugin">
	<cfset request.page.section = "plugins">
	<cfset request.page.desc	= "SVN Repository plugin makes it really easy and quick interacting with a SVN Repository without the overhead">
</cfsilent>

<div class="subnav">
  <div class="container">
  <ul class="breadcrumb">
    <li><a href="./?/plugin">Plugins</a></li>
    <li class="active"><a href="./?/plugin_svn"><cfoutput>#request.page.title#</cfoutput></a></li>
  </ul>
  </div>
</div>


<div class="content" id="content">
	<div class="container cf">

		<h1>SVN Plugin</h1>

		<cfinclude template="pages/sidebar_plugin.inc" />

		<div class="section">

			<p>The openBD SVN plugin lets you quickly and easily interact with a SVN repository.
			You can download or update files and directories in your repsitory as well as get some useful information.
			This plugin uses the <a href="http://svnkit.com">SVNKit</a> library to leverage functionality with the repository</p>

			<h2>Overview of functions</h2>

			<table class="zebra-striped">
				<thead>
					<tr>
						<th>Function Name</th>
						<th>Description</th>
					</tr>
				</thead>
				<tbody>
					<!--- Repository Connectivity --->
					<tr>
						<td width="1%" nowrap align="right"><a href="./?/function/SVNRegisterRepository">SVNRegisterRepository</a></td>
						<td>Register a repository for use with SVN functions</td>
					</tr>
					<tr>
						<td width="1%" nowrap align="right"><a href="./?/function/SVNRemoveRepository">SVNRemoveRepository</a></td>
						<td>Removes a previously registered datasource</td>
					</tr>
					<tr>
						<td width="1%" nowrap align="right"><a href="./?/function/SVNIsValid">SVNIsValid</a></td>
						<td>Test if a repository is valid</td>
					</tr>

					<!--- Repository Content Retrieval --->
					<tr>
						<td width="1%" nowrap align="right"><a href="./?/function/SVNUpdate">SVNUpdate</a></td>
						<td>Get files and directories from the given repository at a revision</td>
					</tr>
					<tr>
						<td width="1%" nowrap align="right"><a href="./?/function/SVNGetFile">SVNGetFile</a></td>
						<td>Returns the file at the given path and revision in the repository</td>
					</tr>
					<tr>
						<td width="1%" nowrap align="right"><a href="./?/function/SVNGetDir">SVNGetDir</a></td>
						<td>Fetches the files under given path and revision in the repository</td>
					</tr>
					<!--- Repository Content Update --->
					<tr>
						<td width="1%" nowrap align="right"><a href="./?/function/SVNCommit">SVNCommit</a></td>
						<td>Commits the specified actions</td>
					</tr>
					<!--- Repository Information --->
					<tr>
						<td width="1%" nowrap align="right"><a href="./?/function/SVNLatestRevision">SVNLatestRevision</a></td>
						<td>Returns the latest revision number in the repository</td>
					</tr>
					<tr>
						<td width="1%" nowrap align="right"><a href="./?/function/SVNGetRevision">SVNGetRevision</a></td>
						<td>Return revisions associated with a resource</td>
					</tr>
					<tr>
						<td width="1%" nowrap align="right"><a href="./?/function/SVNLogView">SVNLogView</a></td>
						<td>Returns the latest revision number in the repository</td>
					</tr>
					<tr>
						<td width="1%" nowrap align="right"><a href="./?/function/SVNGetStatus">SVNGetStatus</a></td>
						<td>Returns the file at the given path and revision in the repository</td>
					</tr>
					<tr>
						<td width="1%" nowrap align="right"><a href="./?/function/SVNDirectoryList">SVNDirectoryList</a></td>
						<td>For the given repository directory get the file contents</td>
					</tr>
					<tr>
						<td width="1%" nowrap align="right"><a href="./?/function/SVNDiff">SVNDiff</a></td>
						<td>Get the diff of a file between revisions</td>
					</tr>
				</tbody>
			</table>

			<p>To use any of the SVN plugin functions, you'll need the SVN server URL, and SVN credentials.  A handy tip would be to store the credentials somewhere outside of a document repository for security purposes</p>

			<p><span class="label notice">Please note:</span> all the following CFML snippets will assumed to be used inside CFSCRIPT unless otherwise stated.</p>
			<p>Some useful SVN terminology</p>
			<ul>
				<li><strong>HEAD:</strong> The most recent revision, also referenced as -1</li>
				<li><strong>CREATE:</strong> The first revision, also references as 0</li>
				<li><strong>CheckSum:</strong> SVN calculated hash of the file</li>
				<li><strong>Diff</strong> the difference between to revisions of a file</li>
			</ul>

			<h2>SVNRegisterRepository</h2>
			<p><code>SVNRegisterRepository( name, url, user, pass, path, key );</code></p>

			<p>Registering a SVN Repository is very similar to database datasource.  Depending on the authentication model for you repository you may need to use different paramters.  If registering the repository is successful, the name of the repository will be returned, otherwise it will return an empty string</p>

			<p>If using a Key Authentication modal, SVNKit required a file to exist.  To allow for different web application security models, there are different ways to handle this</p>
			<ul>
				<li>
					<strong>Direct Key-File:</strong> If the file is stored somewhere in the filesystem that the application can reach, absolute path can be supplied.
				</li>
				<li>
					<strong>Specific Temporary File:</strong> If a path, and a key are specified, the key will be written to the specified path.
				</li>
				<li>
					<strong>Anonymous Temporary File:</strong> If is empty, and a key are specified, the key will be written to the system temp directory with a random file name.
				</li>
			</ul>

			<p>If a Temporary Key File was used, the key file will be deleted when SVNRemoveRepository() is call for the given repository.</p>

<pre>
svnRepoName = "myRepository";
svnRepoURL = "svn+ssh://my.svnserver.com";
svnRepoUserName = "myUser";
svnRepoPassWord = "myPass";
svnKeyPath = "\svnKey.txt";
svnKey = fileRead(svnKeyPath);
svnKeyTempPath = "\tmp\svnKey.txt";

//Username, Password authentication
repoName = SVNRegisterRepository( svnRepoName, svnRepoURL, svnRepoUserName, svnRepoPassWord );

//Username, Password, Key-file authentication
repoName = SVNRegisterRepository( svnRepoName, svnRepoURL, svnRepoUserName, svnRepoPassWord, svnKeyPath );

//Username, Password, Key authentication, specify temp file
repoName = SVNRegisterRepository(svnRepoName, svnRepoURL, svnRepoUserName, svnRepoPassWord, svnKeyTempPath, svnKey);

//Username, Password, Key authentication, anonymous temp file
repoName = SVNRegisterRepository(svnRepoName, svnRepoURL, svnRepoUserName, svnRepoPassWord, "", svnKey);
</pre>

			<h2>SVNRemoveRepository</h2>
			<p><code>SVNRemoveRepository( name );</code></p>

			<p>This is used to deregister a SVN repository.  If a Temporary Key File was created, when the repository was registered, it will be deleted.</p>

<pre>
svnRepoName = "myRepository";

repoName = SVNRemoveRepository( svnRepoName );
</pre>

			<h2>SVNIsValid</h2>
			<p><code>SVNIsValid( name );</code></p>

			<p>Checks to see if a given Repository has been previously registered using SVNRegisterRepository(), returning a boolean indicator </p>

<pre>
svnRepoName = "myRepository";

repoStatus = SVNIsValid( svnRepoName );
</pre>

			<h2>SVNUpdate</h2>
			<p><code>SVNUpdate( name, svnPath, localPath, revision, recursive, properties );</code></p>

			<p>Download content from the SVN repository.  SVNUpdate can work with files, and directories.
				If properties are not requested back, SVNUpdate will return a boolean to indicate if the target was successfully download.
				If properties are requested back, a struct will be returned with a key for each target item downloaded, and each will have subkeys for their SVN properties.
			</p>

			<p>Properties may include (name may be slightly different, and availability may differ based on SVN configuration)</p>
			<ul>
				<li>revision</li>
				<li>committed-date</li>
				<li>eol-style</li>
				<li>keywords</li>
				<li>checksum (<em>This is needed to commit updates</em>)</li>
				<li>last-author</li>
			</ul>

<pre>
svnRepoName = "myRepository";
svnPath = "...";
localPath = "...";

//download a single specific file from the repository, as it exists at HEAD
//this will also work for downloading a directory (non-recursive)
updateStatus = SVNUpdate( svnRepoName, svnPath, localPath);

//download a single file/directory from the repository, as it exists at a given revision
updateStatus = SVNUpdate( svnRepoName, svnPath, localPath, 100);

//download an entire directory (recursively) from the repository, as it exists at a given revision, this has no effect for a file
updateStatus = SVNUpdate( svnRepoName, svnPath, localPath, -1, true);

//download a file/directory from the repository , and get the properties
updateProperties = SVNUpdate(svnRepoName, svnPath, localPath, -1, false, true);
</pre>

			<h2>SVNGetFile</h2>
			<p><code>SVNGetFile( name, svnPath, localPath, revision, properties );</code></p>

			<p>SVNGetFile() preforms the same functionality as SVNUpdate(), but only for files.  It is recommended to use SVNUpdate, unless the specific control is needed.  An error will be thrown if a directory is passed to it.</p>

			<h2>SVNGetDir</h2>
			<p><code>SVNGetDir( name, svnPath, localPath, revision, recursive, properties );</code></p>

			<p>SVNGetDir() preforms the same functionality as SVNUpdate(), but only for directories.  It is recommended to use SVNUpdate, unless the specific control is needed.  An error will be thrown if a file is passed to it.</p>

			<h2>SVNCommit</h2>
			<p><code>SVNCommit( name, actionElems, message, revision );</code></p>

			<p>This is the function to make any/all update to the SVN repository.  A boolean will be returned to indicate success of the operation.</p>

			<p>Actions may be fed through 1 at a time, or in batch.  The keys contained in an action will controll the action</p>

			<table class="zebra-striped">
				<thead>
					<tr>
						<th>Actions Keys</th>
						<th>Action taken</th>
					</tr>
				</thead>
				<tbody>
					<tr>
						<td>svnPath,localPath</td>
						<td>New file/folder</td>
					</tr>
					<tr>
						<td>svnPath,content,charset</td>
						<td>New file with content</td>
					</tr>
					<tr>
						<td>svnPath,localPath,checksum</td>
						<td>Update file/folder</td>
					</tr>
					<tr>
						<td>svnPath,content,checksum,charset</td>
						<td>Update file with content</td>
					</tr>
					<tr>
						<td>svnPath</td>
						<td>Delete file</td>
					</tr>
					<tr>
						<td>svnPath,property,value,checksum</td>
						<td>Update file/folder property</td>
					</tr>
				</tbody>
			</table>

<pre>
svnRepoName = "myRepository";
myCommitMessage = "Adding, update, deleting setting properties";
actions = [
  //this will add the designated file to SVN at the designated path
  {svnPath:"...",localPath:"..."},

  //this will add a file with the supplied content to SVN at the designated path
  {svnPath:"...",content:"...",charset:"..."},

  //this will update the designated file to SVN at the designated path
  {svnPath:"...",localPath:"...",checksum:"..."},

  //this will update a file with the supplied content to SVN at the designated path
  {svnPath:"...",localPath:"...",checksum:"...",charset:"..."},

  //this will delete a file at the designated SVN path
  {svnPath:"..."},

  //this will set the properties at the designated SVN path
  {svnPath:"...",property:"...",value:"...",checksum:"..."}
}

//commit the specified actions to the repository at HEAD
commitStatus = SVNCommit(svnRepoName, actions, myCommitMessage,-1);
</pre>

			<h2>SVNLatestRevision</h2>
			<p><code>SVNLatestRevision( name );</code></p>

			<p>This will return the current HEAD revision of the repository</p>

<pre>
svnRepoName = "myRepository";
headRevision = SVNLatestRevision(svnRepoName);
</pre>

			<h2>SVNGetRevision</h2>
			<p><code>SVNGetRevision( name, svnPath, revision );</code></p>

			<p></p>

<pre>
svnRepoName = "myRepository";
svnPath = "...";

//This is the most recent revision of the path
headRevisionOfPath = SVNGetRevision(svnRepoName,svnPath,"HEAD");

//This will be the revision before HEAD of the path
prevRevisionOfPath = SVNGetRevision(svnRepoName,svnPath,"PREVIOUS");

//This will be the revision the path was added to the repository
createRevisionOfPath = SVNGetRevision(svnRepoName,svnPath,"CREATE");

//This will get every revision the path was added/modified/deleted in
revisionHistoryOfPath = SVNGetRevision(svnRepoName,svnPath,"HISTORY");

//This will get the revision previous to the supplied revision
priorRevisionOfPath = SVNGetRevision(svnRepoName,svnPath,100);
</pre>

			<h2>SVNLogView</h2>
			<p><code>SVNLogView( name, startRevision, endRevision, filter, fileFilter, startDateFilter, endDateFilter);</code></p>

			<p>This will retrieve the repository logs.  Logs may include the following keys (depending on repository configuration</p>
			<ul>
				<li>author</li>
				<li>date</li>
				<li>logMessage</li>
				<li>revision</li>
				<li>changed (this will contain an array of file/directories that were affected by the revision, and the type of action)</li>
			</ul>

<pre>
svnRepoName = "myRepository";

//Get all logs for a repository.  NOTE: This is not recommended
allLogs = SVNLogView( name );

//Get all logs starting at a given revision (inclusive)
logsSince = SVNLogView( name, 100 );

//Get all logs between (inclusive) the given revision
logsBetween = SVNLogView( name, 100, 200 );

//Get all logs looking for a pattern in the message, wildcards are implied before and after
logsWithMessage = SVNLogView( name, 0, -1, "..." );

//Get all logs for a given svn path
logsForPath = SVNLogView( name, 0, -1, "", "...");

//Get all logs from a given date
logsSinceDate = SVNLogView( name, 0, -1, "", "", "2000/12/30");

//get all logs between a given date range
logsBetweenDate = SVNLogView( name, 0, -1, "", "", "2000/1/1","2000/12/30");
</pre>

			<h2>SVNGetStatus</h2>
			<p><code>SVNGetStatus( name, svnPath, revision );</code></p>

			<p>This will tell what time of item the path is.  Possible values are</p>
			<ul>
				<li>file</li>
				<li>dir</li>
				<li>none</li>
			</ul>


<pre>
svnRepoName = "myRepository";
svnPath = "...";

pathStatus = SVNGetStatus( svnRepoName, svnPath, -1 );
</pre>

			<h2>SVNDirectoryList</h2>
			<p><code>SVNDirectoryList( name, svnPath, recursive, listInfo, filter, sort, revision );</code></p>

			<p>List the directory contents of a given path.  This function take parameters similar to <a href="./?/function/directorylist">directoryList()</a></p>

<pre>
svnRepoName = "myRepository";
svnPath = "...";

//returns an array of paths (non-recursive) at the given directory
pathsArray = SVNDirectoryList( svnRepoName, svnPath );

//returns an array of paths (recursive) at the given directory
pathsRecursiveArray = SVNDirectoryList( svnRepoName, svnPath, false);

//returns an array of paths at the given directory
pathsArray = SVNDirectoryList( svnRepoName, svnPath, false, "path");

//returns an array of names at the given directory
namesArray = SVNDirectoryList( svnRepoName, svnPath, false, "name");

//returns a query of all the content at the given directory,
//will contain columns for name, datelastmodified, directory, size, type, revision ,author
directoryQuery = SVNDirectoryList( svnRepoName, svnPath, false, "query");

//returns an array of paths at the given directory, filtered accordingly
pathsTxtArray = SVNDirectoryList( svnRepoName, svnPath, false, "*.txt");

//return an array of paths at the given directory, ordered accordingly
pathsSortedArray = SVNDirectoryList( svnRepoName, svnPath, false, "","name asc");

//return an array of paths at the given directory, at the given revision
pathsSortedArray = SVNDirectoryList( svnRepoName, svnPath, false, "","",100);
</pre>

			<h2>SVNDiff</h2>
			<p><code>SVNDiff( name, svnPath, listInfo, revisionNewest, revisionOldest, splitRev, splitStartRevision, charset );</code></p>

			<p>Returns the Diff information for a path between certain revisions.</p>

<pre>
svnRepoName = "myRepository";
svnPath = "...";
fileHead = SVNGetRevision( svnRepoName, svnPath, "HEAD" );
filePrev = SVNGetRevision( svnRepoName, svnPath, "PREVIOUS" );

//get the diff status struct
diffStuct = SVNDiff( svnRepoName, svnPath, "status", fileHead, filePrev );

//get the diff string for a file between 2 revisions
diffString = SVNDiff( svnRepoName, svnPath, "string", fileHead, filePrev );

//get the diff string formatted in HTML for a file between 2 revisions
diffHTML = SVNDiff( svnRepoName, svnPath, "html", fileHead, filePrev );

//get the diff struct for a file between 2 revisions
diffHTML = SVNDiff( svnRepoName, svnPath, "data", fileHead, filePrev );
</pre>

<p>The data structure when listInfo is data or overlay will have 2 keys; diff and revisions.
	Revisions is an array containing all the revisions covered in the diff.
	Diff is an array or all the lines covered in the diff</p>
<table class="zebra-striped">
	<thead>
		<tr>
			<th>Code</th>
			<th>Status</th>
			<th>Line Keys</th>
			<th>Revision Keys</th>
			<th>Description</th>
		</tr>
	</thead>
	<tbody>
		<tr>
			<td>P</td>
			<td>Pristine</td>
			<td>status,source,revision</td>
			<td>line,status</td>
			<td>Each revision will have entry</td>
		</tr>
		<tr>
			<td>A</td>
			<td>Add</td>
			<td>status,revision</td>
			<td>line,status,source</td>
			<td>Revisions prior to being added will not have an entry</td>
		</tr>
		<tr>
			<td>D</td>
			<td>Removed</td>
			<td>status,revision</td>
			<td>line,status,source</td>
			<td>Revisions after being removed will not have an entry</td>
		</tr>
		<tr>
			<td>U</td>
			<td>Updated</td>
			<td>status,revision</td>
			<td>line,status,source</td>
			<td>Revision that the change happened on will have status "U"</td>
		</tr>
	</tbody>
</table>

<p>Example overlay</p>

<pre>
{ "diff": [
    { "status": "P",
      "source": "hello world!",
      "revision": {
        "1": {
          "line": 1,
          "status": "P"
        },
        "2": {
          "line": 1,
          "status": "P"
        }
      }
    },
    { "status": "U",
      "revision": {
        "1": {
          "line": 2,
          "status": "P",
          "source": "hola mundo."
        },
        "2": {
          "line": 2,
          "status": "U",
          "source": "hola mundo!"
        }
      }
    },
    { "status": "D",
      "revision": {
        "1": {
          "line": 3,
          "status": "P",
          "source": "hi world..."
        }
      }
    },
    { "status": "A",
      "revision": {
        "2": {
          "line": 3,
          "status": "A",
          "source": "Bonjour le monde!"
        }
      }
    }
  ],
  "revisions": [1,2]
}
</pre>

		</div>
	</div>
</div>