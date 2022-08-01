using Pkg
Pkg.activate("..")
Pkg.instantiate()
Pkg.update()
# Pkg.upgrade_manifest()

using Cropbox
using Test
# using Plots
using TimeZones
using DataFramesMeta
using CSV
# Cropbox.Interact.WebIO.setup(:ijulia)

obs_veget_2nd = CSV.read("$(@__DIR__)/../data/Phenology_Vegetative_2nd.csv", DataFrame) |> unitfy;
obs_repro_2nd = CSV.read("$(@__DIR__)/../data/Phenology_Reproductive_2nd.csv", DataFrame) |> unitfy;
obs_lai_2nd = CSV.read("$(@__DIR__)/../data/Morphology_LAI_2nd.csv", DataFrame) |> unitfy;
obs_fruitweightest_2nd = CSV.read("$(@__DIR__)/../data/Morphology_FruitWeightEst_2nd.csv", DataFrame) |> unitfy;

include("../src/Garlic.jl")

import Dates

tz = tz"Asia/Seoul"

Cucumber = @config (
    :Phenology => (
        optimal_temperature = 25, # Topt
        ceiling_temperature = 30, # Tceil
        critical_photoperiod = 12, # critPPD
        # initial_leaves_at_harvest = 5, # ILN
        maximum_leaf_initiation_rate = 1.70878, # LIR
        maximum_emergence_rate = 0.2,
        # maximum_leaf_initiation_rate = 0.1003, # LIR
        maximum_phyllochron_asymptote = 1.75561, # LTARa
        leaves_generic = 50, # GLN
    ),
    :Leaf => (
        maximum_elongation_rate = 4.70, # LER
        minimum_length_of_longest_leaf = 15.0, # LL
        # stay_green = 1.84, # SG
        stay_green = 20,
        length_to_width_ratio = 1,
        leaf_detaching_rate = 23, #LDR
    ),
    :Carbon => (
        maintenance_respiration_coefficient = 0.012, # Rm
        synthesis_efficiency = 0.8, # Yg
    ),
    :Meta => (; cultivar = :Cucumber),
    :Plant => (initial_planting_density = 8,),
);


Validate = @config(Cucumber, (
    :Phenology => (
        planting_date = ZonedDateTime(2021, 2, 1, tz"Asia/Seoul"), # Y1 sow
        emergence_date = ZonedDateTime(2021, 2, 23, tz"Asia/Seoul"), # Y1 emg
        first_flowering_date = ZonedDateTime(2021, 3, 24, tz"Asia/Seoul"),
    ),
    :Meta => (
        planting_group = 2,
        year = 2021,
    ),
    :Calendar => (
        init = ZonedDateTime(2021, 2, 1, tz"Asia/Seoul"),
        last = ZonedDateTime(2021, 8, 29, tz"Asia/Seoul"),
    ),
    :Weather => (
        CO2 = 500, # CO2 Enrichment
        store = Garlic.loadwea("$(@__DIR__)/../data/Cucumber2nd.wea", tz"Asia/Seoul"),
    ),
));


r = simulate(Garlic.Model;
    config=Validate,
    stop="calendar.count",
    snap=s -> Dates.hour(s.calendar.time') == 12,
)
# @test r.leaves_initiated[end] > 0

plot_veg = visualize(r, :DAP, [:leaves_appeared, :leaves_real], kind=:line)
visualize!(plot_veg, obs_veget_2nd, :DAP, [:leaf_count, :internode_count]) |> display # Fig. 3.D
plot_rep_fl = visualize(r, :DAP, [:flowers_appeared], kind=:line)
visualize!(plot_rep_fl, obs_repro_2nd, :DAP, [:flowers_appeared]) |> display
plot_rep_fr = visualize(r, :DAP, [:fruits_appeared], kind=:line)
visualize!(plot_rep_fr, obs_repro_2nd, :DAP, [:fruits_appeared]) |> display
plot_lai = visualize(r, :DAP, :LAI, kind=:line)
visualize!(plot_lai, obs_lai_2nd, :DAP, [:LAI]) |> display # Fig. 4.D
visualize(r, :DAP, :green_leaf_area, kind=:line) |> display
# visualize(r, :DAP, [:leaf_mass, :total_mass, :fruit_mass]) |> display
# plot_photo = visualize(r, :DAP, [:A_net], kind=:line)
# visualize!(plot_photo, obs_photo_2nd, :DAP, [:photo_a]) |> display
# p = visualize(r, :DAP, [:leaves_real], kind=:line)
visualize(r, :fruits_appeared, [:fruit_mass], kind=:line) |> display

# obs_veget_unit = obs_veget |> unitfy
# obs_repro_unit = obs_repro |> unitfy

# f(s) = s.DAP' in obs_repro_unit.DAP && Dates.hour(s.calendar.time') == 12

# calibrate(Garlic.Model, obs_repro_unit;
#     config=Cucumber,
#     stop="calendar.count",
#     index=:DAP,
#     target=:flowers_appeared => :flowers_appeared,
#     parameters= :Phenology => (;
#         FAR_max = (0.4, 1.8),
#         FIR_max = (0.4, 1.8),
#     ),
#     snap=f,
#     optim=(:MaxSteps => 20,),
# )