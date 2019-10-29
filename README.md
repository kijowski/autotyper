# Autotyper

Autotyper is a library and command line utility that can emulate the way that real people are typing.

## Cli usage

```sh
autotyper "This will be printed"
```

```sh
cat file | autotyper
```

```
autotyper -h
Usage:
  autotyper [optional-params] [texts: string...]
Options(opt-arg sep :|=|spc):
  -h, --help                            print this cligen-erated help
  --help-syntax                         advanced: prepend,plurals,..
  -l=, --lowWpm=          int     50    minimum WPM that typer can slow down to
  -t=, --topWpm=          int     90    maximum WPM that typer can speed up to
  -s=, --speedupRate=     int     5     amount of WPM that typer will gain after correct keystroke
  --slowdownRate=         int     5     amount of WPM that typer will lose after incorrect keystroke
  -m=, --mistypeRate=     int     2     percentge of incorrect keystrokes
  -r=, --repetitionRate=  int     1     percentage of repeated keystrokes
  --skipRate=             int     1     percentage of skipped keystrokes
  --startWpm=             int     0     starting WPM. If set to 0 it will be calculated with (lowWpm + topWpm) / 2
  --separator=            string  "\n"  string that will separate multiple phrases
  -f, --fixErrors         bool    true  controls whether typer should fix incorrect keystrokes
```

## Library usage

```nim
import autotyperpkg/typer

# Initialize new typer var
# Can be parametrized with various options
var typer = newTyper()

# Typing to the standard output with proc invocation
typer.typeItOut("This will be typed to stdout")

# Using macro for convenient printing
typeWith typer:
  "This will be typed to stdout"
  "This will also be typed"
```
