#!/bin/bash

# ========================================================================
# Multi-Cloud Infrastructure Deployment Script
# 
# This script automates Terraform deployment across AWS and GCP with:
#   - Cloud provider authentication
#   - Terraform initialization and validation
#   - Security scanning with tfsec and checkov
#   - Controlled deployment with approval steps
#   - Comprehensive logging
# ========================================================================

# Set strict error handling
set -eo pipefail

# Configuration variables - customize these
AWS_PROFILE="default"
GCP_PROJECT_ID=""
TERRAFORM_DIR="./terraform"
LOG_DIR="./deployment_logs"
LOG_FILE="${LOG_DIR}/deploy_$(date +%Y%m%d_%H%M%S).log"

# Color codes for better readability
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ========================================================================
# Helper Functions
# ========================================================================

log() {
  local level=$1
  local message=$2
  local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  
  # Log to console with color
  case $level in
    "INFO")
      echo -e "${BLUE}[INFO]${NC} ${timestamp} - ${message}"
      ;;
    "SUCCESS")
      echo -e "${GREEN}[SUCCESS]${NC} ${timestamp} - ${message}"
      ;;
    "WARNING")
      echo -e "${YELLOW}[WARNING]${NC} ${timestamp} - ${message}"
      ;;
    "ERROR")
      echo -e "${RED}[ERROR]${NC} ${timestamp} - ${message}"
      ;;
    *)
      echo -e "[${level}] ${timestamp} - ${message}"
      ;;
  esac
  
  # Log to file
  echo "[${level}] ${timestamp} - ${message}" >> "$LOG_FILE"
}

check_command() {
  if ! command -v "$1" &> /dev/null; then
    log "ERROR" "Required command not found: $1"
    log "ERROR" "Please install $1 before continuing"
    exit 1
  fi
}

check_exit_status() {
  if [ $1 -ne 0 ]; then
    log "ERROR" "$2 failed with exit code $1"
    exit $1
  else
    log "SUCCESS" "$2 completed successfully"
  fi
}

prompt_continue() {
  local message=$1
  echo -e "${YELLOW}${message}${NC}"
  read -p "Continue? (y/n): " choice
  case "$choice" in 
    y|Y ) return 0;;
    * ) 
      log "INFO" "Operation canceled by user"
      exit 0
      ;;
  esac
}

# ========================================================================
# Setup
# ========================================================================

setup() {
  log "INFO" "Setting up deployment environment"
  
  # Create log directory if it doesn't exist
  mkdir -p "$LOG_DIR"
  
  # Check for required tools
  log "INFO" "Checking required tools..."
  check_command "terraform"
  check_command "aws"
  check_command "gcloud"
  
  # Optional tools
  if ! command -v tfsec &> /dev/null; then
    log "WARNING" "tfsec not found - security scanning will be limited"
  fi
  
  if ! command -v checkov &> /dev/null; then
    log "WARNING" "checkov not found - security scanning will be limited"
  fi
  
  log "INFO" "Environment setup complete"
}

# ========================================================================
# Authentication
# ========================================================================

authenticate_aws() {
  log "INFO" "Authenticating with AWS using profile: $AWS_PROFILE"
  
  if [ -z "$AWS_PROFILE" ]; then
    log "ERROR" "AWS_PROFILE is not set"
    exit 1
  fi
  
  # Test AWS authentication
  aws sts get-caller-identity --profile "$AWS_PROFILE" > /dev/null 2>&1
  check_exit_status $? "AWS authentication"
  
  # Export for Terraform
  export AWS_PROFILE="$AWS_PROFILE"
  log "SUCCESS" "AWS authentication successful"
}

