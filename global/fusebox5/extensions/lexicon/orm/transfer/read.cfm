<cfscript>
	// usage:
	//		<transfer:read object="task" bean="thisTask">
	//			<transfer:parameter name="id" value="#attributes.id#" />
	//		</transfer:read>
	if (fb_.verbInfo.executionMode is "start") {
		// validate attributes
		// object - string
		if (not structKeyExists(fb_.verbInfo.attributes,"object")) {
			fb_throw("fusebox.badGrammar.requiredAttributeMissing",
						"Required attribute is missing",
						"The attribute 'object' is required, for a 'read' verb in fuseaction #fb_.verbInfo.circuit#.#fb_.verbInfo.fuseaction#.");
		}
		// bean - string
		if (not structKeyExists(fb_.verbInfo.attributes,"bean")) {
			fb_throw("fusebox.badGrammar.requiredAttributeMissing",
						"Required attribute is missing",
						"The attribute 'bean' is required, for a 'read' verb in fuseaction #fb_.verbInfo.circuit#.#fb_.verbInfo.fuseaction#.");
		}
		
		// prepare for any parameters:
		fb_.verbInfo.parameters = structNew();
		
	} else {
		// generate code:
		fb_appendLine('<cfset _propertyMap = structNew() />');
		// gather up parameters:
		for (fb_.p in fb_.verbInfo.parameters) {
			fb_appendLine('<cfset _propertyMap.#fb_.p# = "#fb_.verbInfo.parameters[fb_.p]#" />');
		}
		fb_appendLine('<cfset #fb_.verbInfo.attributes.bean# = ' &
				'myFusebox.getApplication().getApplicationData().transferFactory' & 
				'.getTransfer().readByPropertyMap("#fb_.verbInfo.attributes.object#",_propertyMap) />');
		fb_appendLine('<cfset myFusebox.trace("Transfer","Read Bean") />');
	}
</cfscript>
