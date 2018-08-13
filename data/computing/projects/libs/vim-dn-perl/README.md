# dn-perl #

A filetype plugin that supplies auxiliary perl support

## Dependencies ##

This ftplugin relies on functions provided by the dn-utils plugin. In fact, the
functions provided by this ftplugin will fail if they cannot detect dn-utils.

## Settings ##

These settings improve the perl coding experience.

g:perl\_include\_pod

* set to true
* causes the pod.vim syntax file to be included with perl.vim

g:perl\_extended\_vars

* set to true
* highlights complex expressions such as: ``@{\[\$x, \$y\]}``

g:perl\_sync\_dist

* set to 250
* increase the context used for highlighting

g:perl\_sub\_signatures

* set to true
* prevents error highlighting of method arguments

g:keywordprg

* default is to search functions: `perldoc -f X`
* set to search functions, variables, general and faq help: `perldoc -f -X || perldoc -v -X || perldoc -X || perldoc -q-X`

## Perltidy ##

Runs a custom perltidy script on the current file. It honours the `method`
keyword and makes changes in place, saving a backup with a '.bak' extension.
See the `perltidy` man page for further details. Relies on the DNP\_PerlTidy()
function.

DNP\_PerlTidy\(params\)

* purpose: run custom `perltidy` utility on the current file
* params: 1 - all parameters \[Hash\], 'mode': calling mode \('insert'|'normal'\)
* return: nil

Mapping

* This feature is mapped by default to '&lt;LocalLeader&gt;t', usually '\\t',
  in both Insert and Normal modes.

Command

* This feature is also invoked by the command ':Tidy'.

## Perlcritic ##

Runs a custom perlcritic script on the current file and displays any policy
violations. This script honors Moo(se) conventions. See the `perlcritic` man
page for further details. Relies on the DNP\_PerlCritic function.

DNP\_PerlCritic\(params\)

* purpose: run custom `perlcritic` utility on the current file
* params: 1 - all parameters \[Hash\], 'mode': calling mode
  \('insert'|'normal'\), 'severity': severity of analysis \(1..5\)
* return: nil

Mapping

* This feature is mapped in both Insert and Normal modes by default to
  '&lt;LocalLeader&gt;cX' where X is the desired severity of analysis \(1, 2,
  3, 4 or 5\), and is usually '\\cX'.

Commands

* This feature is also invoked by the command ':CriticX' where X is the
  severity.

## Syntax ##

This ftplugin assumes the following syntax files from the vim-perl plugin are
in use: moose.vim and method-signatures.vim. At the time of writing these are
all contributed files \(in the 'contrib' directory\) and must be manually
installed in a directory visible to vim.

These useful files are also contributed to the vim-perl ftplugin and are worth
using: try-tiny.vim, carp.vim, and highlight-all-pragmas.vim.

The syntax file provided by this ftplugin relies on the main perl ftplugin
syntax file, and so is installed to an 'after' directory. This auxiliary syntax
file provides support for keywords provided by the MooseX::App\(::Simple\) and
Readonly modules.
