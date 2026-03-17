# OSPF Lab I

## Abstract
This lab uses the OSPF simple lab topology from Kathara with FRRouting (FRR). You will configure single-area OSPF and observe shortest paths affected by interface costs, Designated Routers (DRs), the Link State Database (LSDB), and topology changes. 

Answer preparation questions before the lab and perform hands-on experiments during the session.

## Preparation
Review OSPF concepts: link-state algorithm, areas, DR/BDR election.  

**Question 0:** What is an LSA? How are LSA IDs and Router IDs determined in OSPF? 
An LSA is a small packet of routing information that a router creates and floods to every other OSPF router in the area (or the whole network).  
<img width="1827" height="1221" alt="image" src="https://github.com/user-attachments/assets/bef2db4e-c36e-4bd0-91c1-6f9238d3465e" />
<img width="1748" height="1062" alt="image" src="https://github.com/user-attachments/assets/83f5bcb5-d3d3-4324-91b9-b3ad06e45f6a" />

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
<img width="1797" height="612" alt="image" src="https://github.com/user-attachments/assets/ce5f3868-b019-4fc9-87db-bd4d8b2fbcfa" />


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

```
<img width="1640" height="695" alt="image" src="https://github.com/user-attachments/assets/36d9dec3-d4a0-4248-938a-3e39e77584b6" />

**Question 3:** What does the command  `show ip ospf route` do? Why some of the routes may not be present in the global IP routing table? 

<img width="1390" height="393" alt="image" src="https://github.com/user-attachments/assets/6cc7da0a-18e9-4b59-a802-eb6c2409eb09" />
<img width="1404" height="702" alt="image" src="https://github.com/user-attachments/assets/11572aa9-461e-4ec5-b9b2-9d52d0814254" />
<img width="1404" height="459" alt="image" src="https://github.com/user-attachments/assets/64f22ad4-fe57-475a-a1e7-03e5dedb5c7a" />

**Question 4:** What does the command  `show ip ospf interface` do? 

<img width="1669" height="843" alt="image" src="https://github.com/user-attachments/assets/ad982193-bdb6-4aae-ae06-caf21edba8ad" />

**Question 5:** Run `show ip ospf neighbor` on all routers. How many neighbors per router? Explain.

Expect 2 neighbors on most (e.g., bb1: bb0, bb2). Full state for LSDB sync; DR elected by priority (default 1), tiebreak Router ID.

Perform traceroutes from/to different interfaces to verify SPF paths and symmetry.

**Question 6:** Run `traceroute 10.0.2.1` from **bb1**. What do you observe?  

  - Expected path: Low-cost route (e.g., bb1 → bb0 → bb2; cost 21 + 10 vs. higher cost 45)  
  - ICMP reply path: Symmetric (reverse path follows the same SPF tree due to shared LSDB)

**Question 7:** Run `traceroute 10.0.3.2` from **bb1**,What do you observe?

  - Expected path: bb1 → bb0 → bb3 (cost 36 + 10 = 46)

**Question 8:** Modify OSPF costs. Re-run traceroute and observe SPF recalculation (new LSAs and path changes). How long does it take to reconverge after the changes? How can you explain that?

## DR Election
**Question 9:** Identify DR per segment (e.g., 10.0.0.0/24 DR=10.0.3.1). Why are changes so infrequent?  

**Solution:** Highest priority/Router ID. New DR floods LSAs, so stable unless failure.

**Question 10:** Shut down interface **eth1** on **bb1**. What changes do you observe in the network?  
Specifically, analyze:
- OSPF convergence time  
- Link State Database (LSDB) updates  

**Solution:**
- When the interface goes down, OSPF immediately detects the link failure and generates a new LSA reflecting the change.  
- This triggers a fast update across the network and recalculation of SPF paths.  

- **Convergence time:**
  - **Fast for direct link failure** (triggered instantly by interface down event)  
  - **Slower in other cases** (e.g., neighbor/DR loss), which depend on timers such as:
    - Dead Interval (~40 seconds by default)  
    - LSA MaxAge (up to 1 hour in worst-case scenarios)  

- **LSDB behavior:** 
  - The LSDB is quickly updated with the new topology information  
  - Routers recompute shortest paths based on the updated LSAs  

**Question 11:** Now add losses on one link interconnecting two routers.
To do so, add to the .startup file of one of the routers:
```plaintext
tc qdisc add dev eth1 root netem loss 1%  # 1% random loss
```
Increase the losses. When do you observe variations in the LSDB? How long does it take to reconverge?

