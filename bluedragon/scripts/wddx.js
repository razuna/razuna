///////////////////////////////////////////////////////////////////////////
//
//	Filename:		wddx.js
//
//	Authors:		Simeon Simeonov (simeons@allaire.com)
//					Nate Weiss (nweiss@icesinc.com)
//
//	Last Modified:	February 2, 2001
//
///////////////////////////////////////////////////////////////////////////


///////////////////////////////////////////////////////////////////////////
//
//	WddxSerializer
//
///////////////////////////////////////////////////////////////////////////


///////////////////////////////////////////////////////////////////////////
// 	serializeValue() serializes any value that can be serialized
//	returns true/false
function wddxSerializer_serializeValue(obj)
{
	var bSuccess = true;
	var val;

	if (obj == null)
	{
		// Null value
		this.write("<null/>");
	}
	else if (typeof(val = obj.valueOf()) == "string")
	{
		// String value
		this.serializeString(val);
	}
	else if (typeof(val = obj.valueOf()) == "number")
	{
		// Distinguish between numbers and date-time values

		if (
			typeof(obj.getTimezoneOffset) == "function" &&
			typeof(obj.toGMTString) == "function")
		{
			// Possible Date
			// Note: getYear() fix is from David Flanagan's 
			// "JS: The Definitive Guide". This code is Y2K safe.
			this.write("<dateTime>" + 
				(obj.getYear() < 1000 ? 1900+obj.getYear() : obj.getYear()) + "-" + (obj.getMonth() + 1) + "-" + obj.getDate() +
				"T" + obj.getHours() + ":" + obj.getMinutes() + ":" + obj.getSeconds());
            if (this.useTimezoneInfo)
            {
            	this.write(this.timezoneString);
            }
            this.write("</dateTime>");
		}
		else
		{
			// Number value
			this.write("<number>" + val + "</number>");
		}
	}
	else if (typeof(val = obj.valueOf()) == "boolean")
	{
		// Boolean value
		this.write("<boolean value='" + val + "'/>");
	}
	else if (typeof(obj) == "object")
	{
		if (typeof(obj.wddxSerialize) == "function")
		{
			// Object knows how to serialize itself
			bSuccess = obj.wddxSerialize(this);
		}
		else if (
			typeof(obj.join) == "function" &&
			typeof(obj.reverse) == "function" &&
			typeof(obj.sort) == "function" &&
			typeof(obj.length) == "number")
		{
			// Possible Array
			this.write("<array length='" + obj.length + "'>");
			for (var i = 0; bSuccess && i < obj.length; ++i)
			{
				bSuccess = this.serializeValue(obj[i]);
			}
			this.write("</array>");
		}
		else
		{
			// Some generic object; treat it as a structure

			// Use the wddxSerializationType property as a guide as to its type			
			if (typeof(obj.wddxSerializationType) == 'string')
			{              
				this.write('<struct type="'+ obj.wddxSerializationType +'">')
			}  
			else
			{                                                       
				this.write("<struct>");
			}
						
			for (var prop in obj)
			{  
				if (prop != 'wddxSerializationType')
				{                          
				    bSuccess = this.serializeVariable(prop, obj[prop]);
					if (! bSuccess)
					{
						break;
					}
				}
			}
			
			this.write("</struct>");
		}
	}
	else
	{
		// Error: undefined values or functions
		bSuccess = false;
	}

	// Successful serialization
	return bSuccess;
}



///////////////////////////////////////////////////////////////////////////
// serializeAttr() serializes an attribute (such as a var tag) using JavaScript 
// functionality available in NS 3.0 and above
function wddxSerializer_serializeAttr(s)
{
	for (var i = 0; i < s.length; ++i)
    {
    	this.write(this.at[s.charAt(i)]);
    }
}


///////////////////////////////////////////////////////////////////////////
// serializeAttrOld() serializes a string using JavaScript functionality
// available in IE 3.0. We don't support special characters for IE3, so
// just throw the unencoded text and hope for the best
function wddxSerializer_serializeAttrOld(s)
{
	this.write(s);
}


///////////////////////////////////////////////////////////////////////////
// serializeString() serializes a string using JavaScript functionality
// available in NS 3.0 and above
function wddxSerializer_serializeString(s)
{
	this.write("<string>");
	for (var i = 0; i < s.length; ++i)
    {
		if (s.charCodeAt(i) > 255) 
			this.write(s.charAt(i));
		else
    	    this.write(this.et[s.charAt(i)]);
    }
	this.write("</string>");
}


