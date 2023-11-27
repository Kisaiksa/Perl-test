#!/usr/bin/perl
#выбор данных из таблиц

use strict;
use warnings;
use Data::Dumper;
use DBI;
use utf8;

if (@ARGV < 1) {
    die "Использование: perl get_data.pl почта\n";
}

my $mail = $ARGV[0];
get_data();

sub get_data {
	my $dsn = "DBI:mysql:database=test";
	my $username = "kate";
	my $password = "www";

	my $dbh = DBI->connect($dsn, $username, $password, {RaiseError => 1});	
	if (!$dbh) {
		die "Ошибка подключения к базе данных: " . DBI->errstr;
	}

	my $sql = <<SQL;
	SELECT SQL_CALC_FOUND_ROWS log.created, log.str, log.int_id 
		FROM log 
		WHERE log.str LIKE ?
	UNION
	SELECT message.created, message.str  , message.int_id
		FROM message 
		WHERE message.str LIKE ?
	ORDER BY int_id, created
	LIMIT 100
SQL

	my $sth = $dbh->prepare($sql);
	$sth->execute("%$mail%", "%$mail%");

	while (my $row = $sth->fetchrow_hashref()) {
		printf ("%20s %s\n", $row->{created}, $row->{str});
	}	

	$sth = $dbh->prepare("SELECT FOUND_ROWS()");
	$sth->execute();
	my ($cnt) = $sth->fetchrow_array();
	print "Всего найдено $cnt записей\n";
   
	$sth->finish();
	$dbh->disconnect();
}