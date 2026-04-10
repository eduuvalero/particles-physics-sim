
#ifndef _PHYSICS_H_
#define _PHYSICS_H_

#include <vector>
#include "Particle.h"

const long double G = 6.674e-11;
const long double K = 9.988e9;

struct Collision {
    size_t i, j;
};

class Physics{
    private:
        std::vector <Particle> particles;
        long double dt;
        std::vector<Collision> collisions;

        void computeAccelerations();
        void handleCollisions();  
        void integrate();     
        long double computeDistance(const long double d[kDIMENSION]) const;
        void computeDistanceVector(const Particle& a, const Particle& b, long double d[kDIMENSION]) const;
        void computeUnitVector(const long double d[kDIMENSION], long double dist, long double u[kDIMENSION]) const;

    public:
        Physics(long double dt);    
        void addParticle(const Particle& p);
        void step();             
        std::vector<Particle>& getParticles();
};

#endif
