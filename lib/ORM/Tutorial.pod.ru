=head1 NAME

ORM - �������� ����������� ������ ��� Perl, ������������ ��� �������� � ������
�������� � ���� ������.

=head1 SYNOPSIS

����� ������� ��������� �������� ������������ ������������� ORM �� �������
�������. � �������� ������� ������� ���������� "����������� �������"
(Todo List). �������� ������������� ���������� Todo List - ��� ��������
���������� ���� ������� � ���������� �����.

=head1 ���� 1: �������� ������

����� ������������� �� ������� ��������� ������, ����������� �� �� ����
����������. ����, ��������� ������ ��������:

=over

=item 1. ������ (Task)

�������� �������� ������:

=over

=item * ��������� (title)

=item * ��������� �������� (desc)

=item * ���� �������� ������ (created)

=item * ���� ������ ���������� (start_date), ����� ���� ��������������

=item * ���� ���������� ���������� (end_date), ����� ���� ��������������

=item * ���� ���������������� ���������� ���������� (deadline), ����� ����
��������������

=item * ������������� ��������

=back

=item 2. �������� (Worker)

�������� �������� ������:

=over

=item * �.�.�. (name)

=back

=back

������ ����� � ������������� ORM �������� �������� ������, ������� �����
������� ������� ��� ���� ������� ����� ������.
����� ����� ���������� B<������������> (B<initial>).

���� Todo/ORM.pm

  package Todo::ORM;

  use ORM::Db::DBI::MySQL; # ����� �������������� ������� ���� MySQL
  use base 'ORM';

  BEGIN
  {
      # ������� _init ������ ����������� ���������� � BEGIN-�����
      # ������ ������������� ������.
      ORM->_init
      (
          # �������� �������� ������� ��������� ��������.
          # ���� ���� �������� ������, ������� ����� ���������.
          # � ���, ��� ������������ �� ���� ����� Todo::History
          # ����...
          history_class        => 'Todo::History',

          # �� ������������ �� ��������� "������� ��������"
          prefer_lazy_load     => 0,

          # �������� �������� ������� ������
          emulate_foreign_keys => 1,

          # ������ ���� ��������
          default_cache_size   => 200,

          # ������������ ������� ���� ������
          db => ORM::Db::DBI::MySQL->new
          (
              host        => 'localhost',
              database    => 'todo_list',
              user        => 'root',
              password    => '',
          ),
      );
  }

  1;

��������� ����� �������� ����� C<Todo::History>, ������� 
����� �������� �� ������� ��������� ��������.
�������� ���� ����� ������ ������:

  package Todo::History;

  $VERSION=0.1;

  use ORM::Base 'Todo::ORM', i_am_history=>1;
  
  1;

������ �������� �������� ��������.

���������� ORM � ������� �� ��������, �� ������� �������� ��������
������� ������������ � � ���� ������ � � ���������� ������.
��� ���������� ������� ������� ��� �������� �������� ������,
���� � ���� ������� ����� ��������������� ����������� ���������
�������� ������.

������� ������ ��������� � ������������ ���� ��� ����� ������
(����� ����� ������� ������������ � ������ ������������).
������� ������� ������ - ���� ������ �� ������� (��� ������ ��
�������������� ������� ���������� � ������� INNER JOIN ������ �
������ ������������).

��������� ���������� ������ ��� �� �������� ���������� ������:

���� Todo/Task.pm

   package Todo::Task;

   $VERSION=0.1;

   use ORM::Base 'Todo::ORM';

���� Todo/Worker.pm

   package Todo::Worker;

   $VERSION=0.1;

   use ORM::Base 'Todo::ORM';

��� �� ORM ���������� ����� ������� ������������� ��������� �������?
�� ���������, ORM �������� ��� ������� �� ����� ������ ����� ����������
����������� ��������� C<$class =~ s/::/_/g;>

����� �������� ��� ��������� ���������� �������� ����� C<_guess_table_name>
� ����� Todo::ORM;

   sub _guess_table_name
   {
       my $my_class = shift;
       my $class = shift;
       my $table;

       $table = substr( $class, index( $class, '::' )+2 );
       $table =~ s/::/_/g;

       return $table;
   }

