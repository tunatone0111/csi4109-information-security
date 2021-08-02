 #!/bin/bash

if [ ! -e "./README" ]
then
    echo "Error: No README file"
    exit 1
fi

if [ ! -e "./Makefile" ]
then
    echo "Error: No Makefile file"
    exit 1
fi

if [ ! -e "./bypass-licensechk-signed" ]; then
    echo "Error: No bypass-licensechk-signed file"
    exit 1
fi


CODE="this_is_a_valid_key"
OUTPUT=$( echo -n "$CODE" | ./bypass-licensechk-signed | sed -n 2p )
if [ "$OUTPUT" = "VALID" ]
then
    echo "Bypass check: 1 SUCCESS!"
else
    echo "Bypass check: 1 FAIL!"
fi

CODE="this_is_a_invalid_key"
OUTPUT=$( echo -n "$CODE" | ./bypass-licensechk-signed | sed -n 2p )
if [ "$OUTPUT" = "VALID" ]
then
    echo "Bypass check: 2 SUCCESS!"
else
    echo "Bypass check: 2 FAIL!"
fi


make > /dev/null

if [ ! -e "./signtool" ]
then
    echo "Error: Running make did not create the signtool file"
    exit 1
fi

if [ ! -x "./signtool" ]
then
    echo "Error: signtool is not executable"
    exit 1
fi


openssl genrsa -out private_key1.pem 2048 > /dev/null 2>&1
openssl rsa -in private_key1.pem -out public_key1.pem -pubout > /dev/null 2>&1
openssl genrsa -out private_key2.pem 2048 > /dev/null 2>&1
openssl rsa -in private_key2.pem -out public_key2.pem -pubout > /dev/null 2>&1


