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
<<!--- Generate an array of parent objects --->>
<<cfset aManyToOne = oMetaData.getRelationshipsFromXML(objectName,"manyToOne")>>

<<cfoutput>>
	<fuseaction name="$$objectName$$_Display" access="public">
		<!-- Display: I display the selected $$objectName$$ record. -->
		<set name="request.page.subtitle" value="View $$oMetaData.getSelectedTableLabel()$$" />
		<set name="request.page.description" value="I display the selected $$objectName$$ record." />

		<xfa name="Edit" value="$$objectName$$_Edit_Form" />
		<xfa name="Delete" value="$$objectName$$_Action_Delete" />
		<xfa name="List" value="$$objectName$$_Listing" />

		<reactor:record alias="$$objectName$$" returnvariable="o$$objectName$$" />
		<<cfloop list="$$lPKFields$$" index="thisPKField">>
		<set value="#o$$objectName$$.set$$thisPKField$$(attributes.$$thisPKField$$)#" /><</cfloop>>
		<invoke object="o$$objectName$$" method="load" />
		
		<set name="fieldlist" value="$$lAllFields$$"/>
		<include circuit="udfs" template="udf_appendParam" />
		<include circuit="v$$oMetaData.getProject()$$" template="dsp_display_$$objectName$$" contentvariable="request.page.pageContent" append="true" />
	</fuseaction>
	
<</cfoutput>>
