# ecs-flask-openresty

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

## Manually create resource

There are resources needed to be manually create before running CI/CD.

1. ECR `ecs-flask-openresty/flask` and `ecs-flask-openresty/openresty`
2. S3 `ecs-flask-openresty-tf-states` and `willis-lambda-assets`
3. EC2 Key Pairs `ecs-flask-cluster` `esc-openresty-cluster`

There are resources needed to be manually create after ran CI/CD.
1. DNS domain `willischou.com` and setup DNS Server to created Route53

## Architecture

The diagram is generated with [PlantUML](https://plantuml.com/) and [C4 Model Extension](https://github.com/RicardoNiepel/C4-PlantUML)

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