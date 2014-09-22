package net.parensoft.protect;

import haxe.macro.Context;
import haxe.macro.Expr;

class Util {

#if macro

  public static function expandMacros(ex: Expr)
    return Context.getTypedExpr(Context.typeExpr(ex));


#end

}
