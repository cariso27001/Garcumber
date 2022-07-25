@system Count begin
    pheno: phenology ~ hold
    NU: nodal_units ~ hold

    leaves_initiated(pheno.leaves_initiated) ~ track::int
    leaves_appeared(pheno.leaves_appeared) ~ track::int

    flowers_initiated(pheno.flowers_initiated) ~ track::int
    flowers_appeared(pheno.flowers_appeared) ~ track::int
    fruits_initiated(pheno.fruits_initiated) ~ track::int
    fruits_appeared(pheno.fruits_appeared) ~ track::int

    leaves_growing(x=NU["*"].leaf.growing) => sum(x) ~ track::int
    leaves_mature(x=NU["*"].leaf.mature) => sum(x) ~ track::int
    leaves_dropped(x=NU["*"].leaf.dropped) => sum(x) ~ track::int
    leaves_detached(x=NU["*"].leaf.detached) => sum(x) ~ track::int
    


    # leaves_detached(leaves_mature, leaves_dropped, detach_to_maintain_max_leaf_number, detach_to_maintain_min_leaf_number) => begin
    #     if leaves_mature - leaves_dropped <= detach_to_maintain_max_leaf_number
    #         0
    #     else
    #         leaves_mature - leaves_dropped - detach_to_maintain_min_leaf_number
    #     end
    # end ~ track::int

    leaves_real(a=leaves_mature, d=leaves_dropped, c=leaves_detached) => (a - d - c ) ~ track::int

    
end
