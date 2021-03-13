#!/bin/bash

set +x
set +e

echo "checking for README"
if [ ! -e "./README" ]
then
        echo "Error: No README file"
        exit 1
fi

echo "checking for Makefile"
if [ ! -e "./Makefile" ]
then
        echo "Error: No Makefile file"
        exit 1
fi

echo "Running make"
make
rc=$?
if [ $rc -ne 0 ]
then
        echo "Error when running the make command"
        exit 1
fi

if [ ! -e "./secure_house" ]
then
        echo "Error: Running make did not create the secure_house file"
        exit 1
fi

if [ ! -x "./secure_house" ]
then
        echo "Error: secure_house is not executable"
        exit 1
fi

INPUT_CASE="WHO'S INSIDE?
// case sensitive
insert key alice key1
INSERT KEY alice key1
TURN KEY alice
// 기본적인 동작
ENTER HOUSE bob
ENTER HOUSE alice
WHO'S INSIDE?
// secret key
INSERT KEY bob FIREFIGHTER_SECRET_KEY
TURN KEY bob
ENTER HOUSE bob
WHO'S INSIDE?
.
CHANGE LOCKS david new_key
CHANGE LOCKS owner new_key
INSERT KEY owner key1
TURN KEY owner
ENTER HOUSE owner
INSERT KEY carol key1
TURN KEY carol
// Rekey가 영향을 미치지 않는다.
CHANGE LOCKS owner new_key
.
ENTER HOUSE carol
WHO'S INSIDE?
INSERT KEY david key1
TURN KEY david
WHO'S INSIDE?
LEAVE HOUSE bob
WHO'S INSIDE?
// invalid leave house
LEAVE HOUSE carol
LEAVE HOUSE carol
LEAVE HOUSE bob
LEAVE HOUSE owner
LEAVE HOUSE alice
WHO'S INSIDE?
"

CORRECT_OUTPUT="NOBODY HOME
ERROR
ERROR
KEY key1 INSERTED BY alice
SUCCESS alice TURNS KEY key1
ERROR
ACCESS DENIED
ACCESS ALLOWED
alice
ERROR
KEY FIREFIGHTER_SECRET_KEY INSERTED BY bob
SUCCESS bob TURNS KEY FIREFIGHTER_SECRET_KEY
ACCESS ALLOWED
alice, bob
ERROR
ACCESS DENIED
ACCESS DENIED
KEY key1 INSERTED BY owner
SUCCESS owner TURNS KEY key1
ACCESS ALLOWED
KEY key1 INSERTED BY carol
SUCCESS carol TURNS KEY key1
ERROR
OK
ERROR
ACCESS ALLOWED
alice, bob, owner, carol
KEY key1 INSERTED BY david
FAILURE david UNABLE TO TURN KEY key1
alice, bob, owner, carol
OK
alice, owner, carol
ERROR
OK
carol NOT HERE
bob NOT HERE
OK
OK
NOBODY HOME
"

echo "Testing your program"
OUTPUT=$( echo -n "$INPUT_CASE" | ./secure_house owner key1 key2 key3)

echo "Your program's output is as follows:"
echo "------------------------------------"
echo "$OUTPUT"
echo "------------------------------------"

DIFF=$(diff -aBw <(echo "$OUTPUT") <(echo "$CORRECT_OUTPUT"))
rc=$?
if [ $rc -ne 0 ]
then
        echo "Error: did not pass the basic test case on the website."
        echo "$DIFF"
else
        echo "SUCCESS!"
fi