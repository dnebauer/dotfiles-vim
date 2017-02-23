---
title: "${cursor}"
header-includes:
    - \usepackage{xcolor}
#   following font setup is taken from Michael Franzl's blog at
#     https://michaelfranzl.com/2014/12/10/xelatex-unicode-font-\
#     fallback-unsupported-characters/
#   IPAexMincho provided in debian by 'texlive-lang-cjk' package
    - \usepackage{fontspec}
    - \setmainfont{Junicode}
    - \newfontfamily\myregularfont{Junicode}
    - \newfontfamily\mychinesefont{IPAexMincho}
    - \usepackage[CJK]{ucharclasses}
    - \setTransitionsForCJK{\mychinesefont}{\myregularfont}
---

