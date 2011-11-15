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
		// evaluate - boolean default false
		if (structKeyExists(fb_.verbInfo.attributes,"evaluate")) {
			if (listFind("true,false,yes,no",fb_.verbInfo.attributes.evaluate) eq 0) {
				fb_throw("fusebox.badGrammar.invalidAttributeValue",
							"Attribute has invalid value",
							"The attribute 'evaluate' must either be ""true"" or ""false"", for a 'set' verb in fuseaction #fb_.verbInfo.circuit#.#fb_.verbInfo.fuseaction#.");
			}
		} else {
			fb_.verbInfo.attributes.evaluate = false;
		}
		// name - string - required if overwrite is present
		if (not structKeyExists(fb_.verbInfo.attributes,"name")) {
			if (structKeyExists(fb_.verbInfo.attributes,"overwrite")) {
				fb_throw("fusebox.badGrammar.requiredAttributeMissing",
							"Required attribute is missing",
							"The attribute 'name' is required when 'overwrite' is present, for a 'set' verb in fuseaction #fb_.verbInfo.circuit#.#fb_.verbInfo.fuseaction#.");
			} else {
				fb_.verbInfo.attributes.name = "";
			}
		}
		// overwrite - boolean - default true
		if (structKeyExists(fb_.verbInfo.attributes,"overwrite")) {
			if (listFind("true,false,yes,no",fb_.verbInfo.attributes.overwrite) eq 0) {
				fb_throw("fusebox.badGrammar.invalidAttributeValue",
							"Attribute has invalid value",
							"The attribute 'overwrite' must either be ""true"" or ""false"", for a 'set' verb in fuseaction #fb_.verbInfo.circuit#.#fb_.verbInfo.fuseaction#.");
			}
		} else {
			fb_.verbInfo.attributes.overwrite = true;
		}
		// value - string - required
		if (not structKeyExists(fb_.verbInfo.attributes,"value")) {
			fb_throw("fusebox.badGrammar.requiredAttributeMissing",
						"Required attribute is missing",
						"The attribute 'value' is required, for a 'set' verb in fuseaction #fb_.verbInfo.circuit#.#fb_.verbInfo.fuseaction#.");
		}
		// strict mode - check attribute count:
		if (fb_.verbInfo.action.getCircuit().getApplication().strictMode) {
			if (structCount(fb_.verbInfo.attributes) neq 4) {
				fb_throw("fusebox.badGrammar.unexpectedAttributes",
							"Unexpected attributes",
							"Unexpected attributes were found in a 'set' verb in fuseaction #fb_.verbInfo.circuit#.#fb_.verbInfo.fuseaction#.");
			}
		}
	
		// compile <set>
		name = fb_.verbInfo.attributes.name;
		value = '"' & fb_.verbInfo.attributes.value & '"';
		
		if (find("##",name) gt 0) {
			name = '"' & name & '"';
		}
		if (fb_.verbInfo.attributes.evaluate) {
			value = "evaluate(" & value & ")";
		}
		if (name is not "") {
			if (fb_.verbInfo.attributes.overwrite) {
				fb_appendLine("<cfset #name# = #value# />");		
			} else {
				fb_appendLine("<cfif not isDefined(""#name#"")><cfset #name# = #value# /></cfif>");
			}
		} else {
			fb_appendLine("<cfset #value# />");
		}
	}
</cfscript>
