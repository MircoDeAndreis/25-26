# LAB-K3a. Basic topology and routing

## 1. Single server topology
In this lab, we will configure a topology in which router `r1` is connected to host `hb` on one
interface and to host `ha` on the other interface. 

![Net3](Figs/net3.drawio.png)

Create a `lab.conf` file:

```shell
ha[0]="A"
ha[image]="kathara/base"

r1[0]="A"
r1[1]="B"
r1[image]="kathara/frr"

hb[0]="B"
hb[image]="kathara/base"
```
<!---
thus, `ha` and `hb` are connected on the same network.
---> 
Note the use of the command `ha[image]="kathara/xx"` to run the Docker image for a specific type of network device. `base` is for a user PC, while `frr` is for a router.
*  Q.: Run this lab. Look at the interfaces of each PC. What is missing? Could you ping the interface of hb from ha? Why?
*  Q.: Suggest a proper IP address for the interfaces in the scenario. How many subnets are there? How can you assign IP interfaces and netmasks in order to minimize the amount of IP addresses used?

Add an IP address to the interfaces of each device. Do it by configuring the proper startup file. For instance, for `ha`, create a `ha.startup` file.
Inside, put the command for adding an ip address and netmask to a given interface (say eth0):
```shell
ip address add (your ip address)/(your netmask) dev eth0
```
<!---
ip route add default via 192.168.1.128 dev eth0
Configure `ha`. Create a `ha.startup` file:
```shell
ip address add 192.168.1.1/24 dev eth0

ip route add default via 192.168.1.128 dev eth0
```

Configure `hb`. Create a `hb.startup` file:
```shell
ip address add 192.168.2.1/24 dev eth0

ip route add default via 192.168.2.128 dev eth0
```
Configure `r1`. Create a `r1.startup` file:
```shell
ip address add 192.168.1.128/24 dev eth0
ip address add 192.168.2.128/24 dev eth1
```
---> 
Run the lab through `kathara lstart` and test connectivity and performance

  * **Q1.1** Through `ip address`, report the IP address for all the interfaces (excluded the local loop).
    * 192.168.1.1 eth0 pc1
    * 192.168.1.128 eth0 r1
    * 192.168.2.128 eth1 r2
    * 192.168.2.1 eth0 pc2
  * **Q1.2** Through `ip route`, report the routing tables for `ha`, `hb` and `r1`.
    * 192.168.1.128 eth0 ha
    * 192.168.2.128 eth0 hb
  * **Q1.3** Report the three routing tables according to the following scheme:
    
    | Network prefix | Gateway | Interface |
    |---             |---      |---        |
    | ...            |         |           |

  * **Q1.4** Through `ping` with a single ICMP packet, report the output of the connectivity test between: `ha-r1`, `hb-r1`, `ha-hb`. Is the network well configured?
    What is missing?

Implement the required changes. Restart the lab. Go again through Q1.1-1.4. Is the network properly configured now?
  
  * **Q1.5** Through `traceroute`, report the output of the route `ha->hb` and of the route `hb->ha`. Are the same? Why?

### iPerf3 Overview

