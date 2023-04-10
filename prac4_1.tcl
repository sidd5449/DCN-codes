set ns [new Simulator] ;# initialise the simulation
$ns color 1 blue
$ns color 2 red
$ns color 3 brown
$ns color 4 green
$ns color 5 orange
# Predefine tracing
set f [open out.tr w]
$ns trace-all $f
set nf [open out.nam w]
$ns namtrace-all $nf

set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]

$n0 color blue
$n1 color red
$n2 color black
$n3 color brown
$n4 color green
$n5 color purple

$ns duplex-link $n0 $n2 5Mb 5ms DropTail
$ns duplex-link $n1 $n2 5Mb 5ms DropTail
$ns duplex-link $n2 $n3 5Mb 5ms DropTail
$ns duplex-link $n3 $n4 5Mb 5ms DropTail
$ns duplex-link $n3 $n5 5Mb 5ms DropTail
# Some agents.
set udp0 [new Agent/UDP] ;# A UDP agent
$ns attach-agent $n0 $udp0 ;# on node $n0
set cbr0 [new Application/Traffic/CBR] ;# A CBR traffic generator agent
$cbr0 attach-agent $udp0 ;# attached to the UDP agent
$udp0 set class_ 0 ;# actually, the default, but. . .
set null0 [new Agent/Null] ;# Its sink
$ns attach-agent $n4 $null0 ;
$ns connect $udp0 $null0
$udp0 set fid_ 1
$ns at 0.0 "$cbr0 start"
puts [$cbr0 set packetSize_]
puts [$cbr0 set interval_]

set tcp [new Agent/TCP]
$tcp set class_ 1
$ns attach-agent $n1 $tcp
set sink [new Agent/TCPSink]
$ns attach-agent $n5 $sink
set ftp [new Application/FTP] ;# TCP does not generate its own traffic
$ftp attach-agent $tcp

$ns at 0.0 "$ftp start"
$ns connect $tcp $sink
$tcp set fid_ 2
$ns at 3.0 "$ns detach-agent $n1 $tcp ; $ns detach-agent $n5 $sink"



$ns at 3.0 "finish"
proc finish {} {
global ns f nf
$ns flush-trace
close $f
close $nf
puts "running nam..."
exec nam out.nam &
exit 0
}
$ns run
