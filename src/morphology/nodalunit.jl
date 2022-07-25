@system NodalUnit(Organ) begin
    rank ~ ::int(override) # preserve
    leaf(context, phenology, rank) ~ ::Leaf
    fruit(context, phenology, rank) ~ ::Fruit

    mass(l=leaf.mass, s=fruit.mass) => (l + s) ~ track(u"g")
end
