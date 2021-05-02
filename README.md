# ecs-flask-openresty

[![Build Status](https://willis.semaphoreci.com/badges/ecs-flask-openresty/branches/master.svg?style=shields)](https://willis.semaphoreci.com/projects/ecs-flask-openresty)

This is a demo of using AWS ECS, Flask and Openresty with CI/CD pipeline. The project uses a Openresty as reverse proxy to a backend Flask application. The Openresty and Flask are all run on AWS ECS.

## Manually create env for CI/CD

We use Semaphore CI to run our CI/CD pipeline which use Terraform. Therefore, the environment variables below are needed:

```yaml
AWS_ACCESS_KEY_ID: ___
AWS_SECRET_ACCESS_KEY: ___
AWS_DEFAULT_REGION: us-east-2
```

We also need a fallback ssl cert for Openresty using `lua-resty-auto-ssl`. The Semaphore CI secrets with file type is needed:

```yaml
~/resty-auto-ssl-fallback.crt
~/resty-auto-ssl-fallback.key
```

![env for cicd](assets/img/manually-create-env-for-cicd.png?raw=true)

## Manually create resource

There are resources needed to be manually create before running CI/CD.  
Pleaes be awared the S3 bucket name is global unique, you may need to create it with your specific name.

1. ECR `ecs-flask-openresty/flask` and `ecs-flask-openresty/openresty`
![ecr](assets/img/ecr.png?raw=true)
2. S3 `ecs-flask-openresty-tf-states` and `willis-lambda-assets`
![s3](assets/img/s3.png?raw=true)
3. EC2 Key Pairs `ecs-flask-cluster` `ecs-openresty-cluster`
![key paris](assets/img/key-paris.png?raw=true)
4. IAM User with programmatic access
![iam](assets/img/iam.png?raw=true)

There are resources needed to be manually create after ran CI/CD.
1. DNS domain `willischou.com` and setup DNS Server to created Route53

## Architecture

The diagram is generated with [PlantUML](https://plantuml.com/) and [C4 Model Extension](https://github.com/RicardoNiepel/C4-PlantUML)

![Architecture](https://www.plantuml.com/plantuml/img/fLHBRvj04BxpAxQ-54krmM2daKyXZlEGQ68PVEW9RTQJ67MzeDqbbHNbltTuc60RcbJbmFBu7iDyErmeJQNEjfnGoJQn1gOp2GEMRDD4WD36brWmdgqXavnij4xLrB8a_JryZlKcUymKI9O8ZSWXSgnbpAXS9_SnfC2jsNYmu5JerG_Vai21Ah160nkVHpCaqLY07APeRXY-z_DX5KR-_3gCbdStjw5XB42gH9XfiNmZlHLwzN3r60Ebo1EdwXUXQThh6y5EQTYQ7BIAG32vIpK2VT1V5PcNz-RCwoEozZLbaccOk8XRvbTaukRY0SYNc04YBvDChAdScS1KbAGW92YzGyXy5f27_NslJruDWiUxS8sDW3_cUF-oWJ_mo8cr3rNF1pvUSDFYq-KL2qnIC8X6HOdEeULTzRRo_534-OJ8Mt5U0Z_-uewYoZRh99Uw3SF5zDosYdKyTYl9puav7ukz7SPNx9KgkklykYMs0XFH8Z8F8ojnVuzhhvj7TQZRfdqIKMtHsTb6KIqQ9qrmdUzdvuEpaMtRHHDoYVty76_BSengAlRDgXg9r2RnVL2kxWE24Wb_WPmNpXRJYMkjhlAb8hLdt-pjIT6Jijfkzj5OUpZs3AIEd_1dew7v1TqopdyLuVnZ4OPn0MADFxO_ "Architecture")

```plantuml
@startuml architecture-component
!includeurl https://raw.githubusercontent.com/RicardoNiepel/C4-PlantUML/release/1-0/C4_Container.puml

LAYOUT_LEFT_RIGHT

Person(person, "User", "Access flask app")
System(lets_encrypt, "Let's Encrypt(CA)")
Container(route53, "Route 53", "Service")
Boundary(ecs_openresty, "ECS Openresty") {
    Container(openresty_elb, "ELB Openresty", "Service")
    Boundary(asg_openresty, "ASG Openresty") {
        Container(openresty_instance_1, "EC2 Openresty", "Instance")
        Container(openresty_instance_2, "EC2 Openresty", "Instance")
    }
    Rel(openresty_elb, openresty_instance_1, "Route to", "HTTP:80/HTTP:443")
    Rel(openresty_elb, openresty_instance_2, "Route to", "HTTP:80/HTTP:443")
}
Boundary(ecs_flask, "ECS Flask") {
    Container(flask_alb, "ALB Flask", "Service")
    Boundary(asg_flask, "ASG Flask") {
        Container(flask_instance_1, "EC2 Flask", "Instance")
    }
    Rel(flask_alb, flask_instance_1, "Route to", "HTTP:32768-61000")
}
Rel(person, openresty_elb, "Access", "HTTP:443/HTTP:80")
Rel(person, route53, "DNS resolve", "TCP:53/UDP:53")
Rel(openresty_instance_1, flask_alb, "Route to", "HTTP:5000")
Rel(openresty_instance_1, lets_encrypt, "Ask certificate", "HTTP:443")
Rel(openresty_instance_2, flask_alb, "Route to", "HTTP:5000")
Rel(openresty_instance_2, lets_encrypt, "Ask certificate", "HTTP:443")


@enduml
```

## CI/CD Implement

1. Create a sempahore 2.0 account and project
2. Create secrets at user(or organization or project) level, please refers "Manually create env for CI/CD" section
3. Create ECR, S3 and EC2 key pairs, please refers "Manually create resource" section
4. Replace the value of `ECR_REGISTRY`, `LAMBDA_ASSETS_S3` and `TERRAFORM_REMOTE_STATE_S3` in `.semaphore/semaphore.yml`
5. Replace the value of `AWS_VPC_ID`, `AWS_SUBNET_A_ID`, `AWS_SUBNET_B_ID` and `ALLOW_SSH_IP` with your own in `.semaphore/semaphore.yml`
6. Replace domain `willischou.com` with your own in `deploy/aws/template/route53.tf` and `nginx/default.conf`
7. Commit your changes and let the pipeline build it for you.