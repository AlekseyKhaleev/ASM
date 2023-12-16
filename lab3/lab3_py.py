def get_numbers():
    max_size = 8
    nums_arr = []
    while len(nums_arr) < max_size:
        print(f'Enter next number ({max_size - len(nums_arr)} remains):')
        if is_correct(num := input()):
            nums_arr.append(int(num))
        else:
            print('Incorrect input. Try again.\n')
    return nums_arr


def is_correct(num: str):
    if num.isdigit() or (num[0] == '-' and num[1:].isdigit()):
        return True
    return False


def process_array(nums_arr: list):
    sum = 0
    pos_lst = [num for num in nums_arr if num >= 0]
    neg_lst = [num for num in nums_arr if num < 0]
    for pos, neg in zip(pos_lst, neg_lst):
        sum += pos * neg
    return sum


if __name__ == '__main__':
    print(process_array(get_numbers()))
