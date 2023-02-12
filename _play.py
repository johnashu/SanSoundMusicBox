
isBound = [0, 0, 789, 1055, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3829, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8313, 0, 0, 9166]

notBound = [452, 472, 0, 0, 1173, 1388, 1682, 1720, 1851, 2027, 2263, 2275, 2755, 3248, 3277, 3689, 3721, 3811, 0, 4268, 4964, 4965, 4966, 5082, 5474, 5557, 5622, 5826, 5844, 5845, 5976, 6035, 6168, 6206, 6208, 6237, 6244, 6271, 6272, 6277, 6289, 6323, 6391, 6412, 6422, 6455, 6456, 7168, 7178, 0, 8400, 8509, 0]


def removeZeros(l: list) -> list:
    removed = []

    for i in l:
        if int(i) != 0:
            removed.append(i)
    return removed

print(f'isBound = {removeZeros(isBound)}')
print(f'notBound = {removeZeros(notBound)}')

userLen = 2
split = 40 // userLen
for i in range(userLen): 
    start = i * split+1;   
    end = split * (i+1)
    print('start unbound', start)
    print('end', start + (split // userLen) - 1)
    print('start bound', start + (split // userLen))
    print('end', end)