echo "#include <stdio.h>\n
int main() {\n
 printf(\"Hello, World\");\n
 return 0;\n
}" > test.c

gcc test.c -o test.out


mv private_key1.pem ../private_key1.pem
OUTPUT=$( ./signtool sign -e test.out -k ../private_key1.pem -o test.signed.out ) 
if [ "$OUTPUT" = "OK" ]
then
    echo "Path check - sign: 1 SUCCESS!"
else
    echo "Path check - sign: 1 FAIL!"
fi
rm -rf test.signed.out

mv test.out ../test.out
OUTPUT=$( ./signtool sign -e ../test.out -k ../private_key1.pem -o test.signed.out ) 
if [ "$OUTPUT" = "OK" ]
then
    echo "Path check - sign: 2 SUCCESS!"
else
    echo "Path check - sign: 2 FAIL!"
fi
rm -rf test.signed.out

mv ../private_key1.pem private_key1.pem
OUTPUT=$( ./signtool sign -e ../test.out -k private_key1.pem -o test.signed.out ) 
if [ "$OUTPUT" = "OK" ]
then
    echo "Path check - sign: 3 SUCCESS!"
else
    echo "Path check - sign: 3 FAIL!"
fi
rm -rf test.signed.out

mv ../test.out test.out
OUTPUT=$( ./signtool sign -e test.out -k private_key1.pem -o test.signed.out )
if [ "$OUTPUT" = "OK" ]
then
    echo "Path check - sign: 4 SUCCESS!"
else
    echo "Path check - sign: 4 FAIL!"
fi

PWD=$( pwd )
OUTPUT=$( ./signtool sign -e "$PWD"/test.out -k private_key1.pem -o "$PWD"/test.signed.out )
if [ "$OUTPUT" = "OK" ]
then
    echo "Path check - sign: 5 SUCCESS!"
else
    echo "Path check - sign: 5 FAIL!"
fi
rm -rf test.signed.out


OUTPUT=$( ./signtool sign -e Makefile -k private_key1.pem -o test.signed.out )
if [ "$OUTPUT" = "INVALID_FILE" ]
then
    echo "File check - sign: 1 SUCCESS!"
else
    echo "File check - sign: 1 FAIL!"
fi
rm -rf test.signed.out

OUTPUT=$( ./signtool sign -e README -k private_key1.pem -o test.signed.out )
if [ "$OUTPUT" = "INVALID_FILE" ]
then
    echo "File check - sign: 2 SUCCESS!"
else
    echo "File check - sign: 2 FAIL!"
fi
rm -rf test.signed.out

OUTPUT=$( ./signtool sign -e foobar -k private_key1.pem -o test.signed.out )
if [ "$OUTPUT" = "INVALID_FILE" ]
then
    echo "File check - sign: 3 SUCCESS!"
else
    echo "File check - sign: 3 FAIL!"
fi
rm -rf test.signed.out


OUTPUT=$( ./signtool sign -e Makefile -k private_key1.pem -o test.signed.out )
if [ "$OUTPUT" = "INVALID_FILE" ]
then
    echo "File check - sign: 4 SUCCESS!"
else
    echo "File check - sign: 4 FAIL!"
fi
rm -rf test.signed.out

OUTPUT=$( ./signtool sign -e README -k private_key1.pem -o test.signed.out )
if [ "$OUTPUT" = "INVALID_FILE" ]
then
    echo "File check - sign: 5 SUCCESS!"
else
    echo "File check - sign: 5 FAIL!"
fi
rm -rf test.signed.out

OUTPUT=$( ./signtool sign -e foobar -k private_key1.pem -o test.signed.out )
if [ "$OUTPUT" = "INVALID_FILE" ]
then
    echo "File check - sign: 6 SUCCESS!"
else
    echo "File check - sign: 6 FAIL!"
fi
rm -rf test.signed.out


OUTPUT=$( ./signtool sign -e test.out -k public_key1.pem -o test.signed.out )
if [ "$OUTPUT" = "INVALID_KEY" ]
then
    echo "Key check - sign: 1 SUCCESS!"
else
    echo "Key check - sign: 1 FAIL!"
fi
rm -rf test.signed.out

OUTPUT=$( ./signtool sign -e test.out -k Makefile -o test.signed.out )
if [ "$OUTPUT" = "INVALID_KEY" ]
then
    echo "Key check - sign: 2 SUCCESS!"
else
    echo "Key check - sign: 2 FAIL!"
fi
rm -rf test.signed.out

OUTPUT=$( ./signtool sign -e test.out -k README -o test.signed.out )
if [ "$OUTPUT" = "INVALID_KEY" ]
then
    echo "Key check - sign: 3 SUCCESS!"
else
    echo "Key check - sign: 3 FAIL!"
fi
rm -rf test.signed.out

OUTPUT=$( ./signtool sign -e test.out -k foobar -o test.signed.out )
if [ "$OUTPUT" = "INVALID_KEY" ]
then
    echo "Key check - sign: 4 SUCCESS!"
else
    echo "Key check - sign: 4 FAIL!"
fi
rm -rf test.signed.out


OUTPUT=$( ./signtool verify -e Makefile -k public_key1.pem )
if [ "$OUTPUT" = "INVALID_FILE" ]
then
    echo "File check - verify: 1 SUCCESS!"
else
    echo "File check - verify: 1 FAIL!"
fi
rm -rf test.signed.out

OUTPUT=$( ./signtool verify -e README -k public_key1.pem )
if [ "$OUTPUT" = "INVALID_FILE" ]
then
    echo "File check - verify: 2 SUCCESS!"
else
    echo "File check - verify: 2 FAIL!"
fi
rm -rf test.signed.out

OUTPUT=$( ./signtool verify -e foobar -k public_key1.pem )
if [ "$OUTPUT" = "INVALID_FILE" ]
then
    echo "File check - verify: 3 SUCCESS!"
else
    echo "File check - verify: 3 FAIL!"
fi
rm -rf test.signed.out

OUTPUT=$( ./signtool verify -e test.out -k public_key1.pem )
if [ "$OUTPUT" = "NOT_SIGNED" ]
then
    echo "File check - verify: 4 SUCCESS!"
else
    echo "File check - verify: 4 FAIL!"
fi
rm -rf test.signed.out


OUTPUT=$( ./signtool sign -e test.out -k private_key1.pem -o test.signed.out )
if [ "$OUTPUT" = "OK" ]
then
    echo "Default - sign: 1 SUCCESS!"
else
    echo "Default - sign: 1 FAIL!"
fi

OUTPUT=$( ./signtool verify -e test.signed.out -k public_key1.pem )
if [ "$OUTPUT" = "OK" ]
then
    echo "Default - verify: 1 SUCCESS!"
else
    echo "Default - verify: 1 FAIL!"
fi
rm -rf test.signed.out

OUTPUT=$( ./signtool sign -e test.out -k private_key2.pem -o test.signed.out )
if [ "$OUTPUT" = "OK" ]
then
    echo "Default - sign: 2 SUCCESS!"
else
    echo "Default - sign: 2 FAIL!"
fi

OUTPUT=$( ./signtool verify -e test.signed.out -k public_key2.pem )
if [ "$OUTPUT" = "OK" ]
then
    echo "Default - verify: 2 SUCCESS!"
else
    echo "Default - verify: 2 FAIL!"
fi
rm -rf test.signed.out


OUTPUT=$( ./signtool sign -e test.out -k private_key1.pem -o test.signed.out )
if [ "$OUTPUT" = "OK" ]
then
    echo "Invalid public key - sign: 1 SUCCESS!"
else
    echo "Invalid public key - sign: 1 FAIL!"
fi

OUTPUT=$( ./signtool verify -e test.signed.out -k public_key2.pem )
if [ "$OUTPUT" = "NOT_OK" ]
then
    echo "Invalid public key - verify: 1 SUCCESS!"
else
    echo "Invalid public key - verify: 1 FAIL!"
fi
rm -rf test.signed.out

OUTPUT=$( ./signtool sign -e test.out -k private_key2.pem -o test.signed.out )
if [ "$OUTPUT" = "OK" ]
then
    echo "Invalid public key - sign: 2 SUCCESS!"
else
    echo "Invalid public key - sign: 2 FAIL!"
fi

OUTPUT=$( ./signtool verify -e test.signed.out -k public_key1.pem )
if [ "$OUTPUT" = "NOT_OK" ]
then
    echo "Invalid public key - verify: 2 SUCCESS!"
else
    echo "Invalid public key - verify: 2 FAIL!"
fi
rm -rf test.signed.out


OUTPUT=$( ./signtool sign -e test.out -k private_key2.pem -o test.signed.out )
if [ "$OUTPUT" = "OK" ]
then
    echo "Invalid private key - sign: 1 SUCCESS!"
else
    echo "Invalid private key - sign: 1 FAIL!"
fi

OUTPUT=$( ./signtool verify -e test.signed.out -k public_key1.pem )
if [ "$OUTPUT" = "NOT_OK" ]
then
    echo "Invalid private key - verify: 1 SUCCESS!"
else
    echo "Invalid private key - verify: 1 FAIL!"
fi
rm -rf test.signed.out

OUTPUT=$( ./signtool sign -e test.out -k private_key2.pem -o test.signed.out )
if [ "$OUTPUT" = "OK" ]
then
    echo "Invalid private key - sign: 2 SUCCESS!"
else
    echo "Invalid private key - sign: 2 FAIL!"
fi

OUTPUT=$( ./signtool verify -e test.signed.out -k public_key1.pem )
if [ "$OUTPUT" = "NOT_OK" ]
then
    echo "Invalid private key - verify: 2 SUCCESS!"
else
    echo "Invalid private key - verify: 2 FAIL!"
fi
rm -rf test.signed.out


OUTPUT=$( ./signtool sign -e test.out -k private_key1.pem -o test.signed.out )
if [ "$OUTPUT" = "OK" ]
then
    echo "Executable section attack - sign: 1 SUCCESS!"
else
    echo "Executable section attack - sign: 1 FAIL!"
fi

objcopy --remove-section .init test.signed.out
OUTPUT=$( ./signtool verify -e test.signed.out -k public_key1.pem )
if [ "$OUTPUT" = "NOT_OK" ]
then
    echo "Executable section attack - verify: 1 SUCCESS!"
else
    echo "Executable section attack - verify: 1 FAIL!"
fi
rm -rf test.signed.out

OUTPUT=$( ./signtool sign -e test.out -k private_key1.pem -o test.signed.out )
if [ "$OUTPUT" = "OK" ]
then
    echo "Executable section attack - sign: 2 SUCCESS!"
else
    echo "Executable section attack - sign: 2 FAIL!"
fi

objcopy --remove-section .text test.signed.out
OUTPUT=$( ./signtool verify -e test.signed.out -k public_key1.pem )
if [ "$OUTPUT" = "NOT_OK" ]
then
    echo "Executable section attack - verify: 2 SUCCESS!"
else
    echo "Executable section attack - verify: 2 FAIL!"
fi
rm -rf test.signed.out

OUTPUT=$( ./signtool sign -e test.out -k private_key1.pem -o test.signed.out )
if [ "$OUTPUT" = "OK" ]
then
    echo "Executable section attack - sign: 3 SUCCESS!"
else
    echo "Executable section attack - sign: 3 FAIL!"
fi

objcopy --remove-section .fini test.signed.out
OUTPUT=$( ./signtool verify -e test.signed.out -k public_key1.pem )
if [ "$OUTPUT" = "NOT_OK" ]
then
    echo "Executable section attack - verify: 3 SUCCESS!"
else
    echo "Executable section attack - verify: 3 FAIL!"
fi
rm -rf test.signed.out

OUTPUT=$( ./signtool sign -e test.out -k private_key1.pem -o test.signed.out )
if [ "$OUTPUT" = "OK" ]
then
    echo "Executable section attack - sign: 4 SUCCESS!"
else
    echo "Executable section attack - sign: 4 FAIL!"
fi

objcopy --add-section .text2=README test.signed.out
OUTPUT=$( ./signtool verify -e test.signed.out -k public_key1.pem )
if [ "$OUTPUT" = "OK" ]
then
    echo "Executable section attack - verify: 4 SUCCESS!"
else
    echo "Executable section attack - verify: 4 FAIL!"
fi
rm -rf test.signed.out

OUTPUT=$( ./signtool sign -e test.out -k private_key1.pem -o test.signed.out )
if [ "$OUTPUT" = "OK" ]
then
    echo "Executable section attack - sign: 5 SUCCESS!"
else
    echo "Executable section attack - sign: 5 FAIL!"
fi

objcopy --add-section .text2=README --set-section-flags .text2=alloc,load,readonly,code test.signed.out > /dev/null 2>&1
OUTPUT=$( ./signtool verify -e test.signed.out -k public_key1.pem )
if [ "$OUTPUT" = "NOT_OK" ]
then
    echo "Executable section attack - verify: 5 SUCCESS!"
else
    echo "Executable section attack - verify: 5 FAIL!"
fi
rm -rf test.signed.out

OUTPUT=$( ./signtool sign -e test.out -k private_key1.pem -o test.signed.out )
if [ "$OUTPUT" = "OK" ]
then
    echo "Executable section attack - sign: 6 SUCCESS!"
else
    echo "Executable section attack - sign: 6 FAIL!"
fi

objcopy --add-section .data2=README --set-section-flags .data2=alloc,load,data,code test.signed.out > /dev/null 2>&1
OUTPUT=$( ./signtool verify -e test.signed.out -k public_key1.pem )
if [ "$OUTPUT" = "NOT_OK" ]
then
    echo "Executable section attack - verify: 6 SUCCESS!"
else
    echo "Executable section attack - verify: 6 FAIL!"
fi
exit
rm -rf test.signed.out


OUTPUT=$( ./signtool sign -e test.out -k private_key1.pem -o test.signed.out )
if [ "$OUTPUT" = "OK" ]
then
    echo ".signature section attack - sign: 1 SUCCESS!"
else
    echo ".signature section attack - sign: 1 FAIL!"
fi

objcopy --remove-section .signature test.signed.out
OUTPUT=$( ./signtool verify -e test.signed.out -k public_key1.pem )
if [ "$OUTPUT" = "NOT_SIGNED" ]
then
    echo ".signature section attack - verify: 1 SUCCESS!"
else
    echo ".signature section attack - verify: 1 FAIL!"
fi
rm -rf test.signed.out

OUTPUT=$( ./signtool sign -e test.out -k private_key1.pem -o test.signed.out )
if [ "$OUTPUT" = "OK" ]
then
    echo ".signature section attack - sign: 2 SUCCESS!"
else
    echo ".signature section attack - sign: 2 FAIL!"
fi

objcopy --update-section .signature=README test.signed.out
OUTPUT=$( ./signtool verify -e test.signed.out -k public_key1.pem )
if [ "$OUTPUT" = "NOT_OK" ]
then
    echo ".signature section attack - verify: 2 SUCCESS!"
else
    echo ".signature section attack - verify: 2 FAIL!"
fi
rm -rf test.signed.out

OUTPUT=$( ./signtool sign -e test.out -k private_key1.pem -o test.signed.out )
if [ "$OUTPUT" = "OK" ]
then
    echo ".signature section attack - sign: 3 SUCCESS!"
else
    echo ".signature section attack - sign: 3 FAIL!"
fi

openssl sha256 -binary -out hashed_README README
objcopy --update-section .signature=hashed_README test.signed.out
OUTPUT=$( ./signtool verify -e test.signed.out -k public_key1.pem )
if [ "$OUTPUT" = "NOT_OK" ]
then
    echo ".signature section attack - verify: 3 SUCCESS!"
else
    echo ".signature section attack - verify: 3 FAIL!"
fi
rm -rf test.signed.out hashed_README

OUTPUT=$( ./signtool sign -e test.out -k private_key1.pem -o test.signed.out )
if [ "$OUTPUT" = "OK" ]
then
    echo ".signature section attack - sign: 4 SUCCESS!"
else
    echo ".signature section attack - sign: 4 FAIL!"
fi

objcopy --set-section-flags .signature=readonly,code test.signed.out
OUTPUT=$( ./signtool verify -e test.signed.out -k public_key1.pem )
if [ "$OUTPUT" = "NOT_OK" ]
then
    echo ".signature section attack - verify: 4 SUCCESS!"
else
    echo ".signature section attack - verify: 4 FAIL!"
fi
rm -rf test.signed.out hashed_README


OUTPUT=$( ./test.out )
if [ "$OUTPUT" = "Hello, World" ]
then
    echo "Output - before: 1 SUCCESS!"
else
    echo "Output - before: 1 FAIL!"
fi

OUTPUT=$( ./signtool sign -e test.out -k private_key1.pem -o test.signed.out )
if [ "$OUTPUT" = "OK" ]
then
    echo "Output - sign: 1 SUCCESS!"
else
    echo "Output - sign: 1 FAIL!"
fi

OUTPUT=$( ./test.signed.out )
if [ "$OUTPUT" = "Hello, World" ]
then
    echo "Output - after: 1 SUCCESS!"
else
    echo "Output - after: 1 FAIL!"
fi

OUTPUT=$( ./signtool verify -e test.signed.out -k public_key1.pem )
if [ "$OUTPUT" = "OK" ]
then
    echo "Output - verify: 1 SUCCESS!"
else
    echo "Output - verify: 1 FAIL!"
fi

rm -rf test.signed.out
rm -rf test.c test.out

echo "#include <stdio.h>\n
int main() {\n
 int i;\n
 for (i = 0; i < 100; ++i) {};\n
 printf(\"%d\", i);\n
 return 0;\n
}" > test.c

gcc test.c -o test.out

OUTPUT=$( ./test.out )
if [ "$OUTPUT" = "100" ]
then
    echo "Output - before: 2 SUCCESS!"
else
    echo "Output - before: 2 FAIL!"
fi

OUTPUT=$( ./signtool sign -e test.out -k private_key2.pem -o test.signed.out )
if [ "$OUTPUT" = "OK" ]
then
    echo "Output - sign: 2 SUCCESS!"
else
    echo "Output - sign: 2 FAIL!"
fi

OUTPUT=$( ./test.signed.out )
if [ "$OUTPUT" = "100" ]
then
    echo "Output - after: 2 SUCCESS!"
else
    echo "Output - after: 2 FAIL!"
fi

OUTPUT=$( ./signtool verify -e test.signed.out -k public_key2.pem )
if [ "$OUTPUT" = "OK" ]
then
    echo "Output - verify: 2 SUCCESS!"
else
    echo "Output - verify: 2 FAIL!"
fi
rm -rf test.signed.out


rm -rf test.c test.out
rm -rf private_key1.pem private_key2.pem public_key1.pem public_key2.pem
