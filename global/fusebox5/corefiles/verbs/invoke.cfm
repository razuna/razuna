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
		// class - string default ""
		// object - string default ""
		// webservice - string default ""
		// one of class / object / webservice must be present
		if (not structKeyExists(fb_.verbInfo.attributes,"class")) {
			if (not structKeyExists(fb_.verbInfo.attributes,"object")) {
				if (not structKeyExists(fb_.verbInfo.attributes,"webservice")) {
					// error: class or object or webservice must be present
					fb_throw("fusebox.badGrammar.requiredAttributeMissing",
								"Required attribute is missing",
								"One of the attributes 'class', 'object' or 'webservice' is required, for a 'invoke' verb in fuseaction #fb_.verbInfo.circuit#.#fb_.verbInfo.fuseaction#.");
				} else {
					// webservice
				}
			} else {
				if (not structKeyExists(fb_.verbInfo.attributes,"webservice")) {
					// object
				} else {
					// error: only one of class or object or webservice may be present
					fb_throw("fusebox.badGrammar.requiredAttributeMissing",
								"Required attribute is missing",
								"One of the attributes 'class', 'object' or 'webservice' is required, for a 'invoke' verb in fuseaction #fb_.verbInfo.circuit#.#fb_.verbInfo.fuseaction#.");
				}
			}
		} else {
			if (structKeyExists(fb_.verbInfo.attributes,"object") or
						structKeyExists(fb_.verbInfo.attributes,"webservice")) {
					// error: only one of class or object or webservice may be present
					fb_throw("fusebox.badGrammar.requiredAttributeMissing",
								"Required attribute is missing",
								"One of the attributes 'class', 'object' or 'webservice' is required, for a 'invoke' verb in fuseaction #fb_.verbInfo.circuit#.#fb_.verbInfo.fuseaction#.");
			} else {
				// class
			}
		}
		fb_.nAttrs = fb_.nAttrs + 1;	// for any one of class, object or webservice
		// methodcall - string default ""
		// method - string default "" (new in FB5)
		// one of methodcall or method must be present
		if (not structKeyExists(fb_.verbInfo.attributes,"methodcall")) {
			if (not structKeyExists(fb_.verbInfo.attributes,"method")) {
				fb_throw("fusebox.badGrammar.requiredAttributeMissing",
							"Required attribute is missing",
							"One of the attributes 'methodcall' or 'method' is required, for a 'invoke' verb in fuseaction #fb_.verbInfo.circuit#.#fb_.verbInfo.fuseaction#.");
			} else {
				// method - prepare to gather up <argument> tags:
				fb_.verbInfo.data.arguments = "";
				fb_.verbInfo.data.separator = "";
			}
		} else {
			if (not structKeyExists(fb_.verbInfo.attributes,"method")) {
				// methodcall - FB41 compatible
				if (fb_.verbInfo.hasChildren) {
					fb_throw("fusebox.badGrammar.unexpectedChildren",
								"Unexpected child verbs",
								"The 'invoke' verb cannot have children when using the 'methodcall' attribute, in fuseaction #fb_.verbInfo.circuit#.#fb_.verbInfo.fuseaction#.");
				}
			} else {
				// error: only one of methodcall or method may be present
				fb_throw("fusebox.badGrammar.requiredAttributeMissing",
							"Required attribute is missing",
							"One of the attributes 'methodcall' or 'method' is required, for a 'invoke' verb in fuseaction #fb_.verbInfo.circuit#.#fb_.verbInfo.fuseaction#.");
			}
		}
		fb_.nAttrs = fb_.nAttrs + 1;	// for either one of methodcall or method
		// overwrite - boolean default true (if returnvariable is present)
		if (structKeyExists(fb_.verbInfo.attributes,"overwrite")) {
			if (listFind("true,false,yes,no",fb_.verbInfo.attributes.overwrite) eq 0) {
				fb_throw("fusebox.badGrammar.invalidAttributeValue",
							"Attribute has invalid value",
							"The attribute 'overwrite' must either be ""true"" or ""false"", for a 'invoke' verb in fuseaction #fb_.verbInfo.circuit#.#fb_.verbInfo.fuseaction#.");
			}
		} else {
			if (structKeyExists(fb_.verbInfo.attributes,"returnvariable")) {
				fb_.verbInfo.attributes.overwrite = true;
			} else {
				fb_.verbInfo.attributes.overwrite = false;
			}
		}
		fb_.nAttrs = fb_.nAttrs + 1;	// for overwrite - since we default it
		// returnvariable - string - required if overwrite is true
		if (not structKeyExists(fb_.verbInfo.attributes,"returnvariable")) {
			if (fb_.verbInfo.attributes.overwrite) {
				fb_throw("fusebox.badGrammar.requiredAttributeMissing",
							"Required attribute is missing",
							"The attribute 'returnvariable' is required if 'overwrite' is 'true', for a 'invoke' verb in fuseaction #fb_.verbInfo.circuit#.#fb_.verbInfo.fuseaction#.");
			}
			// default to "" to make subsequent code easier
			fb_.verbInfo.attributes.returnvariable = "";
		}
		fb_.nAttrs = fb_.nAttrs + 1;	// for returnvariable - since we default it
		// strict mode - check attribute count:
		if (fb_.verbInfo.action.getCircuit().getApplication().strictMode) {
			if (structCount(fb_.verbInfo.attributes) neq fb_.nAttrs) {
				fb_throw("fusebox.badGrammar.unexpectedAttributes",
							"Unexpected attributes",
							"Unexpected attributes were found in a 'invoke' verb in fuseaction #fb_.verbInfo.circuit#.#fb_.verbInfo.fuseaction#.");
			}
		}
		
	} else {	// compile the code on the end tag:

		// check whether we're using the old-style methodcall or the new-style method / argument form:
		if (structKeyExists(fb_.verbInfo.attributes,"methodcall")) {
			fb_.methodcall = fb_.verbInfo.attributes.methodcall;
		} else {
			// complete the method call:
			fb_.methodcall = fb_.verbInfo.attributes.method & "(" & fb_.verbInfo.data.arguments & ")";
		}
		// compile <invoke>
		fb_.ret = fb_.verbInfo.attributes.returnvariable;
		if (structKeyExists(fb_.verbInfo.attributes,"object")) {
			// handled
			fb_.obj = fb_.verbInfo.attributes.object;
		} else if (structKeyExists(fb_.verbInfo.attributes,"class")) {
			// look it up
			fb_.classDef = fb_.verbInfo.action.getCircuit().getApplication().getClassDefinition(fb_.verbInfo.attributes.class);
			fb_.obj = 'createObject("#fb_.classDef.type#","#fb_.classDef.classpath#")';
		} else if (structKeyExists(fb_.verbInfo.attributes,"webservice")) {
			// this makes no sense but it's what the FB41 core files do:
			fb_.obj = fb_.verbInfo.attributes.webservice;
		}
		if (find("##",fb_.ret) gt 0) {
			fb_.ret = '"' & fb_.ret & '"';
		}
		if (fb_.verbInfo.attributes.overwrite) {
			fb_appendLine('<cfset #fb_.ret# = #fb_.obj#.#fb_.methodcall# >');
		} else {
			if (fb_.verbInfo.attributes.returnvariable is not "") {
				fb_appendLine('<cfif not isDefined("#fb_.verbInfo.attributes.returnvariable#")><cfset #fb_.ret# = #fb_.obj#.#fb_.methodcall# ></cfif>');
			} else {
				fb_appendLine('<cfset #fb_.obj#.#fb_.methodcall# >');
			}
		}
	}
</cfscript>
