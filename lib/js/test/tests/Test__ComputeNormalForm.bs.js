// Generated by ReScript, PLEASE EDIT WITH CARE
'use strict';

var Curry = require("rescript/lib/js/curry.js");
var Assert = require("assert");
var State$AgdaModeVscode = require("../../src/State.bs.js");
var Test__Util$AgdaModeVscode = require("./Test__Util.bs.js");

describe.skip("agda-mode.compute-normal-form[DefaultCompute]", (function () {
        describe("request to Agda", (function () {
                describe("global", (function () {
                        it("should be responded with the correct answer", (async function () {
                                var ctx = await Test__Util$AgdaModeVscode.AgdaMode.make(undefined, "ComputeNormalForm.agda");
                                var state = await Test__Util$AgdaModeVscode.AgdaMode.load(ctx);
                                var responses = {
                                  contents: []
                                };
                                var responseHandler = async function (response) {
                                  responses.contents.push(response);
                                };
                                await State$AgdaModeVscode.sendRequest(state, responseHandler, {
                                      TAG: "ComputeNormalFormGlobal",
                                      _0: "DefaultCompute",
                                      _1: "Z + S Z",
                                      [Symbol.for("name")]: "ComputeNormalFormGlobal"
                                    });
                                return Curry._3(Assert.deepEqual, responses.contents, [
                                            {
                                              TAG: "Status",
                                              _0: false,
                                              _1: false,
                                              [Symbol.for("name")]: "Status"
                                            },
                                            {
                                              TAG: "DisplayInfo",
                                              _0: {
                                                TAG: "NormalForm",
                                                _0: "S Z",
                                                [Symbol.for("name")]: "NormalForm"
                                              },
                                              [Symbol.for("name")]: "DisplayInfo"
                                            },
                                            "CompleteHighlightingAndMakePromptReappear"
                                          ], undefined);
                              }));
                        it("should be responded with the correct answer", (async function () {
                                var ctx = await Test__Util$AgdaModeVscode.AgdaMode.make(undefined, "ComputeNormalForm.agda");
                                var state = await Test__Util$AgdaModeVscode.AgdaMode.load(ctx);
                                var responses = {
                                  contents: []
                                };
                                var responseHandler = async function (response) {
                                  responses.contents.push(response);
                                };
                                await State$AgdaModeVscode.sendRequest(state, responseHandler, {
                                      TAG: "ComputeNormalFormGlobal",
                                      _0: "DefaultCompute",
                                      _1: "S Z + S Z",
                                      [Symbol.for("name")]: "ComputeNormalFormGlobal"
                                    });
                                return Curry._3(Assert.deepEqual, responses.contents, [
                                            {
                                              TAG: "Status",
                                              _0: false,
                                              _1: false,
                                              [Symbol.for("name")]: "Status"
                                            },
                                            {
                                              TAG: "DisplayInfo",
                                              _0: {
                                                TAG: "NormalForm",
                                                _0: "S (S Z)",
                                                [Symbol.for("name")]: "NormalForm"
                                              },
                                              [Symbol.for("name")]: "DisplayInfo"
                                            },
                                            "CompleteHighlightingAndMakePromptReappear"
                                          ], undefined);
                              }));
                      }));
              }));
      }));

/*  Not a pure module */