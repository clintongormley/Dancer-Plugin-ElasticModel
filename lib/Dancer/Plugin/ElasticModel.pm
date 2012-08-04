package Dancer::Plugin::ElasticModel;

use strict;
use warnings;

use Dancer qw(:syntax);
use Dancer::Plugin;

#===================================
register emodel => sub {
#===================================
    return _setup_model()->{model};
};

#===================================
register eview => sub {
#===================================
    my $cache = _setup_model();
    if ( @_ == 1 ) {
        my $view = shift || '';
        return $cache->{views}{$view}
            || die "Unknown view ($view)";
    }
    return $cache->{model}->view(@_);
};

#===================================
register edomain => sub {
#===================================
    my $domain = shift || '';
    return _setup_model()->{model}->domain($domain);
};

#===================================
sub _setup_model {
#===================================
    my $settings = plugin_setting;
    my $cache    = $settings->{_cache};
    return $cache if $cache;

    my $model_class = $settings->{model}
        or die "Missing required setting (model)";

    my ( $res, $err ) = Dancer::ModuleLoader->load($model_class);
    die "Error loading model ($model_class): $err"
        unless $res;

    my $es = ElasticSearch->new( %{ $settings->{es} || {} } );
    my $model = $model_class->new( es => $es );

    my $view_conf = $settings->{views} || {};
    my %views = map { $_ => $model->view( %{ $view_conf->{$_} } ) }
        keys %$view_conf;

    return $settings->{_cache} = {
        model => $model,
        views => \%views,
    };
}

register_plugin;

true;

# ABSTRACT: Use Elastic::Model in your Dancer application

=head1 SYNOPSIS

    use Dancer::Plugin::ElasticModel;

    emodel->namespace('myapp')->index->create;

    edomain('myapp')->create( user => { name => 'Joe Bloggs' });

    my $results = eview('users)->search;

=head1 DESCRIPTION

Easy access to your L<Elastic::Model>-based application from within your
L<Dancer> apps.

=head1 CONFIG

    plugins:
        ElasticModel:
            model:          MyApp
            es:
                servers:    es1.mydomain.com:9200
                transport:  http
            views:
                users:
                    domain: myapp
                    type:   user

The C<model> should be the name of your model class (which uses
L<Elastic::Model>). Any parameters specified in C<es> will be passed
directly to L<ElasticSearch/new()>.

Optionally, you can predefine named L<views|Elastic::Model::View>, eg
the C<users> view above is the equivalent of:

    $view = $model->view( domain => 'myapp', type => 'user' );

=head1 METHODS

=head2 emodel()

L</emodel()> gives you access to the model that you have configured in
your C<config.yml> file.

=head2 edomain()

    $domain = edomain('mydomain');

L</edomain()> is a shortcut for:

    $domain = emodel->domain('mydomain');

=head2 eview()

Access the C<views> that you predefined in your L</CONFIG>:

    $users = eview('users')->search;

Or create a new view:

    $users = eview(domain=>'myapp', type => 'user');
    $users = eview->domain('myapp')->type('user');

=head1 SEE ALSO

=over

=item *

L<Elastic::Model>

=item *

L<Dancer>

=item *

L<ElasticSearch>

=back


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Dancer::Plugin::ElasticModel

You can also look for information at:

=over

=item * GitHub

L<http://github.com/clintongormley/Dancer-Plugin-ElasticModel>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Dancer-Plugin-ElasticModel>

=item * Search MetaCPAN

L<https://metacpan.org/module/Dancer::Plugin::ElasticModel>

=back

