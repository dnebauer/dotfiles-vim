" Vim syntax file
" Language: perl
" Maintainer: David Nebauer <david@nebauer.org>
" Last Change: 2015-05-18
" Remark: auxiliary support for modern perl features

" syntax from MooseX::App(::Simple)
syn match perlStatementProc '\<\%(parameter\|options\|cmd_tags\|cmd_flag\|cmd_aliases\|cmd_split\|cmd_position\|cmd_env\|cmd_count\|short\|order\|handles_via\|format\|autosplit\)\>'

" syntax from Readonly
syn match perlStatementReadonly '\<\%(Readonly\s\+my\)\>'
command! -nargs=+ HiLinkRO hi def link <args>
HiLinkRO perlStatementReadonly perlStatement
