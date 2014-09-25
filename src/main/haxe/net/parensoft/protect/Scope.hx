package net.parensoft.protect;

import haxe.macro.Expr;
import haxe.macro.Context;
import net.parensoft.protect.Util.*;


class Scope {

  public static macro function withExits(ex: Expr)
    return switch (ex) {
      case { expr: EBlock(el) }: {
        transform(el);
      }
      default: Context.error("Context.withExits requires a block", ex.pos);
    }

#if macro
  private static function transform(el: Array<Expr>) {
    var ret = [];

    var arrName = genSym();

    for (exp in el) switch (exp) {
      case macro @scope $expr:
        ret.push(macro $i{arrName}.unshift({ fail: null, run: function() $expr }));
      case macro @scope($when) $expr:
        ret.push(macro $i{arrName}.unshift({ fail: $when, run: function() $expr }));
      case macro @SCOPE $expr:
        ret.push(macro $i{arrName}.unshift({ fail: null, run: function() try $expr catch (_: Dynamic) {} }));
      case macro @SCOPE($when) $expr:
        ret.push(macro $i{arrName}.unshift({ fail: $when, run: function() try $expr catch (_: Dynamic) {} }));
      case { expr: EMeta({ name: "closes", params: []}, { expr: EVars(vars), pos: pos }) }: {
        for (vardecl in vars) {
          ret.push({ expr: EVars([ vardecl ]), pos: pos });
          ret.push(macro $i{arrName}.unshift({ fail: null, run: function() $i{vardecl.name}.close() }));
        }
      }
      case { expr: EMeta({ name: "closes", params: [ { expr: EConst(CString(func)) } ]},
                         { expr: EVars(vars), pos: pos }) }: {
        for (vardecl in vars) {
          ret.push({ expr: EVars([ vardecl ]), pos: pos });
          ret.push(macro $i{arrName}.unshift({ fail: null, run: function() $i{vardecl.name}.$func() }));
        }
      }
      case { expr: EMeta({ name: "CLOSES", params: []}, { expr: EVars(vars), pos: pos }) }: {
        for (vardecl in vars) {
          ret.push({ expr: EVars([ vardecl ]), pos: pos });
          ret.push(macro $i{arrName}.unshift(
                { fail: null, run: function() try $i{vardecl.name}.close() catch(_: Dynamic) {} }));
        }
      }
      case { expr: EMeta({ name: "CLOSES", params: [ { expr: EConst(CString(func)) } ]},
                         { expr: EVars(vars), pos: pos }) }: {
        for (vardecl in vars) {
          ret.push({ expr: EVars([ vardecl ]), pos: pos });
          ret.push(macro $i{arrName}.unshift(
                { fail: null, run: function() try $i{vardecl.name}.$func() catch (_: Dynamic) {} }));
        }
      }
      default:
        ret.push(expandMacros(exp));
    }

    var statusName = genSym();
    var counter = genSym();

    return macro {
      var $arrName: Array<net.parensoft.protect.Scope.ExitFunc> = [];

      ${net.parensoft.protect.Protect.protectBuild(macro $b{ret}, macro {

        for ($i{counter} in $i{arrName}) if ($i{counter}.fail != !$i{statusName}) ($i{counter}.run)();

      }, statusName)}


    };
  }
#else
  private static function transform(el: Array<Expr>) 
    throw "Only for macros";
#end

}

typedef ExitFunc = {
  var fail: Null<Bool>;
  var run: Void -> Void;
}
