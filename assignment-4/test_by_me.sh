#!/bin/bash

# All files exist and make successfully creates signtool that is executable. (1 pt)
make
if [ ! -f "signtool" ]; then
    echo "signtool not exists"; exit
fi
if [ ! -f "bypass-licensechk-signed" ]; then
    echo "bypass-licensechk-signed not exists"; exit
fi


# Preperation
rm -rf *.pem
openssl genrsa -out private_key1.pem 2048
openssl rsa -in private_key1.pem -out public_key1.pem -pubout
openssl genrsa -out private_key2.pem 2048
openssl rsa -in private_key2.pem -out public_key2.pem -pubout

echo "#include <stdio.h>
int main(){
    printf(\"Hello Information Security!\n\");
}" > test-elf.c 
gcc test-elf.c -o test-elf 

echo -e "\n###TESTING###\n"

if [[ OK == $(./signtool sign -e test-elf -k private_key1.pem -o test-elf-signed) ]]; then echo "pass"; else echo "fail"; fi
if [[ OK == $(./signtool verify -e test-elf-signed -k public_key1.pem) ]]; then echo "pass"; else echo "fail"; fi


# Error handling according to the spec. (1 pt)
if [[ INVALID_FILE == $(./signtool sign -e invalid-file -k private_key1.pem -o test-elf-signed) ]]; then echo "pass"; else echo "fail"; fi
if [[ INVALID_KEY == $(./signtool sign -e test-elf -k invalid_key.pem -o test-elf-signed) ]]; then echo "pass"; else echo "fail"; fi
if [[ INVALID_KEY == $(./signtool sign -e test-elf -k public_key1.pem -o test-elf-signed) ]]; then echo "pass"; else echo "fail"; fi
if [[ NOT_SIGNED == $(./signtool verify -e test-elf -k public_key1.pem) ]]; then echo "pass"; else echo "fail"; fi
if [[ INVALID_KEY == $(./signtool verify -e test-elf-signed -k private_key1.pem) ]]; then echo "pass"; else echo "fail"; fi

# A new .signature section exists in the signed executable. (1 pt)
if [[ ! -z $(objdump -h test-elf-signed | grep .signature) ]]; then echo "pass"; else echo "fail"; fi

# The signed executable works functionally the same as the original executable. (1 pt)
./test-elf > orig
./test-elf-signed > signed
DIFF=$(diff orig signed)
rc=$?
if [ $rc -ne 0 ]; then echo "fail"; else echo "pass"; fi
rm orig signed

# Resistant to attacks that corrupt any executable section after signing. (2 pts)
echo "HACKED" > hacked
objcopy --update-section .text=hacked test-elf-signed test-elf-signed-text-hacked
objcopy --update-section .plt=hacked test-elf-signed test-elf-signed-plt-hacked
if [[ NOT_OK == $(./signtool verify -e test-elf-signed-text-hacked -k public_key1.pem) ]]; then echo "pass"; else echo "fail"; fi
if [[ NOT_OK == $(./signtool verify -e test-elf-signed-plt-hacked -k public_key1.pem) ]]; then echo "pass"; else echo "fail"; fi

# Resistant to attacks that corrupt the content of the .signature section after signing. (1 pts)
objcopy --update-section .signature=hacked test-elf-signed test-elf-signed-signature-hacked
if [[ NOT_OK == $(./signtool verify -e test-elf-signed-signature-hacked -k public_key1.pem) ]]; then echo "pass"; else echo "fail"; fi

# Resistant to attacks that attempt to verify using an invalid public key. (1 pts)
if [[ NOT_OK == $(./signtool verify -e test-elf-signed -k public_key2.pem) ]]; then echo "pass"; else echo "fail"; fi

# The edited signed executable (i) passes the code integrity (signature) check, (ii) runs functionally
# the same as before your edit, and (iii) bypasses the run-time license check. (2 pts)


# Clean up
rm test-elf.c test-elf test-elf-* hacked 
rm private_key1.pem private_key2.pem public_key1.pem public_key2.pem