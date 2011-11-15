
<cfset destinationFilePath = "">
<cfset datasource = "DSN">
<cfset aTemplateFiles = ArrayNew(1)>
<cfinclude template="templateDescriptor.cfm">

<cfset recordcount = ArrayLen(aTemplateFiles)>
<cfoutput>
Template Report
<table cellpadding="2">
<tr>
	<td></td>
	<td>File</td>
	<td>Method or Fuseaction</td>
	<td>InPlace</td>
	<td>Overwrite</td>
	<td>Per Object</td>
</tr>
<cfset lastFile = "">
<cfloop from="1" to="#recordcount#" index="i">
<cfset thisFile = "#aTemplateFiles[i].MVCpath##aTemplateFiles[i].outputFile#.#aTemplateFiles[i].suffix#">
<cfif left(aTemplateFiles[i].templateFile,Len(aTemplateFiles[i].outputFile)) IS aTemplateFiles[i].outputFile>
	<cfset thisMethod = "">
<cfelse>
	<cfset thisMethod = aTemplateFiles[i].templateFile>
</cfif>

<tr>
	<td>#left(aTemplateFiles[i].templateFile,Len(aTemplateFiles[i].outputFile))#</td>
	<td><cfif thisFile IS NOT lastFile>#thisFile#</cfif></td>
	<td><!--- #aTemplateFiles[i].templateFile# ---> #thisMethod#</td>
	<td align="center"><cfif aTemplateFiles[i].inPlace>Y<cfelse>N</cfif></td>
	<td align="center"><cfif aTemplateFiles[i].overwrite>Y<cfelse>N</cfif></td>
	<td align="center"><cfif aTemplateFiles[i].perObject>Y<cfelse>N</cfif></td>
</tr>
<cfset LastFile = ThisFile>
</cfloop>
</table>
</cfoutput>