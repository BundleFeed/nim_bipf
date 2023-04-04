```
Generating JSON structure...
Structure generated in 22ms
arjMessages length: 9200
celMessages length: 1266
andreMessages length: 5560
fixtureMessages length: 80000
fixtureMessages (500 authors) of 80000 messages

=========================
  Nim Bipf - JS Backend  
=========================

Platform info:
==============
   Darwin 22.3.0 x64
   Node.JS: 19.8.1
   V8: 10.8.168.25-node.12
   CPU: Intel(R) Core(TM) i9-9980HK CPU @ 2.40GHz × 16
   Memory: 32 GB

ssbMessages sample of 16026 messages
Suite: Encoding data ssb messages from arj,cel,andre

   bipf#encode/ssb messages from arj,cel,andre (#)                          0%         (79,706 rps)   (avg: 12μs)
   nim_bipf#serialize/ssb messages from arj,cel,andre                  +38.13%        (110,101 rps)   (avg: 9μs)
   nim_bipf#serializeWithKeyDict/ssb messages from arj,cel,andre       +35.22%        (107,780 rps)   (avg: 9μs)
   nim_bipf_node#serialize/ssb messages from arj,cel,andre             -13.71%         (68,782 rps)   (avg: 14μs)
   json#stringify/ssb messages from arj,cel,andre                     +227.95%        (261,396 rps)   (avg: 3μs)
-----------------------------------------------------------------------

Suite: Encoding data ssb messages from ssb-fixture

   bipf#encode/ssb messages from ssb-fixture (#)                          0%         (91,801 rps)   (avg: 10μs)
   nim_bipf#serialize/ssb messages from ssb-fixture                   +31.3%        (120,532 rps)   (avg: 8μs)
   nim_bipf#serializeWithKeyDict/ssb messages from ssb-fixture       +31.59%        (120,800 rps)   (avg: 8μs)
   nim_bipf_node#serialize/ssb messages from ssb-fixture             -16.51%         (76,642 rps)   (avg: 13μs)
   json#stringify/ssb messages from ssb-fixture                     +216.77%        (290,796 rps)   (avg: 3μs)
-----------------------------------------------------------------------

Suite: Decoding data ssb messages from arj,cel,andre

   bipf#decode/ssb messages from arj,cel,andre (#)                            0%        (210,415 rps)   (avg: 4μs)
   nim_bipf#deserialize/ssb messages from arj,cel,andre                   +5.08%        (221,101 rps)   (avg: 4μs)
   nim_bipf#deserializeWithKeyDict/ssb messages from arj,cel,andre        +3.42%        (217,618 rps)   (avg: 4μs)
   nim_bipf_node#deserialize/ssb messages from arj,cel,andre             -35.06%        (136,642 rps)   (avg: 7μs)
   json#parse(string)/ssb messages from arj,cel,andre                    +18.59%        (249,537 rps)   (avg: 4μs)
   json#parse(buffer)/ssb messages from arj,cel,andre                    +30.93%        (275,503 rps)   (avg: 3μs)
-----------------------------------------------------------------------

Suite: Decoding data ssb messages from ssb-fixture

   bipf#decode/ssb messages from ssb-fixture (#)                            0%        (236,085 rps)   (avg: 4μs)
   nim_bipf#deserialize/ssb messages from ssb-fixture                    -2.3%        (230,653 rps)   (avg: 4μs)
   nim_bipf#deserializeWithKeyDict/ssb messages from ssb-fixture        -2.05%        (231,254 rps)   (avg: 4μs)
   nim_bipf_node#deserialize/ssb messages from ssb-fixture             -30.33%        (164,470 rps)   (avg: 6μs)
   json#parse(string)/ssb messages from ssb-fixture                     +19.3%        (281,654 rps)   (avg: 3μs)
   json#parse(buffer)/ssb messages from ssb-fixture                    +20.95%        (285,534 rps)   (avg: 3μs)
-----------------------------------------------------------------------

Suite: JSON 2 Bipf ssb messages from arj,cel,andre

   json#parse(string)/bipf#allocAndEncodessb messages from arj,cel,andre (#)        0%         (61,256 rps)   (avg: 16μs)
   json#parse(buffer)/bipf#allocAndEncodessb messages from arj,cel,andre        -1.94%         (60,068 rps)   (avg: 16μs)
   json#parse(string)/nim_bipf#serializessb messages from arj,cel,andre        +22.85%         (75,251 rps)   (avg: 13μs)
   json#parse(buffer)/nim_bipf#serializessb messages from arj,cel,andre        +24.39%         (76,197 rps)   (avg: 13μs)
   nim_bipf_node#parseJson2Bipf(string)ssb messages from arj,cel,andre         +48.85%         (91,179 rps)   (avg: 10μs)
   nim_bipf_node#parseJson2Bipf(buffer)ssb messages from arj,cel,andre         +100.6%        (122,877 rps)   (avg: 8μs)
-----------------------------------------------------------------------

Suite: JSON 2 Bipf ssb messages from ssb-fixture

   json#parse(string)/bipf#allocAndEncodessb messages from ssb-fixture (#)        0%         (68,199 rps)   (avg: 14μs)
   json#parse(buffer)/bipf#allocAndEncodessb messages from ssb-fixture        -4.43%         (65,177 rps)   (avg: 15μs)
   json#parse(string)/nim_bipf#serializessb messages from ssb-fixture        +19.93%         (81,794 rps)   (avg: 12μs)
   json#parse(buffer)/nim_bipf#serializessb messages from ssb-fixture        +26.27%         (86,116 rps)   (avg: 11μs)
   nim_bipf_node#parseJson2Bipf(string)ssb messages from ssb-fixture         +42.05%         (96,880 rps)   (avg: 10μs)
   nim_bipf_node#parseJson2Bipf(buffer)ssb messages from ssb-fixture         +87.72%        (128,027 rps)   (avg: 7μs)
-----------------------------------------------------------------------

Suite: Seeking path

   bipf#seekPath(encoded) (#)                  0%        (900,649 rps)   (avg: 1μs)
   bipf#seekPath(compiled)               +451.37%      (4,965,873 rps)   (avg: 201ns)
   nim_bipf#seekPath(encoded)             +84.29%      (1,659,784 rps)   (avg: 602ns)
   nim_bipf#seekPath(compiled)           +684.36%      (7,064,333 rps)   (avg: 141ns)
   nim_bipf_node#seekPath(compiled)      +390.61%      (4,418,680 rps)   (avg: 226ns)
-----------------------------------------------------------------------

Suite: Scanning in memory db (first 100 message of type 'contact')

   bipf#jsArray[js objects]/scan and match (#)               0%         (27,322 rps)   (avg: 36μs)
   bipf#jsArray[bipf]/seekPath(compiled)                -93.72%          (1,716 rps)   (avg: 582μs)
   nim_bipf#jsArray[bipf]/seekPath(compiled)            -91.47%          (2,332 rps)   (avg: 428μs)
   nim_bipf_node#jsArray[bipf]/seekPath(compiled)        -87.8%          (3,332 rps)   (avg: 300μs)
   nim_bipf_node#inModuleMemory                         -37.28%         (17,137 rps)   (avg: 58μs)
-----------------------------------------------------------------------

```