������ ������� ��� ������ C<Todo::Task> ����� ���������� �� C<Todo_Task>,
� ������ C<Task>.

������ ����� ������� ������� � ��.
(��� �� �������� � ������������ ������ ��� ������������� �������������
�������� ����.)

  CREATE DATABASE todo_list;

  DROP TABLE IF EXISTS `todo_list`.`_ORM_refs`;
  CREATE TABLE `_ORM_refs` (
      `class` varchar(45) NOT NULL default '',
      `prop`  varchar(45) NOT NULL default '',
      `ref_class` varchar(45) NOT NULL default '',
      PRIMARY KEY  (`class`,`prop`)
  ) TYPE=InnoDB;

  INSERT INTO '_ORM_refs' VALUES ( 'Todo::Task', 'worker', 'Todo::Worker' );

  DROP TABLE IF EXISTS `todo_list`.`History`;
  CREATE TABLE `History` (
      `id` bigint(20) NOT NULL auto_increment,
      `obj_class` varchar(100) NOT NULL default '',
      `prop_name` varchar(100) NOT NULL default '',
      `obj_id` int(11) NOT NULL default '0',
      `old_value` varchar(255) default '',
      `new_value` varchar(255) default '',
      `date` datetime NOT NULL,
      `editor` varchar(255) NOT NULL default '',
      `slaved_by` bigint(20) unsigned default NULL,
      PRIMARY KEY  (`id`)
  ) TYPE=InnoDB;

  DROP TABLE IF EXISTS `todo_list`.`Task`;
  CREATE TABLE `task` (
      `id` bigint(20) unsigned NOT NULL auto_increment,
      `title` varchar(255) NOT NULL default '',
      `desc` text NOT NULL,
      `created` date default NULL,
      `start_date` date default NULL,
      `deadline` date default NULL,
      `worker` bigint(20) unsigned default NULL,
      PRIMARY KEY  (`id`)
  ) TYPE=InnoDB;

  DROP TABLE IF EXISTS `todo_list`.`Worker`;
  CREATE TABLE `worker` (
      `id` bigint(20) unsigned NOT NULL auto_increment,
      `name` varchar(100) NOT NULL default '',
      PRIMARY KEY  (`id`)
  ) TYPE=InnoDB;

�� ������� 4 �������, ������ �� ��� C<_ORM_refs> �������� ��������,
������ ���� ������� ���������� ����������� ����� �������� ����� ������,
� ����� �������������� � �������� ������� ���.
����� ������� �������� C<Todo::Task>->C<worker> - ������� �� ������
C<Todo::Worker> � ������� ��������� ������:

  class       | prop      | ref_class
  ------------------------------------
  Todo::Task  | worker    | Todo::Worker

��� ����� ������������ ������� ���� ������ ����� �����������
������ �������� - ��� ��������������� ������ ORM::_db_type_to_class,
������� ��������� � �������� ���������� ��� � ��� ���� ������� � ����������
��� ������ ��������.
�� ��������� ���� ����� ��������� ������ L<ORM::Date> � L<ORM::Datetime>
�������������� ��������� ���� C<DATE> � C<DATETIME>.

����� ������� ������������ � ORM ������ ����� ���������������� ���� id,
���������� ��������������� �������.

=head1 ���� 2: �������� � ��������� ��������

��� ���������� ��������� ����� ������, �������� ��� ������� �������
��� �������� � ��������� ��������.

���� new.pl

  #!/usr/bin/perl
  #
  # Use: perl new.pl <Class> <Prop1Name> <Prop1Value> <Prop2Name> <Prop2Value>...
  #
  # Class - Name of the class without 'Todo::' prefix.
  #

  use lib "lib";
  use lib "../ORM/lib";

  $nick  = shift;
  $class = "Todo::$nick";

  eval "require $class" or die $@;

  $error = ORM::Error->new;
  %prop  = @ARGV;
  $obj   = $class->new( prop=>\%prop, error=>$error );

  if( $obj )
  {
      print "New $nick was created with id:".$obj->id."\n" if( $obj );
      $obj->print;
  }

  print $error->text;

