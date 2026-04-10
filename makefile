CC = g++
OBJS = simulator/Particle.o simulator/Physics.o simulator/main.o
FLAGS = -std=c++17 -Wall -g -fopenmp

simulator/simulator: $(OBJS)
	$(CC) $(FLAGS) $(OBJS) -o simulator/simulator

simulator/main.o: simulator/main.cc simulator/Particle.h simulator/Physics.h
	$(CC) $(FLAGS) -c simulator/main.cc -o simulator/main.o

simulator/Physics.o: simulator/Physics.cc simulator/Particle.h simulator/Physics.h
	$(CC) $(FLAGS) -c simulator/Physics.cc -o simulator/Physics.o

simulator/Particle.o: simulator/Particle.cc simulator/Particle.h
	$(CC) $(FLAGS) -c simulator/Particle.cc -o simulator/Particle.o

clean:
	rm -f $(OBJS) simulator/simulator

.PHONY: clean