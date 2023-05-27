#!/bin/bash

#######################################
# subnet-divider.sh - Divide IP ranges into smaller-sized subnets
#######################################

# Author:
# Rahgozar
# rahgozar94725@proton.me
# https://github.com/rahgozar94725/Subnet-Divider

#######################################

# Define colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Help message with colors
help_message() {
    echo -e "${GREEN}Usage:${NC} $0 ${YELLOW}[-i|--input] <IP_RANGE_OR_FILE> [-o|--output <OUTPUT_FILE>] [-s|--subnet <SUBNET_BITS>] [-l|--lines <MAX_LINES>]${NC}"
    echo -e "${GREEN}Example:${NC} $0 ${YELLOW}-i 192.168.0.0/16${NC}"
    echo -e "${GREEN}Example:${NC} $0 ${YELLOW}--input ip_ranges.txt --output output.txt --subnet 16 --lines 1000${NC}"
}

# Validate if input is a valid IP range
validate_ip_range() {
    local ip_range=$1

    if [[ $ip_range =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/[0-9]+$ ]]; then
        return 0
    else
        return 1
    fi
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
    -i | --input)
        input=$2
        shift 2
        ;;
    -o | --output)
        output_file=$2
        shift 2
        ;;
    -s | --subnet)
        subnet_bits=$2
        shift 2
        ;;
    -l | --lines)
        max_lines=$2
        shift 2
        ;;
    *)
        echo -e "${RED}Error: Invalid arguments.${NC}"
        help_message
        exit 1
        ;;
    esac
done

# Check if required options are provided
if [[ -z $input ]]; then
    echo -e "${RED}Error: Missing input argument.${NC}"
    help_message
    exit 1
fi

# Set default subnet_bits to 24 if not provided
if [[ -z $subnet_bits ]]; then
    subnet_bits=24
fi

# Validate input as IP range or file
if [[ -f $input ]]; then
    # Check if the file is empty
    if [[ ! -s $input ]]; then
        echo -e "${RED}Error: File '$input' is empty.${NC}"
        exit 1
    fi
    # Extract filename from input and add subnet_bits as suffix
    if [[ -z $output_file ]]; then
        filename="${input%.*}_${subnet_bits}.txt"
        output_file="$filename"
    fi
else
    # Validate if input is a valid IP range
    if ! validate_ip_range "$input"; then
        echo -e "${RED}Error: Invalid IP range '$input'.${NC}"
        exit 1
    fi

    # Generate default output filename from input and subnet_bits
    if [[ -z $output_file ]]; then
        IFS='/' read -r -a ip_parts <<<"$input"
        base_ip=${ip_parts[0]}
        filename="${base_ip}_${subnet_bits}.txt"
        output_file="$filename"
    fi
fi

# Function to divide IP range into user-specified subnets or add the same subnet if larger than user input
divide_ip_range() {
    local ip_range=$1
    local subnet_bits=$2

    # Check if the subnet is valid
    if [[ $subnet_bits -lt 1 || $subnet_bits -gt 32 ]]; then
        echo -e "${RED}Error: Invalid subnet size. Subnet size should be between 1 and 32.${NC}"
        return
    fi

    # Parse the input IP range
    local base_ip=$(echo "$ip_range" | cut -d '/' -f 1)
    local subnet_mask=$(echo "$ip_range" | cut -d '/' -f 2)

    # Check if the subnet is larger than user input
    if [[ $subnet_mask -gt $subnet_bits ]]; then
        echo "$ip_range"
        return
    fi

    # Calculate the number of subnets needed
    local num_subnets=$((2 ** (subnet_bits - subnet_mask)))

    # Convert the base IP to decimal
    IFS='.' read -r i1 i2 i3 i4 <<<"$base_ip"
    local base_decimal=$(((i1 << 24) + (i2 << 16) + (i3 << 8) + i4))

    # Divide the IP range into user-specified subnets
    for ((i = 0; i < num_subnets; i++)); do
        local subnet_decimal=$((base_decimal + (i << (32 - subnet_bits))))

        # Convert decimal subnet IP back to dotted-decimal format
        local subnet_ip=$(printf "%d.%d.%d.%d" $((subnet_decimal >> 24 & 255)) $((subnet_decimal >> 16 & 255)) $((subnet_decimal >> 8 & 255)) $((subnet_decimal & 255)))

        local subnet="${subnet_ip}/$subnet_bits"
        echo "$subnet"
    done
}

# Check if the output_file already exists
if [[ -f $output_file ]]; then
    echo -e "${YELLOW}Warning: Output file '$output_file' already exists.${NC}"
    read -rp "Do you want to overwrite it? [y/N] (default: Rename with timestamp suffix): " overwrite

    if [[ "${overwrite^^}" == "Y" ]]; then
        # Overwrite the existing file
        echo -e "${YELLOW}Output file will be overwritten.${NC}"
    else
        # Add date and time suffix to the filename
        timestamp=$(date +"%Y%m%d%H%M%S")
        filename="${output_file%.*}_${timestamp}.txt"
        echo -e "${YELLOW}Output will be written to '$filename'.${NC}"
        output_file=$filename
    fi
fi

# Check if the input is a file
if [[ -f $input ]]; then
    # Read each line from the file and store unique subnets in an array
    mapfile -t subnets < <(cat "$input" | while IFS= read -r line; do divide_ip_range "$line" "$subnet_bits"; done)
else
    # Treat the input as a single IP range
    mapfile -t subnets < <(divide_ip_range "$input" "$subnet_bits")
fi

# Write the unique subnets to the output file (sorted numerically)
printf "%s\n" "${subnets[@]}" | sort -u -V >"$output_file"

echo -e "${GREEN}Subnets divided and written to ${YELLOW}$output_file${NC}"

# Split the output file if the max_lines option is provided
if [[ $max_lines -gt 0 ]]; then
    # Count the number of lines in the output file
    line_count=$(wc -l <"$output_file")

    # Calculate the number of files that will be created
    num_files=$((line_count / max_lines))
    if [[ $((line_count % max_lines)) -ne 0 ]]; then
        num_files=$((num_files + 1))
    fi

    # Calculate the number of digits in the file count
    count_digits=${#num_files}

    # Create a directory based on the output_file name (without extension)
    directory_name="${output_file%.*}"
    if [[ -d "$directory_name" ]]; then
        rm -rf "$directory_name"
    fi
    mkdir "$directory_name"

    # Split the output file into multiple files with maximum lines and move them to the directory
    split_files_prefix="${directory_name}/part"
    split -d -l "$max_lines" -a "$count_digits" "$output_file" "$split_files_prefix" --additional-suffix=".txt"

    if [[ $? -eq 0 ]]; then
        if [[ $num_files -gt 1 ]]; then
            echo -e "${GREEN}Output file split into ${YELLOW}${num_files}${GREEN} files in the directory '${directory_name}'.${NC}"
        else
            echo -e "${GREEN}Output file split into ${YELLOW}${num_files}${GREEN} file in the directory '${directory_name}'.${NC}"
        fi
    else
        echo -e "${RED}Error: Failed to split the output file.${NC}"
    fi
fi
