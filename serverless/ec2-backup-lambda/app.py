import boto3
import os
import json
from datetime import datetime

# AWS Clients
ec2 = boto3.client("ec2")
s3 = boto3.client("s3")
sns = boto3.client("sns")

# Environment Variables
INSTANCE_ID = os.environ["INSTANCE_ID"]
S3_BUCKET_NAME = os.environ["S3_BUCKET_NAME"]
SNS_TOPIC_ARN = os.environ["SNS_TOPIC_ARN"]
SNAPSHOT_TAG = os.environ["SNAPSHOT_TAG"]

def get_old_snapshot():
    """Finds and returns the oldest snapshot ID with a specific tag."""
    snapshots = ec2.describe_snapshots(
        Filters=[{"Name": "tag:BackupType", "Values": [SNAPSHOT_TAG]}]
    )["Snapshots"]

    if snapshots:
        snapshots.sort(key=lambda x: x["StartTime"])  # Oldest first
        return snapshots[0]["SnapshotId"]
    return None

def store_snapshot_metadata(snapshot_id):
    """Uploads snapshot details to S3."""
    snapshot_data = {
        "instance_id": INSTANCE_ID,
        "snapshot_id": snapshot_id,
        "timestamp": datetime.utcnow().isoformat()
    }
    
    s3.put_object(
        Bucket=S3_BUCKET_NAME,
        Key=f"ec2-snapshots/{snapshot_id}.json",
        Body=json.dumps(snapshot_data),
        ContentType="application/json"
    )
    print(f"Stored snapshot metadata in S3: {snapshot_id}")

def send_sns_notification(snapshot_id, old_snapshot_id=None):
    """Sends an SNS notification with backup details."""
    message = f"EC2 Snapshot Backup Completed\nInstance: {INSTANCE_ID}\nNew Snapshot ID: {snapshot_id}"
    
    if old_snapshot_id:
        message += f"\nDeleted Old Snapshot: {old_snapshot_id}"
    
    sns.publish(
        TopicArn=SNS_TOPIC_ARN,
        Message=message,
        Subject="EC2 Backup Notification"
    )
    print(f"Sent SNS notification for snapshot: {snapshot_id}")

def lambda_handler(event, context):
    """Main Lambda handler for EC2 backup automation."""
    try:
        # Get Volume ID
        instance_info = ec2.describe_instances(InstanceIds=[INSTANCE_ID])
        volume_id = instance_info["Reservations"][0]["Instances"][0]["BlockDeviceMappings"][0]["Ebs"]["VolumeId"]
        
        # Create a new snapshot
        new_snapshot = ec2.create_snapshot(
            Description=f"Backup for {INSTANCE_ID} on {datetime.utcnow().isoformat()}",
            VolumeId=volume_id
        )

        snapshot_id = new_snapshot["SnapshotId"]

        # Tag the new snapshot
        ec2.create_tags(Resources=[snapshot_id], Tags=[{"Key": "BackupType", "Value": SNAPSHOT_TAG}])

        print(f"Created snapshot: {snapshot_id}")

        # Store snapshot ID in S3
        store_snapshot_metadata(snapshot_id)

        # Delete the old snapshot
        old_snapshot = get_old_snapshot()
        if old_snapshot:
            ec2.delete_snapshot(SnapshotId=old_snapshot)
            print(f"Deleted old snapshot: {old_snapshot}")
        else:
            old_snapshot = "None"

        # Send SNS notification
        send_sns_notification(snapshot_id, old_snapshot_id=old_snapshot)

        return {"statusCode": 200, "body": f"Backup completed: {snapshot_id}"}
    
    except Exception as e:
        print(f"Error: {str(e)}")
        return {"statusCode": 500, "body": f"Error: {str(e)}"}
