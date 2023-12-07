use std::{fs, u32};

fn main() {
    let file_path = "input1.txt";
    let input = fs::read_to_string(file_path).unwrap();
    println!("{}", part1(&input));
}

fn part1(input: &str) -> String {
    let cards = vec![
        "A", "K", "Q", "J", "T", "9", "8", "7", "6", "5", "4", "3", "2", "1",
    ];
    let mut sort_val_and_bid = input
        .lines()
        .map(|line| {
            let mut occurrences: Vec<_> = cards
                .iter()
                .map(|card| {
                    line.split(" ")
                        .nth(0)
                        .unwrap()
                        .match_indices(card)
                        .collect::<Vec<_>>()
                        .iter()
                        .map(|(i, _)| i)
                        .collect::<Vec<_>>()
                        .len()
                })
                .collect();

            occurrences.sort();
            occurrences.retain(|&x| x != 0);

            let mut hand_type = match occurrences.as_slice() {
                &[5] => 7,
                &[1, 4] => 6,
                &[2, 3] => 5,
                &[1, 1, 3] => 4,
                &[1, 2, 2] => 3,
                &[1, 1, 1, 2] => 2,
                _ => 1,
            }
            .to_string();
            let card_convert = line
                .split(" ")
                .nth(0)
                .unwrap()
                .replace("A", "E")
                .replace("K", "D")
                .replace("Q", "C")
                .replace("J", "B")
                .replace("T", "A");

            hand_type.push_str(&format!("{}", card_convert));
            let bid = line.split(" ").nth(1).unwrap().parse().unwrap();
            let intval = isize::from_str_radix(&hand_type, 15).unwrap();
            (intval, bid)
        })
        .collect::<Vec<(isize, u32)>>();
    sort_val_and_bid.sort_by(|val, bid| val.cmp(&bid));
    let answer: u32 = sort_val_and_bid
        .iter()
        .enumerate()
        .map(|(index, (_, bid))| bid * ((index + 1) as u32))
        .sum();
    answer.to_string()
}

#[cfg(test)]
mod test {
    #[test]
    fn given_io() {
        use super::*;

        let input = "32T3K 765
T55J5 684
KK677 28
KTJJT 220
QQQJA 483";
        let result = part1(input);
        assert_eq!("6440", result)
    }
}
