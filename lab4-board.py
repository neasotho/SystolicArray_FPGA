import sys
import pynq
import pynq.lib.dma
import numpy as np
from pynq import Overlay
from pynq import DefaultIP
from pynq import DefaultHierarchy
from pynq import Xlnk
from pynq import MMIO
from pprint import pprint
import random

M=int(sys.argv[1])
N=int(sys.argv[2])


xlnk=Xlnk()
ol = Overlay('./tutorial.bit')

####this prints all the IPs inside
pprint(ol.ip_dict)

# load inputs
in_buffer = xlnk.cma_array(shape=(2*M*M,), dtype=np.uint32)
out_buffer = xlnk.cma_array(shape=(M*M,), dtype=np.uint32)


for i in range(0,len(in_buffer)):
    in_buffer[i]=random.randint(1,9) 
    
m0 = np.zeros((M,M))
for i in range(M*M):
    base_row = int(i*N/(M*M))
    base_column = int(int(i%M)/N)
    column=int(base_column*N) + (int(i%N))
    row = base_row + int((i%((M*M)/N))/M)*N
    m0[row][column] = in_buffer[i]


m1 = np.zeros((M,M))
for i in range(M*M):
    base_column = int(i*N/(M*M))
    base_row = int(int(i%M)/N)
    row=int(base_row*N) + (int(i%N))
    column = base_column + int((i%((M*M)/N))/M)*N
    m1[row][column] = in_buffer[i+M*M]

ol.mm_eval.axi_dma.recvchannel.transfer(out_buffer)
ol.mm_eval.axi_dma.sendchannel.transfer(in_buffer)
ol.mm_eval.axi_dma.sendchannel.wait()
ol.mm_eval.axi_dma.recvchannel.wait()

m2 = np.zeros((M,M))
for i in range(M*M):
    base_row = int(i*N/(M*M))
    base_column = int(int(i%M)/N)
    column=int(base_column*N) + (N-1-int(i%N))
    row = base_row + int((i%((M*M)/N))/M)*N
    m2[row][column] = out_buffer[i]

m2_truth = np.matmul(m0,m1)
print("Matrix 0 (m0) is")
print(m0)    
print("Matrix 1 (m1) is")
print(m1)  
print("Answer is")
print(m2_truth)
print("Your answer is:")
print(m2)
print("##########")

if np.array_equal(m2,m2_truth):
    print("Thank Mr. Goose")
else:
    print("HISSSSS!!")
print("##########")
