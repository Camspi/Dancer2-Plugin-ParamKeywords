use strict;
use warnings;

package Dancer2::Plugin::ParamKeywords;
use Dancer2::Plugin;
use Data::Printer;

our $VERSION = 'v0.0.1';

foreach my $source ( qw( route query body ) ) {
    register "$source\_param" => sub {
        my ($dsl, $param)  = @_;
        $dsl->app->request->params($source)->{$param};
    };
    
    register "$source\_params" => sub {
        my $dsl  = shift;
        $dsl->app->request->params($source); 
    };
}

register munged_params => sub {
     my $dsl = shift;
     my $conf = plugin_setting->{munge_precedence};
     die 'Please configure the plugin settings for ParamKeywords to use this keyword'
       unless ref($conf) eq 'ARRAY';

     my %params = map { $dsl->app->request->params($_) } reverse @$conf;
     wantarray ? %params : \%params;
};

register_plugin for_versions => [ 2 ] ;

1;

# ABSTRACT: Sugar for the params() keyword
# PODNAME: Dancer2::Plugin::ParamKeywords

=head1 SYNOPSIS

    use Dancer2;
    use Dancer2::Plugin::ParamKeywords;

    any '/:some_named_parameter' => sub {
        my $route_param = route_param('some_named_parameter');
        my $get_param   = query_param('some_named_parameter');
        my $post_param  = body_param('some_named_parameter');
    };

=head1 DESCRIPTION

The default L<Dancer2::Core::Request params
accessor|Dancer2::Core::Request/"params($source)">
munges parameters in the following precedence from
highest to lowest: C<POST> parameters, named route parameters,
and C<GET> parameters.

Consider the following route:

    post '/people/:person_id' => sub {
        my $person_id = param('person_id');
        ...
        # Perform some operation using $person_id as a key
    };

In the above example, if the browser/client sends a parameter
C<person_id> with a value of 2 in the C<POST> body to route C</people/1>,
C<$person_id> will equal 2 while still matching the route C</people/1>.

This plugin provides keywords that wrap around C<params($source)>
for convenience to fetch parameter values from specific sources.

=head2 CONFIGURATION

The C<munged_params> keyword requires you to configure an order of
precedence by which to prefer parameter sources.  Please see 
L<Dancer2::Core::Request params accessor|Dancer2::Core::Request/"params($source)">
for a list of valid sources.

    # In config.yml
    plugins:
      ParamKeywords:
        munge_precedence:
          - route
          - body
          - query

If you won't be using this keyword, you don't need to bother configuring
this plugin.

=head1 KEYWORDS

=head2 munged_params

Returns a hash in list context or a hash reference in scalar context of
parameters munged according to the precedence provided in the configuration
file (from highest to lowest).

=head2 query_param(Str)

Returns the value supplied for a given parameter in the query string.

=head2 query_params

Returns the arguments and values supplied by query string. Returns a hash in list context or a hasref in scalar context.

=head2 body_param(Str)

Returns the value supplied for a given parameter in the C<POST> arguments.

=head2 body_params

Returns arguments and values supplied by a C<POST> request.  Returns a hash in list context or a hasref in scalar context.

=head2 route_param(Str)

Returns the value supplied for a given named parameter in the route.

=head2 route_params

Returns the arguments and values suppled by the route. Returns a hash in list context or a hasref in scalar context.
