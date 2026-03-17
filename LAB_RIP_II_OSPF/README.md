# OSPF Lab Exercise
**March 17, 2026** 

## Abstract
This lab uses the OSPF simple lab topology from Kathara with FRRouting (FRR). You will configure single-area OSPF, observe shortest paths influenced by interface costs, Designated Routers (DR), Link State Database (LSDB), and topology changes. 

Answer preparation questions before the lab and perform hands-on experiments during the session.

## Preparation
Review OSPF concepts: link-state algorithm, areas, DR/BDR election, LSAs, SPF computation.

Review FRR commands like `show ip ospf neighbor`, `show ip ospf database`, `show ip ospf route`.

## Setup

Set up the lab configuration files and those of each router to implement the following configuration: 
<img width="2349" height="1183" alt="image" src="https://github.com/user-attachments/assets/3c46b60f-6a2b-455b-8b84-bda0bbfecb67" />
In lab.conf, add the lines

~~~
bb0[0]=A  
bb0[1]=C  
bb0[image]="kathara/frr"  
(...)
~~~
The `.startup` file for each router will be of the form:

~~~
ip address add 10.0.0.3/24 dev eth0  
ip address add 10.0.2.3/24 dev eth1  
systemctl start frr
~~~

Remember to edit `/etc/frr/daemons` to enable OSPF (`ospfd=yes`).

Example of frr configuration file:

~~~
!
! FRRouting configuration file
!

!
! Default cost for exiting an interface is 10
interface eth0
	ospf cost 21
interface eth1
	ospf cost 36
!
router ospf
! Speak OSPF on all interfaces falling in the listed subnets
network 10.0.0.0/16 area 0.0.0.0
!
~~~
## OSPF Neighbor Discovery

First, answer the following questions:

**Question 1:** What does the command `show ip ospf neighbor` do?

<img width="1795" height="848" alt="image" src="https://github.com/user-attachments/assets/f790ed5d-8d1c-4395-8250-bb9615da57b2" />


**Question 2:** What does the command  `show ip ospf database` do? 
**`show ip ospf database`** is the command that displays the **complete OSPF Link-State Database (LSDB)** on the router.

This is the “brain” of OSPF — it contains every Link-State Advertisement (LSA) the router has received (or originated) for all areas it participates in. Running this command lets you see exactly what topology information OSPF is using to build its routing table.

### Typical default output

```plaintext
Router# show ip ospf database

            OSPF Router with ID (192.168.1.1) (Process ID 1)

                Router Link States (Area 0)

Link ID         ADV Router      Age         Seq#       Checksum  Link count
192.168.1.1     192.168.1.1     1234        0x80000005 0x00A3B1  3
192.168.1.2     192.168.1.2     456         0x80000003 0x00F2C4  2

                Net Link States (Area 0)

Link ID         ADV Router      Age         Seq#       Checksum
10.10.10.2      192.168.1.2     789         0x80000001 0x0045D2

                Summary Net Link States (Area 0)

Link ID         ADV Router      Age         Seq#       Checksum
10.20.20.0      192.168.1.1     567         0x80000002 0x00E7A1

**Question 3:** What does the command  `show ip ospf route` do? 
OSPF RIB: N intra-area subnets (cost/area/via if/next-hop); O routers. Shows SPF shortest paths from LSDB + link costs.

**Question 4:** What does the command  `show ip ospf interface` do? 







**Question 1:** Run `show ip ospf neighbor` on all routers. How many neighbors per router? Explain Full/DR/DROther states.  

**Solution:** Expect 2 neighbors on most (e.g., bb1: bb0, bb2). Full state for LSDB sync; DR elected by priority (default 1), tiebreak Router ID.

## LSDB and Topology View
**Question 2:** Run `show ip ospf database` (router, network LSAs). Verify identical LSDB across routers? Decode one Router LSA: Link ID, Links.  
**Solution:** Yes, identical in single area. Router LSA Link ID=Router ID, links to Transit Networks (DR addr).

## Shortest Paths and Costs
**Question 3:** `show ip ospf route`. Predict traceroute bb1 (10.0.0.1?) to 10.0.2.1 path/cost. Run `traceroute 10.0.2.1`. Matches? Reply path same?  
**Solution:** Via low-cost path (e.g., cost 21 via bb0), not high-cost 45. Symmetric due to shared LSDB.

## DR Election
**Question 4:** Identify DR per segment (e.g., 10.0.0.0/24 DR=10.0.3.1). `show ip ospf interface`. Why infrequent changes?  
**Solution:** Highest priority/Router ID. New DR floods LSAs, so stable unless failure.

## Topology Changes
**Question 5:** Down link (e.g., `ip link set eth1 down` on bb1). Observe `show ip ospf route` changes. Time to converge? LSDB update?  
**Solution:** Fast for link (immediate LSA), slower for router/DR (DeadInterval 40s or MaxAge 1h).

## Cost Modifications
**Question 6:** Change cost (e.g., `interface eth1`, `ospf cost 5`). Predict/verify new paths via traceroute.  
**Solution:** SPF recomputes; observe shift to lower total cost path.

## Cleanup
Stop FRR: `killall ospfd zebra`. `kathara lclean`. Reboot if physical.[file:2]
