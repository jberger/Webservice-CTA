package Webservice::CTA;
use Mojo::Base -base;

use Mojo::UserAgent;
use Mojo::URL;
use DateTime::Format::Strptime;

use Webservice::CTA::Stops;

has 'strptime'  => sub {
  DateTime::Format::Strptime->new(
    pattern   => '%Y%m%d %T',
    locale    => 'en_US',
    time_zone => 'America/Chicago',
  );
};

has 'key_file' => sub { $ENV{WEBSERVICE_CTA_KEY_FILE} || 'key.dat' };
has 'key'      => sub {
  return $ENV{WEBSERVICE_CTA_KEY} if defined $ENV{WEBSERVICE_CTA_KEY};
  my $key_file = shift->key_file;
  do $key_file or die "Need API key (tried: $key_file)\n";
};

has 'ua'    => sub { Mojo::UserAgent->new };
has 'url'   => 'http://lapi.transitchicago.com/api/1.0/ttarrivals.aspx';
has 'mapid' => 40380;

has 'data_dir' => sub { 
  return 'share' if -d 'share'; # if not installed
  require File::ShareDir;
  my $dist = ref($_[0]) || $_[0];
  $dist =~ s/::/-/g;
  File::ShareDir::dist_dir($dist);  
};
has 'train_stops_filename' => 'cta_L_stops.csv';

has 'stops' => sub {
  my $self = shift;
  Webservice::CTA::Stops->new( file => $self->train_stops_file );
};

sub train_stops_file {
  require File::Spec;
  my $self = shift;
  return File::Spec->catfile( $self->data_dir, $self->train_stops_filename );
}

sub dom_from_mapid {
  my $self = shift;
  my $opts = ref $_[-1] ? pop : {};

  $opts->{mapid} ||= @_ ? shift : $self->mapid;
  $opts->{key}   ||= $self->key;
  $opts->{max} = 5 unless defined $opts->{max};

  my $url = Mojo::URL->new( delete $opts->{url} || $self->url );
  $url->query( %$opts );
  return $self->ua->get($url)->res->dom;
}

sub parse_dt {
  $_[0]->strptime->parse_datetime($_[1]);
}

sub get_diffs {
  my $self = shift;

  my $dom = 
    eval { $_[0]->isa('Mojo::DOM') } 
    ? shift
    : $self->dom_from_mapid(shift);

  my @diffs;
  foreach my $eta ( $dom->find('eta')->each ) {
    my $arr  = $self->parse_dt($eta->arrT);
    my $curr = $self->parse_dt($eta->prdt);
    push @diffs, ($arr - $curr)->minutes;
  }

  return @diffs;
}

1;

