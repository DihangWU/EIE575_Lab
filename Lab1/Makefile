NETCONVERT ?= netconvert
SUMO ?= sumo
SUMO_GUI ?= sumo-gui

.DEFAULT_GOAL := lab1-netconvert

.PHONY: lab1-netconvert lab1-sumo lab1-sumo-gui

# Lab 1: netconvert creates the road network used by both labs.
lab1-netconvert: lab1.net.xml

lab1.net.xml: lab1.nod.xml lab1.edg.xml lab1.conn.xml
	$(NETCONVERT) \
	  --node-files=lab1.nod.xml \
	  --edge-files=lab1.edg.xml \
	  --connection-files=lab1.conn.xml \
	  --output-file=lab1.net.xml

lab1-sumo: lab1-netconvert
	$(SUMO) -c lab1.sumo.cfg

lab1-sumo-gui: lab1-netconvert
	$(SUMO_GUI) -c lab1.sumo.cfg \
	  --gui-settings-file lab1.sumo_gui_settings.xml \
	  --delay 100
