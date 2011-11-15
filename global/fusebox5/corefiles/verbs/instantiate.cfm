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
		// arguments - string default ""
		if (not structKeyExists(fb_.verbInfo.attributes,"arguments")) {
			// prepare to gather up <argument> tags, if any:
			fb_.verbInfo.data.arguments = "";
			fb_.verbInfo.data.separator = "";
		} else {
			fb_.nAttrs = fb_.nAttrs + 1;	// for arguments - since we do not default it
			if (fb_.verbInfo.hasChildren) {
				fb_throw("fusebox.badGrammar.unexpectedChildren",
							"Unexpected child verbs",
							"The 'instantiate' verb cannot have children when using the 'arguments' attribute, in fuseaction #fb_.verbInfo.circuit#.#fb_.verbInfo.fuseaction#.");
			}
		}
		// class - string default ""
		// webservice - string default ""
		// one of class or webservice must be present
		if (not structKeyExists(fb_.verbInfo.attributes,"class")) {
			if (not structKeyExists(fb_.verbInfo.attributes,"webservice")) {
				// error: class or webservice must be present
				fb_throw("fusebox.badGrammar.requiredAttributeMissing",
							"Required attribute is missing",
							"Either the attribute 'class' or 'webservice' is required, for a 'instantiate' verb in fuseaction #fb_.verbInfo.circuit#.#fb_.verbInfo.fuseaction#.");
			} else {
				// webservice
			}
		} else {
			if (not structKeyExists(fb_.verbInfo.attributes,"webservice")) {
				// class
			} else {
				// error: only one of class or webservice may be present
				fb_throw("fusebox.badGrammar.requiredAttributeMissing",
							"Required attribute is missing",
							"Either the attribute 'class' or 'webservice' is required, for a 'instantiate' verb in fuseaction #fb_.verbInfo.circuit#.#fb_.verbInfo.fuseaction#.");
			}
		}
		fb_.nAttrs = fb_.nAttrs + 1;	// for either one of class or webservice
		// object - string - required
		if (not structKeyExists(fb_.verbInfo.attributes,"object")) {
			fb_throw("fusebox.badGrammar.requiredAttributeMissing",
						"Required attribute is missing",
						"The attribute 'object' is required, for a 'instantiate' verb in fuseaction #fb_.verbInfo.circuit#.#fb_.verbInfo.fuseaction#.");
		}
		fb_.nAttrs = fb_.nAttrs + 1;	// for object
		// overwrite - boolean default true
		if (structKeyExists(fb_.verbInfo.attributes,"overwrite")) {
			if (listFind("true,false,yes,no",fb_.verbInfo.attributes.overwrite) eq 0) {
				fb_throw("fusebox.badGrammar.invalidAttributeValue",
							"Attribute has invalid value",
							"The attribute 'overwrite' must either be ""true"" or ""false"", for a 'instantiate' verb in fuseaction #fb_.verbInfo.circuit#.#fb_.verbInfo.fuseaction#.");
			}
		} else {
			fb_.verbInfo.attributes.overwrite = true;
		}
		fb_.nAttrs = fb_.nAttrs + 1;	// for overwrite - since we default it
		// strict mode - check attribute count:
		if (fb_.verbInfo.action.getCircuit().getApplication().strictMode) {
			if (structCount(fb_.verbInfo.attributes) neq fb_.nAttrs) {
				fb_throw("fusebox.badGrammar.unexpectedAttributes",
							"Unexpected attributes",
							"Unexpected attributes were found in a 'instantiate' verb in fuseaction #fb_.verbInfo.circuit#.#fb_.verbInfo.fuseaction#.");
			}
		}
	
	} else {
		
		// update arguments if we had any child <argument> tags:
		if (structKeyExists(fb_.verbInfo.attributes,"arguments")) {
			fb_.args = fb_.verbInfo.attributes.arguments;
		} else {
			fb_.args = fb_.verbInfo.data.arguments;
		}

		// compile <instantiate>
		fb_.obj = fb_.verbInfo.attributes.object;
		fb_.constructor = "";
		if (find("##",fb_.obj) gt 0) {
			fb_.obj = '"' & fb_.obj & '"';
		}
		if (structKeyExists(fb_.verbInfo.attributes,"class")) {
			// look up the class definition:
			fb_.classDef = fb_.verbInfo.action.getCircuit().getApplication().getClassDefinition(fb_.verbInfo.attributes.class);
			fb_.creation = 'createObject("#fb_.classDef.type#","#fb_.classDef.classpath#")';
			fb_.constructor = fb_.classDef.constructor;
		} else {
			fb_.creation = 'createObject("webservice","#fb_.verbInfo.attributes.webservice#")';
		}
		// I'd rather the constructor was called immediately on construction but it can't be guaranteed that the constructor returns this
		if (fb_.verbInfo.attributes.overwrite) {
			fb_appendLine('<cfset #fb_.obj# = #fb_.creation# >');
			if (fb_.constructor is not "") {
				fb_appendLine('<cfset #fb_.obj#.#fb_.constructor#(#fb_.args#) >');
			} else if (fb_.args is not "") {
				fb_throw("fusebox.badGrammar.invalidAttributeValue",
							"Attribute has invalid value",
							"Arguments may not be specified when there is no constructor specified for the class.");
			}
		} else {
			fb_appendLine('<cfif not isDefined("#fb_.verbInfo.attributes.object#")>');
			fb_appendLine('<cfset #fb_.obj# = #fb_.creation# >');
			if (fb_.constructor is not "") {
				fb_appendLine('<cfset #fb_.obj#.#fb_.constructor#(#fb_.args#) >');
			} else if (fb_.args is not "") {
				fb_throw("fusebox.badGrammar.invalidAttributeValue",
							"Attribute has invalid value",
							"Arguments may not be specified when there is no constructor specified for the class.");
			}
			fb_appendLine('</cfif>');
		}
	}
</cfscript>