authenticate_gcp() {
  log "INFO" "Authenticating with Google Cloud Platform"
  
  if [ -z "$GCP_PROJECT_ID" ]; then
    log "WARNING" "GCP_PROJECT_ID is not set. Please enter your GCP Project ID:"
    read -r GCP_PROJECT_ID
    
    if [ -z "$GCP_PROJECT_ID" ]; then
      log "ERROR" "GCP Project ID is required"
      exit 1
    fi
  fi
  
  # Check if already authenticated
  if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | grep -q "@"; then
    log "INFO" "No active GCP authentication found, initiating login..."
    gcloud auth login
    check_exit_status $? "GCP authentication"
  else
    log "INFO" "Already authenticated with GCP"
  fi
  
  # Set the project
  gcloud config set project "$GCP_PROJECT_ID"
  check_exit_status $? "Setting GCP project"
  
  # Enable required APIs if not already enabled
  log "INFO" "Ensuring required GCP APIs are enabled..."
  gcloud services enable compute.googleapis.com container.googleapis.com sqladmin.googleapis.com --quiet
  
  log "SUCCESS" "GCP authentication successful"
}

# ========================================================================
# Terraform Operations
# ========================================================================

terraform_init() {
  log "INFO" "Initializing Terraform in directory: $TERRAFORM_DIR"
  
  if [ ! -d "$TERRAFORM_DIR" ]; then
    log "ERROR" "Terraform directory not found: $TERRAFORM_DIR"
    exit 1
  fi
  
  # Navigate to Terraform directory
  cd "$TERRAFORM_DIR"
  
  # Initialize Terraform
  terraform init -upgrade
  check_exit_status $? "Terraform initialization"
  
  log "SUCCESS" "Terraform initialization complete"
}

terraform_validate() {
  log "INFO" "Validating Terraform configuration"
  
  # Validate the configuration
  terraform validate
  check_exit_status $? "Terraform validation"
  
  log "SUCCESS" "Terraform validation passed"
}

terraform_fmt_check() {
  log "INFO" "Checking Terraform formatting"
  
  # Check formatting
  terraform fmt -check -recursive
  if [ $? -ne 0 ]; then
    log "WARNING" "Terraform files are not properly formatted"
    prompt_continue "Would you like to automatically format the files?"
    terraform fmt -recursive
    check_exit_status $? "Terraform formatting"
  else
    log "SUCCESS" "Terraform formatting check passed"
  fi
}

terraform_plan() {
  log "INFO" "Generating Terraform execution plan"
  
  # Create a plan file
  terraform plan -out=terraform.plan
  check_exit_status $? "Terraform plan generation"
  
  log "SUCCESS" "Terraform plan generated successfully"
}

terraform_security_scan() {
  log "INFO" "Running security scans on Terraform code"
  
  # Run tfsec if available
  if command -v tfsec &> /dev/null; then
    log "INFO" "Running tfsec scan..."
    tfsec . --no-color > "${LOG_DIR}/tfsec_results.txt" 2>&1 || true
    log "INFO" "tfsec scan results saved to ${LOG_DIR}/tfsec_results.txt"
    
    # Count issues
    local tfsec_count=$(grep -c "WARN" "${LOG_DIR}/tfsec_results.txt" || echo "0")
    if [ "$tfsec_count" -gt 0 ]; then
      log "WARNING" "tfsec found $tfsec_count potential security issues"
    else
      log "SUCCESS" "tfsec scan passed with no issues"
    fi
  fi
  
  # Run checkov if available
  if command -v checkov &> /dev/null; then
    log "INFO" "Running checkov scan..."
    checkov -d . --quiet --output-file-path "${LOG_DIR}" > /dev/null 2>&1 || true
    log "INFO" "checkov scan results saved to ${LOG_DIR}/results_json.json"
    
    # Count issues (simplified)
    if [ -f "${LOG_DIR}/results_json.json" ]; then
      local checkov_failed=$(grep -c "\"FAILED\"" "${LOG_DIR}/results_json.json" || echo "0")
      if [ "$checkov_failed" -gt 0 ]; then
        log "WARNING" "checkov found $checkov_failed potential security issues"
      else
        log "SUCCESS" "checkov scan passed with no issues"
      fi
    fi
  fi
  
  if ! command -v tfsec &> /dev/null && ! command -v checkov &> /dev/null; then
    log "WARNING" "No security scanning tools available. Consider installing tfsec or checkov."
  else
    prompt_continue "Security scan complete. Review the results in the log directory before continuing."
  fi
}

