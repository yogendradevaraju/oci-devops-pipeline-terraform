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

   – **Important:** The newly created private repository will be used as the source code repository to trigger your pipeline. All custom image updates and changes should be committed and pushed to this private repository to ensure they are picked up by the pipeline.

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
```
oci session refresh --profile oci-devops-terraform
```

### 3. Create terraform.tfvars
  – Copy the `terraform.tfvars.example` file to a new file named `terraform.tfvars`.
  – Update it with your specific configuration values.
  – **Note:** The GitHub Personal Access Token (PAT) value should be provided in base64 encoded format.
    You can encode your PAT using the terminal on Linux or MacOS with the following command:
```
echo -n "{replace-your-PAT}" | base64
```

### 4. Create a dynamic group called `DevOpsDynamicGroup` with the following rules 
– **Note:**The dynamic group should be created in the root compartment

```
ALL {resource.type = 'devopsdeploypipeline', resource.compartment.id = '{your-compartment-id}'}

ALL {resource.type = 'devopsrepository', resource.compartment.id = '{your-compartment-id}'}

ALL {resource.type = 'devopsbuildpipeline',resource.compartment.id = '{your-compartment-id}'}

ALL {resource.type = 'devopsconnection',resource.compartment.id = '{your-compartment-id}'}
```

### 5. Add the IAM policy
  – **Note:**The policy should be added in the root compartment
```
Allow dynamic-group DevOpsDynamicGroup to manage all-resources in compartment {your-compartment-name}
```

### 6. Initialize Terraform
  – Run the following command to initialize the working directory containing Terraform configuration files:
```
terraform init
```

### 7. Run Terraform Plan
  – This command creates an execution plan, letting you preview the changes Terraform will make:
```
terraform plan
```

### 8. Apply the Terraform Configuration
  – This command will perform the actions proposed in the plan (and require your confirmation):
```
terraform apply
```

### 9. Enable logging
  – Navigate to the oci console and enable logging under the newly created devops project, follow steps:
```
OCI-console >> Developer Services >> DevOps >> Projects >> oci-custom-image-pipeline-terraform >> Logs >> Enable Log
```
  – Select the log group `custom-image-pipeline-container`.

  – Select the log retention based on your requirement.

### 10. Create Trigger
  After the Terraform setup, you need to manually configure a trigger in the OCI Console:

  – Navigate to your newly created Devops project in the OCI console, follow steps:
  ```
  OCI-console >> Developer Services >> DevOps >> Projects >> oci-custom-image-pipeline-terraform >> Triggers >> Create Trigger
  ```
  – Fill in the trigger details:

    – **Name:** Enter a name for the trigger.

    – **Source connection:** Select `GitHub`.

    – **Actions:** Click `Add action`.

    – **Build Pipeline:** Under `Select`, choose `custom-image-pipeline-terraform` (the pipeline created by Terraform).

    – **Event:** Check the box for `Push` (to trigger on `git push` events).

    – **Build run conditions:** Under `Source branch`, enter `master` (modify as needed for your workflow).

    – **Actions:** Click `Add action`.

  – **Create and Save the Trigger:**:

    - Click the **Create** button.

    - **Important:** When the “Trigger Secret” window appears, **immediately note down the trigger URL and secret, as they cannot be accessed again.**

### 11. Publish events from GitHub
  To connect your GitHub repository with the OCI DevOps trigger:
    - Configure a [GitHub Webhook](https://docs.github.com/en/webhooks-and-events/webhooks/creating-webhooks) in your private repository, using the **trigger URL** as the Payload URL and the **secret** you previously noted.

    **Summary of steps**

        - Go to your `oci-hpc-image-terraform` private GitHub repository → **Settings** → **Webhooks** → **Add webhook**.

        - Enter the **trigger URL from step 10** (from OCI DevOps) in the Payload URL field.

        - Set **Content type** to `application/json`.

        - Paste the **trigger secret from step 10** (from OCI DevOps) in the Secret field.

        - Select the event(s) to trigger the webhook (`push` is recommended).

        - Click **Add webhook** to save.

### 12. Push your custom image updates to trigger the pipeline
  Follow the steps defined in the [`oci-hpc-image-terraform/README.md`](https://github.com/yogendradevaraju/oci-hpc-images-terraform/blob/master/README.md) for details.

### 13. Follow the progress in OCI Console
  – Go to:
  ```
  OCI Console → Developer Services → DevOps → Projects → oci-custom-image-pipeline-terraform → Latest build history
  ```
  – Here you can follow the status, logs, and results of your triggered pipeline builds.
    


