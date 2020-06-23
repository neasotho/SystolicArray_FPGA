create_pblock pe0
resize_pblock [get_pblocks pe0] -add {SLICE_X30Y0:SLICE_X50Y10}
add_cells_to_pblock [get_pblocks pe0] [get_cells [list {row[0].col[0].pe_inst}]]
create_pblock pe1
resize_pblock [get_pblocks pe1] -add {SLICE_X30Y10:SLICE_X50Y20}
add_cells_to_pblock [get_pblocks pe1] [get_cells [list {row[0].col[1].pe_inst}]]
create_pblock pe2
resize_pblock [get_pblocks pe2] -add {SLICE_X30Y20:SLICE_X50Y30}
add_cells_to_pblock [get_pblocks pe2] [get_cells [list {row[0].col[2].pe_inst}]]
create_pblock pe3
resize_pblock [get_pblocks pe3] -add {SLICE_X30Y30:SLICE_X50Y40}
add_cells_to_pblock [get_pblocks pe3] [get_cells [list {row[0].col[3].pe_inst}]]
