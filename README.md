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
my @dirs = $xdg->config_dirs_list;

# system data
my @dirs = $xdg->data_dirs_list;
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

- api

    The API version to use.

    - api = 0

        The default and original API version.

    - api = 1

        Currently experimental API version.  This will issue a warning when invoked
        until version `1.00` is released.  At this point the version 1 API will
        be stable.

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
specification, the returned string is `:`-delimited, except on Windows where it
is `;`-delimited.

For portability ["data\_dirs\_list"](#data_dirs_list) is preferred.

## data\_dirs\_list

\[version 0.06\]

```perl
my @dirs = $xdg->data_dirs_list;
```

Returns the system data directories as a list of [Path::Class](https://metacpan.org/pod/Path::Class) objects.

## config\_dirs

```perl
my $dirs = $xdg->config_dirs;
```

Returns the system config directories, not modified for the application. Per
the specification, the returned string is :-delimited, except on Windows where it
is `;`-delimited.

For portability ["config\_dirs\_list"](#config_dirs_list) is preferred.

## config\_dirs\_list

\[version 0.06\]

```perl
my @dirs = $xdg->config_dirs_list;
```

Returns the system config directories as a list of [Path::Class](https://metacpan.org/pod/Path::Class) objects.

## lookup\_data\_file

```perl
# api = 0
my $path = $xdg->lookup_data_file($subdir, $filename);
```

Looks up the data file by searching for `./$subdir/$filename` relative to all base
directories indicated by `$XDG_DATA_HOME` and `$XDG_DATA_DIRS`. If an environment
variable is either not set or empty, its default value as defined by the
specification is used instead. Returns a [Path::Class](https://metacpan.org/pod/Path::Class) object.

```perl
# api = 1
my $path = $xdg->lookup_data_File($filename);
```

Looks up the data file by searching for `./$name/$filename` (where `$name` is
provided by the constructor) relative to all base directories indicated by
`$XDG_DATA_HOME` and `$XDG_DATA_DIRS`. If an environment variable is either
not set or empty, its default value as defined by the specification is used
instead. Returns a [Path::Class](https://metacpan.org/pod/Path::Class) object.

## lookup\_config\_file

```perl
# api = 0
my $path = $xdg->lookup_config_file($subdir, $filename);
```

Looks up the configuration file by searching for `./$subdir/$filename` relative to
all base directories indicated by `$XDG_CONFIG_HOME` and `$XDG_CONFIG_DIRS`. If an
environment variable is either not set or empty, its default value as defined
by the specification is used instead. Returns a [Path::Class](https://metacpan.org/pod/Path::Class) object.

```perl
# api = 1
my $path = $xdg->lookup_config_file($filename);
```

Looks up the configuration file by searching for `./$name/$filename` (where `$name` is
provided by the constructor) relative to all base directories indicated by
`$XDG_CONFIG_HOME` and `$XDG_CONFIG_DIRS`. If an environment variable is
either not set or empty, its default value as defined by the specification
is used instead. Returns a [Path::Class](https://metacpan.org/pod/Path::Class) object.

# SEE ALSO

[XDG Base Directory specification, version 0.7](http://standards.freedesktop.org/basedir-spec/basedir-spec-latest.html)

# CAVEATS

This module intentionally and out of necessity does not follow the spec on the following platforms:

- `MSWin32` (Strawberry Perl, Visual C++ Perl, etc)

    The spec requires `:` as the path separator, but use of this character is essential for absolute path names in
    Windows, so the Windows Path separator `;` is used instead.

    There are no global data or config directories in windows so the data and config directories are empty list instead of
    the default UNIX locations.

    The base directory instead of being the user's home directory is `%LOCALAPPDATA%`.  Arguably the data and config
    base directory should be `%APPDATA%`, but cache should definitely be in `%LOCALAPPDATA%`, and we chose to use just one
    base directory for simplicity.

# SEE ALSO

- [Path::Class](https://metacpan.org/pod/Path::Class)

    Portable native path class used by this module.

- [Path::Spec](https://metacpan.org/pod/Path::Spec)

    Core Perl library for working with file and directory paths.

- [File::BaseDir](https://metacpan.org/pod/File::BaseDir)

    Provides similar functionality to this module with a different interface.

# AUTHOR

Original author: Síle Ekaterin Aman

Current maintainer: Graham Ollis <plicease@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2012-2021 by Síle Ekaterin Aman.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