terraform_apply() {
  log "INFO" "Preparing to apply Terraform changes"
  
  # Show the plan summary
  terraform show terraform.plan
  
  # Ask for confirmation
  prompt_continue "The above changes will be applied to AWS and GCP. This may incur costs."
  
  # Apply the plan
  log "INFO" "Applying Terraform changes"
  terraform apply terraform.plan
  check_exit_status $? "Terraform apply"
  
  log "SUCCESS" "Infrastructure deployment completed successfully"
}

terraform_output() {
  log "INFO" "Retrieving infrastructure outputs"
  
  # Get and log the outputs
  terraform output -json > "${LOG_DIR}/terraform_outputs.json"
  check_exit_status $? "Terraform output capture"
  
  log "SUCCESS" "Infrastructure outputs saved to ${LOG_DIR}/terraform_outputs.json"
}

# ========================================================================
# Main Execution
# ========================================================================

main() {
  log "INFO" "Starting multi-cloud infrastructure deployment"
  log "INFO" "Deployment ID: $(basename "$LOG_FILE" .log)"
  
  # Setup environment
  setup
  
  # Authenticate with cloud providers
  authenticate_aws
  authenticate_gcp#!/bin/bash

# ========================================================================
# Multi-Cloud Infrastructure Deployment Script
# 
# This script automates Terraform deployment across AWS and GCP with:
#   - Cloud provider authentication
#   - Terraform initialization and validation
#   - Security scanning with tfsec and checkov
#   - Controlled deployment with approval steps
#   - Comprehensive logging
# ========================================================================

# Set strict error handling
set -eo pipefail

# Configuration variables - customize these
AWS_PROFILE="default"
GCP_PROJECT_ID=""
TERRAFORM_DIR="./terraform"
LOG_DIR="./deployment_logs"
LOG_FILE="${LOG_DIR}/deploy_$(date +%Y%m%d_%H%M%S).log"

# Color codes for better readability
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ========================================================================
# Helper Functions
# ========================================================================

log() {
  local level=$1
  local message=$2
  local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  
  # Log to console with color
  case $level in
    "INFO")
      echo -e "${BLUE}[INFO]${NC} ${timestamp} - ${message}"
      ;;
    "SUCCESS")
      echo -e "${GREEN}[SUCCESS]${NC} ${timestamp} - ${message}"
      ;;
    "WARNING")
      echo -e "${YELLOW}[WARNING]${NC} ${timestamp} - ${message}"
      ;;
    "ERROR")
      echo -e "${RED}[ERROR]${NC} ${timestamp} - ${message}"
      ;;
    *)
      echo -e "[${level}] ${timestamp} - ${message}"
      ;;
  esac
  
  # Log to file
  echo "[${level}] ${timestamp} - ${message}" >> "$LOG_FILE"
}

check_command() {
  if ! command -v "$1" &> /dev/null; then
    log "ERROR" "Required command not found: $1"
    log "ERROR" "Please install $1 before continuing"
    exit 1
  fi
}

check_exit_status() {
  if [ $1 -ne 0 ]; then
    log "ERROR" "$2 failed with exit code $1"
    exit $1
  else
    log "SUCCESS" "$2 completed successfully"
  fi
}

prompt_continue() {
  local message=$1
  echo -e "${YELLOW}${message}${NC}"
  read -p "Continue? (y/n): " choice
  case "$choice" in 
    y|Y ) return 0;;
    * ) 
      log "INFO" "Operation canceled by user"
      exit 0
      ;;
  esac
}

# ========================================================================
# Setup
# ========================================================================

