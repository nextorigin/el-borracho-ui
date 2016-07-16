Maquette = require "maquette"


class Mapper
  constructor: (items, @view) ->
    @mapping = Maquette.createMapping @identify, @create, @updateOne
    @update items

  identify:  (item) -> item.id
  create:    (item) => @view item
  updateOne: (item, target) ->

  components: =>
    (component() for component in @mapping.results)

  update: (items) ->
    @mapping.map items


module.exports = Mapper