///////////////////////////////////////////////////////////////////////////
// serializeStringOld() serializes a string using JavaScript functionality
// available in IE 3.0
function wddxSerializer_serializeStringOld(s)
{
	this.write("<string><![CDATA[");
	
	pos = s.indexOf("]]>");
	if (pos != -1)
	{
		startPos = 0;
		while (pos != -1)
		{
			this.write(s.substring(startPos, pos) + "]]>]]&gt;<![CDATA[");
			
			startPos = pos + 3;
			if (startPos < s.length)
			{
				pos = s.indexOf("]]>", startPos);
			}
			else
			{
				// Work around bug in indexOf()
				// "" will be returned instead of -1 if startPos > length
				pos = -1;
			}                               
		}
		this.write(s.substring(startPos, s.length));
	}
	else
	{
		this.write(s);
	}
			
	this.write("]]></string>");
}


///////////////////////////////////////////////////////////////////////////
// serializeVariable() serializes a property of a structure
// returns true/false
function wddxSerializer_serializeVariable(name, obj)
{
	var bSuccess = true;
	
	if (typeof(obj) != "function")
	{
		this.write("<var name='");
		this.preserveVarCase ? this.serializeAttr(name) : this.serializeAttr(name.toLowerCase());
		this.write("'>");

		bSuccess = this.serializeValue(obj);
		this.write("</var>");
	}

	return bSuccess;
}


///////////////////////////////////////////////////////////////////////////
// write() appends text to the wddxPacket buffer
function wddxSerializer_write(str)
{
	this.wddxPacket[this.wddxPacket.length] = str;
}


///////////////////////////////////////////////////////////////////////////
// writeOld() appends text to the wddxPacket buffer using IE 3.0 (JS 1.0)
// functionality. Unfortunately, the += operator has quadratic complexity
// which will cause slowdowns for large packets.
function wddxSerializer_writeOld(str)
{
	this.wddxPacket += str;
}


///////////////////////////////////////////////////////////////////////////
// initPacket() initializes the WDDX packet
function wddxSerializer_initPacket()
{
	this.wddxPacket = new Array();
}


///////////////////////////////////////////////////////////////////////////
// initPacketOld() initializes the WDDX packet for use with IE 3.0 (JS 1.0)
function wddxSerializer_initPacketOld()
{
	this.wddxPacket = "";
}


///////////////////////////////////////////////////////////////////////////
// extractPacket() extracts the WDDX packet as a string
function wddxSerializer_extractPacket()
{
	return this.wddxPacket.join("");
}


///////////////////////////////////////////////////////////////////////////
// extractPacketOld() extracts the WDDX packet as a string (IE 3.0/JS 1.0)
function wddxSerializer_extractPacketOld()
{
	return this.wddxPacket;
}


///////////////////////////////////////////////////////////////////////////
// serialize() creates a WDDX packet for a given object
// returns the packet on success or null on failure
function wddxSerializer_serialize(rootObj)
{
	this.initPacket();

	this.write("<wddxPacket version='1.0'><header/><data>");
	var bSuccess = this.serializeValue(rootObj);
	this.write("</data></wddxPacket>");

	if (bSuccess)
	{
		return this.extractPacket();
	}
	else
	{	
		return null;
	}
}


