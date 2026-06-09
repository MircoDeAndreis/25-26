rm /shared/$(hostname)/$(hostname).pcap
rm -d /shared/$(hostname)
mkdir /shared/$(hostname)
touch /shared/$(hostname)/$(hostname).pcap

tcpdump -n -U -v --direction=in -w /shared/$(hostname)/$(hostname).pcap --interface=any src host 201.1.1.2 and dst host 202.2.2.2


#-w=/shared/$(hostname)/$(date +%s).pcap