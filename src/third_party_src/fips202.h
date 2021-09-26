/********************************************************************************************
* SHA3 hash function and SHA3-derived function SHAKE
*
* Based on the public domain implementation in crypto_hash/keccakc512/simple/
* from http://bench.cr.yp.to/supercop.html by Ronny Van Keer
* and the public domain "TweetFips202" implementation from https://twitter.com/tweetfips202
* by Gilles Van Assche, Daniel J. Bernstein, and Peter Schwabe
*
* See NIST Special Publication 800-185 for more information:
* http://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.800-185.pdf
*
*********************************************************************************************/

#pragma once

#include <stdlib.h>

#define SHA3_384_RATE (104)
#define SHAKE256_RATE (136)

void sha3_384(uint8_t h[48], const uint8_t *in, size_t inlen);

void shake256(uint8_t *out, size_t outlen, const uint8_t *in, size_t inlen);
void shake256_absorb(uint64_t state[25], const uint8_t *in, size_t inlen);
void shake256_squeeze(uint8_t *out, size_t nblocks, uint64_t state[25]);
