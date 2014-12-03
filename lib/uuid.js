/**
  * A module to generate a universally unique identifier (UUID), based on timestamp
  * (RFC 4122 v1)
  *
  * @module uuid
  * @requires node-uuid
*/
var uuid = exports;

/**
  * Generate timestamp-based UUID
  *
  * @method generate
  * @memberof uuid
 */
uuid.generate = function() {
  return require('node-uuid').v1();
};
