#!/usr/bin/env perl
use strict;
use warnings;

BEGIN { $ENV{SHELL} = "/bin/bash" }

use FindBin;
use lib $FindBin::Bin;
use App::perlbrew;
require "test_helpers.pl";

use File::Temp qw( tempdir );
use File::Spec::Functions qw( catdir );
use File::Path::Tiny;
use Test::Spec;
use Test::Output;
use Config;

mock_perlbrew_install("perl-5.14.1");

describe "env command," => sub {
    describe "when invoked with a perl installation name", sub {
        it "displays environment variables that should be set to use the given perl." => sub {
            my $app = App::perlbrew->new("env", "perl-5.14.1");

            stdout_is {
                $app->run;
            } <<"OUT";
export PERLBREW_PERL=perl-5.14.1
export PERLBREW_VERSION=$App::perlbrew::VERSION
export PERLBREW_PATH=$App::perlbrew::PERLBREW_ROOT/bin:$App::perlbrew::PERLBREW_ROOT/perls/perl-5.14.1/bin
export PERLBREW_ROOT=$App::perlbrew::PERLBREW_ROOT
OUT
        };
    };

    describe "when invoked with a perl installation name with lib name", sub {
        it "displays environment variables that should be set to use the given perl." => sub {
            note 'perlbrew env perl-5.14.1@nobita';

            my $PERL5LIB_maybe = $ENV{PERL5LIB} ? ":\$PERL5LIB" : "";
            my $app = App::perlbrew->new("env", 'perl-5.14.1@nobita');

            my $lib_dir = "$App::perlbrew::PERLBREW_HOME/libs/perl-5.14.1\@nobita";
            stdout_is {
                $app->run;
            } <<"OUT";
export PERLBREW_PERL=perl-5.14.1
export PERLBREW_LIB=nobita
export PERLBREW_VERSION=$App::perlbrew::VERSION
export PERLBREW_PATH=$lib_dir/bin:$App::perlbrew::PERLBREW_ROOT/bin:$App::perlbrew::PERLBREW_ROOT/perls/perl-5.14.1/bin
export PERLBREW_ROOT=$App::perlbrew::PERLBREW_ROOT
export PERL5LIB=$lib_dir/lib/perl5/$Config{archname}:$lib_dir/lib/perl5${PERL5LIB_maybe}
OUT
        }
    }
};

runtests unless caller;

