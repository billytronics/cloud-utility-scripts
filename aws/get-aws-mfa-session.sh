#!/bin/sh
# Get a temporary session with MFA via the AWS CLI
#

# This is your MFA device ARN
MFA_SERIAL="arn:aws:iam::300326902600:mfa/billys_duo"

# Initializing global variables
DURATION=""
MFA_CODE=""
KEY_ID=""
SECRET_KEY=""
SESSION_TOKEN=""

# Get desired duration of session:
read -p "Enter length of session in seconds (3600 = an hour): " DURATION

# Get MFA one time code from user:
read -p "Enter MFA code for $MFA_SERIAL: " MFA_CODE

# Obtain temporary AWS session with MFA:
read -r KEY_ID \
        SECRET_KEY \
        SESSION_TOKEN \
  <<<$(aws sts get-session-token \
         --duration-seconds $DURATION \
         --serial-number $MFA_SERIAL \
         --token-code $MFA_CODE \
         --output text \
         --query 'Credentials.[AccessKeyId,SecretAccessKey,SessionToken]')
echo "\n Obtained temporary session with access key id: $KEY_ID"

# Output the temporary session keys to a file:
cat <<EOT > aws_session.out
export AWS_ACCESS_KEY_ID=$KEY_ID
export AWS_SECRET_ACCESS_KEY=$SECRET_KEY
export AWS_SESSION_TOKEN=$SESSION_TOKEN
EOT

# We are done, enjoy the new session...
echo "\n Source the output file by running \"source aws_session.out\" and you're ready to go..." 
exit 0
