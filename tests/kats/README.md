KATs
----

The KATs in this directory hold the same values as the KATs in the official
Reference package at [BIKE website](https://bikesuite.org/):
https://bikesuite.org/files/v4.0/KAT.2020.06.03.1.zip

However, the files are not identical because in this code package additional
values are stored as part of the private key. In the private key field,
the Reference KATs hold only the binary representation of the key and the
sigma value as defined in the BIKE specification.
The private key field in this package holds the following values in this order:
  - Dense representation of the private key polynomials
    (indices of the set bits in the key).
  - Binary representation of the private key (as in the Reference files).
  - The public key (stored for efficiency reasons, to avoid recomputation
    of the public key in the decapsulation phase).
  - Sigma value (as in the Reference files).
