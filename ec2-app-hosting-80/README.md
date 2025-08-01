## Technical Description

Since we need an EC2 instances behind an ALB, we will first need to lay the ground work

### State Storage
Here we will store the state file
1. Create S3 bucket
2. Block Public Access to s3
3. Enable encryption
4.  Allow current User access to read the bucket

### Networking
1. Create **VPC**
2. Create **Private Subnets** in 2 AZs to Host application instances
3. Create **Public Subnets** in 2 AZs to Host Bastion instance, ALB and IGW
4. Create an **Internet Gateway**
5. Create **Route Table** for routing traffic from Public Subnets to Internet Gateway
6. Create two **Elastic IPs**
7. Create **NAT Gateways** (one for each AZ) and attach them to each elastic IP
8. Create **Route Table** to connect Private subnets to the NAT Gateway of respective AZs. 
9. **Load Balancer Security Group** to Allow connection from internet to load balancer (port 80)
10. **Bastion Host Security Group** to Allow connection from the comma separated IP list given in GitHub Variables.
11. **Application Server Security Group** to allow connection from Load Balancer SG on port 80 and Bastion Host SG on port 22
12. Create a **Route53 Hosted Zone** along with DNS records pointing to Load Balancer and having a validation record
13. Create a **Certificate** via ACM and a Certification Validation Record. 
12. Create **Application Load Balancer** with Listener set to port 443. Listener then forwards the requests to Target Group with EC2 instances attached as targets (on port 80)

### Instances
1. **Random Shuffler** to randomly select the subnet for booting up instance(for bastion)
2. **tls private key** to generate a private key dynamically
3. **aws key pair** to set the public key of the above private key in the instances
4. **ec2 instances** one bastion host and two application servers

**NOTE:** Since I am using a custom domain with namecheap,  there has to be a manual step of updating Route53 NameServers for the *test* subdomain.