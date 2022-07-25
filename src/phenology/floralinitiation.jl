@system FloralInitiation(Stage, LeafAppearance) begin
    critPPD: critical_photoperiod => 12.5 ~ preserve(u"hr", parameter)
    
    first_flowering_date => nothing ~ preserve::datetime(optional, parameter)
    begin_from_flowering(first_flowering_date) => !isnothing(first_flowering_date) ~ preserve::Bool

    FIR_max: maximum_floral_initiation_rate => 0.789712 ~ preserve(u"d^-1", parameter)
    floral_initiation(r=FIR_max, β=BF.ΔT) => r*β ~ accumulate(when=floral_initiating)

    floral_initiateable(first_flowering_date, begin_from_flowering, t=calendar.time, day = sun.day) => begin
        if  begin_from_flowering
            t >= first_flowering_date
        else
            day >= 50u"d"
        end
    end~ flag

    #FIXME: implement Sun
    floral_initiated(critPPD, day_length=sun.day_length, day=sun.day, leaves_appeared, flowers_initiated) => begin
        #FIXME solstice consideration is broken (flag turns false after solstice) and maybe unnecessary
        # w = self.pheno.weather
        # solstice = w.time.tz.localize(datetime.datetime(w.time.year, 6, 21))
        # # no MAX_LEAF_NO implied unlike original model
        # w.time <= solstice and w.day_length >= self.critical_photoperiod
        # (Not right for cucumbre as photoperiod affect sex) day_length >= critPPD && day <= 171u"d"
        # day >= 10000u"d" # (temporary fix for cucumber as indeterminate)
        flowers_initiated >= leaves_appeared > 0
    end ~ flag

    floral_initiating(floral_initiateable & !floral_initiated) ~ flag

    # #FIXME postprocess similar to @produce?
    # def finish(self):
    #     GDD_sum = self.pheno.gdd_recorder.rate
    #     print(f"* Floral initiation: time = {self.time}, GDDsum = {GDD_sum}")


    flowers_initiated(floral_initiation) => begin
        floral_initiation
    end ~ track::int(round=:floor)

    
end
