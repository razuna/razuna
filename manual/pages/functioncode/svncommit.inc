<p>
	You can easily commit content to SVN using SVNCommit().
	Actions may be fed through 1 at a time, or in batch.  The keys contained in an action will controll the action
</p>

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