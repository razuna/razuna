/*
	BlueDragonHello.cpp
	
	A simple C++ CFX tag.
*/

#include "cfx.h"

extern "C"
#ifdef _WINDOWS
__declspec(dllexport)
#endif
void ProcessTagRequest( CCFXRequest* pRequest ) 
{
	try
	{
		// Write output back to the user here...
		pRequest->Write( "<h3>Hello! Welcome to BlueDragon from a C++ CFX tag.</h3>" );
	}

	// Catch Cold Fusion exceptions & re-raise them
	catch( CCFXException* e )
	{
		pRequest->ReThrowException( e ) ;
	}
	
	// Catch ALL other exceptions and throw them as 
	// Cold Fusion exceptions (DO NOT REMOVE! -- 
	// this prevents the server from crashing in 
	// case of an unexpected exception)
	catch( ... )
	{
		pRequest->ThrowException( 
			"Error occurred in tag CFX_TestTag",
			"Unexpected error occurred while processing tag." ) ;
	}
}
