/** 
  * A module to create unique hashes out of news article title strings
  * [modified from original author]
  *
  * @module hash-code
  * @author esmiralha, [Stack Overflow: Generate a hash from string in JavaScript]{@link http://stackoverflow.com/a/7616484}
*/
var hashCode = exports;

hashCode.hash = function(str) {
  var hash = 0, i, chr, len;
  if (str.length == 0) return hash;
  for (i = 0, len = str.length; i < len; i++) {
    chr   = str.charCodeAt(i);
    hash  = ((hash << 5) - hash) + chr;
    hash |= 0; // Convert to 32bit integer
  }
  return String(hash);
};
