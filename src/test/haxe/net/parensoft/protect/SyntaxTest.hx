package net.parensoft.protect;

import buddy.*;
using buddy.Should;

class SyntaxText extends BuddySuite implements ProtectSyntax {

  public function new() {

    describe("build macro", {
      it("should work with syntax @protect", {
        var control = [];

        try @protect {
          protected: {
            control.push("prot");
            throw "needed";
          },
          cleanup: control.push("clean")
        }
        catch (e: String) { if ("needed" != e) throw e; }

        control.should.containExactly(["prot", "clean"]);
      });

      it("should expand nested prot-in-prot", {
        var control = [];

        try @protect {
          protected: @protect {
            protected: {
              throw "out!";
            },
            cleanup: {
              control.push("inner");
            }
          },
          cleanup: {
            control.push("outer");
          }
        }
        catch (e: String) { if ("out!" != e) throw e; }
        
        control.should.containExactly(["inner", "outer"]);
      });
    });
  }
}
