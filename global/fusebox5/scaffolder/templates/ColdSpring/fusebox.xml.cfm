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
<<!--- Get the alias first table --->>
<<cfset firstTable = ListFirst(oMetaData.getLTableAliases())>>
<<cfoutput>>
<?xml version="1.0" encoding="UTF-8"?> 
<fusebox> 

  <circuits>
  	<!-- There is a model, view and controller circuit for each database. -->
	<!-- Only the controller has an XML file the others are called implicitly. -->
	<circuit alias="m$$oMetaData.getProject()$$" path="model/m$$oMetaData.getProject()$$/"  parent="" />
	<circuit alias="v$$oMetaData.getProject()$$" path="view/v$$oMetaData.getProject()$$/" parent="" />
	<circuit alias="vLayout" path="view/vLayout/" parent="" />
	<circuit alias="$$oMetaData.getProject()$$" path="controller/$$oMetaData.getProject()$$/" parent="" />
	<circuit alias="udfs" path="udfs/" parent="" />
  </circuits>
  
  <parameters>
  	<parameter name="debug" value="true" />
    <parameter name="fuseactionVariable" value="fuseaction" />
    <parameter name="mode" value="development-full-load" />
    <parameter name="defaultFuseaction" value="$$oMetaData.getProject()$$.$$firstTable$$_Listing" />
    <parameter name="precedenceFormOrUrl" value="form" />
    <parameter name="password" value="scaffold" />
    <parameter name="scriptFileDelimiter" value="cfm" />
    <parameter name="maskedFileDelimiters" value="htm,cfm,cfml,php,php4,asp,aspx" />
    <parameter name="characterEncoding" value="utf-8" />
	<parameter name="allowImplicitCircuits" value="true" />
  </parameters> 
  
  <classes>
  </classes>
  
  <globalfuseactions>
  	<appinit>
		<do action="m$$oMetaData.getProject()$$.Initialise" />
	</appinit>
    <preprocess>
		<do action="m$$oMetaData.getProject()$$.ReInitialise" />
    </preprocess>
    <postprocess>
    </postprocess>
  </globalfuseactions>
  
  <plugins> 
    <phase name="preProcess">
    </phase>
    <phase name="preFuseaction">
    </phase>
    <phase name="postFuseaction">
    </phase>
    <phase name="postProcess">
    </phase>
    <phase name="processError">
    </phase>
    <phase name="fuseactionException">
    </phase>
  </plugins> 
  
</fusebox>
<</cfoutput>>
