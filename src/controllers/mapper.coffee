Maquette = require "maquette"


class Mapper
  constructor: (records, @view) ->
    @mapping = Maquette.createMapping @identify, @create, @updateOne
    @update records

  identify: (record) -> (record.constructor?.className or "") + record.id

  create: (record) =>
    component = -> component.render()
    component.render = => @view record
    component.update = (r) -> record = r
    component

  updateOne: (record, target) ->
    target?.update record

  components: =>
    (target?.render() for target in @mapping.results)

  update: (records) ->
    @mapping.map records


module.exports = Mapper