///////////////////////////////////////////////////////////////////////////
// WddxSerializer() binds the function properties of the object
function WddxSerializer()
{
	// Compatibility section
	if (navigator.appVersion != "" && navigator.appVersion.indexOf("MSIE 3.") == -1)
	{
    	// Character encoding table
        
    	// Encoding table for strings (CDATA)   
        var et = new Array();

    	// Numbers to characters table and 
    	// characters to numbers table
        var n2c = new Array();
        var c2n = new Array();
    
		// Encoding table for attributes (i.e. var=str)
		var at = new Array();

        for (var i = 0; i < 256; ++i)
        {
        	// Build a character from octal code
        	var d1 = Math.floor(i/64);
        	var d2 = Math.floor((i%64)/8);
        	var d3 = i%8;
        	var c = eval("\"\\" + d1.toString(10) + d2.toString(10) + d3.toString(10) + "\"");
    
    		// Modify character-code conversion tables        
        	n2c[i] = c;
            c2n[c] = i; 
            
    		// Modify encoding table
    		if (i < 32 && i != 9 && i != 10 && i != 13)
            {
            	// Control characters that are not tabs, newlines, and carriage returns
                
            	// Create a two-character hex code representation
            	var hex = i.toString(16);
                if (hex.length == 1)
                {
                	hex = "0" + hex;
                }
                
    	    	et[n2c[i]] = "<char code='" + hex + "'/>";

				// strip control chars from inside attrs
				at[n2c[i]] = "";

            }
            else if (i < 128)
            {
            	// Low characters that are not special control characters
    	    	et[n2c[i]] = n2c[i];

				// attr table
				at[n2c[i]] = n2c[i];
            }
            else
            {
            	// High characters
    	    	et[n2c[i]] = "&#x" + i.toString(16) + ";";
				at[n2c[i]] = "&#x" + i.toString(16) + ";";
            }
        }    
    
    	// Special escapes for CDATA encoding
        et["<"] = "&lt;";
        et[">"] = "&gt;";
        et["&"] = "&amp;";

		// Special escapes for attr encoding
		at["<"] = "&lt;";
        at[">"] = "&gt;";
        at["&"] = "&amp;";
		at["'"] = "&apos;";
		at["\""] = "&quot;";
		        
    	// Store tables
        this.n2c = n2c;
        this.c2n = c2n;
        this.et = et;    
		this.at = at;
        
   		// The browser is not MSIE 3.x
		this.serializeString = wddxSerializer_serializeString;
		this.serializeAttr = wddxSerializer_serializeAttr;
		this.write = wddxSerializer_write;
		this.initPacket = wddxSerializer_initPacket;
		this.extractPacket = wddxSerializer_extractPacket;
	}
	else
	{
		// The browser is most likely MSIE 3.x, it is NS 2.0 compatible
		this.serializeString = wddxSerializer_serializeStringOld;
		this.serializeAttr = wddxSerializer_serializeAttrOld;
		this.write = wddxSerializer_writeOld;
		this.initPacket = wddxSerializer_initPacketOld;
		this.extractPacket = wddxSerializer_extractPacketOld;
	}
    
	// Setup timezone information
    
    var tzOffset = (new Date()).getTimezoneOffset();

	// Invert timezone offset to convert local time to UTC time
    if (tzOffset >= 0)
    {
    	this.timezoneString = '-';
    }
    else
    {
    	this.timezoneString = '+';
    }
    this.timezoneString += Math.floor(Math.abs(tzOffset) / 60) + ":" + (Math.abs(tzOffset) % 60);
    
	// Common properties
	this.preserveVarCase = false;
    this.useTimezoneInfo = true;

    // Common functions
	this.serialize = wddxSerializer_serialize;
	this.serializeValue = wddxSerializer_serializeValue;
	this.serializeVariable = wddxSerializer_serializeVariable;
}


///////////////////////////////////////////////////////////////////////////
//
//	WddxRecordset
//
///////////////////////////////////////////////////////////////////////////


///////////////////////////////////////////////////////////////////////////
// isColumn(name) returns true/false based on whether this is a column name
function wddxRecordset_isColumn(name)
{
	// Columns must be objects
	// WddxRecordset extensions might use properties prefixed with 
	// _private_ and these will not be treated as columns
	return (typeof(this[name]) == "object" && 
		    name.indexOf("_private_") == -1);
}


///////////////////////////////////////////////////////////////////////////
// getRowCount() returns the number of rows in the recordset
function wddxRecordset_getRowCount()
{
	var nRowCount = 0;
	for (var col in this)
	{
		if (this.isColumn(col))
		{
			nRowCount = this[col].length;
			break;
		}
	}
	return nRowCount;
}


///////////////////////////////////////////////////////////////////////////
// addColumn(name) adds a column with that name and length == getRowCount()
function wddxRecordset_addColumn(name)
{
	var nLen = this.getRowCount();
	var colValue = new Array(nLen);
	for (var i = 0; i < nLen; ++i)
	{
		colValue[i] = null;
	}
	this[this.preserveFieldCase ? name : name.toLowerCase()] = colValue;
}


///////////////////////////////////////////////////////////////////////////
// addRows() adds n rows to all columns of the recordset
function wddxRecordset_addRows(n)
{
	for (var col in this)
	{
		if (this.isColumn(col))
		{
			var nLen = this[col].length;
			for (var i = nLen; i < nLen + n; ++i)
			{
				this[col][i] = null;
			}
		}
	}
}


