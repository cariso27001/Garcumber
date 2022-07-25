@system FruitInitiation(Stage, FloralInitiation) begin

    FRIR_max: fruit_initiation_rate => 1.70878 ~ preserve(u"d^-1", parameter)

    FRIR(r=FRIR_max, β=BF.ΔT): fruit_initiation => r*β ~ accumulate(when=fruit_initiating)


    fruit_initiateable(floral_initiating) ~ flag
    fruit_initiated(fruits_initiated, flowers_initiated) => begin
        fruits_initiated >= flowers_initiated > 0
    end ~ flag
    fruit_initiating(fruit_initiateable & !fruit_initiated) ~ flag

    # def finish(self):
    #     print(f"* Bulbil and Bulb Maturing: time = {self.time}")


    fruits_initiated(fruit_initiation) => begin
        fruit_initiation
    end ~ track::int(round=:floor)

    





end