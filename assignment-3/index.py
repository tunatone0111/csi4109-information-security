#!/usr/bin/python3

import sys
from os import listdir
from cryptography import x509
from cryptography.hazmat.primitives.asymmetric import rsa
from cryptography.hazmat.backends import default_backend
import numpy as np

if len(sys.argv) != 2:
    print("ERROR: Certification directory must be specified")
    sys.exit()

certs_dir = sys.argv[1]

certs = listdir(certs_dir)
expiration_date = []
validity_period = []
count1, count2 = 0, 0

for idx, cert in enumerate(certs):
    with open(f'{certs_dir}/{cert}', 'rb') as f:
        cert_obj = x509.load_pem_x509_certificate(f.read(), default_backend())

    expiration_date.append(cert_obj.not_valid_after)
    validity_period.append(
        cert_obj.not_valid_after -
        cert_obj.not_valid_before
    )

    pub_key = cert_obj.public_key()
    if isinstance(pub_key, rsa.RSAPublicKey):
        count1 += 1
        if pub_key.key_size == 4096:
            count2 += 1

certs = np.array(certs)
expiration_date = np.array(expiration_date)
validity_period = np.array(validity_period)


print(certs[expiration_date.argmin()])

longest_period = validity_period.max()
print(*sorted(certs[validity_period == longest_period]), sep=", ")

print(count1)
print(count2)
