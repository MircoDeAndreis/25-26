# LAB-K2. Basics on Kathara

The aim of this lab is (i) to learn the basic usage of [Kathara](https://www.kathara.org) to emulate simple networks and (ii) to review basic IPv4 routing. 

ON YOUR DEVICE:

0. Download and install Kathara'. Follow instructions on [Intro to Kathara'](https://github.com/compl-reti-unito/25-26/blob/main/Theory_slides/001-kathara-introduction.pdf)

If installing on Debian 12/13, here are the commands (after installing Docker) that should install Kathara (resolved with Gemini):
```shell
text
echo "deb [trusted=yes] http://ppa.launchpad.net/katharaframework/kathara/ubuntu jammy main" | sudo tee /etc/apt/sources.list.d/kathara.list  
  
sudo apt update  
  
sudo apt install kathara  
  
kathara check  
```

ON A PC IN DIJKSTRA:
>[!NOTE]
>The folders related to the official repository labs of Kathara are available under the local `Kathara-Labs` folder on the VM. 
All the activities for the class labs are instead available under the  local `Datacenter-Lab-CE` folder, in order to simplify the copy&paste actions. All the folder references present in the following text refer to such a local folder.

## First steps

0. Open a terminal and change the folder `cd Datacenter-lab-CE`. Update the lab activity with `git pull`.

1. Type `kathara check` from the command line and check that the message `Container run successfully` appears. 
2. Read carefully the slides in the [Intro to Kathara'](https://github.com/compl-reti-unito/25-26/blob/main/Theory_slides/001-kathara-introduction.pdf)
   * Change the default Docker image (sl. 15) by running `kathara settings`
   * Test Kathara (sl. 22)
   * Understand the meaning of ``kathara lstart``, ``kathara lclean``, ``kathara lrestart``, ``kathara linfo``, `kathara list`, `kathara wipe` commands
   * Understand the meaning of `lab.conf` file (sl. 25-26) and `.startup` file (sl.30)
3. Enter `LAB-K2/K2-TwoHosts` 
   * Read the `lab.conf` and `.startup` files. 
   * Draw the topology. 
     * Q1. What are the IP addresses?
        * Pc1 -> 10.0.0.1
        * Pc2 -> 10.0.0.2 
     * Q2. What are the routing tables?
        * It is tables that contains the different best path of forwarding. 
     * Q3. What is the current state of images and running containers, before starting Kathara? Show the outputs of the proper `docker` commands.
        * docker ps -a
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
   * Start the lab with `kathara lstart`.
     * Q4. What is the current state of images and running containers after starting Kathara? Show the outputs of the proper `docker` commands.
        * docker ps
CONTAINER ID   IMAGE          COMMAND   CREATED          STATUS          PORTS     NAMES
5f5fa52293db   kathara/base   "bash"    11 seconds ago   Up 10 seconds             kathara_mircodeandreis-ondp9aw5ipht9i0ifiyjg_pc1_u158au35kYqBOzBkpThKg
0acb79185cbf   kathara/base   "bash"    11 seconds ago   Up 10 seconds             kathara_mircodeandreis-ondp9aw5ipht9i0ifiyjg_pc2_u158au35kYqBOzBkpThKg
     * Q5. Use `ip` command (see the reference table below) to show the IP addresses of the interfaces and the routing tables, for both hosts. 
         * 21: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    inet 10.0.0.1/24 scope global eth0
       valid_lft forever preferred_lft forever
         * 10.0.0.0/24 dev eth0 proto kernel scope link src 10.0.0.1 
     * Q6. Using `ping`, check the connectivity between the two hosts and report the output. What is going on?
   Why does latency change over time?
         * The output shows that in both of the case the connective is activated, because kathara simulated a real enviroment for this reason is the latency is not stable.
     * Q7. What is the output of `kathara linfo` when the lab is running?
         * The output of kathara linfo shows the stats of all the machine that are actually running on this lab.
     * Q8. What is the output of `kathara list` when the lab is running?
         * It is equal to kathara linfo the only differnce is that kathara list shows all the machine that are running on the computer instead kathara linfo show only the stats of one specific lab.
     * Q9. Show the routing table at both hosts. What is the meaning of what you see? Who configured that? 
         * ip route list
10.0.0.0/24 dev eth0 proto kernel scope link src 10.0.0.2 
         * ip route list
10.0.0.0/24 dev eth0 proto kernel scope link src 10.0.0.1 
         * It means that boths of this pc are connected together, the kernel of linux configured this devices.
   * Within a container of a device, create a file (e.g., using `touch prova.txt`)
     and copy into `/shared` folder. Make sure you can access it from
     any other container and from the local file system. Note that
     this is useful to copy the output of a command within a container
     of a device to the local file system and to export to the
     persistent storage. Try with `ip -4 address > shared/ip.txt` and open the
     file with `gedit` from the local file system.
   * Now stop the lab using `kathara lclean`.
     * Q10. What is the current state of images and running containers after closing Kathara? Show the outputs of the proper `docker` commands.
         * docker ps 
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
         * After kathara lclean all the docker image are cancell.

## Reference commands

* NETPREFIX is a network prefix (e.g., `10.1.2.0/24`)
* IP is an IP address of an interface (e.g., `10.1.2.1`)
* IP/MASK is an IP address with network mask MASK of an interface (e.g., `10.1.2.1/24`)
* IFACE is an interface id (e.g., `eth0`)

| Command | Meaning |
|----| ----|
| Interface settings|
| `ip -4 address`| Diplay IPv4 info of all the interfaces|
| `ip address add IP/MASK dev IFACE` | Add IP address to an interface|
| `ip address del IP/MASK dev IFACE` | Delete IP address from an interface|
| Routing table settings |
| `ip route list`| Show routing tables |
| `ip route add NETPREFIX dev IFACE` | Add route to reach a network prefix on direct delivery on the given interface|
| `ip route add NETPREFIX via IP`| Add route to reach a network prefix through the specified gateway|
| `ip route add default via IP` | Add the default  gateway|
| `ip route del NETPREFIX dev IFACE`| Remove route |
| `ip route del NETPREFIX via IP`| Remove route|
| `ip route del default` | Remove the default gateway|



   


