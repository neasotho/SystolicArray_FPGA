import sys
import numpy as np

M = int(sys.argv[1])
N = int(sys.argv[2])

f_m0 = open("m0.mem", "w") 


for i in range(int(M*M)):
    line = str(0) + str(int(np.random.uniform(0,10)))
    f_m0.write(line+"\n")
f_m0.close()

f_m1 = open("m1.mem", "w") 

for i in range(int(M*M)):
    line = str(0) + str(int(np.random.uniform(0,10)))
    f_m1.write(line+"\n")
f_m1.close()
