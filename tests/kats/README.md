KATs
----

The KATs in this directory hold the same values as the official KATs at [link](https://bikesuite.org/files/v5.0/KAT.2022.10.04.1.zip).
The KATs in the `round3` folder are old KATs corresponding to the round-3 implementation.

However, the KAT files here and the official ones are not identical because in this code package additional
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
