# OSPF Lab I 

## Abstract
This lab uses the OSPF simple lab topology from Kathara with FRRouting (FRR). You will configure single-area OSPF and observe shortest paths affected by interface costs, Designated Routers (DRs), the Link State Database (LSDB), and topology changes. 

Answer preparation questions before the lab and perform hands-on experiments during the session.
Note: it is not mandatory to produce a report, but highly recommended to make the most of this lab.

## Preparation
Review OSPF concepts: link-state algorithm, DR/BDR election.  

**Question 0:** What is an LSA? How are LSA IDs and Router IDs determined in OSPF? 

LSA are link state algorithm, this means that are algorithm that have completly overview of the topology and the cost of the infrastructure, there exist a singolar.



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
It shows all the device that are directly connected with router and also they have ospf activate.

**Question 2:** What does the command  `show ip ospf database` do?  
It show all the network and all the router of the area that are connected with ospf, to have more information you need to use network or router.

**Question 3:** What does the command  `show ip ospf route` do? Why some of the routes may not be present in the global IP routing table? 
The command show the routing table to all  the network, router and external. It doesn't show any router.


**Question 4:** What does the command  `show ip ospf interface` do? 
The command show ip ospf interface show all the interface of the router that call this program, it show to which network is connected, the cost and who is the designeted router of that network and also who is the backup of this network.


**Question 5:** Run `show ip ospf neighbor` on all routers. How many neighbors per router? Explain.
In all the router the neighbor are three except for the router bb0 that in that case are four. It's easy to underastand why, in all the router there are three router that are directly connected to it except for the router in the middle that has 4 connection.

**Question 6:** Run `traceroute 10.0.2.1` from **bb1**. What do you observe?  
The package prefer to travers three different user instead of using the direct connection that exist between bb1 and bb4, it happens this because the cost for the direct connection is higher than the cost of passing in three different router.
N.B. the cost is calculate only by the out interface. 

**Question 7:** Run `traceroute 10.0.3.2` from **bb1**. What do you observe?

**Question 8:** Modify OSPF costs. Re-run traceroute and observe SPF recalculation (new LSAs and path changes). How long does it take to reconverge after the changes? How can you explain that?

## DR Election
**Question 9:** Identify DR per segment (e.g., 10.0.0.0/24 DR=10.0.3.1). Why are changes so infrequent?  

**Question 10:** Shut down interface **eth1** on **bb1**. What changes do you observe in the network?  
Specifically, analyze:
- OSPF convergence time  
- Link State Database (LSDB) updates  

**Question 11:** Now add losses on one link interconnecting two routers.
To do so, add to the .startup file of one of the routers:
```plaintext
tc qdisc add dev eth1 root netem loss 1%  # 1% random loss
```
Increase the losses. When do you observe variations in the LSDB? How long does it take to reconverge?

