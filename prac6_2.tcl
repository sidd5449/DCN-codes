#Create a simulator object set
set ns [new Simulator]
$ns color 1 Blue
$ns color 2 Red
#Open the nam trace file #set nf [open out.nam w] #Sns namtrace-all Snf
#Open the ns trace file set tf [open ass21.tr w] set win file [open Win w] $ns trace-all $tf
#Create five nodes
set n0 [$ns node] 
set n1 [$ns node] 
set n2 [$ns node] 
set n3 [$ns node] 
set n4 [$ns node] 
set n5 [$ns node]
#Create a duplex link between the nodes
$ns duplex-link $n0 $n2 2Mb 10ms DropTail 
$ns duplex-link $n1 $n2 2Mb 10ms DropTail 
$ns simplex-link $n2 $n3 0.3Mb 100ms DropTail 
$ns simplex-link $n3 $n2 0.3Mb 100ms DropTail

$ns duplex-link $n3 $n4 0.5Mb 40ms DropTail
$ns duplex-link $n3 $n5 0.5Mb 30ms DropTail
$ns queue-limit $n2 $n3 20
# Show the queue between no and nl in the #animation which is makes an angle of # 0.5*pi radians (90 degrees) to the #horizontal
#Sns duplex-link Sn0 Sn2 queuePos 0.3 #Sns duplex-link $n1 $n2 queuePos 0.3 #Sns simplex-link $n2 $n3 queue Pos 0.3 #Sns simplex-link Sn3 Sn2 queue Pos 0.3 #Sns duplex-link Sn3 $n4 queuePos 0.3 #$ns duplex-link $n3 Sn5 queuePos 0.3
#Create a UDP agent
set udp0 [new Agent/UDP] 
#$udp0 set fid_2
$ns attach-agent $n1 $udp0
#Create a Null agent (a traffic sink) and attach it to node nl
set null0 [new Agent/Null] 
$ns attach-agent $n5 $null0
#Create a TCP agent
set tcp0 [new Agent/TCP] 
$tcp0 set packetSize_ 1000 
$tcp0 set tcp0 Tick_ .1 
#set fid_ 1
$ns attach-agent $n0 $tcp0
set sink0 [new Agent/TCPSink]
$ns attach-agent $n4 $sink0
# Create a FTP traffic source and attach it TCP agents
set ftp0 [new Application/FTP] 
$ftp0 set type_FTP $ftp0 attach-agent $tcp0
# Create a CBR traffic source and attach it to udp0
set cbr0 [new Application/Traffic/CBR]
$cbr0 set packetSize_ 1000
$cbr0 set rate 0.2Mb
$cbr0 set random_ false
$cbr0 attach-agent $udp0

#Connect the traffic source with the traffic sink
$ns connect $udp0 $null0
$ns connect $tcp0 $sink0
#Schedule events for the CBR agent
$ns at 0.1 "$cbr0 start"
$ns at 124.5 "$cbr0 stop"
$ns at 1.0 "$ftp0 start"
$ns at 124.0 "$ftp0 stop"
#Call the finish procedure after 5 seconds of simulation time
$ns at 125.0 "finish"
#Define a 'Finish' procedure
proc finish {} {
nf tf winfile global ns tf winfile
$ns flush-trace
close $tf
close $winfile
nam out.nam &
exit 0 
}

proc plotWindow {tcpSource file} {
global ns set time 0.1 set now [$ns now]
set cwnd [$tcpSource set cwnd_] puts
$file "$now Scwnd"
$ns at [expr $now+$time] "plotWindow $tcpSource $file"
}
$ns at 0.1 "plotWindow $tcp0 $winfile" 
#Run the simulation
$ns run
