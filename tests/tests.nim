# This is just an example to get you started. You may wish to put all of your
# tests into a single file, or separate them into multiple `test1`, `test2`
# etc. files (better names are recommended, just make sure the name starts with
# the letter 't').
#
# To run these tests, simply execute `nimble test`.

import unittest, sequtils, strutils

import autotyperpkg/typer

suite "flawless typer":
  setup:
    var flawless = newTyper(mistypeRate = 0, repetitionRate = 0, skipRate = 0)

  test "does not have an backspace":
    let longText = "x".repeat(1000)
    let actions = flawless.getActions(longText).mapIt(it.kind)

    check:
      not actions.contains(Backspace)
      actions.len == longText.len

  test "produces output equal to input":
    let complexText = "abcdefghijk".repeat(200)
    let output = flawless
    .getActions(complexText)
    .map(proc (it: Action): string =
      case it.kind:
      of Backspace:
        fail()
      of Letter:
        result = $it.letter)
    .foldl(a & b)

    check:
      output == complexText

suite "constant typer":
  setup:
    var constantTyper = newTyper(topWpm = 50, lowWpm = 50)

  test "all actions have the same delay":
    let longText = "x".repeat(1000)
    let actions = constantTyper.getActions(longText).mapIt(it.delay)
    check:
      actions.all(proc (delay: Natural): bool = delay == actions[0])
