#ifndef _PARTICLE_H_
#define _PARTICLE_H_

#include <array>

const int x = 0;
const int y = 1;
const int z = 2;
const int kDIMENSION = 3;

class Particle{
    public:
        std::array<long double, kDIMENSION> position; // position in meters
        std::array<long double, kDIMENSION> velocity; // velocity in meters per second
        std::array<long double, kDIMENSION> acceleration;
        long double mass; // Mass in kilograms
        long double charge; // Charge in Coulumbs
        long double radius; // Radious in meters

        Particle(std::array<long double, kDIMENSION> position, std::array<long double, kDIMENSION> velocity, long double mass, long double charge, long double radius);

        void updatePosition(long double dt);
};

#endif 