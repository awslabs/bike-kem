Additional implementation of BIKE (Bit Flipping Key Encapsulation) 
------------------------------------------------------------------

This package is an "Additional Optimized" implementation of the 
Key Encapsulation Mechanism (KEM) [BIKE](https://bikesuite.org). 

It was developed and is maintained by Nir Drucker, Shay Gueron, and Dusan Kostic,
(drucker.nir@gmail.com, shay.gueron@gmail.com, dkostic@protonmail.com).

This BIKE repository branch holds an implementation of BIKE that includes
security levels Level-1, Level-3, and Level-5.

The main addition to the code complexity due to the Level-5 implementation
is attributed to the (larger) Level-5 parameters. Accommodating the implementation
to support these parameters requires a slightly modified (and less efficient)
implementation of the polynomial inversion functions.

To avoid increased code complexity in the master branch the Level-5 implementation
is added in a separate branch.

BIKE is a submission to the 
[Post-Quantum Cryptography Standardization project](http://csrc.nist.gov/projects/post-quantum-cryptography).

The official BIKE website is: https://bikesuite.org. 
This package corresponds to the specification document 
["BIKE_Round_3.2020.05.03.1.pdf"](https://bikesuite.org/files/v4.0/BIKE_Spec.2020.05.03.1.pdf).

The package includes the following implementations:
- PORTABLE: a C (C99) portable code implementation.
- AVX2: implementation that leverages the AVX2 architecture features. 
  It is written in C (with C intrinsics for AVX2 functions).
- AVX512: implementation that leverages the AVX512 architecture features. 
  It is written in C (with C intrinsics for AVX512 functions). 
This implementation can also be compiled to use the latest _vector_-PCLMULQDQ 
instruction that is available on the Intel IceLake processors.

The package includes testing and it uses the KAT generation utilities provided
by NIST. The code is "stand-alone", i.e., it does not depend on external 
libraries. In addition, there is a compilation option for integration into
libraries that consume AES256 and SHA384 from OpenSSL. 

All the functionalities available in the package are implemented in constant-time, which means that: 
- No branch depends on a secret piece of information; 
- All the memory access patters are independent of secret information.

The optimizations in this package use, among other techniques, the following papers: 
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
- Nir Drucker, Shay Gueron, and Dusan Kostic. 2020. 
  "Fast polynomial inversion for post quantum QC-MDPC cryptography". 
  Cryptology ePrint Archive, 2020. https://eprint.iacr.org/2020/298.pdf

The analysis for the constant-time BGF decoder used in this package is given in:
- Nir Drucker, Shay Gueron, and Dusan Kostic. 2019. 
  “On Constant-Time QC-MDPC Decoding with Negligible Failure Rate.” 
  Cryptology ePrint Archive, 2019. https://eprint.iacr.org/2019/1289.
- Nir Drucker, Shay Gueron, and Dusan Kostic. 2019. 
  “QC-MDPC decoders with several shades of gray.” 
  Cryptology ePrint Archive, 2019. https://eprint.iacr.org/2019/1423

## License
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

Default is Level-5 (64-bit quantum security) with AVX2 support.
This compilation assumes that AES_NI and POPCNT instructions are available. 
For platforms that do not have AES_NI use USE_OPENSSL=1.

Additional compilation flags:
 - USE_NIST_RAND            - Using the DRBG of NIST and generate the KATs.
 - USE_OPENSSL              - Use OpenSSL for AES/SHA. 
                              In this case, OpenSSL must be installed on the platform.
 - OPENSSL_DIR              - Set the path of the OpenSSL include/lib directories.
 - FIXED_SEED               - Using a fixed seed, for debug purposes.
 - RDTSC                    - Measure time in cycles rather than in milliseconds.
 - VERBOSE                  - Add verbose (level: 1-4 default: 1).
 - NUM_OF_TESTS             - Set the number of tests (keygen/encaps/decaps) to run (default: 1).
 - LEVEL                    - Security level 1 or 3.
 - ASAN/TSAN/MSAN/UBSAN     - Enable the associated clang sanitizer.
 - PORTABLE                 - Compile the fully portable version. When this flag is set it
                              automatically disables AVX2, AVX512, (vector-)PCLMUL.
 - AVX512                   - Compile with AVX512 support.
 - PCLMUL                   - Compile with PCLMUL support when running the PORTABLE code.
                              This flag has no effect when running with AVX2 and AVX512 
                              because the code already assumes that PCLMUL is available.
 - VPCLMUL                  - Compile with VPCLMUL support, 
                              setting this flag forces the AVX512 flag.
 
To clean - remove the `build` directory. Note that a "clean" is required prior to compilation with modified flags.

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

The package was compiled and tested with gcc (version 7.4.0) in 64-bit mode,
on a Linux (Ubuntu 18.04.2 LTS) OS.
The VPCLMUL version was compiled and tested with gcc (version 9.2.1) in 64-bit 
mode on a Linux (Ubuntu 19.04) OS, on an Ice Lake laptop.
Compilation on other platforms may require some adjustments.

KATs
----
The KATs are located in the `tests/kats/` directory.
