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
		fb_.nAttrs = 0;
		// there are five different forms of the <loop> verb:
		// 1. condition - string - required
		// 2. query - string - required
		// 3. from - string - required
		//    to - string - required
		//    index - string - required
		//    step - string - optional
		// 4. collection - string - required
		//    item - string - required
		// 5. list - string - required
		//    index - index - required
		// the last two are new in Fusebox 5
		if (structKeyExists(fb_.verbInfo.attributes,"condition")) {
			
			fb_.nAttrs = 1;
			
			fb_appendLine('<cfloop condition="#fb_.verbInfo.attributes.condition#">');
			
		} else if (structKeyExists(fb_.verbInfo.attributes,"query")) {
			
			fb_.nAttrs = 1;
			
			fb_appendLine('<cfloop query="#fb_.verbInfo.attributes.query#">');
		
		} else if (structKeyExists(fb_.verbInfo.attributes,"from") or structKeyExists(fb_.verbInfo.attributes,"to")) {
		
			fb_.nAttrs = 3;		// from/to/index required
			
			if (not structKeyExists(fb_.verbInfo.attributes,"from") or
					not structKeyExists(fb_.verbInfo.attributes,"to") or 
					not structKeyExists(fb_.verbInfo.attributes,"index")) {
				fb_throw("fusebox.badGrammar.requiredAttributeMissing",
							"Required attribute is missing",
							"The attributes 'from', 'to' and 'index' are both required, for a 'loop' verb in fuseaction #fb_.verbInfo.circuit#.#fb_.verbInfo.fuseaction#.");
			} else {
				fb_appendSegment('<' & 'cfloop from="#fb_.verbInfo.attributes.from#"' &
									' to="#fb_.verbInfo.attributes.to#"' &
									' index="#fb_.verbInfo.attributes.index#"');
				if (structKeyExists(fb_.verbInfo.attributes,"step")) {
					
					fb_.nAttrs = fb_.nAttrs + 1;	// step optional

					fb_appendSegment(' step="#fb_.verbInfo.attributes.step#"');
				}
				fb_appendLine('>');
			}
		
		} else if (structKeyExists(fb_.verbInfo.attributes,"collection")) {
			
			fb_.nAttrs = 2;		// collection/item required
			
			if (not structKeyExists(fb_.verbInfo.attributes,"item")) {
				fb_throw("fusebox.badGrammar.requiredAttributeMissing",
							"Required attribute is missing",
							"The attribute 'item' is required, for a 'loop' verb with a 'collection' attribute in fuseaction #fb_.verbInfo.circuit#.#fb_.verbInfo.fuseaction#.");
			} else {
				fb_appendLine('<cfloop collection="#fb_.verbInfo.attributes.collection#" item="#fb_.verbInfo.attributes.item#">');
			}
			
		} else if (structKeyExists(fb_.verbInfo.attributes,"list")) {
			
			fb_.nAttrs = 2;		// list/index required
			
			if (not structKeyExists(fb_.verbInfo.attributes,"index")) {
				fb_throw("fusebox.badGrammar.requiredAttributeMissing",
							"Required attribute is missing",
							"The attribute 'index' is required, for a 'loop' verb with a 'list' attribute in fuseaction #fb_.verbInfo.circuit#.#fb_.verbInfo.fuseaction#.");
			} else {
				fb_appendLine('<cfloop list="#fb_.verbInfo.attributes.list#" index="#fb_.verbInfo.attributes.index#">');
			}
			
		} else {
			// illegal attributes
			fb_throw("fusebox.badGrammar.requiredAttributeMissing",
						"Required attribute is missing",
						"One of 'condition', 'query', 'from'/'to', 'collection' or 'list' is required, for a 'loop' verb in fuseaction #fb_.verbInfo.circuit#.#fb_.verbInfo.fuseaction#.");
		}
		// strict mode - check attribute count:
		if (fb_.verbInfo.action.getCircuit().getApplication().strictMode) {
			if (structCount(fb_.verbInfo.attributes) neq fb_.nAttrs) {
				fb_throw("fusebox.badGrammar.unexpectedAttributes",
							"Unexpected attributes",
							"Unexpected attributes were found in a 'loop' verb in fuseaction #fb_.verbInfo.circuit#.#fb_.verbInfo.fuseaction#.");
			}
		}
	}

	// compile </loop>
	if (fb_.verbInfo.executionMode is "end") {
		fb_appendLine("</cfloop>");
	}
</cfscript>
