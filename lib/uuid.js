/**
  * A module to generate a universally unique identifier (UUID), based on timestamp
  * (RFC 4122 v1)
  *
  * @module uuid
  * @requires node-uuid
*/
var uuid = exports;

uuid.generate = function() {
  return require('node-uuid').v1();
};
