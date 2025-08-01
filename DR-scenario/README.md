## Technical Description

Since first part of the problem involved handling EC2 failures, I divided the setup into two parts 

1. [BaseSetup](#basesetup)

2. [EC2Attachment](#ec2attachment)

Further, since I wanted to control the AZ failover setup as well, I used a variable  **az_failure** which can be set to true in case of failure.

### BaseSetup

This section involves creation of all the base resources including

1. VPC and Subnet: Where subnet's AZ is decided on the basis of the variable *az_failure*.

2. Security Group: To allow application access (Port80) from internet and SSH access (Port22) from comma separated IP list provided in GitHub Variables. 

3. RouteTable: To associate with the Subnet and provide it internet access.

4. Network Interface (meant to be primary for the instance) in the above Subnet.

5. Elastic IP to be connected to the Network Interface.

6. EBS Volume: Which has two flows described below. Also a Data lifecycle manager rule to create a snapshot of the EBS volume  
   - 6.1. In case variable **create_volume_from_snapshot** is **false**, it will create a blank EBS volume. In first run, we'd need this scenario since there won't be a snapshot present. 
   - 6.2. In case variable **create_volume_from_snapshot** is **true**, it will fetch the latest snapshot and create volume from it.

**Note**: I wanted to make it dynamic using an external resource, but apparently it violates terraform's basic [conditional tenet](https://developer.hashicorp.com/terraform/language/modules/develop/composition#conditional-creation-of-objects)

7. IAM role for enabling the DLM rule. 

### EC2Attachment

This section would be responsible to bind aws instance to the resources created above. This includes

1. Fetching data elements for 
    - ami
    - subnet
    - security group
    - volume
    - network interface
    - elastic IP

2. Creating a TLS key along with an aws-key pair to enable login to EC2 instance(It hasn't been moved into base since I needed the key for my null resource and data doesn't pull the actual pem value).

3. A Security Group Rule that will enable SSH connection from current ip (AgentIP) to EC2 instance and attach it to existing Security Group.

4. Creating an EC2 instance utilizing the above data elements and key pair. ENI is attached as primary to the instance so as to get it unrestricted access to Elastic IP/internet. Also, we will install apache on it

5. Attaching a volume to the instance.

6. A Null resource that will mount the EBS volume and make it persistent across reboots along with placing the application homepage. 

7. A Null resource that will remove the security group rule added in Step3 once the null EBS volume setup is done.