ObjC.import('stdio')
function run(connName) {
  var viscosity = Application('com.viscosityvpn.Viscosity')
  var conns = viscosity.connections
  var conn = (connName != '')
    ? conns.whose({
        name: { _contains: connName }
      })[0]
    : conns[0]

  var name = conn.name()
  $.printf("Connecting to '%s'", name)
  viscosity.connect(name)
}
