# AWSFiddling

This repo has my test projects where I implement and test the interesting scenarios I have come across

# Menu
1. [Web Hosting - EC2](#app-hosting-on-port-80) : A web application deployed on EC2 instances(in private subnet) using Apache and hosting it on a custom domain.
2. [DR Scenario](#dr-scenario) : A web application deployed on EC2 instances using Apache and making it resistant to Server and AZ failures. 
3. [NodeJS App Hosting - EC2](#nodejs-app-hosting--nginx--letsencrypt) : A NodeJS application hosted using nginx, secured by Let's Encrypt Certificate.
4. [GitHub Actions Setup](#github-actions-setup): Actions to Support the deployment 

## App Hosting on Port 80

This project has an application installed on EC2 instances. The said application can be accessed through the Application Load Balancer. The EC2 instances will be residing in the private subnet and can only be accessed via Bastion Host. Also, even though the instances are in private subnet, they will be speaking to internet through NAT gateways. The application will work with the subdomain [test.infrawithmayank.com](test.infrawithmayank.com). Which then is routed through route 53 and points to an Application Load Balancer. ALB points to port 80 on EC2 instances to which the application listens

Technical Details are described in [README](ec2-app-hosting-80/README.md)

## DR Scenario

This project has an EC2 instance that has some application(apache) running on it. The application has some custom data that needs to be retained even if the server crashes. Also, we don't want to reconfigure DNS or connections in case the switchover happens. Further, we wanted it to be resistant to AZ failures as well.

Technical Details are described in [README](DR-scenario/README.md)

## NodeJS App Hosting + NGINX + LetsEncrypt

This project deploys a sample NodeJS application to an ubuntu EC2 instance. The application will be hosted on a custom sub-domain [test.infrawithmayank.com](test.infrawithmayank.com) and secured via Let's Encrypt certificate. Nginx is set up as a reverse proxy applying the certificate and PM2 is setup to automatically start the application on server reboot. 

Technical Details are described in [README](nodejs-letsencrypt/README.md)

## GitHub Actions Setup

Since the entire deployment ecosystem runs via terraform, hence the entire repository follows same pattern, a separate workflow for pull request and another one for a push. I have setup Open ID Connections(OIDC) between the workflows and my AWS account(terraform configuration is in my private repo and can be shared if someone asks nicely!). Pull request workflows only have Read permissions and Push workflows have both read/write accesses which are handled by their respective IAM roles.

Under the hood both workflows call same boilerplate workflow which differentiates between pull request and push events and decides to do a plan or plan/apply steps accordingly.
