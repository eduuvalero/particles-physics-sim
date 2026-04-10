
#include <iostream>
#include <fstream>
#include <string>
#include <sstream>
#include <vector>
#include <stdexcept>

#include "Particle.h"
#include "Physics.h"

using namespace std;

const string dataset = "data/dataset.csv";
const string config = "data/config.csv";
const string outputFile = "data/particles.csv";

void importConfig(long double& dt, int& steps){
    ifstream file(config);
    string line, value;

    if(!file.is_open()){
        throw runtime_error("config.csv could not be opened");
    }

    getline(file, line);
    if(!getline(file, line)){
        throw invalid_argument("config.csv must contain one data row");
    }

    stringstream sLine(line);

    getline(sLine, value, ',');
    steps = stoi(value);
    if(steps <= 0){
        throw invalid_argument("steps must be greater than 0");
    }

    getline(sLine, value);
    dt = stold(value);
    if(dt <= 0){
        throw invalid_argument("dt must be greater than 0");
    }

    file.close();
}

vector<Particle> importParticles(){
    vector<Particle> particles;
    ifstream file(dataset);
    string line;

    if(!file.is_open()){
        throw runtime_error("dataset.csv could not be opened");
    }

    string value;
    getline(file, line);

    while(getline(file, line)){
        stringstream sLine(line);
        long double data[2*kDIMENSION + 3];
        int i = 0;

        while(getline(sLine, value, ',')){
            data[i++] = stold(value);
        }

        if(i != 2*kDIMENSION + 3) continue;

        std::array<long double, 3> pos;
        std::array<long double, 3> vel;

        for (int j = 0; j < kDIMENSION; j++)
            pos[j] = data[j];

        for (int j = 0; j < kDIMENSION; j++)
            vel[j] = data[j + kDIMENSION];

        long double mass = data[2*kDIMENSION];
        long double charge = data[2*kDIMENSION + 1];
        long double radius = data[2*kDIMENSION + 2];

        particles.emplace_back(pos, vel, mass, charge, radius);
    }

    file.close();
    return particles;
}

void exportParticles(Physics& physics, int steps){
    ofstream file(outputFile);

    if(file.is_open()){
        file << "step,id,x,y,z,vx,vy,vz,ax,ay,az,mass,charge,radius\n";
        vector<Particle> &particles = physics.getParticles();
        for(int step = 0; step < steps; step++){
            physics.step();

            size_t i = 0;
            for(const Particle& p : particles){
                file << step << "," << i << ","
                    << p.position[x]        << "," << p.position[y]     << "," << p.position[z]     << ","
                    << p.velocity[x]        << "," << p.velocity[y]     << "," << p.velocity[z]     << ","
                    << p.acceleration[x]    << "," << p.acceleration[y] << "," << p.acceleration[z] << ","
                    << p.mass               << "," << p.charge          << "," << p.radius          << "\n";
                    i++;
            }
        }
        file.close();
    }
}

int main() {
    vector<Particle> particles;
    int steps;
    long double dt;

    try {
        importConfig(dt, steps);
    }
    catch(const std::exception &e){
        cerr << "Error importing config.csv: " << e.what() << std::endl;
        return 1;
    }

    try {
        particles = importParticles();
    }
    catch(const std::exception &e){
        cerr << "Error creating particles: " << e.what() << std::endl;
        return 1;
    }

    Physics physics(dt);
    for(const Particle& p : particles){
        physics.addParticle(p);
    }

    if(physics.getParticles().size() > 0){
        exportParticles(physics, steps);
    }
    else{
        cout << "Error. There isn't any particle"<< endl;
    }

    return 0;
}
