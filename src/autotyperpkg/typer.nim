import random, os, macros, sequtils
from math import cumsummed

type
  ActionKind* = enum
    Letter,
    Backspace

  Action* = object
    delay*: Natural

    case kind*: ActionKind
    of Letter: letter*: char
    of Backspace: nil

  Typer* = object
    lowWpm: Natural
    topWpm: Natural
    currentWpm: Natural
    speedupRate: Natural
    slowdownRate: Natural
    mistypeRate: Natural
    repetitionRate: Natural
    skipRate: Natural
    separator: string
    fixErrors: bool

proc newTyper*(
  lowWpm = 50.Natural,
  topWpm = 90.Natural,
  speedupRate = 5.Natural,
  slowdownRate = 5.Natural,
  mistypeRate = 2.Natural,
  repetitionRate = 1.Natural,
  skipRate = 1.Natural,
  startWpm = 0.Natural,
  separator = "\n",
  fixErrors = true): Typer =
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

proc typeitout*(typer: var Typer, file: File, texts: varargs[string]) =
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

proc typeitout*(typer: var Typer, texts: varargs[string]) =
  typeitout(typer, stdout, texts)

macro typewith*(file: File, typer: var Typer, stmtList: untyped): untyped =
  result = newStmtList()
  expectKind(stmtList, nnkStmtList)
  for child in stmtList:
    expectKind(child, {nnkStrLit, nnkCall, nnkIdent})
    result.add(newCall("typeitout", typer, file, child))
    result.add(newCall("write", file, newStrLitNode("\n")))

macro typewith*(typer: var Typer, stmtList: untyped): untyped =
  result = newCall("typewith", newIdentNode("stdout"), typer, stmtList)
