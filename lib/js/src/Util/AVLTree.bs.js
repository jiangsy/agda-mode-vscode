// Generated by ReScript, PLEASE EDIT WITH CARE
'use strict';

var Caml_option = require("rescript/lib/js/caml_option.js");
var Core__Option = require("@rescript/core/lib/js/src/Core__Option.bs.js");

var $$Node = {};

function find(self, key) {
  return Core__Option.map(Caml_option.nullable_to_opt(self.find(key)), (function (prim) {
                return prim.getValue();
              }));
}

function max(self) {
  return Core__Option.map(Caml_option.nullable_to_opt(self.max()), (function (prim) {
                return prim.getValue();
              }));
}

function min(self) {
  return Core__Option.map(Caml_option.nullable_to_opt(self.min()), (function (prim) {
                return prim.getValue();
              }));
}

function upperBound(self, key) {
  return Core__Option.map(Caml_option.nullable_to_opt(self.upperBound(key)), (function (prim) {
                return prim.getValue();
              }));
}

function lowerBound(self, key) {
  return Core__Option.map(Caml_option.nullable_to_opt(self.lowerBound(key)), (function (prim) {
                return prim.getValue();
              }));
}

function floor(self, key) {
  return Core__Option.map(Caml_option.nullable_to_opt(self.floor(key)), (function (prim) {
                return prim.getValue();
              }));
}

function ceil(self, key) {
  return Core__Option.map(Caml_option.nullable_to_opt(self.ceil(key)), (function (prim) {
                return prim.getValue();
              }));
}

function toArray(self) {
  var accum = [];
  self.traverseInOrder(function (node) {
        var value = node.getValue();
        accum.push(value);
      });
  return accum;
}

exports.$$Node = $$Node;
exports.find = find;
exports.max = max;
exports.min = min;
exports.upperBound = upperBound;
exports.lowerBound = lowerBound;
exports.floor = floor;
exports.ceil = ceil;
exports.toArray = toArray;
/* No side effect */
