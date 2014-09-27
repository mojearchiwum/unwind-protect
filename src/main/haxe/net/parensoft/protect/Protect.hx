package net.parensoft.protect;

import haxe.macro.Expr;
import haxe.macro.Context;
using haxe.macro.ExprTools;
import haxe.macro.ComplexTypeTools;
import haxe.macro.Type;

import net.parensoft.protect.Util.*;

class Protect {

  public static macro function protect(protected: Expr, cleanup: Expr) {

    var typedProt: Util.TypedExpression = protected;

    return protectBuild(typedProt, cleanup, genSym(), typedProt.getType());
  }

  @:allow(net.parensoft.protect.Scope)
#if macro
  private static function protectBuild(protected: Expr, cleanup: Expr, statusName: String, type: Type) {
    var flags = new TransformFlags();
    var transformed = transform(protected, flags);

    var excName = genSym();
    var protVName = genSym();

    var isVoid = false;

    var defvar = switch(type) {
      case TAbstract(t, _):
        switch(t.get()) {
          case { module: "StdTypes", pack: [], name: "Int" }: macro 0;
          case { module: "StdTypes", pack: [], name: "Float" }: macro 0.0;
          case { module: "StdTypes", pack: [], name: "Bool" }: macro false;
          case { module: "StdTypes", pack: [], name: "Void" }: isVoid = true; macro false;
          default: macro null;
        }
      default: macro null;

    }

    var retName = genSym();

    return macro {

      var $retName = ${defvar};

      try {
        ${ if(isVoid) macro $transformed else macro $i{retName} = $transformed };
        throw net.parensoft.protect.Protect.ProtectPass.PassedOK;
      }
      catch ($excName: net.parensoft.protect.Protect.ProtectPass) {
  
        var $statusName: Null<Bool> = true;
  
        $cleanup;
  
        switch ($i{excName}) {
          case net.parensoft.protect.Protect.ProtectPass.PassedOK:
            {}
          case net.parensoft.protect.Protect.ProtectPass.ReturnVoid:
            ${ flags.returnsVoid ? macro { return; } : macro {} };
          case net.parensoft.protect.Protect.ProtectPass.ReturnValue($i{protVName}):
            ${ flags.returnsValue ? macro { return $i{protVName}; } : macro {} };
          case net.parensoft.protect.Protect.ProtectPass.Break:
            ${ flags.breaks ? macro { break; } : macro {} };
          case net.parensoft.protect.Protect.ProtectPass.Continue: 
            ${ flags.continues ? macro { continue; } : macro {} };
  
        }
      }
      catch ($excName: Dynamic) {
        var $statusName: Null<Bool> = false;
  
        $cleanup;
  
        throw $i{excName};
      }
  
      ${ if(isVoid) macro {} else macro $i{retName} };

    };
  }
#else
  private static function protectBuild(protected: Expr, cleanup: Expr, statusName: String)
    throw "Must be called from a macro";
#end

  private static function transform(expr: Expr, flags: TransformFlags, ?inLoop = false): Expr {
    return switch(expr) {
      case macro break if (!inLoop):
        flags.breaks = true;
        macro throw net.parensoft.protect.Protect.ProtectPass.Break;
      case macro continue if (!inLoop):
        flags.continues = true;
        macro throw net.parensoft.protect.Protect.ProtectPass.Continue;
      case macro return:
        flags.returnsVoid = true;
        macro throw net.parensoft.protect.Protect.ProtectPass.ReturnVoid;
      case macro return $val:
        flags.returnsValue = true;
        macro throw net.parensoft.protect.Protect.ProtectPass.ReturnValue($val);
      case { expr: EFunction(_, _) }:
        expr;
      case { expr: EFor(it, body) }:
        { pos: expr.pos, expr: EFor(it, transform(body, flags, true)) };
      case { expr: EWhile(ecnd, exp, norm) }:
        { pos: expr.pos, expr: EWhile(ecnd, transform(exp, flags, true), norm) };
      case { expr: ETry(tryexp, catches) }: {

        if (catches.length > 0 && 
            ComplexTypeTools.toString(catches[0].type) == "net.parensoft.protect.Protect.ProtectPass")
          expr;
        else {
        
          var ncatches = catches.map(function(cExp) {
            return {
              name : cExp.name,
              type : cExp.type, 
              expr: transform(cExp.expr, flags, inLoop) };
          });

          var excName = genSym();

          ncatches.unshift({
            name: excName,
            type: macro :net.parensoft.protect.Protect.ProtectPass,
            expr: macro throw $i{excName}
          });

          { pos: expr.pos, expr: ETry(transform(tryexp, flags, inLoop), ncatches) };

        }
      }
      default: 
        var trans = transform.bind(_, flags, inLoop);
        expr.map(trans);
        
    }
  }
  
}

private class TransformFlags {
  public var returnsValue(default, default): Bool = false;
  public var returnsVoid(default, default): Bool = false;
  public var breaks(default, default): Bool = false;
  public var continues(default, default): Bool = false;

  public function new() {}
}

enum ProtectPass {
  PassedOK;
  ReturnVoid;
  ReturnValue(value: Dynamic);
  Break;
  Continue;
}
