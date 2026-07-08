transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vcom -93 -work work {C:/Users/visha/Downloads/IITB/2_XTRA/VHDL-based-Digital-frequency-and-Duty-Cycle-meter/clock_divider.vhd}
vcom -93 -work work {C:/Users/visha/Downloads/IITB/2_XTRA/VHDL-based-Digital-frequency-and-Duty-Cycle-meter/counter_module.vhd}
vcom -93 -work work {C:/Users/visha/Downloads/IITB/2_XTRA/VHDL-based-Digital-frequency-and-Duty-Cycle-meter/control_fsm.vhd}
vcom -93 -work work {C:/Users/visha/Downloads/IITB/2_XTRA/VHDL-based-Digital-frequency-and-Duty-Cycle-meter/top_level.vhd}

vcom -93 -work work {C:/Users/visha/Downloads/IITB/2_XTRA/VHDL-based-Digital-frequency-and-Duty-Cycle-meter/Quartus/../testbench.vhd}

vsim -t 1ps -L altera -L lpm -L sgate -L altera_mf -L altera_lnsim -L fiftyfivenm -L rtl_work -L work -voptargs="+acc"  tb_top_level

add wave *
view structure
view signals
run -all
