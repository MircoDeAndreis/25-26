import pyshark
import sys
import collections

packet_passage = ["" for _ in range(10000)]


for i in range(1,7):
    print(sys.argv[i])
    path = './shared/'+sys.argv[i]+'/'+sys.argv[i]+'.pcap'
    pcap = pyshark.FileCapture(input_file=path)
    for packet in pcap:
        index = int(packet[packet.transport_layer].dstport)-10000
        packet_passage[index] += sys.argv[i]
        if i < 5:
            packet_passage[index]+=" --> "
    pcap.close()


print(collections.Counter(packet_passage))
