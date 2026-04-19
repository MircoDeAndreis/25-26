# OSPF Lab II: Multi-Area

## Abstract
This lab uses the OSPF multi-area lab topology from Kathara with FRRouting (FRR). You will configure multi-area OSPF, observe area-specific LSDBs, ABR summary LSAs, inter-area paths via the backbone, path types (intra/inter-area), and stub area default routes.

Answer preparation questions before the lab and perform hands-on experiments during the session.
Note: It is not mandatory to produce a report, but highly recommended to make the most of this lab.

## Preparation
Review OSPF multi-area concepts: areas (backbone, stub), ABRs, ASBRs, path types (intra-area, inter-area, E1/E2 external), summary LSAs.

**Question 0:** What is an ABR? How do routers in stub areas learn external routes?

- An abr is a router of the backbone area that it is connected to another stub area. Via an asbr that comunicate to the network the external routes normally with protocol like BGP

## Setup

Set up the lab configuration files and the router configuration files to implement the following multi-area topology.

<img width="2126" height="1352" alt="image" src="https://github.com/user-attachments/assets/dd92b472-09be-4712-b78a-3b05dc5b9ebc" />
Remember to edit `/etc/frr/daemons` to enable OSPF (`ospfd=yes`). Create one subfolder and a `.startup` file for each router. 
Example FRR configuration file `frr.conf` for backbone router bb1:

~~~
!
! FRRouting configuration file
!
!
!  OSPF CONFIGURATION
!
interface eth0
ospf cost 90
!
router ospf
! Speak OSPF on all interfaces falling in the listed subnets
network 10.0.0.0/16 area 0.0.0.0
network 100.0.0.0/30 area 1.1.1.1
network 110.0.0.0/30 area 2.2.2.2
area 1.1.1.1 stub
area 2.2.2.2 stub
!
!
log file /var/log/frr/frr.log
~~~

For r1:

~~~
!
! FRRouting configuration file
!
!
!  OSPF CONFIGURATION
!
router ospf
! Speak OSPF on all interfaces falling in the listed subnets
network 100.0.0.0/30 area 1.1.1.1
network 200.0.0.0/16 area 1.1.1.1
area 1.1.1.1 stub
!
log file /var/log/frr/frr.log
~~~

For bb1, the startup file is:

~~~
ip address add 10.0.0.1/24 dev eth0
ip address add 10.0.3.1/24 dev eth1
ip address add 100.0.0.1/30 dev eth2
ip address add 110.0.0.1/30 dev eth3
systemctl start frr
~~~


## OSPF Multi-Area Neighbor Discovery

First, answer the following questions:

**Question 1:** What does `show ip ospf database summary` show in multi-area OSPF?

- Show every link discovered by ospf, it also show the router that discovered this connection that in the case of external area connection it is always the area border router connected to that area.

**Question 2:** What does `show ip ospf route` display for inter-area (IA) paths?

- It shows all the network in the autonomus system and all the area border router in the same area except for himself(if it is a area border router). It also specify if the network is inside an area of the router or outside and it need to pass to one or more different area. 

**Question 3:** Run `show ip ospf neighbor` on backbone and stub routers. How many neighbors? Why no adjacency across areas?

- It depends on the router but in general, it is the same amount of neighbour that you can count watching the graph.


**Question 4:** Run `traceroute 200.0.0.2` from bb0 (backbone). What path via ABR? Run reverse from r2.

- traceroute to 200.0.0.2 (200.0.0.2), 30 hops max, 60 byte packets
 1  10.0.0.1 (10.0.0.1)  1.478 ms  2.065 ms  2.581 ms
 2  100.0.0.2 (100.0.0.2)  9.304 ms  10.961 ms  11.066 ms
 3  200.0.0.2 (200.0.0.2)  12.064 ms  12.406 ms  12.726 ms

- traceroute to 10.0.0.3 (10.0.0.3), 30 hops max, 60 byte packets
 1  200.0.0.1 (200.0.0.1)  1.939 ms  2.725 ms  4.169 ms
 2  100.0.0.1 (100.0.0.1)  5.112 ms  6.151 ms  7.005 ms
 3  10.0.0.3 (10.0.0.3)  9.130 ms  12.966 ms  12.859 ms

**Question 5:** On an ABR, run `show ip ospf database router` for area 0.0.0.0 and 1.1.1.1. How many link state databases do you observe?

- for 1.1.1.1 three, instead for 0.0.0.0 they are five.

**Question 6:** Modify interface cost on backbone link (e.g., eth0 on bb0 to 50). Re-run traceroute from router r2 in the stub area. Explain how inter-area reconvergence takes place, and measure how long it takes.

- For packet than want to go from r2 to r5, if we modify the ospf cost path of bb3 eth0 to over than 10, it will gonna redirect the message to bb0 instead of bb3, because the main route is r1,bb1,bb4,bb3,bb2,r5 with cost 50 that it is equal to this path r1,bb1,bb4,bb0,bb2,r5, so if we modify bb3 interface eth0 even of one point we redirect every packet. 

## ABR and Path Types

**Question 7:** Identify ABRs and areas. Run `show ip ospf database summary` on internal routers. Note metrics from ABR.

Ask professor

**Question 8:** On stub router r2, check `show ip ospf route` for default route. Why is it present? What is the metric?

ask professor

<!--
On the stub router (likely r2 or r3 in area 1.1.1.1 or 2.2.2.2), show ip ospf route displays a default route O 0.0.0.0/0 [110/metric] (e.g., 11 or 20), via the ABR interface (e.g., eth1 to 100.0.0.1).
​

