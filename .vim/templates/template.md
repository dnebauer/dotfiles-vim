---
title: "${cursor}"
header-includes:
# use this to run non-interactively
#- \nonstopmode
- \usepackage{xcolor}
# following font setup is taken from Michael Franzl's blog at
#   https://michaelfranzl.com/2014/12/10/xelatex-unicode-font-\
#   fallback-unsupported-characters/
# IPAexMincho provided in debian by 'texlive-lang-cjk' package
- \usepackage{fontspec}
- \setmainfont{Junicode}
- \newfontfamily\myregularfont{Junicode}
- \newfontfamily\mychinesefont{IPAexMincho}
- \usepackage[CJK]{ucharclasses}
- \setTransitionsForCJK{\mychinesefont}{\myregularfont}
# start all top level headings on a new page
# [fails because lines get munged by pandoc in latex output]
#- \let\oldsection\section
#- \renewcommand{\section}[1]{\clearpage\oldsection{#1}}
---

