# Red team interview framework

This is the red team interview scenario framework as prepared for
Cisco's Offensive Summit 2020.

The demo scenario consists of a kali jumphost and two simulated
corporate machines.

## Initial setup

You will need Terraform, Packer, and an AWS account.

Copy `.env.example` to `.env` and enter your
details. You can leave TF_VAR_candidate_key empty for testing. When
conducting an interview, this should be the candidate's ssh public key.

Your AWS account must be subscribed to the [kali ami](https://aws.amazon.com/marketplace/pp/B01M26MMTT).

Build the custom kali AMI:

```
cd build/kali
packer build kali.json
```

Enter the resulting AMI ID in TF_VAR_kali_ami in .env.

Before the interview, the interviewer runs `./launch.sh`. This will
create a VPC containing an isolated instance of the interview infrastructure.
It is recommended to create two independent instances, in separate availability
zones. Note that it may take a minute or two from when the launch finishes before the
environment is ready.

## Usage

Each invocation of `launch.sh` creates an independent copy of the
interview infrastructure identified by a UUID.
```
./launch.sh
./connect.sh <session uuid> <host identifier>
```

For example,
```
./launch.sh
./connect.sh 98b7467e-204e-4a73-9476-9d412a7d8c5a kali
```

Host configuration can take a while, so if launch.sh succeeds but you
get ssh failures, just try waiting a few minutes.

To delete a copy of the infrastructure,

```
./destroy.sh <session uuid>
```
