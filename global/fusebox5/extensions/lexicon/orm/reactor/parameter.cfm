<cfscript>
	// usage inside other verbs:
	//		<reactor:parameter
	//				name="paramName"
	//				value="someVal" />
	if (fb_.verbInfo.executionMode is "start") {
		// validate attributes
		// <parameter> must have a parent verb in this lexicon:
		if (structKeyExists(fb_.verbInfo,"parent") and
				fb_.verbInfo.parent.lexicon is fb_.verbInfo.lexicon and
				listFind("delete,read,save",fb_.verbInfo.parent.lexiconVerb) neq 0) {

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
			// add this parameter to the parent data:
			fb_.verbInfo.parent.parameters[fb_.verbInfo.attributes.name] = fb_.verbInfo.attributes.value;

		} else {

			fb_throw("fusebox.badGrammar.parameterInvalidParent",
						"Verb 'parameter' has invalid parent verb",
						"Found 'parameter' verb with no valid parent verb in fuseaction #fb_.verbInfo.circuit#.#fb_.verbInfo.fuseaction#.");

		}

	}
</cfscript>
