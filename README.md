#  Terraform Azure Infrastructure Deployment

##  Project Overview

This project demonstrates the use of **Infrastructure as Code (IaC)** with **Terraform** to deploy a secure, multi-tier Azure environment automatically.

I successfully provisioned:

* Resource Group
* Virtual Network & Subnets
* Network Security Groups (NSGs)
* Load Balancer with backend web servers
* Key Vault for secrets management
* Azure SQL Server (PaaS)
* Parameterized deployment through variables

---

##  Project Structure

| File           | Purpose                                      |
| -------------- | -------------------------------------------- |
| `main.tf`      | Core infrastructure definition               |
| `variables.tf` | Input variables and defaults                 |
| `providers.tf` | Provider and Terraform version configuration |
| `outputs.tf`   | Key deployment outputs                       |

---
(screenshot)

##  Prerequisites

Before deploying, ensure the following are in place:

1. **Azure Subscription** – Contributor or Owner access
2. **Terraform Installed (≥ 1.12.2)**

   ```bash
   terraform version
   ```
   (screenshot)
3. **Azure CLI Installed and Logged In**

   ```bash
   az login
   az account set --subscription "<your_subscription_id>"
   ```
   (screenshot)


---

##  Configuration Files Breakdown

###  1. `providers.tf`

```hcl
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0.0"
    }
  }
  required_version = ">= 1.3.0"
}

provider "azurerm" {
  features {}
}
```

 (Screenshot)

---

###  2. `variables.tf`

Declares environment parameters for reusability and environment consistency.

```hcl
variable "location" { default = "eastus" }
variable "prefix"   { default = "assess" }

variable "admin_username" { default = "azureadmin" }
variable "admin_password" { sensitive = true }

variable "web_vm_count" { default = 2 }
variable "web_vm_size"  { default = "Standard_D2s_v3" }
variable "db_vm_size"   { default = "Standard_D4s_v3" }

variable "tenant_id" { description = "Azure tenant ID for Key Vault access" }
variable "sql_admin_username" { description = "Admin username for SQL Server" }
variable "sql_admin_password" { description = "Admin password for SQL Server", sensitive = true }
```

 (Screenshot)

---

###  3. `main.tf`

Defines the infrastructure resources:

* **Resource Group**
(image)
* **VNet + Subnets**
(image)
* **Network Security Groups**
(image9)
* **Load Balancer + Backend Web VMs**
(image)
(image)
* **Key Vault**
(image)
* **Azure SQL Server (PaaS)**
(image)

---

###  4. `outputs.tf`

Displays essential resource details after deployment.

```hcl
output "resource_group" {
  description = "The name of the resource group created"
  value       = azurerm_resource_group.rg.name
}

output "load_balancer_public_ip" {
  description = "Public IP of the load balancer"
  value       = azurerm_public_ip.lb_pip.ip_address
}

output "sql_fqdn" {
  description = "SQL Server fully qualified domain name"
  value       = azurerm_mssql_server.sqlserver.fully_qualified_domain_name
}

output "key_vault_id" {
  description = "Azure Key Vault resource ID"
  value       = azurerm_key_vault.kv.id
}
```

(Screenshot)

---

##  Step-by-Step Execution

### Step 1: Initialize Terraform

```bash
terraform init
```

(Screenshot)

---

### Step 2: Format and Validate Configuration

```bash
terraform fmt
terraform validate
```

(Screenshot)

---

### Step 3: Plan Deployment

```bash
terraform plan -out=tfplan
```

(Screnshot)
(Screnshot)
(Screnshot)
(screen)

---

### Step 4: Apply Deployment

```bash
terraform apply "tfplan"
```
(Screenshot)
(screen)

---

### Step 5: Verify Outputs

```bash
terraform output
```

(Screenshot)

```bash
terraform state list

```
(screen)
---

### Step 6: Validate in Azure Portal

Check the following under your **Resource Group**:

*  Virtual Network and Subnets
* Network Security Groups
*  Load Balancer frontend/backend configuration
* Deployed Linux Web VMs
*  Azure SQL Server & Database
* Key Vault

  Azure resource group tab

---

### Step 7: Clean Up Resources

When done, destroy all resources to avoid billing charges.

```bash
terraform destroy
```

(Screenshot)
(screenshot)

---

##  Challenges and Resolutions

