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

    });
  }

}
