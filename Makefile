## ---- user config ----

# list of markdown files (in order) for the syllabus sections
# use the default only if all .md files in alphabetical order works for you
syllabus_md := $(filter-out README.md,$(wildcard *.md))
# syllabus configuration (normally just the one yaml file)
syllabus_yaml := $(wildcard *.yaml)

# Set to anything non-empty to suppress most of latex's messaging. To diagnose
# LaTeX errors, you may want to do `make latex_quiet=""` to get verbose output
latex_quiet := true

# Set to anything non-empty to reprocess the TeX file every time we make the PDF.
# Otherwise the former will be regenerated only when the source markdown
# changes; in that case, if you change other dependencies (e.g. the
# bibliography), use the -B option to make in order to force regeneration.
# always_latexmk := true
always_latexmk := 

# Set to anything non-empty to use xelatex rather than pdflatex. I always do
# this in order to use system fonts and better Unicode support. pdflatex is
# faster, and there are some packages with which xelatex is incompatible.
xelatex := true

# Extra options to pandoc (e.g. "-H mypreamble.tex")
PANDOC_OPTIONS := --biblatex

## ---- special external file ----

# Normally this does not need to be changed:
# works if the template is local or in ~/.pandoc/templates
PANDOC_TMPL := memoir-syllabus.latex

## ---- subdirectories (normally, no need to change) ----

# temporary file subdirectory; will be removed after every latex run
temp_dir := tmp

# name of output directory for .tex and .pdf files
out_dir := out

# base for name of output .tex and .pdf files
syllabus := syllabus

## ---- commands ----

# Change these only to really change the behavior of the whole setup

PANDOC := pandoc $(if $(xelatex),--latex-engine xelatex) \
    $(PANDOC_OPTIONS)

LATEXMK := latexmk $(if $(xelatex),-xelatex,-pdflatex="pdflatex %O %S") \
    -pdf -dvi- -ps- $(if $(latex_quiet),-silent,-verbose) \
    -outdir=$(temp_dir)

## ---- build rules ----

texs := $(patsubst $(md_dir)/%.md,$(out_dir)/%.tex,$(mds))

tex := $(out_dir)/$(syllabus).tex
pdf := $(out_dir)/$(syllabus).pdf

$(tex): $(syllabus_yaml) $(syllabus_md)
	mkdir -p $(dir $@)
	$(PANDOC) --template=$(PANDOC_TMPL) -o $@ $^

phony_pdfs := $(if $(always_latexmk),$(pdf))

.PHONY: $(phony_pdfs) clean reallyclean

$(pdf): $(tex)
	mkdir -p $(dir $@)
	rm -rf $(dir $@)$(temp_dir)
	cd $(dir $<); $(LATEXMK) $(notdir $<)
	mv $(dir $<)$(temp_dir)/$(notdir $@) $@
	rm -r $(dir $<)$(temp_dir)

# clean up everything except final pdf
clean:
	rm -rf $(out_dir)/$(temp_dir)
	rm -f $(tex)

# clean up everything including pdfs
reallyclean: clean
	rm -f $(pdf)
	-rmdir $(out_dir)

.DEFAULT_GOAL := $(pdf)
