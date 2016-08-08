package Dn::Package;

use Moo;    #                                                          {{{1
use strictures 2;
use 5.006;
use 5.22.1;
use version; our $VERSION = qv('0.1');
use namespace::clean;

use autodie qw(open close);
use Carp qw(confess);
use Dn::Common;
use Dn::InteractiveIO;
use Dn::Menu;
use English qw(-no_match_vars);
use Function::Parameters;
use MooX::HandlesVia;
use Path::Tiny;
use Readonly;
use Sys::Syslog qw(:DEFAULT setlogsock);
use Try::Tiny;
use Types::Standard;
use experimental 'switch';

Readonly my $TRUE  => 1;
Readonly my $FALSE => 0;
my $cp = Dn::Common->new();
my $io = Dn::InteractiveIO->new;
Sys::Syslog::openlog( 'ident', 'user' );    #                        }}}1
        # ident is prepended to every message - adapt to module
        # user is the most commonly used facility - leave as is

# debug
use Data::Dumper::Simple;

# attributes

# log                                                                  {{{1
has 'log' => (
    is            => 'ro',
    isa           => Types::Standard::Bool,
    required      => $FALSE,
    default       => $FALSE,
    documentation => 'Whether to write status messages to system log',
);

# _attr_1                                                              {{{1
has '_attr_1' => (
    is            => 'lazy',
    isa           => Types::Standard::Str,
    documentation => 'Insert here',
);

method _build__attr_1 () {
    return My::App->new->get_value;
}

# _attr_list                                                       ____{{{1
has '_attr_list' => (
    is  => 'rw',
    isa => Types::Standard::ArrayRef [
        Types::Standard::InstanceOf ['Config::Simple']
    ],
    lazy        => $TRUE,
    default     => sub { [] },
    handles_via => 'Array',
    handles     => {
        _attrs    => 'elements',
        _add_attr => 'push',
        _has_attr => 'count',
    },
    documentation => 'Array of values',
);    #                                                                }}}1

# methods

# my_method($thing)                                                    {{{1
#
# does:   it does stuff
# params: $thing - for this [optional, default=grimm]
# prints: nil
# return: scalar boolean
method my_method ($thing) {
    $io->say('This is feedback');
}

# _log($msg, [$type])                                              {{{1
#
# does:   log message if logging
# params: $msg  - message [scalar string, optional, no default]
#         $type - message type [scalar string, optional, default=INFO]
#                 can be EMERG|ALERT|CRIT|ERR|WARNING|NOTICE|INFO|DEBUG
# prints: nil
# return: n/a, dies on failure
# note:   appends most recent system error message for message types
#         EMERG, ALERT, CRIT and ERR
method _log ($msg, $type) {

    # only log if logging
    return if not $self->log;

    # check params
    return if not defined $msg;
    if ( not $type ) { $type = 'INFO'; }
    my %valid_type = map { ( $_ => $TRUE ) }
        qw(EMERG ALERT CRIT ERR WARNING NOTICE INFO DEBUG);
    if ( not $valid_type{$type} ) { $self->_fail("Invalid type '$type'"); }

    # display system error message for serious message types
    my %error_type = map { ( $_ => $TRUE ) } qw(EMERG ALERT CRIT ERR);
    if ( $error_type{$type} ) { $msg .= ': %m'; }

    # log message
    Sys::Syslog::syslog( $type, $msg );

    return;
}

# _fail($err)                                                          {{{1
#
# does:   print stack trace if interactive, log message if logging,
#         and exit with error status
#
# params: $err - error message [scalar string, required]
# prints: error message
# return: n/a, dies on completion
method _fail ($err) {

    # log error message (if logging)
    $self->_log( $err, 'ERR' );

    # exit with failure status, printing stack trace if interactive
    if   ( $io->interactive ) { confess $err; }
    else                      { exit 1; }
}

# _other($err)                                                         {{{1
#
# does:   do the other thing
#
# params: nil
# prints: error message
# return: n/a, dies on completion
method _other () {
}    #                                                                 }}}1


1;

# POD                                                                  {{{1
__END__

=head1 NAME

My::Module - what I do

=head1 SYNOPSIS

    use My::Module;
    ...

=head1 DESCRIPTION

Full description. May have subsections.

=head1 ATTRIBUTES

=head2 attr_1

Does stuff...

Scalar string. Required.

=head1 METHODS

=head2 method1($param)

=head3 Purpose

Method purpose.

=head3 Parameters

=over

=item $param

Parameter details. Scalar string.

Required.

=back

=head1 DIAGNOSTICS

Supposedly a listing of every error and warning message
that the module can generate (even the ones that will
"never happen"), with a full explanation of each problem,
one or more likely causes, and any suggested remedies.

Really?

=head1 CONFIGURATION AND ENVIRONMENT

Config files and locations, and available settings.

Config variables, and available settings.

=head1 DEPENDENCIES

=head2 Perl modules

autodie, Carp, Dn::InteractiveIO, Dn::Common, Dn::Menu, English, experimental, Function::Parameters, Moo, MooX::HandlesVia, namespace::clean, Path::Tiny, Readonly, Sys::Syslog, strictures, Try::Tiny, Types::Common::Numeric, Types::Common::String, Types::Path::Tiny, Types::Standard, version.

=back

=head2 Executables

wget.

=head2 INCOMPATIBILITIES

Modules this one cannot be used with, and why.

=head1 BUGS AND LIMITATIONS

Please report any bugs to the author.

=head1 AUTHOR

David Nebauer E<lt>davidnebauer@hotkey.net.auE<gt>

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2016 ${author}

This script is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
# vim:fdm=marker
