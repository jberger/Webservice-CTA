#!/usr/bin/env perl

use strict;
use warnings;
use v5.10;

BEGIN{
  for ( qw'lib ../lib' ) {
    unshift @INC, $_ if -d;
  }
}

use Webservice::CTA;

my $cta = Webservice::CTA->new;
#say for $cta->get_diffs;

say $_->stop_id for @{ $cta->stops->stops };

