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
		// <parameter> is actually two verbs and behaves differently depending on its
		// parent:
		// - inside an <include>, it saves / sets variables for the duration of the
		//   include just as it does inside a <do> directive
		// - inside an <xfa>, it defines URL parameters to add to the XFA value
		if (structKeyExists(fb_.verbInfo,"parent")) {

			if (fb_.verbInfo.parent.lexiconVerb is "include") {

				// name - string - required, must be varname or varname.varname
				if (not structKeyExists(fb_.verbInfo.attributes,"name")) {
					fb_throw("fusebox.badGrammar.requiredAttributeMissing",
								"Required attribute is missing",
								"The attribute 'name' is required, for a 'parameter' verb in fuseaction #fb_.verbInfo.circuit#.#fb_.verbInfo.fuseaction#.");
				}
				fb_.match1 = REFind("[A-Za-z0-9_]*",fb_.verbInfo.attributes.name,1,true);
				fb_.match2 = REFind("[A-Za-z0-9_]*\.[A-Za-z0-9_]*",fb_.verbInfo.attributes.name,1,true);
				fb_.nameLen = len(fb_.verbInfo.attributes.name);
				if (fb_.match1.pos[1] eq 1 and fb_.match1.len[1] eq fb_.nameLen) {
					fb_.name = "variables." & fb_.verbInfo.attributes.name;
				} else if (fb_.match2.pos[1] eq 1 and fb_.match2.len[1] eq fb_.nameLen) {
					fb_.name = fb_.verbInfo.attributes.name;
				} else {
					fb_throw("fusebox.badGrammar.invalidAttributeValue",
								"Attribute has invalid value",
								"The attribute 'name' must be a simple variable name, optionally qualified by a scope name, for a 'parameter' verb in fuseaction #fb_.verbInfo.circuit#.#fb_.verbInfo.fuseaction#.");
				}
				// value - string - optional
				// strict mode - check attribute count:
				if (fb_.verbInfo.action.getCircuit().getApplication().strictMode) {
					if (structCount(fb_.verbInfo.attributes) neq 2) {
						fb_throw("fusebox.badGrammar.unexpectedAttributes",
									"Unexpected attributes",
									"Unexpected attributes were found in a 'parameter' verb in fuseaction #fb_.verbInfo.circuit#.#fb_.verbInfo.fuseaction#.");
					}
				}
				
				// append this parameter to the parent data:
				arrayAppend(fb_.verbInfo.parent.parameters,fb_.name);
				// output the push code:
				fb_appendLine('<' & 'cfif isDefined("#fb_.name#")><' &
							'cfset myFusebox.stack["#fb_.name#"] = #fb_.name# ></' & 'cfif>');
				// reset the value of the "local" variable, if appropriate:
				if (structKeyExists(fb_.verbInfo.attributes,"value")) {
					fb_appendLine('<' & 'cfset #fb_.name# = "#fb_.verbInfo.attributes.value#" />');
				}
				
			} else if (fb_.verbInfo.parent.lexiconVerb is "xfa") {

				// name - string - required
				if (not structKeyExists(fb_.verbInfo.attributes,"name")) {
					fb_throw("fusebox.badGrammar.requiredAttributeMissing",
								"Required attribute is missing",
								"The attribute 'name' is required, for a 'parameter' verb in fuseaction #fb_.verbInfo.circuit#.#fb_.verbInfo.fuseaction#.");
				}
				// value - string - required
				if (not structKeyExists(fb_.verbInfo.attributes,"value")) {
					fb_throw("fusebox.badGrammar.requiredAttributeMissing",
								"Required attribute is missing",
								"The attribute 'value' is required, for a 'parameter' verb in fuseaction #fb_.verbInfo.circuit#.#fb_.verbInfo.fuseaction#.");
				}
				fb_.parameter = structNew();
				fb_.parameter.name = fb_.verbInfo.attributes.name;
				fb_.parameter.value = fb_.verbInfo.attributes.value;
				// append this parameter to the parent data:
				arrayAppend(fb_.verbInfo.parent.parameters,fb_.parameter);

			} else {

				fb_throw("fusebox.badGrammar.parameterInvalidParent",
							"Verb 'parameter' has invalid parent verb",
							"Found 'parameter' verb with no valid parent verb (either 'include' or 'xfa') in fuseaction #fb_.verbInfo.circuit#.#fb_.verbInfo.fuseaction#.");

			}

		} else {

			fb_throw("fusebox.badGrammar.parameterInvalidParent",
						"Verb 'parameter' has invalid parent verb",
						"Found 'parameter' verb with no valid parent verb (either 'include' or 'xfa') in fuseaction #fb_.verbInfo.circuit#.#fb_.verbInfo.fuseaction#.");

		}

	}
</cfscript>
