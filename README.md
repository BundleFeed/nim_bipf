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

# Backends

- [x] Nim library
- [x] Pure JS library (to deploy in the browser use NodeJs Buffer polyfill or some packager)
- [x] Compatibility layer with https://www.npmjs.com/package/bipf (pass all tests but those that are not compliant with the spec in this implementation) 
- [x] NodeJs Module (build with cmake-js)
- [ ] WebAssembly Module

## Performance

### For JS
A benchmark is available in the `tests-js` folder.  To run it:

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

Apache-2.0