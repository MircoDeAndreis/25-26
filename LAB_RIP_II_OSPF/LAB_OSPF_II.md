# OSPF Lab II: Multi-Area

## Abstract
This lab uses the OSPF multi-area lab topology from Kathara with FRRouting (FRR). You will configure multi-area OSPF, observe area-specific LSDBs, ABR summary LSAs, inter-area paths via the backbone, path types (intra/inter-area), and stub area default routes.

Answer preparation questions before the lab and perform hands-on experiments during the session.
Note: it is not mandatory to produce a report, but highly recommended to make the most of this lab.

## Preparation
Review OSPF multi-area concepts: areas (backbone 0.0.0.0, stub), ABRs, ASBRs, path types (intra-area, inter-area, E1/E2 external), summary LSAs.

**Question 0:** What is an ABR? How do routers in stub areas learn external routes?

## Setup

Set up the lab configuration files and those of each router to implement the following multi-area topology.

<img width="2126" height="1352" alt="image" src="https://github.com/user-attachments/assets/dd92b472-09be-4712-b78a-3b05dc5b9ebc" />
In lab.conf, add lines for routers A, B, C, D (backbone area 0.0.0.0), E (ABR), and others in areas like 1.1.1.1 (stub), 2.2.2.2 with FRR images.

~~~
A[image]="kathara/frr"
B[0]=A;B[image]="kathara/frr"
C[0]=B;C[1]=D;C[image]="kathara/frr"
D[0]=C;D[1]=E;D[image]="kathara/frr"
E[0]=D;E[1]=I;E[2]=G;E[image]="kathara/frr"
I[0]=E;I[image]="kathara/frr"
~~~

The `.startup` file for backbone routers (e.g., A):

~~~
ip address add 10.0.0.1/24 dev eth0
ip address add 10.0.1.1/24 dev eth1
systemctl start frr
~~~

For ABR E:

~~~
ip address add 10.0.2.1/24 dev eth0  # backbone
ip address add 100.0.0.1/30 dev eth1  # area 1.1.1.1
ip address add 110.0.0.1/30 dev eth2  # area 2.2.2.2
systemctl start frr
~~~

Remember to edit `/etc/frr/daemons` to enable OSPF (`ospfd=yes`).

Example FRR configuration file for backbone router A:

~~~
!
interface eth0
 ip ospf cost 10
interface eth1
 ip ospf cost 10
!
router ospf
 network 10.0.0.0/24 area 0.0.0.0
 network 10.0.1.0/24 area 0.0.0.0
!
~~~

For ABR E:

~~~
!
interface eth0
 ip ospf cost 10
interface eth1
 ip ospf cost 10
interface eth2
 ip ospf cost 10
!
router ospf
 network 10.0.2.0/24 area 0.0.0.0
 network 100.0.0.0/30 area 1.1.1.1
 network 110.0.0.0/30 area 2.2.2.2
 area 1.1.1.1 stub
!
~~~

For stub area router I:

~~~
!
interface eth0
 ip ospf cost 10
!
router ospf
 network 200.0.0.0/30 area 1.1.1.1
!
~~~

## OSPF Multi-Area Neighbor Discovery

First, answer the following questions:

**Question 1:** What does `show ip ospf database summary` show in multi-area OSPF?

**Question 2:** What does `show ip ospf route` display for inter-area (IA) paths?

**Question 3:** Run `show ip ospf neighbor` on backbone (**A**) and stub routers (**I**). How many neighbors? Why no adjacency across areas?

**Question 4:** Run `traceroute 200.0.0.2` from **A** (backbone). What path via ABR? Run reverse from stub.

**Question 5:** On ABR **E**, run `show ip ospf database router` for area 0.0.0.0 and 1.1.1.1. Confirm separate LSDBs.

**Question 6:** Modify interface cost on backbone link (e.g., eth1 on **A** to 50). Re-run traceroute from stub. Observe inter-area reconvergence.

## ABR and Path Types

**Question 7:** Identify ABRs and areas. Run `show ip ospf database summary` on internal routers. Note metrics from ABR.

**Question 8:** On stub router **I**, check `show ip ospf route` for default route (0.0.0.0). Why present? Metric?

**Question 9:** Shut down ABR link to stub (eth1 on **E**). Observe convergence time, LSDB changes, failover if ECMP.

**Question 10:** Add link loss: 
```plaintext
tc qdisc add dev eth1 root netem loss 1%  # on ABR
