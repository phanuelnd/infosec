#!/bin/bash

# Setup script for BLP, Biba, and BMA security models
# This script creates the necessary directory structure, user accounts, and implements security policies

# Function to create user accounts with different security clearances
create_users() {
    # BLP/Biba Users
    sudo useradd -m -s /bin/bash user_topsecret
    sudo useradd -m -s /bin/bash user_secret
    sudo useradd -m -s /bin/bash user_confidential
    sudo useradd -m -s /bin/bash user_unclassified
    
    # BMA Users
    sudo useradd -m -s /bin/bash user_high
    sudo useradd -m -s /bin/bash user_medium
    sudo useradd -m -s /bin/bash user_low
    
    # Set passwords
    echo "user_topsecret:topsecret123" | sudo chpasswd
    echo "user_secret:secret123" | sudo chpasswd
    echo "user_confidential:confidential123" | sudo chpasswd
    echo "user_unclassified:unclassified123" | sudo chpasswd
    echo "user_high:high123" | sudo chpasswd
    echo "user_medium:medium123" | sudo chpasswd
    echo "user_low:low123" | sudo chpasswd
}

# Function to create directory structure
create_directories() {
    # BLP/Biba directories
    sudo mkdir -p /secure_share/{topsecret,secret,confidential,unclassified}
    
    # BMA directories
    sudo mkdir -p /integrity_share/{high,medium,low}
    
    # Set base permissions
    sudo chmod 755 /secure_share /integrity_share
}

# Function to set BLP security policies
implement_blp() {
    # Top Secret directory
    sudo chown user_topsecret:user_topsecret /secure_share/topsecret
    sudo chmod 700 /secure_share/topsecret
    
    # Secret directory
    sudo chown user_secret:user_secret /secure_share/secret
    sudo chmod 750 /secure_share/secret
    
    # Confidential directory
    sudo chown user_confidential:user_confidential /secure_share/confidential
    sudo chmod 750 /secure_share/confidential
    
    # Unclassified directory
    sudo chown user_unclassified:user_unclassified /secure_share/unclassified
    sudo chmod 755 /secure_share/unclassified
    
    # Create security groups
    sudo groupadd topsecret_group
    sudo groupadd secret_group
    sudo groupadd confidential_group
    
    # Add users to appropriate groups (implementing No Read Up)
    sudo usermod -a -G topsecret_group user_topsecret
    sudo usermod -a -G secret_group user_topsecret user_secret
    sudo usermod -a -G confidential_group user_topsecret user_secret user_confidential
}

# Function to set Biba integrity policies
implement_biba() {
    # Set integrity levels using ACLs
    sudo setfacl -m g:topsecret_group:rx /secure_share/topsecret
    sudo setfacl -m g:secret_group:rx /secure_share/secret
    sudo setfacl -m g:confidential_group:rx /secure_share/confidential
    
    # Implement No Write Down
    sudo setfacl -m g:topsecret_group:w /secure_share/topsecret
    sudo setfacl -m g:secret_group:w /secure_share/secret
    sudo setfacl -m g:confidential_group:w /secure_share/confidential
}

# Function to implement BMA (Chinese Wall) policies
implement_bma() {
    # High integrity directory
    sudo chown user_high:user_high /integrity_share/high
    sudo chmod 700 /integrity_share/high
    
    # Medium integrity directory
    sudo chown user_medium:user_medium /integrity_share/medium
    sudo chmod 750 /integrity_share/medium
    
    # Low integrity directory
    sudo chown user_low:user_low /integrity_share/low
    sudo chmod 770 /integrity_share/low
    
    # Create integrity groups
    sudo groupadd high_integrity
    sudo groupadd medium_integrity
    sudo groupadd low_integrity
    
    # Implement integrity-based access control
    sudo usermod -a -G high_integrity user_high
    sudo usermod -a -G medium_integrity user_high user_medium
    sudo usermod -a -G low_integrity user_high user_medium user_low
}

# Main execution
echo "Setting up secure file sharing system..."
create_users
create_directories
implement_blp
implement_biba
implement_bma

echo "Setup complete!"

# Test script
#!/bin/bash

test_access() {
    echo "Testing BLP/Biba access controls..."
    
    # Test No Read Up
    sudo -u user_confidential cat /secure_share/secret/test.txt
    
    # Test No Write Down
    sudo -u user_topsecret touch /secure_share/confidential/test.txt
    
    # Test BMA integrity
    sudo -u user_low touch /integrity_share/high/test.txt
    
    echo "Access control tests completed."
}