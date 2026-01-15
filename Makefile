# Usage
#
# make [syllabus]		# generate out/syllabus.pdf
# make clean			# remove intermediate files
# make reallyclean		# remove intermediate and output files

## ---- user config ----

# base for name of output .tex and .pdf files
syllabus := syllabus

# other markdown files to exclude from the syllabus
EXCLUDE := README.md 

# list of markdown files (in order) for the syllabus sections
# use the default only if all .md files in alphabetical order works for you
syllabus_md := $(filter-out $(EXCLUDE),$(wildcard *.md))
# syllabus configuration
syllabus_yaml := $(wildcard *.yaml)

# assume all local bib files will be used 
syllabus_bib := $(wildcard *.bib)

# Set to anything non-empty to suppress most of latex's messaging. To diagnose
# LaTeX errors, you may want to do `make latex_quiet=""` to get verbose output
latex_quiet := true

# Set to anything non-empty to reprocess the TeX file every time we make the PDF.
# Otherwise, TeX processing is trigged by changes to markdown, yaml, or bib files.
# # always_latexmk := true
always_latexmk := 

# Set to anything non-empty to use xelatex rather than pdflatex. I always do
# this in order to use system fonts and better Unicode support. pdflatex is
# faster, and there are some packages with which xelatex is incompatible.
xelatex := true

# Extra options to pandoc (e.g. "-H mypreamble.tex")
# not that --biblatex is necessary to convert pandoc-style citations to biblatex
# BUT the accompanying templates subsequently set biblatex: false to remove some default 
# templating from pandoc which is undesirable
PANDOC_OPTIONS := --biblatex --top-level-division=section

## ---- special external files ----

# Normally this does not need to be changed:
# works if the template is local or in ~/.pandoc/templates
SYLLABUS_TMPL := memoir-syllabus.latex

## ---- subdirectories (normally, no need to change) ----

# temporary file subdirectory; will be removed after every latex run
temp_dir := tmp

# name of output directory for .tex and .pdf files
out_dir := out

## ---- commands ----

# Change these only to really change the behavior of the whole setup

pandoc2 := `pandoc -v | head -1 | grep '^pandoc 2'`
pandoc_xelatex := $(if $(xelatex),$(if $(pandoc2),--pdf-engine,--latex-engine) xelatex)
PANDOC := pandoc $(pandoc_xelatex) $(PANDOC_OPTIONS)

LATEXMK := latexmk $(if $(xelatex),-xelatex,-pdflatex="pdflatex %O %S") \
    -pdf -dvi- -ps- $(if $(latex_quiet),-silent,-verbose) \
    -outdir=$(temp_dir)

## ---- build rules ----

syllabus_tex := $(out_dir)/$(syllabus).tex
syllabus_pdf := $(out_dir)/$(syllabus).pdf

$(syllabus_tex): $(syllabus_yaml) $(syllabus_md)
	mkdir -p $(dir $@)
	$(PANDOC) --template=$(SYLLABUS_TMPL) -o $@ $^

$(syllabus): $(syllabus_pdf)

.PHONY: $(if $(always_latexmk),$(syllabus_pdf)) clean reallyclean $(syllabus)

$(syllabus_pdf): $(syllabus_tex) $(syllabus_bib)
	mkdir -p $(dir $@)
	rm -rf $(dir $@)$(temp_dir)
	cd $(dir $<); $(LATEXMK) $(notdir $<)
	mv $(dir $<)$(temp_dir)/$(notdir $@) $@
	rm -r $(dir $<)$(temp_dir)


# clean up everything except final pdf
clean:
	rm -rf $(out_dir)/$(temp_dir)
	rm -f $(syllabus_tex)

# clean up everything including pdfs
reallyclean: clean
	rm -f $(syllabus_pdf)
	-rmdir $(out_dir)

.DEFAULT_GOAL := $(syllabus_pdf)
