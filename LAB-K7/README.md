# LAB-K7. Two levels load balancing for a web service

## 5.1 Lab setup

We will consider the network scenario illustrated in the following Figure:

![Net4](Figs/LABK7.png)

Download and unzip the folder containing the lab setup: kathara-lab_two-levels-load-balancing.zip and familiarize youself
with the main configuration files.

## 5.1 Basic questions

Answer the following questions:  

1. Which file contain the basic configuration allowing the first level of load balancing (by DNS). Why does it work?
2. Which file contain the basic configuration allowing the second level of load balancing (layer-4 load balancing). How does it work?

## 5.2 Test load balancing
Use local-preference to influence outbound traffic (exiting AS6003). Use AS-PATH prepending (check Internet/AI for its meaning) to influence in-bound traffic (directed to AS 65003)   

## 5.3 Sniff DNS traffic 
After you setup the routing protocol(s), try to shut down the primary link to ISP2 and see if the secondary link restores connectivity:

1. First, try that by shutting down the neighbor ISP2 inside the BGP configuration terminal on R3 (see slides). How long does it take to restore connectivity?
2. Then shut down one of the ethernet interfaces of the primary link using "ip link set eth<n> down". How long does it take to restore connectivity in this case? why?

## 5.4 (Optional) Experiments with machine failures:
1. Failure of ws3: shut down the corresponding container. Try fetching www.uniroma3.it from the client. What do you expect to happen? Why?
2. Failure of load balancer lb1: shut down the corresponding container. Try fetching www.uniroma3.it from the client. What do you expect to happen? Why?     



