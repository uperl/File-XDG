# File::XDG ![static](https://github.com/uperl/File-XDG/workflows/static/badge.svg) ![linux](https://github.com/uperl/File-XDG/workflows/linux/badge.svg)

Basic implementation of the XDG base directory specification

# SYNOPSIS

```perl
use File::XDG;

my $xdg = File::XDG->new(name => 'foo');

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
```

# DESCRIPTION

This module provides a basic implementation of the XDG base directory
specification as exists by the Free Desktop Organization (FDO). It supports
all XDG directories except for the runtime directories, which require session
management support in order to function.

# CONSTRUCTOR

## $xdg = File::XDG->new( %args )

Returns a new instance of a `File::XDG` object. This must be called with an
application name as the `name` argument.

Takes the following named arguments:

- name => STRING

    Name of the application for which File::XDG is being used.

# METHODS

## $xdg->data\_home()

Returns the user-specific data directory for the application as a `Path::Class` object.

## $xdg->config\_home()

Returns the user-specific configuration directory for the application as a `Path::Class` object.

## $xdg->cache\_home()

Returns the user-specific cache directory for the application as a `Path::Class` object.

## $xdg->data\_dirs()

Returns the system data directories, not modified for the application. Per the
specification, the returned string is :-delimited.

## $xdg->config\_dirs()

Returns the system config directories, not modified for the application. Per
the specification, the returned string is :-delimited.

## $xdg->lookup\_data\_file('subdir', 'filename');

Looks up the data file by searching for ./subdir/filename relative to all base
directories indicated by $XDG\_DATA\_HOME and $XDG\_DATA\_DIRS. If an environment
variable is either not set or empty, its default value as defined by the
specification is used instead. Returns a `Path::Class` object.

## $xdg->lookup\_config\_file('subdir', 'filename');

Looks up the configuration file by searching for ./subdir/filename relative to
all base directories indicated by $XDG\_CONFIG\_HOME and $XDG\_CONFIG\_DIRS. If an
environment variable is either not set or empty, its default value as defined
by the specification is used instead. Returns a `Path::Class` object.

# SEE ALSO

[XDG Base Directory specification, version 0.7](http://standards.freedesktop.org/basedir-spec/basedir-spec-latest.html)

# ACKNOWLEDGEMENTS

This module's Windows support is made possible by `File::HomeDir`. I would also like to thank `Path::Class` and `File::Spec`.

# AUTHORS

- Kiyoshi Aman <kiyoshi.aman@gmail.com>
- Graham Ollis <plicease@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2012-2021 by Kiyoshi Aman <kiyoshi.aman@gmail.com>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
