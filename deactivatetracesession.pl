#!/usr/bin/perl
use Net::Telnet;

#Usage : perl deactivatesession.pl <mahinename> <username> <password> <sessionName>
#e.g   : perl deactivatesession.pl x86hlrfe4  rtp99 rtp99 shh_trace

$machinename = $ARGV[0];
chomp($machinename);
print "Machine : $machinename\n";

$username = $ARGV[1];
chomp($username);
print "Username : $username\n";

$password = $ARGV[2];
chomp($password);
print "Password : $password\n";

$session = $ARGV[3];
chomp($session);
print "Session : $session\n";

my $telnet = new Net::Telnet (Timeout=>45);
$telnet->open(Host => $machinename, Errmode=>sub
{
        print "\nUnable to connect to the machine\n";
        goto LAST;
});

$telnet->waitfor(Match => '/.*: $/i', Errmode=>sub{ goto LAST; });
$telnet->print($username);
$telnet->waitfor('/password: $/i');
$telnet->print($password);
@output = $telnet->waitfor(Match => '/> $/i',Errmode=>sub{ goto LAST; });
print @output;

$cmd = "/opt/SMAW/INTP/bin/AdvTraceTool.sh deactivateSession $session";
$telnet->print($cmd);
@output = $telnet->waitfor('/> $/i');
print @output;

($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) =
                                          localtime(time);
print $sec."\n".$min."\n".$hour."\n";

$folder_name = "SDM_Suite"."-".$hour."-".$min;
print $folder_name."\n";

$cmd = "/opt/SMAW/INTP/bin/AdvTrcFmt -last -arg -Session $session -I=/export/home/rtp99/99/trace/AdvTrace -O=/var/tmp/$folder_name";
$telnet->print($cmd);
@output = $telnet->waitfor('/> $/i');
print @output;

$telnet->close;
LAST:
print "\nClosed telnet session ... \n";


