---
title: "${cursor}"
author: 
date: 
# clever referencing #
eqnos-cleveref: on
eqnos-plus-name: equation
fignos-cleveref: on
fignos-plus-name: figure
tablenos-cleveref: on
# customise latex header
header-includes:
# run mode #
# :: run non-interactively
#- \nonstopmode
# color #
# :: improved color handling
- \usepackage{xcolor}
# fonts #
# :: font setup is taken from Michael Franzl's blog at
#    https://michaelfranzl.com/2014/12/10/xelatex-unicode-font-\
#    fallback-unsupported-characters/
# :: IPAexMincho provided in debian by 'texlive-lang-cjk' package
- \usepackage{fontspec}
- \setmainfont{Junicode}
- \newfontfamily\myregularfont{Junicode}
- \newfontfamily\mychinesefont{IPAexMincho}
- \usepackage[CJK]{ucharclasses}
- \setTransitionsForCJK{\mychinesefont}{\myregularfont}
# headings #
# :: start top level headings on a new page
#- \let\oldsection\section
#- \renewcommand{\section}[1]{\clearpage\oldsection{#1}}
---

