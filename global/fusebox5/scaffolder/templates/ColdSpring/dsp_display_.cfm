<<!---
Copyright 2006-07 Objective Internet Ltd - http://www.objectiveinternet.com

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
--->>
<<!--- Set the name of the object (table) being updated --->>
<<cfset objectName = oMetaData.getSelectedTableAlias()>>
<<!--- Generate a list of the table fields --->>
<<cfset lFields = oMetaData.getFieldListFromXML(objectName)>>
<<!--- Generate a list of the joined fields --->>
<<cfset lAllFields = lFields>>
<<cfset lJoinedFields = oMetaData.getJoinedFieldListFromXML(objectName)>>
<<cfloop list="$$lJoinedFields$$" index="thisField">>
	<<cfif ListFindNoCase(lAllFields,thisField) EQ 0>>
		<<cfset lAllFields = ListAppend(lAllFields,thisField)>>
	<</cfif>>
<</cfloop>>
<<!--- Generate a list of the Primary Key fields --->>
<<cfset lPKFields = oMetaData.getPKListFromXML(objectName)>>
<<!--- Get an array of fields --->>
<<cfset aFields = oMetaData.getFieldsFromXML(objectName)>>
<<!--- Get an array of joinedfields --->>
<<cfset aJoinedFields = oMetaData.getJoinedFieldsFromXML(objectName)>>
<<cfoutput>>

<cfsilent>
<!--- -->
<fusedoc fuse="$RCSfile: dsp_display_$$objectName$$.cfm,v $" language="ColdFusion 7.01" version="2.0">
	<responsibilities>
		I display a single $$objectname$$ record from an object, a structure, a query or from attributes scope.
	</responsibilities>
	<properties>
		<history author="$$oMetaData.getAuthor()$$" email="$$oMetaData.getAuthorEmail()$$" date="$$dateFormat(now(),'dd-mmm-yyyy')$$" role="Architect" type="Create" />
		<property name="copyright" value="(c)$$year(now())$$ $$oMetaData.getCopyright()$$" />
		<property name="licence" value="$$oMetaData.getLicence()$$" />
		<property name="version" value="$Revision: $$oMetaData.getVersion()$$ $" />
		<property name="lastupdated" value="$Date: $$DateFormat(now(),'yyyy/mm/dd')$$ $$ TimeFormat(now(),'HH:mm:ss')$$ $" />
		<property name="updatedby" value="$Author: $$oMetaData.getAuthor()$$ $" />
	</properties>
	<io>
		<in>
			<string name="self" scope="request" optional="Yes" />
			<string name="XFA.list" scope="variables" optional="Yes" />
			<string name="XFA.edit" scope="variables" optional="Yes" />
			<string name="XFA.delete" scope="variables" optional="Yes" />
			<string name="XFA.continue" scope="variables" optional="Yes" />
			
			<list name="fieldlist" scope="variables" optional="Yes" comments="Controls the fields displayed and the sequence of the display." />
			
			<object name="o$$objectname$$" comments="The record object to be displayed." optional="Yes" />
			
			<structure name="st$$objectname$$" comments="Not used if o$$objectname$$ is provided." optional="Yes" >
				<<cfloop from="1" to="$$ArrayLen(aFields)$$" index="i">>
				<$$aFields[i].fuseDocType$$ name="$$aFields[i].alias$$" /><</cfloop>>
				<<cfloop from="1" to="$$ArrayLen(aJoinedFields)$$" index="i">>
				<$$aJoinedFields[i].fuseDocType$$ name="$$aJoinedFields[i].alias$$" /><</cfloop>>
			</structure>
			
			<number name="_recordNumber" precision="Integer" scope="variables"/>
			<recordset name="q$$objectname$$" primaryKeys="$$lPKFields$$" scope="variables" optional="Yes" comments="Recordset containing $$objectName$$ records " >
				<<cfloop from="1" to="$$ArrayLen(aFields)$$" index="i">><$$aFields[i].fuseDocType$$ name="$$aFields[i].alias$$" />
				<</cfloop>>
				<<cfloop from="1" to="$$ArrayLen(aJoinedFields)$$" index="i">><$$aJoinedFields[i].fuseDocType$$ name="$$aJoinedFields[i].alias$$" />
				<</cfloop>>
			</recordset>
			<<cfloop from="1" to="$$ArrayLen(aFields)$$" index="i">>
			<$$aFields[i].fuseDocType$$ name="$$aFields[i].alias$$" scope="attributes" optional="Yes" comments="Not used if o$$objectName$$, st$$objectName$$ or q$$objectName$$ is provided." /><</cfloop>>
			<<cfloop from="1" to="$$ArrayLen(aJoinedFields)$$" index="i">><<cfif NOT ListFindNoCase(lFields,aJoinedFields[i].alias)>>
			<$$aJoinedFields[i].type$$ name="$$aJoinedFields[i].alias$$" /><</cfif>><</cfloop>>
				
			<array name="aErrors" scope="variables" optional="Yes" comments="Created by Validation. Present when an error has been found with server validation and passes back from action." >
				<structure>
					<string name="field" />
					<string name="type" />
					<string name="message" />
				</structure>
			</array>
		</in>
		<out>
		</out>
	</io>
