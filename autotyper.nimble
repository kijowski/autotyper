# Package

version       = "0.2.0"
author        = "Michal Kijowski"
description   = "Keyboard typing emulator"
license       = "MIT"
srcDir        = "src"
installExt    = @["nim"]
bin           = @["autotyper"]
binDir        = "bin"



# Dependencies

requires "nim >= 1.0.2"
requires "cligen"

# Tasks

task doc, "Generate documentation":
  rmDir "docs"
  exec "nim doc --project --index:on --git.url:https://github.com/kijowski/autotyper --git.commit:master --out=docs src/autotyperpkg/typer.nim"
  exec "nim buildIndex -o:docs/theindex.html docs"