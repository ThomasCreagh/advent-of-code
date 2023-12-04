use nom::{
    bytes::complete::{tag, take_until, take_while},
    character::complete::{char, digit1, multispace0},
    combinator::map_res,
    multi::separated_list0,
    sequence::{preceded, separated_pair, terminated},
    IResult,
};
use std::fs;

fn main() {
    let file_path = "input2.txt";
    let input = fs::read_to_string(file_path).unwrap();
    println!("{}", part2(&input));
}

fn remove_card(input: &str) -> IResult<&str, &str> {
    take_until(": ")(input)
}

fn remove_space_and_colon(input: &str) -> IResult<&str, &str> {
    terminated(tag(": "), take_while(|c| c == ' '))(input)
}

fn get_integer(input: &str) -> IResult<&str, u32> {
    map_res(preceded(multispace0, digit1), str::parse)(input)
}

fn separate_list(input: &str) -> IResult<&str, Vec<u32>> {
    separated_list0(terminated(char(' '), multispace0), get_integer)(input)
}

fn split_lists(input: &str) -> IResult<&str, (Vec<u32>, Vec<u32>)> {
    separated_pair(separate_list, tag(" | "), separate_list)(input)
}

fn up_till_card_num(input: &str) -> IResult<&str, &str> {
    tag("Card ")(input)
}

fn part2(input: &str) -> String {
    let data: Vec<u32> = input
        .lines()
        .into_iter()
        .map(|line| {
            let remaining = match up_till_card_num(line) {
                Ok((remaining_input, _)) => remaining_input,
                Err(e) => panic!("{e}"),
            };
            let (remaining, number) = match remove_card(remaining) {
                Ok((remaining_input, number)) => (remaining_input, number),
                Err(e) => panic!("{e}"),
            };
            let _number = match get_integer(number) {
                Ok((_, parsed_num)) => parsed_num,
                Err(e) => panic!("{e}"),
            };
            let remaining = match remove_space_and_colon(remaining) {
                Ok((remaining_input, _)) => remaining_input,
                Err(e) => panic!("{e}"),
            };
            let (left_vec, right_vec) = match split_lists(remaining) {
                Ok((_, (left, right))) => (left, right),
                Err(e) => panic!("{e}"),
            };
            left_vec
                .into_iter()
                .filter(|item| right_vec.contains(item))
                .collect::<Vec<u32>>()
                .len() as u32
        })
        .collect::<Vec<u32>>();
    let mut card_amounts: Vec<u32> = vec![1; data.len()];
    for (i, v) in data.into_iter().enumerate() {
        for j in i..((i as u32) + v) as usize {
            card_amounts[j + 1] += card_amounts[i]
        }
    }
    let answer: u32 = card_amounts.into_iter().sum();
    answer.to_string()
}

#[cfg(test)]
mod test {
    #[test]
    fn given_io() {
        use super::*;

        let input = "Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11";
        let result = part2(input);
        assert_eq!("30", result);
    }
}
