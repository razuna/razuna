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
<<!--- Generate an array of the table fields --->>
<<cfset aFields = oMetaData.getFieldsFromXML(objectName)>>
<<!--- Generate a list of the table fields --->>
<<cfset lFields = oMetaData.getFieldListFromXML(objectName)>>
<<!--- Generate a list of the Primary Key fields --->>
<<cfset lPKFields = oMetaData.getPKListFromXML(objectName)>>
<<!--- Generate an array of parent objects --->>
<<cfset aManyToOne = oMetaData.getRelationshipsFromXML(objectName,"manyToOne")>>

<<cfoutput>>
	<fuseaction name="$$objectName$$_Action_Update" access="public">
		<!-- Action_Update: I update the selected $$objectName$$ record using the entered data. -->
		<set name="request.page.subtitle" value="Edit $$oMetaData.getSelectedTableLabel()$$" />
		<set name="request.page.description" value="I update the selected $$objectName$$ record using the entered data." />

		<xfa name="Continue" value="$$objectName$$_Listing" />
		<xfa name="Save" value="$$objectName$$_Action_Update" />
		<xfa name="Cancel" value="$$objectName$$_Listing" />
		
		<cs:get bean="$$objectName$$Service" 
					 returnvariable="variables.$$objectName$$Service" 
					 coldspringfactory="serviceFactory"/>
		
		<<cfloop from="1" to="$$ArrayLen(aPKFields)$$" index="i">>
		<set name="attributes.$$aPKFields[i].alias$$" <<cfif aPKFields[i].type IS "string">>value=""<<cfelse>>value="0"<</cfif>> overwrite="false"/><</cfloop>>
		<set name="o$$objectName$$" value="#variables.$$objectName$$Service.get$$objectName$$(attributes.$$lPKFields$$)#" />
		
		<<cfloop from="1" to="$$ArrayLen(aFields)$$" index="i">>
		<<cfif ListFindNoCase("Dropdown,Checkbox",aFields[i].formType)>><set name="attributes.$$aFields[i].name$$" value="false" overwrite="false"/>
		<</cfif>><set value="#o$$objectName$$.set$$aFields[i].name$$(attributes.$$aFields[i].name$$)#" /><</cfloop>>
		
		<set name="aErrors" value="#o$$objectName$$.validate()#" />
		
		<if condition="ArrayLen(aErrors) EQ 0">
			<true>
				<invoke object="$$objectName$$Service" method="save" returnvariable="success">
					<argument name="$$objectName$$" value="#o$$objectName$$#" />
				</invoke>
				<if condition="success">
					<true>
						<relocate url="#self#?fuseaction=#XFA.Continue#&amp;_listSortByFieldList=#URLEncodedFormat(attributes._listSortByFieldList)#&amp;_startrow=#attributes._startrow#&amp;_maxrows=#attributes._maxrows#" />
					</true>
					<false>
						<set name="stError" value="#structNew()#" />
						<set name="stError.message" value="Error in Database Update" />
						<set name="stError.field" value="Unknown" />
						<set value="#ArrayAppend(aErrors,stError)#" />
					</false>
				</if>
			</true>
		</if>
		<if condition="ArrayLen(aErrors) EQ 0">
			<false>
				<<cfloop from="1" to="$$ArrayLen(aManyToOne)$$" index="i">>
				<cs:get bean="$$aManyToOne[i].name$$Service" 
							 returnvariable="variables.$$aManyToOne[i].name$$Service" 
							 coldspringfactory="serviceFactory"/>
				<</cfloop>>
				
				<<cfloop from="1" to="$$ArrayLen(aManyToOne)$$" index="i">>
				<set name="variables.sortByFieldList" value="" />
				<invoke object="$$aManyToOne[i].name$$Service" method="getAll" returnvariable="q$$aManyToOne[i].name$$">
					<argument name="sortByFieldList" value="#variables.sortByFieldList#" />
				</invoke><</cfloop>>
				
				<set name="fieldlist" value="$$lFields$$"/>
				<include circuit="udfs" template="udf_appendParam" />
				
				<set name="mode" value="edit" />
				<include circuit="v$$oMetaData.getProject()$$" template="dsp_form_$$objectName$$" contentvariable="request.page.pageContent" append="true" />
			</false>
		</if>
	</fuseaction>
<</cfoutput>>
