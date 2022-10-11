Additional implementation of BIKE (Bit Flipping Key Encapsulation) 
------------------------------------------------------------------

This package is an "Additional Optimized" implementation of the 
Key Encapsulation Mechanism (KEM) [BIKE](https://bikesuite.org). 

It is developed and maintained solely by the DGK team that consists of
Nir Drucker, Shay Gueron, and Dusan Kostic.

BIKE is a KEM submission to the [Post-Quantum Cryptography Standardization project](https://csrc.nist.gov/projects/post-quantum-cryptography/post-quantum-cryptography-standardization). At this point in time, NIST is considering BIKE as a fourth round candidate in the PQC Standardization process ([link](https://csrc.nist.gov/News/2022/pqc-candidates-to-be-standardized-and-round-4)).

The official BIKE website is: https://bikesuite.org. 
This package corresponds to the specification document 
["BIKE_Spec.2021.09.29.1.pdf"](https://bikesuite.org/files/v4.2/BIKE_Spec.2021.09.29.1.pdf), but also includes other options that the DGK team deems as useful (via compilation flags).

The package includes implementations for several CPU architectures.
In particular, it can be compiled for a 64-bit ARM and for x86 processors.
ARM architectures are supported by a fully portable implementation written in C.
When the code is compiled for x86 processors, the resulting binary contains
the following implementations:
- Fully portable
- Optimized for AVX2 and AVX512 instruction sets 
- Optimized for CPUs that support PCLMULQDQ, and the latest Intel
  vector-PCLMULQDQ instruction.

When the package is used on an x86 CPU, it automatically (in runtime) detects 
the CPU capabilities and runs the fastest available code path, based on the
detected capabilities. The fully portable version, which is built by default,
requires OpenSSL. The library can also be compiled in a "stand-alone" mode,
without OpenSSL, but only for a processor that supports AES-NI and AVX
instructions. This mode can be enabled by a compilation flag described below.

The package includes testing and it uses the KAT generation utilities provided
by NIST.

All the functionalities in the package are implemented in constant-time,
which means that: 
- No branch depends on a secret piece of information; 
- All the memory access patters are independent of secret information.

The optimizations in this package use, among other techniques, algorithms
presented in the following papers:
- Nir Drucker, Shay Gueron, 
  "A Toolbox for Software Optimization of QC-MDPC Code-Based Cryptosystems."
  Journal of Cryptographic Engineering, January 2019, 1–17
  https://doi.org/10.1007/s13389-018-00200-4.

- Chou, T.: QcBits: Constant-Time Small-Key Code-Based Cryptography. In: 
  Gier-lichs, B., Poschmann, A.Y. (eds.) Cryptographic Hardware and
  Embedded Systems– CHES 2016. pp. 280–300. Springer Berlin Heidelberg, 
  Berlin, Heidelberg (2016)

- Guimarães, Antonio, Diego F Aranha, and Edson Borin. 2019.
  “Optimized Implementation of QC-MDPC Code-Based Cryptography.”
  Concurrency and Computation: Practice and Experience 31 (18):
  e5089. https://doi.org/10.1002/cpe.5089.

The GF2X inversion in this package is based on:
- Nir Drucker, Shay Gueron, Dusan Kostic, Fast polynomial inversion for post quantum QC-MDPC cryptography, Information and Computation, 2021, 104799, ISSN 0890-5401, https://doi.org/10.1016/j.ic.2021.104799.

The definition and the analysis of the constant-time BGF decoder used in this package is given in:
- Drucker N., Gueron S., Kostic D. (2020) On Constant-Time QC-MDPC Decoders with Negligible Failure Rate. In: Baldi M., Persichetti E., Santini P. (eds) Code-Based Cryptography. CBCrypto 2020. Lecture Notes in Computer Science, vol 12087. Springer, Cham. https://doi.org/10.1007/978-3-030-54074-6_4
- Drucker N., Gueron S., Kostic D. (2020) QC-MDPC Decoders with Several Shades of Gray. In: Ding J., Tillich JP. (eds) Post-Quantum Cryptography. PQCrypto 2020. Lecture Notes in Computer Science, vol 12100. Springer, Cham. https://doi.org/10.1007/978-3-030-44223-1_3

The code contains additional versions that can be enabled by the following
flags: BIND_PK_AND_M and USE_SHA3_AND_SHAKE. The flags can be turned on
individually or both at the same time.

Flag BIND_PK_AND_M enables binding of the public key and the message when
generating the ciphertext in encapsulation. This security measure was
proposed in:
- Drucker N., Gueron S., Kostic D. (2021) Binding BIKE Errors to a Key Pair. In: Dolev S., Margalit O., Pinkas B., Schwarzmann A. (eds) Cyber Security Cryptography and Machine Learning. CSCML 2021. Lecture Notes in Computer Science, vol 12716. Springer, Cham. https://doi.org/10.1007/978-3-030-78086-9_21

Flag USE_SHA3_AND_SHAKE turns on the version of BIKE which uses SHA3 algorithm
as a hash function (wherever a hash function is needed) and SHAKE based PRF.
This modification was proposed by the BIKE team in https://bikesuite.org/files/v4.2/BIKE_Spec.2021.07.26.1.pdf.

License
-------
This project is licensed under the Apache-2.0 License.

Dependencies
------------
This package requires
- CMake 3 and above
- An installation of OpenSSL for the KAT testing

BUILD
-----

To build the directory first create a working directory
```
mkdir build
cd build
```

Then, run CMake and compile
```
cmake -DCMAKE_BUILD_TYPE=Release ..
make
```

By default the package is compiled with parameters defined for NIST security
Level-1 (64-bit quantum security). The default compilation options require
OpenSSL to be available on the system. The "stand-alone" compilation, which can
be enabled by a flag, assumes that AES_NI and POPCNT instructions are available.

Additional compilation flags:
 - USE_NIST_RAND            - Using the DRBG of NIST and generate the KATs.
 - STANDALONE_IMPL          - Stand-alone implementation that doesn't depend on
                              any external library.
 - OPENSSL_DIR              - Set the path of the OpenSSL include/lib
                              directories (required only if OpenSSL is not
                              installed in usual directories).
 - BIND_PK_AND_M            - Bind the public key and the message in encapsulation.
 - USE_SHA3_AND_SHAKE       - Use SHA3 as the hash function and SHAKE as a PRF.
 - FIXED_SEED               - Using a fixed seed, for debug purposes.
 - RDTSC                    - Benchmark the algorithm (results in CPU cycles).
 - VERBOSE                  - Add verbose (level: 1-4 default: 1).
 - NUM_OF_TESTS             - Set the number of tests (keygen/encaps/decaps)
                              to run (default: 1).
 - LEVEL                    - Security level 1 or 3.
 - ASAN/TSAN/MSAN/UBSAN     - Enable the associated clang sanitizer.
 
To clean - remove the `build` directory. Note that a "clean" is required prior
to compilation with modified flags.

To format (`clang-format-9` or above is required):

`make format`

To use clang-tidy (`clang-tidy-9` is required):

```
CC=clang-9 cmake -DCMAKE_C_CLANG_TIDY="clang-tidy-9;--fix-errors;--format-style=file" ..
make
```

Before committing code, please test it using
`tests/run_tests.sh 0`
This will run all the sanitizers.

The package was compiled and tested with clang (version 10.0.0) in 64-bit mode,
on a Linux (Ubuntu 20.04) on Intel Xeon (x86) and Graviton 2 (ARM) processors.
The x86 tests are done with Intel SDE which can emulate any Intel CPU.  
Compilation on other platforms may require some adjustments.

KATs
----
The KATs are located in the `tests/kats/` directory.

Performance
----
The performance of different versions of BIKE measured on two CPUs, one with vector-PCLMUL support and the other one without. The numbers represent average number of processor cycles required to complete each operation.

Measurements on Intel(R) Xeon(R) Platinum 8175M CPU @ 2.50GHz (_doesn't_ support vector-PCLMUL):
```
  L1    |      a      |      b      |      c      |      d      |
----------------------------------------------------------------|
keygen  |    589,712  |    594,706  |    598,685  |    600,404  |
encaps  |     96,388  |    113,165  |    128,012  |    152,060  |
decaps  |  1,136,909  |  1,157,417  |  1,161,506  |  1,185,791  |

  L3    |      a      |      b      |      c      |      d      |
----------------------------------------------------------------|
keygen  |  1,825,772  |  1,822,106  |  1,831,052  |  1,830,032  |
encaps  |    217,102  |    248,402  |    275,782  |    326,975  |
decaps  |  3,883,230  |  3,934,521  |  3,955,854  |  3,980,154  |
```

Measurements on Intel(R) Xeon(R) Platinum 8375C CPU @ 2.90GHz (supports vector-PCLMUL):
```
  L1    |      a      |      b      |      c      |      d      |
----------------------------------------------------------------|
keygen  |    365,577  |    365,577  |    369,842  |    369,960  |
encaps  |     74,152  |     85,611  |     96,731  |    114,971  |
decaps  |  1,171,399  |  1,182,687  |  1,194,031  |  1,212,310  |

  L3    |      a      |      b      |      c      |      d      |
----------------------------------------------------------------|
keygen  |  1,046,864  |  1,053,795  |  1,063,760  |  1,060,223  |
encaps  |    157,035  |    181,363  |    201,464  |    234,489  |
decaps  |  3,469,903  |  3,490,288  |  3,534,174  |  3,547,011  |
```

where:
- (a) round 3 BIKE
- (b) round 3 BIKE + BIND_PK_AND_M
- (c) round 3 BIKE + SHA3_AND_SHAKE
- (d) round 3 BIKE + BIND_PK_AND_M + SHA3_AND_SHAKE

Rejection sampling
------------------
The rejection sampling design and implementation that is used here is described in the document entitled ["Isochronous implementation of the errors-vector generation of BIKE"](https://github.com/awslabs/bike-kem/blob/master/BIKE_Rejection_Sampling.pdf). This document explains our response to the paper [Don’t reject this: Key-recovery timing attacks due to rejection-sampling in HQC and BIKE](https://doi.org/10.46586/tches.v2022.i3.223-263) by Qian Guo et al, which is implemented here (since June 2022).
