#!/bin/bash

# ==

userid="2019193015"
pass_phrase_for_part_b="2019193015"

set +x
set +e

# ==

if [ ! -e "./part_a.ctxt" ]
then
    echo "Error: No part_a.ctxt file"
    exit 1
fi

test_string="THIS FILE IS GOING TO BE ENCRYPTED.
THIS FILE IS GOING TO BE ENCRYPTED.
THIS FILE IS GOING TO BE ENCRYPTED.
THIS FILE IS GOING TO BE ENCRYPTED.
THIS FILE IS GOING TO BE ENCRYPTED.
THIS FILE IS GOING TO BE ENCRYPTED.
THIS FILE IS GOING TO BE ENCRYPTED.
THIS FILE IS GOING TO BE ENCRYPTED.
THIS FILE IS GOING TO BE ENCRYPTED.
THIS FILE IS GOING TO BE ENCRYPTED.
THIS FILE IS GOING TO BE ENCRYPTED.
THIS FILE IS GOING TO BE ENCRYPTED.
THIS FILE IS GOING TO BE ENCRYPTED.
THIS FILE IS GOING TO BE ENCRYPTED.
THIS FILE IS GOING TO BE ENCRYPTED.
THIS FILE IS GOING TO BE ENCRYPTED.
THIS FILE IS GOING TO BE ENCRYPTED.
THIS FILE IS GOING TO BE ENCRYPTED."

echo "$test_string" > test1.txt
openssl enc -aes256 -d -in part_a.ctxt -out test2.txt -pass pass:"$userid" > /dev/null 2>&1

DIFF=$(diff test1.txt test2.txt)
rc=$?
if [ $rc -ne 0 ] 
then
    echo "part A: FAIL!"
    echo "$DIFF"
else
    echo "Part A: SUCCESS!"
fi

rm -f test1.txt
rm -f test2.txt

# ==

if [ ! -e "./part_b.pem" ]
then
    echo "Error: No part_b.pem file"
    exit 1
fi

if [ ! -e "./part_c.sig" ]
then
    echo "Error: No part_c.sig file"
    exit 1
fi

test_string="THIS FILE IS GOING TO BE SIGNED."

echo "$test_string" > test1.txt
openssl dgst -sha256 -sign part_b.priv.pem -passin pass:"$pass_phrase_for_part_b" -out test1.sig part_c.txt 

DIFF=$(diff part_c.sig test1.sig)
rc=$?
if [ $rc -ne 0 ] 
then
    echo "part B,C: FAIL!"
    echo "$DIFF"
else
    echo "Part B,C: SUCCESS!"
fi

rm -f test1.txt
rm -f test1.sig

# ==

if [ ! -e "./part_d.pem" ]
then
    echo "Error: No part_d.pem file"
    exit 1
fi

if [ ! -d "./sigs" ]
then
    echo "Error: No sigs directory"
    exit 1
fi

hash_full=$(echo -n "$userid" | sha256sum)
hash_8=${hash_full:0:8}

rst1=$(openssl dgst -verify ./part_d.pem -signature ./sigs/$hash_8/file1.sig ./sigs/$hash_8/file1.txt)
rst2=$(sed -n 1p part_d.txt)
if [ "$rst1" = "Verified OK" ]
then
    if [ "$rst2" = "VALID" ]
    then
        echo "Part D: 1 SUCCESS!"
    else
        echo "Part D: 1 FAIL!"
    fi
else
    if [ "$rst2" = "INVALID" ]
    then
        echo "Part D: 1 SUCCESS!"
    else
        echo "Part D: 1 FAIL!"
    fi
fi

rst1=$(openssl dgst -verify ./part_d.pem -signature ./sigs/$hash_8/file2.sig ./sigs/$hash_8/file2.txt)
rst2=$(sed -n 2p part_d.txt)
if [ "$rst1" = "Verified OK" ]
then
    if [ "$rst2" = "VALID" ]
    then
        echo "Part D: 2 SUCCESS!"
    else
        echo "Part D: 2 FAIL!"
    fi
else
    if [ "$rst2" = "INVALID" ]
    then
        echo "Part D: 2 SUCCESS!"
    else
        echo "Part D: 2 FAIL!"
    fi
fi

rst1=$(openssl dgst -verify ./part_d.pem -signature ./sigs/$hash_8/file3.sig ./sigs/$hash_8/file3.txt)
rst2=$(sed -n 3p part_d.txt)
if [ "$rst1" = "Verified OK" ]
then
    if [ "$rst2" = "VALID" ]
    then
        echo "Part D: 3 SUCCESS!"
    else
        echo "Part D: 3 FAIL!"
    fi
else
    if [ "$rst2" = "INVALID" ]
    then
        echo "Part D: 3 SUCCESS!"
    else
        echo "Part D: 3 FAIL!"
    fi
fi

# ==

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

make > /dev/null
rc=$?
if [ $rc -ne 0 ]
then
        echo "Error when running the make command"
        exit 1
fi

if [ ! -e "./certcheck" ]
then
        echo "Error: Running make did not create the certcheck file"
        exit 1
fi

if [ ! -x "./certcheck" ]
then
        echo "Error: certcheck is not executable"
        exit 1
fi

if [ -f "./99certs" ]
then
        echo "Error: 99certs directory exists"
        exit 1
fi

if [ ! -e "./99certs.zip" ]
then
        echo "Error: No 99certs.zip file"
        exit 1
fi

unzip 99certs.zip > /dev/null

CORRECT_OUTPUT="netflix.com.pem
apache.org.pem, gravatar.com.pem, nytimes.com.pem, wordpress.com.pem
83
1"

OUTPUT=$(./certcheck 99certs)

DIFF=$(diff -aBw <(echo "$OUTPUT") <(echo "$CORRECT_OUTPUT"))
rc=$?
if [ $rc -ne 0 ]
then
    echo "Part E: 1 FAIL!"
    echo "$DIFF"
else
    echo "Part E: 1 SUCCESS!"
fi

mv 99certs test1

OUTPUT=$(./certcheck test1)

DIFF=$(diff -aBw <(echo "$OUTPUT") <(echo "$CORRECT_OUTPUT"))
rc=$?
if [ $rc -ne 0 ]
then
    echo "Part E: 2 FAIL!"
    echo "$DIFF"
else
    echo "Part E: 2 SUCCESS!"
fi

rm -rf test1
