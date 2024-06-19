[![License: Unlicense](https://img.shields.io/badge/license-Unlicense-white.svg)](https://choosealicense.com/licenses/unlicense/) [![GitHub pull-requests closed](https://img.shields.io/github/issues-pr-closed/kunduso/add-aws-lambda-terraform)](https://github.com/kunduso/add-aws-lambda-terraform/pulls?q=is%3Apr+is%3Aclosed) [![GitHub pull-requests](https://img.shields.io/github/issues-pr/kunduso/add-aws-lambda-terraform)](https://GitHub.com/kunduso/add-aws-lambda-terraform/pull/) 
[![GitHub issues-closed](https://img.shields.io/github/issues-closed/kunduso/add-aws-lambda-terraform)](https://github.com/kunduso/add-aws-lambda-terraform/issues?q=is%3Aissue+is%3Aclosed) [![GitHub issues](https://img.shields.io/github/issues/kunduso/add-aws-lambda-terraform)](https://GitHub.com/kunduso/add-aws-lambda-terraform/issues/) 
[![terraform-infra-provisioning](https://github.com/kunduso/add-aws-lambda-terraform/actions/workflows/terraform.yml/badge.svg?branch=main)](https://github.com/kunduso/add-aws-lambda-terraform/actions/workflows/terraform.yml) [![checkov-static-analysis-scan](https://github.com/kunduso/add-aws-lambda-terraform/actions/workflows/code-scan.yml/badge.svg?branch=main)](https://github.com/kunduso/add-aws-lambda-terraform/actions/workflows/code-scan.yml)
![Image](https://skdevops.files.wordpress.com/2024/06/95-image-0-1.png)
This repository contains the necessary files and configurations to deploy AWS cloud infrastructure resources using Terraform. For a detailed walkthrough on creating an AWS Lambda function using Terraform please check [-create-aws-lambda-using-github-actions](https://skundunotes.com/2024/06/18/automating-aws-lambda-deployment-harnessing-terraform-github-actions-and-python-for-cloudwatch-logging/).

Additionally, this repository includes:
</br> - a [Checkov pipeline](./.github/workflows/code-scan.yml) for scanning the Terraform code for security and compliance issues.

The entire setup and deployment process is automated via the GitHub Actions pipelines, eliminating the need for manual steps.

## Prerequisites
For this code to function without errors, create an OpenID connect identity provider in Amazon Identity and Access Management that has a trust relationship with your GitHub repository. You can read about it [here](https://skundunotes.com/2023/02/28/securely-integrate-aws-credentials-with-github-actions-using-openid-connect/) to get a detailed explanation with steps.
<br />Store the `ARN` of the `IAM Role` as a GitHub secret which is referred in the `terraform.yml` file.
<br />For the **Infracost** integration, create an `INFRACOST_API_KEY` and store that as a GitHub Actions secret. You can manage the cost estimate process using a GitHub Actions variable `INFRACOST_SCAN_TYPE` where the value is either `hcl_code` or `tf_plan`, depending on the type of scan desired.
<br />You can read about that at - [integrate-Infracost-with-GitHub-Actions.](http://skundunotes.com/2023/07/17/estimate-aws-cloud-resource-cost-with-infracost-terraform-and-github-actions/)
## Usage
Ensure that the policy attached to the IAM role whose credentials are being used in this configuration has permission to create and manage all the resources that are included in this repository.
<br />Review the code including the [`terraform.yml`](./.github/workflows/terraform.ymlt) to understand the steps in the GitHub Actions pipeline. Also review the terraform code to understand all the concepts associated with creating the AWS Cloud resources..

<br />If you want to check the pipeline logs, click on the **Build Badges** above the image in this ReadMe.

## Contributing
If you find any issues or have suggestions for improvement, feel free to open an issue or submit a pull request. Contributions are always welcome!

## License
This code is released under the Unlicense License. See [LICENSE](LICENSE).