
export function isNumeric(num){
    return !isNaN(num)
  }
  
  export function isNotEmpty(text){
      return text != ""
  }
  
  export function isEmpty(text){
      return text == ""
  }
  
  export function isValidJson (jsonString){
      try {
          JSON.parse(jsonString);
          return true
      }
      catch (e) {console.log("Error parsing JSON " + e);}
      return false;
  };