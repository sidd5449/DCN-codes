set ns [new Simulator] ;# initialise the simulation
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

$ns simplex-link $n0 $n1 5Mb 5ms DropTail
$ns simplex-link $n1 $n2 5Mb 5ms DropTail
$ns simplex-link $n2 $n3 5Mb 5ms DropTail
$ns duplex-link $n3 $n4 5Mb 5ms DropTail
$ns duplex-link $n4 $n5 5Mb 5ms DropTail
$ns duplex-link $n5 $n0 5Mb 5ms DropTail


#UDP
set udp0 [new Agent/UDP] ;# A UDP agent
$ns attach-agent $n0 $udp0 ;# on node $n0
set cbr0 [new Application/Traffic/CBR] ;# A CBR traffic generator agent
$cbr0 attach-agent $udp0 ;# attached to the UDP agent
$udp0 set class_ 0 ;# actually, the default, but. . .
set null0 [new Agent/Null] ;# Its sink
$ns attach-agent $n3 $null0 ;
$ns connect $udp0 $null0
$ns at 0.0 "$cbr0 start"
puts [$cbr0 set packetSize_]
puts [$cbr0 set interval_]

$ns at 2.0 "$cbr0 stop"

set tcp [new Agent/TCP]
$tcp set class_ 1
$ns attach-agent $n3 $tcp
set sink [new Agent/TCPSink]
$ns attach-agent $n0 $sink
set ftp [new Application/FTP] ;# TCP does not generate its own traffic
$ftp attach-agent $tcp

$ns at 2.0 "$ftp start"
$ns connect $tcp $sink
$ns at 4.0 "$ns detach-agent $n3 $tcp ; $ns detach-agent $n0 $sink"


$ns at 4.0 "finish"
proc finish {} {
global ns f nf
$ns flush-trace
close $f
close $nf
puts "running nam..."
exec nam out.nam &
exit 0
}
# Finally, start the simulation.
$ns run
