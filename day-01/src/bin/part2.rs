use std::fs;

fn main() {
    let file_path = "input.txt";
    println!("In file {}", file_path);

    let contents = fs::read_to_string(file_path).unwrap();
    let lines = contents.split("\n").collect::<Vec<&str>>();
    let mut sum = 0;

    for line in lines {
        if line == "" || line == "\n" {
            continue;
        }
        let mut numbers_in_list: Vec<_> = Vec::<(usize, &str)>::new();
        let numbers = ["one", "two", "three", "four",
                "five", "six", "seven", "eight", "nine", "1", "2",
                "3", "4", "5", "6", "7", "8", "9"];
        for word_number in numbers {
            numbers_in_list.append(&mut line.match_indices(word_number).collect());
        
        }

        let numbers = ["one", "two", "three", "four",
                "five", "six", "seven", "eight", "nine"];

        let left_digit = numbers_in_list.iter().min_by_key(|d| &d.0).unwrap().1;
        let right_digit = numbers_in_list.iter().max_by_key(|d| &d.0).unwrap().1;

        if numbers.contains(&left_digit) {
            sum += (numbers.iter().position(|&r| r == left_digit).unwrap() + 1) * 10;
        } else {
            sum += left_digit.to_string().parse::<usize>().unwrap() * 10;
        }

        if numbers.contains(&right_digit) {
            sum += numbers.iter().position(|&r| r == right_digit).unwrap() + 1;
        } else {
            sum += right_digit.to_string().parse::<usize>().unwrap();
        }
    }
    println!("sum: {sum}");
}
// 54980
