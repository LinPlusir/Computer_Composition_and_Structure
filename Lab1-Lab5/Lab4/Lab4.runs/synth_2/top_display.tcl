# 
# Synthesis run script generated by Vivado
# 

set TIME_start [clock seconds] 
proc create_report { reportName command } {
  set status "."
  append status $reportName ".fail"
  if { [file exists $status] } {
    eval file delete [glob $status]
  }
  send_msg_id runtcl-4 info "Executing : $command"
  set retval [eval catch { $command } msg]
  if { $retval != 0 } {
    set fp [open $status w]
    close $fp
    send_msg_id runtcl-5 warning "$msg"
  }
}
create_project -in_memory -part xc7a100tcsg324-1

set_param project.singleFileAddWarning.threshold 0
set_param project.compositeFile.enableAutoGeneration 0
set_param synth.vivado.isSynthRun true
set_msg_config -source 4 -id {IP_Flow 19-2162} -severity warning -new_severity info
set_property webtalk.parent_dir D:/ALL_Project/PCexp/Lab4/Lab4.cache/wt [current_project]
set_property parent.project_path D:/ALL_Project/PCexp/Lab4/Lab4.xpr [current_project]
set_property XPM_LIBRARIES XPM_MEMORY [current_project]
set_property default_lib xil_defaultlib [current_project]
set_property target_language Verilog [current_project]
set_property ip_output_repo d:/ALL_Project/PCexp/Lab4/Lab4.cache/ip [current_project]
set_property ip_cache_permissions {read write} [current_project]
add_files D:/ALL_Project/PCexp/Lab4/Lab4.ip_user_files/mipstest.coe
read_verilog -library xil_defaultlib {
  D:/ALL_Project/PCexp/Lab4/Lab4.srcs/sources_1/imports/ex4/rtl/adder.v
  D:/ALL_Project/PCexp/Lab4/Lab4.srcs/sources_1/imports/ex4/rtl/alu.v
  D:/ALL_Project/PCexp/Lab4/Lab4.srcs/sources_1/imports/ex4/rtl/aludec.v
  D:/ALL_Project/PCexp/Lab4/Lab4.srcs/sources_1/imports/ex4/rtl/controller.v
  D:/ALL_Project/PCexp/Lab4/Lab4.srcs/sources_1/imports/ex4/rtl/datapath.v
  D:/ALL_Project/PCexp/Lab4/Lab4.srcs/sources_1/new/display.v
  D:/ALL_Project/PCexp/Lab4/Lab4.srcs/sources_1/imports/ex4/rtl/eqcmp.v
  D:/ALL_Project/PCexp/Lab4/Lab4.srcs/sources_1/imports/ex4/rtl/flopenr.v
  D:/ALL_Project/PCexp/Lab4/Lab4.srcs/sources_1/imports/ex4/rtl/flopenrc.v
  D:/ALL_Project/PCexp/Lab4/Lab4.srcs/sources_1/imports/ex4/rtl/flopr.v
  D:/ALL_Project/PCexp/Lab4/Lab4.srcs/sources_1/imports/ex4/rtl/floprc.v
  D:/ALL_Project/PCexp/Lab4/Lab4.srcs/sources_1/imports/ex4/rtl/hazard.v
  D:/ALL_Project/PCexp/Lab4/Lab4.srcs/sources_1/imports/ex4/rtl/maindec.v
  D:/ALL_Project/PCexp/Lab4/Lab4.srcs/sources_1/imports/ex4/rtl/mips.v
  D:/ALL_Project/PCexp/Lab4/Lab4.srcs/sources_1/imports/ex4/rtl/mux2.v
  D:/ALL_Project/PCexp/Lab4/Lab4.srcs/sources_1/imports/ex4/rtl/mux3.v
  D:/ALL_Project/PCexp/Lab4/Lab4.srcs/sources_1/imports/ex4/rtl/pc.v
  D:/ALL_Project/PCexp/Lab4/Lab4.srcs/sources_1/imports/ex4/rtl/regfile.v
  D:/ALL_Project/PCexp/Lab4/Lab4.srcs/sources_1/new/seg7.v
  D:/ALL_Project/PCexp/Lab4/Lab4.srcs/sources_1/imports/ex4/rtl/signext.v
  D:/ALL_Project/PCexp/Lab4/Lab4.srcs/sources_1/imports/ex4/rtl/sl2.v
  D:/ALL_Project/PCexp/Lab4/Lab4.srcs/sources_1/new/top_display.v
}
read_ip -quiet D:/ALL_Project/PCexp/Lab4/Lab4.srcs/sources_1/ip/data_ram/data_ram.xci
set_property used_in_implementation false [get_files -all d:/ALL_Project/PCexp/Lab4/Lab4.srcs/sources_1/ip/data_ram/data_ram_ooc.xdc]

read_ip -quiet D:/ALL_Project/PCexp/Lab4/Lab4.srcs/sources_1/ip/inst_ram/inst_ram.xci
set_property used_in_implementation false [get_files -all d:/ALL_Project/PCexp/Lab4/Lab4.srcs/sources_1/ip/inst_ram/inst_ram_ooc.xdc]

# Mark all dcp files as not used in implementation to prevent them from being
# stitched into the results of this synthesis run. Any black boxes in the
# design are intentionally left as such for best results. Dcp files will be
# stitched into the design at a later time, either when this synthesis run is
# opened, or when it is stitched into a dependent implementation run.
foreach dcp [get_files -quiet -all -filter file_type=="Design\ Checkpoint"] {
  set_property used_in_implementation false $dcp
}
read_xdc D:/ALL_Project/PCexp/Lab4/Lab4.srcs/constrs_1/new/constrain.xdc
set_property used_in_implementation false [get_files D:/ALL_Project/PCexp/Lab4/Lab4.srcs/constrs_1/new/constrain.xdc]

read_xdc dont_touch.xdc
set_property used_in_implementation false [get_files dont_touch.xdc]
set_param ips.enableIPCacheLiteLoad 1
close [open __synthesis_is_running__ w]

synth_design -top top_display -part xc7a100tcsg324-1


# disable binary constraint mode for synth run checkpoints
set_param constraints.enableBinaryConstraints false
write_checkpoint -force -noxdef top_display.dcp
create_report "synth_2_synth_report_utilization_0" "report_utilization -file top_display_utilization_synth.rpt -pb top_display_utilization_synth.pb"
file delete __synthesis_is_running__
close [open __synthesis_is_complete__ w]
