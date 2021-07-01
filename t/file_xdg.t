use strict;
use warnings;
use Test::More;
use File::XDG;
use File::Temp;
use File::Path qw(make_path);

subtest 'env' => sub {
  my $xdg = File::XDG->new(name => 'test');

  {
    local $ENV{XDG_CONFIG_HOME} = '/home/user/.config';
    ok($xdg->config_home eq '/home/user/.config/test', 'user-specific app configuration');
  }
  {
    local $ENV{XDG_DATA_HOME} = '/home/user/.local/share';
    ok($xdg->data_home eq '/home/user/.local/share/test', 'user-specific app data');
  }
  {
    local $ENV{XDG_CACHE_HOME} = '/home/user/.cache';
    ok($xdg->cache_home eq '/home/user/.cache/test', 'user-specific app cache');
  }
  {
    local $ENV{XDG_DATA_DIRS} = '/usr/local/share:/usr/share';
    ok($xdg->data_dirs eq '/usr/local/share:/usr/share', 'system-wide data directories');
  }
  {
    local $ENV{XDG_CONFIG_DIRS} = '/etc/xdg';
    ok($xdg->config_dirs eq '/etc/xdg', 'system-wide configuration directories');
  }
};

subtest 'noenv' => sub {
  my $xdg = File::XDG->new(name => 'test');

  {
    local $ENV{HOME} = '/home/test';
    local $ENV{XDG_CONFIG_HOME};
    is($xdg->config_home, '/home/test/.config/test', 'user-specific app configuration');
    local $ENV{XDG_DATA_HOME};
    is($xdg->data_home, '/home/test/.local/share/test', 'user-specific app data');
    local $ENV{XDG_CACHE_HOME};
    is($xdg->cache_home, '/home/test/.cache/test', 'user-specific app cache');
  }
};

subtest 'lookup' => sub {
  local $ENV{HOME} = File::Temp->newdir();
  local $ENV{XDG_DATA_DIRS} = File::Temp->newdir();
  local $ENV{XDG_CONFIG_DIRS} = File::Temp->newdir();

  subtest 'data_home' => sub {
    plan tests => 6;
    test_lookup('data_home', 'data_dirs', 'lookup_data_file');
  };

  subtest 'config_home' => sub {
    plan tests => 6;
    test_lookup('config_home', 'config_dirs', 'lookup_config_file');
  };
};

sub test_lookup {
  my ($home_m, $dirs_m, $lookup_m) = @_;

  my $name = 'test';
  my $xdg = File::XDG->new(name => $name);

  my @subpath = ('subdir', 'filename');
  my $home = ($xdg->$home_m =~ /(.*)$name/)[0];
  my $dir  = $xdg->$dirs_m;

  make_file($home, @subpath);
  make_file($dir, @subpath);

  my $home_file = File::Spec->join($home, @subpath);
  my $dir_file = File::Spec->join($dir, @subpath);

  ok(-f $home_file, "created file in $home_m");
  ok(-f $dir_file, "created file in $dirs_m");

  isnt($home_file, $dir_file, "created distinct files in $home_m and $dirs_m");
  is($xdg->$lookup_m(@subpath), $home_file, "lookup found file in $home_m");
  unlink($home_file);
  is($xdg->$lookup_m(@subpath), $dir_file, "after removing file in $home_m, lookup found file in $dirs_m");
  unlink($dir_file);
  is($xdg->$lookup_m(@subpath), undef, "after removing file in $dirs_m, lookup did not find file");
}

sub make_file {
  my (@path) = @_;

  my $filename = pop @path;
  my $directory = File::Spec->join(@path);
  my $path = File::Spec->join($directory, $filename);

  make_path($directory);

  my $file = IO::File->new($path, 'w');
  $file->close;
}

done_testing;
