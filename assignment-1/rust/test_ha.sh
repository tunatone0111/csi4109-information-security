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

INPUT_CASE=".
// insert -> turn -> enter하는 경우
INSERT KEY owner key1
TURN KEY owner
ENTER HOUSE thief
.
WHO'S INSIDE?
.
INSERT KEY owner key2
TURN KEY thief
.
WHO'S INSIDE?
.
INSERT KEY owner key3
TURN KEY owner
ENTER HOUSE owner
.
WHO'S INSIDE?
.
LEAVE HOUSE owner
WHO's INSIDE?
.
// insert를 계속 하려는 경우
INSERT KEY owner key1
INSERT KEY owner key2
INSERT KEY owner key3
INSERT KEY owner key4
INSERT KEY owner key5
TURN KEY owner
.
// change하려는 경우
CHANGE LOCKS thief keya keyb keyc
CHANGE LOCKS owner keya keyb keyc
.
INSERT KEY owner key1
TURN KEY owner
ENTER HOUSE owner
.
INSERT KEY user1 key2
TURN KEY user1
ENTER HOUSE user1
.
INSERT KEY user2 key3
TURN KEY user2
ENTER HOUSE user2
.
WHO'S INSIDE?
.
CHANGE LOCKS thief keya keyb keyc
CHANGE LOCKS owner keya keyb keyc
.
WHO'S INSIDE?
.
LEAVE HOUSE owner
LEAVE HOUSE owner
.
LEAVE HOUSE user1
LEAVE HOUSE user1
.
LEAVE HOUSE user2
LEAVE HOUSE user2
.
INSERT KEY user1 keyb
TURN KEY user1
ENTER HOUSE user1
.
INSERT KEY user2 keyc
TURN KEY user2
ENTER HOUSE user2
.
CHANGE LOCKS thief key1 key2 key3
CHANGE LOCKS owner key1 key2 key3
.
WHO'S INSIDE?
.
"

CORRECT_OUTPUT="ERROR
ERROR
KEY key1 INSERTED BY owner
SUCCESS owner TURNS KEY key1
ACCESS DENIED
ERROR
NOBODY HOME
ERROR
KEY key2 INSERTED BY owner
FAILURE thief UNABLE TO TURN KEY key2
ERROR
NOBODY HOME
ERROR
KEY key3 INSERTED BY owner
SUCCESS owner TURNS KEY key3
ACCESS ALLOWED
ERROR
owner
ERROR
OK
ERROR
ERROR
ERROR
KEY key1 INSERTED BY owner
KEY key2 INSERTED BY owner
KEY key3 INSERTED BY owner
KEY key4 INSERTED BY owner
KEY key5 INSERTED BY owner
FAILURE owner UNABLE TO TURN KEY key5
ERROR
ERROR
ACCESS DENIED
ACCESS DENIED
ERROR
KEY key1 INSERTED BY owner
SUCCESS owner TURNS KEY key1
ACCESS ALLOWED
ERROR
KEY key2 INSERTED BY user1
SUCCESS user1 TURNS KEY key2
ACCESS ALLOWED
ERROR
KEY key3 INSERTED BY user2
SUCCESS user2 TURNS KEY key3
ACCESS ALLOWED
ERROR
owner, user1, user2
ERROR
ACCESS DENIED
OK
ERROR
owner, user1, user2
ERROR
OK
owner NOT HERE
ERROR
OK
user1 NOT HERE
ERROR
OK
user2 NOT HERE
ERROR
KEY keyb INSERTED BY user1
SUCCESS user1 TURNS KEY keyb
ACCESS ALLOWED
ERROR
KEY keyc INSERTED BY user2
SUCCESS user2 TURNS KEY keyc
ACCESS ALLOWED
ERROR
ACCESS DENIED
ACCESS DENIED
ERROR
user1, user2
ERROR
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