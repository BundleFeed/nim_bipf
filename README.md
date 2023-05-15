<!--
 Copyright 2023 Geoffrey Picron
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
     http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
-->

# Nim BIPF

BIPF is a binary format for data interchange, designed to be compact and fast to parse.

This library provides a Nim implementation of BIPF, with support for both reading, writing, searching.

*Status*: Work in progress, prefer pointing to the github repository for now in the requires section of your nimble file.

# Installation
For Nim library:

```bash
nimble install https://github.com/BundleFeed/nim_bipf
```

For NPM library:

```bash
npm install nim_bipf
```

Note: the Node module is not yet published on NPM.  To use it, you need to clone the repository and build it locally using `nimble compileNodeJsModule`.

# Backends

- [x] Nim library
- [x] Pure JS library (to deploy in the browser use NodeJs Buffer polyfill or some packager)
- [x] Compatibility layer with https://www.npmjs.com/package/bipf (pass all tests but those that are not compliant with the spec in this implementation) 
- [x] NodeJs Module (build with cmake-js)
- [ ] WebAssembly Module
- [x] Spec pull request implementation [Convert NULLBOOL type to ATOM type](https://github.com/ssbc/bipf-spec/pull/3)

## Performance

### For JS 
A benchmark [(results)](benchmark-result.md) is available in the `tests-js` folder.  To run it:

```bash
nimble benchJs
```

or 

```bash
npm run benchmark
```

It compares the performances of 
- the reference JS implementation: https://www.npmjs.com/package/bipf
- Nim implementation compiled to JS backend
- Nim implementation compiled to NodeJs Module 

## License

### Wrapper License

This repository is licensed and distributed under either of

* MIT license: [LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT

or

* Apache License, Version 2.0, ([LICENSE-APACHEv2](LICENSE-APACHEv2) or http://www.apache.org/licenses/LICENSE-2.0)

at your option. This file may not be copied, modified, or distributed except according to those terms.
