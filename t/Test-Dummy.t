#!/usr/bin/perl

use lib "t";
use Test::More tests => 20;

BEGIN
{
    use_ok( 'Test::Dummy' );
    use_ok( 'Test::Dummy::Child1' );
}

#ORM::DbLog->write_to_stdout( 1 ); Test::ORM->history_is_enabled( 0 );
#Test::Dummy->_cache->change_size( 0 );

my $error;
my $d1;
my $d2;

$error = ORM::Error->new;
$d1    = Test::Dummy->new( prop=>{ a=>'a', b=>'b', c=>'c' }, error=>$error );

ok( !$error->fatal && $d1 && $d1->a eq 'a' && $d1->b eq 'b' && $d1->c eq 'c', 'new' );

$error = ORM::Error->new;
$d1->update( prop=>{ a=>'aa', b=>'bb' }, error=>$error );

ok( !$error->fatal && $d1 && $d1->a eq 'aa' && $d1->b eq 'bb' && $d1->c eq 'c', 'update' );

$error = ORM::Error->new;
$d1->update( prop=>{ b=>undef }, old_prop=>{ a=>'aa', b=>'bb', c=>'c' }, error=>$error );

ok( !$error->fatal && $d1 && $d1->a eq 'aa' && ! defined $d1->b && $d1->c eq 'c', 'update' );

$error = ORM::Error->new;
$d1->update( prop=>{ b=>'bbb' }, old_prop=>{ a=>'aa', b=>'bb', c=>'c' }, error=>$error );

ok
(
    (
        $d1
        && $d1->a eq 'aa'
        && ! defined $d1->b
        && $d1->c eq 'c'
        && $error->text =~ / do not match properties assumed by user\n$/
    ),
    'update'
);

$error = ORM::Error->new;
$d1->delete( error=>$error );

ok( !$error->fatal, 'delete' );

$error = ORM::Error->new;
$d1 = Test::Dummy::Child1->new( prop=>{ a=>'a', b=>'b', c=>'c', ca=>'ca', cb=>'cb' }, error=>$error );

ok( !$error->fatal && $d1 && $d1->a eq 'a' && $d1->b eq 'b' && $d1->c eq 'c' && $d1->ca eq 'ca' && $d1->cb eq 'cb', 'new' );

$error = ORM::Error->new;
$d1 = Test::Dummy->find( filter=>(Test::Dummy->M->id == $d1->id), error=>$error, lazy_load=>0 );

ok( !$error->fatal && ! exists $d1->{_ORM_missing_tables} && ref $d1 eq 'Test::Dummy::Child1' && $d1->{_ORM_data}{ca} eq 'ca', 'lazy_load' );

$d1->_cache->delete( $d1 );
$error = ORM::Error->new;
$d1 = Test::Dummy->find( filter=>(Test::Dummy->M->id == $d1->id), error=>$error, lazy_load=>1 );

ok
(
    (
        !$error->fatal
        && 
        ( ref $d1->{_ORM_missing_tables} eq 'HASH' )
        &&
        ( ( join ',', (keys %{$d1->{_ORM_missing_tables}}) ) eq 'Dummy__Child1' )
    ),
    'lazy_load',
);

$d1->ca( error=>$error );

ok( !$error->fatal && ! exists $d1->{_ORM_missing_tables}, 'lazy_load' );

$d1->_cache->delete( $d1 );
$error = ORM::Error->new;
$d1 = Test::Dummy->find_id( id=>$d1->id, error=>$error );

ok( !$error->fatal && ! exists $d1->{_ORM_missing_tables} && ref $d1 eq 'Test::Dummy::Child1' && $d1->{_ORM_data}{ca} eq 'ca', 'lazy_load' );

$d1->_cache->delete( $d1 );
$error = ORM::Error->new;
$d1 = Test::Dummy->find_id( id=>$d1->id, error=>$error, lazy_load=>1 );

ok
(
    !$error->fatal
    && (join ',', (exists $d1->{_ORM_missing_tables} && keys %{$d1->{_ORM_missing_tables}})) eq 'Dummy' && ref $d1 eq 'Test::Dummy',
    'lazy_load'
);

$d1->c( error=>$error );

ok
(
    (join ',', (exists $d1->{_ORM_missing_tables} && keys %{$d1->{_ORM_missing_tables}})) eq 'Dummy__Child1'
    && ref $d1 eq 'Test::Dummy::Child1'
    && $d1->{_ORM_data}{c} eq 'c',
    'lazy_load'
);

$d1->ca( error=>$error );

ok
(
    ! exists $d1->{_ORM_missing_tables}
    && ref $d1 eq 'Test::Dummy::Child1'
    && $d1->{_ORM_data}{ca} eq 'ca',
    'lazy_load'
);

$d1->_cache->delete( $d1 );
$error = ORM::Error->new;
$d1 = Test::Dummy::Child1->find_id( id=>$d1->id, error=>$error, lazy_load=>1 );

ok
(
    !$error->fatal
    && (join ',', (exists $d1->{_ORM_missing_tables} && sort keys %{$d1->{_ORM_missing_tables}})) eq 'Dummy,Dummy__Child1',
    'lazy_load'
);

$error = ORM::Error->new;
$d1->update( prop=>{ a=>'aa', ca=>'cccaaa' }, error=>$error );

ok( !$error->fatal && $d1 && $d1->a eq 'aa' && $d1->ca eq 'cccaaa', 'update' );

$error = ORM::Error->new;
$d1->update( prop=>{ ca=>'ccaa' }, error=>$error );
print $error->text;
ok( !$error->fatal && $d1 && $d1->ca eq 'ccaa', 'update' );

$error = ORM::Error->new;
$d1->update( prop=>{ ca=>($d1->M->ca)->_append( 'aa' ) }, error=>$error );

ok( !$error->fatal && $d1 && $d1->ca eq 'ccaaaa', 'server_side_update' );

$error = ORM::Error->new;
$d1->delete( error=>$error );

ok( !$error->fatal, 'delete' );
