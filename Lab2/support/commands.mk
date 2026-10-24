# Additional build and run helpers for Lab 2.
# Usage from the repository root:
#   make -C Lab2/support -f commands.mk help
VEINS_ROOT ?= /home/maple/veins-5.3.1
OMNETPP_ROOT ?= /home/maple/omnetpp-6.1
SUMO ?= sumo
SUMO_GUI ?= sumo-gui
LAB2_CONFIG ?= General
LAB2_ARGS ?=

LAB2_SUPPORT_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
LAB2_CORE_DIR := $(abspath $(LAB2_SUPPORT_DIR)/../core)
LAB2_OUT_DIR := $(abspath $(LAB2_SUPPORT_DIR)/../out)
LAB2_NED_DIR := $(LAB2_OUT_DIR)/ned
LAB2_RESULTS_DIR := $(abspath $(LAB2_SUPPORT_DIR)/../results)
LAB2_RUNTIME_DIR := $(abspath $(LAB2_SUPPORT_DIR)/../runtime)
LAB2_CHART_WORKSPACE ?= /tmp/eie575_lab2_chart_workspace
PROJECT_ROOT := $(abspath $(LAB2_SUPPORT_DIR)/../..)
export PATH := $(OMNETPP_ROOT)/bin:$(PATH)

.DEFAULT_GOAL := help
.PHONY: help lab2-netconvert lab2-opp-nedtool lab2-nedpath lab2-build \
        lab2-veins-launchd-sumo lab2-veins-launchd-sumo-gui \
        lab2-omnetpp-cmdenv lab2-omnetpp-qtenv lab2-opp-charttool

help:
	@printf '%s\n' \
	  'Use: make -C Lab2/support -f commands.mk <target>' \
	  '  lab2-opp-nedtool                Validate the core and compatibility NED files.' \
	  '  lab2-build                      Compile the compatibility library.' \
	  'Terminal 1: start ONE proxy and leave it running:' \
	  '  lab2-veins-launchd-sumo          Start the proxy for background SUMO.' \
	  '  lab2-veins-launchd-sumo-gui      Start the proxy for graphical SUMO.' \
	  'Terminal 2: run OMNeT++:' \
	  '  lab2-omnetpp-cmdenv              Run without an OMNeT++ GUI.' \
	  '  lab2-omnetpp-qtenv               Open the OMNeT++ GUI.' \
	  '  lab2-opp-charttool               Export the existing General result plots.' \
	  'Stop the old proxy with Ctrl+C before switching proxy modes.'

lab2-netconvert:
	$(MAKE) -C "$(PROJECT_ROOT)/Lab1" lab1-netconvert

lab2-opp-nedtool: lab2-netconvert
	test -r "$(VEINS_ROOT)/src/libveins.so"
	"$(OMNETPP_ROOT)/bin/opp_nedtool" validate \
	  "$(LAB2_CORE_DIR)/package.ned" "$(LAB2_CORE_DIR)/lab2.ned" \
	  "$(LAB2_SUPPORT_DIR)/compat/Lab2TraCIMobility.ned"

$(LAB2_OUT_DIR)/Makefile: $(LAB2_SUPPORT_DIR)/commands.mk $(LAB2_SUPPORT_DIR)/.oppbuildspec $(LAB2_SUPPORT_DIR)/compat/Lab2TraCIMobility.cc
	mkdir -p "$(LAB2_OUT_DIR)"
	ln -sfn ../support/compat/Lab2TraCIMobility.cc "$(LAB2_OUT_DIR)/Lab2TraCIMobility.cc"
	cd "$(LAB2_OUT_DIR)" && "$(OMNETPP_ROOT)/bin/opp_makemake" \
	  -f --make-so -P . -o lab2 -O . \
	  -I"$(LAB2_SUPPORT_DIR)/compat" \
	  -I"$(VEINS_ROOT)/src" -L"$(VEINS_ROOT)/src" -lveins

# The course and Veins share org.car2x.veins. Load one package.ned for both.
lab2-nedpath:
	python3 "$(LAB2_SUPPORT_DIR)/prepare_ned.py" \
	  "$(LAB2_CORE_DIR)" "$(VEINS_ROOT)/src/veins" "$(LAB2_NED_DIR)"

lab2-build: lab2-opp-nedtool lab2-nedpath $(LAB2_OUT_DIR)/Makefile
	$(MAKE) -C "$(LAB2_OUT_DIR)" MODE=release

lab2-veins-launchd-sumo: lab2-netconvert
	cd "$(LAB2_SUPPORT_DIR)" && "$(VEINS_ROOT)/bin/veins_launchd" -vv -c "$(SUMO)"

lab2-veins-launchd-sumo-gui: lab2-netconvert
	cd "$(LAB2_SUPPORT_DIR)" && "$(VEINS_ROOT)/bin/veins_launchd" -vv -s \
	  -c "'$(SUMO_GUI)' {} --gui-settings-file '$(PROJECT_ROOT)/Lab1/lab1.sumo_gui_settings.xml' --delay 100"

lab2-omnetpp-cmdenv: lab2-build
	mkdir -p "$(LAB2_RUNTIME_DIR)" "$(LAB2_RESULTS_DIR)"
	cd "$(LAB2_RUNTIME_DIR)" && "$(OMNETPP_ROOT)/bin/opp_run_release" \
	  -l "$(VEINS_ROOT)/src/veins" -l "$(LAB2_OUT_DIR)/lab2" \
	  -n "$(LAB2_NED_DIR);$(LAB2_SUPPORT_DIR)/compat" \
	  --image-path="$(VEINS_ROOT)/images" \
	  -u Cmdenv -c "$(LAB2_CONFIG)" \
	  --result-dir="$(LAB2_RESULTS_DIR)" $(LAB2_ARGS) "$(LAB2_CORE_DIR)/omnetpp.ini"

lab2-omnetpp-qtenv: lab2-build
	mkdir -p "$(LAB2_RUNTIME_DIR)" "$(LAB2_RESULTS_DIR)"
	cd "$(LAB2_RUNTIME_DIR)" && "$(OMNETPP_ROOT)/bin/opp_run_release" \
	  -l "$(VEINS_ROOT)/src/veins" -l "$(LAB2_OUT_DIR)/lab2" \
	  -n "$(LAB2_NED_DIR);$(LAB2_SUPPORT_DIR)/compat" \
	  --image-path="$(VEINS_ROOT)/images" \
	  -u Qtenv -c "$(LAB2_CONFIG)" \
	  --result-dir="$(LAB2_RESULTS_DIR)" $(LAB2_ARGS) "$(LAB2_CORE_DIR)/omnetpp.ini"

lab2-opp-charttool:
	mkdir -p "$(LAB2_CHART_WORKSPACE)"
	cd "$(LAB2_SUPPORT_DIR)" && "$(OMNETPP_ROOT)/bin/opp_charttool" imageexport lab2.anf \
	  -w "$(LAB2_CHART_WORKSPACE)" \
	  -p "/lab2=$(LAB2_SUPPORT_DIR)" "/veins=$(VEINS_ROOT)" \
	  -f png -d "$(LAB2_RESULTS_DIR)/plots" --dpi 150
