#include "Physics.h"
#include <cmath>
#include <array>

Physics::Physics(long double dt) : dt(dt), accelerations_initialized(false) {}

void Physics::addParticle(const Particle& p){ particles.push_back(p); }

void Physics::computeAccelerations(){
    collisions.clear();

    for(Particle& p : particles)
        for(int k = 0; k < kDIMENSION; k++)
            p.acceleration[k] = 0;

    #pragma omp parallel for schedule(dynamic)
    for(size_t i = 0; i < particles.size(); i++){
        for(size_t j = i + 1; j < particles.size(); j++){
            Particle &a = particles[i];
            Particle &b = particles[j];

            long double d[kDIMENSION];
            computeDistanceVector(a, b, d);
            long double dist = computeDistance(d);

            long double u[kDIMENSION];
            computeUnitVector(d, dist, u);

            long double gForce = (G * a.mass * b.mass) / (dist*dist);
            long double eForce = (K * a.charge * b.charge) / (dist*dist);

            long double gravForce[3];
            long double elctricForce[3];
            for(int k = 0; k < kDIMENSION; k++){
                gravForce[k] = - gForce *  u[k];
                elctricForce[k] = eForce *  u[k];
            }

            for(int k = 0; k < kDIMENSION; k++){
                #pragma omp atomic
                // Acceleration that a makes to b
                b.acceleration[k] += (gravForce[k] + elctricForce[k]) / b.mass;

                // Acceleration that b makes to a
                #pragma omp atomic
                a.acceleration[k] -= (gravForce[k] + elctricForce[k]) / a.mass;
            }

            if(dist < (a.radius + b.radius)){
                #pragma omp critical
                collisions.push_back({i,j});
            }
        }
    }
}

void Physics::step(){
    if(!accelerations_initialized){
        computeAccelerations();
        accelerations_initialized = true;
    }

    for(Particle& p : particles)
        p.updatePosition(dt);

    std::vector<std::array<long double, kDIMENSION>> acc_old(particles.size());
    for(size_t i = 0; i < particles.size(); i++)
        for(int k = 0; k < kDIMENSION; k++)
            acc_old[i][k] = particles[i].acceleration[k];

    computeAccelerations();

    for(size_t i = 0; i < particles.size(); i++)
        for(int k = 0; k < kDIMENSION; k++)
            particles[i].velocity[k] += 0.5*(acc_old[i][k] + particles[i].acceleration[k])*dt;

    handleCollisions();
}

void Physics::handleCollisions(){
    for(const Collision& c : collisions){
        Particle &a = particles[c.i];
        Particle &b = particles[c.j];

        long double d[kDIMENSION];
        computeDistanceVector(a, b, d);

        long double dist = computeDistance(d);

        long double n[kDIMENSION];
        computeUnitVector(d, dist, n);

        // velocity proyection
        long double vAn = 0, vBn = 0;
        for(int k = 0; k < kDIMENSION; k++){
            vAn += a.velocity[k] * n[k];
            vBn += b.velocity[k] * n[k];
        }

        // 1D elastic bound
        long double vAn_post = (vAn*(a.mass-b.mass) + 2*b.mass*vBn) / (a.mass+b.mass);
        long double vBn_post = (vBn*(b.mass-a.mass) + 2*a.mass*vAn) / (a.mass+b.mass);

        // update velocities
        for(int k = 0; k < kDIMENSION; k++){
            a.velocity[k] += (vAn_post - vAn) * n[k];
            b.velocity[k] += (vBn_post - vBn) * n[k];
        }

         // correct overlap
        long double overlap = (a.radius + b.radius - dist) / 2.0;
        for(int k = 0; k < kDIMENSION; k++){
            a.position[k] -= n[k] * overlap;
            b.position[k] += n[k] * overlap;
        }
    }
}

std::vector<Particle>& Physics::getParticles() { return particles; }

void Physics::computeDistanceVector(const Particle& a, const Particle& b, long double d[kDIMENSION]) const {
    for(int k = 0; k < kDIMENSION; k++)
        d[k] = b.position[k] - a.position[k];
}

long double Physics::computeDistance(const long double d[kDIMENSION]) const {
    long double dist = 0;
    for(int k = 0; k < kDIMENSION; k++)
        dist += d[k]*d[k];
    return sqrt(dist + 1e-29);
}

void Physics::computeUnitVector(const long double d[kDIMENSION], long double dist, long double u[kDIMENSION]) const {
    for(int k = 0; k < kDIMENSION; k++)
        u[k] = d[k] / dist;
}
