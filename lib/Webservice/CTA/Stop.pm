package Webservice::CTA::Stop;
use Mojo::Base -base;

# This spec is in order of the CSV fields, but with the names for this class
my $spec = [qw/
  stop_id direction stop_name
  lon lat
  station_name station_descriptive_name parent_stop_id is_ada
  red blue brown green purple purple_express yellow pink orange
/];

has $spec;

sub spec { $spec }

1;

