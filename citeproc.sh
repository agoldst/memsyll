#!/bin/sh
# one-liner showing how to use pandoc to turn schedule markdown with
# [@citations] into markdown suitable for further conversion for web. It's not
# perfect by any means, but whose fault is that?

pandoc --citeproc --csl memsyll.csl --bibliography sources.bib 4schedule.md -t markdown

