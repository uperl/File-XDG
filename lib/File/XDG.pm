package File::XDG;

use strict;
use warnings;
use feature qw(:5.10);

our $VERSION = 0.03;

use Carp qw(croak);

use Path::Class;
use File::HomeDir;

=head1 NAME

C<File::XDG> - Basic implementation of the XDG base directory specification

=head1 SYNOPSIS

 use File::XDG;
 
 my $xdg = File::XDG->new('foo');

 # user config
 $xdg->config_home

 # user data
 $xdg->data_home

 # user cache
 $xdg->cache_home

 # system config
 $xdg->config_dirs

 # system data
 $xdg->data_dirs

=head1 DESCRIPTION

This module provides a basic implementation of the XDG base directory
specification as exists by the Free Desktop Organization (FDO). It supports
all XDG directories except for the runtime directories, which require session
management support in order to function.

=cut

=head1 CONSTRUCTOR

=cut

=head2 $xdg = File::XDG->new( %args )

Returns a new instance of a C<File::XDG> object. This must be called with an
application name as the C<name> argument.

Takes the following named arguments:

=over 8

=item name => STRING

Name of the application for which File::XDG is being used.

=back

=cut

sub new {
    my $class = shift;
    my %args = (@_);

    my $self = {
        name => delete $args{name} // croak('application name required'),
    };

    return bless $self, $class || ref $class;
}

sub _win {
    my ($type) = @_;

    return File::HomeDir->my_data;
}

sub _home {
    my ($type) = @_;
    my $home = $ENV{HOME};

    return _win($type) unless ($^O !~ /win/i);

    given ($type) {
        when ('data') {
            return "$home/.local/share/"
        } when ('config') {
            return "$home/.config/"
        } when ('cache') {
            return "$home/.cache/"
        } default {
            croak 'invalid user home requested'
        }
    }
}

=head1 METHODS

=cut

=head2 $xdg->data_home()

Returns the user-specific data directory for the application.

=cut

sub data_home {
    my $self = shift;

    my $xdg;

    if (defined($ENV{XDG_DATA_HOME})) {
        $xdg = $ENV{XDG_DATA_HOME};
    } else {
        $xdg = _home('data');
    }

    return dir($xdg, $self->{name});
}

=head2 $xdg->config_home()

Returns the user-specific configuration directory for the application.

=cut

sub config_home {
    my $self = shift;

    my $xdg;

    if (defined($ENV{XDG_CONFIG_HOME})) {
        $xdg = $ENV{XDG_CONFIG_HOME};
    } else {
        $xdg = _home('config');
    }

    return dir($xdg, $self->{name});
}

=head2 $xdg->cache_home()

Returns the user-specific cache directory for the application.

=cut

sub cache_home {
    my $self = shift;

    my $xdg;

    if (defined($ENV{XDG_CACHE_HOME})) {
        $xdg = $ENV{XDG_CACHE_HOME};
    } else {
        $xdg = _home('cache');
    }

    return dir($xdg, $self->{name});
}

=head2 $xdg->data_dirs()

Returns the system data directories, not modified for the application. Per the
specification, the returned string is :-delimited.

=cut

sub data_dirs {
    my $self = shift;

    if (defined($ENV{XDG_DATA_DIRS})) {
        return $ENV{XDG_DATA_DIRS};
    } else {
        return '/usr/local/share:/usr/share'
    }
}

=head2 $xdg->config_dirs()

Returns the system config directories, not modified for the application. Per
the specification, the returned string is :-delimited.

=cut

sub config_dirs {
    my $self = shift;

    if (defined($ENV{XDG_CONFIG_DIRS})) {
        return $ENV{XDG_CONFIG_DIRS};
    } else {
        return '/etc/xdg'
    }
}

=head1 ACKNOWLEDGEMENTS

This module's Windows support is made possible by C<File::HomeDir>. I would also like to thank C<Path::Class>. 

=head1 AUTHOR

Kiyoshi Aman <kiyoshi.aman@gmail.com>

=cut

1;
