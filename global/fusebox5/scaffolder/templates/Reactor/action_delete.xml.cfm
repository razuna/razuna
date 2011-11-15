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
<<!--- Generate a list of the Primary Key fields --->>
<<cfset lPKFields = oMetaData.getPKListFromXML(objectName)>>
<<!--- Generate an array of parent objects --->>
<<cfset aManyToOne = oMetaData.getRelationshipsFromXML(objectName,"manyToOne")>>

<<cfoutput>>
	<fuseaction name="$$objectName$$_Action_Delete" access="public">
		<!-- Action_Delete: I delete the selected $$objectName$$ record. -->
		<set name="request.page.subtitle" value="Delete $$oMetaData.getSelectedTableLabel()$$" />
		<set name="request.page.description" value="I delete the selected $$objectName$$ record." />

		<xfa name="Continue" value="$$objectName$$_Listing" />
		
		<reactor:record alias="$$objectName$$" returnvariable="o$$objectName$$" />
		<<cfloop list="$$lPKFields$$" index="thisPKField">>
		<set value="#o$$objectName$$.set$$thisPKField$$(attributes.$$thisPKField$$)#" /><</cfloop>>
		<invoke object="o$$objectName$$" method="delete" />
		
		<relocate url="#self#?fuseaction=#XFA.Continue#&amp;_listSortByFieldList=#URLEncodedFormat(attributes._listSortByFieldList)#&amp;_startrow=#attributes._startrow#&amp;_maxrows=#attributes._maxrows#" />
	</fuseaction>
	
<</cfoutput>>
