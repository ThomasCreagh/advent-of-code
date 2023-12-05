// use itertools::Itertools;
use nom::{
    bytes::complete::{tag, take_until, take_while},
    character::complete::{char, digit1, multispace0},
    combinator::map_res,
    multi::separated_list0,
    sequence::{preceded, separated_pair, terminated},
    IResult,
};
// use std::error::Error;
use std::fs;
fn main() {
    let file_path = "input1.txt";
    let input = fs::read_to_string(file_path).unwrap();
    println!("answer: {}", part1(&input));
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

fn part1(input: &str) -> String {
    let data: u32 = input
        .lines()
        .into_iter()
        .map(|line| {
            let (remaining, _) = up_till_card_num(line).unwrap();
            let (remaining, _) = remove_card(remaining).unwrap();
            let (remaining, _) = remove_space_and_colon(remaining).unwrap();
            let (_, (left_vec, right_vec)) = split_lists(remaining).unwrap();
            let sum: u32 = left_vec
                .into_iter()
                .filter(|item| right_vec.contains(item))
                .collect::<Vec<u32>>()
                .len() as u32;
            if sum <= 0 {
                return 0;
            }
            let answer: u32 = 2;
            answer.pow(sum - 1)
        })
        .sum();
    data.to_string()
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
        let result = part1(input);
        assert_eq!("13", result)
    }
}
