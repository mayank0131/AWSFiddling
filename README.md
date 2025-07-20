# AWSFiddling

This repo has my test projects I work and test the interesting scenarios I have come across

## App Hosting on Port 80

This project has an application installed on EC2 instances. The said application can be accessed through the Application Load Balancer. 

The EC2 instances will be residing in the private subnet and can only be accessed via Bastion Host. Also, even though the instances are in private subnet, they will be speaking to internet through NAT gateways. 

As of now, I have kept the application hosted on port 80 of the instances. I plan to secure it later once I obtain a Domain and then will use AWS Certificate Manager terminating on ALB.

Technical Details are described in [README](ec2-app-hosting-80/README.md)

## DR Scenario

This project has an EC2 instance that has some application(apache) running on it. The application has some custom data that needs to be retained even if the server crashes. Also, we don't want to reconfigure DNS or connections in case the switchover happens. Further, we wanted it to be resistant to AZ failures as well.

Technical Details are described in [README](DR-scenario/README.md)