</fusedoc>
--->
<!--- Set up the URL parameters so that we can return to the same page in the list. --->
<cfparam name="attributes._StartRow" default="1">
<cfparam name="attributes._Maxrows" default="10">
<cfparam name="attributes._listsortByFieldList" default="">
<cfparam name="request.searchSafe" default="false">

<cfset pageParams = appendParam("","_listsortByFieldList",attributes._listsortByFieldList)>
<cfset pageParams = appendParam(pageParams,"_Maxrows",attributes._Maxrows)>
<cfset pageParams = appendParam(pageParams,"_StartRow",attributes._Startrow)>
<<cfloop list="$$lPKFields$$" index="thisKey">>
<cfset editParams = appendParam(pageParams,"$$thisKey$$",attributes.$$thisKey$$)><</cfloop>>

<!--- Set the complete list of Local Variables which can be used to populate the display. --->
<!--- The sequence can be rearranged to display the fields required in any order. --->
<cfparam name="variables.fieldlist" default="$$lAllFields$$">
<cfset _joinedFieldlist="$$lJoinedFields$$">
<cfif isDefined("o$$objectname$$")>
	<!--- Get variables from the object. --->
	<cfloop list="#fieldlist#" index="thisField">
		<cfset setvariable("variables.#thisField#", evaluate("o$$objectname$$.get" & thisField & "()"))>
	</cfloop>
<cfelseif isDefined("st$$objectname$$")>
	<!--- Copy variables from the structure. --->
	<cfloop list="#fieldlist#" index="thisField">
		<cfset setvariable("variables.#thisField#", st$$objectname$$[thisField])>
	</cfloop>
<cfelseif isDefined("q$$objectname$$")>
	<cfparam name="_recordNumber" default="1">
	<!--- Copy variables from the query. --->
	<cfloop list="#fieldlist#" index="thisField">
		<cfset setvariable("variables.#thisField#", q$$objectname$$[thisField][_recordNumber])>
	</cfloop>
<cfelse>
	<!--- Copy variables from attributes scope. --->
	<cfloop list="#fieldlist#" index="thisField">
		<cfset setvariable("variables.#thisField#", attributes[thisField])>
	</cfloop>
</cfif>
</cfsilent>

<!--- Work out which fields to report as errors if any. --->
<cfset highlightfields = "">
<cfset aErrorMessages = arrayNew(1)>
<cfif isDefined("valid") AND ArrayLen(aErrors) GT 0 >
	<cfloop index="i" from="1" to="#arrayLen(aErrors)#">
		<cfset errorfield = ListGetAt(aErrors[i],2,".")>
		<cfif ListFindNoCase(fieldlist,errorfield)>
			<!--- Set fields to highlight --->
			<cfset highlightfields = ListAppend(highlightfields, errorfield)>
			<!--- Add to error messages --->
			<cfset ArrayAppend(aErrorMessages,aTranslatedErrors[i])>
		</cfif>
	</cfloop>
