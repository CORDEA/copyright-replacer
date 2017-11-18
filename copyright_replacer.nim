# Copyright 2016 Yoshihiro Tanaka
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

  # http://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Author: Yoshihiro Tanaka <contact@cordea.jp>
# date  :2016-09-01

import os, osproc, pegs
import strutils, subexes, times

const
  copyright = """
  rule <- 'Copyright' \s+ year ( '-' year )? \s+ \[* {\w+ \s* \w+} \]*
  year <- \[* {\d+} \]*
  """
  initialCopyright = "Copyright [yyyy] [name of copyright owner]"
  copyrightTemplate = "Copyright $# $#"

type
  SyntaxError = object of Exception
  CommandError = object of Exception
  GitConfigurationError = object of Exception

proc getDefaultName(): string =
  let (output, code) = execCmdEx("git config --get user.name")
  if code != 0:
    raise newException(CommandError, output)
  result = output.strip()

proc getLatestCopyright(name: string = "", startYear, endYear: int = -1): string =
  var
    yearString = $startYear
    name = name
  let
    currentYear = getLocalTime(getTime()).year

  if startYear > 0 and endYear > 0:
    if endYear != currentYear:
      yearString = subex("$#-$#") % [$startYear, $currentYear]
    else:
      yearString = subex("$#-$#") % [$startYear, $endYear]
  else:
    if startYear < 1:
      yearString = $currentYear
    elif startYear != currentYear:
      yearString = subex("$#-$#") % [$startYear, $currentYear]

  if name.isNilOrWhitespace():
    name = getDefaultName()
    if name.isNilOrWhitespace():
      raise newException(GitConfigurationError, "")
  result = subex(copyrightTemplate) % [yearString, name]

proc handleMatches(m: int, n: int, c: openarray[string]): string = 
  if n == 2:
    let
      name = c[1]
      year = parseInt(c[0])
    result = getLatestCopyright(name, year)
  elif n == 3:
    let
      name = c[2]
      startYear = parseInt(c[0])
      endYear = parseInt(c[1])
    result = getLatestCopyright(name, startYear, endYear)
  else:
    raise newException(SyntaxError, "")

proc replace(filename: string) =
  let
    pattern = peg(copyright)
    lines = filename.readFile()
  var replacedLines = lines
  replacedLines = replacedLines.replace(pattern, handleMatches)
  if lines == replacedLines:
    replacedLines = replacedLines.replace(initialCopyright, getLatestCopyright())
  let newfile = filename & "_new"
  let writef = newfile.open(fmWrite)
  writef.write replacedLines
  writef.close()
  newfile.moveFile filename

proc walk(dirname: string) =
  for kind, path in walkDir(dirname):
    if kind == pcFile:
      replace(path)
    if kind == pcDir:
      walk(path)

when isMainModule:
    let arg = commandLineParams()
    if len(arg) == 1:
      if existsFile arg[0]:
        replace(arg[0])
      if existsDir arg[0]:
        walk(arg[0])
