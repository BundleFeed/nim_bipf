const tape = require('tape')
const bipf = require('../')
const fixtures = require('bipf-spec/fixtures.json')

tape('fixtures compare', (t) => {
  for (let i = 0; i < fixtures.length; ++i) {
    const f = fixtures[i]
    t.comment(`testing: ${f.name}`)

    const buf = Buffer.from(f.json, 'hex')
    const jsonValue = JSON.parse(buf.toString('utf8'))
    t.comment(`   data: ${buf}`)

    const bipfBuffer = Buffer.from(bipf.allocAndEncode(jsonValue))

    t.equal(bipfBuffer.toString('hex'), f.binary)
  }

  t.end()
})
