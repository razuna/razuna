<<!---
Copyright 2007 Objective Internet Ltd - http://www.objectiveinternet.com

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
<<!--- Set the name of the datasource, This is used to create the names of directories and circuits --->>
<<cfset datasourceName = oMetaData.getDatasource()>>
<<!--- Set the name of the object (table) being updated --->>
<<cfset objectName = oMetaData.getSelectedTableAlias()>>
<<!--- Generate a list of the table fields --->>
<<cfset lFields = oMetaData.getFieldListFromXML(objectName)>>
<<!--- Generate a list of the joined fields --->>
<<cfset lJoinedFields = oMetaData.getJoinedFieldListFromXML(objectName)>>
<<cfset lAllFields = ListAppend(lFields,lJoinedFields)>>
<<!--- Generate a list of the Primary Key fields --->>
<<cfset lPKFields = oMetaData.getPKListFromXML(objectName)>>
<<!--- Get an array of fields --->>
<<cfset aFields = oMetaData.getFieldsFromXML(objectName)>>
<<!--- Get an array of PK fields --->>
<<cfset aPKFields = oMetaData.getPKFieldsFromXML(objectName)>>
<<!--- Get an array of joinedfields --->>
<<cfset aJoinedFields = oMetaData.getJoinedFieldsFromXML(objectName)>>
<<!--- Get a dotted path to the Object --->>
<<cfset dottedPath = oMetaData.getDottedPath(arguments.DestinationFilePath,"",objectName)>>

<<cfoutput>>
package $$dottedPath$$
{
	[RemoteClass(alias="$$dottedPath$$")]

	[Bindable]
	public class $$objectName$$
	{
		<<cfloop from="1" to="$$ArrayLen(aFields)$$" index="i">>
		public var set$$aFields[i].alias$$:$$aFields[i].type$$ = Null;<</cfloop>>
		
		public function $$objectName$$VO()
		{
		}

	}
}
<</cfoutput>>
