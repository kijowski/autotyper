# This is just an example to get you started. A typical hybrid package
# uses this file as the main entry point of the application.

import autotyperpkg/typer

proc ctrlc() {.noconv.} =
  quit()

setControlCHook(ctrlc)

proc autotyper(
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
  var typer = newTyper(lowWpm, topWpm, startWpm, speedupRate, slowdownRate,
      mistypeRate, repetitionRate, skipRate, separator, fixErrors)
  if texts.len > 0:
    typer.typeitout(texts)
  else:
    typer.typeitout(stdin.readAll)

when isMainModule:
  import cligen
  dispatch(autotyper, help = {
      "lowWpm": "minimum WPM that typer can slow down to",
      "topWpm": "maximum WPM that typer can speed up to",
      "speedupRate": "amount of WPM that typer will gain after correct keystroke",
      "slowdownRate": "amount of WPM that typer will lose after incorrect keystroke",
      "mistypeRate": "percentge of incorrect keystrokes",
      "repetitionRate": "percentage of repeated keystrokes",
      "skipRate": "percentage of skipped keystrokes",
      "startWpm": "starting WPM. If set to 0 it will be calculated with (lowWpm + topWpm) / 2",
      "separator": "string that will separate multiple phrases",
      "fixErrors": "controls whether typer should fix incorrect keystrokes"
    })
