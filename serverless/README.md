To **deploy** this AWS Lambda function, we'll use the **AWS SAM (Serverless Application Model)**, which simplifies deployment using Infrastructure as Code (IaC). Below is the step-by-step guide.

---

# **1️⃣ Install AWS SAM CLI**
Ensure you have the AWS SAM CLI installed:

- **macOS (Homebrew)**  
  ```sh
  brew install aws/tap/aws-sam-cli
  ```

- **Windows (Chocolatey)**  
  ```sh
  choco install aws-sam-cli
  ```

- **Linux**  
  ```sh
  curl -fsSL https://raw.githubusercontent.com/aws/aws-sam-cli/main/install/install.sh | sh
  ```

Verify the installation:  
```sh
sam --version
```

---

# **2️⃣ Set Up the Project Directory**
Create a new directory and navigate into it:

```sh
mkdir ec2-backup-lambda && cd ec2-backup-lambda
```

---

## Step 1: Create IAM Role for Lambda
1. Open the **AWS IAM Console**
2. Create a new IAM **Role**
3. Attach the following **Inline Policy**:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:CreateSnapshot",
                "ec2:DescribeSnapshots",
                "ec2:DeleteSnapshot",
                "ec2:CreateTags",
                "ec2:DescribeInstances"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::your-s3-bucket-name/*"
        },
        {
            "Effect": "Allow",
            "Action": "sns:Publish",
            "Resource": "arn:aws:sns:us-east-1:YOUR_ACCOUNT_ID:your-sns-topic"
        }
    ]
}
```

4. Attach the role to the Lambda function

# **3️⃣ Create the Lambda Function**
Inside `ec2-backup-lambda/`, create a new file `app.py` and paste the following code:

### **`app.py` (Lambda Function)**
```python
import boto3
import os
from datetime import datetime

# Initialize EC2 client
ec2 = boto3.client("ec2")

# Environment Variables
INSTANCE_ID = os.environ["INSTANCE_ID"]
SNAPSHOT_TAG = "EC2_Backup"

def get_old_snapshot():
    """Finds the previous snapshot with the defined tag."""
    snapshots = ec2.describe_snapshots(
        Filters=[{"Name": "tag:BackupType", "Values": [SNAPSHOT_TAG]}]
    )["Snapshots"]

    if snapshots:
        snapshots.sort(key=lambda x: x["StartTime"])  # Oldest first
        return snapshots[0]["SnapshotId"]  # Return oldest snapshot ID
    return None

def lambda_handler(event, context):
    # Create a new snapshot
    new_snapshot = ec2.create_snapshot(
        Description=f"Backup for {INSTANCE_ID} on {datetime.utcnow().isoformat()}",
        VolumeId=ec2.describe_instances(InstanceIds=[INSTANCE_ID])["Reservations"][0]["Instances"][0]["BlockDeviceMappings"][0]["Ebs"]["VolumeId"]
    )

    snapshot_id = new_snapshot["SnapshotId"]

    # Tag the new snapshot
    ec2.create_tags(Resources=[snapshot_id], Tags=[{"Key": "BackupType", "Value": SNAPSHOT_TAG}])

    print(f"Created snapshot: {snapshot_id}")

    # Find and delete the old snapshot
    old_snapshot = get_old_snapshot()
    if old_snapshot:
        ec2.delete_snapshot(SnapshotId=old_snapshot)
        print(f"Deleted old snapshot: {old_snapshot}")

    return {"statusCode": 200, "body": f"Backup completed: {snapshot_id}"}
```

---

# **4️⃣ Define AWS SAM Template**
Create a `template.yaml` file in the same directory.

### **`template.yaml` (SAM Deployment Template)**
```yaml
AWSTemplateFormatVersion: '2010-09-09'
Transform: AWS::Serverless-2016-10-31

Resources:
  EC2BackupLambda:
    Type: AWS::Serverless::Function
    Properties:
      FunctionName: EC2BackupLambda
      Runtime: python3.11
      Handler: app.lambda_handler
      CodeUri: .
      MemorySize: 128
      Timeout: 30
      Policies:
        - AWSLambdaBasicExecutionRole
        - Statement:
            - Effect: Allow
              Action:
                - "ec2:CreateSnapshot"
                - "ec2:DescribeSnapshots"
                - "ec2:DeleteSnapshot"
                - "ec2:CreateTags"
                - "ec2:DescribeInstances"
              Resource: "*"
      Environment:
        Variables:
          INSTANCE_ID: "i-xxxxxxxxxxxxxxxxx"  # Replace with your EC2 instance ID
      Events:
        ScheduledTrigger:
          Type: Schedule
          Properties:
            Schedule: rate(15 days)  # Runs every 15 days
```

---

# **5️⃣ Build and Deploy the Lambda Function**
### **1. Build the function**
```sh
sam build
```

### **2. Deploy the function**
```sh
sam deploy --guided
```
You'll be prompted to enter:
- **Stack Name**: `ec2-backup-lambda`
- **AWS Region**: Choose the region (e.g., `us-east-1`)
- **Confirm changes before deploy**: `Y`
- **Save arguments for next deploy**: `Y`

---

# **6️⃣ Verify the Deployment**
Once the deployment is complete, go to:

1. **AWS Lambda Console** → Find `EC2BackupLambda`
2. **Amazon EventBridge** → Find a rule with `rate(15 days)`
3. **AWS CloudWatch Logs** → View execution logs

To **test manually**, run:
```sh
aws lambda invoke --function-name EC2BackupLambda output.json
cat output.json
```

## Step 4: Configure CloudWatch Event (Optional)
To trigger the Lambda function every 15 days:
1. Open **AWS EventBridge**
2. Create a new **Rule**
3. Choose **Schedule expression**
4. Set cron expression:
   ```
   cron(0 0 1,16 * ? *)
   ```
5. Set the **Target** to the Lambda function

---

### 🎉 **Conclusion**
This setup **automates EC2 backups** every 15 days, **keeps only the latest snapshot**, and **deletes the old one** to save storage. 🚀 Let me know if you need enhancements like **storing snapshot IDs in S3/DynamoDB** or **triggering notifications via SNS**!