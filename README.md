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

This uses exceptions internally, so things like this won't (yet) work:

```
#!haxe
@protect {
  protected: try {
    return 1;
  }
  catch (e: Dynamic) {},
  cleanup: CLEAN
}
```

In this case ```CLEAN``` will get executed, but ```return 1``` **will get suppressed**.



License: MIT

(C) Parensoft.NET 2014