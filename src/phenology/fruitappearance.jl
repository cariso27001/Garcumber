# @system ScapeGrowth(Stage, LeafAppearance, FloralInitiation) begin
#     #HACK: can't mixin ScapeRemoval/FlowerAppearance due to cyclic dependency
#     scape_removed ~ hold
#     flower_appeared ~ hold

#     #HACK: use phyllochron
#     SR_max(LTAR_max): maximum_scaping_rate ~ track(u"d^-1")

#     scape(r=SR_max, β=BF.ΔT) => r*β ~ accumulate(when=scaping)

#     scapeable(leaf_appeared & floral_initiated) ~ flag
#     scaped(scape_removed | flower_appeared) ~ flag
#     scaping(scapeable & !scaped) ~ flag
# end

# @system ScapeAppearance(Stage, ScapeGrowth) begin
#     scape_appearable(scapeable) ~ flag
#     scape_appearance_threshold => 3.0 ~ preserve(parameter)
#     scape_appeared(scape, t=scape_appearance_threshold) => (scape >= t) ~ flag
#     scape_appearing(scape_appearable & !scape_appeared) ~ flag

#     # def finish(self):
#     #     print(f"* Scape Tip Visible: time = {self.time}, leaves = {self.pheno.leaves_appeared} / {self.pheno.leaves_initiated}")
# end

# @system ScapeRemoval(Stage, ScapeGrowth, ScapeAppearance) begin
#     #FIXME handling default (non-removal) value?
#     scape_removal_date => nothing ~ preserve::datetime(optional, parameter)

#     scape_removeable(scape_appeared) ~ flag
#     scape_removed(scape_removal_date, scape_removeable, t=calendar.time) => begin
#         isnothing(scape_removal_date) ? false : scape_removeable && (t >= scape_removal_date)
#     end ~ flag
#     scape_removing(scape_appeared & !scape_removed) ~ flag

#     # def finish(self):
#     #     print(f"* Scape Removed and Bulb Maturing: time = {self.time}")
# end


@system FruitAppearance(Stage, FruitInitiation) begin
    fruit_appearable(!fruit_appeared) ~ flag
    # fruit_appearance_threshold => 5.5 ~ preserve(parameter)
    # fruit_appeared(scape, t=fruit_appearance_threshold, scape_removed) => (scape >= t && !scape_removed) ~ flag
    
    FRAR_max: fruit_appearance_rate => 1.75561 ~ preserve(u"d^-1", parameter)

    FRAR(r=FRAR_max, β=BF.ΔT): fruit_appearance => r*β ~ accumulate(when=fruit_appearing)

    fruit_appeared(fruits_appeared, fruits_initiated) => (fruits_appeared >= fruits_initiated > 0 || fruits_initiated == 0) ~ flag
    
    fruit_appearing(fruit_appearable & !fruit_appeared) ~ flag

    # def finish(self):
    #     print(f"* Bulbil and Bulb Maturing: time = {self.time}")

    fruits_appeared(fruit_appearance) => begin
        fruit_appearance
    end ~ track::int(round=:floor)


end
