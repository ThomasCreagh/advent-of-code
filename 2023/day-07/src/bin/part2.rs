use std::fs;

fn main() {
    let file_path = "input2.txt";
    let input = fs::read_to_string(file_path).unwrap();
    println!("{}", part2(&input));
}

fn part2(input: &str) -> String {
    let cards = vec![
        "A", "K", "Q", "J", "T", "9", "8", "7", "6", "5", "4", "3", "2", "1",
    ];
    let mut sort_val_and_bid = input
        .lines()
        .map(|line| {
            let find_items: Vec<_> = cards
                .iter()
                .map(|card| {
                    line.split(" ")
                        .nth(0)
                        .unwrap()
                        .match_indices(card)
                        .collect::<Vec<_>>()
                })
                .collect();
            let mut cards_list = find_items
                .iter()
                .map(|card| {
                    (
                        (
                            if card.len() > 0 {
                                if card[0].1 == "J" {
                                    0
                                } else {
                                    card.iter().map(|(i, _)| i).collect::<Vec<_>>().len()
                                }
                            } else {
                                card.iter().map(|(i, _)| i).collect::<Vec<_>>().len()
                            },
                            if card.len() > 0 {
                                match card[0].1 {
                                    "T" => 10,
                                    "Q" => 12,
                                    "J" => 0,
                                    "K" => 13,
                                    "A" => 14,
                                    _ => card[0].1.parse::<usize>().unwrap(),
                                }
                            } else {
                                0
                            },
                        ),
                        if card.len() > 0 { card[0].1 } else { "" },
                    )
                })
                .collect::<Vec<((usize, usize), &str)>>();
            cards_list.sort_by(|(a1, _), (a2, _)| a1.partial_cmp(a2).unwrap());
            let great_card = cards_list.last().unwrap();

            let new_line = line.replace("J", &great_card.1);
            let mut occurrences: Vec<_> = cards
                .iter()
                .map(|card| {
                    new_line
                        .split(" ")
                        .nth(0)
                        .unwrap()
                        .match_indices(card)
                        .collect::<Vec<_>>()
                })
                .collect::<Vec<_>>()
                .iter()
                .map(|card| card.iter().map(|(i, _)| i).collect::<Vec<_>>().len())
                .collect();
            occurrences.sort();
            occurrences.retain(|&x| x != 0);

            let hand_type = match occurrences.as_slice() {
                &[5] => 7,
                &[1, 4] => 6,
                &[2, 3] => 5,
                &[1, 1, 3] => 4,
                &[1, 2, 2] => 3,
                &[1, 1, 1, 2] => 2,
                &[] => 7,
                _ => 1,
            };

            let card_convert = line
                .split(" ")
                .nth(0)
                .unwrap()
                .replace("A", "E")
                .replace("K", "D")
                .replace("Q", "C")
                .replace("J", "0")
                .replace("T", "A");

            let bid = line.split(" ").nth(1).unwrap().parse().unwrap();
            let intval = isize::from_str_radix(&card_convert, 15).unwrap();

            ((hand_type as isize, intval), bid)
        })
        .collect::<Vec<((isize, isize), u32)>>();
    sort_val_and_bid.sort_by(|(a1, _), (a2, _)| a1.partial_cmp(a2).unwrap());
    let answer: u32 = sort_val_and_bid
        .iter()
        .enumerate()
        .map(|(index, ((_, _), bid))| bid * ((index + 1) as u32))
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
        let result = part2(input);
        assert_eq!("5905", result);
    }

    #[test]

    fn all_j() {
        use super::*;

        let input = "QQQQ2 1
JKKK2 10
33221 100
22331 1000";
        let result = part2(input);
        assert_eq!("1234", result);

        let input1 = "A2345 100
6789T 200
KKKKJ 50
JJJTJ 75
QT9KJ 120";
        let result1 = part2(input1);
        assert_eq!("1310", result1);

        let input2 = "J2345 100
6789J 200
JJJKJ 50
JJJTJ 75
QT9KJ 120";
        let result2 = part2(input2);
        assert_eq!("1410", result2);

        let input3 = "2345J 765
6789J 684
JJJJJ 28
JJJTJ 220
JJQJJ 483";
        let result3 = part2(input3);
        assert_eq!("5512", result3);
    }
}
