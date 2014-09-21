package net.parensoft.protect;

import haxe.macro.Expr;
import haxe.macro.Context;
using haxe.macro.ExprTools;
import haxe.macro.ComplexTypeTools;

class Protect {

  public static macro function protect(protected: Expr, cleanup: Expr) {
    var flags = new TransformFlags();
    var transformed = transform(expandMacros(protected), flags);


    return macro try {
      $transformed;
      throw net.parensoft.protect.Protect.ProtectPass.PassedOK;
    }
    catch (__protect_exception: net.parensoft.protect.Protect.ProtectPass) {

      $cleanup;

      switch (__protect_exception) {
        case net.parensoft.protect.Protect.ProtectPass.PassedOK:
          {}
        case net.parensoft.protect.Protect.ProtectPass.ReturnVoid:
          ${ flags.returnsVoid ? macro { return; } : macro {} };
        case net.parensoft.protect.Protect.ProtectPass.ReturnValue(__protect_value):
          ${ flags.returnsValue ? macro { return __protect_value; } : macro {} };
        case net.parensoft.protect.Protect.ProtectPass.Break:
          ${ flags.breaks ? macro { break; } : macro {} };
        case net.parensoft.protect.Protect.ProtectPass.Continue: 
          ${ flags.continues ? macro { continue; } : macro {} };

      }
    }
    catch (__protect_exception: Dynamic) {
      $cleanup;
      throw __protect_exception;
    }
  }

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
      case { expr: ETry(tryexp, catches) }:
        var ncatches = catches.map(function(cExp) {
          return 
            { name : cExp.name,
              type : cExp.type, 
              expr: transform(cExp.expr, flags, inLoop) };
          });
        if (ncatches.length > 0 && 
            ComplexTypeTools.toString(ncatches[0].type) != "net.parensoft.protect.Protect.ProtectPass")
          ncatches.unshift( { name: "__protect_e", 
                            type: macro :net.parensoft.protect.Protect.ProtectPass,
                            expr: macro throw __protect_e 
                          } );
        { pos: expr.pos, expr: ETry(transform(tryexp, flags, inLoop), ncatches) };
      default: 
        var trans = transform.bind(_, flags, inLoop);
        expr.map(trans);
        
    }
  }
  
  private static function expandMacros(ex: Expr)
    return Context.getTypedExpr(Context.typeExpr(ex));

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
