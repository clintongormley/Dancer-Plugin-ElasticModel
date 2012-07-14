package Dancer::Plugin::ElasticModel;

use strict;
use warnings;

use Dancer qw(:syntax);
use Dancer::Plugin;

my $Model;

#===================================
register emodel => sub {
#===================================
    return $Model || _setup_model();
};

#===================================
sub _setup_model {
#===================================
    my $settings = plugin_setting;

    my $model_class = $settings->{model}
        or die "Missing required setting (model)";

    eval "require $model_class"
        or die "Error loading model ($model_class): " . ( $@ || 'Unknown' );

    my $es = ElasticSearch->new( %{ $settings->{es} || {} } );
    $Model = $model_class->new( es => $es );
}

register_plugin;

true;

# ABSTRACT: Use Elastic::Model in your Dancer application

=head1 SYNOPSIS

    use Dancer::Plugin::ElasticModel;

    emodel->domain('myapp')->create( user => { name => 'Joe Bloggs' });

    my $results = emodel->view->search;

=head1 DESCRIPTION

Easy access to your L<Elastic::Model>-based application from within your
L<Dancer> apps.

=head1 METHODS

=head2 emodel()

When you C<use Dancer::Plugin::ElasticModel;> it will import a single method
C<emodel()> which gives you access to the model that you have configured in
your C<config.yml> file.

=head1 CONFIG

    plugins:
        ElasticModel:
            model:          MyApp
            es:
                servers:    es1.mydomain.com:9200
                transport:  http


The C<model> should be the name of your model class (which uses L<Elastic::Model>).
Any parameters specified in C<es> will be passed directly to L<ElasticSearch/new()>.

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

