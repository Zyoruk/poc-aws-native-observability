import json
from dotenv import load_dotenv

load_dotenv()

# from aws_lambda_powertools.event_handler import APIGatewayRestResolver
from aws_lambda_powertools.utilities.typing import LambdaContext
from aws_lambda_powertools.logging import correlation_paths
from aws_lambda_powertools import Logger
from aws_lambda_powertools import Tracer
from aws_lambda_powertools import Metrics
from aws_lambda_powertools.metrics import MetricUnit

# app = APIGatewayRestResolver()
service = "coe-aws-obs-lambda"
tracer = Tracer(service=service)
logger = Logger(service=service)
metrics = Metrics(namespace=service)

@tracer.capture_method
def create_table_structure():
    # Sample column names and data for DataFrame
    COLUMNS = ["full_name", "id", "project_manager_name", "project_name", 
            "technical_skill", "soft_skills", "years_in_company", "seniority"]

    # Sample DataFrame initialization
    SAMPLE_DATA = [
        ["John Doe", "1", "Alice", "Project A", {"Python": 3, "AWS": 2}, {"Communication": 5, "Teamwork": 4}, 3, "SE1"],
        ["Jane Smith", "2", "Bob", "Project B", {"Java": 4, "AWS": 3}, {"Leadership": 5, "Problem-solving": 5}, 5, "SE2"],
        ["Mark Johnson", "3", "Charlie", "Project A", {"Go": 4, "AWS": 4}, {"Adaptability": 4, "Collaboration": 3}, 2, "SE1"],
        ["Eve Brown", "4", "Alice", "Project C", {"Ruby": 5, "SQL": 3}, {"Time management": 5, "Creativity": 4}, 6, "SSE"],
        ["Chris Green", "5", "Bob", "Project B", {"JavaScript": 4, "AWS": 2}, {"Problem-solving": 5, "Teamwork": 3}, 3, "SE2"],
        ["Olivia Taylor", "6", "David", "Project A", {"Python": 4, "Django": 3}, {"Communication": 4, "Leadership": 3}, 4, "SSE"],
        ["Daniel White", "7", "Eve", "Project D", {"C++": 3, "Java": 4}, {"Adaptability": 4, "Collaboration": 5}, 2, "SE1"],
        ["Sophia Martin", "8", "Frank", "Project E", {"Swift": 4, "AWS": 4}, {"Time management": 3, "Leadership": 4}, 5, "SSE"],
        ["Liam Wilson", "9", "Grace", "Project F", {"Go": 4, "Kubernetes": 2}, {"Problem-solving": 5, "Teamwork": 4}, 7, "SSE"],
        ["Mia Moore", "10", "Harry", "Project G", {"Java": 3, "React": 4}, {"Creativity": 5, "Communication": 4}, 1, "SE1"],
    ]

    return COLUMNS, SAMPLE_DATA

@tracer.capture_method
def analyze_employee_data(columns, data):
    # Basic statistics
    details = {
        "number_of_columns": len(columns),
        "number_of_rows": len(data),
        "seniority_counts": {},
        "total_years": 0,
        "avg_years_in_company": 0,
        "grouped_by_seniority": {},
        "avg_years_by_seniority": {}
    }
    
    # Get seniority index for easier access
    seniority_idx = columns.index("seniority")
    years_idx = columns.index("years_in_company")
    
    # Initialize temporary storage for years by seniority
    years_by_seniority = {}
    
    # Process each row
    for row in data:
        seniority = row[seniority_idx]
        years = row[years_idx]
        
        # Update seniority counts
        details["seniority_counts"][seniority] = details["seniority_counts"].get(seniority, 0) + 1
        
        # Update total years
        details["total_years"] += years
        
        # Group by seniority
        if seniority not in details["grouped_by_seniority"]:
            details["grouped_by_seniority"][seniority] = []
        details["grouped_by_seniority"][seniority].append(dict(zip(columns, row)))
        
        # Accumulate years by seniority for average calculation
        if seniority not in years_by_seniority:
            years_by_seniority[seniority] = []
        years_by_seniority[seniority].append(years)
    
    # Calculate average years in company
    details["avg_years_in_company"] = round(details["total_years"] / len(data), 2)
    
    # Calculate average years by seniority
    for seniority, years_list in years_by_seniority.items():
        details["avg_years_by_seniority"][seniority] = round(sum(years_list) / len(years_list), 2)
    
    return details

# @app.get("/hello")
@tracer.capture_method
def test_logs():
    try:
        # Adding custom metrics
        metrics.add_metric(name="HelloWorldInvocations", unit=MetricUnit.Count, value=1)

        columns, data = create_table_structure()
        details = analyze_employee_data(columns, data)

        # Standardized log structure
        logger.info("Analyzed employee data", extra={
            "result_details": details,
            "total_rows": len(data),
            "columns": columns
        })

        all_rows_dict = {}
        data_id = columns.index("id")
        data_full_name = columns.index("full_name")
        for row in data:
            row_dict = {
                "Full_Name": row[data_full_name],
                "ID": row[data_id]
            }
            all_rows_dict[row[data_id]] = row_dict

        logger.debug("Processed all rows", extra={"all_rows": all_rows_dict})

        result = {
            "statusCode": 200,
            "message": json.dumps("Data retrieved successfully!"),
            "body": {
                "data": json.dumps(len(data))
            }
        }
    except Exception as ex:
        logger.error("Error processing data", extra={"error": str(ex)})
        result = {
            "statusCode": 400,
            "message": json.dumps("Data not retrieved!"),
            "body": {
                "data": "no_available"
            },
            "errors": str(ex)
        }

    logger.info("Lambda execution result", extra={"result": result})
    return result

# Enrich logging with contextual information from Lambda
@logger.inject_lambda_context(correlation_id_path=correlation_paths.API_GATEWAY_REST)
# Adding tracer
# See: https://awslabs.github.io/aws-lambda-powertools-python/latest/core/tracer/
@tracer.capture_lambda_handler
# ensures metrics are flushed upon request completion/failure and capturing ColdStart metric
@metrics.log_metrics(capture_cold_start_metric=True)
def handler(event: dict, context: LambdaContext) -> dict:
    return test_logs()