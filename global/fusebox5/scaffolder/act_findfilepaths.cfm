
<!--- Work out where all the generated code will go. --->
<cfset baseDirectory = getDirectoryFromPath(cgi.PATH_TRANSLATED)>
<cfset baseURL = getDirectoryFromPath(cgi.SCRIPT_NAME)>

<!--- Work out where the URL and File path match by removing matching directories until they don't match --->
<cfset rootDirectory = baseDirectory>
<cfset rootURL = baseURL>

<cfloop from="#ListLen(baseURL,'/')#" to="1" step="-1" index="i">
	<cfset thisDir = ListGetAt(baseURL,i,"/")>
	<cfif listLast(rootDirectory,"\/") IS thisDir>
		<cfset rootDirectory = left(rootDirectory,(len(rootDirectory) - len(thisDir) - 1))>
		<cfset rootURL = left(rootURL,(len(rootURL) - len(thisDir) - 1))>
	</cfif>
</cfloop>

<!--- Work out which directory the scaffolder is located in (this template is in the same place)--->
<cfset thisFilePath = getDirectoryFromPath(getCurrentTemplatePath())>

<cfif Left(thisFilePath,Len(rootDirectory)) IS rootDirectory>
	<cfset thisURLPath = rootURL & replace(removeChars(thisFilePath, 1, Len(rootDirectory)),"\","/","all")>
<cfelse>
	<cfset thisURLPath = rootURL & "Rubbish/">
</cfif>

<cfset thisCFCPath = replace(removeChars(thisURLPath,1,1),"/",".","all")>

