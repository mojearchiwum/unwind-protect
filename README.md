# unwind-protect, or try/finally for Haxe

## Usage:

## Build macro (recommended):

```
#!haxe

@protect {
  protected: PROT,
  cleanup: CLEAN
}

```

```CLEAN``` will **always** be executed when ```PROT``` exits. This includes normal completion or an abrupt exit with an exception, or a ```return```, ```break``` or ```continue``` statement.

To use ```@protect``` the class _must_ implement the ```net.parensoft.protect.ProtectSyntax``` interface or be annotated with ```@:build(net.parensoft.protect.ProtectSyntax.SyntaxBuilder.build())```

## Expression macro:

```
#!haxe
import net.parensoft.protect.Protect;

....

Protect.protect(
  PROT,
  CLEAN);
```

As above, ```CLEAN``` is executed always whenever ```PROT``` exits.

## Known limitations

Value of the ```@protected``` expression is undefined.

Expression macros that expand to:

* ```return```, ```break``` or ```continue``` expressions
* loops
* functions

will not be handled and havoc may ensue.


License: MIT

(C) Parensoft.NET 2014
