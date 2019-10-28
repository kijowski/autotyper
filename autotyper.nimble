# Package

version       = "0.1.0"
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
