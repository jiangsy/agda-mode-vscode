// Generated by BUCKLESCRIPT, PLEASE EDIT WITH CARE
'use strict';

var Mocha$BsMocha = require("bs-mocha/lib/js/src/Mocha.bs.js");
var Assert$BsMocha = require("bs-mocha/lib/js/src/Assert.bs.js");
var QueryIM$AgdaModeVscode = require("../../src/InputMethod/QueryIM.bs.js");

function testQueryIMUpdate(self, input, output, command, param) {
  var result = QueryIM$AgdaModeVscode.update(self, input);
  if (result !== undefined) {
    Assert$BsMocha.equal(undefined, result[0], output);
    if (command !== undefined) {
      return Assert$BsMocha.equal(undefined, result[1], command);
    } else {
      return ;
    }
  } else {
    return Assert$BsMocha.fail("shouldn't be deactivated after \"" + (input + "\""));
  }
}

Mocha$BsMocha.describe("Input Method (Query)")(undefined, undefined, undefined, (function (param) {
        Mocha$BsMocha.describe("Insertion")(undefined, undefined, undefined, (function (param) {
                Mocha$BsMocha.it("should translate \"\bn\" to \"𝕟\"")(undefined, undefined, undefined, (function (param) {
                        var queryIM = QueryIM$AgdaModeVscode.make(undefined);
                        QueryIM$AgdaModeVscode.activate(queryIM, "");
                        testQueryIMUpdate(queryIM, "b", "♭", undefined, undefined);
                        return testQueryIMUpdate(queryIM, "♭n", "𝕟", /* Deactivate */1, undefined);
                      }));
                return Mocha$BsMocha.it("should translate \"garbage \\bn\" to \"garbage 𝕟\"")(undefined, undefined, undefined, (function (param) {
                              var queryIM = QueryIM$AgdaModeVscode.make(undefined);
                              QueryIM$AgdaModeVscode.activate(queryIM, "garbage ");
                              testQueryIMUpdate(queryIM, "garbage b", "garbage ♭", undefined, undefined);
                              return testQueryIMUpdate(queryIM, "garbage ♭n", "garbage 𝕟", /* Deactivate */1, undefined);
                            }));
              }));
        return Mocha$BsMocha.describe("Backspacing")(undefined, undefined, undefined, (function (param) {
                      return Mocha$BsMocha.it("should work just fine")(undefined, undefined, undefined, (function (param) {
                                    var queryIM = QueryIM$AgdaModeVscode.make(undefined);
                                    QueryIM$AgdaModeVscode.activate(queryIM, "");
                                    testQueryIMUpdate(queryIM, "l", "←", undefined, undefined);
                                    testQueryIMUpdate(queryIM, "←a", "←a", undefined, undefined);
                                    testQueryIMUpdate(queryIM, "←am", "←am", undefined, undefined);
                                    testQueryIMUpdate(queryIM, "←amb", "←amb", undefined, undefined);
                                    testQueryIMUpdate(queryIM, "←ambd", "←ambd", undefined, undefined);
                                    testQueryIMUpdate(queryIM, "←ambda", "λ", undefined, undefined);
                                    testQueryIMUpdate(queryIM, "", "lambd", undefined, undefined);
                                    testQueryIMUpdate(queryIM, "lamb", "lamb", undefined, undefined);
                                    testQueryIMUpdate(queryIM, "lambd", "lambd", undefined, undefined);
                                    testQueryIMUpdate(queryIM, "lambda", "λ", undefined, undefined);
                                    testQueryIMUpdate(queryIM, "λb", "λb", undefined, undefined);
                                    testQueryIMUpdate(queryIM, "λba", "λba", undefined, undefined);
                                    return testQueryIMUpdate(queryIM, "λbar", "ƛ", /* Deactivate */1, undefined);
                                  }));
                    }));
      }));

var Assert;

exports.Assert = Assert;
exports.testQueryIMUpdate = testQueryIMUpdate;
/*  Not a pure module */