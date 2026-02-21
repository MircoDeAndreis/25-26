# LAB-K1. Docker hands-on

Aim of this lab activity is to become familiar with the basic commands of `docker`, required in the following labs.

NOTE WELL: If you work on the PCs in Dijkstra's room, it is advisable to always use the same PC for the whole course, as your files will be stored on that machine (only).

ON DIJKSTRA PCs:

To access the Ubuntu virtual machine (VM) in the Dykstra lab using a PC:

* At the GUI login screen, enter username and password as follows:

Username: complreti
Password: reti2026PWD

+ Once logged in, the Ubuntu VM will automatically start and display in full-screen console mode.

+ Run Docker.

**Shutdown Steps:**

* Shut down properly by running the command poweroff in the terminal (or via the GUI shutdown menu if available).

+ Do not use the host PC's power button, Ctrl+Alt+Del, or close the window—this can corrupt the VM.

+ Wait for the VM to power off fully, then log out of the host PC GUI.

Please report any login or VM startup issues to the lab supervisor as soon as possible.


ON YOUR DEVICE:
0. Download and install Docker (if you are on your own device).

1. Open a terminal and type `docker run hello-world` to check that `docker` works properly

2. Open the tutorial on https://docker-curriculum.com/ with the Chrome browser 
> [!TIP]
> Follow carefully the steps below and do not skip any detail, since they will become very useful in the following labs.
3. Read the section **INTRODUCTION** and answer to the following questions:
   - Q1: What is a container and how is it different from a Virtual Machine (VM)? In which terms containers are "better" than VMs?
      - A container is a private area of our computer where we can run application or service in a isolated enviroment, the difference between a vm and a container is that a containers doesn't add a guest os but it only add the library that are need to run the application for this reason is more efficent than a normal vm. 
   - Q2: What is the meaning of _isolation_ for  VMs and containers?
      - The VMs and container are isolated from all the other process and they have their own part of memory, they don't interact directly with the operating system, this thing is important to make run in every operating system the application.

> [!WARNING]
> Skip the section **GETTING STARTED**

4. Follow step-by-step the **HELLO WORLD** section and answer to the following questions:
   - Q3: What is the meaning of `docker pull` command?
      - The docker pull command is needed to download a image from a registry. 
   - Q4: What is the meaning of `docker images` command and how is related to the `docker pull`?
      - The command docker images is a command that permits you to know all the image that are download in your computer, it related with docker pull because docker pull download the image so for this reason they are related, one command download the image the other one tell you which kind of image are available on your computer.
   - Q5: What is the meaning of `docker run` command and how is it related to `docker images`? 
      - Docker run is a command that is usefull to run the docker application, it is related with docker images because docker run runs image that are saved in our computer for this reason, it's important to know which kind of image are available on our machine, if the image are not available on the computer the command docker run automatically run the command docker pull.
   - Q6: What is the difference between an _image_ and a _container_?
      - An image is an application or a operating system that runs inside a container, so the containers is the box where the image run.
   - Q7: What is the meaning of `docker ps` command and how is it related to `docker run`?
      - Docker ps is usefull to see the docker application that runs on our computer, it is related with docker run because every time that we run a docker application, we can saw it with the command docker ps.
   - Q8: What is the difference between `docker ps` and `docker ps -a`?
      - The difference between this two command is that docker ps shows only the docker application that are still running on the computer instead docker ps -a shows every  docker application even the application that are finished.
   - Q9: What is the meaning of `docker rm` command and how is it related to `docker ps`?   
      - Docker rm remove the containers from the ram, freeing the memory of the computer that was reserved to the containers, it is related with docker ps because it show all the docker application that are running on the computer with relative id, with the id is possible to cancel the containers.
   - Q10: What is the meaning of `docker container prune`? 
      - It's a command that cancels every docker application that are stopped in our computer.
   - Q11: What is the meaning of `docker rmi` and how is it related to `docker container prune`?
      - Docker rmi is a command that cancel a docker image from the computer, they are related because docker container prune, cancel all the containers that are stopped instead docker rmi cancel directly the image.







