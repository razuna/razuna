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
	fb_.fbApp = fb_.verbInfo.action.getCircuit().getApplication();
	if (fb_.verbInfo.executionMode is "start") {
		// validate attributes
		// evaluate - boolean default false
		if (structKeyExists(fb_.verbInfo.attributes,"evaluate")) {
			if (listFind("true,false,yes,no",fb_.verbInfo.attributes.evaluate) eq 0) {
				fb_throw("fusebox.badGrammar.invalidAttributeValue",
							"Attribute has invalid value",
							"The attribute 'evaluate' must either be ""true"" or ""false"", for a 'xfa' verb in fuseaction #fb_.verbInfo.circuit#.#fb_.verbInfo.fuseaction#.");
			}
		} else {
			fb_.verbInfo.attributes.evaluate = false;
		}
		// name - string - required
		if (not structKeyExists(fb_.verbInfo.attributes,"name") or trim(fb_.verbInfo.attributes.name) is "") {
			fb_throw("fusebox.badGrammar.requiredAttributeMissing",
						"Required attribute is missing",
						"The attribute 'name' is required when 'overwrite' is present, for a 'xfa' verb in fuseaction #fb_.verbInfo.circuit#.#fb_.verbInfo.fuseaction#.");
		}
		// overwrite - boolean - default true
		if (structKeyExists(fb_.verbInfo.attributes,"overwrite")) {
			if (listFind("true,false,yes,no",fb_.verbInfo.attributes.overwrite) eq 0) {
				fb_throw("fusebox.badGrammar.invalidAttributeValue",
							"Attribute has invalid value",
							"The attribute 'overwrite' must either be ""true"" or ""false"", for a 'xfa' verb in fuseaction #fb_.verbInfo.circuit#.#fb_.verbInfo.fuseaction#.");
			}
		} else {
			fb_.verbInfo.attributes.overwrite = true;
		}
		// value - string - required
		if (not structKeyExists(fb_.verbInfo.attributes,"value")) {
			fb_throw("fusebox.badGrammar.requiredAttributeMissing",
						"Required attribute is missing",
						"The attribute 'value' is required, for a 'xfa' verb in fuseaction #fb_.verbInfo.circuit#.#fb_.verbInfo.fuseaction#.");
		}
		// strict mode - check attribute count and that there are no URL parameters:
		if (fb_.verbInfo.action.getCircuit().getApplication().strictMode) {
			if (structCount(fb_.verbInfo.attributes) neq 4) {
				fb_throw("fusebox.badGrammar.unexpectedAttributes",
							"Unexpected attributes",
							"Unexpected attributes were found in a 'xfa' verb in fuseaction #fb_.verbInfo.circuit#.#fb_.verbInfo.fuseaction#.");
			}
			// do not allow URL parameters in the XFA value:
			if (find(fb_.fbApp.queryStringSeparator,fb_.verbInfo.attributes.value) neq 0) {
				fb_throw("fusebox.badGrammar.invalidAttributeValue",
							"Attribute has invalid value",
							"The attribute 'value' contains URL parameters, which is not allowed in 'strict' mode, for a 'xfa' verb in fuseaction #fb_.verbInfo.circuit#.#fb_.verbInfo.fuseaction#.");
			}
		}
		
		// if there are children, set up a parameter block:
		if (fb_.verbInfo.hasChildren) {
			// do not allow URL parameters in the XFA value:
			if (find(fb_.fbApp.queryStringSeparator,fb_.verbInfo.attributes.value) neq 0) {
				fb_throw("fusebox.badGrammar.invalidAttributeValue",
							"Attribute has invalid value",
							"The attribute 'value' contains URL parameters, which is not allowed when 'parameter' is present, for a 'xfa' verb in fuseaction #fb_.verbInfo.circuit#.#fb_.verbInfo.fuseaction#.");
			}
			// this is where the child <parameter> verbs will store the parameter details:
			fb_.verbInfo.parameters = arrayNew(1);
		}
		
	} else {
	
		// compile <xfa>
		name = "xfa." & fb_.verbInfo.attributes.name;
		value = fb_.verbInfo.attributes.value;

		if (fb_.verbInfo.attributes.evaluate) {
			value = "evaluate(" & value & ")";
		} else if (listLen(value,".") lt 2) {
			// adjust xfa value if it is local to this circuit:
			// <xfa name="foo" value="bar" /> becomes
			// <xfa name="foo" value="thiscircuit.bar" />
			value = fb_.verbInfo.circuit & "." & value;
		}
		// append any parameters to the URL value:
		if (fb_.verbInfo.hasChildren) {
			fb_.n = arrayLen(fb_.verbInfo.parameters);
			for (fb_.i = 1; fb_.i lte fb_.n; fb_.i = fb_.i + 1) {
				value = value & fb_.fbApp.queryStringSeparator & fb_.verbInfo.parameters[fb_.i].name &
								fb_.fbApp.queryStringEqual & fb_.verbInfo.parameters[fb_.i].value;
			}
		}
		value = '"' & value & '"';
		
		if (find("##",name) gt 0) {
			name = '"' & name & '"';
		}
		if (fb_.verbInfo.attributes.overwrite) {
			fb_appendLine("<cfset #name# = #value# />");		
		} else {
			fb_appendLine("<cfif not isDefined(""#name#"")><cfset #name# = #value# /></cfif>");
		}
	}
</cfscript>
