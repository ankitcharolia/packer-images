# How to Create AWS AMI

NOTE: We use HCL2 (Hashicorp Configuration Language 2) syntax for creating AMI (Amazon Machine Image) in this example. It can be written in json template as well.

### Authenticate to AWS
```shell
# Before you can build the AMI, you need to provide your AWS credentials to Packer. These credentials have permissions to create, modify and delete EC2 instances. Refer to the

source exportAWSProfile.sh 
```

### # Initialize Packer configuration
```shell
# Starting from version 1.7, Packer supports a new packer init command allowing automatic installation of Packer plugins.
packer init .
```

### Format and validate your Packer template
```shell
# Format your template. Packer will print out the names of the files it modified
packer fmt .

# If Packer detects any invalid configuration, Packer will print out the file name, the error type and line number of the invalid configuration
packer validate .
```

### Build Packer image
```shell
packer build -var-file="ubuntu-stage.pkrvars.hcl" aws-ubuntu.pkr.hcl
```
---
**Visit the AWS AMI page to verify that Packer successfully built your AMI.**

**After running the above command, your AWS account now has an AMI associated with it. AMIs are stored in S3 by Amazon so you may be charged.**




### Useful Links
* [Build Amazon AMI with Packer](https://www.middlewareinventory.com/blog/build-packer-aws-image-example/)