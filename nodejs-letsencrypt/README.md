## Technical Description

In this setup, the configuration setup is done in 3 parts

1. Setting up the infrastructure via terraform 
2. Manually updating DNS (since I'm using a namecheap domain and they neeed at least $50 in wallet and 20 domains to give API access)
3. Running terraform script to install certbot and perform certificate installation

Now let's dig into individual components

### InfraProvisioning

This part is responsible for basic setup of application infrastructure. This involves the following steps:

1. Create VPC and Subnet(Public since I'm planning to use Elastic IP, in case an ALB is used, we can use Private Subnets)

2. Create a Security Group which allows
  - Inbound Connection from current ip to port 22 to enable SSH
  - Inbound Connection from internet to port 80 (I need this to validate if the initial setup is working)
  - Inbound Connection from internet to port 443
  - Outbound Connection to Internet

3. Internet Gateway and Route Table linked to Subnet

4. Create Elastic IP 

5. Create EC2 instance along with Private Key and Key Pairs. A User data script would be responsible for installing nginx, pm2 and setting up the nginx as a reverse proxy

6. Associate Elastic IP with the EC2 instance

7. This setup outputs Elastic IP and the private key. These will be used in part 3 of the setup

### DNS Update

Since I want my application to point to **test.infrawithmayank.com** and I have an Elastic IP, DNS needs to be updated with an **A record** pointing to **Elastic IP** for **test** alias. 

### LE Setup

Once the DNS change is done and http connection to the test subdomain points to the application landing page, now Let's Encrypt SSL certificate setup can be done. 

For this I imported the state of InfraProvisioning step so I can get both the public ip and Private Key to enable ssh using null resource. Once it is done, it's just a matter of replacing Server name and installing Certbot which in turn will install the certificate. 