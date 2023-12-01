with open("input.txt", "r") as reader:
    data = reader.readlines()

total_sum = 0
for line in data:
    for i in line:
        if i.isnumeric():
            total_sum += int(i)*10
            break
    for i in reversed(line):
        if i.isnumeric():
            total_sum += int(i)
            break
print(total_sum)
# 55816