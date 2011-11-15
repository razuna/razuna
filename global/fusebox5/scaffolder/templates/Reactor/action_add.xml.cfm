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
	<fuseaction name="$$objectName$$_Action_Add" access="public">
		<!-- Action_Add: I add a new $$objectName$$ record using the entered data. -->
		<set name="request.page.subtitle" value="Add $$oMetaData.getSelectedTableLabel()$$" />
		<set name="request.page.description" value="I add a new $$objectName$$ record using the entered data." />

		<xfa name="Continue" value="$$objectName$$_Listing" />
		<xfa name="Save" value="$$objectName$$_Action_Add" />
		<xfa name="Cancel" value="$$objectName$$_Listing" />
		
		<set name="attributes.$$objectName$$_Id" value="0" overwrite="false"/>
		<reactor:record alias="$$objectName$$" returnvariable="o$$objectName$$" />
		<<cfloop list="$$lFields$$" index="thisField">>
		<set value="#o$$objectName$$.set$$thisField$$(attributes.$$thisField$$)#" /><</cfloop>>
		
		<invoke object="o$$objectName$$" method="validate" />
		<set name="valid" value="#NOT o$$objectName$$.hasErrors()#" />
		
		<if condition="valid">
			<true>
				<invoke object="o$$objectName$$" method="save" />
			</true>
		</if>
		<if condition="valid">
			<false>
				<<cfloop from="1" to="$$ArrayLen(aManyToOne)$$" index="i">>
				<set name="variables.sortByFieldList" value="" />
				<invoke object="Application.ao__AppObj_m$$oMetaData.getProject()$$_$$aManyToOne[i].name$$_Gateway" method="getAll" returnvariable="q$$aManyToOne[i].name$$">
					<argument name="sortByFieldList" value="#variables.sortByFieldList#" />
				</invoke><</cfloop>>
				
				<set name="fieldlist" value="$$lFields$$"/>
				<include circuit="udfs" template="udf_appendParam" />
				
				<set name="aErrors" value="#o$$objectName$$._getErrorCollection().getErrors()#" />
				<set name="aErrorMessages" value="#o$$objectName$$._getErrorCollection().getTranslatedErrors()#" />
				<include template="act_setupErrorsFromReactor" />
				
				<set name="mode" value="insert" />
				<include circuit="v$$oMetaData.getProject()$$" template="dsp_form_$$objectName$$" contentvariable="request.page.pageContent" append="true" />
			</false>
		</if>
		<if condition="valid">
			<true>
				<relocate url="#self#?fuseaction=#XFA.Continue#&amp;_listSortByFieldList=#URLEncodedFormat(attributes._listSortByFieldList)#&amp;_startrow=#attributes._startrow#&amp;_maxrows=#attributes._maxrows#" />
			</true>
		</if>
	</fuseaction>
	
<</cfoutput>>
