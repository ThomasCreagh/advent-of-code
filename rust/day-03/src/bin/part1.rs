use std::fs;

fn main() {
    let file_path = "input1.txt";
    let input = fs::read_to_string(file_path).unwrap();
    println!("{}", part1(&input));
}

fn part1(input: &str) -> String {
    let data = input.split("\n").collect::<Vec<&str>>();
    for line in data {}
    todo!()
}

#[cfg(test)]
mod test {
    #[test]
    fn given_io() {
        use super::*;

        let input = "";
        let result = part1(input);
        assert_eq!("", result)
    }
}
