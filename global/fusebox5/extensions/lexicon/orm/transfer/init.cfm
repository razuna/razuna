<cfscript>
	// usage:
	//		<transfer:init
	//				datasource="/config/datasource.xml"
	//				configuration="/config/transfer.xml"
	//				definitions="/output" />
	if (fb_.verbInfo.executionMode is "start") {
		// validate attributes
		// configuration - string (path)
		if (not structKeyExists(fb_.verbInfo.attributes,"configuration")) {
			fb_throw("fusebox.badGrammar.requiredAttributeMissing",
						"Required attribute is missing",
						"The attribute 'configuration' is required, for a 'init' verb in fuseaction #fb_.verbInfo.circuit#.#fb_.verbInfo.fuseaction#.");
		}
		// datasource - string (path)
		if (not structKeyExists(fb_.verbInfo.attributes,"datasource")) {
			fb_throw("fusebox.badGrammar.requiredAttributeMissing",
						"Required attribute is missing",
						"The attribute 'datasource' is required, for a 'init' verb in fuseaction #fb_.verbInfo.circuit#.#fb_.verbInfo.fuseaction#.");
		}
		// definitions - string (path)
		if (not structKeyExists(fb_.verbInfo.attributes,"definitions")) {
			fb_throw("fusebox.badGrammar.requiredAttributeMissing",
						"Required attribute is missing",
						"The attribute 'definitions' is required, for a 'init' verb in fuseaction #fb_.verbInfo.circuit#.#fb_.verbInfo.fuseaction#.");
		}
		// generate code:
		fb_appendLine('<cfset myFusebox.getApplication().getApplicationData().transferFactory = ' &
				'createObject("component","transfer.TransferFactory")' &
					'.init("#fb_.verbInfo.attributes.datasource#","#fb_.verbInfo.attributes.configuration#","#fb_.verbInfo.attributes.definitions#") />');
		fb_appendLine('<cfset myFusebox.trace("Transfer","Created TransferFactory") />');
	} else {
	}
</cfscript>
