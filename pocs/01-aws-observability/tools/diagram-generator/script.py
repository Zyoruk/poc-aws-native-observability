from diagrams import Diagram, Cluster, Edge
from diagrams.aws.network import VPC, InternetGateway, NATGateway, ALB
from diagrams.aws.compute import EC2AutoScaling, LambdaFunction
from diagrams.aws.mobile import APIGateway
from diagrams.aws.storage import S3 
from diagrams.aws.database import Dynamodb

from diagrams.aws.management import Cloudwatch
from diagrams.aws.integration import SNS
from diagrams.onprem.monitoring import Grafana, Prometheus
import os

# Ensure the '../docs' folder exists
os.makedirs("../docs", exist_ok=True)

with Diagram("AWS Observability POC Architecture", filename="../docs/aws_observability_poc_diagram", 
             outformat=["png"], show=False):
    # External components
    igw = InternetGateway("Internet Gateway")
    apigw = APIGateway("API Gateway")
    # Storage cluster outside VPC
    with Cluster("Storage"):
        storage_s3 = S3("Lambda Code S3 Bucket")
        storage_ddb = Dynamodb("DynamoDB Table")
    # Monitoring services cluster outside VPC
    with Cluster("AWS Monitoring Services"):
        cw = Cloudwatch("CloudWatch")
        sns_topic = SNS("Alarm SNS Topic")
    # Connect CloudWatch to SNS for alarms
    cw >> Edge(label="Alarm Notification") >> sns_topic
    
    with Cluster("VPC (10.0.0.0/24)"):
        # Public Subnets cluster (2 Availability Zones)
        with Cluster("Public Subnets (2 AZs)"):
            # Observability EC2 instances (Grafana & Prometheus servers)
            with Cluster("Observability EC2 Instances"):
                grafana = Grafana("Grafana Server")
                prometheus = Prometheus("Prometheus Server")
            # Application compute cluster (container fleet in an ASG)
            with Cluster("Container Fleet (EC2 Auto Scaling Group)"):
                container_asg = EC2AutoScaling("EC2 Auto Scaling Group")
            # Public-facing load balancer and NAT Gateway
            alb = ALB("Application Load Balancer")
            natgw = NATGateway("NAT Gateway")
        # Private Subnets cluster (2 Availability Zones)
        with Cluster("Private Subnets (2 AZs)"):
            lambda_func = LambdaFunction("Lambda Function")
    
        # Private subnet outbound access via NAT Gateway
        lambda_func >> Edge(label="Outbound") >> natgw
        natgw >> Edge(label="Internet Access") >> igw
        # Internet Gateway ingress to ALB (public-facing)
        igw >> Edge(label="Inbound") >> alb
        
        # API Gateway invokes the Lambda (AWS Proxy integration)
        apigw >> Edge(label="Invoke") >> lambda_func
        # Lambda function reads/writes to DynamoDB
        lambda_func >> Edge(label="Reads/Writes") >> storage_ddb
        # Lambda code package stored in S3 (deployment artifact)
        storage_s3 >> Edge(label="Code", style="dashed") >> lambda_func
        
        # ALB forwards traffic to container instances (Node Exporter on 9100)
        alb >> Edge(label="Forwards traffic") >> container_asg
        # Prometheus scrapes metrics via ALB endpoint
        prometheus >> Edge(label="Scrape metrics") >> alb
        # Grafana queries Prometheus for metrics data
        grafana >> Edge(label="Query") >> prometheus
        # Grafana pulls CloudWatch metrics/logs via CloudWatch API
        grafana >> Edge(label="CloudWatch API") >> cw
