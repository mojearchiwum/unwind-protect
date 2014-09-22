package net.parensoft.protect;

import haxe.macro.Context;
import haxe.macro.Expr;

class Util {

#if macro


  public static function expandMacros(ex: Expr)
    return Context.getTypedExpr(Context.typeExpr(ex));
  
#end

  private static var genSymCounter: Int = 1000;

  public static function genSym(?base: String = "__net_parensoft_protect") {
    genSymCounter++;

    return '${base}_${genSymCounter}';
  }



}