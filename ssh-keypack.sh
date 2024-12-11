#!/bin/bash

# Exit on non-zero exit codes.
set -e

Help() {
    # Display Help
    echo "Add description of the script functions here."
    echo
    echo "Syntax: ssh-keypack <algorithm> <user> <host> <git-username> <git-repository> [-h]"
    echo "Options:"
    echo "algorithm      Algorithm string passed to ssh-keygen."
    echo "user           Username associated with this SSH key pair."
    echo "host           Hostname associated with this SSH key pair"
    echo "git-username   (Optional) Owner of the Git repository associated with this SSH key pair."
    echo "git-repository (Optional) Name of the Git repository associated with this SSH key pair."
    echo "-h             (Optional) Display this help text and quit."
    echo
}

Generate() {
    algorithm=${1}
    name=-${2}
    host=@${3}
    timestamp=$(date +%s)
    filename=${algorithm}-key-${timestamp}${name}${host}
    comment=${filename}

    if [[ -n "${4}" && -n "${5}" ]]; then
        comment=${filename}:${4}/${5}
        filename=${filename}:${4}+${5}
    elif [[ -n "${4}" ]]; then
        comment=${filename}:${4}
        filename=${filename}:${4}
    fi

    # Generate a key pair with the specified algorithm
    ssh-keygen \
        -a 100 \
        -t ${algorithm} \
        -C ${comment} \
        -f ${filename} \
        -N "" \
        -q

    # Apply more restrictive permissions
    chmod 600 ${filename}
    chmod 644 ${filename}.pub

    # Rename the private and public keys
    mv ${filename} ${filename}.ospk
    mv ${filename}.pub ${filename}.ospubk

    # Compute the hash for the private key
    ssh-keygen -lf ${filename}.ospk | tee ${filename}.sha256 >/dev/null

    # Print the public key to console
    printf "Generated public key:\n$(cat ${filename}.ospubk)\n"

    # Create an archive to store the keys and their checksum. Here we temporarily create a timestamped archive as the ":" character can wreak havok when using tar.
    tar -czf "${timestamp}.tar.gz" \
        "${filename}.ospk" \
        "${filename}.ospubk" \
        "${filename}.sha256"
    mv ${timestamp}.tar.gz ${filename}.tar.gz

    rm \
      ${filename}.ospk \
      ${filename}.ospubk \
      ${filename}.sha256
}

while getopts ":gh" option; do
    case $option in
    g) # Generate an SSH key pair archive.
        Generate ${@:2}
        exit
        ;;
    h) # Display the help text.
        Help
        exit
        ;;
    \?) # Quit on invalid option.
        echo "Error: Invalid option"
        exit
        ;;
    esac
done
