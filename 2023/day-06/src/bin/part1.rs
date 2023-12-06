use std::fs;

#[derive(Debug)]
struct Race {
    time: u32,
    distance: u32,
}

fn main() {
    let file_path = "input1.txt";
    let input = fs::read_to_string(file_path).unwrap();
    println!("{}", part1(&input));
}

fn parser(input: &str) -> Vec<Race> {
    let lines: Vec<Vec<u32>> = input
        .lines()
        .map(|line| {
            line.split_whitespace()
                .flat_map(|word| word.parse::<u32>())
                .collect()
        })
        .collect::<Vec<Vec<u32>>>();
    (0..lines[0].len())
        .into_iter()
        .map(|i| Race {
            time: lines[0][i],
            distance: lines[1][i],
        })
        .collect()
}

fn part1(input: &str) -> String {
    let races: u32 = parser(input)
        .iter()
        .map(|race| {
            (0..race.time)
                .into_iter()
                .map(|time| {
                    if time * (race.time - time) > race.distance {
                        1
                    } else {
                        0
                    }
                })
                .sum::<u32>()
        })
        .product();
    races.to_string()
}

#[cfg(test)]
mod test {
    #[test]
    fn given_io() {
        use super::*;

        let input = "Time:      7  15   30
Distance:  9  40  200";
        let result = part1(input);
        assert_eq!("288", result)
    }
}
