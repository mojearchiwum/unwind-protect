package net.parensoft.protect;

import haxe.macro.Expr;

class SupportMacros {

  
  public static macro function retVal(ex: Expr)
    return macro return $ex;

  public static macro function cont(ex: Expr) 
    return macro continue;

  public static macro function brk(ex: Expr) 
    return macro break;
  
}
