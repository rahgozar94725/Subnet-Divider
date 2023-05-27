# Subnet Divider

Subnet Divider is a bash script that helps you divide IP ranges into smaller-sized subnets. This script accepts either an IP range or a file containing multiple IP ranges as input and creates a list of mutually exclusive subnets based on the user-specified subnet size. It supports IPv4 with CIDR range notation.

## Features

- Divides IP ranges into subnets
- Supports both single IP ranges and an input file containing IP ranges split by new lines
- User-specified subnet size
- Outputs subnets into a file
- Combines previous outputs by removing duplicate ranges and sorting them all together
- [Optional] Split the output file into multiple files based on a user-specified maximum number of lines per file

## Installation

1. Clone the repository:

```bash
git clone https://github.com/rahgozar94725/Subnet-Divider.git
```

2. Navigate to the repository directory:

```bash
cd Subnet-Divider
```

3. Make the script executable:

```bash
chmod +x subnet-divider.sh
```

## Usage

```bash
./subnet-divider.sh -i <IP_RANGE_OR_FILE> [--output <OUTPUT_FILE>] [--subnet <SUBNET_BITS>] [--lines <MAX_LINES>]
```

- `-i <IP_RANGE_OR_FILE>`, `--input <IP_RANGE_OR_FILE>`: IP range or a file containing IP ranges.
- `-o <OUTPUT_FILE>`, `--output <OUTPUT_FILE>` (optional): The output file name [Default: Based on input file name]
- `-s <SUBNET_BITS>`, `--subnet <SUBNET_BITS>` (optional): Target subnet size in bits. [Default: 24]
- `-l <MAX_LINES>`, `--lines <MAX_LINES>` (optional): Maximum lines per file for splitting the output. [Default: No splitting]

## Examples

Divide a single IP range:

```bash
./subnet-divider.sh -i 192.168.0.0/16
```

Extract IP ranges from a file, designate an output file, specify the desired subnet size, and divide the resulting output into multiple files, each containing 1000 lines:

```bash
./subnet-divider.sh --input ip_ranges.txt --output output.txt --subnet 16 --lines 100
```

## Support

### Give a Star

If you find this script useful, please consider giving it a star on GitHub. It boosts the project's visibility and encourages further development.

### Donation

If you find this script helpful and would like to support its development and maintenance, you can donate using the cryptocurrencies:

<a href="https://nowpayments.io/donation?api_key=K2CZ4C9-PJ8MDMZ-NR36PRM-JCTVGCQ&source=lk_donation&medium=referral" target="DOGE">
<img src="https://nowpayments.io/images/embeds/donation-button-black.svg" alt="Crypto donation button by NOWPayments">
</a>

Your donations will be greatly appreciated (But not required) and will contribute to this project's ongoing improvement and support.

![Custom badge](https://img.shields.io/endpoint?style=social&url=https%3A%2F%2Fhits.dwyl.com%2F9f28b8b5-e9b2-384b-a376-663df3357d92%2Ff1ed8149-2299-335c-bd30-7754f87bed7b.json)
