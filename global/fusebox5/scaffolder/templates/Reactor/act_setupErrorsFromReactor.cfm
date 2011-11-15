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
<!--- -->
<<cfoutput>>
<fusedoc fuse="$RCSfile: act_setupErrorsFromReactor,v $" language="ColdFusion 7.01" version="2.0">
	<responsibilities>
		This template prepares the reactor validation error messages for display by the dsp_form fuse.
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
			<array name="aErrors" scope="variables" optional="Yes" comment="Created by Reactor Validation. Present when an error has been found with server validation and passes back from action."/>
		</in>
		<out>
			<list name="highlightfields" default="" />
		</out>
	</io>
</fusedoc>
--->
<cfparam name="highlightfields" default="" />
<cfif isDefined("variables.aErrors")>
	<cfloop from="1" to="#ArrayLen(variables.aErrors)#" index="i">
		<cfset highlightfields = ListAppend(highlightfields,ListGetAt(aErrors[i],2,".")) >
	</cfloop>
</cfif>
<</cfoutput>>
