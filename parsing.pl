#!/usr/bin/perl
#разбор файла out и заполнение таблиц
use strict;
use warnings;
use Data::Dumper;
use utf8;

read_file();
my @message;
my @log;

sub read_file {
	my $file = 'out';
	open(my $fh, '<', $file) or die "Не могу открыть файл '$file' $!";
	while (my $line = <$fh>) {
		parsing($line);
	}
	close($fh);
	insert();
	print "Файл разобран\n";
}

sub parsing {
	my ($line)=@_;
	
	if ($line =~ /^(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2})\s+(\S+)\s+(\S{2})\s+(\S+@\S+)\s+(.*)$/) { 
		my $created = $1;
		my $int_id = $2;
		my $str = "$2 $3 $4 $5";
		my $address = $4;
		my $label = $3 || '';

		if ($label eq '<=') {
			my %message;
			$message{created} = $created;
			$message{int_id} = $int_id;
			$message{str} = $str;
			($message{id}) = $str =~ /id=(\S+)$/;
			push @message, \%message;
		} else {
			my %log;
			$log{created} = $created;
			$log{int_id} = $int_id;
			$log{str} = $str;
			$address =~ s/:$//;
			$log{address} = $address;
			push @log, \%log;
		}
		
	} 
	elsif ($line =~ /^(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2})\s+(\S+)\s+(.*)$/){
			my $created = $1;
			my $int_id = $2;
			my $info = $3;

			my %log;
			$log{created} = $created;
			$log{int_id} = $int_id;
			$log{str} = "$int_id $info";
			push @log, \%log;
	} 	
}

sub insert{
	use DBI;

	my $dsn = "DBI:mysql:database=test";
	my $username = "kate";
	my $password = "www";

	my $dbh = DBI->connect($dsn, $username, $password, {RaiseError => 1});	
	if (!$dbh) {
		die "Ошибка подключения к базе данных: " . DBI->errstr;
	}

	foreach my $message (@message) {
		my $sth = $dbh->prepare("SELECT COUNT(id) FROM message WHERE id LIKE ?");
		$sth->execute($message->{id});

		if ($sth->fetchrow_array()){
			next;
		}
		
		my $sql = "INSERT INTO message (created, int_id, str, id) VALUES (?,?,?,?)";
		$sth = $dbh->prepare($sql);
		$sth->execute(
			$message->{created}, 
			$message->{int_id}, 
			$message->{str}, 
			$message->{id}) 
		or die "Ошибка выполнения запроса: " . $dbh->errstr;
		
	}

	foreach my $log (@log) {
		my $sql = "INSERT INTO log (created, int_id, str, address) VALUES (?,?,?,?)";
		my $sth = $dbh->prepare($sql);
		$sth->execute(
			$log->{created}, 
			$log->{int_id}, 
			$log->{str}, 
			$log->{address}) 
		or die "Ошибка выполнения запроса: " . $dbh->errstr;
		
	}

    $dbh->disconnect();
}
