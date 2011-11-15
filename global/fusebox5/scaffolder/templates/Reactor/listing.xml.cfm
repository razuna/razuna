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
<<!--- Generate an array of parent objects --->>
<<cfset aManyToOne = oMetaData.getRelationshipsFromXML(objectName,"manyToOne")>>

<<cfoutput>>	
	<fuseaction name="$$objectName$$_Listing" access="public">
		<!-- Listing: I display a list of the records in the $$objectName$$ table. -->
		<set name="request.page.subtitle" value="$$oMetaData.getSelectedTableLabel()$$ List" />
		<set name="request.page.description" value="I display a list of the $$objectName$$ records in the table." />

		<xfa name="Update" value="$$objectName$$_Edit_Form" />
		<xfa name="Delete" value="$$objectName$$_Action_Delete" />
		<xfa name="Display" value="$$objectName$$_Display" />
		<xfa name="Add" value="$$objectName$$_Add_Form" />
		<xfa name="Prev" value="$$objectName$$_Listing" />
		<xfa name="Next" value="$$objectName$$_Listing" />
		<xfa name="Page" value="$$objectName$$_Listing" />
		<xfa name="Sort" value="$$objectName$$_Listing" />
		
		<set name="attributes._maxrows" value="10" overwrite="false" />
		<set name="attributes._startrow" value="1" overwrite="false" />
		<<cfloop list="$$lPKFields$$" index="thisPKField">>
		<set name="attributes._listSortByFieldList" value="$$objectName$$|$$thisPKField$$|ASC" overwrite="false" /><</cfloop>>
		
		<invoke object="Application.ao__AppObj_m$$oMetaData.getProject()$$_$$objectName$$_Gateway" method="getRecordCount" returnvariable="attributes.totalRowCount" />
		<if condition="attributes._StartRow GT attributes.totalRowCount">
			<true>
				<set name="attributes._startrow" value="#val((attributes._maxrows * ((attributes.totalRowCount - 1) \ attributes._maxrows)) + 1)#"/> 
			</true>
		</if>
		
		<invoke object="Application.ao__AppObj_m$$oMetaData.getProject()$$_$$objectName$$_Gateway" method="getNWithJoin" returnvariable="q$$objectName$$">
			<argument name="sortByFieldList" value="#attributes._listSortByFieldList#" />
			<argument name="startrow" value="#attributes._startRow#" />
			<argument name="maxrows" value="#attributes._maxrows#" />
		</invoke>
		<set name="fieldlist" value="$$lAllFields$$"/>
		<include circuit="udfs" template="udf_appendParam" />
		<include circuit="v$$oMetaData.getProject()$$" template="dsp_list_$$objectName$$" contentvariable="request.page.pageContent" append="true" />
	</fuseaction>
	
<</cfoutput>>