���� update.pl

  #!/usr/bin/perl
  #
  # Use: perl update.pl <Class> <ObjectID> <Prop1Name> <Prop1Value> <Prop2Name> <Prop2Value>...
  #
  # Class - Name of the class without 'Todo::' prefix.
  #

  use lib "lib";
  use lib "../ORM/lib";

  $nick  = shift;
  $class = "Todo::$nick";

  eval "require $class" or die $@;

  $id    = shift;
  $error = ORM::Error->new;
  %prop  = @ARGV;
  $obj   = $class->find_id( id=>$id, error=>$error );

  if( $obj )
  {
      $obj->update( prop=>\%prop, error=>$error ) unless( $error->fatal );
      print "Updated $nick with id:".$obj->id."\n";
      $obj->print;
  }
  else
  {
      print STDERR "Object #$id of $class not found!\n";
  }

  print $error->text;

��� ������� ���������� ����� print, ������� ���������� ������� � ������������
������ C<Todo::ORM>. ���� ����� ������� ���������� �� ������� ��� �������� ��
����������:

  sub print
  {
      my $self  = shift;
      my $ident = shift||0;
      my @ref;

      # ��� ������ ���������� � ��������� ��������
      # �� ������� ������ �������� ������ ��������.
      
      return if( $ident > 3 );

      # ������� ���������� �� �������
      
      print ' 'x($ident*2),('-'x20),"\n";
      for my $prop ( (ref $self)->_all_props )
      {
          printf "%".(20+$ident*2)."s %s\n", "$prop:", $self->_property_id( $prop );
          if( (ref $self)->_prop_is_ref( $prop ) && $self->_property( $prop ) )
          {
              push @ref, $self->_property( $prop );
          }
      }
      print ' 'x($ident*2),('-'x20),"\n\n";

      # ������� ���������� � ��������� ��������

      for my $prop ( @ref )
      {
          print ' 'x(($ident+1)*2),"Related object '$prop':\n";
          $prop->print( $ident+1 );
      }
  }

������ �������� ��������� ���������� � �����.

  # perl new.pl Worker name "Eric Cartman"
  New Worker was created with id:1
  --------------------
                   id: 1
                class: Todo::Worker
                 name: Eric Cartman
  --------------------
  
  # perl new.pl Worker name "Kenny McCormic"
  New Worker was created with id:2
  --------------------
                   id: 2
                class: Todo::Worker
                 name: Kenny McCormic
  --------------------

  # perl new.pl Task \
        title "Kill Kenny" \
        desc "Just kill Kenny!" \
        worker 1 \
        created "2005-12-18" \
        start_date "2006-01-01" \
        deadline "2006-01-02"

  New Task was created with id:1
  --------------------
                   id: 1
                class: Todo::Task
              created: 2005-12-18
                 desc: Just kill Kenny!
               worker: 1
             deadline: 2006-01-02
                title: Kill Kenny
           start_date: 2006-01-01
  --------------------

    Related object 'worker':
    --------------------
                     id: 1
                  class: Todo::Worker
                   name: Eric Cartman
    --------------------

  # perl new.pl Task \
        title "Eat Chocolate pie" \
        desc "Ask your mummy." \
        worker 1 \
        created "2005-12-18" \
        start_date "2006-01-01" \
        deadline "2006-01-02"

  New Task was created with id:2
  --------------------
                   id: 2
                class: Todo::Task
              created: 2005-12-18
                 desc: Ask your mummy.
               worker: 1
             deadline: 2006-01-02
                title: Eat Chocolate pie
           start_date: 2006-01-01
  --------------------

    Related object 'worker':
    --------------------
                     id: 1
                  class: Todo::Worker
                   name: Eric Cartman
    --------------------

��� �������� ������ ��������� � ����� C<Todo::Task>,
����� �� ��������� �������� created �������������� 
������� ����:

  sub _validate_prop
  {
      my $self = shift;
      my %arg  = @_;

      if( ! $self->id && ! $self->created )
      {
          $self->_fix_prop( prop=>{ created=>ORM::Date->current }, error=>$arg{error} );
      }

      $self->SUPER::_validate_prop( %arg );
  }

=over