It is present because stub areas automatically receive a default route from the ABR instead of detailed external (AS-external) LSAs, reducing LSDB size and external route flooding—no ASBRs allowed in stubs.
​

The metric (e.g., 11) reflects the ABR-advertised cost: OSPF seed metric 10 + link cost to ABR (e.g., 1), with AD 110; backbone routers lack this default.
-->

**Question 9:** Shut down ABR link to the stub (eth2 on bb1). Observe and note convergence time and LSDB changes.

When I shutdown a interface it needs a little amount of time to change routing path.
<!--
Shutting down eth1 on ABR **E** (link to stub area 1.1.1.1) triggers fast OSPF reconvergence (~1-5 seconds in FRR lab). 

## Expected Observations

**Immediate effects (sub-second):**
- Interface down detected; **E** stops Hellos on eth1.
- Kernel removes connected route; Zebra notifies OSPF. 

**LSDB Changes (1-3s):**
- r2 flushes/updates its Router LSA (Type 1) in stub area LSDB (removes eth1 link).
- No DR Type 2 LSA if point-to-point (/30); stub routers detect adjacency loss, reflood LSAs.
- If ECMP to backbone (e.g., via **G** 110.0.0.0/30), ABR **E** recalculates inter-area summaries; injects updated default Type 3 LSA (metric increases if alternate path longer). Stub LSDB shows new Type 3 default via backup ABR path. 

**Stub routers (**I**, **J**):**
- Lose adjacency to **E**; SPF rerun → default route switches to alternate ABR (e.g., metric from 11 → 21).
- `show ip ospf database summary` → updated Type 3 0.0.0.0/0 from backup ABR.
- No external LSAs (stub blocks). 

**Convergence time:** <5s total (Hello/Dead ~40s default, but LSA flood/SPF fast); faster with ECMP as OSPF precomputes multiples (`show ip route` shows both pre-fail). 

**Verify:** `show log` for "link down", SPF events; `watch show ip ospf route` on stub for default flip.
-->

**Question 10:** Add link loss on ABR towards stub area: 
```plaintext
tc qdisc add dev eth1 root netem loss 1%  # on ABR
```
Increase to 5%. Monitor LSDB variations and reconvergence in the stub area.

**Question 1:** Reconfigure the backbone area to use RIP instead of OSPF. What are the key changes in the OSPF databases present in each stub area, with respect to the previous case?

The stub area aren't connected to each other because all the backbone router doesn't comunicate to the different stub area, so there exist only connection between the same areas.
## Advanced: Stub and External with BGP
Use OSPF for backbone area.  
Add ASBR router AS100r1 to lab.conf (connected to backbone):
<img width="1856" height="1372" alt="image" src="https://github.com/user-attachments/assets/4c4e99d1-5ad8-42a7-96c6-5994d3470af0" />
Sample `frr.conf` for router AS100r1:
~~~
!
! FRRouting configuration file
!
!
!    BGP CONFIGURATION
!
!
router bgp 100
no bgp ebgp-requires-policy
no bgp network import-check
network 50.0.0.0/16
neighbor 140.0.0.1 remote-as 10
neighbor 140.0.0.1 description bb3
!
log file /var/log/frr/frr.log
!
debug bgp
debug bgp events
debug bgp filters
debug bgp fsm
debug bgp keepalives
debug bgp updates
!
~~~
For bb3:
~~~
!
! FRRouting configuration file
!
!
!    OSPF CONFIGURATION
!
!
router ospf
! Speak OSPF on all interfaces falling in 10.0.0.0/16
network 10.0.0.0/16 area 0.0.0.0
default-information originate always

!
!    BGP CONFIGURATION
!
router bgp 10
no bgp ebgp-requires-policy
no bgp network import-check
network 10.0.0.0/16
network 100.0.0.0/30
network 110.0.0.0/30
network 120.0.0.0/30
network 130.0.0.0/30
network 200.0.0.0/16
network 210.0.0.0/16
network 220.0.0.0/16
neighbor 140.0.0.2 remote-as 100
neighbor 140.0.0.2 description as100r1
!
log file /var/log/frr/frr.log
!
debug bgp
debug bgp events
debug bgp filters
debug bgp fsm
debug bgp keepalives
debug bgp updates
!
!
~~~
Do not forget to enable the OSPF and BGP daemons on the appropriate routers.

**Question 11:** Configure area 1.1.1.1 as `stub no-summary` on ABR and internal routers.

On ABR, add (/etc/frr/frr.conf):
~~~
router ospf
 ...
 area 1.1.1.1 stub no-summary
~~~

On internal routers at stub, add:
~~~
router ospf
 ...
 area 1.1.1.1 stub
~~~

Are there ASBR-summary in stub area routers?:
- Internal router: run `show ip ospf database asbr-summary`
  <!-- it should be empty-->
- ABR:?
 
**Question 12:** Configure ASBR to inject external route 50.0.0.0/16 as E2.
On **O** /etc/frr/frr.conf, add: 
~~~
....
!
ip prefix-list EXTERNAL permit 50.0.0.0/16
!
 network 50.0.0.0/16
....
~~~
Restart the scenario. Run `show ip ospf database external`  and `show ip route` on a backbone and an internal router in the stub area. 
What do you observe?

Test: `ping 50.0.0.1`  and traceroute from bb1 and r2. What do you observe?


