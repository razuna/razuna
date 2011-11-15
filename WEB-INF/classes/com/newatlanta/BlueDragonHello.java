/*
	BlueDragonHello.java
	
	A simple Java CFX tag.
*/

package com.newatlanta;

import com.allaire.cfx.*;

public class BlueDragonHello implements CustomTag
{
    public void processRequest( Request request, Response response ) throws Exception
    {
        response.write( "<h3>Hello! Welcome to BlueDragon from a Java CFX tag.</h3>" );
    }
}