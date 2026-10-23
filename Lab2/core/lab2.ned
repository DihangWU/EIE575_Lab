package org.car2x.veins;

import org.car2x.veins.nodes.RSU;
import org.car2x.veins.nodes.Scenario;

network hello extends Scenario
{
    submodules:
        rsu[1]: RSU
        {
            @display("p=150,140;i=veins/sign/yellowdiamond;is=vs;r=500");
        }
}
