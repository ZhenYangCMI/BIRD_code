import os
import sys

numSub = 0


with open(sys.argv[1], 'r') as subList:

    for line in subList:

        if 'subject_id' in line:
            numSub = numSub + 1

print "Number of subjects in subject list: ", numSub, "\n"
