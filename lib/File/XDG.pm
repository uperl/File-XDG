package File::XDG;

use strict;
use warnings;
use Carp qw(croak);
use Path::Class qw(dir file);
use File::HomeDir;

# ABSTRACT: Basic implementation of the XDG base directory specification
# VERSION:

=head1 SYNOPSIS

 use File::XDG;

 my $xdg = File::XDG->new(name => 'foo');

 # user config
 my $path = $xdg->config_home;

 # user data
 my $path = $xdg->data_home;

 # user cache
 my $path = $xdg->cache_home;

 # system config
 my @dirs = split /:/, $xdg->config_dirs;

 # system data
 my @dirs = split /:/, $xdg->data_dirs;

=head1 DESCRIPTION

This module provides a basic implementation of the XDG base directory
specification as exists by the Free Desktop Organization (FDO). It supports
all XDG directories except for the runtime directories, which require session
management support in order to function.

=cut

=head1 CONSTRUCTOR

=cut

=head2 new

 my $xdg = File::XDG->new( %args );

Returns a new instance of a L<File::XDG> object. This must be called with an
application name as the L</name> argument.

Takes the following named arguments:

=over 4

=item name

Name of the application for which File::XDG is being used.

=back

=cut

sub new {
    my $class = shift;
    my %args = (@_);

    my $name = delete $args{name};
    croak('application name required') unless defined $name;

    my $self = {
        name => $name,
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

    $home = _win($type) if ($^O eq 'MSWin32');

    my %locations = (
        data => ($ENV{XDG_DATA_HOME} || "$home/.local/share/"),
        cache => ($ENV{XDG_CACHE_HOME} || "$home/.cache/"),
        config => ($ENV{XDG_CONFIG_HOME} || "$home/.config/"),
    );

    return $locations{$type} if exists $locations{$type};
    croak 'invalid _home requested';
}

sub _dirs {
    my $type = shift;

    my %locations = (
        data => ($ENV{XDG_DATA_DIRS} || '/usr/local/share:/usr/share'),
        config => ($ENV{XDG_CONFIG_DIRS} || '/etc/xdg'),
    );

    return $locations{$type} if exists $locations{$type};
    croak 'invalid _dirs requested';
}

sub _lookup_file {
    my ($self, $type, @subpath) = @_;

    unless (@subpath) {
        croak 'subpath not specified';
    }

    my @dirs = (_home($type), split(/:/, _dirs($type)));
    my @paths = map { file($_, @subpath) } @dirs;
    my ($match) = grep { -f $_ } @paths;

    return $match;
}

=head1 METHODS

=head2 data_home

 my $path = $xdg->data_home;

Returns the user-specific data directory for the application as a L<Path::Class> object.

=cut

sub data_home {
    my $self = shift;
    my $xdg = _home('data');
    return dir($xdg, $self->{name});
}

=head2 config_home

 my $path = $xdg->config_home;

Returns the user-specific configuration directory for the application as a L<Path::Class> object.

=cut

sub config_home {
    my $self = shift;
    my $xdg = _home('config');
    return dir($xdg, $self->{name});
}

=head2 cache_home

 my $path = $xdg->cache_home;

Returns the user-specific cache directory for the application as a L<Path::Class> object.

=cut

sub cache_home {
    my $self = shift;
    my $xdg = _home('cache');
    return dir($xdg, $self->{name});
}

=head2 data_dirs

 my $dirs = $xdg->data_dirs;

Returns the system data directories, not modified for the application. Per the
specification, the returned string is :-delimited.

=cut

sub data_dirs {
    return _dirs('data');
}

=head2 config_dirs

 my $dirs = $xdg->config_dirs;

Returns the system config directories, not modified for the application. Per
the specification, the returned string is :-delimited.

=cut

sub config_dirs {
    return _dirs('config');
}

=head2 lookup_data_file

 my $path = $xdg->lookup_data_file($subdir, $filename);

Looks up the data file by searching for C<./$subdir/$filename> relative to all base
directories indicated by $XDG_DATA_HOME and $XDG_DATA_DIRS. If an environment
variable is either not set or empty, its default value as defined by the
specification is used instead. Returns a L<Path::Class> object.

=cut

sub lookup_data_file {
    my ($self, @subpath) = @_;
    return $self->_lookup_file('data', @subpath);
}

=head2 lookup_config_file

 my $path = $xdg->lookup_config_file($subdir, $filename);

Looks up the configuration file by searching for C<./$subdir/$filename> relative to
all base directories indicated by $XDG_CONFIG_HOME and $XDG_CONFIG_DIRS. If an
environment variable is either not set or empty, its default value as defined
by the specification is used instead. Returns a L<Path::Class> object.

=cut

sub lookup_config_file {
    my ($self, @subpath) = @_;
    return $self->_lookup_file('config', @subpath);
}

=head1 SEE ALSO

L<XDG Base Directory specification, version 0.7|http://standards.freedesktop.org/basedir-spec/basedir-spec-latest.html>

=head1 ACKNOWLEDGEMENTS

This module's Windows support is made possible by L<File::HomeDir>. I would also like to thank L<Path::Class> and L<File::Spec>.

=cut

1;
