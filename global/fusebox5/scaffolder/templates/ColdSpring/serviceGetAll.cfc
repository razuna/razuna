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
<<!--- Generate a list of the table fields --->>
<<cfset lFields = oMetaData.getFieldListFromXML(objectName)>>
<<cfoutput>>
	<cffunction name="getAll" access="public" output="false" returntype="query">
		<cfargument name="orderBy" required="No" type="string">
		<cfif ListFindNoCase(lFields,"active")><cfargument name="active" type="boolean" required="false" default="true" /><</cfif>
		<cfreturn variables.$$oMetaData.getSelectedTableAlias()$$Gateway.getAll(argumentCollection=arguments) />
	</cffunction>
<</cfoutput>>	