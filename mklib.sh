#!/bin/sh

rm -f out/unwind-protect.zip

zip -r out/unwind-protect.zip haxelib.json src/main/haxe \
  -x $(find . -name .\*.swp) 