</cfif>

<!--- Start of the form --->
<cfoutput>
	<table width="590" border="0" cellpadding="2" cellspacing="2" summary="This table shows details of a single $$objectname$$ record." class="">
		<!--- Show any Error Messages --->
		<!--- Errors from the validation. --->
		<cfif isDefined("valid") AND ArrayLen(aErrorMessages) GT 0 >
			<tr>
				<td colspan="2">
				<p class="standard">The following invalid entries were found, please 
				<a href="#self#?fuseaction=#XFA.edit#&Fuseaction_Id=#Fuseaction_Id#">go back and correct them</a> and resubmit.</p>
				<ul>
					<cfloop index="i" from="1" to="#arrayLen(aErrorMessages)#">
						<li class="highlight">#aErrorMessages[i]#</li>
					</cfloop>
				</ul>
				</td>
			</tr>
		</cfif>
		
		<cfloop list="#fieldlist#" index="thisField">
		  <cfswitch expression="#thisField#">
		    <<cfloop from="1" to="$$ArrayLen(aFields)$$" index="i">>
			<cfcase value="$$aFields[i].alias$$">
				<tr>
				  <cfif ListFindNocase(highlightfields,'$$aFields[i].alias$$')>
					<th align="left" class="highlight">
				  <cfelse>
					<th align="left" class="standard">
				  </cfif>
						$$aFields[i].label$$
					</th>
					<td>
						<cftry>#$$Format("variables.$$aFields[i].alias$$","$$aFields[i].format$$")$$#<cfcatch>#variables.$$aFields[i].alias$$#</cfcatch></cftry>
					</td>
				</tr>
			</cfcase><</cfloop>>
			<<cfloop from="1" to="$$ArrayLen(aJoinedFields)$$" index="i">><<cfif NOT ListFindNoCase(lFields,aJoinedFields[i].alias)>>
			<cfcase value="$$aJoinedFields[i].alias$$">
				<tr>
				  <cfif ListFindNocase(highlightfields,'$$aJoinedFields[i].alias$$')>
					<th align="left" class="highlight">
				  <cfelse>
					<th align="left" class="standard">
				  </cfif>
						$$aJoinedFields[i].label$$
					</th>
					<td>
						<cftry>#$$Format("variables.$$aJoinedFields[i].alias$$","$$aJoinedFields[i].format$$")$$#<cfcatch>#variables.$$aJoinedFields[i].alias$$#</cfcatch></cftry>
					</td>
				</tr>
			</cfcase><</cfif>><</cfloop>>
		  </cfswitch>
		</cfloop>
		<cfif isDefined("XFA.list") OR isDefined("XFA.edit") OR isDefined("XFA.delete") OR isDefined("XFA.continue")>
		<tr>
			<td colspan="2">
				&nbsp;
			</th>
		</tr>
		</tr>
			<td align="left" colspan="2">
				<cfif isDefined("XFA.list")>[<a href="#self##appendParam(pageParams,"fuseaction",XFA.list)#">List</a>]</cfif>
				<cfif isDefined("XFA.edit")>[<a href="#self##appendParam(editParams,"fuseaction",XFA.edit)#">Edit</a>]</cfif>
				<cfif isDefined("XFA.delete")>[<a href="#self##appendParam(editParams,"fuseaction",XFA.delete)#">Delete</a>]</cfif>
				<cfif isDefined("XFA.continue")>[<a href="#self##appendParam(editParams,"fuseaction",XFA.continue)#">Continue</a>]</cfif>
			</td>
		</tr>
		</cfif>
	</table>
</cfoutput>
<</cfoutput>>
