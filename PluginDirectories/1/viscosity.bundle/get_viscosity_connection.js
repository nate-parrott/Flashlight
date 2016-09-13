ObjC.import('stdio')
function run(connName) {
  var viscosity = Application('com.viscosityvpn.Viscosity')
  return viscosity.connections[0].name()
}
