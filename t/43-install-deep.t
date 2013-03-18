#!perl

use strict;
use warnings;

use Test::More;
use Test::File;
use Test::Exception;

use Path::Class qw(dir);
use File::Which qw(which);

use Pinto::Tester;
use Pinto::Tester::Util qw(make_dist_archive);

#------------------------------------------------------------------------------

my $cpanm_exe = which('cpanm');
plan skip_all => 'cpanm required for install tests' unless $cpanm_exe;

my $min_cpanm   = 1.5013;
my ($cpanm_ver) = qx{$cpanm_exe --version} =~ m{version ([\d._]+)};
plan skip_all => "Need cpanm $min_cpanm or newer" unless $cpanm_ver >= $min_cpanm;

#------------------------------------------------------------------------------

warn "You will see some messages from cpanm, don't be alarmed...\n";

#------------------------------------------------------------------------------

my $upstream = Pinto::Tester->new;
$upstream->populate('JOHN/DistA-1 = PkgA~1');

my $local = Pinto::Tester->new(init_args => {sources => $upstream->stack_url});
$local->populate('MARK/DistB-1 = PkgB~1 & PkgA~1');

#------------------------------------------------------------------------------

{
  my $buffer = '';
  my $sandbox = File::Temp->newdir;
  my $p5_dir = dir($sandbox, qw(lib perl5));
  my %cpanm_opts = (cpanm_options => {q => undef, L => $sandbox->dirname});
  $local->run_ok(Install => {targets => ['PkgB'], %cpanm_opts, out => \$buffer, do_pull =>1});

  file_exists_ok($p5_dir->file('PkgA.pm'));
  file_exists_ok($p5_dir->file('PkgB.pm'));
}

#------------------------------------------------------------------------------

done_testing;

