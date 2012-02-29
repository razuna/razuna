var cfform_isvalid;
var cfform_error_message = "";
var cfform_invalid_fields = new Object();
var cfform_submit_status= new Array();

function tf_validate_boolean( elementName ){
  var the_value = tf_trim( elementName.value.toLowerCase() );
	if ( the_value.length == 0 )
	  return true;

  if ( the_value == "true" || the_value == "yes" || tf_number(the_value) 
	      || the_value == "false" || the_value == "no" )
	  return true;
	else
	  return false;
}

function tf_validate_social_security_number( elementName ){
	return tf_validate_regular_expression( elementName, /^[0-9]{3}[\- ][0-9]{2}[\- ][0-9]{4}$/ );
}
		
function tf_validate_uuid( elementName ){
	return tf_validate_regular_expression( elementName, /[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{16}/ );
}
	
function tf_validate_guid( elementName ){
	return tf_validate_regular_expression( elementName, /[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/ );
}

function tf_validate_url( elementName ){                                                                                                                                          
	return tf_validate_regular_expression( elementName, /^((file:\/\/([a-z0-9-]+(\.[a-z0-9-]+)*)?\/(([0-9a-z\?:@&=$-_\.+])|(%[0-9a-f]+)+)*(\/(([0-9a-z\?:@&=$-_\.+])|(%[0-9a-f]+)+)*)*)|((http|https|ftp)\:\/\/([a-z0-9]*:[a-z0-9]*(@))?[a-z0-9-\.]+(\.[a-z]{2,3})?(:[a-z0-9]*)?\/?([a-z0-9-\._\?\,\'\/\+&%\$#\=~])*)|((mailto)\:((?:(?:(?:[a-z0-9][\.\-\+_]?)*)[a-z0-9])+)\@((?:(?:(?:[a-z0-9][\.\-_]?){0,62})[a-z0-9])+)\.([a-z0-9]{2,6})([a-z0-9-\._\?\,\'\/\+&%\$#\=~])*)|((news)\:[a-z0-9\.]*))$/ );
}

function tf_validate_email( elementName ){
  return tf_validate_regular_expression( elementName, /^((?:(?:(?:[a-zA-Z0-9][\.\-\+_]?)*)[a-zA-Z0-9])+)\@((?:(?:(?:[a-zA-Z0-9][\.\-_]?){0,62})[a-zA-Z0-9])+)\.([a-zA-Z0-9]{2,6})$/ );
}

function tf_validate_telephone( elementName ){
	return tf_validate_regular_expression( elementName, /^((1[ \.-]?)?(\(?[2-9][0-9]{2}\)?))?[ \.\-]?[2-9][0-9]{2}[ \.\-]?[0-9]{4}( x?[0-9]{1,5})?$/ );
}

function tf_validate_zipcode( elementName ){
	return tf_validate_regular_expression( elementName, /^[0-9]{5}([\- ][0-9]{4})?$/ );
}
	  
function tf_validate_noblanks( elementName ){
  var the_value = elementName.value;
  if ( the_value.length == 0 )
    return true;
  return tf_trim( the_value ).length != 0;
}
	
function tf_validate_date( elementName, iseuro ){
  var the_value = tf_trim( elementName.value.toLowerCase() );
	if ( the_value.length == 0 )
	  return true;
    separator = '/';
    separator_indx = the_value.indexOf( separator );
    if (separator_indx == -1){
      separator = '.';
      separator_indx = the_value.indexOf( separator );
    }
    if (separator_indx == -1){
      separator = '-';
      separator_indx = the_value.indexOf( separator );
    }
    if (separator_indx == -1 || separator_indx == the_value.length)
     return false;

    if ( separator_indx == 4 ){ // yyyy-mm-dd format
      year = the_value.substring(0, separator_indx);
      separator_indx = the_value.indexOf( separator, separator_indx+1 );
      if ( separator_indx == -1 || separator_indx == the_value.length )
        return false;
      month = the_value.substring((year.length + 1), separator_indx);
      day = the_value.substring(separator_indx + 1);
    }else{
      if ( iseuro ){
        day = the_value.substring(0, separator_indx);
      }else{
        month = the_value.substring(0, separator_indx);
      }
      separator_indx = the_value.indexOf( separator, separator_indx+1 );
      if ( separator_indx == -1 || separator_indx == the_value.length )
        return false;
      if ( iseuro ){
        month = the_value.substring((day.length + 1), separator_indx);
      }else{
        day = the_value.substring((month.length + 1), separator_indx);
      }
      year = the_value.substring(separator_indx + 1);
    }

    if (!tf_integer(month))
      return false;
    else if (!tf_checkrange(month, 1, 12))
      return false;
    else if (!tf_integer(year))
      return false;
    else if (!tf_checkrange(year, 0, null))
      return false;
    else if (!tf_integer(day))
      return false;
    else if (!tf_checkday(year, month, day))
      return false;
    else
     return true;
}

function tf_validate_time( elementName ){
	return tf_validate_regular_expression( elementName, /^(([0-1]?[0-9]|[2][0-3]):([0-5]?[0-9])(:[0-5]?[0-9])?)[ \t]?([ap]m)?$/ );
}
		  
function tf_element_has_value(elementName, elementType){
  if (elementType == '_TEXT' || elementType == '_PASSWORD' || elementType == '_FILE' || elementType == '_TEXTAREA' || elementType == '_TREE'){
    if (elementName.value.length == 0) 
      return false;
    else 
      return true;
  } else if (elementType == '_SELECT'){
    for (i=0; i < elementName.length; i++){
      if (elementName.options[i].selected)
        return true;
    }
    return false;  
  } else if (elementType == '_RADIO' || elementType == '_CHECKBOX'){
    if ( elementName.length ){
      for (i=0; i < elementName.length; i++){
        if (elementName[i].checked)
          return true;
      }
      return false;
    }else{
      return elementName.checked;
    }
  }else{
    return true;
  }
}
		  
function tf_validate_eurodate( elementName ){
  return tf_validate_date( elementName, true );
}

function tf_validate_usdate( elementName ){
  return tf_validate_date( elementName, false );
}

function tf_validate_integer( elementName ){
  return tf_integer( elementName.value )
}
 
function tf_validate_numeric( elementName ){
  return tf_number( elementName.value  );
}		  

function tf_validate_float( elementName ){
  return tf_number( elementName.value  );
}  
		  
function tf_validate_creditcard( elementName ){

  var whiteSpace = ' -';
  var creditcardString = '';
  var temp;
  var the_value = elementName.value;
  if (the_value.length == 0)
   return true;

  for (var x = 0; x < the_value.length; x++){
    temp = whiteSpace.indexOf(the_value.charAt(x))
    if (temp < 0)
     creditcardString += the_value.substring(x, (x + 1));
  }

  if (creditcardString.length == 0)
   return false;
  
  if (creditcardString.charAt(0) == '+')
   return false;

  if (!tf_integer(creditcardString))
   return false;

  var doubledigit = creditcardString.length % 2 == 1 ? false : true;
  var checkdigit = 0;
  var tempdigit;

  for (var i = 0; i < creditcardString.length; i++)  {
   tempdigit = eval(creditcardString.charAt(i))

  if (doubledigit){
   tempdigit *= 2;
   checkdigit += (tempdigit % 10);

   if ((tempdigit / 10) >= 1.0){
    checkdigit++;
   }
 
   doubledigit = false;
  }else{
   checkdigit += tempdigit;
   doubledigit = true;
  }
 }  
  return (checkdigit % 10) == 0 ? true : false;
}
		  
function tf_validate_regular_expression( elementName, re ){
  var the_value = tf_trim( elementName.value.toLowerCase() );
	if ( the_value.length == 0 )
	  return true;
  return re.test( the_value );

}

function tf_validate_maxlength( elementName, maxlen ){
  return elementName.value.length <= maxlen;
}

function tf_number( theString ){
  if (theString.length == 0) return true;

  var start = ' .+-0123456789';
  var number = ' .0123456789';
  var temp = start.indexOf(theString.charAt(0));
  var decimal = false;
  var trailing = false;
  var digits = false;

  if (temp == 1)
    decimal = true;
  else if (temp < 1)
    return false;

  for (var x = 1; x < theString.length; x++){
    temp = number.indexOf(theString.charAt(x))
    if (temp < 0)
      return false;
    else if (temp == 1){
      if (decimal)
        return false;
      else
        decimal = true;
    } else if (temp == 0){
      if (decimal || digits)
        trailing = true;
    }else if (trailing)
      return false;
    else
      digits = true;
  }
  return true;
}

function tf_integer( theString ){
  if (theString.length == 0) return true;

  var decimalPoint = '.';
  var temp = theString.indexOf(decimalPoint);
  if (temp < 1)
    return tf_number( theString );
  else
    return false;
}

function tf_validate_range(elementName, minimum, maximum){
  var the_value = tf_trim( elementName.value.toLowerCase() );
	if ( the_value.length == 0 )
	  return true;
  return tf_checkrange( the_value, minimum, maximum );
}

function tf_checkrange(the_value, minimum, maximum){
  if (the_value.length == 0)  return true;
  if (!tf_number(the_value))  
    return false;
  else
    return (tf_numberrange((eval(the_value)), minimum, maximum));
}

function tf_numberrange(theNumber, minimum, maximum){
  if (minimum != null){
    if (theNumber < minimum)
    return false;
  }
  if (maximum != null){
    if (theNumber > maximum)
    return false;
  }
  return true;
}

function tf_checkday(year, month, day){
  maximum = 31;
  if (month == 4 || month == 6 || month == 9 || month == 11)
    maximum = 30;
  else if (month == 2){
    if (year % 4 > 0)
      maximum =28;
    else if (year % 100 == 0 && year % 400 > 0)
      maximum = 28;
    else
      maximum = 29;
  }
  return tf_checkrange(day, 1, maximum);
}

function tf_trim( str ){
  return str.replace(/^\s*|\s*$/g,'');
}

function tf_setFormParam( formName, inputName, inputValue ){
  var strObjName = 'document.' + formName + '.' + inputName;
  var obj = eval( strObjName );
  obj.value = inputValue;
  return true;
}

function tf_on_error( theForm, elementName, elementValue, errMessage ){
  if ( cfform_invalid_fields[elementName] == null ){
    cfform_isvalid = false;
    cfform_invalid_fields[elementName] = true;
    cfform_error_message += errMessage + "\n";
  }
  return true;
}

