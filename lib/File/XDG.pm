package File::XDG;

use strict;
use warnings;
use Carp qw(croak);
use Path::Class qw(dir file);
use Config;
use if $^O eq 'MSWin32', 'Win32';

# ABSTRACT: Basic implementation of the XDG base directory specification
# VERSION

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
 my @dirs = $xdg->config_dirs_list;

 # system data
 my @dirs = $xdg->data_dirs_list;

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

    corak("unknown arguments: @{[ sort keys %args ]}") if %args;

    my $self = bless {
        name => $name,
    }, $class;

    if($^O eq 'MSWin32') {
        my $local = Win32::GetFolderPath(Win32::CSIDL_LOCAL_APPDATA(), 1);
        $self->{data}        = $ENV{XDG_DATA_HOME}   || "$local\\.local\\share\\";
        $self->{cache}       = $ENV{XDG_CACHE_HOME}  || "$local\\.cache\\";
        $self->{config}      = $ENV{XDG_CONFIG_HOME} || "$local\\.config\\";
        $self->{data_dirs}   = $ENV{XDG_DATA_DIRS}   || '';
        $self->{config_dirs} = $ENV{XDG_CONFIG_DIRS} || '';
    } else {
        my $home = $ENV{HOME} || [getpwuid($>)]->[7];
        $self->{data}        = $ENV{XDG_DATA_HOME}   || "$home/.local/share/";
        $self->{cache}       = $ENV{XDG_CACHE_HOME}  || "$home/.cache/";
        $self->{config}      = $ENV{XDG_CONFIG_HOME} || "$home/.config/";
        $self->{data_dirs}   = $ENV{XDG_DATA_DIRS}   || '/usr/local/share:/usr/share';
        $self->{config_dirs} = $ENV{XDG_CONFIG_DIRS} || '/etc/xdg';
    }

    return $self;
}

sub _dirs {
    my($self, $type) = @_;
    return $self->{"${type}_dirs"} if exists $self->{"${type}_dirs"};
    croak 'invalid _dirs requested';
}

sub _lookup_file {
    my ($self, $type, @subpath) = @_;

    croak 'subpath not specified' unless @subpath;
    croak "invalid type: $type" unless defined $self->{$type};

    my @dirs = ($self->{$type}, split(/\Q$Config{path_sep}\E/, $self->_dirs($type)));
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
    my $xdg = $self->{data};
    return dir($xdg, $self->{name});
}

=head2 config_home

 my $path = $xdg->config_home;

Returns the user-specific configuration directory for the application as a L<Path::Class> object.

=cut

sub config_home {
    my $self = shift;
    my $xdg = $self->{config};
    return dir($xdg, $self->{name});
}

=head2 cache_home

 my $path = $xdg->cache_home;

Returns the user-specific cache directory for the application as a L<Path::Class> object.

=cut

sub cache_home {
    my $self = shift;
    my $xdg = $self->{cache};
    return dir($xdg, $self->{name});
}

=head2 data_dirs

 my $dirs = $xdg->data_dirs;

Returns the system data directories, not modified for the application. Per the
specification, the returned string is C<:>-delimited, except on Windows where it
is C<;>-delimited.

For portability L</data_dirs_list> is preferred.

=cut

sub data_dirs {
    return shift->_dirs('data');
}

=head2 data_dirs_list

[version 0.06]

 my @dirs = $xdg->data_dirs_list;

Returns the system data directories as a list.

=cut

sub data_dirs_list {
    return split /\Q$Config{path_sep}\E/, shift->data_dirs;
}

=head2 config_dirs

 my $dirs = $xdg->config_dirs;

Returns the system config directories, not modified for the application. Per
the specification, the returned string is :-delimited, except on Windows where it
is C<;>-delimited.

For portability L</config_dirs_list> is preferred.

=cut

sub config_dirs {
    return shift->_dirs('config');
}

=head2 config_dirs_list

[version 0.06]

 my @dirs = $xdg->config_dirs_list;

Returns the system config directories as a list.

=cut

sub config_dirs_list {
    return split /\Q$Config{path_sep}\E/, shift->config_dirs;
}

=head2 lookup_data_file

 my $path = $xdg->lookup_data_file($subdir, $filename);

Looks up the data file by searching for C<./$subdir/$filename> relative to all base
directories indicated by C<$XDG_DATA_HOME> and C<$XDG_DATA_DIRS>. If an environment
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
all base directories indicated by C<$XDG_CONFIG_HOME> and C<$XDG_CONFIG_DIRS>. If an
environment variable is either not set or empty, its default value as defined
by the specification is used instead. Returns a L<Path::Class> object.

=cut

sub lookup_config_file {
    my ($self, @subpath) = @_;
    return $self->_lookup_file('config', @subpath);
}

=head1 SEE ALSO

L<XDG Base Directory specification, version 0.7|http://standards.freedesktop.org/basedir-spec/basedir-spec-latest.html>

=head1 CAVEATS

This module intentionally and out of necessity does not follow the spec on the following platforms:

=over 4

=item C<MSWin32> (Strawberry Perl, Visual C++ Perl, etc)

The spec requires C<:> as the path separator, but use of this character is essential for absolute path names in
Windows, so the Windows Path separator C<;> is used instead.

There are no global data or config directories in windows so the data and config directories are empty list instead of
the default UNIX locations.

The base directory instead of being the user's home directory is C<%LOCALAPPDATA%>.  Arguably the data and config
base directory should be C<%APPDATA%>, but cache should definitely be in C<%LOCALAPPDATA%>, and we chose to use just one
base directory for simplicity.

=back

=head1 SEE ALSO

=over 4

=item L<Path::Class>

Portable native path class used by this module.

=item L<Path::Spec>

Core Perl library for working with file and directory paths.

=item L<File::BaseDir>

Provides similar functionality to this module with a different interface.

=back

=cut

1;
