<cfscript>
	// usage:
	//		<transfer:new object="task" bean="thisTask" populate="true|false" />
	if (fb_.verbInfo.executionMode is "start") {
		// validate attributes
		// object - string
		if (not structKeyExists(fb_.verbInfo.attributes,"object")) {
			fb_throw("fusebox.badGrammar.requiredAttributeMissing",
						"Required attribute is missing",
						"The attribute 'object' is required, for a 'new' verb in fuseaction #fb_.verbInfo.circuit#.#fb_.verbInfo.fuseaction#.");
		}
		// bean - string
		if (not structKeyExists(fb_.verbInfo.attributes,"bean")) {
			fb_throw("fusebox.badGrammar.requiredAttributeMissing",
						"Required attribute is missing",
						"The attribute 'bean' is required, for a 'new' verb in fuseaction #fb_.verbInfo.circuit#.#fb_.verbInfo.fuseaction#.");
		}
		// populate - boolean
		if (not structKeyExists(fb_.verbInfo.attributes,"populate")) {
			fb_throw("fusebox.badGrammar.requiredAttributeMissing",
						"Required attribute is missing",
						"The attribute 'populate' is required, for a 'new' verb in fuseaction #fb_.verbInfo.circuit#.#fb_.verbInfo.fuseaction#.");
		} else if (listFind("true,false,yes,no",fb_.verbInfo.attributes.populate) eq 0) {
			fb_throw("fusebox.badGrammar.invalidAttributeValue",
						"Attribute has invalid value",
						"The attribute 'populate' must either be ""true"" or ""false"", for a 'include' verb in fuseaction #fb_.verbInfo.circuit#.#fb_.verbInfo.fuseaction#.");
		}
		
		// generate code:
		fb_appendLine('<cfset #fb_.verbInfo.attributes.bean# = ' &
				'myFusebox.getApplication().getApplicationData().transferFactory' & 
				'.getTransfer().new("#fb_.verbInfo.attributes.object#") />');
		if (fb_.verbInfo.attributes.populate) {
			fb_appendLine('<cfset #fb_.verbInfo.attributes.bean#.setMemento(attributes) />');
		}
		fb_appendLine('<cfset myFusebox.trace("Transfer","Created New Bean") />');

	} else {
	}
</cfscript>
