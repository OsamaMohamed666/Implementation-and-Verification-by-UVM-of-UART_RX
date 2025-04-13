# Compile the design and testbench with assertion coverage enabled
vcs -licqueue -full64 '-timescale=1ns/1ns' '+vcs+flush+all' '+warn=all' '-sverilog' '-ntb_opts' 'uvm' +incdir+$UVM_HOME/src testbench.sv design.sv -cm assert 

# Run the simulation with UVM verbosity set to LOW and collect assertion coverage
./simv +UVM_VERBOSITY=UVM_LOW  +vcs+lic+wait -cm assert

# Generate the coverage report in both HTML and text formats
urg  -dir simv.vdb -format both 

# List all generated HTML report files
ls -l urgReport/*html

# Combine all text coverage reports into a single HTML file for viewing
cat urgReport/*txt > final_report.html