setup() {
  log "INFO" "Setting up deployment environment"
  
  # Create log directory if it doesn't exist
  mkdir -p "$LOG_DIR"
  
  # Check for required tools
  log "INFO" "Checking required tools..."
  check_command "terraform"
  check_command "aws"
  check_command "gcloud"
  
  # Optional tools
  if ! command -v tfsec &> /dev/null; then
    log "WARNING" "tfsec not found - security scanning will be limited"
  fi
  
  if ! command -v checkov &> /dev/null; then
    log "WARNING" "checkov not found - security scanning will be limited"
  fi
  
  log "INFO" "Environment setup complete"
}

# ========================================================================
# Authentication
# ========================================================================

authenticate_aws() {
  log "INFO" "Authenticating with AWS using profile: $AWS_PROFILE"
  
  if [ -z "$AWS_PROFILE" ]; then
    log "ERROR" "AWS_PROFILE is not set"
    exit 1
  fi
  
  # Test AWS authentication
  aws sts get-caller-identity --profile "$AWS_PROFILE" > /dev/null 2>&1
  check_exit_status $? "AWS authentication"
  
  # Export for Terraform
  export AWS_PROFILE="$AWS_PROFILE"
  log "SUCCESS" "AWS authentication successful"
}

authenticate_gcp() {
  log "INFO" "Authenticating with Google Cloud Platform"
  
  if [ -z "$GCP_PROJECT_ID" ]; then
    log "WARNING" "GCP_PROJECT_ID is not set. Please enter your GCP Project ID:"
    read -r GCP_PROJECT_ID
    
    if [ -z "$GCP_PROJECT_ID" ]; then
      log "ERROR" "GCP Project ID is required"
      exit 1
    fi
  fi
  
  # Check if already authenticated
  if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | grep -q "@"; then
    log "INFO" "No active GCP authentication found, initiating login..."
    gcloud auth login
    check_exit_status $? "GCP authentication"
  else
    log "INFO" "Already authenticated with GCP"
  fi
  
  # Set the project
  gcloud config set project "$GCP_PROJECT_ID"
  check_exit_status $? "Setting GCP project"
  
  # Enable required APIs if not already enabled
  log "INFO" "Ensuring required GCP APIs are enabled..."
  gcloud services enable compute.googleapis.com container.googleapis.com sqladmin.googleapis.com --quiet
  
  log "SUCCESS" "GCP authentication successful"
}

# ========================================================================
# Terraform Operations
# ========================================================================

terraform_init() {
  log "INFO" "Initializing Terraform in directory: $TERRAFORM_DIR"
  
  if [ ! -d "$TERRAFORM_DIR" ]; then
    log "ERROR" "Terraform directory not found: $TERRAFORM_DIR"
    exit 1
  fi
  
  # Navigate to Terraform directory
  cd "$TERRAFORM_DIR"
  
  # Initialize Terraform
  terraform init -upgrade
  check_exit_status $? "Terraform initialization"
  
  log "SUCCESS" "Terraform initialization complete"
}

terraform_validate() {
  log "INFO" "Validating Terraform configuration"
  
  # Validate the configuration
  terraform validate
  check_exit_status $? "Terraform validation"
  
  log "SUCCESS" "Terraform validation passed"
}

terraform_fmt_check() {
  log "INFO" "Checking Terraform formatting"
  
  # Check formatting
  terraform fmt -check -recursive
  if [ $? -ne 0 ]; then
    log "WARNING" "Terraform files are not properly formatted"
    prompt_continue "Would you like to automatically format the files?"
    terraform fmt -recursive
    check_exit_status $? "Terraform formatting"
  else
    log "SUCCESS" "Terraform formatting check passed"
  fi
}

terraform_plan() {
  log "INFO" "Generating Terraform execution plan"
  
  # Create a plan file
  terraform plan -out=terraform.plan
  check_exit_status $? "Terraform plan generation"
  
  log "SUCCESS" "Terraform plan generated successfully"
}

