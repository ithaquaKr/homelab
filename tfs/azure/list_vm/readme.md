# Azure VM Infrastructure - Setup and Troubleshooting Guide

- This terraform code use to create a list of virtual machine with lowest cost Azure Cloud.
- This code will generate one Jumpbox, 3 VM

## Quick Start

1. **Deploy Infrastructure:**

   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

2. **Connect to Jumpbox:**

   ```bash
   # Use SSH agent forwarding (recommended)
   ssh -A azureuser@<jumpbox_public_ip>

   # Or use the output command from Terraform
   ```

3. **From Jumpbox, connect to private VMs:**

   ```bash
   # The private key is automatically set up
   ssh azureuser@<private_vm_ip>
   ```

## Verification Commands

### On Jumpbox

```bash
# Test internet connectivity
curl -I https://www.google.com

# Check network configuration
ip addr show
ip route show

# View helper script
./connect.sh

# Check initialization logs
cat /tmp/internet-test.log
cat /tmp/network-info.log

# List available functions
vm_ips
test_internet
```

### SSH to Private VMs

```bash
# From jumpbox, connect to private VMs
ssh azureuser@10.0.1.4   # Example IP
ssh azureuser@10.0.1.5   # Example IP
ssh azureuser@10.0.1.6   # Example IP
```

### From Private VMs

```bash
# Test internet access through NAT Gateway
curl -I https://www.google.com

# Check what IP you're using for outbound traffic
curl -s ifconfig.me  # Should show NAT Gateway public IP
```

## File Structure

```
.
├── main.tf                 # Main Terraform configuration
├── variables.tf           # Variable definitions
├── outputs.tf            # Output values
├── terraform.tfvars      # Your custom values (create from example)
├── terraform.tfvars.example  # Example values
├── ssh-init.sh       # Jumpbox SSH initialization script
└── README.md            # This file
```

## Network Architecture

```
Internet
    │
    ├── Jumpbox (Public IP) ──────────┐
    │                                 │
    └── NAT Gateway (Public IP)       │
            │                         │
            │                         │
    ┌───────▼─────────────────────────▼───────┐
    │           Subnet (10.0.1.0/24)          │
    │  ┌─────────┐  ┌─────────┐  ┌─────────┐  │
    │  │VM-Linux1│  │VM-Linux2│  │VM-Linux3│  │
    │  │(Private)│  │(Private)│  │(Private)│  │
    │  └─────────┘  └─────────┘  └─────────┘  │
    └─────────────────────────────────────────┘
```

## Troubleshooting

### SSH Issues

1. Verify SSH key permissions: `ls -la ~/.ssh/`
2. Test SSH agent: `ssh-add -l`
3. Use verbose SSH: `ssh -v azureuser@<ip>`

### Network Issues

1. Check NSG rules in Azure portal
2. Verify NAT Gateway association
3. Test DNS resolution: `nslookup google.com`

### VM Issues

1. Check VM status in Azure portal
2. View serial console for boot issues
3. Verify Spot instance hasn't been evicted
