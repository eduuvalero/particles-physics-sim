import os

def get_results_dir():
    base = 'results'
    os.makedirs(base, exist_ok=True)
    
    i = 1
    while os.path.exists(f'{base}/sim{i}'):
        i += 1
    
    sim_dir = f'{base}/sim{i}'
    os.makedirs(sim_dir)
    return sim_dir

if __name__ == '__main__':
    print(get_results_dir())