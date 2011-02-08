package WebService::Google::Suggest;

use strict;
use vars qw($VERSION);
$VERSION = '0.04';

use Carp;
use LWP::UserAgent;
use URI::Escape;

use vars qw($CompleteURL);
$CompleteURL = "http://www.google.com/complete/search?hl=en&js=true&qu=";

sub new {
    my $class = shift;
    my $ua    = LWP::UserAgent->new();
    $ua->agent("Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1)");
    bless { ua => $ua }, $class;
}

sub ua { $_[0]->{ua} }

sub complete {
    my ( $self, $query ) = @_;
    my $url = $CompleteURL . uri_escape($query);

    my $response = $self->ua->get($url);
    $response->is_success
        or croak "Google doesn't respond well: ", $response->code;

    my $content = $response->content();
    $content =~ /^window\.google\.ac\.\w+\(\["([^"]+)",\[(.*)\]\)$/
        or croak "Google returns unrecognized format: $content";

    my ( $user_query, $array ) = ( $1, $2 );
    my @results;
    while ( $array =~ /\[([^\]]+)\]/g ) {        
        my $row = $1;
        my ( $query, $count, $rank ) = $row =~ /\"([^"]+)\",\"([\d]+)?\",\"([\d]+)?\"/;
        $count =~ tr/,//d;
        $count += 0; # numify
        $rank  += 0;
        push @results, { query => $query, results => $count, rank => $rank };
    }

    return @results;
}

1;
__END__

=head1 NAME

WebService::Google::Suggest - Google Suggest as an API

=head1 SYNOPSIS

  use WebService::Google::Suggest;

  my $suggest     = WebService::Google::Suggest->new();
  my @suggestions = $suggest->complete("goog");
  for my $suggestion (@suggestions) {
    print "[" . $suggestion->{rank} . "] "
      . $suggestion->{query} . ":"
      . $suggestion->{results} results . "\n";
  }

=head1 DESCRIPTION

WebService::Google::Suggest allows you to use Google Suggest as a Web Service API to retrieve completions to your search query or partial query. This module is based on Adam Stiles' hack (http://www.adamstiles.com/adam/2004/12/hacking_google_.html).

=head1 METHODS

=over 4

=item new

  $suggest = WebService::Google::Suggest->new();

Creates new WebService::Google::Suggest object.

=item complete

  @suggestions = $suggest->complete($query);

Sends your C<$query> to Google web server and fetches suggestions for
the query. Suggestions are in a list of hashrefs, for example with
query "Google":

  @suggestions = (
    { query => "google",         results => 0, rank => 0 },
    { query => "google toolbar", results => 0, rank => 1 },
    ...
  );

Note that C<results> value does NOT contain commas and "results" text.

=item ua

  $ua = $suggest->ua;

Returns underlying LWP::UserAgent object. It allows you to change
User-Agent (Windows IE by default), timeout seconds and various
properties.

=back

=head1 AUTHOR

Tatsuhiko Miyagawa E<lt>miyagawa@bulknews.netE<gt>

Franck Cuny E<lt>franck@lumberjaph.netE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

This module gives you B<NO WARRANTY>.

=head1 SEE ALSO

http://www.adamstiles.com/adam/2004/12/hacking_google_.html

http://www.google.com/webhp?complete=1&hl=en

http://labs.google.com/suggest/faq.html

=cut
