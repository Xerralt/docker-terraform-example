# docker-terraform-example
Disclaimer: I have not tested this example on windows, it was developed utilizing a mac.
In this example we will walk through the basics of spinning up a terraform module using our local docker instances. This readme will act as a baseline guide to walk you through the ins and outs of terraform as I understand it, along with some fun facts and banter along the way. Without further ado, let's get into it!

- [docker-terraform-example](#docker-terraform-example)
- [What is Terraform?](#what-is-terraform)
- [Versions of tools](#versions-of-tools)

# What is Terraform?
Terraform itself is an Infrastructure as Code (IaC) tool that is often used in order to follow a DevOps set of practices. We leverage tools such as these in order to have a single source of truth for our infrastrucutre as we build it. Whatever is in the code is what our infrastructure will consist of, nothing more and nothing less. Any manual modifications should become IaC, otherwise we lose parity with our single source of truth, so if you're using terraform be sure to make note of manual changes and convert them to code as you go.



# Versions of tools
| Tool            | Version | Date of Last Update |
| --------------- | ------- | ------------------- |
| Terraform       | v1.0.9  | 10/19/2021          |
| Docker Provider | v2.15.0 | 10/19/2021          |