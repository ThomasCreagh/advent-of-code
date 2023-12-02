use std::fs;

fn main() {
    let file_path = "../../input1.txt";
    let input = fs::read_to_string(file_path).unwrap();
    part1(&input);
}

fn part1(input: &str) -> String {
    let lines = input.split("\n").collect::<Vec<&str>>();
    let mut sum = 0;

    for line in lines {
        for i in line.chars() {
            if i.is_numeric() {
                sum += (i.to_string()).parse::<i32>().unwrap()*10;
                break;
            }
        } 
        for i in line.chars().rev() {
            if i.is_numeric() {
                sum += (i.to_string()).parse::<i32>().unwrap();
                break;
            }
        } 
    }
    return sum.to_string();
}

#[cfg(test)]
mod test {
    #[test]
    fn given_io() {
        use super::*;

        let input = "1abc2
                pqr3stu8vwx
                a1b2c3d4e5f
                treb7uchet";
        let result = part1(input);
        assert_eq!("142", result)
    }
}
