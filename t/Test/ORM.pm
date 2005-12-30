package Test::ORM;

use ORM::Db::DBI::SQLite;
use ORM::Db::DBI::MySQL;
use base 'ORM';

BEGIN
{
    ORM->_init
    (
        history_class        => 'Test::History',
        prefer_lazy_load     => 0,
        emulate_foreign_keys => 1,
        default_cache_size   => 200,

        db => ORM::Db::DBI::SQLite->new
        (
            database    => 't/Test.db',
            user        => '',
            password    => '',
        ),

        db2 => ORM::Db::DBI::MySQL->new
        (
            host        => 'localhost',
            database    => 'orm_test',
            user        => 'orm_test',
            password    => 'orm_test',
        ),
    );
}

sub _guess_table_name
{
    my $my_class = shift;
    my $class = shift;
    my $table;

    $table = substr( $class, index( $class, '::' )+2 );
    $table =~ s/::/__/g;

    return $table;
}

1;
