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
		fb_.app = fb_.verbInfo.action.getCircuit().getApplication();
		fb_.nAttrs = 0;
		// required - boolean - default true
		if (structKeyExists(fb_.verbInfo.attributes,"required")) {
			if (listFind("true,false,yes,no",fb_.verbInfo.attributes.required) eq 0) {
				fb_throw("fusebox.badGrammar.invalidAttributeValue",
							"Attribute has invalid value",
							"The attribute 'required' must either be ""true"" or ""false"", for a 'include' verb in fuseaction #fb_.verbInfo.circuit#.#fb_.verbInfo.fuseaction#.");
			}
		} else {
			fb_.verbInfo.attributes.required = true;
		}
		fb_.nAttrs = fb_.nAttrs + 1;	// for required - since we default it
		// template - string - required
		if (not structKeyExists(fb_.verbInfo.attributes,"template")) {
			fb_throw("fusebox.badGrammar.requiredAttributeMissing",
						"Required attribute is missing",
						"The attribute 'template' is required, for a 'include' verb in fuseaction #fb_.verbInfo.circuit#.#fb_.verbInfo.fuseaction#.");
		}
		fb_.nAttrs = fb_.nAttrs + 1;	// for template
		// contentvariable - string - default ""
		if (not structKeyExists(fb_.verbInfo.attributes,"contentvariable")) {
			fb_.verbInfo.attributes.contentvariable = "";
		}
		fb_.nAttrs = fb_.nAttrs + 1;	// for contentvariable - since we default it
		// overwrite - boolean - default true
		if (structKeyExists(fb_.verbInfo.attributes,"overwrite")) {
			if (listFind("true,false,yes,no",fb_.verbInfo.attributes.overwrite) eq 0) {
				fb_throw("fusebox.badGrammar.invalidAttributeValue",
							"Attribute has invalid value",
							"The attribute 'overwrite' must either be ""true"" or ""false"", for a 'include' verb in fuseaction #fb_.verbInfo.circuit#.#fb_.verbInfo.fuseaction#.");
			}
		} else {
			fb_.verbInfo.attributes.overwrite = true;
		}
		fb_.nAttrs = fb_.nAttrs + 1;	// for overwrite - since we default it
		// append - boolean - default false
		if (structKeyExists(fb_.verbInfo.attributes,"append")) {
			if (listFind("true,false,yes,no",fb_.verbInfo.attributes.append) eq 0) {
				fb_throw("fusebox.badGrammar.invalidAttributeValue",
							"Attribute has invalid value",
							"The attribute 'append' must either be ""true"" or ""false"", for a 'include' verb in fuseaction #fb_.verbInfo.circuit#.#fb_.verbInfo.fuseaction#.");
			}
		} else {
			fb_.verbInfo.attributes.append = false;
		}
		fb_.nAttrs = fb_.nAttrs + 1;	// for append - since we default it
		// prepend - boolean - default false
		if (structKeyExists(fb_.verbInfo.attributes,"prepend")) {
			if (listFind("true,false,yes,no",fb_.verbInfo.attributes.prepend) eq 0) {
				fb_throw("fusebox.badGrammar.invalidAttributeValue",
							"Attribute has invalid value",
							"The attribute 'prepend' must either be ""true"" or ""false"", for a 'include' verb in fuseaction #fb_.verbInfo.circuit#.#fb_.verbInfo.fuseaction#.");
			}
		} else {
			fb_.verbInfo.attributes.prepend = false;
		}
		fb_.nAttrs = fb_.nAttrs + 1;	// for prepend - since we default it
		// circuit - string - default current circuit alias
		// FB5: official support for this undocumented feature of FB4.x
		if (structKeyExists(fb_.verbInfo.attributes,"circuit")) {
			fb_.nAttrs = fb_.nAttrs + 1;	// we don't default this into the attributes struct
			if (structKeyExists(fb_.app.circuits,fb_.verbInfo.attributes.circuit)) {
				fb_.targetCircuit = fb_.app.circuits[fb_.verbInfo.attributes.circuit];
			} else if (fb_.app.allowImplicitCircuits) {
				// FB55: attempt to create an implicit circuit
				fb_.app.circuits[fb_.verbInfo.attributes.circuit] = __makeImplicitCircuit();
				fb_.targetCircuit = fb_.app.circuits[fb_.verbInfo.attributes.circuit];
			} else {
				fb_throw("fusebox.undefinedCircuit",
							"undefined Circuit",
							"The attribute 'circuit' (which was '#fb_.verbInfo.attributes.circuit#') must specify an existing circuit alias, for a 'include' verb in fuseaction #fb_.verbInfo.circuit#.#fb_.verbInfo.fuseaction#.");
			}
		} else {
			fb_.targetCircuit = fb_.verbInfo.action.getCircuit();
		}
		// strict mode - check attribute count:
		if (fb_.app.strictMode) {
			if (structCount(fb_.verbInfo.attributes) neq fb_.nAttrs) {
				fb_throw("fusebox.badGrammar.unexpectedAttributes",
							"Unexpected attributes",
							"Unexpected attributes were found in a 'include' verb in fuseaction #fb_.verbInfo.circuit#.#fb_.verbInfo.fuseaction#.");
			}
		}
				
		// auto-append script extension:
		fb_.standardExtension = fb_.app.scriptFileDelimiter;
		fb_.extension = listLast(fb_.verbInfo.attributes.template,".");
		if (listFindNoCase(fb_.app.maskedFileDelimiters,fb_.extension,',') eq 0 and 
				listFindNoCase(fb_.app.maskedFileDelimiters,'*',',') eq 0) {
			fb_.template = fb_.verbInfo.attributes.template & "." & fb_.standardExtension;
		} else {
			fb_.template = fb_.verbInfo.attributes.template;
		}
		if (find('##',fb_.template) gt 0) {
			fb_.templateLen = 'len("#fb_.template#")';
		} else {
			fb_.templateLen = len(fb_.template);
		}
		
		if (fb_.app.debug) {
			// trace inclusion of this fuse:
			fb_appendLine('<' & 'cfset myFusebox.trace("Runtime","&lt;include template=""#fb_.template#"" circuit=""#fb_.targetCircuit.getAlias()#""/&gt;") >');
		}
		
		// if there are children, assume we need a stack frame:
		if (fb_.verbInfo.hasChildren) {
			fb_appendLine('<' & 'cfset myFusebox.enterStackFrame() >');
			// this is where the child <parameter> verbs will store the variable names:
			fb_.verbInfo.parameters = arrayNew(1);
		}
		
	} else {
		
		// any child <parameter> verbs will have been compiled by now
		
		// compile <include>
		if (fb_.verbInfo.attributes.contentvariable is not "" and not fb_.verbInfo.attributes.overwrite) {
			fb_appendLine('<cfif not isDefined("#fb_.verbInfo.attributes.contentvariable#")>');
		}
		fb_appendLine("<cftry>");
		if (fb_.verbInfo.attributes.contentvariable is not "") {
			if (fb_.verbInfo.attributes.append) {
				fb_appendLine('<cfparam name="#fb_.verbInfo.attributes.contentvariable#" default=""><cfsavecontent variable="#fb_.verbInfo.attributes.contentvariable#"><cfoutput>###fb_.verbInfo.attributes.contentvariable###<cfinclude template="#fb_.verbInfo.action.getCircuit().getApplication().parseRootPath##fb_.targetCircuit.getRelativePath()##fb_.template#"></cfoutput></cfsavecontent>');
			} else if (fb_.verbInfo.attributes.prepend) {
				fb_appendLine('<cfparam name="#fb_.verbInfo.attributes.contentvariable#" default=""><cfsavecontent variable="#fb_.verbInfo.attributes.contentvariable#"><cfoutput><cfinclude template="#fb_.verbInfo.action.getCircuit().getApplication().parseRootPath##fb_.targetCircuit.getRelativePath()##fb_.template#">###fb_.verbInfo.attributes.contentvariable###</cfoutput></cfsavecontent>');
			} else {
				fb_appendLine('<cfsavecontent variable="#fb_.verbInfo.attributes.contentvariable#"><cfoutput><cfinclude template="#fb_.verbInfo.action.getCircuit().getApplication().parseRootPath##fb_.targetCircuit.getRelativePath()##fb_.template#"></cfoutput></cfsavecontent>');
			}
		} else {
			fb_appendLine('<cfoutput><cfinclude template="#fb_.verbInfo.action.getCircuit().getApplication().parseRootPath##fb_.targetCircuit.getRelativePath()##fb_.template#"></cfoutput>');
		}
		fb_appendLine('<cfcatch type="missingInclude"><cfif len(cfcatch.MissingFileName) gte #fb_.templateLen# and right(cfcatch.MissingFileName,#fb_.templateLen#) is "#fb_.template#">');
		if (fb_.verbInfo.attributes.required) {
			fb_appendLine('<cfthrow type="fusebox.missingFuse" message="missing Fuse" ' &
					'detail="You tried to include a fuse #fb_.template# in circuit ' &
						'#fb_.targetCircuit.getAlias()# which does not exist (from fuseaction #fb_.verbInfo.circuit#.#fb_.verbInfo.fuseaction#).">');
		} else {
			fb_appendLine('<!--- do nothing --->');
		}
		fb_appendLine('<cfelse><cfrethrow></cfif></cfcatch></cftry>');
		if (fb_.verbInfo.attributes.contentvariable is not "" and not fb_.verbInfo.attributes.overwrite) {
			fb_appendLine('</cfif>');
		}
		
		// clean up any stack frame:
		if (fb_.verbInfo.hasChildren) {
			// unwind the stack:
			for (fb_.i = arrayLen(fb_.verbInfo.parameters); fb_.i gt 0; fb_.i = fb_.i - 1) {
				fb_.name = fb_.verbInfo.parameters[fb_.i];
				fb_.scope = listFirst(fb_.name,".");
				fb_.qName = listRest(fb_.name,".");
				fb_appendLine('<' & 'cfif structKeyExists(myFusebox.stack,"#fb_.name#")><' &
							'cfset #fb_.name# = myFusebox.stack["#fb_.name#"] ><' &
							'cfelse><' & 
							'cfset structDelete(#fb_.scope#,"#fb_.qName#")></' & 'cfif>');
			}
			fb_appendLine('<' & 'cfset myFusebox.leaveStackFrame() >');
		}
	}
</cfscript>
