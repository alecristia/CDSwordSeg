import sys

with open(sys.argv[1]) as listf:
    for line1 in listf:
        arr1 = line1.split()
        if len(arr1) == 2:
            with open(sys.argv[2]) as dictf:
                for line2 in dictf:
                    arr2 = line2.split()
                    if arr1[0] == arr2[1]:
                        print arr2[0] + "\t" + arr1[0] + "\t" + arr1[1]
                        break
        else:
            print line1
