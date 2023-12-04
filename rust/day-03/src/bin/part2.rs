// IMPLEMENTATION BY chris biscardi
// just trying to learn more about run by doing..

use std::{collections::BTreeMap, fs};

use itertools::Itertools;

#[derive(Debug)]
enum Cell {
    Symbol(char),
    Empty,
    Number(u32),
}

fn main() {
    let file_path = "input2.txt";
    let input = fs::read_to_string(file_path).unwrap();
    println!("{}", part2(&input));
}

fn part2(input: &str) -> String {
    let map = input
        .lines()
        .enumerate()
        .flat_map(|(y, line)| {
            line.chars().enumerate().map(move |(x, character)| {
                (
                    (y as i32, x as i32),
                    match character {
                        '.' => Cell::Empty,
                        c if c.is_ascii_digit() => {
                            Cell::Number(c.to_digit(10).expect("should be a number"))
                        }
                        c => Cell::Symbol(c),
                    },
                )
            })
        })
        .collect::<BTreeMap<(i32, i32), Cell>>();

    let mut numbers: Vec<Vec<((i32, i32), u32)>> = vec![];
    for ((y, x), value) in map.iter() {
        if let Cell::Number(num) = value {
            match numbers.iter().last() {
                Some(v) => {
                    let last_num = v.iter().last();
                    match last_num {
                        Some(((last_num_x, _), _)) => {
                            if last_num_x + 1 == *x {
                                let last = numbers.iter_mut().last().expect("should exist");
                                last.push(((*x, *y), *num));
                            } else {
                                numbers.push(vec![((*x, *y), *num)]);
                            }
                        }
                        None => unimplemented!("shouldn't happen"),
                    }
                }
                None => {
                    numbers.push(vec![((*x, *y), *num)]);
                }
            }
        }
    }

    let mut sum = 0;
    for symbol in map
        .iter()
        .filter(|(_key, value)| matches!(value, Cell::Symbol('*')))
    {
        // (x,y)
        let positions = [
            (1, 0),
            (1, -1),
            (0, -1),
            (-1, -1),
            (-1, 0),
            (-1, 1),
            (0, 1),
            (1, 1),
        ];
        let pos_to_check: Vec<(i32, i32)> = positions
            .iter()
            .map(|outer_pos| (outer_pos.0 + symbol.0 .1, outer_pos.1 + symbol.0 .0))
            .collect();

        let mut indexes_of_numbers = vec![];

        for pos in pos_to_check {
            for (i, num_list) in numbers.iter().enumerate() {
                if num_list
                    .iter()
                    .find(|(num_pos, _)| num_pos == &pos)
                    .is_some()
                {
                    indexes_of_numbers.push(i);
                }
            }
        }

        let is_gear = indexes_of_numbers.iter().unique().count() == 2;

        if is_gear {
            sum += indexes_of_numbers
                .iter()
                .unique()
                .map(|index| {
                    numbers[*index]
                        .iter()
                        .map(|(_, num)| num.to_string())
                        .collect::<String>()
                        .parse::<usize>()
                        .unwrap()
                })
                .product::<usize>();
        }
    }

    sum.to_string()
}

#[cfg(test)]
mod test {
    #[test]
    fn given_io() {
        use super::*;

        let input = "467..114..
...*......
..35..633.
......#...
617*......
.....+.58.
..592.....
......755.
...$.*....
.664.598..";
        let result = part2(input);
        assert_eq!("467835", result);
    }
}
