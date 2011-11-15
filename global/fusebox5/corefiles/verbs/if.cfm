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
		// condition - string - required
		if (not structKeyExists(fb_.verbInfo.attributes,"condition")) {
			fb_throw("fusebox.badGrammar.requiredAttributeMissing",
						"Required attribute is missing",
						"The attribute 'condition' is required, for a 'if' verb in fuseaction #fb_.verbInfo.circuit#.#fb_.verbInfo.fuseaction#.");
		}
		// strict mode - check attribute count:
		if (fb_.verbInfo.action.getCircuit().getApplication().strictMode) {
			if (structCount(fb_.verbInfo.attributes) neq 1) {
				fb_throw("fusebox.badGrammar.unexpectedAttributes",
							"Unexpected attributes",
							"Unexpected attributes were found in a 'if' verb in fuseaction #fb_.verbInfo.circuit#.#fb_.verbInfo.fuseaction#.");
			}
		}
		
		// validation of children:
		// at most one <true>, at most one <false>, nothing else:
		fb_.hasTrue = false;
		fb_.hasFalse = false;
		for (fb_.i = 1; fb_.i lte fb_.verbInfo.nChildren; fb_.i = fb_.i + 1) {
			if (fb_.verbInfo.children[fb_.i].getNamespace() is not "") {
				fb_throw("fusebox.badGrammar.illegalVerb",
						"Illegal verb",
						"An 'if' may contain only 'true' and 'false' verbs in fuseaction #fb_.verbInfo.circuit#.#fb_.verbInfo.fuseaction#.");
			}
			switch (fb_.verbInfo.children[fb_.i].getVerb()) {
			case "true":
				if (fb_.hasTrue) {
					fb_throw("fusebox.badGrammar.illegalVerb",
							"Illegal verb",
							"An 'if' may contain at most one 'true' verb in fuseaction #fb_.verbInfo.circuit#.#fb_.verbInfo.fuseaction#.");
				} else {
					fb_.hasTrue = true;
				}
				break;
			case "false":
				if (fb_.hasFalse) {
					fb_throw("fusebox.badGrammar.illegalVerb",
							"Illegal verb",
							"An 'if' may contain at most one 'false' verb in fuseaction #fb_.verbInfo.circuit#.#fb_.verbInfo.fuseaction#.");
				} else {
					fb_.hasFalse = true;
				}
				break;
			default:
				fb_throw("fusebox.badGrammar.illegalVerb",
						"Illegal verb",
						"An 'if' may contain only 'true' and 'false' verbs in fuseaction #fb_.verbInfo.circuit#.#fb_.verbInfo.fuseaction#.");
				break;
			}
		}
		
		// compile <if>
		// <true> and <false> can occur in either order so we defer the conditional
		// to the child tags...
		fb_.verbInfo.condition = fb_.verbInfo.attributes.condition;
		fb_.verbInfo.ifUsed = false;
	} else {
		// compile </if>
		if (fb_.verbInfo.ifUsed) {
			fb_appendLine("</cfif>");
		}
	}
</cfscript>