=item * ����� '_validate_prop' ���������� ��� �������� �������
(�� ������ 'new') � ��� ��� ��������� (�� ������ 'update')

=item * ������� ( !$self->id ) ��������, ��� ������ ��� �� ��� ��������
� ���� ������. �� ���� ��� ����� ��������� ������ ��� �������� �������.

=item * ����� '_fix_prop' ������ ���������� ������ �� ������ '_validate_prop'

=item * �� ��������� �������� ����� '_validate_prop' �������� ������.

=back

������ ������� ��� ���� ������:

  # perl new.pl Task \
        title "Keep alive" \
        desc "Just keep alive!" \
        worker 2 \
        start_date "2005-12-31" \
        deadline "2006-01-02"

  New Task was created with id:3
  --------------------
                   id: 3
                class: Todo::Task
              created: 2005-12-18
                 desc: Just keep alive!
               worker: 2
             deadline: 2006-01-02
                title: Keep alive
           start_date: 2005-12-31
  --------------------

    Related object 'worker':
    --------------------
                     id: 2
                  class: Todo::Worker
                   name: Kenny McCormic
    --------------------

�� �� ��������� �������� created � ��� �� ��������� ������������
������� ����. ������ ����� ��� ����� ����� �� ���������� deadline.

=head1 ���� 3: ������� � ����������

������ ����� �� ���� ��������������� ������,
����� ������� ��������. �������� ������ ���:

=over

=item * ������ ��������������� ��� ���������� ������������ �����������.

=item * ������, ������� ������ ���� ��������� � ����������� �����.

=back

������� ��� ������� ������ ���������� ��������� ��������:

  ORM::DbLog->write_to_stderr( 1 );
  @tasks = Todo::Task->find
  (
      filter => ( Todo::Task->M->worker == $worker ),
      error  => $error,
  );

Todo::Task->M->worker - ��� ������������, �.�. ������ ������ ORM::Metaprop
��� ��� �������. � �������������� SQL-������� ������ ����� ������� �����
������������ ��� ���������������� ���� �������.
������������ Todo::Task->M �������� ��� ������ ������ Todo::Task.
����� �� �������, ��� ������������ �������������� ����� ������.

$worker ����� ���� �������� ������ Todo::Worker ��� id ������� �� ����.

������ $error ���� ORM::Error ����� ��������� �������� ������,
���� ������� ���������� �� ����� ���������� �������.
���� �������� ������������, � ������� ������ ���� �������� $error
������, �� ������ ����� ���������������, � ������� �������,
�������� ���������� ����������������, ��� ������� ��������� ��� �������
������ � ���������� ��������� error ����� ��������� ��������.

����� C<ORM::DbLog>->C<write_to_stderr( 1 )> �������� ����� SQLlog � STDERR.
����� ������� ����� ������ � ����� ������� ������������ ��������� ������ ORM.
� ����� ������ ��������������� ������ ����� ��������� ��������� �������
(��� $worker=1):

  --------------------------
  [Mon Dec 26 00:14:27 2005]: ORM::find: Success
  SELECT
    DISTINCT `Task`.*
  FROM
    `Task`
  WHERE
    (`worker` = '1')

���� ����� ������� ������� ����� ���� ������ ��� ���������,
�� ������ ����� ��������� ���:

  @tasks = Todo::Task->find
  (
      filter => ( Todo::Task->M->worker->name eq $worker_name ),
      order  => ORM::Order->new( [ Todo::Task->M->created, 'DESC' ] ),
      error  => $error,
  );

�������� �������� �� ������������� ���������� == � eq. ��� ��������� ��� 
���� �� ������ ������� ����� ��������� � �������� ���������� ���������,
������� ������ �� �� ���������� ���������� ����������, ������ ��� ������
������������� ������� ������������ ���������� �� ������ ��������.

�������� order ������� � ���, ��� ��������� ������ ������ �������������
� ������������ � ����� �������� �� ��������.

��� ������� �������� ��� ������, ���������� ������, ����� ����� ������� ������
���������� ��� �����������, ���� ������ ����� �����:

  @tasks = Todo::Task->find
  (
      filter => ( Todo::Task->M->worker->name->_like( '%Cartman%' ) ),
      order  => ORM::Order->new( [ Todo::Task->M->created, 'DESC' ] ),
      error  => $error,
  );

