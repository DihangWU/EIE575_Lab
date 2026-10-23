NETCONVERT ?= netconvert
SUMO ?= sumo
SUMO_GUI ?= sumo-gui

.DEFAULT_GOAL := help

.PHONY: help lab1-netconvert lab1-sumo lab1-sumo-gui \

# Lab 1: netconvert creates the road network used by both labs.
lab1-netconvert: Lab1/lab1.net.xml

Lab1/lab1.net.xml: Lab1/lab1.nod.xml Lab1/lab1.edg.xml Lab1/lab1.conn.xml
	cd Lab1 && $(NETCONVERT) \
	  --node-files=lab1.nod.xml \
	  --edge-files=lab1.edg.xml \
	  --connection-files=lab1.conn.xml \
	  --output-file=lab1.net.xml

lab1-sumo: lab1-netconvert
	$(SUMO) -c Lab1/lab1.sumo.cfg

lab1-sumo-gui: lab1-netconvert
	$(SUMO_GUI) -c Lab1/lab1.sumo.cfg \
	  --gui-settings-file Lab1/lab1.sumo_gui_settings.xml \
	  --delay 100
