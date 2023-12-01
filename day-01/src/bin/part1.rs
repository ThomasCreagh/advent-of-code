use std::fs;

fn main() {
    let file_path = "input.txt";
    println!("In file {}", file_path);

    let contents = fs::read_to_string(file_path).unwrap();
    let lines = contents.split("\n").collect::<Vec<&str>>();
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
    println!("sum: {sum}");
}
// 55816
