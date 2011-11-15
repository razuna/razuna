<!---
Copyright 2006-2007 TeraTech, Inc. http://teratech.com/

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
<cfscript>
	if (fb_.verbInfo.executionMode is "start") {
		// validate attributes
		// url/xfa - string - one of these is required
		if (structKeyExists(fb_.verbInfo.attributes,"url")) {
			if (structKeyExists(fb_.verbInfo.attributes,"xfa")) {
				fb_throw("fusebox.badGrammar.requiredAttributeMissing",
							"Required attribute is missing",
							"Either the attribute 'url' or 'xfa' is required, for a 'relocate' verb in fuseaction #fb_.verbInfo.circuit#.#fb_.verbInfo.fuseaction#.");
			} else {
				fb_.theUrl = fb_.verbInfo.attributes.url;
			}
		} else {
			if (structKeyExists(fb_.verbInfo.attributes,"xfa")) {
				// url = myself + the xfa value
				fb_.theUrl = "##myFusebox.getMyself()####xfa." & fb_.verbInfo.attributes.xfa & "##";
			} else {
				fb_throw("fusebox.badGrammar.requiredAttributeMissing",
							"Required attribute is missing",
							"Either the attribute 'url' or 'xfa' is required, for a 'relocate' verb in fuseaction #fb_.verbInfo.circuit#.#fb_.verbInfo.fuseaction#.");
			}
		}
		// addtoken - boolean - default false
		if (structKeyExists(fb_.verbInfo.attributes,"addtoken")) {
			if (listFind("true,false,yes,no",fb_.verbInfo.attributes.addtoken) eq 0) {
				fb_throw("fusebox.badGrammar.invalidAttributeValue",
							"Attribute has invalid value",
							"The attribute 'addtoken' must either be ""true"" or ""false"", for a 'relocate' verb in fuseaction #fb_.verbInfo.circuit#.#fb_.verbInfo.fuseaction#.");
			}
		} else {
			fb_.verbInfo.attributes.addtoken = false;
		}
		// type - server|client - default client
		if (structKeyExists(fb_.verbInfo.attributes,"type")) {
			// FB51: adds moved and javascript types:
			if (listFind("server,client,moved,javascript",fb_.verbInfo.attributes.type) eq 0) {
				fb_throw("fusebox.badGrammar.invalidAttributeValue",
							"Attribute has invalid value",
							"The attribute 'type' must either be ""server"", ""client"", ""moved"" or ""javascript"", for a 'relocate' verb in fuseaction #fb_.verbInfo.circuit#.#fb_.verbInfo.fuseaction#.");
			}
		} else {
			fb_.verbInfo.attributes.type = "client";
		}
		// strict mode - check attribute count:
		if (fb_.verbInfo.action.getCircuit().getApplication().strictMode) {
			if (structCount(fb_.verbInfo.attributes) neq 3) {
				fb_throw("fusebox.badGrammar.unexpectedAttributes",
							"Unexpected attributes",
							"Unexpected attributes were found in a 'relocate' verb in fuseaction #fb_.verbInfo.circuit#.#fb_.verbInfo.fuseaction#.");
			}
		}
		
		// compile <relocate>
		switch (fb_.verbInfo.attributes.type) {

		case "server":
			fb_appendLine('<cfset getPageContext().forward("#fb_.theUrl#")>');
			break;

		case "client":
			fb_appendLine('<cflocation url="#fb_.theUrl#" addtoken="#fb_.verbInfo.attributes.addtoken#">');
			break;

		case "moved":
			fb_appendLine('<cfheader statuscode="301" statustext="Moved Permanently">');
			fb_appendLine('<cfheader name="Location" value="#fb_.theUrl#">');
			break;

		case "javascript":
			fb_appendLine('<cfoutput><script type="text/javascript">( document.location.replace ) ? ' &
							'document.location.replace("#fb_.theUrl#") : ' &
							'document.location.href = "#fb_.theUrl#";</script></cfoutput>');
			break;

		}
		fb_appendLine('<cfabort>');
	}
</cfscript>
