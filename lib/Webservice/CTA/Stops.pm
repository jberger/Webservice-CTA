package Webservice::CTA::Stops;
use Mojo::Base -base;

use Webservice::CTA::Stop;
use Text::ParseWords ();

has 'stops' => sub {
  my $self = shift;
  $self->parse_file;
};

has 'file';

sub parse_file {
  my $self = shift;
  my $file = shift || $self->file || die "Need a file to parse";

  open my $fh, '<', $file or die "Cannot open $file: $!\n";
  <$fh>; #skip header

  my $spec = Webservice::CTA::Stop->spec;

  my @stops;
  while (my $line = <$fh>) {
    chomp $line;
    $line =~ s/'/\\'/g; # escape single quotes
    my %fields;
    @fields{@$spec} = Text::ParseWords::parse_line( ',', 0, $line );
    push @stops, Webservice::CTA::Stop->new(%fields);
  }

  return \@stops;
}

1;


