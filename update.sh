#!/bin/bash
# Update the system
yum update -y

# Install Apache web server
yum install -y httpd

# Start Apache and enable it to start on boot
systemctl start httpd
systemctl enable httpd

# Get instance ID using instance metadata service
# Get the instance ID using the instance metadata
INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token: $(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")" -s http://169.254.169.254/latest/meta-data/instance-id)
echo "Instance ID is: $INSTANCE_ID"
# Create a simple web page
cat <<EOF > /var/www/html/index.html
<html>
  <body>
    <h1>Hello from EC2 Instance 1</h1>
    <h2>Instance ID: $INSTANCE_ID </h2> 
  </body>
</html>
EOF