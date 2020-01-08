# ecs-flask-openresty

This is a demo of using AWS ECS, Flask and Openresty with CI/CD pipeline. The project uses a Openresty as reverse proxy to a backend Flask application. The Openresty and Flask are all run on AWS ECS.

## Manually create resource

There are resources needed to be manually create before running CI/CD.

1. ECR `ecs-flask-openresty/flask` and `ecs-flask-openresty/openresty`
2. S3 `ecs-flask-openresty-tf-states`
3. EC2 Key Pairs `ecs-flask-cluster`

## Architecture
```plantuml
@startuml architecture-component
!includeurl https://raw.githubusercontent.com/RicardoNiepel/C4-PlantUML/release/1-0/C4_Container.puml

LAYOUT_LEFT_RIGHT

Person(person, "User", "Access flask app")
Boundary(ecs_openresty, "ECS Openresty") {
    Container(openresty_elb, "ELB Openresty", "Service")
    Boundary(asg_openresty, "ASG Openresty") {
        Container(openresty_instance_1, "EC2 Openresty", "Service")
    }

    Rel(openresty_elb, openresty_instance_1, "Route to", "HTTP:80")
}
Boundary(ecs_flask, "ECS Flask") {
    Container(flask_alb, "ALB Flask", "Service")
    Boundary(asg_flask, "ASG Flask") {
        Container(flask_instance_1, "EC2 Flask", "Service")
    }
    Rel(flask_alb, flask_instance_1, "Route to", "HTTP:32768-61000")
}
Rel(person, openresty_elb, "Access", "HTTP")
Rel(openresty_instance_1, flask_alb, "Route to", "HTTP:5000")


@enduml
```