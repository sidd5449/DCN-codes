set ns [new Simulator]
$ns rtproto DV
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

$ns duplex-link $n0 $n1 10Mb 5ms DropTail
$ns duplex-link $n1 $n2 10Mb 5ms DropTail
$ns duplex-link $n2 $n3 10Mb 5ms DropTail
$ns duplex-link $n3 $n4 10Mb 5ms DropTail
$ns duplex-link $n4 $n5 10Mb 5ms DropTail
$ns duplex-link $n5 $n0 10Mb 5ms DropTail


set udp0 [new Agent/UDP] ;# A UDP agent
$ns attach-agent $n0 $udp0 ;# on node $n0
set cbr0 [new Application/Traffic/CBR] ;# A CBR traffic generator agent
$cbr0 attach-agent $udp0 ;# attached to the UDP agent
$udp0 set class_ 0 ;# actually, the default, but. . .
$udp0 set fid_ 1
set null0 [new Agent/Null] ;
$ns attach-agent $n5 $null0 ;
$ns connect $udp0 $null0
$ns at 0.0 "$cbr0 start"

$ns rtmodel-at 1.0 down $n0 $n5
$ns rtmodel-at 1.5 up $n0 $n5
puts [$cbr0 set packetSize_]
puts [$cbr0 set interval_]
$ns at 1.5 "$ns detach-agent $n0 $udp0 ; $ns detach-agent $n5 $null0"

set tcp [new Agent/TCP]
$tcp set class_ 1
$ns attach-agent $n0 $tcp
set sink [new Agent/TCPSink]
$ns attach-agent $n5 $sink
$tcp set fid_ 2
set ftp [new Application/FTP] ;# TCP does not generate its own traffic
$ftp attach-agent $tcp
$ns at 1.5 "$ftp start"
$ns rtmodel-at 1.5 down $n0 $n5
$ns rtmodel-at 2.0 up $n0 $n5
$ns connect $tcp $sink
$ns at 3.0 "$ns detach-agent $n0 $tcp ; $ns detach-agent $n5 $sink"

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