| # | Challenge Encountered                                                                  | Root Cause                                                | Solution Implemented                                                  |
| - | -------------------------------------------------------------------------------------- | --------------------------------------------------------- | --------------------------------------------------------------------- |
| 1 | **Invalid variable syntax** (`Invalid single-argument block definition`)               | Used `{}` inline for multi-attribute variables            | Reformatted variables to multi-line blocks                            |
| 2 | **Unsupported argument: `resource_group_name` in backend pool**                        | Removed in newer AzureRM provider versions                | Removed from `azurerm_lb_backend_address_pool` and `azurerm_lb_probe` |
| 3 | **Unsupported argument: `load_balancer_backend_address_pool_ids`**                     | Deprecated field in newer provider versions               | Replaced with explicit backend pool association                       |
| 4 | **Undeclared variable `tenant_id`**                                                    | Missing declaration in variables.tf                       | Added `variable "tenant_id"` block                                    |
| 5 | **Duplicate provider configuration**                                                   | Defined in both `main.tf` and `providers.tf`              | Removed duplicate from main.tf                                        |
| 6 | **Unsupported block `backend_address` in Application Gateway**                         | AzureRM v3 doesn’t allow backend addresses inline         | Removed dynamic block and replaced with static configuration          |
| 7 | **Invalid resource type** (`azurerm_application_gateway_backend_address_pool_address`) | Resource only supported in AzureRM v4+                    | Removed from main.tf for compatibility                                |
| 8 | **Final validation failure**                                                           | Provider/resource mismatch                                | Updated provider version and validated configuration                  |
| | **Final Success**                                                                      | Terraform validated successfully and ready for deployment | Confirmed with `terraform validate` and portal inspection             |

 Challenges and Errors Faced (continuation)



1. **Invalid Resource Configuration Errors**

   * **Issue:** Terraform initially failed validation due to deprecated or unsupported arguments (for example, `resource_group_name` in backend pool and probe resources).
   * **Resolution:** Updated the configuration to align with the latest AzureRM provider schema, removing unsupported arguments and using the correct resource relationships.

2. **Application Gateway Subnet Conflict**

   * **Issue:** The Application Gateway failed to deploy with the error
     *“ApplicationGatewaySubnetCannotHaveOtherResources”*.
   * **Root Cause:** The gateway was originally deployed in the same subnet as the web servers, but Azure requires the Application Gateway to reside in a **dedicated subnet**.
   * **Resolution:** Created a new subnet (`assess-agw-subnet`) exclusively for the Application Gateway and updated the gateway configuration to use it.

3. **SQL Server Provisioning and Region Restriction**

   * **Issue:** SQL Server creation failed with
     *“Provisioning is restricted in this region”* and later
     *“A resource with the same name cannot be created in location 'eastus2'”*.
   * **Root Cause:** The SQL Server was being created in a region that restricts new resources or conflicted with an existing resource name.
   * **Resolution:** Overrode the SQL Server’s location variable to a valid Azure region (`eastus2`) and ensured a unique resource name.

4. **SQL Server Password Complexity Error**

   * **Issue:** Azure SQL creation failed with
     *“PasswordNotComplex”* due to insufficient password strength.
   * **Resolution:** Replaced the admin password with a compliant one that met Azure’s complexity rules (example: `T3rraF0rm!2025_AzureSQL`).

5. **Missing Tenant and Subscription Configuration**

   * **Issue:** Terraform plan failed with
     *“subscription ID could not be determined and was not specified”*.
   * **Resolution:** Added the correct Azure subscription context using the command:

     ```bash
     az login
     az account set --subscription "<subscription-id>"
     ```

     This ensured the provider was properly authenticated and linked to the correct subscription.

---

 **Outcome:**
All issues were resolved successfully, leading to a fully validated Terraform configuration that deploys a complete Azure environment — including a resource group, network infrastructure, web tier, SQL server, and a properly configured Application Gateway.


 snippets of actual terminal errors 
 (image)
  (image)
   (image)
    (image)
  (image)  

---

##  Final Output Verification

Once `terraform apply` completes, the final outputs confirm a successful deployment.

Example output:

```
Apply complete! Resources: 25 added, 0 changed, 0 destroyed.

Outputs:

resource_group = "assess-rg"
load_balancer_public_ip = "20.210.88.113"
sql_fqdn = "assess-sqlserver.database.windows.net"
key_vault_id = "/subscriptions/.../resourceGroups/assess-rg/providers/Microsoft.KeyVault/vaults/assess-kv"
```

---

##  Conclusion

This project successfully showcases:

* Full lifecycle management with Terraform,
* Secure Azure architecture provisioning,
* Infrastructure modularity and scalability,
* Strong debugging, documentation, and reporting discipline.

The **successful creation of the Resource Group and associated components** confirms full deployment completion.


---

