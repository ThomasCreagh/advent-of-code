with open("input.txt", "r") as reader:
    data = reader.readlines()

data = """467..114..
...*......
..35..633.
......#...
617*......
.....+.58.
..592.....
......755.
...$.*....
.664.598.."""
data = data.split("\n")

sum = 0
for h, i in enumerate(data):
    for k in range(len(i)):
        if i[k].isnumeric():
            valid = True
            value = 0;
            for m in range(k, len(i)):
                if not i[m].isnumeric():
                    value = int(i[k:m])
                    if not (data[h][m] == "."):
                        valid = False
                    if m-1 >= 0 and data[h][m-1] != ".":
                        valid = False
                    if k-1 >= 0 and h-1 >= 0 and data[h-1][m] != ".":
                        valid = False
                    if k-1 >= 0 and h-1 >= 0 and data[h-1][m-1] != ".":
                        valid = False
                    if h+1 <= len(i)-1 and  data[h+1][m] != ".":
                        valid = False
                    if h+1 <= len(i)-1 and data[h+1][m-1] != ".":
                        valid = False
                    for n in range(m-k):
                        if h-1 
                        if (data[h-1][k+n] == "." and
                            data[h+1][k+n] == "."):
                            valid = False
                            break
            if valid:
                sum += value
print(sum)
