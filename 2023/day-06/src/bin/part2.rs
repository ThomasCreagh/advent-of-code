use std::fs;

use nom::sequence::Tuple;

#[derive(Debug)]
struct Race {
    time: u32,
    distance: u32,
}

fn main() {
    let file_path = "input2.txt";
    let input = fs::read_to_string(file_path).unwrap();
    println!("{}", part2(&input));
}

fn parser(input: &str) -> (u64, u64) {
    let mut numbers_iter = input
        .chars()
        .filter_map(|c| c.to_digit(10).map(|d| d as u64));

    let first = numbers_iter.by_ref().take(8).fold(0, |acc, x| acc * 10 + x);
    let second = numbers_iter
        .by_ref()
        .take(15)
        .fold(0, |acc, x| acc * 10 + x);

    (first, second)
}

fn part2(input: &str) -> String {
    let time_dist = parser(input);
    let race_time = (0..time_dist.0)
        .into_iter()
        .map(|time| {
            if time * (time_dist.0 - time) > time_dist.1 {
                1
            } else {
                0
            }
        })
        .sum::<u64>();
    race_time.to_string()
}

#[cfg(test)]
mod test {
    #[test]
    fn given_io() {
        use super::*;

        let input = "Time:      7  15   30
Distance:  9  40  200";
        let result = part2(input);
        assert_eq!("71503", result);
    }
}
