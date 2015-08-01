#!/usr/bin/perl
# Restarts PPP daemon if connection is lost or daemon is hung.
use Net::Ping;

# Change this.
$server_to_ping="ya.ru";


sub check_ping_server
{
$host_alive=1;
$ping=Net::Ping->new('icmp');
if( $ping->ping($_[0]) ) { $host_alive=1;}
 else  {$host_alive=0;}
return $host_alive;
}



if(!check_ping_server($server_to_ping))
    {
    system("killall -9 ppp");
    system("sleep 2");

    # Start PPP ADSL connection.
    system("/usr/sbin/ppp -quiet -ddial adsl");

    # Send the message to.
    system("echo PPP restarted by timeout...");
    }

exit;
