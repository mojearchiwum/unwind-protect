package net.parensoft.protect;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

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

#if macro
abstract TypedExpression(TypedExpr) from TypedExpr to TypedExpr {
  
  public function new(aThis: TypedExpr) this = aThis;

  @:from public static function fromExpr(anExpr: Expr)
    return new TypedExpression(Context.typeExpr(anExpr));

  @:to public function toExpr()
    return Context.getTypedExpr(this);

  public function getType()
    return this.t;
}
#end
