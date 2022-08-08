# Terraform for F5XC MCN 3rd Party IPSec

This repository consists of Terraform file to bring up:

- GCP public cloud site
- AWS public cloud site
- Global L3 network connecting AWS and GCP site
- IPSec VPN connection pointing to 3rd party gateway
- BGP Routing between CE and 3rd party

Each site type has its own set of input data and can be deployed independently of each other. More information about
input data can be found in chapter [Prepare Terraform](#prepare-terraform).

## Requirements
---------------

- [Terraform](https://www.terraform.io/downloads.html) >= 1.2.3
- [AWS-Authenaticator](https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.htmlaws-authenticator) >
  = 0.5.7.

## Prepare environment
----------------------

### Clone repository

- Clone this repo with: `git clone --recurse-submodules https://github.com/cklewar/f5-xc-mcn-ipsec`
- Enter repository directory with: `cd f5-xc-mcn-ipsec`

### F5XC Multi Cloud Use Case

Generate F5XC API certificate and token by following below steps:

- Login to F5XC Console using you provided credentials
- Navigate to users account settings by pressing user icon in upper right corner and choose __Account Settings__ -->
  __Personal Management__ --> __Credentials__
- Create API certificate by pressing __Add credentials__ button
- Choose __API Certificate__ from available options and set a name and expiry date. Cert file access will be protected
  by password
- We will need the password later to gain access to cert file hence store password
- Cert will be generated and downloaded automatically
- Store __API Certificate__ P12 file in the root of repository
- Create API token by pressing __Add credentials__ button
- Choose __API Token__ from available options and set a name and expiry date. Token will shown after creation. Save
  token for later use

![F5XC_credentials](https://github.com/cklewar/f5-xc-mcn-ipsec/blob/main/pictures/volterra_credentials.png "Create F5XC API credentials")

### AWS

Obtain AWS credentials from AWS Console. Mandatory items are __access key__ and __secret key__.

````bash
Access: abcdef
Secret: ghijkl
console creds: user/passsword
Account ID: xyz
AWS: console.aws.com
````

### GCP

- [Create GCP service account in GCP Console](https://cloud.google.com/iam/docs/creating-managing-service-accounts)
- Download credentials in JSON format and save file into root of repository

## Prepare Terraform
--------------------

### Input data

Terraform input data is kept on a per site type basis. To change input data edit `sample.tfvars.json` in respective
directory. Directories of interest are `gcp` and `aws`.

````bash
.
├── aws
├── gcp
├── modules
└── pictures
````

### AWS input data

This section describes Terraform input data for AWS public cloud site.

- `project_prefix`          : String prepend to name
- `project_sufix`           : String append to name
- `access_key`              : AWS access key
- `secret_key`              : AWS secret key
- `deployment`              : F5XC site deployment name
- `tenant`                  : F5XC tenant
- `region`                  : AWS region
- `cluster_latitude`        : F5XC CE node latitude
- `cluster_longitude`       : F5XC CE node longitude
- `fabric_address_pool`     : AWS IP supernet
- `fabric_subnet_private`   : AWS private IP subnet
- `fabric_subnet_inside`    : AWS inside IP subnet
- `fleet_label`             : F5XC Fleet Label
- `tunnel_clear_secret`     : 3rd party IPSec tunnel PSK
- `tunnel_remote_ip_address`: 3rd party IPSec tunnel remote gateway IP
- `tunnel_interface_static_ip`: 3rd party IPSec tunnel interface static IP
- `tunnel_virtual_network_ip_prefixes`: List of IP prefixes routed into 3rd party IPSec tunnel
- `global_virtual_network`: F5XC global virtual network name
- `api_p12_file`: F5XC API P12 file
- `api_url`: F5XC API URL
- `api_token`: F5XC API token
- `machine_public_key`: Public SSH keys for e.g. AWS / GCP instances
- `aws_iam_authenticator_bin_path`: AWS IAM Authenticator binary location

It is mandatory to set `aws_iam_authenticator_bin_path` correctly.

### AWS Terraform example input data

````json
{
  "project_prefix": "aws",
  "project_suffix": "01",
  "access_key": "",
  "secret_key": "",
  "iam_owner": "c.klewar@f5.com",
  "tenant": "xyz-ydghbxyc",
  "namespace": "system",
  "region": "us-east-2",
  "cluster_latitude": "28.6448",
  "cluster_longitude": "77.2167",
  "fabric_address_pool": "192.168.32.0/22",
  "fabric_subnet_private": "192.168.32.0/25",
  "fabric_subnet_inside": "192.168.32.128/25",
  "fleet_label": "fleetaws01",
  "tunnel_clear_secret": "abcdefg123456789",
  "tunnel_remote_ip_address": "192.168.2.3",
  "tunnel_interface_static_ip": "172.16.28.1/24",
  "tunnel_virtual_network_ip_prefixes": [
    "10.128.1.0/24",
    "169.254.186.2/32"
  ],
  "api_p12_file": "xyz.console.ves.volterra.io.api-creds.p12",
  "api_url": "https://xyz.console.ves.volterra.io/api",
  "api_token": "",
  "machine_public_key": "",
  "aws_iam_authenticator_bin_path": "/opt/homebrew/bin/aws-iam-authenticator",
  "bgp_local_asn": 65200,
  "bgp_peer_asn": 65000,
  "bgp_peer_address": "169.254.186.2"
}
````

### GCP input data

This section describes Terraform input data for GCP public cloud site.

- `project_prefix`            : String prepend to name
- `project_sufix`             : String append to name
- `tenant`                    : F5XC tenant
- `region`                    : AWS region
- `zone`                      : GCP availability zone
- `cluster_latitude`          : F5XC CE node latitude
- `cluster_longitude`         : F5XC CE node longitude
- `fabric_subnet_public`      : GCP public subnet
- `fabric_subnet_inside`      : GCP inside subnet
- `gcp_credentials_file_path` : AWS IP supernet
- `gcp_project_name`          : GCP project name
- `fleet_label`               : F5XC Fleet Label
- `tunnel_clear_secret`       : 3rd party IPSec tunnel PSK
- `tunnel_remote_ip_address`  : 3rd party IPSec tunnel remote gateway IP
- `tunnel_interface_static_ip`: 3rd party IPSec tunnel interface static IP
- `tunnel_virtual_network_ip_prefixes`: List of IP prefixes routed into 3rd party IPSec tunnel
- `api_p12_file`                      : F5XC API P12 file
- `api_url`                           : F5XC API URL
- `api_token`                         : F5XC API token
- `machine_public_key`                : Public SSH keys for e.g. AWS / GCP instances

```json
{
  "project_prefix": "gcp",
  "project_suffix": "01",
  "api_p12_file": "xyz.console.ves.volterra.io.api-creds.p12",
  "api_url": "https://cyz.console.ves.volterra.io/api",
  "api_token": "",
  "tenant": "xyz-ydghbxyc",
  "namespace": "system",
  "fleet_label": "fleetgcp02",
  "region": "us-west2",
  "zone": "us-west2-a",
  "cluster_latitude": "39.8282",
  "cluster_longitude": "-98.5795",
  "fabric_subnet_public": "192.168.0.0/25",
  "fabric_subnet_inside": "192.168.0.128/25",
  "machine_public_key": "",
  "gcp_credentials_file_path": "gcp_creds.json",
  "gcp_project_name": "",
  "tunnel_clear_secret": "abcdefg123456789",
  "tunnel_remote_ip_address": "192.168.2.3",
  "tunnel_interface_static_ip": "172.16.28.2/24",
  "tunnel_virtual_network_ip_prefixes": [
    "10.128.1.0/24",
    "169.254.186.3/32"
  ],
  "bgp_local_asn": 65200,
  "bgp_peer_asn": 65000,
  "bgp_peer_address": "169.254.186.3"
}
```

## AWS site operations
----------------------

Change into directory `aws`. If this is the first time than
run [`terraform init`](https://www.terraform.io/docs/commands/init.html) and terraform will automatically install all
needed providers.

Before any operation can take place the F5XC API cert access password need to be set as environment variable:

````bash
export VES_P12_PASSWORD=<Password defined during generation>
````

### Apply AWS site

Run terraform apply command as shown below. The process will take approximately 10 minutes.

```bash
$ terraform apply -auto-approve --var-file=./sample.tfvars.json
```

Example output after successful creation:

````bash
Apply complete! Resources: 13 added, 0 changed, 0 destroyed.

Outputs:

device_name = "ip-192-168-32-4"
fabric_network = "192.168.32.0/22"
fabric_subnet_private = "192.168.32.0/25"
fabric_subnet_private_id = "subnet-0b7e8c6c5d4f24991"
inside_ip_address = "192.168.32.229"
private_ip_address = "192.168.32.4"
public_ip_address = "13.59.36.86"
````

### Destroy AWS site

```bash
$ terraform destroy -auto-approve --var-file=./sample.tfvars.json
```

## GCP site operations
----------------------
Change into directory `gcp`. If this is the first time than
run [`terraform init`](https://www.terraform.io/docs/commands/init.html) and terraform will automatically install all
needed providers.

Before any operation can take place the F5XC API cert access password need to be set as environment variable:

````bash
export VES_P12_PASSWORD=<Password defined during generation>
````

### Apply GCP site

Run terraform apply command as shown below. The process will take approximately 10 minutes.

```bash
$ terraform apply -auto-approve --var-file=./sample.tfvars.json
```

Example output after successful creation:

````bash
Apply complete! Resources: 21 added, 0 changed, 0 destroyed.

Outputs:

private_ip_address = "192.168.0.2"
public_ip_address = "35.235.124.88"
sli_network = "gcp-02-sli-vpc-network"
sli_subnetwork = "gcp-02-sli-subnetwork"
slo_network = "gcp-02-slo-vpc-network"
slo_subnetwork = "gcp-02-slo-subnetwork"
````

### Destroy GCP site

```bash
$ terraform destroy -auto-approve --var-file=./sample.tfvars.json
```

## 3rd Party Gateway JNPR SRX
-----------------------------

### Tunnel Interface

```bash
st0 {
    unit 0 {
        multipoint;
        family inet {
            next-hop-tunnel 10.15.250.2 ipsec-vpn aws;
            address 10.15.250.1/24;
        }
    }
}
```

### IPSec Configuration

AWS / GCP site IPSec gateway address is derived from Terraform output parameter `public_ip_address`.

```bash
ike {
    proposal aws {
        authentication-method pre-shared-keys;
        authentication-algorithm sha-256;
        encryption-algorithm aes-192-cbc;
    }
    policy aws {
        mode main;
        proposals aws;
        pre-shared-key ascii-text "$9$ZbUDkmPQn6A.mO1hcleoJZUqmFn/OIEpudbsY4o"; ## SECRET-DATA
    }
    gateway aws {
        ike-policy aws;
        address 18.195.92.148;
        local-identity inet 80.136.116.119;
        remote-identity inet 10.100.1.55;
        external-interface ge-0/0/0;
    }
}
ipsec {
    proposal aws {
        protocol esp;
        authentication-algorithm hmac-sha1-96;
        encryption-algorithm aes-256-cbc;
        lifetime-seconds 7200;
        lifetime-kilobytes 102400000;
    }
    policy aws {
        proposals aws;
    }
    vpn aws {
        bind-interface st0.0;
        ike {
            gateway aws;
            ipsec-policy aws;
        }
        establish-tunnels immediately;
    }
}
```

### BGP Configuration

BGP neighbor is derived from Terraform output parameter `private_ip_address`.

````bash
group aws {
    type external;
    multihop {
        ttl 15;
    }
    local-address 10.15.250.1;
    peer-as 65200;
    local-as 65000;
    multipath;
    allow 0.0.0.0/0;
    neighbor 192.168.32.4 {
        multihop {
            ttl 15;
        }
        local-address 10.15.250.1;
        peer-as 65200;
        local-as 65000;
        multipath;
    }
}
````

### Routing

#### AWS

Static routing towards AWS site needs manual adjustment. Below example Terraform output shows `private_ip_address` parameter.
This IP is CEs SLO interface and a static route needs to be added pointing into according IPSec tunnel.

```bash
Outputs:

device_name = "ip-192-168-32-4"
fabric_network = "192.168.32.0/22"
fabric_subnet_private = "192.168.32.0/25"
fabric_subnet_private_id = "subnet-0b7e8c6c5d4f24991"
inside_ip_address = "192.168.32.229"
private_ip_address = "192.168.32.4"
public_ip_address = "13.59.36.86"
```

```bash
routing-options {
    static {
        route 0.0.0.0/0 next-hop 192.168.2.1;
        route 192.168.32.4/32 next-hop 10.15.250.2;
    }
    router-id 10.15.250.1;
    autonomous-system 65000;
}
```

#### GCP

Static routing towards GCP site needs manual adjustment. Below example Terraform output shows `private_ip_address` parameter.
This IP is CEs SLO interface and a static route needs to be added pointing into according IPSec tunnel.

````bash
Outputs:

private_ip_address = "192.168.0.2"
public_ip_address = "35.235.124.88"
sli_network = "gcp-02-sli-vpc-network"
sli_subnetwork = "gcp-02-sli-subnetwork"
slo_network = "gcp-02-slo-vpc-network"
slo_subnetwork = "gcp-02-slo-subnetwork"
````

```bash
routing-options {
    static {
        route 0.0.0.0/0 next-hop 192.168.2.1;
        route 192.168.0.2/32 next-hop 10.15.250.2;
    }
    router-id 10.15.250.1;
    autonomous-system 65000;
}
```