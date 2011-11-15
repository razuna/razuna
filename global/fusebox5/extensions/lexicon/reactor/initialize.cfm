<cfscript>
	// @ Author Nathan Strutz
	// Initializes a Reactor factory into the current application scope (respecting the fusebox application key)
	// usage:
	// 1. add the lexicon declaration to your circuit file:
	//    <circuit xmlns:reactor="reactor/">
	// 2. use the verb in a fuseaction:
	//    <reactor:initialize configuration="#expandPath('/config/Reactor.xml')#"/>
	//
	if (fb_.verbInfo.executionMode is "start") {

		// beanDefinitionFile is required
		if (not structKeyExists(fb_.verbInfo.attributes,"configuration")) {
			fb_throw("fusebox.badGrammar.requiredAttributeMissing",
						"Required attribute is missing",
						"The attribute 'configuration' is required, for a 'initialize' verb in fuseaction #fb_.verbInfo.circuit#.#fb_.verbInfo.fuseaction#.");
		}
		//

		// set ColdSpring in this fusebox instance's application space
		fb_appendLine('<cfset myFusebox.getApplication().getApplicationData().reactor = createObject("component", "reactor.reactorFactory").init("#fb_.verbInfo.attributes.configuration#") />');
	} else {
		//
		// end mode - do nothing
	}
</cfscript>