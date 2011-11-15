<!---
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
--->
<!--- 
appendParam function 
	PURPOSE:	I build a URL string by appending parameters to it.
	SYNTAX:		appendParam(string,name,value)
	EG:  		<cfset sortParams = appendParam(sortParams,"Maxrows",attributes.Maxrows)>
 ---> 
<cfscript>
	function appendParam(string,name,value){
		var queryStringStart = "?";
		var queryStringSeparator = "&amp;";
		var queryStringEquals = "=";
		
		// set search safe if required
		if (request.searchSafe){
			queryStringStart = "/";
			queryStringSeparator = "/";
			queryStringEquals = "/";
		}
		
		// check for the first string
		if (trim(string) EQ "")
			string = queryStringStart;
		else{
			if (trim(string) IS NOT "?" AND trim(string) IS NOT "/")
				string = string & queryStringSeparator;
		}
		
		if (trim(name) IS NOT "" AND trim(value) IS NOT "")
			string = string & name & queryStringEquals & urlencodedformat(value);
		
		return string;
	}
</cfscript>