///////////////////////////////////////////////////////////////////////////
// getField() returns the element in a given (row, col) position
function wddxRecordset_getField(row, col)
{
	return this[this.preserveFieldCase ? col : col.toLowerCase()][row];
}


///////////////////////////////////////////////////////////////////////////
// setField() sets the element in a given (row, col) position to value
function wddxRecordset_setField(row, col, value)
{
	this[this.preserveFieldCase ? col : col.toLowerCase()][row] = value;
}


///////////////////////////////////////////////////////////////////////////
// wddxSerialize() serializes a recordset
// returns true/false
function wddxRecordset_wddxSerialize(serializer)
{
	// Create an array and a list of column names
	var colNamesList = "";
	var colNames = new Array();
	var i = 0;
	for (var col in this)
	{
		if (this.isColumn(col))
		{
			colNames[i++] = col;

            if (colNamesList.length > 0)
			{
				colNamesList += ",";
			}
			colNamesList += col;			
		}
	}
	
	var nRows = this.getRowCount();
	
	serializer.write("<recordset rowCount='" + nRows + "' fieldNames='" + colNamesList + "'>");
	
	var bSuccess = true;
	for (i = 0; bSuccess && i < colNames.length; i++)
	{
		var name = colNames[i];
		serializer.write("<field name='" + name + "'>");
		
		for (var row = 0; bSuccess && row < nRows; row++)
		{
			bSuccess = serializer.serializeValue(this[name][row]);
		}
		
		serializer.write("</field>");
	}
	
	serializer.write("</recordset>");
	
	return bSuccess;
}


///////////////////////////////////////////////////////////////////////////
// dump(escapeStrings) returns an HTML table with the recordset data
// It is a convenient routine for debugging and testing recordsets
// The boolean parameter escapeStrings determines whether the <>& 
// characters in string values are escaped as &lt;&gt;&amp;
function wddxRecordset_dump(escapeStrings)
{
	// Get row count
	var nRows = this.getRowCount();
	
	// Determine column names
	var colNames = new Array();
	var i = 0;
	for (var col in this)
	{
		if (typeof(this[col]) == "object")
		{
			colNames[i++] = col;
		}
	}

    // Build table headers	
	var o = "<table border=1><tr><td><b>RowNumber</b></td>";
	for (i = 0; i < colNames.length; ++i)
	{
		o += "<td><b>" + colNames[i] + "</b></td>";
	}
	o += "</tr>";
	
	// Build data cells
	for (var row = 0; row < nRows; ++row)
	{
		o += "<tr><td>" + row + "</td>";
		for (i = 0; i < colNames.length; ++i)
		{
        	var elem = this.getField(row, colNames[i]);
            if (escapeStrings && typeof(elem) == "string")
            {
            	var str = "";
            	for (var j = 0; j < elem.length; ++j)
                {
                	var ch = elem.charAt(j);
                    if (ch == '<')
                    {
                    	str += "&lt;";
                    }
                    else if (ch == '>')
                    {
                    	str += "&gt;";
                    }
                    else if (ch == '&')
                    {
                    	str += "&amp;";
                    }
                    else
                    {
                    	str += ch;
                    }
                }            
				o += ("<td>" + str + "</td>");
            }
            else
            {
				o += ("<td>" + elem + "</td>");
            }
		}
		o += "</tr>";
	}

	// Close table
	o += "</table>";

	// Return HTML recordset dump
	return o;	
}


