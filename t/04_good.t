use Test::More tests => 7, import => ['!pass'];
use strict;
use warnings;

use lib 't/lib';
use Dancer ':syntax';
use Dancer::Test appdir => path( dirname($0), 'good', 'config.yml' );
use Dancer::Plugin::ElasticModel;

is
    emodel->namespace('foo')->name,
    'foo',
    'Has namespace';

isa_ok
    emodel->es->transport,
    'ElasticSearch::Transport::HTTPTiny',
    'Configured ES';

isa_ok my $domain = edomain('foo'), 'Elastic::Model::Domain', 'edomain';
is $domain->name, 'foo', 'edomain name';

isa_ok my $view = eview('user'), 'Elastic::Model::View', 'eview';
is_deeply $view->domain, ['foo'],  'View has domain foo';
is_deeply $view->type,   ['user'], 'View has type user';

