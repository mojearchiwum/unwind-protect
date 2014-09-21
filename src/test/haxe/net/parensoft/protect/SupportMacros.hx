package net.parensoft.protect;

import haxe.macro.Expr;

class SupportMacros {

  
  public static macro function retVal(ex: Expr)
    return macro return $ex;
  
}
