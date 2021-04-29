#!/bin/bash

openssl dgst -sha256 -verify part_d.pem -signature sigs/3a2b225a/file1.sig sigs/3a2b225a/file1.txt
openssl dgst -sha256 -verify part_d.pem -signature sigs/3a2b225a/file2.sig sigs/3a2b225a/file2.txt
openssl dgst -sha256 -verify part_d.pem -signature sigs/3a2b225a/file3.sig sigs/3a2b225a/file3.txt