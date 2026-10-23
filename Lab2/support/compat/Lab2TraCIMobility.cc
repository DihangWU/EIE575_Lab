#include "veins/modules/mobility/traci/TraCIMobility.h"

// Register vectors while OMNeT++ is executing this mobility module's
// initialize(), rather than when TraCIScenarioManager first records a value.
// This preserves per-vehicle module paths with Veins 5.3.1 / OMNeT++ 6.1.
class Lab2TraCIMobility : public veins::TraCIMobility
{
  protected:
    void initialize(int stage) override
    {
        veins::TraCIMobility::initialize(stage);
        if (stage == 0) {
            currentPosXVec.registerVector();
            currentPosYVec.registerVector();
            currentSpeedVec.registerVector();
            currentAccelerationVec.registerVector();
            currentCO2EmissionVec.registerVector();
        }
    }
};

Define_Module(Lab2TraCIMobility);
