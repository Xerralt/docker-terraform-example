# docker-terraform-example
This project assumes you currently have terraform docker, and task installed. All of these can be found in the version of tools section at the bottom of the README. It is also assumed that you understand the basic concepts of containers and how containerization works with docker. Task has been installed as an alternative to makefiles. Albeit we may not use task I prefer having it out of habit.

In this example we will walk through the basics of spinning up a terraform module using our local docker instances. This readme will act as a baseline guide to walk you through the ins and outs of terraform as I understand it, along with some fun facts and banter along the way. Without further ado, let's get into it!

- [docker-terraform-example](#docker-terraform-example)
- [What is Terraform?](#what-is-terraform)
- [Getting started with the Code](#getting-started-with-the-code)
- [Breaking down a project with Terraform](#breaking-down-a-project-with-terraform)
  - [docker-image](#docker-image)
  - [docker-container](#docker-container)
- [Versions of tools](#versions-of-tools)

# What is Terraform?
Terraform itself is an Infrastructure as Code (IaC) tool that is often used in order to follow a DevOps set of practices. We leverage tools such as these in order to have a single source of truth for our infrastrucuture as we build it. Whatever is in the code is what our infrastructure will consist of, nothing more and nothing less. Any manual modifications should become IaC, otherwise we lose parity with our single source of truth, so if you're using terraform be sure to make note of manual changes and convert them to code as you go. Terraform allows us an easy way to do this though, as it tracks our changes to the code and lets us build out our resources as the need arises. In this we often have the ability to modify resources in place, and if not then terraform will let us know of the destructive nature so that we can account for the downtime that could occur from applying our resources. 

Terraform is also a fairly smart IaC tool in that it utilizes several open source providers. These providers allow us to build our infrastructure in a more piece by piece manner. These pieces could be as small as a single tool, such as Jenkins or Gitlab. These pieces could also be as large as an entire Kubernetes cluster inside of AWS, or the foundations for a website hosted within Azure. Really we can pivot quite easily and utilize these various providers in order to create and capitalize on the power of Terraform. 

When we compile our terraform scripts to apply, we also have a benefit from our providers. Every resource we generate have two types of variables within them: Required and Optional. These two speak for themselves, but also come with a few special properties. Those which are required are often utilized to fill out the optional variables with defaults, and tend to have some form of primary functionality that should be designed within the architecture of your project. Examples of this include: Images for Containers, Resource IDs as reference, IP addresses, etc. 

The Optional variables are often used for our own benefit and for fine tuning your resources. Optional variables will default to certain values, often based on the required variables that we set for the baseline of the resources we need. Examples of optional resources are: Tags, Names, Resource limits/requests, etc. 

One last note on what Terraform is. Terraform is automatic provisioning, but if you were to delete a resource manually, or modify/add to a resource, you should most certainly edit the code to reflect that. If you don't you could wind up with a state that is invalid, or terraform failing to delete resources properly due to dependencies between IaC and manual changes.

# Getting started with the Code
The first thing you need in order to start work with terraform will be your main<span></span>.tf file. Terraform will always look for a main<span></span>.tf first and foremost, and that is where we must put our providers and any specifics about the providers we have chosen. You'll note that in our code we have two primary blocks: Terraform and Provider. The terraform block is where we denote configurations to terraform as it builds out our infrastructure. In our case we have specified required providers and pinned versions of these providers to be used. This is a solid method to pick a provider and avoid drift or breaking changes by constantly having record of which version to search for documentation for. Many projects I have used haven't had this, and without that level of control debugging future breaks due to changes became a bit more difficult. 

With pinning a specific provider we also must instantiate that provider. We have the provider block for that. In many cases these blocks will reach out to a cloud service of some sort, or will have a few added settings within them rather than the blank instance we see with docker. Since this project is built locally the docker provider doesn't require any set variables within our provider, but be sure to check the initial documentation in order to set those properly within your code. 

After this you can easily provision the rest of your resources directly beneathe the provider block. This way your main<span></span>.tf is the only file you would need, and in many cases that is even preferred. In the case of this example I have taken the opportunity to show another aspect of Terraform which we will discuss in a moment.

For now you can run the basic terraform init command. This will scan through your main<span></span>.tf and create a .terraform file which stores all of the libraries that the provider needs in order to create your projects infrastructure. You can explore this after running the following command within the projects directory:
```
terraform init
```

# Breaking down a project with Terraform
Often times you're going to want to compartmentalize the code that you are writing based on it's functionality. In the case of this example I have divided every set of resources into basic .tf files. You'll note that we have two: docker-container<span></span>.tf and docker-image<span></span>.tf. These both contribute to building out the entire infrastrucuture, and are even reliant upon one another to run. Let's take a look at what each do.

## docker-image
This terraform script is incredibly basic, but also the foundation for our docker container. This file will be detected by terraform and will be built in the apropriate order so that our container has an image to refer to. Notice how incredibly simple this file is. If you were to look into the docker provider's documentation you would notice that there are multiple optional fields that we could provide here. We only provide the specific name, in this case the name of the image being "nginx:latest". This means that we will be pulling down the latest nginx version from artifact hub, which will then be utilized to instantiate our containers. We generate this resource primarily so that we can grab the image ID for our container to reference. The ID value will be filled in by terraform once it creates the docker-image resource based upon the name we've given it. You can view this if you run the terraform plan command. In this you will see the docker resources that will be generated by an apply. If you look through the plan you'll take note that there is an image item with values "known after apply". These are the optional values that we will reference when looking at the container file. Go ahead and run the following command and become familiar with the output:
```
terraform plan 
```

## docker-container
The docker container file is the aspect that we are going to see instantiate. The beauty of IaC is that we can provision aspects that we will touch, and things we want automated. The image is part that we don't really see when developing an application ontop of our infrastructure, but is a critical background piece. The Container is part that we will interact with directly through our localhost in this example. In production environments we may even shell into our containers, run docker exec commands, or perhaps access it through a web interface given the projects architecture supports such access. Let's go ahead and deploy our nginx container by running the following:
```
terraform apply
```

In our example code we draw from another resource. You may notice the reference to docker_image.nginx.latest. Since this variable will be filled out, our docker_container resource will draw from it at the time that it is generated by the terraform apply. This becomes much more prominent and necessary in the case of cloud provisioning, and we will look into that in other example projects I have planned. 

Notice as well that we have also provided a few extra options for the sake of our container. We provide it with a name, and this will allow us to see it by running the `docker ps` command. We also give memory limits so that we can ensure the container has enough processing power to run, but doesn't consume too much to bother operations of other containers or our local machine. In this we also provide the must run tag, which gives us the assurance that our container will be up and running by the end of the script. This is valuable in cases where one container is a dependency for another.

With this we also open various ports for us to access the container on our localhost. Since we are utilizing nginx, we have the ability to access the hosting properties of the container so long as the ports are properly exposed. You'll notice that for the container we direct the internal port to 80, and the external to 8000. This gives us a tunnel straight into the nginx ingress for our container, and in such we get a basic web page! 

We can now go ahead and clean up our containers by running a terraform destroy. This will read through the statefile that was recently generated, and in doing so it will recognize the generated infrastructure which you will want destroyed. For our sake this should just be a container and image, but many times you'll have considerably more resources being destroyed, so always check through what you're about to blow away. Go ahead and run the following and you'll be good to move on, or if you'd like make edits and contribute to the tutorial!


# Versions of tools
| Tool            | Version | Date of Last Update | Link to tool |
| --------------- | ------- | ------------------- |--------------|
| Terraform       | v1.0.9  | 10/19/2021          | [terraform](https://www.terraform.io/downloads.html) |
| Docker          | v4.1.1  | 10/19/2021          | [docker](https://www.docker.com/products/docker-desktop)|
| Task            | v3.9.0  | 10/23/2019          | [task](https://taskfile.dev/#/installation) |
