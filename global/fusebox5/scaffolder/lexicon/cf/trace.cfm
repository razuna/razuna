<cfscript>
	// Author: Qasim Rasheed (qasimrasheed@gmail.com)
	// example custom verb that compiles to a <cftrace> tag
	// usage:
	// 1. add the lexicon declaration to your circuit file:
	//    <circuit xmlns:cf="cf/">
	// 2. use the verb in a fuseaction:
	//    <cf:trace text="Just testing this tag" />
	//	
	// For details on the use of <cftrace> tag. please refer to the documentation.
	// http://livedocs.macromedia.com/coldfusion/7/htmldocs/00000345.htm
	//
	// how this works:
	// a. validate the attributes passed in (fb_.verbInfo.attributes) along with checking for valid value for attributes.
	// b. in start mode, generate the required CFML
	// c. in end mode, add the closing cftrace tag.
	//
	
	if (fb_.verbInfo.executionMode is "start") {
		fb_.abort = 'false';
		fb_.category = '';
		fb_.inline = 'false';
		fb_.text = '';
		fb_.type = 'Information';
		fb_.var = '';
		
		if ( structKeyExists(fb_.verbInfo.attributes, 'category' ) ) 
			fb_.category = ' category="#fb_.verbInfo.attributes.category#"';
		
		if ( structKeyExists( fb_.verbInfo.attributes, 'type' ) ){ 
			fb_.type = fb_.verbInfo.attributes.type;
			if (not listfindnocase( 'Information,Warning,Error,Fatal Information', fb_.type ) ) 
				fb_throw(	"fusebox.badGrammar.invalidAttributeValue",
	                        "Attribute has invalid value",
	                        "The attribute 'type' must be one of the these values 'Information,Warning,Error,Fatal Information' for 'trace' verb in fuseaction #fb_.verbInfo.circuit#.#fb_.verbInfo.fuseaction#.");	
		}	
		
		if ( structKeyExists( fb_.verbInfo.attributes, 'text' ) ) 
			fb_.text = ' text="#fb_.verbInfo.attributes.text#"';
		
		if ( structKeyExists( fb_.verbInfo.attributes, 'var' ) ) 
			fb_.var = ' var="#fb_.verbInfo.attributes.var#"';
							
		fb_appendLine('<cftrace abort="#fb_.abort#" inline="#fb_.inline#" type="#fb_.type#"#fb_.category##fb_.var##fb_.text#>');
	} else {
	// fb_.verbInfo.executionMode is "end"
		fb_appendLine("</cftrace>");
	}	
</cfscript>