This is are the Refined prompts i have used for creating the infra:   

Here's a more conversational, human-friendly version of those prompts:


## Creating Your Infrastructure Code
"Hey, could you help me write some Terraform code for setting up systems across both AWS and GCP? I want to make sure it follows best practices for security and can scale easily. It would be great if the code is organized into reusable modules and shows me important information about the resources it creates."

### For AWS, I need:
- A network with plenty of space (a /16 block) with some public and private areas, plus all the gateway stuff to make it work
- A Kubernetes cluster with a couple of worker nodes that can grow when needed
- A secure PostgreSQL database that's tucked away in a private area
- A storage bucket for keeping track of infrastructure changes, with versioning so we don't lose anything
- User roles that only have the permissions they absolutely need

### For GCP, I need similar stuff:
- A good-sized network with public and private sections
- A managed Kubernetes setup with a couple of nodes that can scale
- A secure PostgreSQL database with automatic backups
- A storage bucket for tracking infrastructure changes
- User permissions that follow the principle of least privilege

## Drawing It Out
"Could you sketch out what this multi-cloud setup would look like? I'd like to see how all the pieces connect - the networks, Kubernetes clusters, databases, storage, and security components. Maybe use different colors for AWS and GCP stuff, and show me how data flows between everything."

## Keeping It Secure
"What are the best ways to keep this multi-cloud setup secure? I'm especially interested in managing user permissions, encryption, firewall settings, and keeping different parts of the network separate. Also, how should I set up secure connections between AWS and GCP, and what monitoring tools should I use to keep an eye on everything?"

## Setting Up Automated Deployment
"I need a GitHub Actions workflow that can automatically deploy this multi-cloud setup. It should check the code for problems, look for security issues, deploy to both AWS and GCP, and then make sure everything is working properly."

## Making Deployment Easy
"Could you write me a script that makes deploying all this infrastructure easy? I want it to set up Terraform, log into both cloud providers, run security checks, apply all the changes, and keep good logs so I can troubleshoot if needed."

These should help you get your cloud infrastructure up and running across both AWS and GCP without drowning in technical jargon. Everything's covered - from writing the code to drawing diagrams, securing it all, and automating the deployment.