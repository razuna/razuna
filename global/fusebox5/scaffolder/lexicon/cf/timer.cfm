<cfscript>
	// Author: Qasim Rasheed (qasimrasheed@gmail.com)
	// example custom verb that compiles to a <cftrace> tag
	// usage:
	// 1. add the lexicon declaration to your circuit file:
	//    <circuit xmlns:cf="cf/">
	// 2. use the verb in a fuseaction:
	//    <cf:timer type="debug" />
	//	
	// For details on the use of <cftimer> tag. please refer to the documentation.
	// http://livedocs.macromedia.com/coldfusion/7/htmldocs/00000346.htm
	//
	// how this works:
	// a. validate the attributes passed in (fb_.verbInfo.attributes) along with checking for valid value for attributes.
	// b. in start mode, generate the required CFML
	// c. in end mode, add the closing cftrace tag.
	//
	
	if (fb_.verbInfo.executionMode is "start") {
		fb_.label = '';
		fb_.type = 'debug';
		
		if ( structKeyExists(fb_.verbInfo.attributes, 'label' ) ) 
			fb_.label = ' label="#fb_.verbInfo.attributes.label#"';
		
		if ( structKeyExists( fb_.verbInfo.attributes, 'type' ) ) { 
			fb_.type = fb_.verbInfo.attributes.type;
			if (not listfindnocase( 'inline,outline,comment,debug', fb_.type ) ) 
				fb_throw(	"fusebox.badGrammar.invalidAttributeValue",
	                        "Attribute has invalid value",
	                        "The attribute 'type' must be one of the these values 'inline,outline,comment,debug' for 'timer' verb in fuseaction #fb_.verbInfo.circuit#.#fb_.verbInfo.fuseaction#.");	
		}	
								
		fb_appendLine('<cftimer type="#fb_.type#"#fb_.label#>');
	} else {
		// fb_.verbInfo.executionMode is "end"
		fb_appendLine("</cftimer>");
	}	
</cfscript>