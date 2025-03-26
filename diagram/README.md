# AWS Observability POC Architecture Diagram

This folder contains a Python script to generate a diagram for the AWS Observability Proof of Concept (POC) architecture.
https://diagrams.mingrammer.com/docs/nodes/aws

## Prerequisites

1. **Python**: Ensure Python 3.6 or later is installed.
2. **Diagrams Library**: Install the `diagrams` Python library. You can do this using pip:
   ```bash
   pip install diagrams
   ```

## How to Generate the Diagram

1. Navigate to this folder in your terminal:
   ```bash
   cd diagram
   ```

2. Run the script:
   ```bash
   python script.py
   ```

3. The script will generate two files in the `../docs` folder:
   - `../docs/aws_observability_poc_diagram.png`

## How to Generate the Diagram Using Conda

1. Create a new conda environment:
   ```bash
   conda create -n aws-diagram python=3.8 -y
   ```

2. Activate the environment:
   ```bash
   conda activate aws-diagram
   ```

3. Install the required library:
   ```bash
   pip install diagrams
   ```

4. Navigate to this folder in your terminal:
   ```bash
   cd diagram
   ```

5. Run the script:
   ```bash
   python script.py
   ```

6. The script will generate two files in the `../docs` folder:
   - `../docs/aws_observability_poc_diagram.png`

## Output

The generated diagram visualizes the AWS Observability POC architecture, including components like VPC, subnets, EC2 instances, Lambda functions, and monitoring tools.

## Notes

- You can modify the script (`script.py`) to customize the architecture or add new components.
- Ensure all required Python dependencies are installed before running the script.

