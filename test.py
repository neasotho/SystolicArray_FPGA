import numpy as np
import sys

N = int(sys.argv[1])

mem0 = open("m0.mem")
depth_mem0 = len(mem0.readlines())

M = np.sqrt(depth_mem0)

m0 = np.zeros((int(M),int(M)))
m1 = np.zeros((int(M),int(M)))
m2 = np.zeros((int(M),int(M)))




mem0 = open("m0.mem")
i=0
for line in mem0:
        base_row = int(i*N/(M*M))
        base_column = int(int(i%M)/N)
        column=int(base_column*N) + (int(i%N))
        row = base_row + int((i%((M*M)/N))/M)*N#base_row + int((int(i%int((M*M)/N))/M)*N)
        #print(i,base_row,row,base_column,column)
        m0[row][column] = int(line,16)
        i+=1

mem1 = open("m1.mem")
i=0
for line in mem1:
        base_column = int(i*N/(M*M))
        base_row = int(int(i%M)/N)
        row=int(base_row*N) + (int(i%N))
        column = base_column + int((i%((M*M)/N))/M)*N#base_row + int((int(i%int((M*M)/N))/M)*N)
        m1[row][column] = int(line,16)
        i+=1


mem2 = open("m2.mem")
i=0
for line in mem2:
    if(line[0]!="/"):
        base_row = int(i*N/(M*M))
        base_column = int(int(i%M)/N)
        column=int(base_column*N) + (N-1-int(i%N))
        row = base_row + int((i%((M*M)/N))/M)*N#base_row + int((int(i%int((M*M)/N))/M)*N)
        m2[row][column] = int(line,16)
        i+=1
truth=np.matmul(m0,m1)
print("Matrix 0 (m0) is")
print(m0)    
print("Matrix 1 (m1) is")
print(m1)  
print("Answer is")
print(truth)
print("Your answer is:")
print(m2)
print("##########")
if np.array_equal(m2,truth):
    print("Thank Mr. Goose")
else:
    print("HISSSSS!!")
print("##########")
