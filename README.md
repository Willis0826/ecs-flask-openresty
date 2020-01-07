# ecs-flask-openresty

This is a demo of using AWS ECS, Flask and Openresty with CI/CD pipeline. The project uses a Openresty as reverse proxy to a backend Flask application. The Openresty and Flask are all run on AWS ECS.

## Manually create resource

There are resources needed to be manually create before running CI/CD.

1. ECR `ecs-flask-openresty/flask` and `ecs-flask-openresty/openresty`
2. S3 `ecs-flask-openresty-tf-states`
3. EC2 Key Pairs `ecs-flask-cluster`