SQL-������ ��� ����� ������ �������� ��������� �������:

  SELECT
    DISTINCT `_T1_Task`.*
  FROM
    `Task` AS `_T1_Task`
      LEFT JOIN `Worker` AS `_T2_Worker` ON( `_T1_Task`.`worker`=`_T2_Worker`.`id` )
  WHERE
    (`_T2_Worker`.`name` LIKE '%Cartman%')
  ORDER BY `_T1_Task`.`created` DESC

������ ��� ������� ������ �������� ����������:

  $M     = Todo::Task->M;
  @tasks = Todo::Task->find( filter => ( $M->deadline < '2006-01-30' ) );

���������� $M ������� ��� ���������, ����� ����� ������ ������������ � ������
������� ������� ������.

��� ������� ����� ����������� ��� ���� ����� - ���������� ����� �����������
������� �� �����������, ��� ����� ������ ����� ����������� ����� C<stat>,
������� ���������� ���������� �� �������� ������ � ��������� � ���� ���������
������ �������, � ����, ����������� �������������:

  $M   = Todo::Worker->M;
  $res = Todo::Worker->stat
  (
      data =>
      {
          worker => $M,
          tasks  => $M->_rev( 'Todo::Task' => 'worker' )->_count,
      },
      group_by => [ $M ],
      preload  => { worker=>1 },
  );

����������� ���������� ������ ����� ������ �� ������ �����, ����������
����������� ������.

�������� data ���������� ������, ������� ����� ��������
� ���������� �������. � ������ ������ ������ �� ��������� ������� @$res
����� ������������ �� ���� ��� � ����� �������: worker - ����� ��������� 
��� ������ ������ Todo::Worker, � tasks ���������� ���������� �����������
��������� �����.

�������� group_by ��������� ���������� ��������� GROUP BY � SQL � �������������
� ���� � �������������� SQL-�������. ������ ��� ����������� ���� � ����� ������
����� ���������� �������� _count.

�������� preload ���������� ������ ����� �������� ������ ���� ����������
������������ SQL-��������. � ����� ������ �� ��������, ��� �������� ��������
����� ��������� ��� ���� �������� worker. ���� �� ���� �������� ��� ������,
�� ������� ���� �� ��������� � ������ lazy_load � ����������� �� ������� ��
���� ����������, ��������� �� ���� � ����������� ������.

$M->_rev( 'Todo::Task' => 'worker' ) - ��� �������� ������������, �.�. �������
������ 'Todo::Task' ������������ �� 'Todo::Worker' ����� �������� 'worker'.

'_count' - ��� ������ �������� ������������ ������� COUNT.

������ ��������������� ��������� ������� ������ stat �������� ���:

  --------------------------
  [Mon Dec 26 00:49:34 2005]: ORM::stat: Success
  SELECT
    'Todo::Worker' AS `_worker class`,
    COUNT( `_T2_Task`.`id` ) AS `tasks`,
    `_T1_Worker`.`id` AS `worker`,
    `_T1_Worker`.`name` AS `_worker name`
  FROM
    `Worker` AS `_T1_Worker`
      LEFT JOIN `Task` AS `_T2_Task` ON( `_T1_Worker`.`id`=`_T2_Task`.`worker` )
  GROUP BY `_T1_Worker`.`id`

=head1 ���� 4: �������� �������� (� ��������...)


=head1 ���� 5: ������� ��������� (� ��������...)


=head1 ���� 6: ��������� ������ (� ��������...)


=head1 ���� 7: ���������� (� ��������...)


=head1 ���� 8: ������� �������� (LAZY_LOAD) (� ��������...)


=head1 ���� 9: ������������ (� ��������...)


=head1 ���� 10: ����������� (� ��������...)


=head1 SEE ALSO

http://www.sourceforge.net/projects/perlorm

=head1 AUTHOR

Alexey V. Akimov

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2005 by Alexey V. Akimov

This library is free software; you can redistribute it and/or modify
it under the terms of LGPL licence.

=cut