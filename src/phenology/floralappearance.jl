@system FloralAppearance(Stage, FloralInitiation) begin

    first_flowering_date => nothing ~ preserve::datetime(optional, parameter)
    begin_from_flowering(first_flowering_date) => !isnothing(first_flowering_date) ~ preserve::Bool

    FAR_max: floral_appearance_rate => 1.50971 ~ preserve(u"d^-1", parameter)

    FAR(r=FAR_max, β=BF.ΔT): floral_appearance => r*β ~ accumulate(when=floral_appearing)

    

    floral_appearable(first_flowering_date, begin_from_flowering, t=calendar.time, d=sun.day) => begin
        if  begin_from_flowering
            t >= first_flowering_date
        else
            day >= 50u"d"
        end
    end~ flag
    # floral_appearance_threshold => 5.0 ~ preserve(parameter)
    floral_appeared(flowers_appeared, flowers_initiated) => begin
        flowers_appeared >= flowers_initiated > 0
    end ~ flag
    floral_appearing(floral_appearable & !floral_appeared) ~ flag

    # def finish(self):
    #     print(f"* Inflorescence Visible and Flowering: time = {self.time}")

    flowers_appeared(FAR) => (FAR) ~ track::int(round=:floor)

end