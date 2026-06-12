from scapy import *

a=IP(src='201.1.1.2',dst='202.2.2.2')/TCP(sport=33789,dport=(10000,19999))
#[p for p in a]
for s in a:
    s.sport=s.dport
    print(s)
send(a)