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

$n0 color blue
$n1 color red
$n2 color black
$n3 color brown
$n4 color green

$ns duplex-link $n2 $n0 10Mb 2ms DropTail
$ns duplex-link $n2 $n1 10Mb 2ms DropTail
$ns duplex-link $n2 $n3 5Mb 2ms DropTail
$ns duplex-link $n2 $n4 5Mb 2ms DropTail
# Some agents.
set udp0 [new Agent/UDP] ;# A UDP agent
$ns attach-agent $n2 $udp0 ;# on node $n0
set cbr0 [new Application/Traffic/CBR] ;# A CBR traffic generator agent
$cbr0 attach-agent $udp0 ;# attached to the UDP agent
$udp0 set class_ 0 ;# actually, the default, but. . .
set null0 [new Agent/Null] ;# Its sink
$ns attach-agent $n0 $null0 ;
$ns connect $udp0 $null0
$udp0 set fid_ 1
$ns at 1.0 "$cbr0 start"
puts [$cbr0 set packetSize_]
puts [$cbr0 set interval_]

set udp0 [new Agent/UDP] ;# A UDP agent
$ns attach-agent $n2 $udp0 ;# on node $n0
set cbr0 [new Application/Traffic/CBR] ;# A CBR traffic generator agent
$cbr0 attach-agent $udp0 ;# attached to the UDP agent
$udp0 set class_ 0 ;# actually, the default, but. . .
set null0 [new Agent/Null] ;# Its sink
$ns attach-agent $n3 $null0 ;
$ns connect $udp0 $null0
$udp0 set fid_ 3
$ns at 1.0 "$cbr0 start"
puts [$cbr0 set packetSize_]
puts [$cbr0 set interval_]
# A FTP over TCP/Tahoe from $n1 to $n3, flowid 2
set tcp [new Agent/TCP]
$tcp set class_ 1
$ns attach-agent $n2 $tcp
set sink [new Agent/TCPSink]
$ns attach-agent $n1 $sink
set ftp [new Application/FTP] ;# TCP does not generate its own traffic
$ftp attach-agent $tcp

$ns at 0.0 "$ftp start"
$ns connect $tcp $sink
$tcp set fid_ 2
$ns at 1.35 "$ns detach-agent $n2 $tcp ; $ns detach-agent $n1 $sink"

set tcp [new Agent/TCP]
$tcp set class_ 1
$ns attach-agent $n2 $tcp
set sink [new Agent/TCPSink]
$ns attach-agent $n4 $sink
set ftp [new Application/FTP] ;# TCP does not generate its own traffic
$ftp attach-agent $tcp

$ns at 0.0 "$ftp start"
$ns connect $tcp $sink
$tcp set fid_ 4
$ns at 1.35 "$ns detach-agent $n2 $tcp ; $ns detach-agent $n4 $sink"

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
# Finally, start the simulation.
$ns run
