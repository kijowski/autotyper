# This is just an example to get you started. A typical hybrid package
# uses this file as the main entry point of the application.

import autotyperpkg/typer

proc ctrlc() {.noconv.} =
  quit()

setControlCHook(ctrlc)

proc cli(
  lowWpm = 50.Natural,
  topWpm = 90.Natural,
  speedupRate = 5.Natural,
  slowdownRate = 5.Natural,
  mistypeRate = 2.Natural,
  repetitionRate = 1.Natural,
  skipRate = 1.Natural,
  startWpm = 0.Natural,
  separator = "\n",
  fixErrors = true,
  texts: seq[string]) =
  var typer = newTyper(lowWpm, topWpm, speedupRate, slowdownRate, mistypeRate,
      repetitionRate, skipRate, startWpm, separator, fixErrors)
  if texts.len > 0:
    typer.typeitout(texts)
  else:
    typer.typeitout(stdin.readAll)

when isMainModule:
  import cligen
  dispatch(cli)
