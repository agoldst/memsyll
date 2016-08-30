# A pandoc template for typesetting a course syllabus

This repository gives a setup for generating a syllabus in PDF from source files in markdown (pandoc's variant) and a bibliographic database in biblatex format. The typesetting and layout are governed by the supplied pandoc template, which has some options that can be tweaked via template variables. The PDF generation process is automated with the included Makefile. This simply joins together almost all `.md`  and `.yaml` files in the directory and generates `out/syllabus.pdf`.

The (silly) example files show how I recommend this setup be used. Markdown files are concatenated in alphabetical order, so if you are using multiple files I suggest putting numbers at start of their names (as here). You can of course have just the one markdown file if you prefer. `syllabus.yaml` includes some metadata as well as a number of template variables for adjusting the appearance of the PDF.

This `README.md` is excluded, as are the files named in the Make variable `other_mds`. The latter is meant for separate files you wish to generate in the same way; this repository includes an example, `booklist.md`, which I use to create a handout with a list of books that students need to buy (whereas the syllabus lists everything we have to read, including material from the library's digital collection, online, etc.).

Typography: the first page will set the course `title` and `subtitle` in `titlefont` over a rule, then put the `course-info` in a left-flush block (note that the `author` is only used in the PDF metadata; put your name in `course-info`). To remove this and make your own title block, set `custom-title: true`. The page headers and footers can be set with `o[lcr][head|foot]` (if `classoption: [twoside]` is given then `e[lcr][head|foot]` can be used as well).

This setup uses system fonts: set `mainfont`, `mainfontoptions`, and `titlefont` to the names of fonts to be used by XeLaTeX. Garamond Premier Pro is a commercial font, available as part of the Adobe [Font Folio Education Essentials](http://www.adobe.com/products/fontfolio-education-essentials.html), but of course choose anything you like.

Primitive page layout is done with the `hmargin` and `vmargin` template variables, which should be set to TeX dimensions. The default page for the memoir package is meant for continuous text rather than the list-like form of the syllabus, which I think can tolerate narrower margins.

I do citations and bibliography via `biblatex-chicago`: this template implements this if you set `biblatex: true` and `biblatex-chicago: true`. The **bibliography file path is relative to the** `out` **directory** (which is created by the Make rules). So if, as in the example files here, the bibliography lives in the same directory as the markdown files and is called `sources.bib`, then the template variable is `bibliography: ../sources.bib`. 
In return for this quirky setup, all intermediate latex, biblatex, etc. outputs are corralled in an `out` folder which is created when you executed `make syllabus.pdf`. `latexmk` is used to automate `xelatex` and `biber` processing runs.

All cited sources appear as a list of "Readings" at the end of the syllabus. If `bibcols: 2` is given, then readings are printed as two columns of small type. To take over the printing and formatting of the bibliography yourself (e.g. if you want it in sections), set `custom-bib: true`. To cite sources in e.g. a schedule of assigned reading, I suggest using pandoc's syntax, `[@casanova:world]`. This is what I have done in [the sample schedule](4schedule.md). This will generate short citations (that are also clickable links to the bibliography). One can also use biblatex citation commands directly, but the pandoc syntax means the markdown is also suitable for conversion to HTML with citations generated using pandoc-citeproc.

Put `\nocite{*}` somewhere in the markdown if you want everything in your bibliography file to appear in the list of readings (I regularly do this because I often list alternative texts).

As the sample schedule file shows, unnumbered lists are also configured without bullet points, because the 1990s are over.

If template field `thanks` is set, is appears under the heading "Acknowledgments" after the list of Readings.

This repository is based on my more general [memarticle](https://github.com/agoldst/memarticle) pandoc/latex template. It attempts to simplify my older, more chaotic [tex/syllabus](https://github.com/agoldst/tex/syllabus) setup.
