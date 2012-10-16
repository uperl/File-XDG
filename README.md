NAME
    "File::XDG" - Basic implementation of the XDG base directory
    specification

SYNOPSIS
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

DESCRIPTION
    This module provides a basic implementation of the XDG base directory
    specification as defined by the Free Desktop Organization (FDO). It
    supports all XDG directories except for the runtime directories, which
    require session management support in order to function.

CONSTRUCTOR
  $xdg = File::XDG->new( %args )
    Returns a new instance of a "File::XDG" object. This must be called with
    an application name as the "name" argument.

    Takes the following named arguments:

    name => STRING
            Name of the application for which File::XDG is being used.

METHODS
  $xdg->data_home()
    Returns the user-specific data directory for the application.

  $xdg->config_home()
    Returns the user-specific configuration directory for the application.

  $xdg->cache_home()
    Returns the user-specific cache directory for the application.

  $xdg->data_dirs()
    Returns the system data directories, not modified for the application.
    Per the specification, the returned string is :-delimited.

  $xdg->config_dirs()
    Returns the system config directories, not modified for the application.
    Per the specification, the returned string is :-delimited.

AUTHOR
    Kiyoshi Aman <kiyoshi.aman@gmail.com>

