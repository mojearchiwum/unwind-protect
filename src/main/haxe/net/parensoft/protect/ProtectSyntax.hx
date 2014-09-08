package net.parensoft.protect;

import haxe.macro.Expr;
using haxe.macro.ExprTools;

@:autoBuild(net.parensoft.protect.ProtectSyntax.SyntaxBuilder.build())
interface ProtectSyntax {}

#if macro
class SyntaxBuilder {

  public static function build() {
    return haxe.macro.Context.getBuildFields().map(transformField);
  }

  static function transformField(field: Field) {
    switch (field.kind) {
      case FFun(fun): 
        transform(fun.expr);
      default: {}
    }

    return field;

  }

  static function transform(ex: Expr) 
    switch (ex) {
      case macro @protect { protected: $prot, cleanup: $clean }:
        transform(prot); transform(clean);
        ex.expr = (macro net.parensoft.protect.Protect.protect($prot, $clean)).expr;
      default:
        ex.iter(transform);
    }
}
#end
