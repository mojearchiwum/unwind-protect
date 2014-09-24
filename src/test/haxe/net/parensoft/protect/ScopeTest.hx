package net.parensoft.protect;

import buddy.*;
using buddy.Should;

class ScopeTest extends BuddySuite {

  public function new() {

    describe("scope exit basic tests", {
      it("should execute on exit", {
        var control = [];

        Scope.withExits({
          @scope control.push("two");
          control.push("one");
        });

        control.should.containExactly(["one", "two"]);
      });

      it("should observe true/false/null", {
        var control = [];

        Scope.withExits({
          @scope(true) control.push("true");
          @scope(null) control.push("null");
          @scope(false) control.push("false");
          control.push("start");
        });

        control.should.containExactly(["start", "null", "true"]);
      });

      it("should observe true/false/null on exception", {
        var control = [];

        try Scope.withExits({
          @scope(true) control.push("true");
          @scope(null) control.push("null");
          @scope(false) control.push("false");
          control.push("start");
          throw "out";
        })
        catch (e: String) control.push(e);

        control.should.containExactly(["start", "false", "null", "out"]);
      });

    });

  }

}
