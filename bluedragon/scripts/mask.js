var __mask_oldValue = "";
var __mask_mask = "";

function _maskFocus( _field, _mask ){
  oldValue = _field.value;
  __mask_mask = _mask;
  _maskCheck(_field);
}

function _maskCheck( field ){
  var fieldValue = field.value;
 
  if ( fieldValue.length > __mask_mask.length ){ fieldValue = fieldValue.substring(0,__mask_mask.length); }
 
  var newValue = "";
  for ( var x=0; x < __mask_mask.length; x++ ){
    if ( x < fieldValue.length ){
      if ( !_maskIsMask( __mask_mask.charAt(x) ) ) {
        newValue += __mask_mask.charAt(x);
      } else if ( _maskIsMask( __mask_mask.charAt(x) ) && _maskIsValidChar( fieldValue.charAt(x), __mask_mask.charAt(x) ) ){
        newValue += fieldValue.charAt(x);
      } else {
        newValue = __mask_oldValue;
        break;
      }
    }else{
      if ( !_maskIsMask( __mask_mask.charAt(x) ) ) { newValue += __mask_mask.charAt(x); }else{ break; }
    }
  }

  __mask_oldValue = newValue;
  field.value = newValue;
  return true;
}

function _maskIsValidChar( fieldChar, maskChar ){
  if ( maskChar == '9' && fieldChar >= '0' && fieldChar <= '9'){ return true; }
  else if ( maskChar == '?' ){ return true; }
  else if ( maskChar == 'A' && fieldChar >= 'a' && fieldChar <= 'z' ){ return true; }
  else if ( maskChar == 'A' && fieldChar >= 'A' && fieldChar <= 'Z' ){ return true; }
  else if ( maskChar == 'X' && fieldChar >= 'a' && fieldChar <= 'z' ){ return true; }
  else if ( maskChar == 'X' && fieldChar >= 'A' && fieldChar <= 'Z' ){ return true; }
  else if ( maskChar == 'X' && fieldChar >= '0' && fieldChar <= '9' ){ return true; }
  return false;
}

function _maskIsMask( maskChar ){ if ( maskChar == '9' || maskChar == 'A' || maskChar == 'X' || maskChar == '?' ){ return true; }else{ return false; } }