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
<cfsilent>
<!--- -->
<fusedoc fuse="dsp_layout.cfm" language="ColdFusion 7.01" version="2.0">
	<responsibilities>
		This page is a fusebox layout page.
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
			<structure name="page" scope="request" >
				<string name="subtitle" />
				<string name="menu" />
				<string name="pageContent" />
			</structure>
		</in>
		<out>
			<string name="fuseaction" scope="formOrUrl" />
		</out>
	</io>
</fusedoc>
--->
</cfsilent>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
	<title><cfoutput>#request.page.subtitle#</cfoutput></title>
<!--- Simple stylesheet supports highlighting of form errors --->
<style>
.pagetitle {
	FONT-SIZE: 16px; COLOR: Black; FONT-FAMILY: Arial, Helvetica, Geneva, Swiss, SunSans-Regular
}
.highlight {
	FONT-SIZE: 12px; COLOR: Red; FONT-FAMILY: Arial, Helvetica, Geneva, Swiss, SunSans-Regular
}
.standard  {
	FONT-SIZE: 12px; COLOR: Black; FONT-FAMILY: Arial, Helvetica, Geneva, Swiss, SunSans-Regular
}
</style>

</head>

<body>
<cfoutput><h1 class="pagetitle">#request.page.subtitle#</h1></cfoutput>
<table>
	<tr>
		<!--- Menu --->
		<td valign="top"><cfoutput>#request.page.menu#</cfoutput></td>
		<!--- Page --->
		<td valign="top"><cfoutput>#request.page.pageContent#</cfoutput></td>
	</tr>
</table>
</body>
</html>
