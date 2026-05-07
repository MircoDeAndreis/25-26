# LAB-K7. Two levels load balancing for a web service

## 5.1 Lab setup

We will consider the network scenario illustrated in the following Figure:

![Net4](Figs/LABK7.png)

Download and unzip the folder containing the lab setup: kathara-lab_two-levels-load-balancing.zip and familiarize youself
with the main configuration files.

## 5.1 Basic questions

Answer the following questions:  

1. Which file contains the basic configuration allowing the first level of load balancing (by DNS). Why does it work?
2. Which file contains the basic configuration allowing the second level of load balancing (layer-4 load balancing). How does it work?

## 5.2 Test load balancing
Type `links www.uniroma3.it` on the client to experiment load balancing. Try reloading the page several times 
with CTRL-R. What happens? Why? Try closing and launching links several times. 
Ask an AI to write a python script to compute the distribution of server used. Put the script in the 
shared folder to access it on the client. Run the script to verify an almost uniform distribution (25% for each server)
with large enough number of servers.

## 5.3 Sniff DNS traffic 
Use `rndc flush` the clean the cache on ldns.
Connect a wireshark device to collision domain D.
Open any browser on the host machine on localhost:3000, sniff eth1, launch links on the client and identify on the packet trace 
the recursive operation of DNS. Isolate in the proper packet the bytes containing the IP address 22.2.2.2 

## 5.4 (Optional) Experiments with machine failures:
1. Emulate failure of ws3: (using `ip link set eth0 down`). Try fetching `www.uniroma3.it` several times from the client,
possibly using the automated script suggested in 5.2. What do you expect to happen? Why?
3. Emulate failure of load balancer lb1: shut down the corresponding container and remove the corresponding DNS record. Try fetching several times `www.uniroma3.it` from the client. What do you expect to happen? Why?     



