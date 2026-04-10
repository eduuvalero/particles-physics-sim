#include "Particle.h"
#include <stdexcept>

Particle::Particle(std::array<long double, kDIMENSION> pos, std::array<long double, kDIMENSION> vel, long double m, long double q, long double r) 
    : position(pos), velocity(vel), acceleration{0,0,0}, mass(m), charge(q), radius(r)
{
    if(m <= 0) throw std::invalid_argument("Mass must be positive");
    if(r <= 0) throw std::invalid_argument("Radius must be positive");
}

void Particle::updatePosition(long double dt){
    for(int d = 0; d < kDIMENSION; d++){
        position[d] += velocity[d] * dt + 0.5 * acceleration[d] * dt *  dt;
    }
}