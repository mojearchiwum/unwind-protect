package net.parensoft.protect;

import buddy.*;
using buddy.Should;

import net.parensoft.protect.Protect;

class ReturnTest extends BuddySuite {

  public function new() {

    describe("returning from protected and cleanup blocks", {
      it("should run cleanup when prot returns value", {
        var control = [];

        var run = function() {
          Protect.protect({
            return "value";
          },
          {
            control.push("clean");
          });
          return "whatever";
        };

        control.push(run());

        control.should.containExactly(["clean", "value"]);


      });

      it("should run cleanup when prot returns void", {
        var control = [];

        var run = function() {
          Protect.protect({
            return;
          },{
            control.push("clean");
          });
          
          throw "unexpected";
        }

        run();

        control.should.containExactly(["clean"]);

      });

      it("should ignore return and throw whatever cleanup throws", {
        var control = [];

        var run = function() {
          Protect.protect({
            return "ignore";
          },
          {
            throw "thrown";
          });
          throw "unexpected";
        };

        run.should.throwValue("thrown");

      });
    });


  }
}