///////////////////////////////////////////////////////////////////////////
// WddxRecordset([flagPreserveFieldCase]) creates an empty recordset.
// WddxRecordset(columns [, flagPreserveFieldCase]) creates a recordset 
//   with a given set of columns provided as an array of strings.
// WddxRecordset(columns, rows [, flagPreserveFieldCase]) creates a 
//   recordset with these columns and some number of rows.
// In all cases, flagPreserveFieldCase determines whether the exact case
//   of field names is preserved. If omitted, the default value is false
//   which means that all field names will be lowercased.
function WddxRecordset()
{
	// Add default properties
	this.preserveFieldCase = false;

	// Add extensions
	if (typeof(wddxRecordsetExtensions) == "object")
	{
		for (var prop in wddxRecordsetExtensions)
		{
			// Hook-up method to WddxRecordset object
			this[prop] = wddxRecordsetExtensions[prop]
		}
	}

	// Add built-in methods
	this.getRowCount = wddxRecordset_getRowCount;
	this.addColumn = wddxRecordset_addColumn;
	this.addRows = wddxRecordset_addRows;
	this.isColumn = wddxRecordset_isColumn;
	this.getField = wddxRecordset_getField;
	this.setField = wddxRecordset_setField;
	this.wddxSerialize = wddxRecordset_wddxSerialize;
	this.dump = wddxRecordset_dump;
	
	// Perfom any needed initialization
	if (WddxRecordset.arguments.length > 0)
	{
		if (typeof(val = WddxRecordset.arguments[0].valueOf()) == "boolean")
		{
			// Case preservation flag is provided as 1st argument
			this.preserveFieldCase = WddxRecordset.arguments[0];
		}
		else
		{
			// First argument is the array of column names
			var cols = WddxRecordset.arguments[0];

			// Second argument could be the length or the preserve case flag
			var nLen = 0;
			if (WddxRecordset.arguments.length > 1)
			{
				if (typeof(val = WddxRecordset.arguments[1].valueOf()) == "boolean")
				{
					// Case preservation flag is provided as 2nd argument
					this.preserveFieldCase = WddxRecordset.arguments[1];
				}
				else
				{
					// Explicitly specified recordset length
					nLen = WddxRecordset.arguments[1];

					if (WddxRecordset.arguments.length > 2)
					{
						// Case preservation flag is provided as 3rd argument
						this.preserveFieldCase = WddxRecordset.arguments[2];
					}
				}
			}
			
			for (var i = 0; i < cols.length; ++i)
			{
 				var colValue = new Array(nLen);
				for (var j = 0; j < nLen; ++j)
				{
					colValue[j] = null;
				}
			
				this[this.preserveFieldCase ? cols[i] : cols[i].toLowerCase()] = colValue;
			}
		}
	}
}


///////////////////////////////////////////////////////////////////////////
//
// WddxRecordset extensions
//
// The WddxRecordset class has been designed with extensibility in mind.
//
// Developers can add new properties to the object and as long as their
// names are prefixed with _private_ the WDDX serialization function of
// WddxRecordset will not treat them as recordset columns.
//
// Developers can create new methods for the class outside this file as
// long as they make a call to registerWddxRecordsetExtension() with the
// name of the method and the function object that implements the method.
// The WddxRecordset constructor will automatically register all these
// methods with instances of the class.
//
// Example:
//
// If I want to add a new WddxRecordset method called addOneRow() I can
// do the following:
//
// - create the method implementation
//
// function wddxRecordset_addOneRow()
// {
// 	this.addRows(1);
// }
//
// - call registerWddxRecordsetExtension() 
//
// registerWddxRecordsetExtension("addOneRow", wddxRecordset_addOneRow);
//
// - use the new function
//
// rs = new WddxRecordset();
// rs.addOneRow();
//
///////////////////////////////////////////////////////////////////////////


///////////////////////////////////////////////////////////////////////////
// registerWddxRecordsetExtension(name, func) can be used to extend 
// functionality by registering functions that should be added as methods 
// to WddxRecordset instances.
function registerWddxRecordsetExtension(name, func)
{
	// Perform simple validation of arguments
	if (typeof(name) == "string" && typeof(func) == "function")
	{
		// Guarantee existence of wddxRecordsetExtensions object
		if (typeof(wddxRecordsetExtensions) != "object")
		{
			// Create wddxRecordsetExtensions instance
			wddxRecordsetExtensions = new Object();
		}
		
		// Register extension; override an existing one
		wddxRecordsetExtensions[name] = func;
	}
}



///////////////////////////////////////////////////////////////////////////
//
// WddxBinary
//
///////////////////////////////////////////////////////////////////////////


///////////////////////////////////////////////////////////////////////////
// wddxSerialize() serializes a binary value
// returns true/false
function wddxBinary_wddxSerialize(serializer) 
{
	serializer.write(
		"<binary encoding='" + this.encoding + "'>" + this.data + "</binary>");
	return true;
}


///////////////////////////////////////////////////////////////////////////
// WddxBinary() constructs an empty binary value
// WddxBinary(base64Data) constructs a binary value from base64 encoded data
// WddxBinary(data, encoding) constructs a binary value from encoded data
function WddxBinary(data, encoding)
{
	this.data = data != null ? data : "";
	this.encoding = encoding != null ? encoding : "base64";

	// Custom serialization mechanism
	this.wddxSerialize = wddxBinary_wddxSerialize;
}