terraform_security_scan() {
  log "INFO" "Running security scans on Terraform code"
  
  # Run tfsec if available
  if command -v tfsec &> /dev/null; then
    log "INFO" "Running tfsec scan..."
    tfsec . --no-color > "${LOG_DIR}/tfsec_results.txt" 2>&1 || true
    log "INFO" "tfsec scan results saved to ${LOG_DIR}/tfsec_results.txt"
    
    # Count issues
    local tfsec_count=$(grep -c "WARN" "${LOG_DIR}/tfsec_results.txt" || echo "0")
    if [ "$tfsec_count" -gt 0 ]; then
      log "WARNING" "tfsec found $tfsec_count potential security issues"
    else
      log "SUCCESS" "tfsec scan passed with no issues"
    fi
  fi
  
  # Run checkov if available
  if command -v checkov &> /dev/null; then
    log "INFO" "Running checkov scan..."
    checkov -d . --quiet --output-file-path "${LOG_DIR}" > /dev/null 2>&1 || true
    log "INFO" "checkov scan results saved to ${LOG_DIR}/results_json.json"
    
    # Count issues (simplified)
    if [ -f "${LOG_DIR}/results_json.json" ]; then
      local checkov_failed=$(grep -c "\"FAILED\"" "${LOG_DIR}/results_json.json" || echo "0")
      if [ "$checkov_failed" -gt 0 ]; then
        log "WARNING" "checkov found $checkov_failed potential security issues"
      else
        log "SUCCESS" "checkov scan passed with no issues"
      fi
    fi
  fi
  
  if ! command -v tfsec &> /dev/null && ! command -v checkov &> /dev/null; then
    log "WARNING" "No security scanning tools available. Consider installing tfsec or checkov."
  else
    prompt_continue "Security scan complete. Review the results in the log directory before continuing."
  fi
}

terraform_apply() {
  log "INFO" "Preparing to apply Terraform changes"
  
  # Show the plan summary
  terraform show terraform.plan
  
  # Ask for confirmation
  prompt_continue "The above changes will be applied to AWS and GCP. This may incur costs."
  
  # Apply the plan
  log "INFO" "Applying Terraform changes"
  terraform apply terraform.plan
  check_exit_status $? "Terraform apply"
  
  log "SUCCESS" "Infrastructure deployment completed successfully"
}

terraform_output() {
  log "INFO" "Retrieving infrastructure outputs"
  
  # Get and log the outputs
  terraform output -json > "${LOG_DIR}/terraform_outputs.json"
  check_exit_status $? "Terraform output capture"
  
  log "SUCCESS" "Infrastructure outputs saved to ${LOG_DIR}/terraform_outputs.json"
}

# ========================================================================
# Main Execution
# ========================================================================

main() {
  log "INFO" "Starting multi-cloud infrastructure deployment"
  log "INFO" "Deployment ID: $(basename "$LOG_FILE" .log)"
  
  # Setup environment
  setup
  
  # Authenticate with cloud providers
  authenticate_aws
  authenticate_gcp
  
  # Initialize and validate Terraform
  terraform_init
  terraform_validate
  terraform_fmt_check
  
  # Security scanning
  terraform_security_scan
  
  # Plan and deploy
  terraform_plan
  terraform_apply
  terraform_output
  
  log "SUCCESS" "Deployment completed successfully. Log saved to: $LOG_FILE"
  echo -e "\n${GREEN}Deployment completed successfully!${NC}"
  echo -e "Log file: $LOG_FILE"
  echo -e "Terraform outputs: ${LOG_DIR}/terraform_outputs.json"
}

# Run the script
main "$@"
  
  # Initialize and validate Terraform
  terraform_init
  terraform_validate
  terraform_fmt_check
  
  # Security scanning
  terraform_security_scan
  
  # Plan and deploy
  terraform_plan
  terraform_apply
  terraform_output
  
  log "SUCCESS" "Deployment completed successfully. Log saved to: $LOG_FILE"
  echo -e "\n${GREEN}Deployment completed successfully!${NC}"
  echo -e "Log file: $LOG_FILE"
  echo -e "Terraform outputs: ${LOG_DIR}/terraform_outputs.json"
}

# Run the script
main "$@"