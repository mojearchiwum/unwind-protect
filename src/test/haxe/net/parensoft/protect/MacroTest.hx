package net.parensoft.protect;

import buddy.*;
using buddy.Should;

import haxe.macro.Expr;

class MacroTest extends BuddySuite {

  public function new() {

    describe("handle macroed returns, loops, etc", {
      it("should correctly handle macroed return", {
        var control = [];

        var run = function() {
          Protect.protect({
            SupportMacros.retVal("ret");
          },
          {
            control.push("clean");
          });
          return "whatever";
        };

        control.push(run());

        control.should.containExactly(["clean", "ret"]);
      });
    });

  }


}

