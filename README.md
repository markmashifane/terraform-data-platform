# Enterprise Azure Data Lakehouse Architecture (IaC & DevOps)

![Terraform](https://img.shields.io/badge/IaC-Terraform_v1.5+-623CE4?logo=terraform&logoColor=white)
![Bicep](https://img.shields.io/badge/IaC-Azure_Bicep-0089D6?logo=microsoftazure&logoColor=white)
![Azure](https://img.shields.io/badge/Cloud-Microsoft_Azure-0089D6?logo=microsoftazure&logoColor=white)
![CI/CD](https://img.shields.io/badge/CI%2FCD-GitHub_Actions-2088FF?logo=githubactions&logoColor=white)
![Security](https://img.shields.io/badge/Zero_Trust-Private_Link_%26_RBAC-005858)
![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)

An enterprise-grade, zero-trust Azure Data Lakehouse foundation provisioned using modular **Terraform** and **Bicep** Infrastructure as Code (IaC). Built with automated CI/CD static analysis via **GitHub Actions**, private network isolation (Hub-and-Spoke), medallion storage layers, and containerized ETL execution components.

---

## 📌 Project Overview

This project implements a secure, scalable enterprise data platform architecture on Microsoft Azure. The entire infrastructure is defined as code using Terraform modules and Bicep scripts, strictly adhering to Azure Landing Zone patterns, Zero Trust security principles, and DevOps best practices.

### Core Objectives
* **Infrastructure as Code (IaC):** Modular, reusable Terraform and Bicep components enabling declarative provisioning across environments.
* **Network Isolation:** Air-gapped network perimeter enforcing end-to-end traffic routing via Private Endpoints and Private DNS.
* **Medallion Data Architecture:** Layered data processing model supporting structured analytics workflows across Bronze, Silver, and Gold tiers.
* **Automated Governance & Quality:** Continuous Integration pipeline enforcing automated linting, security scanning, and unit testing prior to execution.

---

## 🏗️ Architecture & Network Topology

\\\	ext
                     +-------------------------------------------------+
                     |                 Hub VNet                        |
                     |  +-------------------------------------------+  |
                     |  |  snet-management / Bastion / Gateway      |  |
                     |  +-------------------------------------------+  |
                     +------------------------+------------------------+
                                              |
                                     (VNet Peering)
                                              |
                     +------------------------v------------------------+
                     |                Spoke VNet                       |
                     |                                                 |
  +------------------+------------------+   +--------------------------+------------------+
  | snet-aks (Container Runtime)        |   | snet-data (Private Endpoints)               |
  |  - Azure Kubernetes Service (AKS)   |   |  - ADLS Gen2 (Bronze / Silver / Gold)        |
  |  - Managed Identity Integration     |   |  - Azure Key Vault (Secrets & Keys)          |
  +-------------------------------------+   +---------------------------------------------+
\\\

---

## 🔑 Key Features & Security Controls

* **Hub-and-Spoke Isolation:** Segregates runtime compute resources (\snet-aks\) from private data platform services (\snet-data\) using strict Network Security Group (NSG) rules and custom Route Tables.
* **Zero Trust & Private Connectivity:** Public network access is disabled on ADLS Gen2 and Key Vault. Communication is enforced exclusively over **Azure Private Endpoints** backed by **Private DNS Zones**.
* **Medallion Data Storage Architecture:** Provisioned Azure Data Lake Storage Gen2 (ADLS Gen2) account structured for raw (Bronze), cleansed (Silver), and curated business-ready (Gold) data layers.
* **Identity & Key Management:** Access configured via Azure RBAC utilizing System-Assigned and User-Assigned Managed Identities. Sensitive credentials and connection strings are managed dynamically via Azure Key Vault.
* **Automated CI/CD Quality Gates:** GitHub Actions workflow executes automated \	erraform fmt\ checks, \	erraform validate\, static security scanning via CodeQL/Checkov, and unit tests using \pytest\.

---

## 🛠️ Technology Stack

| Category | Technologies |
| :--- | :--- |
| **Cloud Provider** | Microsoft Azure (ADLS Gen2, Key Vault, AKS, VNet, Private Link) |
| **Infrastructure as Code** | Terraform (v1.5+), Azure Bicep |
| **CI/CD & Automation** | GitHub Actions, Azure CLI, PowerShell |
| **Data Processing & Code** | Python 3.10+, Pytest, Medallion Architecture Pipelines |
| **Security & Governance** | Azure RBAC, Managed Identities, Private DNS, NSGs |

---

## 📂 Repository Structure

\\\	ext
.
├── .github/
│   └── workflows/
│       └── terraform-ci.yml      # GitHub Actions CI pipeline for IaC validation
├── docs/
│   └── architecture-diagram.png  # High-level architecture design diagram
├── infra/
│   ├── environments/
│   │   └── dev/                  # Development environment deployment root
│   │       ├── main.tf           # Environment composition & module calls
│   │       ├── outputs.tf        # Environment resource outputs
│   │       ├── providers.tf      # AzureRM provider & backend configuration
│   │       └── variables.tf      # Variable definitions & defaults
│   └── modules/
│       ├── networking/           # VNet, Subnets, Route Tables & NSG rules
│       ├── private_endpoints/    # Private DNS Zones, A-Records & Endpoints
│       ├── security/             # Key Vault, Access Policies & RBAC Roles
│       └── storage/              # ADLS Gen2, Containers & Filesystem layers
├── scripts/
│   └── process_medallion.py      # Medallion layer processing execution script
├── src/
│   └── etl_pipeline.py           # Core ETL ingestion & transformation pipeline
├── tests/
│   ├── conftest.py               # Pytest fixtures and mock objects
│   └── test_etl_pipeline.py      # Automated unit tests for data transformations
├── .gitignore
├── LICENSE                       # MIT License
└── pyproject.toml                # Python dependency & tooling configuration
\\\

---

## 🚀 Getting Started & Local Validation

### Prerequisites
* [Terraform v1.5+](https://www.terraform.io/downloads)
* [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
* [Python 3.10+](https://www.python.org/)

### 1. Clone the Repository
\\\powershell
git clone https://github.com/markmashifane/terraform-data-platform.git
cd terraform-data-platform
\\\

### 2. Validate Terraform Infrastructure
Navigate to the development environment and validate the IaC configuration:

\\\powershell
# Navigate to dev environment
cd infra/environments/dev

# Initialize providers and local modules
terraform init

# Check formatting and syntax validation
terraform validate

# Dry-run execution plan
terraform plan
\\\

### 3. Run Pipeline Unit Tests
Verify data processing logic and transformation scripts locally using \pytest\:

\\\powershell
# Install project dependencies
pip install -e .

# Execute test suite
pytest tests/
\\\

---

## 👤 Author

**Mark Mashifane**  
*Cloud & DevOps Engineer*  
* **GitHub:** [@markmashifane](https://github.com/markmashifane)  
* **LinkedIn:** [Mark Mashifane](https://linkedin.com/in/markmashifane)  

---

## 📄 License

This project is open source and available under the [MIT License](LICENSE).
