##[
  Autotyper is a library and command line utility that can emulate the way that real people are typing.

  Notice
  ######
  1. This library is using ``random`` module so make sure to initialize it with ``randomize`` beforehand
  2. This library assumes that Word in WPM metric is 5 characters long
]##

import random, os, macros
from math import cumsummed

type
  ActionKind* = enum
    Letter,
    Backspace

  Action* = object
    ## Indicates typing action together with delay in ms. This delay is derived from the current speed of the typer
    delay*: Natural

    case kind*: ActionKind
    of Letter: letter*: char
    of Backspace: nil

  Typer* = object
    ## Contains various typing settings and current typing speed
    ## - lowWpm - minimum WPM that typer can slow down to
    ## - topWpm - maximum WPM that typer can speed up to
    ## - speedupRate - amount of WPM that typer will gain after correct keystroke
    ## - slowdownRate - amount of WPM that typer will lose after incorrect keystroke
    ## - mistypeRate - percentge of incorrect keystrokes
    ## - repetitionRate - percentage of repeated keystrokes
    ## - skipRate - percentage of skipped keystrokes
    ## - startWpm - starting WPM. If set to 0 it will be calculated with (lowWpm + topWpm) / 2
    ## - separator - string that will separate multiple phrases
    ## - fixErrors - controls whether typer should fix incorrect keystrokes
    ## - currentWpm - current typing speed
    lowWpm: Natural
    topWpm: Natural
    currentWpm: Natural
    speedupRate: Natural
    slowdownRate: Natural
    mistypeRate: range[0..99]
    repetitionRate: range[0..99]
    skipRate: range[0..99]
    separator: string
    fixErrors: bool

proc newTyper*(
  lowWpm = 50.Natural,
  topWpm = 90.Natural,
  startWpm = 0.Natural,
  speedupRate = 5.Natural,
  slowdownRate = 5.Natural,
  mistypeRate = 2,
  repetitionRate = 1,
  skipRate = 1,
  separator = "\n",
  fixErrors = true): Typer =
  ## Create new Typer object with sane defaults
  assert(mistypeRate + repetitionRate + skipRate < 100, "Sum of error rates must be lower than 100")
  let currentWpm = if startWpm == 0: (lowWpm + topWpm) div 2 else: startWpm
  Typer(lowWpm: lowWpm, topWpm: topWpm, speedupRate: speedupRate,
      slowdownRate: slowdownRate, mistypeRate: mistypeRate,
      repetitionRate: repetitionRate,
      skipRate: skipRate,
      fixErrors: fixErrors,
      currentWpm: currentWpm,
      separator: separator)

proc slowdown(typer: var Typer) =
  typer.currentWpm = max(typer.lowWpm, typer.currentWpm - typer.slowdownRate)

proc speedup(typer: var Typer): void =
  typer.currentWpm = min(typer.topWpm, typer.currentWpm + typer.speedupRate)

proc currentDelay(typer: Typer): Natural =
  1000 div ((typer.currentWpm * 5) div 60)

proc actionDistribution(typer: Typer): seq[int] =
  cumsummed [100-typer.mistypeRate - typer.repetitionRate - typer.skipRate,
      typer.mistypeRate, typer.repetitionRate, typer.skipRate]

const Actions = ["correct_letter", "wrong_letter", "repeat_letter", "skip_letter"]

proc letter(character: char, delay: Natural): Action =
  Action(kind: Letter, letter: character, delay: delay)

proc backspace(delay: Natural): Action =
  Action(kind: Backspace, delay: delay)

proc getActions*(typer: var Typer, phrase: string): seq[Action] =
  ## Returns sequence of ``Action`` that are required to type out input phrase
  let cdf = typer.actionDistribution
  var pos = 0
  while (pos < phrase.len()):
    let act = sample(Actions, cdf)
    let delay = typer.currentDelay
    case act:
      of "correct_letter":
        result.add letter(phrase[pos], delay)
        pos.inc
        typer.speedup
      of "wrong_letter":
        result.add letter((phrase[pos].int + 1).char, delay)
        if(typer.fixErrors):
          result.add backspace(delay)
        else:
          pos.inc
        typer.slowdown
      of "repeat_letter":
        result.add letter(phrase[pos], delay)
        result.add letter(phrase[pos], delay)
        if(typer.fixErrors):
          result.add backspace(delay)
        pos.inc
        typer.slowdown
      of "skip_letter":
        if(not typer.fixErrors):
          pos.inc
          typer.slowdown

proc typeItOut*(typer: var Typer, file: File, texts: varargs[string]) =
  ## Creates sequence of Actions for given input texts and then write them to supplied File handle
  for i, text in texts:
    for action in typer.getActions text:
      case action.kind:
        of Letter:
          file.write action.letter
        of Backspace:
          file.write '\b'
      file.flushFile
      sleep action.delay
    if(i < texts.len() - 1):
      file.write typer.separator
      file.flushFile

proc typeItOut*(typer: var Typer, texts: varargs[string]) =
  ## typeItOut override that assumes ``stdout`` is the desired output
  runnableExamples:
    var defaultTyper = newTyper()
    defaultTyper.typeItOut("This will", "be typed", "to stdout")
  typeitout(typer, stdout, texts)

macro typeWith*(file: File, typer: var Typer, stmtList: untyped): untyped =
  ## Macro that enables nice syntax for typing out a list of strings using specified Typer
  result = newStmtList()
  expectKind(stmtList, nnkStmtList)
  for child in stmtList:
    expectKind(child, {nnkStrLit, nnkCall, nnkIdent})
    result.add(newCall("typeitout", typer, file, child))
    result.add(newCall("write", file, newStrLitNode("\n")))

macro typeWith*(typer: var Typer, stmtList: untyped): untyped =
  ## typeWith overload that assumes ``stdout`` is the desired output
  runnableExamples:
    var defaultTyper = newTyper()
    typeWith defaultTyper:
      "This will"
      "be typed"
      "to stdout"
  result = newCall("typewith", newIdentNode("stdout"), typer, stmtList)
