# OCI Custom-Image DevOps Pipeline with Terraform

This repo contains Terraform code to provision an Oracle Cloud Infrastructure (OCI) DevOps project, build pipeline, GitHub mirror repository and trigger.  
Once you’ve applied the Terraform, you’ll copy the trigger secret into GitHub as a webhook so pushes and PR merges automatically start your OCI build.

---

## Prerequisites

### 1. OCI CLI setup 
   – OCI cli setup with relevant oci config

### 2. Terraform setup
   – Install Terraform v1.1+ (https://learn.hashicorp.com/terraform/getting-started/install)
   ```
   oci session authenticate --> confirm region --> complete browser authentication 
   Enter the name of the profile you would like to create: 'oci-devops-terraform'
   ```

### 3. Pure ansible source-code repository setup
   – Clone the provided sample repository and push it into your Github account as a private repository.This ensures that your   workflow, code, and pipeline configuration remain under your control and are not publicly visible.
   ```
   git clone https://github.com/yogendradevaraju/oci-hpc-images-terraform.git
   ```
   – After pushing to your private GitHub repository, **copy the URL of your private repo and keep it handy**; you will need to provide this URL in later steps during the pipeline setup.

### 4. GitHub Personal Access Token (PAT)
   – Create a Personal Access Token (PAT) in GitHub with at least `repo` scope.  
   – **Store the generated PAT securely and keep it handy**; you will need to provide it as an input during the Terraform provisioning process, where it will be stored in an OCI Vault.
   – For instructions on creating a PAT, see [GitHub documentation](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens#creating-a-personal-access-token-classic).

## Terraform Implementation 

### 1. Clone the Terraform repository
```
git clone https://github.com/yogendradevaraju/oci-devops-pipeline-terraform.git
cd oci-hpc-images-terraform
```

### 2. Session authentication
  – Make sure that the profile oci-devops-terraform profile is setup and the session is active.

### 3. Create terraform.tfvars
  – Copy the `terraform.tfvars.example` file to a new file named `terraform.tfvars`.
  – Update it with your specific configuration values.

### 4. terraform init

### 5. terraform plam

### 6. terraform apply 

### 7. manual setup of logs, trigger and IAM policies

### check the console to verify that the planned oci devops pipeline is active or not

### use the github repo to push your changes, follow the readme in the github to push the commit, the commit should trigger the pipeline






