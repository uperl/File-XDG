# File::XDG ![static](https://github.com/uperl/File-XDG/workflows/static/badge.svg) ![linux](https://github.com/uperl/File-XDG/workflows/linux/badge.svg) ![macos](https://github.com/uperl/File-XDG/workflows/macos/badge.svg)

Basic implementation of the XDG base directory specification

# SYNOPSIS

```perl
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
```

# DESCRIPTION

This module provides a basic implementation of the XDG base directory
specification as exists by the Free Desktop Organization (FDO). It supports
all XDG directories except for the runtime directories, which require session
management support in order to function.

# CONSTRUCTOR

## new

```perl
my $xdg = File::XDG->new( %args );
```

Returns a new instance of a [File::XDG](https://metacpan.org/pod/File::XDG) object. This must be called with an
application name as the ["name"](#name) argument.

Takes the following named arguments:

- name

    Name of the application for which File::XDG is being used.

# METHODS

## data\_home

```perl
my $path = $xdg->data_home;
```

Returns the user-specific data directory for the application as a [Path::Class](https://metacpan.org/pod/Path::Class) object.

## config\_home

```perl
my $path = $xdg->config_home;
```

Returns the user-specific configuration directory for the application as a [Path::Class](https://metacpan.org/pod/Path::Class) object.

## cache\_home

```perl
my $path = $xdg->cache_home;
```

Returns the user-specific cache directory for the application as a [Path::Class](https://metacpan.org/pod/Path::Class) object.

## data\_dirs

```perl
my $dirs = $xdg->data_dirs;
```

Returns the system data directories, not modified for the application. Per the
specification, the returned string is :-delimited.

## config\_dirs

```perl
my $dirs = $xdg->config_dirs;
```

Returns the system config directories, not modified for the application. Per
the specification, the returned string is :-delimited.

## lookup\_data\_file

```perl
my $path = $xdg->lookup_data_file($subdir, $filename);
```

Looks up the data file by searching for `./$subdir/$filename` relative to all base
directories indicated by $XDG\_DATA\_HOME and $XDG\_DATA\_DIRS. If an environment
variable is either not set or empty, its default value as defined by the
specification is used instead. Returns a [Path::Class](https://metacpan.org/pod/Path::Class) object.

## lookup\_config\_file

```perl
my $path = $xdg->lookup_config_file($subdir, $filename);
```

Looks up the configuration file by searching for `./$subdir/$filename` relative to
all base directories indicated by $XDG\_CONFIG\_HOME and $XDG\_CONFIG\_DIRS. If an
environment variable is either not set or empty, its default value as defined
by the specification is used instead. Returns a [Path::Class](https://metacpan.org/pod/Path::Class) object.

# SEE ALSO

[XDG Base Directory specification, version 0.7](http://standards.freedesktop.org/basedir-spec/basedir-spec-latest.html)

# ACKNOWLEDGEMENTS

This module's Windows support is made possible by [File::HomeDir](https://metacpan.org/pod/File::HomeDir). I would also like to thank [Path::Class](https://metacpan.org/pod/Path::Class) and [File::Spec](https://metacpan.org/pod/File::Spec).

# AUTHOR

Original author: Kiyoshi Aman <kiyoshi.aman@gmail.com>

Current maintainer: Graham Ollis <plicease@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2012-2021 by Kiyoshi Aman <kiyoshi.aman@gmail.com>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
