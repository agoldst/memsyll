# A pandoc template for typesetting a course syllabus

This repository gives a setup for generating a syllabus in PDF from source files in markdown (pandoc's variant) and a bibliographic database in biblatex format. The typesetting and layout are governed by a supplied [pandoc template](memoir-syllabus.latex), which has some options that can be tweaked via template variables. The PDF generation process is automated with the included [Makefile](Makefile). `make` will join together almost all `.md`  and `.yaml` files in the directory and generate `out/syllabus.pdf` (on my system it comes out [like this](https://andrewgoldstone.com/memsyll/syllabus.pdf)).

The (silly) example files show how I recommend this setup be used. Markdown files are concatenated in alphabetical order, so if you are using multiple files I suggest putting numbers at the start of their names (as here). You can of course have just the one markdown file if you prefer; you can also edit the `syllabus_md` variable in the Makefile to be an explicit list (in order) of files. This `README.md` is excluded, as are the files named in the Make variable `other_mds`.

Some output customization is possible using YAML metadata to change the template variables. I have separated out the YAML into three files because the number of fields was getting overwhelming. In my ordinary usage, I only change fields in [syllabus.yaml](syllabus.yaml) (see below). Layout parameters are in <memoir-layout.yaml>, and biblatex-chicago setup is in <biblatex.yaml>.

In order not to clutter up the main directory with TeX's many auxiliary files, outputs go in an `out` subdirectory. These files are removed if generation is successful. If it is not and you wish to examine errors, try `make latex_quiet=""` which ensures verbose output from TeX.

## HTML version

I always want an HTML version of the reading schedule as well. Working from markdown should make that simple enough, but citations are an enduring difficulty. I have given up on my old complicated solution with tex4ht and pandoc filters. Instead, I supply a hacked [CSL style](memsyll.csl) which I use to turn the syllabus into a webpage (with a command line like in [citeproc.sh](citeproc.sh)). Unfortunately it needs hand-correcting. As ever, a nice PDF and a nice webpage can never **quite** be produced automatically from the same minimal source no matter how much complex templating you use.

## Installation

Clone the repository. The `*.latex` template files can stay in the folder with the syllabus or be moved to `~/.pandoc/templates`. 

## More details on settings and options

Typography: the first page will set the course `title` and `subtitle` in `titlefont` over a rule, then put the `course-info` in a left-flush block (note that the `author` is only used in the PDF metadata; put your name in `course-info`). To remove this and make your own title block, set `custom-title: true`. The page headers and footers can be set with `o[lcr][head|foot]` (if `classoption: [twoside]` is given then `e[lcr][head|foot]` can be used as well).

This setup uses system fonts: set `mainfont` and `titlefont` to the names of fonts to be used by XeLaTeX (with corresponding `mainfontoptions` and `titlefontoptions`. In the template, I use Garamond Premier Pro, a commercial font, which for a long time was available inexpensively to educators from Adobe. Not any more. macOS users have the elegant if somewhat florid Hoefler Text (and [some other options](https://en.wikipedia.org/wiki/List_of_typefaces_included_with_macOS)). Otherwise you have to find an open alternative or pay Adobe some kind of subscription fee. The gods will smite you if you choose Times New Roman.

Layout settings are in <memoir-layout.yaml> (which also defines the whole thing to be a `memoir` class document). Margins are set with the `hmargin` and `vmargin` template variables, which should be set to TeX dimensions (like `1 in`). The default typeblock for the memoir package is meant for continuous text rather than the list-like form of the syllabus, which I think can tolerate narrower margins.

I do citations and bibliography via `biblatex-chicago`. The options controlling this are in <biblatex.yaml>. To use Chicago style, set `biblatex: false` [sic!] and `biblatex-chicago: true`. The **bibliography file path is relative to the** `out` **directory** (which is created by the Make rules). So if, as in the example files here, the bibliography lives in the same directory as the markdown files and is called `sources.bib`, then the template variable is `bibliography: ../sources.bib`. 
In return for this quirky setup, all intermediate latex, biblatex, etc. outputs are corralled in an `out` folder which is created when you executed `make syllabus.pdf`. `latexmk` is used to automate `xelatex` and `biber` processing runs. 

All cited sources appear as a list of "Readings" at the end of the syllabus. If `bibcols: 2` is given, then readings are printed as two columns of small type. To reject all this and do the printing and formatting of the bibliography yourself (e.g. if you want it in sections), set `custom-bib: true`. To cite sources in e.g. a schedule of assigned reading, I suggest using pandoc's syntax, `[@casanova:world, 1–40].`. This is what I have done in [the sample schedule](4schedule.md). This will generate short citations (that are also clickable links to the bibliography). One can also use biblatex citation commands directly.

Put `\nocite{*}` somewhere in the markdown if you want everything in your bibliography file to appear in the list of readings.

If template field `thanks` is set, its contents appear under the heading "Acknowledgments" after the list of readings.

One disadvantage of using custom pandoc templates is that pandoc's latex output assumes all kinds of things will be set up as in the default latex template. If pandoc changes its default templates, mine fall out of sync until I notice and fix it. Following my updates in January 2026, the <memoir-syllabus.latex> template relies on pandoc's default "partial" templates, which factors out some of these issues. Only some.

I have a more general [memarticle](https://github.com/agoldst/memarticle) pandoc/latex template which I still (early 2026) have to update.
