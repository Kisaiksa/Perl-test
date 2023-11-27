#!/usr/bin/perl
#создание таблиц mySQL
use strict;
use warnings;
use DBI;
use utf8;

my $dsn = "DBI:mysql:database=test";
my $username = "kate";
my $password = "www";

my $dbh = DBI->connect($dsn, $username, $password, { RaiseError => 1, PrintError => 0, AutoCommit => 1 });

my $table = <<'SQL';
	CREATE TABLE IF NOT EXISTS message (
		created TIMESTAMP DEFAULT 0 NOT NULL,
		id VARCHAR(255) NOT NULL,
		int_id CHAR(16) NOT NULL,
		str VARCHAR(255) NOT NULL,
		status TINYINT(1),
		CONSTRAINT message_id_pk PRIMARY KEY(id)
	)
SQL
$dbh->do($table);

$dbh->do('CREATE INDEX message_created_idx ON message (created)');
$dbh->do('CREATE INDEX message_int_id_idx ON message (int_id)');

my $table = <<'SQL';
	CREATE TABLE IF NOT EXISTS log (
	created TIMESTAMP DEFAULT 0 NOT NULL,
	int_id CHAR(16) NOT NULL,
	str VARCHAR(255),
	address VARCHAR(255)
	)
SQL
$dbh->do($table);
$dbh->do('CREATE INDEX log_address_idx ON log (address)');

$dbh->disconnect();