# AWSFiddling
Create EC2 instance behind an Application Load Balancer allowing SSH through Bastion Host. 

The EC2 instance resides in a private subnet, has NAT gateways associated with it and has apache tomcat installed on it. 

The configuration allows Load Balancer to be open to internet and Bastion Host allowing connection from the server that is running this terraform code.

## Thought Process

Since we need an EC2 instance behind an ALB, we will first need to lay the ground work
1. Create VPC
2. Create a Private Subnet
3. Create a Public Subnet
4. Create an Internet Gateway & a NAT Gateway to provide internet access to the servers
5. Create route tables to segregate traffic 
Internet -> IGW -> Public Subnet
Private Subnet Instancees -> NAT GW 
NAT GW will need an EIP attached to it
6. Security Groups to Allow connection from 
 Internet -> ALB
 IP running Terraform -> Bastion Host (By design since I'm running stuff on my VM, we can substitute with some variable IP as well)
 ALB -> App Server
 Bastion Host -> App Server
7. Create Application Load Balancer
Request -> ALB -> Listener -> Target Group (Logical Group of Targets)-> Target Group Attachments (Actual EC2 instances)
8. EC2 Instances
App Server -> Private Subnet
Bastion Host -> Public Subnet
Both these servers have a common SSH Key (we can use multiple keys as well, just need to replicate)


Application flow => User -> Load Balancer(Listener -> Target Group) -> Instance
Outbound flow => EC2 -> NAT GW + EIP -> IGW