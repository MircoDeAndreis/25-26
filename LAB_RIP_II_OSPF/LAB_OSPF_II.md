# OSPF Lab II: Multi-Area

## Abstract
This lab uses the OSPF multi-area lab topology from Kathara with FRRouting (FRR). You will configure multi-area OSPF, observe area-specific LSDBs, ABR summary LSAs, inter-area paths via the backbone, path types (intra/inter-area), and stub area default routes.

Answer preparation questions before the lab and perform hands-on experiments during the session.
Note: It is not mandatory to produce a report, but highly recommended to make the most of this lab.

## Preparation
Review OSPF multi-area concepts: areas (backbone, stub), ABRs, ASBRs, path types (intra-area, inter-area, E1/E2 external), summary LSAs.

**Question 0:** What is an ABR? How do routers in stub areas learn external routes?

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

**Question 2:** What does `show ip ospf route` display for inter-area (IA) paths?

**Question 3:** Run `show ip ospf neighbor` on backbone and stub routers. How many neighbors? Why no adjacency across areas?

**Question 4:** Run `traceroute 200.0.0.2` from bb0 (backbone). What path via ABR? Run reverse from r2.

**Question 5:** On an ABR, run `show ip ospf database router` for area 0.0.0.0 and 1.1.1.1. How many link state databases do you observe?

**Question 6:** Modify interface cost on backbone link (e.g., eth0 on bb0 to 50). Re-run traceroute from router r2 in the stub area. Explain how inter-area reconvergence takes place, and measure how long it takes.

## ABR and Path Types

**Question 7:** Identify ABRs and areas. Run `show ip ospf database summary` on internal routers. Note metrics from ABR.

**Question 8:** On stub router **I**, check `show ip ospf route` for default route (0.0.0.0). Why is it present? What is the metric?

**Question 9:** Shut down ABR link to the stub (eth1 on **E**). Observe and note convergence time, and LSDB changes.

**Question 10:** Add link loss: 
```plaintext
tc qdisc add dev eth1 root netem loss 1%  # on ABR
```
Increase to 5%. Monitor LSDB variations and reconvergence in the stub area.

## Advanced: Stub and External (Complex Scenario)

**Preparation for ASBR:** Add ASBR router **O** to lab.conf (connected to backbone, e.g., D[2]=O):
~~~
O[image]="kathara/frr"
O[0]=D
~~~

.startup for **O**:
~~~
ip address add 140.0.0.1/24 dev eth0
ip address add 50.0.0.1/16 dev lo  # simulate external prefix
systemctl start frr
~~~

**Question 11:** Configure area 1.1.1.1 as `stub no-summary` on ABR (**E**) and internals (**I**, **J**).

On ABR **E** /etc/frr/frr.conf:
~~~
router ospf
 ...
 area 1.1.1.1 stub no-summary
~~~

On **I**, **J**:
~~~
router ospf
 ...
 area 1.1.1.1 stub
~~~

Reload: `systemctl restart frr` on all. Verify no ASBR-summary in stub:
- **I**: `show ip ospf database asbr-summary` → empty
- **A** (backbone): sees summaries from **E**

**Question 12:** Configure ASBR **O** to inject external route 50.0.0.0/16 as E2.
<img width="1856" height="1372" alt="image" src="https://github.com/user-attachments/assets/4c4e99d1-5ad8-42a7-96c6-5994d3470af0" />
On **O** /etc/frr/frr.conf (enable bgpd too: /etc/frr/daemons bgpd=yes):
~~~
!
ip prefix-list EXTERNAL permit 50.0.0.0/16
!
router bgp 65000  # dummy AS
 bgp router-id 10.0.3.3
 network 50.0.0.0/16
 neighbor 140.0.0.2 remote-as 65000  # loop to self, or connect fabric
!
router ospf
 redistribute bgp metric-type 2 metric 100 subnets
 network 140.0.0.0/24 area 0.0.0.0
!
~~~
Restart FRR on **O**. Verify:

**Backbone** (**A**):
- `show ip ospf database external` → E2 LSA from **O** (metric 100 + OSPF cost to ASBR)
- `show ip route` → `O E2 50.0.0.0/16 [110/100] via 140.0.0.1`

**Stub** (**I**):
- `show ip ospf database external` → empty (blocked by no-summary)
- `show ip route` → only default `O 0.0.0.0/0 [110/20] via 100.0.0.1` (to ABR)

Test: `ping 50.0.0.1` from **A** → succeeds via ASBR; from **I** → via default to backbone.