**iPerf3** is an open-source tool for measuring maximum TCP, UDP, or SCTP bandwidth on IP networks, reporting throughput, loss, and jitter between two endpoints. [iperf](https://iperf.fr)

#### Basic Usage (Client-Server Model)
- **Server**: `iperf3 -s` (listens on port 5201).
- **Client**: `iperf3 -c <server_IP>` (client-to-server, 10s test).
- **Reverse**: `iperf3 -c <server_IP> -R` (server-to-client).
- **UDP**: Add `-u`; bandwidth `-b 10M`.

* **Q1.6** Through `iperf3`, report the average bandwidth between `ha` and `hb`. Recall that `iperf3 -s` runs as server and `iperf3 -c X.X.X.X` runs as client sending the traffic towards `X.X.X.X`. 

## 2. Linear topology

Consider the topology below.

![Net1](Figs/net1.drawio.png)


  * **Q2.1** Choose a proper addressing plan to minimize the waste of IP addresses, within the range 10.M.0.0/16, where M is your matricola modulo 100. Assume that at most 1000 hosts could be connected to each network *neta1* and *netbB*. Fill the following table.


| Network | Network address|
| ---| ---|
| neta1  | 10.69.0.0/22|
|net12  |  10.69.8.0/30 |
| net2b| 10.69.4.0/22 |

| Interface | IP address/netmask |
|---|--- |
| ha | 10.69.0.1 |
| hb | 10.69.4.2 |
| r1a | 10.69.0.2 |
| r12 | 10.69.8.1 |
| r21 | 10.69.8.2 |
| r2b | 10.69.4.1 |

  * **Q2.2** Configure the routing tables for each device. Fill in the following table.

| Network prefix | Gateway | Interface |
|---|---|---|
|  ... |  |  |

Implement the scenario on Kathara by creating the necessary files. Run the scenario.
  * **Q2.3** Show the routing path `ha->hb` and `hb->ha` through `traceroute`. Check that the implemented configuration is the one intended.
  * **Q2.4** What is the routing algorithm running at r1 and r2? How can you answer this question? Find the appropriate commands.
  * **Q2.5** Why is the routing problem solved in this way at r1 and r2? And how can the network example work, in this case? 

## 3. Routing in a loop topology

Consider the topology below.

![Net1](Figs/net2.drawio.png)

**Q3.1** Choose a proper addressing plan in order to minimize the waste of IP addresses, within the range M.0.0.0/8, where M is your matricola number modulo 100. Assume that at most 100 hosts could be connected to each network *neta1* and *net4b*. All the links between two routers are point-to-point. Fill the following table.

| Network | Network address|
| ---| ---|
| neta1  |69.0.0.0/25|
|net12  | 69.0.1.0/30  |
|net24  | 69.0.1.4/30  |
|net13  | 69.0.1.8/30  |
|net34  | 69.0.1.12/30  |
| net4b| 69.0.0.128/25 |

| Interface | IP address/netmask |
|---|--- |
| ha  | 69.0.0.1 |
| hb  | 69.0.0.130 |
| r1a | 69.0.0.2 |
| r12 | 69.0.1.1 |
| r13 | 69.0.1.9 |
| r21 | 69.0.1.2 |
| r24 | 69.0.1.5 |
| r31 | 69.0.1.10 |
| r34 | 69.0.1.13 |
| r42 | 69.0.1.6 |
| r43 | 69.0.1.14 |
| r4b | 69.0.0.129 |


**Q3.2** Configure the routing tables for each device such that *the traffic follow a clockwise direction within the loop* inside the topology. Fill the following table.

| Network prefix | Gateway | Interface |
|---|---|---|
|  ... |  |  |

**Q3.3** Show the output of `ping ` with a single ICMP packet from `ha` to `hb` and vice versa.

**Q3.4** Show the output of `traceroute` for path `ha->hb` and for path `hb->ha`.

**Q3.5** (Optional) Show a routing table (as similar as possible to **Q3.2**) that would lead to a routing loop. For which destination IPs a routing loop will occur? 
  * ip route add 10.0.0.129/32 via 10.0.1.13 #It's looping because 10.0.0.129/32 it is more specific than a the network 10.0.0.128/25.
  ip route add 10.0.0.0/25 via 10.0.1.13

**Q3.6** (Optional) Configure the routing table as in Q3.5 and show the effect of a routing loop using `ping` and `traceroute`. 
  *  traceroute to 10.0.0.129 (10.0.0.129), 30 hops max, 60 byte packets
 1  10.0.0.8 (10.0.0.8)  14.152 ms  9.122 ms  9.404 ms
 2  10.0.1.9 (10.0.1.9)  14.856 ms  15.369 ms  15.728 ms
 3  10.0.1.14 (10.0.1.14)  16.468 ms  17.223 ms  17.927 ms
 4  10.0.1.6 (10.0.1.6)  18.668 ms  19.454 ms  20.136 ms
 5  10.0.0.8 (10.0.0.8)  20.979 ms  18.967 ms  19.550 ms
 6  10.0.1.9 (10.0.1.9)  20.278 ms  12.158 ms  12.819 ms
 7  10.0.1.14 (10.0.1.14)  13.474 ms  12.536 ms  12.112 ms
 8  10.0.1.6 (10.0.1.6)  11.689 ms  11.237 ms  11.233 ms
 9  10.0.0.8 (10.0.0.8)  11.203 ms  11.112 ms  11.077 ms
10  10.0.1.9 (10.0.1.9)  13.037 ms  13.892 ms  13.829 ms
11  10.0.1.14 (10.0.1.14)  14.188 ms  14.769 ms  14.895 ms
12  10.0.1.6 (10.0.1.6)  15.684 ms  16.649 ms  17.032 ms
13  10.0.0.8 (10.0.0.8)  17.190 ms  18.210 ms  18.781 ms
14  10.0.1.9 (10.0.1.9)  22.086 ms  22.523 ms  22.496 ms
15  10.0.1.14 (10.0.1.14)  22.693 ms  20.891 ms  21.293 ms
16  10.0.1.6 (10.0.1.6)  20.740 ms  20.585 ms  19.829 ms
17  10.0.0.8 (10.0.0.8)  19.382 ms  18.424 ms  18.687 ms
18  10.0.1.9 (10.0.1.9)  21.922 ms  21.324 ms  21.395 ms
19  10.0.1.14 (10.0.1.14)  21.018 ms  19.122 ms  19.564 ms
20  10.0.1.6 (10.0.1.6)  19.201 ms  18.760 ms  18.263 ms
21  10.0.0.8 (10.0.0.8)  16.733 ms  16.996 ms  17.013 ms
22  10.0.1.9 (10.0.1.9)  19.906 ms  19.880 ms  19.930 ms
23  10.0.1.14 (10.0.1.14)  20.102 ms  19.025 ms  19.476 ms
24  10.0.1.6 (10.0.1.6)  18.785 ms  19.064 ms  18.258 ms
25  10.0.0.8 (10.0.0.8)  19.445 ms  19.066 ms  18.627 ms
26  10.0.1.9 (10.0.1.9)  21.054 ms  20.863 ms  20.660 ms
27  10.0.1.14 (10.0.1.14)  20.150 ms  18.851 ms  18.970 ms
28  10.0.1.6 (10.0.1.6)  18.490 ms  17.041 ms  15.119 ms
29  10.0.0.8 (10.0.0.8)  14.817 ms  14.617 ms  14.580 ms
30  10.0.1.9 (10.0.1.9)  13.865 ms  11.498 ms  11.663 ms

## 3. Routing in a loop topology (solution)

The network configuraton in ``lab.conf`` is the following:

```
ha[0]="neta1"
ha[image]="kathara/base"

hb[0]="net4b"
hb[image]="kathara/base"

r1[0]="neta1"
r1[1]="net12"
r1[2]="net13"
r1[image]="kathara/frr"

r2[0]="net12"
r2[1]="net24"
r2[image]="kathara/frr"

r3[0]="net13"
r3[1]="net34"
r3[image]="kathara/frr"

r4[0]="net4b"
r4[1]="net24"
r4[2]="net34"
r4[image]="kathara/frr"
```


**Q3.1**

Assume matricola 123410, then M=10

| Network | Network address|
| ---| ---|
| neta1  |10.0.0.0/25|
|net12  | 10.0.1.0/30  |
|net24  | 10.0.1.8/30  |
|net13  | 10.0.1.4/30  |
|net34  | 10.0.1.12/30  |
| net4b|  10.0.0.128/25|

| Interface | IP address/netmask |
|---|--- |
| ha |10.0.0.1/25 |
| hb| 10.0.0.129/25|
| r1a |10.0.0.8/25|
| r12 | 10.0.1.1/30 |
| r13 | 10.0.1.5/30 |
| r21 | 10.0.1.2/30|
| r24 | 10.0.1.9/30|
| r31 | 10.0.1.6/30|
| r34|  10.0.1.13/30|
| r42 | 10.0.1.10/30 |
|r43|   10.0.1.14/30|
|r4b|   10.0.0.136/30|

**Q3.2**

We report the routing tables and the startup configuration file for each device. Note that it is enough to set the IP address of each network interface to get automatically the route entry for the corresponding network. 

**Host ha**

| Network prefix | Gateway | Interface |
|---|---|---|
|  10.0.0.0/25 | *  | eth0 |
| default/0 | 10.0.0.8 | eth0|

ha.startup:
```
ip address add 10.0.0.1/25 dev eth0

ip route add default via 10.0.0.8 dev eth0
```

**Host hb**

| Network prefix | Gateway | Interface |
|---|---|---|
|  10.0.0.128/25 | *  | eth0 |
| default/0 | 10.0.0.136 | eth0|

hb.startup:
```
ip address add 10.0.0.129/25 dev eth0

ip route add default via 10.0.0.136 dev eth0
```

**Router r1**

| Network prefix | Gateway | Interface |
|---|---|---|
|  10.0.0.0/25 | *  | eth0 |
| 10.0.1.0/30 | * | eth1 |
| 10.0.1.4/30 | * | eth2 |
| default/0 | 10.0.1.2 | eth1|

r1.startup:
```
ip address add 10.0.0.8/25 dev eth0
ip address add 10.0.1.1/30 dev eth1
ip address add 10.0.1.5/30 dev eth2

ip route add default via 10.0.1.2
```

**Router r2**
| Network prefix | Gateway | Interface |
|---|---|---|
|  10.0.1.0/30 | *  | eth0 |
| 10.0.1.8/30 | * | eth1 |
| 10.0.0.0/25 | 10.0.1.1 | eth0 |
| default/0 | 10.0.1.10 | eth1|

r2.startup:
```
ip address add 10.0.1.2/30 dev eth0
ip address add 10.0.1.9/30 dev eth1

ip route add 10.0.0.0/25 via 10.0.1.1
ip route add default via 10.0.1.10
```

**Router r3**
| Network prefix | Gateway | Interface |
|---|---|---|
|  10.0.1.4/30 | *  | eth0 |
| 10.0.1.12/30 | * | eth1 |
| 10.0.0.128/25 | 10.0.1.14 | eth1 |
| default/0 | 10.0.1.5 | eth0|


r3.startup:
```
ip address add 10.0.1.6/30 dev eth0
ip address add 10.0.1.13/30 dev eth1

ip route add 10.0.0.128/25 via 10.0.1.14
ip route add default via 10.0.1.5
```

**Router r4**
| Network prefix | Gateway | Interface |
|---|---|---|
|  10.0.0.128/25 | *  | eth0 |
| 10.0.1.8/30 | * | eth1 |
| 10.0.1.12/30 | * | eth2 |
| 10.0.0.0/25 | 10.0.1.13 | eth2|

r4.startup:
```
ip address add 10.0.0.136/25 dev eth0
ip address add 10.0.1.10/30 dev eth1
ip address add 10.0.1.14/30 dev eth2

ip route add 10.0.0.0/25 via 10.0.1.13
```

**Q3.3** 

The ```ping``` command highlights a 3 hops between ``ha`` and ``hb`` since the TTL is 61 (i.e., 64-3).

```
root@ha:/# ping 10.0.0.129 -c 1
PING 10.0.0.129 (10.0.0.129) 56(84) bytes of data.
64 bytes from 10.0.0.129: icmp_seq=1 ttl=61 time=5.60 ms

--- 10.0.0.129 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 5.597/5.597/5.597/0.000 ms
```

```
root@hb:/# ping 10.0.0.1 -c 1
PING 10.0.0.1 (10.0.0.1) 56(84) bytes of data.
64 bytes from 10.0.0.1: icmp_seq=1 ttl=61 time=3.70 ms

--- 10.0.0.1 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 3.697/3.697/3.697/0.000 ms
```


**Q3.4**



```
root@hb:/# traceroute  10.0.0.1 
traceroute to 10.0.0.1 (10.0.0.1), 30 hops max, 60 byte packets
 1  10.0.0.136 (10.0.0.136)  1.735 ms  2.533 ms  3.039 ms
 2  10.0.1.13 (10.0.1.13)  4.708 ms  5.022 ms  5.597 ms
 3  10.0.1.1 (10.0.1.1)  7.270 ms  7.675 ms  8.134 ms
 4  10.0.0.1 (10.0.0.1)  8.375 ms  8.737 ms  9.540 ms
 ```

```
 root@ha:/# traceroute 10.0.0.129 
traceroute to 10.0.0.129 (10.0.0.129), 30 hops max, 60 byte packets
 1  10.0.0.8 (10.0.0.8)  1.365 ms  1.682 ms  2.138 ms
 2  10.0.1.2 (10.0.1.2)  3.517 ms  3.991 ms  4.427 ms
 3  10.0.1.14 (10.0.1.14)  5.024 ms  5.171 ms  5.532 ms
 4  10.0.0.129 (10.0.0.129)  7.220 ms  7.751 ms  8.281 ms
```

<!--
**Q3.5**
To generate a loop, it is enough to substitute the following entry in the routing table of **r4**:

| Network prefix | Gateway | Interface |
|---|---|---|
| ... | ...| ...|
| 10.0.0.0/25 | 10.0.1.13 | eth2|

with 

| Network prefix | Gateway | Interface |
|---|---|---|
| ... | ...| ...|
| default/0 | 10.0.1.13 | eth2|


Now pinging an external IP address, a loop will be generated:
```
root@ha:/# ping 1.2.3.4 -c 1
PING 1.2.3.4 (1.2.3.4) 56(84) bytes of data.
From 10.0.1.6 icmp_seq=1 Time to live exceeded

--- 1.2.3.4 ping statistics ---
1 packets transmitted, 0 received, +1 errors, 100% packet loss, time 0ms
```

Similarly, ```traceroute``` will highlight a loop:  
```
root@ha:/# traceroute  1.2.3.4 
traceroute to 1.2.3.4 (1.2.3.4), 30 hops max, 60 byte packets
 1  10.0.0.8 (10.0.0.8)  1.109 ms  1.636 ms  2.639 ms
 2  10.0.1.2 (10.0.1.2)  3.137 ms  3.685 ms  5.202 ms
 3  10.0.1.14 (10.0.1.14)  7.017 ms  7.976 ms  8.352 ms
 4  10.0.1.6 (10.0.1.6)  9.900 ms  10.323 ms  10.599 ms
 5  10.0.0.8 (10.0.0.8)  10.604 ms  11.645 ms  11.933 ms
 6  10.0.1.2 (10.0.1.2)  12.266 ms  11.558 ms  11.658 ms
 ...

 -->
